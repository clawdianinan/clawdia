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
import hashlib
import json
import re
import smtplib
import ssl
import sqlite3
import subprocess
import time
from dataclasses import dataclass
from datetime import datetime, timedelta
from email.message import EmailMessage
from email.utils import formatdate, getaddresses, make_msgid
from email.utils import parseaddr
from pathlib import Path
from typing import Any

import iih_booking_connectors as connectors


WORKSPACE_DIR = Path(__file__).resolve().parent.parent
BOOKING_DIR = WORKSPACE_DIR / "documents" / "IIH" / "Bookings"
CONFIG_PATH = WORKSPACE_DIR / "config" / "iih_booking_system.json"
TEMPLATE_DIR = WORKSPACE_DIR / "config" / "templates"
STATE_PATH = BOOKING_DIR / "booking_agent.sqlite3"
ACCOUNT = "facilitybookings"
FOLDER = "INBOX"
EVENTS_CC = "events@iih.ng"
BOOKING_ADDRESS = "facilitybookings@iih.ng"
BOOKING_INTAKE_ADDRESSES = (BOOKING_ADDRESS, EVENTS_CC)
# The native form on the website replaced the Google Form on 2026-08-11.
# Submissions now land in the iih.ng backend as facilityBookings rows with
# status "new" and are complete intake - see iih.bookings.list.
BOOKING_FORM_URL = "https://iih.ng/book-space"
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
BOOKING_CONTEXT_TERMS = (
    "facility",
    "facility booking",
    "booking",
    "hall",
    "venue",
    "space",
    "meeting room",
    "main hall",
    "pitch hall",
    "ilorin innovation hub",
    "iih",
)
BOOKING_INTENT_TERMS = (
    "book",
    "booking",
    "reserve",
    "reservation",
    "rent",
    "hire",
    "use your facility",
    "use the facility",
    "use the hall",
    "host an event",
    "hold an event",
    "facility enquiry",
    "facility inquiry",
    "booking enquiry",
    "booking inquiry",
    "availability",
)
MEDIA_APPROVAL_TERMS = (
    "photograph",
    "photographs",
    "photography",
    "photo shoot",
    "photoshoot",
    "backdrop",
    "proper credit",
    "request your approval",
    "approval for this activity",
    "indemnity undertaking",
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
TOUR_EXCURSION_TERMS = (
    "facility tour",
    "tour of the ilorin innovation hub",
    "tour of ilorin innovation hub",
    "school excursion",
    "excursion",
    "student visit",
    "students and team",
    "academy visit",
)
CLIENT_UPDATE_TERMS = (
    "received",
    "well received",
    "noted",
    "updated",
    "edited",
    "revised",
    "changed",
    "correction",
    "confirming",
    "for your information",
    "fyi",
)
CLIENT_ACTION_REQUEST_TERMS = (
    "please",
    "kindly",
    "negotiate",
    "reduce",
    "discount",
    "waive",
    "refund",
    "cancel",
    "reschedule",
    "alternative date",
    "change the date",
    "change date",
    "invoice",
    "vat",
    "payment",
    "paid",
    "proof",
    "receipt",
    "account details",
    "quotation",
    "quote",
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
SPAM_TERMS = (
    "urgent wire",
    "crypto",
    "password",
    "click here immediately",
    "account suspended",
    "gift card",
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


def run_cmd(args: list[str], timeout: int = 30, retries: int = 3,
            backoff: float = 1.5, base_delay: float = 1.0) -> str:
    """Run a subprocess with bounded retry + exponential backoff.

    The mailbox connector (himalaya) intermittently times out at 30s under load;
    historically that produced 112 terminal timeout tracebacks and silently
    dropped inbound booking mail. Retrying with backoff makes a transient
    timeout recoverable instead of losing the message.

    Only retries on TimeoutExpired and transient subprocess errors. A non-zero
    exit caused by bad input (CalledProcessError with output) is raised as-is,
    because retrying it would just repeat the same failure.
    """
    last_exc: Exception | None = None
    for attempt in range(1, retries + 1):
        try:
            result = subprocess.run(
                args, check=True, capture_output=True, text=True, timeout=timeout
            )
            return result.stdout
        except subprocess.TimeoutExpired as exc:
            last_exc = exc
            if attempt < retries:
                delay = base_delay * (backoff ** (attempt - 1))
                time.sleep(delay)
                continue
            raise
        except subprocess.CalledProcessError as exc:
            # Deterministic failure (bad args, auth error) - do not retry.
            raise
        except FileNotFoundError as exc:
            last_exc = exc
            if attempt < retries:
                time.sleep(base_delay * (backoff ** (attempt - 1)))
                continue
            raise
    if last_exc:
        raise last_exc
    raise RuntimeError("run_cmd: unreachable")


def now() -> str:
    return datetime.now().isoformat(timespec="seconds")


def load_config() -> dict[str, Any]:
    with CONFIG_PATH.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def state_set(conn: sqlite3.Connection, key: str, value: Any) -> None:
    conn.execute(
        """
        INSERT INTO runtime_state (key, value, updated_at) VALUES (?, ?, ?)
        ON CONFLICT(key) DO UPDATE SET value = excluded.value, updated_at = excluded.updated_at
        """,
        (key, json.dumps(value, sort_keys=True), now()),
    )


def state_get(conn: sqlite3.Connection, key: str, default: Any = None) -> Any:
    row = conn.execute("SELECT value FROM runtime_state WHERE key = ?", (key,)).fetchone()
    if not row:
        return default
    try:
        return json.loads(row[0])
    except json.JSONDecodeError:
        return default


def lagos_date() -> str:
    return datetime.now().date().isoformat()


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


def reply_all_recipients(record: MessageRecord) -> tuple[list[str], list[str]]:
    excluded = {BOOKING_ADDRESS.lower(), "md@iih.ng"}
    to_recipients = [record.sender_email.lower()]
    cc_recipients: list[str] = []

    for _name, address in getaddresses([record.headers.get("to", ""), record.headers.get("cc", "")]):
        email = address.lower().strip()
        if not email or email in excluded:
            continue
        if any(term in email for term in SYSTEM_SENDERS):
            continue
        if email in to_recipients or email in cc_recipients:
            continue
        cc_recipients.append(email)

    if EVENTS_CC.lower() not in to_recipients and EVENTS_CC.lower() not in cc_recipients:
        cc_recipients.append(EVENTS_CC)

    return to_recipients, cc_recipients


def recipient_addresses(record: MessageRecord) -> set[str]:
    return {
        address.lower().strip()
        for _name, address in getaddresses([record.headers.get("to", ""), record.headers.get("cc", "")])
        if address
    }


def addressed_to_booking(record: MessageRecord) -> bool:
    return BOOKING_ADDRESS.lower() in recipient_addresses(record)


def addressed_to_booking_intake_channel(record: MessageRecord) -> bool:
    recipients = recipient_addresses(record)
    return any(address.lower() in recipients for address in BOOKING_INTAKE_ADDRESSES)


def directly_asks_booking_handler(record: MessageRecord, text: str) -> bool:
    if not is_internal_iih_sender(record.sender_email):
        return False
    return any(term in text for term in ("facilitybookings", "facility bookings", "aisha"))


def is_internal_iih_sender(email: str) -> bool:
    return email.lower().endswith("@iih.ng")


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


def has_clear_new_booking_intent(record: MessageRecord, thread_reason: str, text: str) -> bool:
    if thread_reason != "new_thread":
        return False
    if not is_external_sender(record.sender_email):
        return False
    if not addressed_to_booking_intake_channel(record):
        return False
    if record.has_attachment:
        return False
    if record.subject.lower().strip().startswith(("re:", "fw:", "fwd:")):
        return False
    if any(term in text for term in PAYMENT_TERMS):
        return False

    has_context = any(term in text for term in BOOKING_CONTEXT_TERMS)
    has_intent = any(term in text for term in BOOKING_INTENT_TERMS)
    explicit_request = re.search(
        r"\b(i|we|our organization|my organization)\b.{0,80}"
        r"\b(want|would like|wish|intend|plan|need|request|enquire|inquire|ask)\b.{0,80}"
        r"\b(book|reserve|rent|hire|use|host|hold)\b",
        text,
        flags=re.I | re.S,
    )
    return has_context and (has_intent or explicit_request is not None)


def is_client_update_acknowledgement_only(record: MessageRecord, thread_reason: str, text: str) -> bool:
    if thread_reason == "new_thread":
        return False
    if not is_external_sender(record.sender_email):
        return False
    if record.has_attachment:
        return False
    if not any(term in text for term in CLIENT_UPDATE_TERMS):
        return False
    return not any(term in text for term in CLIENT_ACTION_REQUEST_TERMS)


def sender_parts(envelope: dict[str, Any]) -> tuple[str, str]:
    raw_from = envelope.get("from") or {}
    if isinstance(raw_from, dict):
        return str(raw_from.get("addr") or "").lower(), str(raw_from.get("name") or "")
    name, addr = parseaddr(str(raw_from))
    return addr.lower(), name


def message_identity(headers: dict[str, str], envelope_id: str) -> str:
    return headers.get("message-id") or f"himalaya:{ACCOUNT}:{FOLDER}:{envelope_id}"


def auth_status(headers: dict[str, str]) -> dict[str, Any]:
    auth = headers.get("authentication-results", "").lower()
    checks = {
        "spf": "pass" if "spf=pass" in auth else "fail" if "spf=fail" in auth else "unknown",
        "dkim": "pass" if "dkim=pass" in auth else "fail" if "dkim=fail" in auth else "unknown",
        "dmarc": "pass" if "dmarc=pass" in auth else "fail" if "dmarc=fail" in auth else "unknown",
    }
    checks["authenticated"] = not any(value == "fail" for value in checks.values())
    return checks


def spam_prefilter(record: MessageRecord) -> dict[str, Any]:
    text = f"{record.subject}\n{record.body}".lower()
    matched = [term for term in SPAM_TERMS if term in text]
    return {"spam": bool(matched), "matched_terms": matched}


def record_sender_rate(conn: sqlite3.Connection, sender_email: str) -> dict[str, Any]:
    config = load_config()
    reliability = config.get("reliability") or {}
    allow = {email.lower() for email in reliability.get("sender_allowlist") or []}
    deny = {email.lower() for email in reliability.get("sender_denylist") or []}
    sender = sender_email.lower()
    current = now()
    existing = conn.execute("SELECT message_count, first_seen_at FROM sender_rate_limits WHERE sender_email = ?", (sender,)).fetchone()
    if existing:
        first_seen = str(existing[1])
        try:
            within_window = datetime.now() - datetime.fromisoformat(first_seen) < timedelta(hours=1)
        except ValueError:
            within_window = False
        count = int(existing[0]) + 1 if within_window else 1
        if not within_window:
            first_seen = current
    else:
        count = 1
        first_seen = current
    disposition = "allow" if sender in allow else "deny" if sender in deny else "normal"
    if disposition == "normal" and count > int(reliability.get("sender_rate_limit_per_hour") or 20):
        disposition = "rate_limited"
    conn.execute(
        """
        INSERT INTO sender_rate_limits (sender_email, first_seen_at, last_seen_at, message_count, disposition)
        VALUES (?, ?, ?, ?, ?)
        ON CONFLICT(sender_email) DO UPDATE SET
            last_seen_at = excluded.last_seen_at,
            message_count = excluded.message_count,
            disposition = excluded.disposition
        """,
        (sender, first_seen, current, count, disposition),
    )
    return {"sender": sender, "message_count": count, "disposition": disposition}


def template_record(template_id: str) -> dict[str, Any]:
    path = TEMPLATE_DIR / f"{template_id}.json"
    with path.open("r", encoding="utf-8") as handle:
        data = json.load(handle)
    content = f"{data.get('subject_prefix', '')}\n{data.get('plain', '')}\n{data.get('html', '')}"
    checksum = hashlib.sha256(content.encode("utf-8")).hexdigest()
    if data.get("checksum") != checksum:
        raise RuntimeError(f"Template checksum mismatch for {template_id}.")
    return data


def render_template(template_id: str, context: dict[str, Any]) -> tuple[str, str, dict[str, Any]]:
    data = template_record(template_id)
    values = {
        "booking_form_url": BOOKING_FORM_URL,
        "cafeteria_menu_url": CAFETERIA_MENU_URL,
        "signature_text": connectors.BOOKING_SIGNATURE_TEXT,
        "signature_html": connectors.BOOKING_SIGNATURE_HTML,
        **context,
    }
    plain = str(data["plain"]).format(**values)
    html = str(data["html"]).format(**values)
    return plain, html, data


GENERIC_SENDER_NAME_TERMS = {
    "admin",
    "booking",
    "bookings",
    "client",
    "contact",
    "enquiries",
    "enquiry",
    "events",
    "facility",
    "hello",
    "info",
    "mail",
    "no reply",
    "noreply",
    "office",
    "reservations",
    "support",
}


def clean_sender_name(value: str) -> str:
    candidate = re.sub(r"<[^>]*>", " ", value or "")
    candidate = re.sub(r"[_]+", " ", candidate)
    candidate = re.sub(r"[^A-Za-z0-9 .'-]+", " ", candidate)
    candidate = re.sub(r"\s+", " ", candidate).strip(" .'\"-")
    if not candidate or "@" in candidate:
        return ""
    if candidate.lower() in GENERIC_SENDER_NAME_TERMS:
        return ""
    return candidate.title() if candidate.isupper() or candidate.islower() else candidate


def client_salutation(record: MessageRecord) -> str:
    name = clean_sender_name(record.sender_name)
    if not name:
        local_part = record.sender_email.split("@", 1)[0]
        if local_part.lower() not in GENERIC_SENDER_NAME_TERMS:
            name = clean_sender_name(local_part.replace(".", " ").replace("-", " "))
    return f"Dear {name}," if name else "Hello,"


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

    is_form_response = sender in FORM_SENDERS or (
        any(sender.endswith(domain) for domain in NO_REPLY_DOMAINS) and any(term in text for term in FORM_TERMS)
    )
    is_tour_or_excursion = any(term in text for term in TOUR_EXCURSION_TERMS)
    is_media_approval_request = any(term in text for term in MEDIA_APPROVAL_TERMS)

    if sender == BOOKING_ADDRESS:
        classification = "outbound_booking_response"
        next_action = "no_action_record_sent_response"
    elif is_internal_iih_sender(sender) and not addressed_to_booking(record) and not directly_asks_booking_handler(record, text):
        classification = "internal_fyi_not_addressed_to_booking"
        next_action = "no_response_record_only"
    elif is_form_response:
        if thread_reason == "new_thread":
            classification = "form_submission_new_booking"
            next_action = "review_new_form_submission_no_reply_to_google_prepare_booking_workflow"
        else:
            classification = "form_submission_data"
            next_action = "link_form_submission_to_existing_enquiry_no_reply_prepare_invoice"
    elif any(term in sender for term in SYSTEM_SENDERS):
        classification = "system_update"
        next_action = "review_system_update"
    elif (
        is_media_approval_request
        and thread_reason == "new_thread"
        and is_external_sender(record.sender_email)
        and addressed_to_booking_intake_channel(record)
    ):
        classification = "media_or_photography_approval_request"
        next_action = "send_internal_guidance_request_to_maureen_or_md_before_client_response"
    elif (
        is_tour_or_excursion
        and thread_reason == "new_thread"
        and is_external_sender(record.sender_email)
        and addressed_to_booking_intake_channel(record)
    ):
        classification = "tour_or_excursion_request"
        next_action = "check_tour_excursion_calendar_no_invoice_schedule_if_no_tour_clash"
    elif any(term in text for term in PAYMENT_TERMS) or record.has_attachment:
        classification = "payment_proof" if status in {"Invoice Sent", "Payment Pending"} else "payment_or_attachment"
        next_action = "manual_review_wait_for_instruction"
    elif is_client_update_acknowledgement_only(record, thread_reason, text):
        classification = "client_update_acknowledgement_only"
        next_action = "send_brief_acknowledgement_existing_thread"
    elif thread_reason != "new_thread":
        classification = "thread_reply"
        next_action = "manual_review_wait_for_instruction"
    elif has_clear_new_booking_intent(record, thread_reason, text):
        classification = "new_booking_request"
        next_action = "deduce_intake_and_prepare_missing_fields_or_invoice"
    else:
        classification = "requires_human_review"
        next_action = "send_internal_guidance_request_to_maureen_or_md_before_client_response"

    return {
        "classification": classification,
        "next_action": next_action,
        "thread_reason": thread_reason,
        "amounts": amounts,
        "invoice_total": invoice_total,
    }


def new_enquiry_body(record: MessageRecord) -> tuple[str, str]:
    plain, html, _template = render_template("new_enquiry_ack", {"salutation": client_salutation(record)})
    return plain, html


def template_id_for_decision(decision: dict[str, Any]) -> str | None:
    if decision["classification"] == "new_booking_request":
        return "new_enquiry_ack"
    return None


def send_budget_available(conn: sqlite3.Connection) -> tuple[bool, str | None]:
    config = load_config()
    limits = config.get("reliability") or {}
    if state_get(conn, "send_circuit_breaker_tripped", False):
        return False, "send_circuit_breaker_already_tripped"
    max_per_run = int(limits.get("max_sends_per_run") or 10)
    current_run_sends = int(state_get(conn, "current_run_sends", 0) or 0)
    if current_run_sends >= max_per_run:
        state_set(conn, "send_circuit_breaker_tripped", True)
        state_set(conn, "auto_respond_enabled", False)
        return False, "max_sends_per_run_exceeded"
    one_hour_ago = (datetime.now() - timedelta(hours=1)).isoformat(timespec="seconds")
    sends_last_hour = conn.execute(
        "SELECT COUNT(*) FROM action_log WHERE action IN ('auto_response_sent', 'dry_run_template_preview') AND created_at >= ?",
        (one_hour_ago,),
    ).fetchone()[0]
    if int(sends_last_hour) >= int(limits.get("max_sends_per_rolling_hour") or 30):
        state_set(conn, "send_circuit_breaker_tripped", True)
        state_set(conn, "auto_respond_enabled", False)
        return False, "max_sends_per_rolling_hour_exceeded"
    return True, None


def send_template_response(
    conn: sqlite3.Connection,
    thread_key: str,
    record: MessageRecord,
    decision: dict[str, Any],
    dry_run: bool = False,
) -> str | None:
    if not is_external_sender(record.sender_email):
        return None
    if decision.get("classification") != "new_booking_request":
        conn.execute(
            "INSERT INTO action_log (thread_key, action, detail_json, created_at) VALUES (?, ?, ?, ?)",
            (
                thread_key,
                "auto_response_suppressed_request_type_gate",
                json.dumps(
                    {
                        "classification": decision.get("classification"),
                        "next_action": decision.get("next_action"),
                        "reason": "request_type_not_confirmed_paid_facility_booking",
                    },
                    sort_keys=True,
                ),
                now(),
            ),
        )
        return None
    if decision["classification"] in {"form_submission_data", "form_submission_new_booking"}:
        return None
    template_id = template_id_for_decision(decision)
    if not template_id:
        if is_external_sender(record.sender_email):
            conn.execute(
                "INSERT INTO action_log (thread_key, action, detail_json, created_at) VALUES (?, ?, ?, ?)",
                (
                    thread_key,
                    "auto_response_suppressed_manual_review",
                    json.dumps(
                        {
                            "classification": decision["classification"],
                            "next_action": decision["next_action"],
                            "reason": "only_new_booking_request_autoresponse_allowed",
                        },
                        sort_keys=True,
                    ),
                    now(),
                ),
            )
        return None
    text = f"{record.subject}\n{record.body}".lower()
    if not has_clear_new_booking_intent(record, str(decision.get("thread_reason") or ""), text):
        conn.execute(
            "INSERT INTO action_log (thread_key, action, detail_json, created_at) VALUES (?, ?, ?, ?)",
            (
                thread_key,
                "auto_response_suppressed_manual_review",
                json.dumps(
                    {
                        "classification": decision["classification"],
                        "next_action": decision["next_action"],
                        "reason": "new_booking_autoresponse_failed_send_time_recheck",
                    },
                    sort_keys=True,
                ),
                now(),
            ),
        )
        return None
    plain, html = new_enquiry_body(record)
    template = template_record(template_id)
    dedup_key = f"{thread_key}|{template_id}|{template['version']}|{lagos_date()}"
    if conn.execute("SELECT 1 FROM outbound_dedup WHERE dedup_key = ?", (dedup_key,)).fetchone():
        conn.execute(
            "INSERT INTO action_log (thread_key, action, detail_json, created_at) VALUES (?, ?, ?, ?)",
            (
                thread_key,
                "outbound_template_suppressed_duplicate",
                json.dumps({"dedup_key": dedup_key, "template_id": template_id}, sort_keys=True),
                now(),
            ),
        )
        return None
    allowed, reason = send_budget_available(conn)
    if not allowed:
        conn.execute(
            "INSERT INTO action_log (thread_key, action, detail_json, created_at) VALUES (?, ?, ?, ?)",
            (
                thread_key,
                "send_circuit_breaker_blocked",
                json.dumps({"reason": reason, "escalate_to": "clawdia"}, sort_keys=True),
                now(),
            ),
        )
        return None

    subject = record.subject if record.subject.lower().startswith("re:") else f"Re: {record.subject}"
    if dry_run:
        to_recipients, cc_recipients = reply_all_recipients(record)
        conn.execute(
            """
            INSERT INTO outbound_dedup (dedup_key, thread_key, template_id, template_version, lagos_date, message_id, created_at)
            VALUES (?, ?, ?, ?, ?, NULL, ?)
            """,
            (dedup_key, thread_key, template_id, template["version"], lagos_date(), now()),
        )
        conn.execute(
            "INSERT INTO action_log (thread_key, action, detail_json, created_at) VALUES (?, ?, ?, ?)",
            (
                thread_key,
                "dry_run_template_preview",
                json.dumps(
                    {
                        "reply_all_to": to_recipients,
                        "reply_all_cc": cc_recipients,
                        "subject": subject,
                        "template_id": template_id,
                        "template_version": template["version"],
                        "in_reply_to": record.headers.get("message-id"),
                        "references": " ".join(
                            part for part in (record.headers.get("references"), record.headers.get("message-id")) if part
                        ).strip(),
                        "body_preview": plain[:1000],
                    },
                    sort_keys=True,
                ),
                now(),
            ),
        )
        state_set(conn, "current_run_sends", int(state_get(conn, "current_run_sends", 0) or 0) + 1)
        return "dry-run"

    to_recipients, cc_recipients = reply_all_recipients(record)
    msg = EmailMessage()
    msg["From"] = f"Aisha <{BOOKING_ADDRESS}>"
    msg["To"] = ", ".join(to_recipients)
    msg["Cc"] = ", ".join(cc_recipients)
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
    connectors.attach_signature_logo(msg)

    password = connectors.read_secret("ZOHO_APP_PASSWORD")
    with smtplib.SMTP("smtp.zoho.com", 587, timeout=45) as smtp:
        smtp.ehlo()
        smtp.starttls(context=ssl.create_default_context())
        smtp.ehlo()
        smtp.login(BOOKING_ADDRESS, password)
        smtp.send_message(msg, from_addr=BOOKING_ADDRESS, to_addrs=to_recipients + cc_recipients)
    message_id = str(msg["Message-ID"])
    conn.execute(
        """
        INSERT INTO outbound_dedup (dedup_key, thread_key, template_id, template_version, lagos_date, message_id, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        """,
        (dedup_key, thread_key, template_id, template["version"], lagos_date(), message_id, now()),
    )
    state_set(conn, "current_run_sends", int(state_get(conn, "current_run_sends", 0) or 0) + 1)
    return message_id


def ensure_db(path: Path | None = None) -> sqlite3.Connection:
    path = path or STATE_PATH
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
    conn.execute(
        """
        CREATE TABLE IF NOT EXISTS processed_messages (
            message_id TEXT PRIMARY KEY,
            envelope_id TEXT NOT NULL,
            thread_key TEXT NOT NULL,
            processed_at TEXT NOT NULL,
            status TEXT NOT NULL,
            detail_json TEXT NOT NULL DEFAULT '{}'
        )
        """
    )
    conn.execute(
        """
        CREATE TABLE IF NOT EXISTS outbound_dedup (
            dedup_key TEXT PRIMARY KEY,
            thread_key TEXT NOT NULL,
            template_id TEXT NOT NULL,
            template_version TEXT NOT NULL,
            lagos_date TEXT NOT NULL,
            message_id TEXT,
            created_at TEXT NOT NULL
        )
        """
    )
    conn.execute(
        """
        CREATE TABLE IF NOT EXISTS runtime_state (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL,
            updated_at TEXT NOT NULL
        )
        """
    )
    conn.execute(
        """
        CREATE TABLE IF NOT EXISTS sender_rate_limits (
            sender_email TEXT PRIMARY KEY,
            first_seen_at TEXT NOT NULL,
            last_seen_at TEXT NOT NULL,
            message_count INTEGER NOT NULL DEFAULT 0,
            disposition TEXT NOT NULL DEFAULT 'normal'
        )
        """
    )
    conn.execute(
        """
        CREATE TABLE IF NOT EXISTS quarantine (
            quarantine_id INTEGER PRIMARY KEY AUTOINCREMENT,
            message_id TEXT NOT NULL,
            sender_email TEXT NOT NULL,
            reason TEXT NOT NULL,
            detail_json TEXT NOT NULL DEFAULT '{}',
            created_at TEXT NOT NULL
        )
        """
    )
    conn.execute(
        """
        CREATE TABLE IF NOT EXISTS daily_health_digest (
            digest_date TEXT PRIMARY KEY,
            runs INTEGER NOT NULL DEFAULT 0,
            messages_classified INTEGER NOT NULL DEFAULT 0,
            sends INTEGER NOT NULL DEFAULT 0,
            escalations INTEGER NOT NULL DEFAULT 0,
            holds_expiring_72h INTEGER NOT NULL DEFAULT 0,
            deposits_awaiting_resolution INTEGER NOT NULL DEFAULT 0,
            detail_json TEXT NOT NULL DEFAULT '{}',
            updated_at TEXT NOT NULL
        )
        """
    )
    conn.execute(
        """
        CREATE TABLE IF NOT EXISTS access_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            actor TEXT NOT NULL,
            action TEXT NOT NULL,
            resource TEXT NOT NULL,
            detail_json TEXT NOT NULL DEFAULT '{}',
            created_at TEXT NOT NULL
        )
        """
    )
    _migrate_conversation_guards(conn)
    return conn


# Guard columns that record the evidence trail a confirmation must satisfy.
# Added by migration so existing databases upgrade in place (idempotent).
CONVERSATION_GUARD_COLUMNS = (
    ("payment_proof_reference", "TEXT"),
    ("payment_proof_at", "TEXT"),
    ("payment_amount", "INTEGER"),
    ("finance_confirmed_at", "TEXT"),
    ("finance_confirmation_reference", "TEXT"),
    ("availability_checked_at", "TEXT"),
    ("availability_evidence", "TEXT"),
    ("sponsor_code_id", "TEXT"),
    ("confirmed_at", "TEXT"),
    ("confirmed_by", "TEXT"),
)


def _migrate_conversation_guards(conn: sqlite3.Connection) -> None:
    """Add guard/evidence columns to conversations if absent. Safe to re-run."""
    existing = {
        row[1] for row in conn.execute("PRAGMA table_info(conversations)").fetchall()
    }
    if not existing:
        return
    for column, sqltype in CONVERSATION_GUARD_COLUMNS:
        if column not in existing:
            conn.execute(f"ALTER TABLE conversations ADD COLUMN {column} {sqltype}")
    conn.commit()


def log_access(conn: sqlite3.Connection, action: str, resource: str, detail: dict[str, Any]) -> None:
    conn.execute(
        "INSERT INTO access_log (actor, action, resource, detail_json, created_at) VALUES (?, ?, ?, ?, ?)",
        ("iih_booking_agent", action, resource, json.dumps(detail, sort_keys=True), now()),
    )


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
            "--header",
            "Authentication-Results",
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


def quarantine_message(
    conn: sqlite3.Connection,
    record: MessageRecord,
    reason: str,
    detail: dict[str, Any],
) -> None:
    conn.execute(
        "INSERT INTO quarantine (message_id, sender_email, reason, detail_json, created_at) VALUES (?, ?, ?, ?, ?)",
        (
            message_identity(record.headers, record.envelope_id),
            record.sender_email,
            reason,
            json.dumps(detail, sort_keys=True),
            now(),
        ),
    )


def process_envelope(
    conn: sqlite3.Connection,
    envelope: dict[str, Any],
    auto_respond: bool = False,
    dry_run: bool = False,
) -> dict[str, Any]:
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

    # Dedup BEFORE any rate accounting. Previously the sender rate limiter ran
    # first, so every re-poll of the same message inflated the per-sender count
    # and eventually quarantined a legitimate sender (live DB showed 261
    # quarantine rows for only 27 distinct messages). If we have already seen
    # this exact message, short-circuit and touch nothing.
    msg_id = message_identity(record.headers, record.envelope_id)
    already = conn.execute(
        "SELECT 1 FROM processed_messages WHERE message_id = ?", (msg_id,)
    ).fetchone()
    if already:
        return {
            "envelope_id": envelope_id,
            "inserted": False,
            "thread_key": "",
            "subject": record.subject,
            "from": sender_email,
            "classification": "duplicate",
            "next_action": "no_action_already_processed",
            "events_cc_required": True,
        }

    sender_rate = record_sender_rate(conn, record.sender_email)
    auth = auth_status(record.headers)
    spam = spam_prefilter(record)
    thread_key, reason = thread_key_for(record, conn)
    if sender_rate["disposition"] in {"deny", "rate_limited"}:
        decision = {
            "classification": "sender_quarantined",
            "next_action": "manual_review_sender_rate_or_denylist",
            "thread_reason": reason,
            "amounts": [],
            "invoice_total": None,
        }
        quarantine_message(conn, record, sender_rate["disposition"], sender_rate)
    elif spam["spam"]:
        decision = {
            "classification": "spam_or_phishing",
            "next_action": "quarantine_no_booking_state_advance",
            "thread_reason": reason,
            "amounts": [],
            "invoice_total": None,
        }
        quarantine_message(conn, record, "spam_or_phishing_prefilter", spam)
    else:
        decision = classify(record, conn, thread_key, reason)
        if not auth["authenticated"]:
            if decision["classification"] in {"payment_proof", "payment_or_attachment"}:
                decision["classification"] = "unauthenticated_payment_claim"
                decision["next_action"] = "quarantine_payment_claim_no_state_advance"
            quarantine_message(conn, record, "mail_authentication_failed", auth)
    inserted = store_message(conn, record, thread_key, decision)
    conn.execute(
        """
        INSERT OR IGNORE INTO processed_messages (message_id, envelope_id, thread_key, processed_at, status, detail_json)
        VALUES (?, ?, ?, ?, ?, ?)
        """,
        (msg_id, record.envelope_id, thread_key, now(), "processed" if inserted else "duplicate", json.dumps(decision, sort_keys=True)),
    )
    auto_response_message_id = None
    if inserted and auto_respond:
        try:
            auto_response_message_id = send_template_response(conn, thread_key, record, decision, dry_run=dry_run)
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
                                "dry_run": dry_run,
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
        "auth": auth,
        "dry_run": dry_run,
    }


def poll(limit: int, auto_respond: bool = False, dry_run: bool = False) -> dict[str, Any]:
    with ensure_db() as conn:
        state_set(conn, "current_run_sends", 0)
        if state_get(conn, "send_circuit_breaker_tripped", False):
            auto_respond = False
        resource = f"{ACCOUNT}:{FOLDER}"
        try:
            envelopes = fetch_envelopes(limit)
        except (subprocess.CalledProcessError, subprocess.TimeoutExpired) as exc:
            detail = {
                "limit": limit,
                "auto_respond": auto_respond,
                "dry_run": dry_run,
                "error_type": type(exc).__name__,
                "error": str(exc),
            }
            if isinstance(exc, subprocess.CalledProcessError):
                detail["returncode"] = exc.returncode
                detail["stderr"] = (exc.stderr or "")[-2000:]
            log_access(conn, "mailbox_poll_failed", resource, detail)
            conn.commit()
            raise
        log_access(
            conn,
            "mailbox_poll_succeeded",
            resource,
            {"limit": limit, "message_count": len(envelopes), "auto_respond": auto_respond, "dry_run": dry_run},
        )
        results = [
            process_envelope(conn, envelope, auto_respond=auto_respond, dry_run=dry_run) for envelope in envelopes
        ]
        state_set(conn, "last_successful_poll", now())
        conn.execute(
            """
            INSERT INTO daily_health_digest (digest_date, runs, messages_classified, sends, escalations, detail_json, updated_at)
            VALUES (?, 1, ?, ?, ?, '{}', ?)
            ON CONFLICT(digest_date) DO UPDATE SET
                runs = runs + 1,
                messages_classified = messages_classified + excluded.messages_classified,
                sends = sends + excluded.sends,
                escalations = escalations + excluded.escalations,
                updated_at = excluded.updated_at
            """,
            (
                lagos_date(),
                len(results),
                int(state_get(conn, "current_run_sends", 0) or 0),
                len([item for item in results if "review" in item["next_action"] or "escalate" in item["next_action"]]),
                now(),
            ),
        )
        conn.commit()
    inserted = [item for item in results if item["inserted"]]
    return {
        "account": ACCOUNT,
        "folder": FOLDER,
        "checked": len(results),
        "new_records": len(inserted),
        "auto_respond": auto_respond,
        "dry_run": dry_run,
        "actions": inserted,
    }


def watchdog() -> dict[str, Any]:
    config = load_config()
    minutes = int((config.get("reliability") or {}).get("watchdog_minutes") or 30)
    with ensure_db() as conn:
        last = state_get(conn, "last_successful_poll")
        if not last:
            alert = True
            age_minutes = None
        else:
            age_minutes = (datetime.now() - datetime.fromisoformat(last)).total_seconds() / 60
            alert = age_minutes > minutes
        if alert:
            conn.execute(
                "INSERT INTO action_log (thread_key, action, detail_json, created_at) VALUES (?, ?, ?, ?)",
                (
                    "system",
                    "watchdog_alert",
                    json.dumps(
                        {
                            "last_successful_poll": last,
                            "threshold_minutes": minutes,
                            "alert_channel": (config.get("reliability") or {}).get("md_monitored_alert_channel"),
                        },
                        sort_keys=True,
                    ),
                    now(),
                ),
            )
            conn.commit()
    return {"alert": alert, "last_successful_poll": last, "age_minutes": age_minutes, "threshold_minutes": minutes}


def reset_send_circuit() -> dict[str, Any]:
    with ensure_db() as conn:
        state_set(conn, "send_circuit_breaker_tripped", False)
        state_set(conn, "auto_respond_enabled", True)
        state_set(conn, "current_run_sends", 0)
        conn.execute(
            "INSERT INTO action_log (thread_key, action, detail_json, created_at) VALUES (?, ?, ?, ?)",
            ("system", "send_circuit_breaker_manual_reset", "{}", now()),
        )
        conn.commit()
    return {"ok": True, "send_circuit_breaker_tripped": False, "auto_respond_enabled": True}


def resolve_form_link(respondent_email: str, host_name: str, event_date: str, facility: str) -> dict[str, Any]:
    with ensure_db() as conn:
        email_rows = conn.execute(
            """
            SELECT thread_key, subject, client_email FROM conversations
            WHERE client_email = ?
            ORDER BY updated_at DESC
            """,
            (respondent_email.lower(),),
        ).fetchall()
        if len(email_rows) == 1:
            return {"linked": True, "reason": "respondent_email", "thread_key": email_rows[0][0]}
        if len(email_rows) > 1:
            return {"linked": False, "manual_review": True, "reason": "multiple_email_matches"}
        pattern_host = f"%{host_name}%"
        pattern_date = f"%{event_date}%"
        pattern_facility = f"%{facility}%"
        fallback_rows = conn.execute(
            """
            SELECT c.thread_key, c.subject, c.client_email
            FROM conversations c
            LEFT JOIN action_log a ON a.thread_key = c.thread_key
            WHERE (c.subject LIKE ? OR a.detail_json LIKE ?)
              AND (c.subject LIKE ? OR a.detail_json LIKE ?)
              AND (c.subject LIKE ? OR a.detail_json LIKE ?)
            GROUP BY c.thread_key
            ORDER BY c.updated_at DESC
            """,
            (pattern_host, pattern_host, pattern_date, pattern_date, pattern_facility, pattern_facility),
        ).fetchall()
        if len(fallback_rows) == 1:
            return {"linked": True, "reason": "host_date_facility", "thread_key": fallback_rows[0][0]}
        return {
            "linked": False,
            "manual_review": True,
            "reason": "ambiguous_fallback_match" if fallback_rows else "no_match",
            "candidate_count": len(fallback_rows),
        }


def record_invoice(args: argparse.Namespace) -> dict[str, Any]:
    """Record a sent invoice for a thread.

    Guard (rule 8): if the caller supplies --expected-updated-at, the write is
    only applied when the conversation is still at that revision. A mismatch
    means the booking was edited after the invoice was priced, so the invoice
    amount may no longer match - we refuse instead of silently billing a stale
    amount.
    """
    with ensure_db() as conn:
        current = conn.execute(
            "SELECT updated_at, status, invoice_id FROM conversations WHERE thread_key = ?",
            (args.thread_key,),
        ).fetchone()
        if current is None:
            raise SystemExit(f"Unknown thread_key: {args.thread_key}")

        if args.expected_updated_at and current[0] != args.expected_updated_at:
            conn.execute(
                "INSERT INTO action_log (thread_key, action, detail_json, created_at) VALUES (?, ?, ?, ?)",
                (
                    args.thread_key,
                    "invoice_record_refused_stale_revision",
                    json.dumps(
                        {
                            "expected_updated_at": args.expected_updated_at,
                            "actual_updated_at": current[0],
                            "invoice_number": args.invoice_number,
                            "amount": args.amount,
                        },
                        sort_keys=True,
                    ),
                    now(),
                ),
            )
            conn.commit()
            raise SystemExit(
                "Invoice recording refused for thread "
                f"{args.thread_key}: conversation changed after it was priced "
                f"(expected {args.expected_updated_at}, found {current[0]}). "
                "Re-quote before invoicing."
            )

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


def _require_confirmation_guards(conn: sqlite3.Connection, thread_key: str) -> dict[str, Any]:
    """Collect the conversation row and assert every confirmation gate is satisfied.

    Policy gates that MUST hold before a booking can be Confirmed:
      1. An invoice was recorded and is not in a failed state.
      2. Payment proof was recorded against the thread.
      3. finance@iih.ng confirmed the payment.
      4. Availability was checked (evidence recorded) at/after invoice time.

    Raises ConfirmationBlocked (SystemExit) listing every unmet gate, so the
    operator sees all missing evidence at once rather than one at a time.
    """
    row = conn.execute(
        """
        SELECT status, invoice_id, invoice_number, invoice_status, invoice_total,
               payment_proof_reference, payment_proof_at,
               finance_confirmed_at, finance_confirmation_reference,
               availability_checked_at, availability_evidence
        FROM conversations WHERE thread_key = ?
        """,
        (thread_key,),
    ).fetchone()
    if row is None:
        raise SystemExit(f"Unknown thread_key: {thread_key}")

    (status, invoice_id, invoice_number, invoice_status, invoice_total,
     pay_ref, pay_at, fin_at, fin_ref, avail_at, avail_ev) = row

    blockers: list[str] = []

    # Gate 1 - an invoice exists and is recorded as sent.
    if not invoice_id or not invoice_number:
        blockers.append("no_invoice_recorded")
    elif (invoice_status or "").lower() in {"", "draft", "failed", "void", "cancelled"}:
        blockers.append(f"invoice_status_not_sendable:{invoice_status}")

    # Gate 2 - payment proof captured.
    if not (pay_ref or pay_at):
        blockers.append("no_payment_proof_recorded")

    # Gate 3 - finance confirmed.
    if not fin_at:
        blockers.append("no_finance_confirmation")

    # Gate 4 - availability checked (evidence recorded).
    if not (avail_at or avail_ev):
        blockers.append("no_availability_check_recorded")

    return {
        "blockers": blockers,
        "status": status,
        "invoice_id": invoice_id,
        "invoice_number": invoice_number,
        "invoice_status": invoice_status,
        "invoice_total": invoice_total,
        "finance_confirmed_at": fin_at,
    }


def mark_confirmed(args: argparse.Namespace) -> dict[str, Any]:
    """Confirm a booking ONLY after every policy gate is satisfied.

    Previously this flipped status to Confirmed with no checks at all, which let
    a booking be confirmed without an invoice, payment, finance sign-off or an
    availability check. It now refuses and records the refusal in action_log.
    """
    with ensure_db() as conn:
        guards = _require_confirmation_guards(conn, args.thread_key)
        if guards["blockers"]:
            conn.execute(
                "INSERT INTO action_log (thread_key, action, detail_json, created_at) VALUES (?, ?, ?, ?)",
                (
                    args.thread_key,
                    "confirmation_refused_guard_failed",
                    json.dumps(
                        {
                            "blockers": guards["blockers"],
                            "status": guards["status"],
                            "invoice_number": guards["invoice_number"],
                            "calendar_event_uid": args.calendar_event_uid,
                        },
                        sort_keys=True,
                    ),
                    now(),
                ),
            )
            conn.commit()
            raise SystemExit(
                "Confirmation refused for thread "
                f"{args.thread_key}: unmet gates -> {', '.join(guards['blockers'])}"
            )

        conn.execute(
            """
            UPDATE conversations
            SET status = 'Confirmed',
                invoice_status = 'paid',
                calendar_event_uid = COALESCE(?, calendar_event_uid),
                next_action = 'confirmed_calendar_handoff_complete',
                events_cc_required = 1,
                confirmed_at = ?,
                confirmed_by = ?,
                updated_at = ?
            WHERE thread_key = ?
            """,
            (args.calendar_event_uid, now(), args.confirmed_by, now(), args.thread_key),
        )
        if conn.total_changes == 0:
            raise SystemExit(f"Unknown thread_key: {args.thread_key}")
        conn.execute(
            "INSERT INTO action_log (thread_key, action, detail_json, created_at) VALUES (?, ?, ?, ?)",
            (
                args.thread_key,
                "booking_confirmed_after_payment_match",
                json.dumps(
                    {
                        "calendar_event_uid": args.calendar_event_uid,
                        "invoice_number": guards["invoice_number"],
                        "finance_confirmed_at": guards["finance_confirmed_at"],
                        "confirmed_by": args.confirmed_by,
                        "cc": EVENTS_CC,
                    },
                    sort_keys=True,
                ),
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
        # Finance confirmation is only meaningful once an invoice exists.
        existing = conn.execute(
            "SELECT invoice_id, invoice_number, status FROM conversations WHERE thread_key = ?",
            (args.thread_key,),
        ).fetchone()
        if existing is None:
            raise SystemExit(f"Unknown thread_key: {args.thread_key}")
        if not existing[0] or not existing[1]:
            conn.execute(
                "INSERT INTO action_log (thread_key, action, detail_json, created_at) VALUES (?, ?, ?, ?)",
                (
                    args.thread_key,
                    "finance_confirmation_refused_no_invoice",
                    json.dumps({"status": existing[2], "reference": args.reference}, sort_keys=True),
                    now(),
                ),
            )
            conn.commit()
            raise SystemExit(
                f"Finance confirmation refused for {args.thread_key}: no invoice recorded yet."
            )

        conn.execute(
            """
            UPDATE conversations
            SET status = 'Finance Confirmed',
                invoice_status = 'finance_confirmed_paid',
                finance_confirmed_at = ?,
                finance_confirmation_reference = ?,
                next_action = 'create_confirmed_calendar_event',
                events_cc_required = 1,
                updated_at = ?
            WHERE thread_key = ?
            """,
            (now(), args.reference, now(), args.thread_key),
        )
        if conn.total_changes == 0:
            raise SystemExit(f"Unknown thread_key: {args.thread_key}")
        conn.execute(
            "INSERT INTO action_log (thread_key, action, detail_json, created_at) VALUES (?, ?, ?, ?)",
            (
                args.thread_key,
                "finance_confirmed_payment",
                json.dumps(
                    {
                        "finance_email": "finance@iih.ng",
                        "confirmation_reference": args.reference,
                        "invoice_number": existing[1],
                    },
                    sort_keys=True,
                ),
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


def record_payment_proof(args: argparse.Namespace) -> dict[str, Any]:
    """Record client payment proof (gate 2) before finance can confirm it."""
    with ensure_db() as conn:
        existing = conn.execute(
            "SELECT invoice_id, invoice_number FROM conversations WHERE thread_key = ?",
            (args.thread_key,),
        ).fetchone()
        if existing is None:
            raise SystemExit(f"Unknown thread_key: {args.thread_key}")
        if not existing[0]:
            raise SystemExit(
                f"Payment proof refused for {args.thread_key}: no invoice recorded yet."
            )
        conn.execute(
            """
            UPDATE conversations
            SET payment_proof_reference = ?,
                payment_proof_at = ?,
                payment_amount = ?,
                next_action = 'await_finance_confirmation',
                updated_at = ?
            WHERE thread_key = ?
            """,
            (args.reference, now(), args.amount, now(), args.thread_key),
        )
        conn.execute(
            "INSERT INTO action_log (thread_key, action, detail_json, created_at) VALUES (?, ?, ?, ?)",
            (
                args.thread_key,
                "payment_proof_recorded",
                json.dumps(
                    {
                        "reference": args.reference,
                        "amount": args.amount,
                        "invoice_number": existing[1],
                        "payer": args.payer,
                    },
                    sort_keys=True,
                ),
                now(),
            ),
        )
        conn.commit()
    return {
        "ok": True,
        "thread_key": args.thread_key,
        "next_action": "await_finance_confirmation",
    }


def record_availability_check(args: argparse.Namespace) -> dict[str, Any]:
    """Record that availability was checked against the events calendar (gate 4)."""
    with ensure_db() as conn:
        existing = conn.execute(
            "SELECT status FROM conversations WHERE thread_key = ?",
            (args.thread_key,),
        ).fetchone()
        if existing is None:
            raise SystemExit(f"Unknown thread_key: {args.thread_key}")
        conn.execute(
            """
            UPDATE conversations
            SET availability_checked_at = ?,
                availability_evidence = ?,
                updated_at = ?
            WHERE thread_key = ?
            """,
            (now(), args.evidence, now(), args.thread_key),
        )
        conn.execute(
            "INSERT INTO action_log (thread_key, action, detail_json, created_at) VALUES (?, ?, ?, ?)",
            (
                args.thread_key,
                "availability_check_recorded",
                json.dumps({"evidence": args.evidence, "available": args.available}, sort_keys=True),
                now(),
            ),
        )
        conn.commit()
    return {"ok": True, "thread_key": args.thread_key, "availability_checked_at": now()}


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
    poll_parser.add_argument("--dry-run", action="store_true", help="Classify and compose previews without sending.")
    poll_parser.add_argument("--pretty", action="store_true")

    state_parser = sub.add_parser("state", help="Show recent booking-agent conversation state.")
    state_parser.add_argument("--limit", type=int, default=20)
    state_parser.add_argument("--pretty", action="store_true")

    invoice_parser = sub.add_parser("record-invoice", help="Record sent invoice metadata for a thread.")
    invoice_parser.add_argument("--thread-key", required=True)
    invoice_parser.add_argument("--invoice-id", required=True)
    invoice_parser.add_argument("--invoice-number", required=True)
    invoice_parser.add_argument("--amount", type=int, required=True)
    invoice_parser.add_argument(
        "--expected-updated-at",
        default="",
        help="Optimistic-concurrency guard: refuse if the conversation revision differs.",
    )
    invoice_parser.add_argument("--pretty", action="store_true")

    payment_parser = sub.add_parser("record-payment-proof", help="Record client payment proof for a thread.")
    payment_parser.add_argument("--thread-key", required=True)
    payment_parser.add_argument("--reference", required=True)
    payment_parser.add_argument("--amount", type=int, default=0)
    payment_parser.add_argument("--payer", default="")
    payment_parser.add_argument("--pretty", action="store_true")

    confirm_parser = sub.add_parser("mark-confirmed", help="Mark a thread confirmed after matched payment proof.")
    confirm_parser.add_argument("--thread-key", required=True)
    confirm_parser.add_argument("--calendar-event-uid", default="")
    confirm_parser.add_argument("--confirmed-by", default="aisha")
    confirm_parser.add_argument("--pretty", action="store_true")

    finance_parser = sub.add_parser("mark-finance-confirmed", help="Record finance@iih.ng confirmation of payment.")
    finance_parser.add_argument("--thread-key", required=True)
    finance_parser.add_argument("--reference", default="")
    finance_parser.add_argument("--pretty", action="store_true")

    availability_parser = sub.add_parser("record-availability", help="Record an availability check against the events calendar.")
    availability_parser.add_argument("--thread-key", required=True)
    availability_parser.add_argument("--evidence", required=True)
    availability_parser.add_argument("--available", type=int, default=1)
    availability_parser.add_argument("--pretty", action="store_true")

    watchdog_parser = sub.add_parser("watchdog", help="Alert if no successful poll has completed recently.")
    watchdog_parser.add_argument("--pretty", action="store_true")

    reset_parser = sub.add_parser("reset-send-circuit", help="Manual reset for the send circuit breaker.")
    reset_parser.add_argument("--pretty", action="store_true")

    link_parser = sub.add_parser("resolve-form-link", help="Resolve form submission to a booking thread safely.")
    link_parser.add_argument("--respondent-email", required=True)
    link_parser.add_argument("--host-name", required=True)
    link_parser.add_argument("--event-date", required=True)
    link_parser.add_argument("--facility", required=True)
    link_parser.add_argument("--pretty", action="store_true")

    args = parser.parse_args()
    if args.command == "poll":
        output = poll(args.limit, auto_respond=args.auto_respond, dry_run=args.dry_run)
    elif args.command == "state":
        output = state(args.limit)
    elif args.command == "record-invoice":
        output = record_invoice(args)
    elif args.command == "record-payment-proof":
        output = record_payment_proof(args)
    elif args.command == "mark-confirmed":
        output = mark_confirmed(args)
    elif args.command == "mark-finance-confirmed":
        output = mark_finance_confirmed(args)
    elif args.command == "record-availability":
        output = record_availability_check(args)
    elif args.command == "watchdog":
        output = watchdog()
    elif args.command == "reset-send-circuit":
        output = reset_send_circuit()
    elif args.command == "resolve-form-link":
        output = resolve_form_link(args.respondent_email, args.host_name, args.event_date, args.facility)
    else:
        raise SystemExit(f"Unknown command: {args.command}")

    print(json.dumps(output, indent=2 if getattr(args, "pretty", False) else None))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
