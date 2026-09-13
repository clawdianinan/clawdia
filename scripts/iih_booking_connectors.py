#!/usr/bin/env python3
"""IIH booking connectors for Zoho Books, Zoho CRM, Zoho Calendar, and local holds.

Default behavior is dry-run/read-only. Live Zoho writes require --confirm-live.
Email/invoice sends additionally require --confirm-email-send.
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
import sqlite3
import subprocess
import sys
import urllib.error
import urllib.parse
import urllib.request
import uuid
from datetime import date, datetime, time, timedelta
from pathlib import Path
from typing import Any

SCRIPT_DIR = Path(__file__).resolve().parent
WORKSPACE_DIR = SCRIPT_DIR.parent
BOOKING_DIR = WORKSPACE_DIR / "documents" / "IIH" / "Bookings"
CONFIG_PATH = WORKSPACE_DIR / "config" / "iih_booking_system.json"
REGISTER_PATH = BOOKING_DIR / "booking_register.sqlite3"
STATE_PATH = BOOKING_DIR / "booking_agent.sqlite3"
MIGRATIONS_DIR = BOOKING_DIR / "migrations"
SIGNATURE_LOGO_PATH = WORKSPACE_DIR / "analysis" / "security_report" / "1749122382045004_1686933120.png"
SIGNATURE_LOGO_CID = "iih-signature-logo"

sys.path.insert(0, str(SCRIPT_DIR))
import iih_booking_quote as quote  # noqa: E402

REQUIRED_SECRET_NAMES = [
    "ZOHO_CLIENT_ID",
    "ZOHO_CLIENT_SECRET",
    "ZOHO_REFRESH_TOKEN",
    "ZOHO_BOOKS_ORG_ID",
]

OPTIONAL_SECRET_NAMES = [
    "ZOHO_APP_PASSWORD",
    "ZOHO_EMAIL",
    "ZOHO_FROM",
    "ZOHO_CALENDAR_UID",
]

EVENTBOOKINGS_EMAIL = "facilitybookings@iih.ng"
EVENTS_CC = "events@iih.ng"
EVERYONE_CC = "everyone@iih.ng"
BOOKING_SIGNATURE_TEXT = """Warm regards,

Aisha
IIH Facility Booking AI Agent | Ilorin Innovation Hub
www.iih.ng
Ahmadu Bello Way, GRA, Ilorin, Kwara State, Nigeria

This message and any attachments are confidential and intended only for the recipient."""
BOOKING_SIGNATURE = BOOKING_SIGNATURE_TEXT
BOOKING_SIGNATURE_HTML = """<div style="clear: both;">
 Warm regards,
 <br>
 <br>
</div>
<div style="font-family: Arial, sans-serif; font-size: 14px; color: #333; line-height: 1.5;">
 <div>
 <table class="ze_tableView" cellpadding="2" cellspacing="2" border="0" style="font-size: 10pt; font-family: Arial, Helvetica, sans-serif; border-collapse: collapse; border: 0px solid black; color: black;">
 <tbody>
 <tr>
 <td style="vertical-align: top; width: 158.141px;">
 <div>
 <img src="cid:iih-signature-logo" width="155" height="74" style="float: left;" orig_width="371" orig_height="181">
 <br>
 </div>
 </td>
 <td style="vertical-align: top; width: 645.859px;">
 <div style="font-family: Arial, sans-serif; font-size: 14px; color: #333; line-height: 1.5;">
 <div>
 <div>
 <b>
 <span class="size" style="font-size:10.6667px">
 Aisha
 <br>
 </span>
 </b>
 <span class="size" style="font-size:10.6667px">
 IIH Facility Booking AI Agent&nbsp;|
 <span class="colour" style="color:rgb(0, 204, 0)">
 Ilorin Innovation Hub
 </span>
 <span class="colour" style="color: rgb(106, 168, 79); font-weight: 500;">
 <br>
 </span>
 </span>
 <a target="_blank" style="color: #1a73e8;" href="https://iih.ng">
 <span class="size" style="font-size:10.6667px">
 www.iih.ng
 </span>
 </a>
 <span class="size" style="font-size:10.6667px">
 <br>
 Ahmadu Bello Way, GRA, Ilorin, Kwara State, Nigeria
 </span>
 <br>
 </div>
 </div>
 </div>
 </td>
 </tr>
 </tbody>
 </table>
 <p>
 <span class="colour" style="color:rgb(153, 153, 153)">
 <span class="size" style="font-size:10.6667px">
 This message and any attachments are confidential and intended only for the recipient.&nbsp;
 </span>
 </span>
 <br>
 </p>
 </div>
</div>
<div style="clear: both;">
 <br>
</div>"""


def attach_signature_logo(message: Any) -> None:
    if not SIGNATURE_LOGO_PATH.exists():
        raise ConnectorError(f"Missing IIH signature logo asset: {SIGNATURE_LOGO_PATH}")
    for part in message.walk():
        if part.get_content_type() == "text/html":
            part.add_related(
                SIGNATURE_LOGO_PATH.read_bytes(),
                maintype="image",
                subtype="png",
                cid=f"<{SIGNATURE_LOGO_CID}>",
                filename=SIGNATURE_LOGO_PATH.name,
            )
            return
    raise ConnectorError("Cannot attach IIH signature logo because the message has no HTML part.")


class ConnectorError(RuntimeError):
    pass


def load_config() -> dict[str, Any]:
    with CONFIG_PATH.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def read_secret(name: str, required: bool = True) -> str | None:
    if name in {"ZOHO_EMAIL", "ZOHO_FROM"}:
        return EVENTBOOKINGS_EMAIL

    value = os.environ.get(name)
    if value:
        return value

    service = os.environ.get(f"IIH_BOOKING_{name}_SERVICE", f"iih-booking-{name}")
    try:
        result = subprocess.run(
            ["security", "find-generic-password", "-s", service, "-w"],
            check=True,
            capture_output=True,
            text=True,
        )
        value = result.stdout.strip()
        if value:
            return value
    except (subprocess.CalledProcessError, FileNotFoundError):
        pass

    if required:
        raise ConnectorError(f"Missing required secret: {name}")
    return None


def secret_status() -> dict[str, bool]:
    status: dict[str, bool] = {}
    for name in REQUIRED_SECRET_NAMES + OPTIONAL_SECRET_NAMES:
        try:
            status[name] = bool(read_secret(name, required=False))
        except ConnectorError:
            status[name] = False
    return status


def request_json(
    method: str,
    url: str,
    token: str | None = None,
    payload: dict[str, Any] | None = None,
    form: dict[str, str] | None = None,
) -> dict[str, Any]:
    data: bytes | None = None
    headers: dict[str, str] = {}

    if payload is not None:
        data = json.dumps(payload).encode("utf-8")
        headers["Content-Type"] = "application/json"
    elif form is not None:
        data = urllib.parse.urlencode(form).encode("utf-8")
        headers["Content-Type"] = "application/x-www-form-urlencoded"

    if token:
        headers["Authorization"] = f"Zoho-oauthtoken {token}"

    request = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            body = response.read().decode("utf-8")
            return json.loads(body) if body else {}
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")
        raise ConnectorError(f"HTTP {exc.code} from {url}: {body}") from exc
    except urllib.error.URLError as exc:
        raise ConnectorError(f"Network error calling {url}: {exc}") from exc


def get_zoho_token() -> str:
    response = request_json(
        "POST",
        "https://accounts.zoho.com/oauth/v2/token",
        form={
            "refresh_token": read_secret("ZOHO_REFRESH_TOKEN") or "",
            "client_id": read_secret("ZOHO_CLIENT_ID") or "",
            "client_secret": read_secret("ZOHO_CLIENT_SECRET") or "",
            "grant_type": "refresh_token",
        },
    )
    token = response.get("access_token")
    if not token:
        raise ConnectorError("Zoho token response did not include access_token.")
    return str(token)


def books_base() -> str:
    org_id = read_secret("ZOHO_BOOKS_ORG_ID")
    return f"https://www.zohoapis.com/books/v3?organization_id={org_id}"


def books_url(path: str, params: dict[str, str] | None = None) -> str:
    org_id = read_secret("ZOHO_BOOKS_ORG_ID")
    query = {"organization_id": org_id or ""}
    if params:
        query.update(params)
    return f"https://www.zohoapis.com/books/v3/{path}?{urllib.parse.urlencode(query)}"


def find_or_create_books_contact(token: str, booking: dict[str, Any], live: bool) -> dict[str, Any]:
    search = request_json(
        "GET",
        books_url("contacts", {"email": booking["email"]}),
        token=token,
    )
    contacts = search.get("contacts") or []
    if contacts:
        return {"contact_id": contacts[0]["contact_id"], "created": False, "raw": contacts[0]}

    name_parts = str(booking["full_name"]).split()
    payload = {
        "contact_name": booking.get("organization") or booking["full_name"],
        "contact_type": "customer",
        "contact_persons": [
            {
                "first_name": name_parts[0] if name_parts else booking["full_name"],
                "last_name": " ".join(name_parts[1:]) if len(name_parts) > 1 else "",
                "email": booking["email"],
                "phone": booking["phone"],
                "is_primary_contact": True,
            }
        ],
    }
    if not live:
        return {"contact_id": None, "created": True, "dry_run_payload": payload}

    created = request_json("POST", books_url("contacts"), token=token, payload=payload)
    return {"contact_id": created["contact"]["contact_id"], "created": True, "raw": created}


def build_invoice_payload(contact_id: str, booking: dict[str, Any]) -> dict[str, Any]:
    bundle = quote.build_bundle(booking)
    allowed = {
        "item_id",
        "name",
        "description",
        "quantity",
        "rate",
        "tax_id",
        "tax_name",
        "tax_percentage",
    }
    return {
        "customer_id": contact_id,
        "date": bundle["invoice"]["date"],
        "due_date": bundle["invoice"]["due_date"],
        "line_items": [
            {
                key: value
                for key, value in item.items()
                if key in allowed and value is not None
            }
            for item in bundle["quote"]["line_items"]
        ],
        "notes": bundle["invoice"]["notes"],
        "terms": bundle["invoice"]["terms"],
    }


def create_invoice(token: str, contact_id: str, booking: dict[str, Any], live: bool) -> dict[str, Any]:
    payload = build_invoice_payload(contact_id, booking)
    if not live:
        return {"invoice_id": None, "dry_run_payload": payload}
    created = request_json("POST", books_url("invoices"), token=token, payload=payload)
    return {"invoice_id": created["invoice"]["invoice_id"], "raw": created}


def invoice_email_payload(booking: dict[str, Any], reminder: bool = False) -> dict[str, Any]:
    subject_prefix = "Payment Reminder" if reminder else "Invoice"
    opening = (
        "This is a reminder that payment is required to confirm your booking at Ilorin Innovation Hub. "
        if reminder
        else "Thank you for your booking inquiry at Ilorin Innovation Hub. "
    )
    action_line = (
        "Please review the attached invoice and send proof of payment once completed. "
        if reminder
        else "Please find attached your invoice. "
    )
    body_text = (
        f"Dear {booking['full_name']},\n\n"
        f"{opening}"
        f"{action_line}"
        f"The invoice covers the {booking['facility']} on {booking['event_date']}.\n\n"
        "Kindly make payment within 7 days to confirm your booking. "
        "Your calendar slot will be confirmed after payment proof is received and matched to the invoice amount.\n\n"
        f"For questions, contact {EVENTBOOKINGS_EMAIL}.\n\n"
        f"{BOOKING_SIGNATURE}"
    )
    body_html = (
        f"<p>Dear {booking['full_name']},</p>"
        f"<p>{opening.strip()}</p>"
        f"<p>{action_line.strip()}</p>"
        f"<p>The invoice covers the <strong>{booking['facility']}</strong> on <strong>{booking['event_date']}</strong>.</p>"
        "<p>Kindly make payment within 7 days to confirm your booking. "
        "Your calendar slot will be confirmed after payment proof is received and matched to the invoice amount.</p>"
        f"<p>For questions, contact <a href=\"mailto:{EVENTBOOKINGS_EMAIL}\">{EVENTBOOKINGS_EMAIL}</a>.</p>"
        f"{BOOKING_SIGNATURE_HTML}"
    )
    cc_mail_ids: list[str] = []
    for email in [EVENTS_CC, *(booking.get("cc_emails") or [])]:
        normalized = str(email).lower().strip()
        if not normalized or normalized in {booking["email"].lower(), EVENTBOOKINGS_EMAIL, "md@iih.ng"}:
            continue
        if normalized not in cc_mail_ids:
            cc_mail_ids.append(normalized)
    return {
        "to_mail_ids": [booking["email"]],
        "cc_mail_ids": cc_mail_ids,
        "subject": f"{subject_prefix} for {booking['facility']} Booking - {booking['event_name']} | IIH Space",
        "body": body_text,
    }


def send_invoice_email(token: str, invoice_id: str, booking: dict[str, Any], live: bool) -> dict[str, Any]:
    payload = invoice_email_payload(booking)
    if not live:
        return {
            "sent": False,
            "delivery": "download_pdf_and_reply_to_existing_thread",
            "dry_run_payload": payload,
        }
    raise ConnectorError(
        "Invoice delivery must reply to the existing client email thread with the downloaded invoice PDF attached; "
        "do not send invoices from Zoho Books."
    )


def send_payment_reminder(token: str, invoice_id: str, booking: dict[str, Any], live: bool) -> dict[str, Any]:
    payload = invoice_email_payload(booking, reminder=True)
    if not live:
        return {
            "sent": False,
            "delivery": "reply_to_existing_client_thread",
            "dry_run_payload": payload,
        }
    raise ConnectorError(
        "Payment reminders must reply to the existing client email thread; "
        "do not send payment reminders from Zoho Books or a fresh email thread."
    )


def assert_booking_identity() -> None:
    configured_from = read_secret("ZOHO_FROM", required=False)
    configured_email = read_secret("ZOHO_EMAIL", required=False)
    configured_values = [value.lower() for value in (configured_from, configured_email) if value]
    if EVENTBOOKINGS_EMAIL not in configured_values:
        raise ConnectorError(
            "Booking email sends require ZOHO_FROM or ZOHO_EMAIL to be facilitybookings@iih.ng."
        )
    if "md@iih.ng" in configured_values:
        raise ConnectorError("md@iih.ng is excluded from the IIH Booking System.")


def create_or_update_crm_contact(token: str, booking: dict[str, Any], live: bool) -> dict[str, Any]:
    criteria = f"(Email:equals:{booking['email']})"
    search_url = "https://www.zohoapis.com/crm/v2/Contacts/search?" + urllib.parse.urlencode(
        {"criteria": criteria}
    )
    try:
        search = request_json("GET", search_url, token=token)
    except ConnectorError as exc:
        if "HTTP 204" in str(exc):
            search = {}
        else:
            raise

    data = search.get("data") or []
    if data:
        contact_id = data[0]["id"]
        payload = {"data": [{"id": contact_id, "Phone": booking["phone"]}]}
        if not live:
            return {"contact_id": contact_id, "updated": True, "dry_run_payload": payload}
        updated = request_json(
            "PUT",
            f"https://www.zohoapis.com/crm/v2/Contacts/{contact_id}",
            token=token,
            payload=payload,
        )
        return {"contact_id": contact_id, "updated": True, "raw": updated}

    name_parts = str(booking["full_name"]).strip().split()
    payload = {
        "data": [
            {
                "First_Name": name_parts[0] if name_parts else booking["full_name"],
                "Last_Name": " ".join(name_parts[1:]) if len(name_parts) > 1 else "-",
                "Email": booking["email"],
                "Phone": booking["phone"],
                "Account_Name": booking.get("organization"),
                "Lead_Source": "IIH Space Booking Form",
                "Description": f"First booking: {booking['facility']} on {booking['event_date']} for '{booking['event_name']}'",
            }
        ],
        "trigger": ["workflow"],
    }
    if not live:
        return {"contact_id": None, "created": True, "dry_run_payload": payload}
    created = request_json("POST", "https://www.zohoapis.com/crm/v2/Contacts", token=token, payload=payload)
    return {"contact_id": created["data"][0]["details"]["id"], "created": True, "raw": created}


def calendar_uid(token: str) -> str:
    configured_uid = read_secret("ZOHO_CALENDAR_UID", required=False)
    if configured_uid:
        return configured_uid
    calendars = request_json("GET", "https://calendar.zoho.com/api/v1/calendars", token=token)
    all_calendars = calendars.get("calendars") or []
    if not all_calendars:
        raise ConnectorError("No Zoho calendars returned.")
    primary = next((cal for cal in all_calendars if cal.get("isdefault")), all_calendars[0])
    return str(primary["uid"])


def build_calendar_payload(booking: dict[str, Any], status: str = "tentative") -> dict[str, Any]:
    start = datetime.strptime(f"{booking['event_date']} {booking['start_time']}", "%Y-%m-%d %H:%M")
    if booking.get("end_time"):
        end = datetime.strptime(f"{booking['event_date']} {booking['end_time']}", "%Y-%m-%d %H:%M")
    else:
        end = start + timedelta(hours=float(booking["duration_hours"]))
    label = "TENTATIVE" if status == "tentative" else "CONFIRMED"
    return {
        "dateandtime": {
            "start": start.strftime("%Y%m%dT%H%M%S"),
            "end": end.strftime("%Y%m%dT%H%M%S"),
            "timezone": "Africa/Lagos",
        },
        "title": f"[{label}] {booking['facility']} - {booking['event_name']}",
        "description": (
            f"Organizer: {booking['full_name']} ({booking.get('organization', '')})\n"
            f"Email: {booking['email']}\n"
            f"Phone: {booking['phone']}\n"
            f"Attendees: {booking['expected_attendance']}\n"
            f"Booking inbox: {EVENTBOOKINGS_EMAIL}\n"
            f"External Catering: {'Yes (NGN 100k corkage)' if booking.get('external_catering') else 'No'}"
        ),
        "isprivate": False,
        "attendees": [
            {"email": EVENTS_CC},
            {"email": EVERYONE_CC},
        ],
        "reminders": [{"minutes": "1440", "action": "email"}],
    }


def create_calendar_event(token: str, booking: dict[str, Any], live: bool, status: str = "tentative") -> dict[str, Any]:
    payload = build_calendar_payload(booking, status=status)
    if not live:
        return {"event_uid": None, "dry_run_payload": payload}
    uid = calendar_uid(token)
    created = request_json(
        "POST",
        f"https://calendar.zoho.com/api/v1/calendars/{uid}/events",
        token=token,
        form={"eventdata": json.dumps(payload)},
    )
    event_uid = (created.get("events") or [{}])[0].get("uid")
    return {"event_uid": event_uid, "raw": created}


def get_calendar_event(token: str, event_uid: str) -> dict[str, Any]:
    """Fetch a single calendar event, returning raw data including etag."""
    cal_uid = calendar_uid(token)
    response = request_json(
        "GET",
        f"https://calendar.zoho.com/api/v1/calendars/{cal_uid}/events/{event_uid}",
        token=token,
    )
    events = response.get("events") or []
    if not events:
        raise ConnectorError(f"Event {event_uid} not found")
    return events[0]


def update_calendar_event(
    token: str, event_uid: str, updates: dict[str, Any], live: bool = False
) -> dict[str, Any]:
    """Update an existing calendar event via PUT with eventdata as query param.

    Fetches the latest etag automatically. The `updates` dict should contain
    the fields to change (title, dateandtime, description, etc).
    """
    current = get_calendar_event(token, event_uid)
    etag = current.get("etag")
    if not etag:
        raise ConnectorError("No etag found on calendar event")

    updates["etag"] = etag
    cal_uid = calendar_uid(token)

    if not live:
        return {"event_uid": event_uid, "dry_run": True, "updates": updates}

    params = urllib.parse.urlencode({"eventdata": json.dumps(updates)})
    url = f"https://calendar.zoho.com/api/v1/calendars/{cal_uid}/events/{event_uid}?{params}"

    req = urllib.request.Request(url, method="PUT")
    req.add_header("Authorization", f"Zoho-oauthtoken {token}")
    req.add_header("Content-Type", "application/x-www-form-urlencoded")

    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            body = resp.read().decode()
            result = json.loads(body)
            ev = (result.get("events") or [{}])[0]
            return {"event_uid": ev.get("uid", event_uid), "raw": result}
    except urllib.error.HTTPError as e:
        body = e.read().decode(errors="replace") if e.fp else ""
        raise ConnectorError(f"HTTP {e.code} updating event: {body}") from e


def delete_calendar_event(
    token: str, event_uid: str, live: bool = False
) -> dict[str, Any]:
    """Delete a calendar event. Fetches the latest etag automatically."""
    current = get_calendar_event(token, event_uid)
    etag = current.get("etag")
    if not etag:
        raise ConnectorError("No etag found on calendar event")

    if not live:
        return {"event_uid": event_uid, "dry_run": True, "deleted": False}

    cal_uid = calendar_uid(token)
    url = f"https://calendar.zoho.com/api/v1/calendars/{cal_uid}/events/{event_uid}"

    req = urllib.request.Request(url, method="DELETE")
    req.add_header("Authorization", f"Zoho-oauthtoken {token}")
    req.add_header("etag", etag)
    req.add_header("Content-Type", "application/x-www-form-urlencoded")

    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            body = resp.read().decode()
            result = json.loads(body) if body else {"status": "deleted"}
            ev = (result.get("events") or [{}])[0]
            return {"event_uid": ev.get("uid", event_uid), "deleted": True, "raw": result}
    except urllib.error.HTTPError as e:
        body = e.read().decode(errors="replace") if e.fp else ""
        raise ConnectorError(f"HTTP {e.code} deleting event: {body}") from e


def ensure_register() -> sqlite3.Connection:
    BOOKING_DIR.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(REGISTER_PATH, timeout=45)
    conn.execute("PRAGMA busy_timeout = 45000")
    conn.execute("PRAGMA journal_mode = WAL")
    conn.execute(
        """
        CREATE TABLE IF NOT EXISTS bookings (
            booking_reference TEXT PRIMARY KEY,
            facility TEXT NOT NULL,
            event_name TEXT NOT NULL,
            client_email TEXT NOT NULL,
            starts_at TEXT NOT NULL,
            ends_at TEXT NOT NULL,
            status TEXT NOT NULL,
            source TEXT NOT NULL,
            created_at TEXT NOT NULL
        )
        """
    )
    conn.execute(
        """
        CREATE TABLE IF NOT EXISTS schema_migrations (
            migration_id TEXT PRIMARY KEY,
            applied_at TEXT NOT NULL
        )
        """
    )
    return conn


def booking_window(booking: dict[str, Any]) -> tuple[str, str]:
    start = datetime.strptime(f"{booking['event_date']} {booking['start_time']}", "%Y-%m-%d %H:%M")
    if booking.get("end_time"):
        end = datetime.strptime(f"{booking['event_date']} {booking['end_time']}", "%Y-%m-%d %H:%M")
    else:
        end = start + timedelta(hours=float(booking["duration_hours"]))
    return start.isoformat(timespec="minutes"), end.isoformat(timespec="minutes")


def facility_id_for(booking_or_facility: dict[str, Any] | str) -> str:
    config = load_config()
    facility = booking_or_facility.get("facility") if isinstance(booking_or_facility, dict) else booking_or_facility
    info = (config.get("facilities") or {}).get(str(facility), {})
    return str(info.get("facility_id") or str(facility).lower().replace(" ", "_"))


def lagos_now() -> datetime:
    return datetime.now()


def cutoff_for_event(event_date: str) -> datetime:
    event_day = datetime.strptime(event_date, "%Y-%m-%d").date()
    return datetime.combine(event_day - timedelta(days=7), time(18, 0))


def apply_migrations(db_path: Path, prefix: str | None = None) -> dict[str, Any]:
    db_path.parent.mkdir(parents=True, exist_ok=True)
    applied: list[str] = []
    with sqlite3.connect(db_path, timeout=45) as conn:
        conn.execute("PRAGMA busy_timeout = 45000")
        conn.execute("CREATE TABLE IF NOT EXISTS schema_migrations (migration_id TEXT PRIMARY KEY, applied_at TEXT NOT NULL)")
        for path in sorted(MIGRATIONS_DIR.glob("*.up.sql")):
            migration_id = path.name.removesuffix(".up.sql")
            if prefix and not migration_id.startswith(prefix):
                continue
            row = conn.execute("SELECT 1 FROM schema_migrations WHERE migration_id = ?", (migration_id,)).fetchone()
            if row:
                continue
            conn.executescript(path.read_text(encoding="utf-8"))
            conn.execute(
                "INSERT OR REPLACE INTO schema_migrations (migration_id, applied_at) VALUES (?, ?)",
                (migration_id, lagos_now().isoformat(timespec="seconds")),
            )
            applied.append(migration_id)
        conn.commit()
    return {"database": str(db_path), "applied": applied}


def migrate() -> dict[str, Any]:
    return {
        "register": apply_migrations(REGISTER_PATH, prefix="001"),
        "state": apply_migrations(STATE_PATH, prefix="002"),
    }


def active_hold_conflicts(conn: sqlite3.Connection, booking: dict[str, Any]) -> list[dict[str, Any]]:
    start, end = booking_window(booking)
    start_time = start[11:16]
    end_time = end[11:16]
    rows = conn.execute(
        """
        SELECT hold_id, booking_id, facility_id, event_date, start_time, end_time, hold_status, expires_at
        FROM holds
        WHERE facility_id = ?
          AND event_date = ?
          AND hold_status IN ('Tentative', 'Invoice Sent', 'Payment Pending', 'Active')
          AND start_time < ?
          AND end_time > ?
        ORDER BY created_at
        """,
        (facility_id_for(booking), booking["event_date"], end_time, start_time),
    ).fetchall()
    return [
        {
            "hold_id": row[0],
            "booking_id": row[1],
            "facility_id": row[2],
            "event_date": row[3],
            "start_time": row[4],
            "end_time": row[5],
            "hold_status": row[6],
            "expires_at": row[7],
        }
        for row in rows
    ]


def availability(booking: dict[str, Any]) -> dict[str, Any]:
    start, end = booking_window(booking)
    with ensure_register() as conn:
        apply_migrations(REGISTER_PATH, prefix="001")
        rows = conn.execute(
            """
            SELECT booking_reference, facility, event_name, client_email, starts_at, ends_at, status
            FROM bookings
            WHERE facility = ?
              AND status NOT IN ('Cancelled')
              AND starts_at < ?
              AND ends_at > ?
            ORDER BY starts_at
            """,
            (booking["facility"], end, start),
        ).fetchall()
        hold_conflicts = active_hold_conflicts(conn, booking)
    conflicts = [
        {
            "booking_reference": row[0],
            "facility": row[1],
            "event_name": row[2],
            "client_email": row[3],
            "starts_at": row[4],
            "ends_at": row[5],
            "status": row[6],
        }
        for row in rows
    ]
    return {
        "available": not conflicts and not hold_conflicts,
        "conflicts": conflicts,
        "hold_conflicts": hold_conflicts,
        "checked_window": {"start": start, "end": end},
    }


def register_booking(booking: dict[str, Any], status: str, source: str) -> dict[str, Any]:
    start, end = booking_window(booking)
    reference = quote.booking_reference(booking)
    with ensure_register() as conn:
        apply_migrations(REGISTER_PATH, prefix="001")
        conn.execute(
            """
            INSERT OR REPLACE INTO bookings (
                booking_reference, facility, event_name, client_email, starts_at, ends_at,
                status, source, created_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                reference,
                booking["facility"],
                booking["event_name"],
                booking["email"],
                start,
                end,
                status,
                source,
                datetime.now().isoformat(timespec="seconds"),
            ),
        )
    return {"registered": True, "booking_reference": reference, "status": status, "register_path": str(REGISTER_PATH)}


def create_hold(booking: dict[str, Any], status: str = "Tentative") -> dict[str, Any]:
    reference = quote.booking_reference(booking)
    start, end = booking_window(booking)
    with ensure_register() as conn:
        apply_migrations(REGISTER_PATH, prefix="001")
        conflicts = active_hold_conflicts(conn, booking)
        existing_invoice_holder = [item for item in conflicts if item["hold_status"] == "Invoice Sent" and item["booking_id"] != reference]
        if existing_invoice_holder:
            return {
                "held": False,
                "blocked": True,
                "escalate_to": ["events@iih.ng", "clawdia"],
                "reason": "slot_already_won_by_invoice_sent_booking",
                "conflicts": existing_invoice_holder,
            }
        if any(item["booking_id"] != reference for item in conflicts):
            return {
                "held": False,
                "blocked": True,
                "escalate_to": ["events@iih.ng", "clawdia"],
                "reason": "active_hold_overlap",
                "conflicts": conflicts,
            }
        hold_id = f"HOLD-{uuid.uuid4().hex[:12].upper()}"
        conn.execute(
            """
            INSERT INTO holds (
                hold_id, booking_id, facility_id, event_date, start_time, end_time,
                hold_status, created_at, expires_at, released_reason
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NULL)
            """,
            (
                hold_id,
                reference,
                facility_id_for(booking),
                booking["event_date"],
                start[11:16],
                end[11:16],
                status,
                lagos_now().isoformat(timespec="seconds"),
                cutoff_for_event(booking["event_date"]).isoformat(timespec="seconds"),
            ),
        )
        conn.commit()
    return {"held": True, "hold_id": hold_id, "booking_reference": reference, "status": status}


def release_expired_holds(as_of: datetime | None = None) -> dict[str, Any]:
    as_of = as_of or lagos_now()
    with ensure_register() as conn:
        apply_migrations(REGISTER_PATH, prefix="001")
        rows = conn.execute(
            """
            SELECT hold_id, booking_id, expires_at FROM holds
            WHERE hold_status IN ('Tentative', 'Invoice Sent', 'Payment Pending', 'Active')
              AND expires_at <= ?
            ORDER BY expires_at
            """,
            (as_of.isoformat(timespec="seconds"),),
        ).fetchall()
        for hold_id, booking_id, _expires_at in rows:
            conn.execute(
                "UPDATE holds SET hold_status = 'Released', released_reason = ? WHERE hold_id = ?",
                ("payment_not_finance_confirmed_by_cutoff", hold_id),
            )
            conn.execute(
                """
                INSERT INTO booking_lifecycle (booking_id, action, status_from, status_to, detail_json, created_at)
                VALUES (?, 'hold_auto_released', NULL, 'Released', ?, ?)
                """,
                (
                    booking_id,
                    json.dumps({"notify": ["events@iih.ng"], "reason": "seven_day_payment_cutoff"}, sort_keys=True),
                    as_of.isoformat(timespec="seconds"),
                ),
            )
        conn.commit()
    return {"released": len(rows), "holds": [row[0] for row in rows], "notify_events": bool(rows)}


def holds_needing_payment_reminder(as_of: datetime | None = None) -> dict[str, Any]:
    as_of = as_of or lagos_now()
    target = as_of + timedelta(hours=48)
    with ensure_register() as conn:
        apply_migrations(REGISTER_PATH, prefix="001")
        rows = conn.execute(
            """
            SELECT hold_id, booking_id, expires_at FROM holds
            WHERE hold_status IN ('Tentative', 'Invoice Sent', 'Payment Pending', 'Active')
              AND expires_at > ?
              AND expires_at <= ?
            ORDER BY expires_at
            """,
            (as_of.isoformat(timespec="seconds"), target.isoformat(timespec="seconds")),
        ).fetchall()
    return {
        "reminder_due": len(rows),
        "holds": [{"hold_id": row[0], "booking_id": row[1], "expires_at": row[2]} for row in rows],
    }


def cancellation_terms(booking_reference: str) -> dict[str, Any]:
    return {
        "booking_reference": booking_reference,
        "status": "Cancelled With Fee",
        "cancellation_fee_percent": 30,
        "refund_percent": 70,
        "refund_timing": "two to three business days after confirmed cancellation",
    }


def reschedule_terms(booking_reference: str, event_date: str, request_date: str, reschedule_count: int) -> dict[str, Any]:
    event_day = datetime.strptime(event_date, "%Y-%m-%d").date()
    request_day = datetime.strptime(request_date, "%Y-%m-%d").date()
    days_before = (event_day - request_day).days
    if reschedule_count == 0 and days_before >= 3:
        return {"booking_reference": booking_reference, "status": "Reschedule Requested", "fee": 0, "availability_required": True}
    terms = cancellation_terms(booking_reference)
    terms["reason"] = "late_or_second_reschedule_treated_as_cancellation"
    return terms


def deposit_resolution(booking_reference: str, damage_amount: int = 0, extra_cleaning_amount: int = 0) -> dict[str, Any]:
    deposit = int(((load_config().get("fees") or {}).get("refundable_security_deposit") or {}).get("rate_ngn") or 100000)
    deductions = max(0, int(damage_amount)) + max(0, int(extra_cleaning_amount))
    status = "Deposit Refunded" if deductions == 0 else "Deposit Partially Withheld"
    if deductions >= deposit:
        status = "Deposit Held"
    return {
        "booking_reference": booking_reference,
        "route_to": ["events@iih.ng", "finance@iih.ng"],
        "refund_instruction_allowed": False,
        "assessment_required_before_refund": True,
        "deposit_ngn": deposit,
        "deductions_ngn": deductions,
        "status_after_assessment": status,
        "excess_damage_billable_ngn": max(0, deductions - deposit),
    }


def validate_booking_file(path: Path) -> dict[str, Any]:
    booking = quote.load_booking(path)
    errors = quote.validate_booking(booking)
    if errors:
        raise ConnectorError("; ".join(errors))
    return booking


def prepare(booking: dict[str, Any]) -> dict[str, Any]:
    bundle = quote.build_bundle(booking)
    bundle["availability"] = availability(booking)
    bundle["email_identity"] = {
        "from": EVENTBOOKINGS_EMAIL,
        "reply_to": EVENTBOOKINGS_EMAIL,
        "cc": EVENTS_CC,
        "md_address_excluded": True,
    }
    bundle["zoho_payloads"] = {
        "invoice_email": invoice_email_payload(booking),
        "calendar_hold": build_calendar_payload(booking),
        "crm_contact": create_or_update_crm_contact_payload_only(booking),
    }
    return bundle


def create_or_update_crm_contact_payload_only(booking: dict[str, Any]) -> dict[str, Any]:
    name_parts = str(booking["full_name"]).strip().split()
    return {
        "data": [
            {
                "First_Name": name_parts[0] if name_parts else booking["full_name"],
                "Last_Name": " ".join(name_parts[1:]) if len(name_parts) > 1 else "-",
                "Email": booking["email"],
                "Phone": booking["phone"],
                "Account_Name": booking.get("organization"),
                "Lead_Source": "IIH Space Booking Form",
            }
        ],
        "trigger": ["workflow"],
    }


def doctor() -> dict[str, Any]:
    gcalcli_path = shutil.which("gcalcli") or "/Users/clawdia/Library/Python/3.9/bin/gcalcli"
    return {
        "config": str(CONFIG_PATH),
        "register": str(REGISTER_PATH),
        "secret_status": secret_status(),
        "himalaya": {
            "installed": bool(shutil.which("himalaya")),
            "facilitybookings_account_configured": himalaya_account_exists("facilitybookings"),
        },
        "gcalcli": {
            "installed": Path(gcalcli_path).exists(),
            "path": gcalcli_path if Path(gcalcli_path).exists() else None,
            "booking_production_path": "Zoho Calendar API, not Google Calendar",
        },
        "email_identity": {
            "booking_from": EVENTBOOKINGS_EMAIL,
            "md_address_excluded": True,
        },
    }


def himalaya_account_exists(fragment: str) -> bool:
    try:
        result = subprocess.run(
            ["himalaya", "account", "list"],
            check=True,
            capture_output=True,
            text=True,
        )
        return fragment.lower() in result.stdout.lower()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False


def execute_steps(
    booking: dict[str, Any],
    steps: list[str],
    confirm_live: bool,
    confirm_email_send: bool,
    existing_invoice_id: str | None = None,
    payment_proof_ref: str = "",
    finance_confirmation_ref: str = "",
    availability_evidence: str = "",
) -> dict[str, Any]:
    if not confirm_live:
        raise ConnectorError("Live Zoho writes require --confirm-live.")
    token = get_zoho_token()
    result: dict[str, Any] = {"steps": {}}

    contact_id: str | None = None
    invoice_id: str | None = existing_invoice_id

    if "books-contact" in steps or "invoice" in steps:
        contact = find_or_create_books_contact(token, booking, live=True)
        result["steps"]["books-contact"] = contact
        contact_id = contact["contact_id"]

    if "crm-contact" in steps:
        result["steps"]["crm-contact"] = create_or_update_crm_contact(token, booking, live=True)

    if "invoice" in steps:
        if not contact_id:
            raise ConnectorError("Cannot create invoice without Books contact ID.")
        conflict_check = availability(booking)
        if not conflict_check["available"]:
            raise ConnectorError(
                "Cannot create invoice because the requested slot has a local register or hold conflict; escalate to Events and Clawdia."
            )
        hold = create_hold(booking, status="Invoice Sent")
        if hold.get("blocked"):
            raise ConnectorError(
                "Cannot create invoice because another booking has already won or is holding the slot; escalate to Events and Clawdia."
            )
        invoice = create_invoice(token, contact_id, booking, live=True)
        result["steps"]["invoice"] = invoice
        result["steps"]["local-hold"] = hold
        invoice_id = invoice["invoice_id"]

    if "invoice-email" in steps:
        if not confirm_email_send:
            raise ConnectorError("Invoice email send requires --confirm-email-send.")
        if not invoice_id:
            raise ConnectorError("Cannot send invoice email without invoice ID from invoice step or --invoice-id.")
        result["steps"]["invoice-email"] = send_invoice_email(token, invoice_id, booking, live=True)

    if "payment-reminder" in steps:
        if not confirm_email_send:
            raise ConnectorError("Payment reminder send requires --confirm-email-send.")
        if not invoice_id:
            raise ConnectorError("Cannot send payment reminder without invoice ID from invoice step or --invoice-id.")
        result["steps"]["payment-reminder"] = send_payment_reminder(token, invoice_id, booking, live=True)

    if "calendar-hold" in steps:
        if not confirm_email_send:
            raise ConnectorError("External calendar invite requires --confirm-email-send.")
        result["steps"]["calendar-hold"] = create_calendar_event(token, booking, live=True)

    if "calendar-confirmed" in steps:
        if not confirm_email_send:
            raise ConnectorError("Confirmed external calendar invite requires --confirm-email-send.")
        # Policy gates (rules 1, 3, 4): a booking must not be confirmed without an
        # invoice, client payment proof, finance@iih.ng confirmation and a fresh
        # availability check. These are asserted here as well as in the agent CLI
        # because this is a second, independent entry point to Confirmed state.
        missing = []
        if not payment_proof_ref:
            missing.append("no_payment_proof")
        if not finance_confirmation_ref:
            missing.append("no_finance_confirmation")
        if not availability_evidence:
            missing.append("no_availability_check")
        if missing:
            raise ConnectorError(
                "Refusing to create a confirmed calendar event: unmet gates -> "
                + ", ".join(missing)
                + ". Provide --payment-proof-ref, --finance-confirmation-ref and "
                "--availability-evidence, each captured from its authoritative source."
            )
        conflict_check = availability(booking)
        if not conflict_check["available"]:
            raise ConnectorError(
                "Refusing to confirm: the slot now conflicts with a local register entry or hold. Escalate to Events and Clawdia."
            )
        result["steps"]["calendar-confirmed"] = create_calendar_event(token, booking, live=True, status="confirmed")
        result["steps"]["booking-register"] = register_booking(booking, "Confirmed", "payment-proof")

    return result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)

    doctor_parser = sub.add_parser("doctor", help="Check connector readiness without exposing secrets.")
    doctor_parser.add_argument("--pretty", action="store_true")

    prepare_parser = sub.add_parser("prepare", help="Build dry-run booking operations bundle.")
    prepare_parser.add_argument("booking_json", type=Path)
    prepare_parser.add_argument("--pretty", action="store_true")

    availability_parser = sub.add_parser("availability", help="Check local booking register conflicts.")
    availability_parser.add_argument("booking_json", type=Path)
    availability_parser.add_argument("--pretty", action="store_true")

    register_parser = sub.add_parser("register", help="Add/update local booking register.")
    register_parser.add_argument("booking_json", type=Path)
    register_parser.add_argument("--status", default="Tentative")
    register_parser.add_argument("--source", default="manual")
    register_parser.add_argument("--approve-local-write", action="store_true")
    register_parser.add_argument("--pretty", action="store_true")

    hold_parser = sub.add_parser("hold", help="Create a local active hold after conflict detection.")
    hold_parser.add_argument("booking_json", type=Path)
    hold_parser.add_argument("--status", default="Tentative")
    hold_parser.add_argument("--approve-local-write", action="store_true")
    hold_parser.add_argument("--pretty", action="store_true")

    release_parser = sub.add_parser("release-expired-holds", help="Release unpaid holds past the seven-day cutoff.")
    release_parser.add_argument("--as-of", help="Override current local timestamp, ISO format.")
    release_parser.add_argument("--pretty", action="store_true")

    reminder_parser = sub.add_parser("payment-reminders-due", help="List holds needing the 48-hour cutoff payment reminder.")
    reminder_parser.add_argument("--as-of", help="Override current local timestamp, ISO format.")
    reminder_parser.add_argument("--pretty", action="store_true")

    cancel_parser = sub.add_parser("cancellation-terms", help="Calculate host cancellation terms.")
    cancel_parser.add_argument("--booking-reference", required=True)
    cancel_parser.add_argument("--pretty", action="store_true")

    reschedule_parser = sub.add_parser("reschedule-terms", help="Calculate reschedule terms.")
    reschedule_parser.add_argument("--booking-reference", required=True)
    reschedule_parser.add_argument("--event-date", required=True)
    reschedule_parser.add_argument("--request-date", required=True)
    reschedule_parser.add_argument("--reschedule-count", type=int, default=0)
    reschedule_parser.add_argument("--pretty", action="store_true")

    deposit_parser = sub.add_parser("deposit-resolution", help="Route post-event deposit assessment.")
    deposit_parser.add_argument("--booking-reference", required=True)
    deposit_parser.add_argument("--damage-amount", type=int, default=0)
    deposit_parser.add_argument("--extra-cleaning-amount", type=int, default=0)
    deposit_parser.add_argument("--pretty", action="store_true")

    migrate_parser = sub.add_parser("migrate", help="Apply additive booking database migrations.")
    migrate_parser.add_argument("--pretty", action="store_true")

    execute_parser = sub.add_parser("execute", help="Run approved live Zoho operations.")
    execute_parser.add_argument("booking_json", type=Path)
    execute_parser.add_argument(
        "--step",
        action="append",
        choices=[
            "books-contact",
            "crm-contact",
            "invoice",
            "invoice-email",
            "payment-reminder",
            "calendar-hold",
            "calendar-confirmed",
        ],
        required=True,
    )
    execute_parser.add_argument("--invoice-id", help="Existing Zoho Books invoice ID for invoice email/reminder steps.")
    execute_parser.add_argument(
        "--payment-proof-ref",
        default="",
        help="Client payment proof reference, captured from the authoritative source (required for calendar-confirmed).",
    )
    execute_parser.add_argument(
        "--finance-confirmation-ref",
        default="",
        help="finance@iih.ng confirmation reference (required for calendar-confirmed).",
    )
    execute_parser.add_argument(
        "--availability-evidence",
        default="",
        help="Evidence that the events calendar was checked (required for calendar-confirmed).",
    )
    execute_parser.add_argument("--confirm-live", action="store_true")
    execute_parser.add_argument("--confirm-email-send", action="store_true")
    execute_parser.add_argument("--pretty", action="store_true")

    args = parser.parse_args()

    try:
        if args.command == "doctor":
            output = doctor()
        elif args.command == "migrate":
            output = migrate()
        elif args.command == "release-expired-holds":
            output = release_expired_holds(datetime.fromisoformat(args.as_of) if args.as_of else None)
        elif args.command == "payment-reminders-due":
            output = holds_needing_payment_reminder(datetime.fromisoformat(args.as_of) if args.as_of else None)
        elif args.command == "cancellation-terms":
            output = cancellation_terms(args.booking_reference)
        elif args.command == "reschedule-terms":
            output = reschedule_terms(args.booking_reference, args.event_date, args.request_date, args.reschedule_count)
        elif args.command == "deposit-resolution":
            output = deposit_resolution(args.booking_reference, args.damage_amount, args.extra_cleaning_amount)
        else:
            booking = validate_booking_file(args.booking_json)
            if args.command == "prepare":
                output = prepare(booking)
            elif args.command == "availability":
                output = availability(booking)
            elif args.command == "register":
                if not args.approve_local_write:
                    raise ConnectorError("Local register write requires --approve-local-write.")
                output = register_booking(booking, args.status, args.source)
            elif args.command == "hold":
                if not args.approve_local_write:
                    raise ConnectorError("Local hold write requires --approve-local-write.")
                output = create_hold(booking, args.status)
            elif args.command == "execute":
                output = execute_steps(
                    booking,
                    args.step,
                    args.confirm_live,
                    args.confirm_email_send,
                    existing_invoice_id=args.invoice_id,
                    payment_proof_ref=args.payment_proof_ref,
                    finance_confirmation_ref=args.finance_confirmation_ref,
                    availability_evidence=args.availability_evidence,
                )
            else:
                raise ConnectorError(f"Unknown command: {args.command}")
        print(json.dumps(output, indent=2 if getattr(args, "pretty", False) else None))
        return 0
    except ConnectorError as exc:
        print(json.dumps({"ok": False, "error": str(exc)}, indent=2))
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
