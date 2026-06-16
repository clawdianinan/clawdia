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
from datetime import datetime, timedelta
from pathlib import Path
from typing import Any

SCRIPT_DIR = Path(__file__).resolve().parent
WORKSPACE_DIR = SCRIPT_DIR.parent
BOOKING_DIR = WORKSPACE_DIR / "documents" / "IIH" / "Bookings"
CONFIG_PATH = WORKSPACE_DIR / "config" / "iih_booking_system.json"
REGISTER_PATH = BOOKING_DIR / "booking_register.sqlite3"

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
    return {
        "customer_id": contact_id,
        "date": bundle["invoice"]["date"],
        "due_date": bundle["invoice"]["due_date"],
        "line_items": [
            {
                key: value
                for key, value in item.items()
                if key in {"item_id", "name", "description", "quantity", "rate"}
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
    return {
        "to_mail_ids": [booking["email"]],
        "cc_mail_ids": [EVENTS_CC],
        "subject": f"{subject_prefix} for {booking['facility']} Booking - {booking['event_name']} | IIH Space",
        "body": (
            f"Dear {booking['full_name']},\n\n"
            f"{opening}"
            f"{action_line}"
            f"The invoice covers the {booking['facility']} on {booking['event_date']}.\n\n"
            "Kindly make payment within 7 days to confirm your booking. "
            "Your calendar slot will be confirmed after payment proof is received and matched to the invoice amount.\n\n"
            f"For questions, contact {EVENTBOOKINGS_EMAIL}.\n\n"
            "Warm regards,\n"
            "IIH Bookings"
        ),
    }


def send_invoice_email(token: str, invoice_id: str, booking: dict[str, Any], live: bool) -> dict[str, Any]:
    payload = invoice_email_payload(booking)
    if not live:
        return {"sent": False, "dry_run_payload": payload}
    assert_booking_identity()
    sent = request_json(
        "POST",
        books_url(f"invoices/{invoice_id}/email"),
        token=token,
        payload=payload,
    )
    return {"sent": True, "raw": sent}


def send_payment_reminder(token: str, invoice_id: str, booking: dict[str, Any], live: bool) -> dict[str, Any]:
    payload = invoice_email_payload(booking, reminder=True)
    if not live:
        return {"sent": False, "dry_run_payload": payload}
    assert_booking_identity()
    sent = request_json(
        "POST",
        books_url(f"invoices/{invoice_id}/email"),
        token=token,
        payload=payload,
    )
    return {"sent": True, "raw": sent}


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
            {"email": EVENTS_CC, "name": "IIH Events"},
            {"email": booking["email"], "name": booking["full_name"]},
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
        payload=payload,
    )
    event_uid = (created.get("events") or [{}])[0].get("uid")
    return {"event_uid": event_uid, "raw": created}


def ensure_register() -> sqlite3.Connection:
    BOOKING_DIR.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(REGISTER_PATH)
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
    return conn


def booking_window(booking: dict[str, Any]) -> tuple[str, str]:
    start = datetime.strptime(f"{booking['event_date']} {booking['start_time']}", "%Y-%m-%d %H:%M")
    end = start + timedelta(hours=float(booking["duration_hours"]))
    return start.isoformat(timespec="minutes"), end.isoformat(timespec="minutes")


def availability(booking: dict[str, Any]) -> dict[str, Any]:
    start, end = booking_window(booking)
    with ensure_register() as conn:
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
    return {"available": not conflicts, "conflicts": conflicts, "checked_window": {"start": start, "end": end}}


def register_booking(booking: dict[str, Any], status: str, source: str) -> dict[str, Any]:
    start, end = booking_window(booking)
    reference = quote.booking_reference(booking)
    with ensure_register() as conn:
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
        invoice = create_invoice(token, contact_id, booking, live=True)
        result["steps"]["invoice"] = invoice
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
    execute_parser.add_argument("--confirm-live", action="store_true")
    execute_parser.add_argument("--confirm-email-send", action="store_true")
    execute_parser.add_argument("--pretty", action="store_true")

    args = parser.parse_args()

    try:
        if args.command == "doctor":
            output = doctor()
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
            elif args.command == "execute":
                output = execute_steps(
                    booking,
                    args.step,
                    args.confirm_live,
                    args.confirm_email_send,
                    existing_invoice_id=args.invoice_id,
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
