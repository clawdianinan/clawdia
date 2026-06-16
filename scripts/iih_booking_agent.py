#!/usr/bin/env python3
"""Poll, classify, and optionally respond to IIH facility booking mailbox messages.

This processor is intentionally stateful and conservative. It records messages,
tracks conversation threads, classifies new requests versus replies, and queues
the next booking action. When --auto-respond is enabled, it sends only approved
template responses for external booking enquiries/replies and never replies to
Google Form submissions.
"""

from __future__ import annotations

import argparse
import json
import re
import smtplib
import ssl
import sqlite3
import subprocess
from dataclasses import dataclass
from datetime import datetime
from email.message import EmailMessage
from email.utils import formatdate, make_msgid
from email.utils import parseaddr
from pathlib import Path
from typing import Any

import iih_booking_connectors as connectors


WORKSPACE_DIR = Path(__file__).resolve().parent.parent
BOOKING_DIR = WORKSPACE_DIR / "documents" / "IIH" / "Bookings"
STATE_PATH = BOOKING_DIR / "booking_agent.sqlite3"
ACCOUNT = "facilitybookings"
FOLDER = "INBOX"
EVENTS_CC = "events@iih.ng"
BOOKING_ADDRESS = "facilitybookings@iih.ng"
BOOKING_FORM_URL = "https://forms.gle/psuxSJ4MG1CqQWKD8"
CAFETERIA_MENU_URL = "https://drive.google.com/file/d/1Tyry0_1a6dNmfruWaXRIA4kE-60iwIIm/view?usp=sharing"
INTERNAL_DOMAINS = ("@iih.ng",)

BOOKING_TERMS = (
    "book",
    "booking",
    "hall",
    "venue",
    "facility",
    "space",
    "event",
    "meeting room",
    "main hall",
    "pitch hall",
    "use hall",
    "rent",
)
PAYMENT_TERMS = (
    "paid",
    "payment",
    "proof",
    "receipt",
    "transfer",
    "transaction",
    "remita",
    "invoice",
    "deposit",
)
SYSTEM_SENDERS = (
    "noreply@",
    "no-reply@",
    "zoho",
    "mailer-daemon",
)
FORM_SENDERS = (
    "forms-receipts-noreply@google.com",
    "forms-noreply@google.com",
    "googleforms-noreply@google.com",
)
FORM_TERMS = (
    "booking form",
    "facility booking",
    "new response",
    "google forms",
)
NO_REPLY_DOMAINS = (
    "@google.com",
    "@zoho.com",
    "@zohomail.com",
)


@dataclass
class MessageRecord:
    envelope_id: str
    subject: str
    sender_email: str
    sender_name: str
    date: str
    has_attachment: bool
    body: str
    headers: dict[str, str]
    raw: dict[str, Any]


def run_cmd(args: list[str], timeout: int = 30) -> str:
    result = subprocess.run(args, check=True, capture_output=True, text=True, timeout=timeout)
    return result.stdout


def now() -> str:
    return datetime.now().isoformat(timespec="seconds")


def normalize_subject(subject: str) -> str:
    subject = re.sub(r"^\s*(re|fw|fwd)\s*:\s*", "", subject, flags=re.I)
    subject = re.sub(r"\s+", " ", subject).strip().lower()
    return subject


def parse_headers_and_body(text: str) -> tuple[dict[str, str], str]:
    headers: dict[str, str] = {}
    lines = text.splitlines()
    body_start = 0
    current: str | None = None

    for idx, line in enumerate(lines):
        if not line.strip():
            body_start = idx + 1
            break
        if ":" in line and not line.startswith((" ", "\t")):
            name, value = line.split(":", 1)
            current = name.strip().lower()
            headers[current] = value.strip()
        elif current:
            headers[current] = f"{headers[current]} {line.strip()}".strip()
    else:
        body_start = min(len(lines), 12)

    return headers, "\n".join(lines[body_start:]).strip()


def extract_email_addresses(text: str) -> list[str]:
    emails = re.findall(r"[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}", text, flags=re.I)
    cleaned: list[str] = []
    for email in emails:
        normalized = email.lower().strip(".,;:<>[]()")
        if normalized not in cleaned:
            cleaned.append(normalized)
    return cleaned


def is_external_sender(email: str) -> bool:
    sender = email.lower()
    if sender == BOOKING_ADDRESS:
        return False
    if any(sender.endswith(domain) for domain in INTERNAL_DOMAINS):
        return False
    if any(sender.endswith(domain) for domain in NO_REPLY_DOMAINS):
        return False
    if any(term in sender for term in SYSTEM_SENDERS):
        return False
    return True


def sender_parts(envelope: dict[str, Any]) -> tuple[str, str]:
    raw_from = envelope.get("from") or {}
    if isinstance(raw_from, dict):
        return str(raw_from.get("addr") or "").lower(), str(raw_from.get("name") or "")
    name, addr = parseaddr(str(raw_from))
    return addr.lower(), name


def message_identity(headers: dict[str, str], envelope_id: str) -> str:
    return headers.get("message-id") or f"himalaya:{ACCOUNT}:{FOLDER}:{envelope_id}"


def thread_key_for(record: MessageRecord, conn: sqlite3.Connection) -> tuple[str, str]:
    is_form_response = record.sender_email.lower() in FORM_SENDERS or any(
        term in f"{record.subject}\n{record.body}".lower() for term in FORM_TERMS
    )
    if is_form_response:
        for email in extract_email_addresses(record.body):
            if email == BOOKING_ADDRESS or email.endswith(INTERNAL_DOMAINS) or email.endswith(NO_REPLY_DOMAINS):
                continue
            row = conn.execute(
                """
                SELECT thread_key FROM conversations
                WHERE client_email = ?
                ORDER BY updated_at DESC
                LIMIT 1
                """,
                (email,),
            ).fetchone()
            if row:
                return str(row[0]), "form_email_match"

    refs = " ".join(
        part for part in (record.headers.get("in-reply-to"), record.headers.get("references")) if part
    )
    if refs:
        for token in re.findall(r"<[^>]+>", refs) or [refs]:
            row = conn.execute(
                "SELECT thread_key FROM messages WHERE message_id = ? OR raw_headers LIKE ? ORDER BY processed_at DESC LIMIT 1",
                (token, f"%{token}%"),
            ).fetchone()
            if row:
                return str(row[0]), "header_reference"

    normalized = normalize_subject(record.subject)
    if normalized:
        row = conn.execute(
            """
            SELECT thread_key FROM conversations
            WHERE normalized_subject = ?
              AND (? = '' OR client_email = ? OR client_email = '')
            ORDER BY updated_at DESC
            LIMIT 1
            """,
            (normalized, record.sender_email, record.sender_email),
        ).fetchone()
        if row:
            return str(row[0]), "subject_match"

    return f"{record.sender_email}|{normalized or record.envelope_id}", "new_thread"


def extract_amounts(text: str) -> list[int]:
    amounts: list[int] = []
    patterns = [
        r"(?:NGN|N)\s*([0-9][0-9,]*(?:\.[0-9]{1,2})?)",
        r"\u20a6\s*([0-9][0-9,]*(?:\.[0-9]{1,2})?)",
        r"([0-9][0-9,]{4,})(?:\s*naira)?",
    ]
    for pattern in patterns:
        for match in re.findall(pattern, text, flags=re.I):
            try:
                amounts.append(int(float(str(match).replace(",", ""))))
            except ValueError:
                continue
    return sorted(set(amounts), reverse=True)


def classify(record: MessageRecord, conn: sqlite3.Connection, thread_key: str, thread_reason: str) -> dict[str, Any]:
    text = f"{record.subject}\n{record.body}".lower()
    sender = record.sender_email.lower()
    amounts = extract_amounts(f"{record.subject}\n{record.body}")

    existing = conn.execute(
        "SELECT status, invoice_total, invoice_id, client_email FROM conversations WHERE thread_key = ?",
        (thread_key,),
    ).fetchone()
    status = str(existing[0]) if existing else "New"
    invoice_total = int(existing[1]) if existing and existing[1] is not None else None

    is_form_response = sender in FORM_SENDERS or any(term in text for term in FORM_TERMS)

    if sender == BOOKING_ADDRESS:
        classification = "outbound_booking_response"
        next_action = "no_action_record_sent_response"
    elif is_form_response:
        classification = "form_submission_data"
        next_action = "link_form_submission_to_existing_enquiry_no_reply_prepare_invoice"
    elif any(term in sender for term in SYSTEM_SENDERS):
        classification = "system_update"
        next_action = "review_system_update"
    elif any(term in text for term in PAYMENT_TERMS) or record.has_attachment:
        classification = "payment_proof" if status in {"Invoice Sent", "Payment Pending"} else "payment_or_attachment"
        if invoice_total and invoice_total in amounts:
            next_action = "email_finance_for_payment_confirmation"
        elif invoice_total:
            next_action = "human_review_payment_amount"
        else:
            next_action = "link_invoice_before_payment_review"
    elif thread_reason != "new_thread":
        classification = "thread_reply"
        next_action = "continue_existing_booking_thread"
    elif any(term in text for term in BOOKING_TERMS):
        classification = "new_booking_request"
        next_action = "deduce_intake_and_prepare_missing_fields_or_invoice"
    else:
        classification = "requires_human_review"
        next_action = "review_unclassified_booking_mail"

    return {
        "classification": classification,
        "next_action": next_action,
        "thread_reason": thread_reason,
        "amounts": amounts,
        "invoice_total": invoice_total,
    }


def new_enquiry_body() -> tuple[str, str]:
    plain = f"""Dear Client,

Thank you for reaching out to Ilorin Innovation Hub regarding your facility booking enquiry.

To help us capture the full booking details cleanly, kindly complete the facility booking form here:
{BOOKING_FORM_URL}

You may also review our cafeteria/catering menu here:
{CAFETERIA_MENU_URL}

Once we receive the completed booking form, we will check availability, review the most suitable hall option, reconcile any catering requirements, and prepare the applicable Zoho Books invoice for your review and payment.

{connectors.BOOKING_SIGNATURE_TEXT}
"""
    html = f"""<!doctype html><html><body style="font-family:Arial,sans-serif;color:#222;line-height:1.5;font-size:14px">
<p>Dear Client,</p>
<p>Thank you for reaching out to Ilorin Innovation Hub regarding your facility booking enquiry.</p>
<p>To help us capture the full booking details cleanly, kindly complete the facility booking form here:<br>
<a href="{BOOKING_FORM_URL}">{BOOKING_FORM_URL}</a></p>
<p>You may also review our cafeteria/catering menu here:<br>
<a href="{CAFETERIA_MENU_URL}">{CAFETERIA_MENU_URL}</a></p>
<p>Once we receive the completed booking form, we will check availability, review the most suitable hall option, reconcile any catering requirements, and prepare the applicable Zoho Books invoice for your review and payment.</p>
{connectors.BOOKING_SIGNATURE_HTML}
</body></html>"""
    return plain, html


def reply_ack_body(decision: dict[str, Any]) -> tuple[str, str]:
    if decision["classification"] in {"payment_proof", "payment_or_attachment"}:
        message = (
            "Thank you. We have received your payment proof/attachment and will review it against the booking record. "
            "Where payment confirmation is required, we will validate with the appropriate team before final confirmation."
        )
    else:
        message = (
            "Thank you for the update. We have received your response and will continue processing the booking request."
        )
    plain = f"""Dear Client,

{message}

{connectors.BOOKING_SIGNATURE_TEXT}
"""
    html = f"""<!doctype html><html><body style="font-family:Arial,sans-serif;color:#222;line-height:1.5;font-size:14px">
<p>Dear Client,</p>
<p>{message}</p>
{connectors.BOOKING_SIGNATURE_HTML}
</body></html>"""
    return plain, html


def send_template_response(record: MessageRecord, decision: dict[str, Any]) -> str | None:
    if not is_external_sender(record.sender_email):
        return None
    if decision["classification"] == "form_submission_data":
        return None
    if decision["classification"] == "new_booking_request":
        plain, html = new_enquiry_body()
    elif decision["classification"] in {"thread_reply", "payment_proof", "payment_or_attachment"}:
        plain, html = reply_ack_body(decision)
    else:
        return None

    subject = record.subject if record.subject.lower().startswith("re:") else f"Re: {record.subject}"
    msg = EmailMessage()
    msg["From"] = f"Aisha <{BOOKING_ADDRESS}>"
    msg["To"] = record.sender_email
    msg["Cc"] = EVENTS_CC
    msg["Subject"] = subject
    msg["Date"] = formatdate(localtime=True)
    msg["Message-ID"] = make_msgid(domain="iih.ng")
    in_reply_to = record.headers.get("message-id")
    references = " ".join(
        part for part in (record.headers.get("references"), record.headers.get("message-id")) if part
    ).strip()
    if in_reply_to:
        msg["In-Reply-To"] = in_reply_to
    if references:
        msg["References"] = references
    msg.set_content(plain)
    msg.add_alternative(html, subtype="html")

    password = connectors.read_secret("ZOHO_APP_PASSWORD")
    with smtplib.SMTP("smtp.zoho.com", 587, timeout=45) as smtp:
        smtp.ehlo()
        smtp.starttls(context=ssl.create_default_context())
        smtp.ehlo()
        smtp.login(BOOKING_ADDRESS, password)
        smtp.send_message(msg, from_addr=BOOKING_ADDRESS, to_addrs=[record.sender_email, EVENTS_CC])
    return str(msg["Message-ID"])


def ensure_db(path: Path = STATE_PATH) -> sqlite3.Connection:
    BOOKING_DIR.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(path, timeout=45)
    conn.execute("PRAGMA busy_timeout = 45000")
    conn.execute("PRAGMA journal_mode = WAL")
    conn.execute(
        """
        CREATE TABLE IF NOT EXISTS messages (
            message_id TEXT PRIMARY KEY,
            envelope_id TEXT NOT NULL,
            thread_key TEXT NOT NULL,
            subject TEXT NOT NULL,
            normalized_subject TEXT NOT NULL,
            sender_email TEXT NOT NULL,
            sender_name TEXT,
            message_date TEXT,
            has_attachment INTEGER NOT NULL DEFAULT 0,
            classification TEXT NOT NULL,
            next_action TEXT NOT NULL,
            raw_headers TEXT NOT NULL,
            body_preview TEXT,
            processed_at TEXT NOT NULL,
            raw_json TEXT NOT NULL
        )
        """
    )
    conn.execute(
        """
        CREATE TABLE IF NOT EXISTS conversations (
            thread_key TEXT PRIMARY KEY,
            normalized_subject TEXT NOT NULL,
            subject TEXT NOT NULL,
            client_email TEXT NOT NULL,
            status TEXT NOT NULL,
            booking_reference TEXT,
            invoice_id TEXT,
            invoice_number TEXT,
            invoice_total INTEGER,
            invoice_status TEXT,
            calendar_event_uid TEXT,
            last_message_id TEXT,
            next_action TEXT NOT NULL,
            events_cc_required INTEGER NOT NULL DEFAULT 1,
            updated_at TEXT NOT NULL
        )
        """
    )
    conn.execute(
        """
        CREATE TABLE IF NOT EXISTS action_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            thread_key TEXT NOT NULL,
            action TEXT NOT NULL,
            detail_json TEXT NOT NULL,
            created_at TEXT NOT NULL
        )
        """
    )
    return conn


def fetch_envelopes(limit: int) -> list[dict[str, Any]]:
    raw = run_cmd(
        [
            "himalaya",
            "-o",
            "json",
            "envelope",
            "list",
            "--account",
            ACCOUNT,
            "--folder",
            FOLDER,
            "--page-size",
            str(limit),
        ]
    )
    return json.loads(raw or "[]")


def read_message(envelope_id: str) -> tuple[dict[str, str], str]:
    text = run_cmd(
        [
            "himalaya",
            "message",
            "read",
            "--account",
            ACCOUNT,
            "--folder",
            FOLDER,
            "--preview",
            "--header",
            "Message-ID",
            "--header",
            "In-Reply-To",
            "--header",
            "References",
            "--header",
            "Subject",
            "--header",
            "From",
            "--header",
            "To",
            "--header",
            "Cc",
            "--header",
            "Date",
            envelope_id,
        ]
    )
    return parse_headers_and_body(text)


def upsert_conversation(
    conn: sqlite3.Connection,
    record: MessageRecord,
    thread_key: str,
    decision: dict[str, Any],
) -> None:
    normalized = normalize_subject(record.subject)
    existing = conn.execute("SELECT status FROM conversations WHERE thread_key = ?", (thread_key,)).fetchone()
    if existing and decision["classification"] == "outbound_booking_response":
        conn.execute(
            """
            UPDATE conversations
            SET last_message_id = ?,
                events_cc_required = 1,
                updated_at = ?
            WHERE thread_key = ?
            """,
            (message_identity(record.headers, record.envelope_id), now(), thread_key),
        )
        return

    status = existing[0] if existing else ("Draft" if decision["classification"] == "new_booking_request" else "Inbox Review")
    if decision["classification"] == "payment_proof" and decision["next_action"] == "confirm_calendar_with_events_cc":
        status = "Payment Evidence Matched"

    conn.execute(
        """
        INSERT INTO conversations (
            thread_key, normalized_subject, subject, client_email, status, last_message_id,
            next_action, events_cc_required, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, 1, ?)
        ON CONFLICT(thread_key) DO UPDATE SET
            subject = excluded.subject,
            client_email = CASE
                WHEN conversations.client_email = '' THEN excluded.client_email
                ELSE conversations.client_email
            END,
            status = excluded.status,
            last_message_id = excluded.last_message_id,
            next_action = excluded.next_action,
            events_cc_required = 1,
            updated_at = excluded.updated_at
        """,
        (
            thread_key,
            normalized,
            record.subject,
            record.sender_email,
            status,
            message_identity(record.headers, record.envelope_id),
            decision["next_action"],
            now(),
        ),
    )


def store_message(
    conn: sqlite3.Connection,
    record: MessageRecord,
    thread_key: str,
    decision: dict[str, Any],
) -> bool:
    msg_id = message_identity(record.headers, record.envelope_id)
    try:
        conn.execute(
            """
            INSERT INTO messages (
                message_id, envelope_id, thread_key, subject, normalized_subject,
                sender_email, sender_name, message_date, has_attachment, classification,
                next_action, raw_headers, body_preview, processed_at, raw_json
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                msg_id,
                record.envelope_id,
                thread_key,
                record.subject,
                normalize_subject(record.subject),
                record.sender_email,
                record.sender_name,
                record.date,
                1 if record.has_attachment else 0,
                decision["classification"],
                decision["next_action"],
                json.dumps(record.headers, sort_keys=True),
                record.body[:1000],
                now(),
                json.dumps(record.raw, sort_keys=True),
            ),
        )
    except sqlite3.IntegrityError:
        return False

    conn.execute(
        "INSERT INTO action_log (thread_key, action, detail_json, created_at) VALUES (?, ?, ?, ?)",
        (thread_key, decision["next_action"], json.dumps(decision, sort_keys=True), now()),
    )
    upsert_conversation(conn, record, thread_key, decision)
    return True


def process_envelope(conn: sqlite3.Connection, envelope: dict[str, Any], auto_respond: bool = False) -> dict[str, Any]:
    envelope_id = str(envelope.get("id") or "")
    try:
        headers, body = read_message(envelope_id)
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired) as exc:
        return {
            "envelope_id": envelope_id,
            "inserted": False,
            "thread_key": "",
            "subject": str(envelope.get("subject") or ""),
            "from": sender_parts(envelope)[0],
            "classification": "read_failed",
            "next_action": f"retry_or_review_message_read: {type(exc).__name__}",
            "events_cc_required": True,
        }
    sender_email, sender_name = sender_parts(envelope)
    record = MessageRecord(
        envelope_id=envelope_id,
        subject=str(envelope.get("subject") or headers.get("subject") or ""),
        sender_email=sender_email,
        sender_name=sender_name,
        date=str(envelope.get("date") or headers.get("date") or ""),
        has_attachment=bool(envelope.get("has_attachment")),
        body=body,
        headers=headers,
        raw=envelope,
    )
    thread_key, reason = thread_key_for(record, conn)
    decision = classify(record, conn, thread_key, reason)
    inserted = store_message(conn, record, thread_key, decision)
    auto_response_message_id = None
    if inserted and auto_respond:
        try:
            auto_response_message_id = send_template_response(record, decision)
            if auto_response_message_id:
                conn.execute(
                    "INSERT INTO action_log (thread_key, action, detail_json, created_at) VALUES (?, ?, ?, ?)",
                    (
                        thread_key,
                        "auto_response_sent",
                        json.dumps(
                            {
                                "message_id": auto_response_message_id,
                                "to": record.sender_email,
                                "cc": EVENTS_CC,
                                "classification": decision["classification"],
                            },
                            sort_keys=True,
                        ),
                        now(),
                    ),
                )
        except Exception as exc:  # noqa: BLE001 - log and continue polling other messages.
            conn.execute(
                "INSERT INTO action_log (thread_key, action, detail_json, created_at) VALUES (?, ?, ?, ?)",
                (
                    thread_key,
                    "auto_response_failed",
                    json.dumps({"error": str(exc), "classification": decision["classification"]}, sort_keys=True),
                    now(),
                ),
            )
    return {
        "envelope_id": envelope_id,
        "inserted": inserted,
        "thread_key": thread_key,
        "subject": record.subject,
        "from": record.sender_email,
        "classification": decision["classification"],
        "next_action": decision["next_action"],
        "events_cc_required": True,
        "auto_response_message_id": auto_response_message_id,
    }


def poll(limit: int, auto_respond: bool = False) -> dict[str, Any]:
    with ensure_db() as conn:
        envelopes = fetch_envelopes(limit)
        results = [process_envelope(conn, envelope, auto_respond=auto_respond) for envelope in envelopes]
        conn.commit()
    inserted = [item for item in results if item["inserted"]]
    return {
        "account": ACCOUNT,
        "folder": FOLDER,
        "checked": len(results),
        "new_records": len(inserted),
        "auto_respond": auto_respond,
        "actions": inserted,
    }


def record_invoice(args: argparse.Namespace) -> dict[str, Any]:
    with ensure_db() as conn:
        conn.execute(
            """
            UPDATE conversations
            SET status = 'Invoice Sent',
                invoice_id = ?,
                invoice_number = ?,
                invoice_total = ?,
                invoice_status = 'sent',
                next_action = 'wait_for_payment_proof',
                events_cc_required = 1,
                updated_at = ?
            WHERE thread_key = ?
            """,
            (args.invoice_id, args.invoice_number, args.amount, now(), args.thread_key),
        )
        if conn.total_changes == 0:
            raise SystemExit(f"Unknown thread_key: {args.thread_key}")
        conn.execute(
            "INSERT INTO action_log (thread_key, action, detail_json, created_at) VALUES (?, ?, ?, ?)",
            (
                args.thread_key,
                "invoice_recorded_wait_for_payment_proof",
                json.dumps(
                    {
                        "invoice_id": args.invoice_id,
                        "invoice_number": args.invoice_number,
                        "amount": args.amount,
                        "cc": EVENTS_CC,
                    },
                    sort_keys=True,
                ),
                now(),
            ),
        )
        conn.commit()
    return {"ok": True, "thread_key": args.thread_key, "status": "Invoice Sent", "next_action": "wait_for_payment_proof"}


def mark_confirmed(args: argparse.Namespace) -> dict[str, Any]:
    with ensure_db() as conn:
        conn.execute(
            """
            UPDATE conversations
            SET status = 'Confirmed',
                invoice_status = 'paid',
                calendar_event_uid = COALESCE(?, calendar_event_uid),
                next_action = 'confirmed_calendar_handoff_complete',
                events_cc_required = 1,
                updated_at = ?
            WHERE thread_key = ?
            """,
            (args.calendar_event_uid, now(), args.thread_key),
        )
        if conn.total_changes == 0:
            raise SystemExit(f"Unknown thread_key: {args.thread_key}")
        conn.execute(
            "INSERT INTO action_log (thread_key, action, detail_json, created_at) VALUES (?, ?, ?, ?)",
            (
                args.thread_key,
                "booking_confirmed_after_payment_match",
                json.dumps({"calendar_event_uid": args.calendar_event_uid, "cc": EVENTS_CC}, sort_keys=True),
                now(),
            ),
        )
        conn.commit()
    return {
        "ok": True,
        "thread_key": args.thread_key,
        "status": "Confirmed",
        "next_action": "confirmed_calendar_handoff_complete",
        "events_cc_required": True,
    }


def mark_finance_confirmed(args: argparse.Namespace) -> dict[str, Any]:
    with ensure_db() as conn:
        conn.execute(
            """
            UPDATE conversations
            SET status = 'Finance Confirmed',
                invoice_status = 'finance_confirmed_paid',
                next_action = 'create_confirmed_calendar_event',
                events_cc_required = 1,
                updated_at = ?
            WHERE thread_key = ?
            """,
            (now(), args.thread_key),
        )
        if conn.total_changes == 0:
            raise SystemExit(f"Unknown thread_key: {args.thread_key}")
        conn.execute(
            "INSERT INTO action_log (thread_key, action, detail_json, created_at) VALUES (?, ?, ?, ?)",
            (
                args.thread_key,
                "finance_confirmed_payment",
                json.dumps({"finance_email": "finance@iih.ng", "confirmation_reference": args.reference}, sort_keys=True),
                now(),
            ),
        )
        conn.commit()
    return {
        "ok": True,
        "thread_key": args.thread_key,
        "status": "Finance Confirmed",
        "next_action": "create_confirmed_calendar_event",
    }


def state(limit: int) -> dict[str, Any]:
    with ensure_db() as conn:
        rows = conn.execute(
            """
            SELECT thread_key, status, client_email, subject, invoice_number, invoice_total,
                   calendar_event_uid, next_action, updated_at
            FROM conversations
            ORDER BY updated_at DESC
            LIMIT ?
            """,
            (limit,),
        ).fetchall()
    return {
        "conversations": [
            {
                "thread_key": row[0],
                "status": row[1],
                "client_email": row[2],
                "subject": row[3],
                "invoice_number": row[4],
                "invoice_total": row[5],
                "calendar_event_uid": row[6],
                "next_action": row[7],
                "updated_at": row[8],
                "events_cc_required": True,
            }
            for row in rows
        ]
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)

    poll_parser = sub.add_parser("poll", help="Poll facilitybookings inbox and classify new messages.")
    poll_parser.add_argument("--limit", type=int, default=25)
    poll_parser.add_argument("--auto-respond", action="store_true", help="Send approved template responses for external new enquiries/replies.")
    poll_parser.add_argument("--pretty", action="store_true")

    state_parser = sub.add_parser("state", help="Show recent booking-agent conversation state.")
    state_parser.add_argument("--limit", type=int, default=20)
    state_parser.add_argument("--pretty", action="store_true")

    invoice_parser = sub.add_parser("record-invoice", help="Record sent invoice metadata for a thread.")
    invoice_parser.add_argument("--thread-key", required=True)
    invoice_parser.add_argument("--invoice-id", required=True)
    invoice_parser.add_argument("--invoice-number", required=True)
    invoice_parser.add_argument("--amount", type=int, required=True)
    invoice_parser.add_argument("--pretty", action="store_true")

    confirm_parser = sub.add_parser("mark-confirmed", help="Mark a thread confirmed after matched payment proof.")
    confirm_parser.add_argument("--thread-key", required=True)
    confirm_parser.add_argument("--calendar-event-uid", default="")
    confirm_parser.add_argument("--pretty", action="store_true")

    finance_parser = sub.add_parser("mark-finance-confirmed", help="Record finance@iih.ng confirmation of payment.")
    finance_parser.add_argument("--thread-key", required=True)
    finance_parser.add_argument("--reference", default="")
    finance_parser.add_argument("--pretty", action="store_true")

    args = parser.parse_args()
    if args.command == "poll":
        output = poll(args.limit, auto_respond=args.auto_respond)
    elif args.command == "state":
        output = state(args.limit)
    elif args.command == "record-invoice":
        output = record_invoice(args)
    elif args.command == "mark-confirmed":
        output = mark_confirmed(args)
    elif args.command == "mark-finance-confirmed":
        output = mark_finance_confirmed(args)
    else:
        raise SystemExit(f"Unknown command: {args.command}")

    print(json.dumps(output, indent=2 if getattr(args, "pretty", False) else None))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
