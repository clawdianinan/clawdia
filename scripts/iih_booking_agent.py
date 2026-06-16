#!/usr/bin/env python3
"""Poll and classify IIH facility booking mailbox responses.

This processor is intentionally stateful and conservative. It records messages,
tracks conversation threads, classifies new requests versus replies, and queues
the next booking action. It does not send external email by itself.
"""

from __future__ import annotations

import argparse
import json
import re
import sqlite3
import subprocess
from dataclasses import dataclass
from datetime import datetime
from email.utils import parseaddr
from pathlib import Path
from typing import Any


WORKSPACE_DIR = Path(__file__).resolve().parent.parent
BOOKING_DIR = WORKSPACE_DIR / "documents" / "IIH" / "Bookings"
STATE_PATH = BOOKING_DIR / "booking_agent.sqlite3"
ACCOUNT = "facilitybookings"
FOLDER = "INBOX"
EVENTS_CC = "events@iih.ng"
BOOKING_ADDRESS = "facilitybookings@iih.ng"

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


def sender_parts(envelope: dict[str, Any]) -> tuple[str, str]:
    raw_from = envelope.get("from") or {}
    if isinstance(raw_from, dict):
        return str(raw_from.get("addr") or "").lower(), str(raw_from.get("name") or "")
    name, addr = parseaddr(str(raw_from))
    return addr.lower(), name


def message_identity(headers: dict[str, str], envelope_id: str) -> str:
    return headers.get("message-id") or f"himalaya:{ACCOUNT}:{FOLDER}:{envelope_id}"


def thread_key_for(record: MessageRecord, conn: sqlite3.Connection) -> tuple[str, str]:
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

    if sender == BOOKING_ADDRESS:
        classification = "outbound_booking_response"
        next_action = "no_action_record_sent_response"
    elif any(term in sender for term in SYSTEM_SENDERS):
        classification = "system_update"
        next_action = "review_system_update"
    elif any(term in text for term in PAYMENT_TERMS) or record.has_attachment:
        classification = "payment_proof" if status in {"Invoice Sent", "Payment Pending"} else "payment_or_attachment"
        if invoice_total and invoice_total in amounts:
            next_action = "confirm_calendar_with_events_cc"
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


def ensure_db(path: Path = STATE_PATH) -> sqlite3.Connection:
    BOOKING_DIR.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(path)
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


def process_envelope(conn: sqlite3.Connection, envelope: dict[str, Any]) -> dict[str, Any]:
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
    return {
        "envelope_id": envelope_id,
        "inserted": inserted,
        "thread_key": thread_key,
        "subject": record.subject,
        "from": record.sender_email,
        "classification": decision["classification"],
        "next_action": decision["next_action"],
        "events_cc_required": True,
    }


def poll(limit: int) -> dict[str, Any]:
    with ensure_db() as conn:
        envelopes = fetch_envelopes(limit)
        results = [process_envelope(conn, envelope) for envelope in envelopes]
        conn.commit()
    inserted = [item for item in results if item["inserted"]]
    return {
        "account": ACCOUNT,
        "folder": FOLDER,
        "checked": len(results),
        "new_records": len(inserted),
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

    args = parser.parse_args()
    if args.command == "poll":
        output = poll(args.limit)
    elif args.command == "state":
        output = state(args.limit)
    elif args.command == "record-invoice":
        output = record_invoice(args)
    elif args.command == "mark-confirmed":
        output = mark_confirmed(args)
    else:
        raise SystemExit(f"Unknown command: {args.command}")

    print(json.dumps(output, indent=2 if getattr(args, "pretty", False) else None))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
