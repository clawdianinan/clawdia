#!/usr/bin/env python3
"""Validate IIH booking intake and generate a dry-run operations bundle."""

from __future__ import annotations

import argparse
import json
import re
from datetime import date, datetime, timedelta
from pathlib import Path
from typing import Any


REQUIRED_FIELDS = [
    "full_name",
    "email",
    "phone",
    "organization",
    "facility",
    "event_name",
    "event_type",
    "event_date",
    "start_time",
    "duration_hours",
    "expected_attendance",
    "external_catering",
]

FACILITIES = {
    "Main Hall": {
        "billing_mode": "day",
        "rate_ngn": 750000,
        "item_id": "6104627000000136098",
    },
    "Pitch Hall": {
        "billing_mode": "day",
        "rate_ngn": 400000,
        "item_id": "6104627000000136021",
    },
    "Meeting Room": {
        "billing_mode": "hour",
        "rate_ngn": 20000,
        "item_id": "6104627000000250451",
    },
    "Private Office": {
        "billing_mode": "hour",
        "rate_ngn": 20000,
        "item_id": "6104627000000151001",
    },
}

SECURITY_DEPOSIT = {
    "name": "Refundable Security Deposit",
    "rate_ngn": 100000,
    "item_id": "6104627000000150065",
}

EXTERNAL_CATERING = {
    "name": "External Catering Corkage Fee",
    "rate_ngn": 100000,
}


class BookingError(ValueError):
    pass


def load_booking(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        data = json.load(handle)
    if not isinstance(data, dict):
        raise BookingError("Booking input must be a JSON object.")
    return data


def validate_booking(booking: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    missing = [field for field in REQUIRED_FIELDS if field not in booking or booking[field] in ("", None)]
    if missing:
        errors.append(f"Missing required fields: {', '.join(missing)}")

    facility = booking.get("facility")
    if facility and facility not in FACILITIES:
        errors.append(f"Unsupported facility: {facility}")

    email = str(booking.get("email", ""))
    if email and not re.match(r"^[^@\s]+@[^@\s]+\.[^@\s]+$", email):
        errors.append("Email is not valid.")

    event_date = str(booking.get("event_date", ""))
    if event_date:
        try:
            datetime.strptime(event_date, "%Y-%m-%d")
        except ValueError:
            errors.append("event_date must use YYYY-MM-DD.")

    start_time = str(booking.get("start_time", ""))
    if start_time:
        try:
            datetime.strptime(start_time, "%H:%M")
        except ValueError:
            errors.append("start_time must use HH:MM in 24-hour time.")

    try:
        duration = float(booking.get("duration_hours", 0))
        if duration <= 0:
            errors.append("duration_hours must be greater than zero.")
    except (TypeError, ValueError):
        errors.append("duration_hours must be numeric.")

    try:
        attendance = int(booking.get("expected_attendance", 0))
        if attendance <= 0:
            errors.append("expected_attendance must be greater than zero.")
    except (TypeError, ValueError):
        errors.append("expected_attendance must be numeric.")

    if "external_catering" in booking and not isinstance(booking.get("external_catering"), bool):
        errors.append("external_catering must be true or false.")

    return errors


def booking_reference(booking: dict[str, Any]) -> str:
    raw_name = re.sub(r"[^A-Za-z0-9]+", "", str(booking["organization"] or booking["full_name"]))
    client = (raw_name[:8] or "CLIENT").upper()
    return f"IIH-BOOK-{booking['event_date'].replace('-', '')}-{client}"


def build_quote(booking: dict[str, Any]) -> dict[str, Any]:
    facility = FACILITIES[booking["facility"]]
    quantity = float(booking["duration_hours"]) if facility["billing_mode"] == "hour" else 1.0
    if isinstance(quantity, float) and quantity.is_integer():
        quantity = int(quantity)

    line_items: list[dict[str, Any]] = [
        {
            "name": booking["facility"],
            "item_id": facility["item_id"],
            "description": f"{booking['event_name']} | {booking['event_date']} {booking['start_time']}",
            "quantity": quantity,
            "rate": facility["rate_ngn"],
            "amount": quantity * facility["rate_ngn"],
        },
        {
            "name": SECURITY_DEPOSIT["name"],
            "item_id": SECURITY_DEPOSIT["item_id"],
            "quantity": 1,
            "rate": SECURITY_DEPOSIT["rate_ngn"],
            "amount": SECURITY_DEPOSIT["rate_ngn"],
        },
    ]

    if booking.get("external_catering"):
        line_items.append(
            {
                "name": EXTERNAL_CATERING["name"],
                "description": "IIH Policy: NGN 100,000/day for external catering",
                "quantity": 1,
                "rate": EXTERNAL_CATERING["rate_ngn"],
                "amount": EXTERNAL_CATERING["rate_ngn"],
            }
        )

    return {
        "currency": "NGN",
        "line_items": line_items,
        "total": sum(item["amount"] for item in line_items),
    }


def build_bundle(booking: dict[str, Any]) -> dict[str, Any]:
    invoice_date = date.today()
    due_date = invoice_date + timedelta(days=7)
    quote = build_quote(booking)
    reference = booking_reference(booking)

    return {
        "status": "Tentative",
        "booking_reference": reference,
        "quote": quote,
        "invoice": {
            "date": invoice_date.isoformat(),
            "due_date": due_date.isoformat(),
            "notes": (
                f"Event: {booking['event_name']}\n"
                f"Facility: {booking['facility']}\n"
                f"Date: {booking['event_date']} at {booking['start_time']}\n"
                f"Attendees: {booking['expected_attendance']}"
            ),
            "terms": (
                "Payment is required to confirm your booking. Cancellations must be made "
                "48 hours in advance for a refund review of the security deposit."
            ),
        },
        "crm": {
            "lead_source": "IIH Space Booking Form",
            "contact_email": booking["email"],
            "organization": booking.get("organization"),
        },
        "calendar_hold": {
            "title": f"[TENTATIVE] {booking['facility']} - {booking['event_name']}",
            "timezone": "Africa/Lagos",
            "date": booking["event_date"],
            "start_time": booking["start_time"],
            "duration_hours": booking["duration_hours"],
            "attendees": ["events@iih.ng", booking["email"]],
        },
        "approval_required": [
            "availability/conflict check",
            "Zoho Books contact write",
            "Zoho CRM contact write",
            "invoice creation",
            "invoice email send",
            "external calendar invite",
        ],
        "next_actions": [
            "Confirm facility availability for the requested slot.",
            "Approve or reject the prepared Zoho operations bundle.",
            "Send invoice only after explicit approval.",
            "Confirm payment before marking booking as Confirmed.",
        ],
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("booking_json", type=Path, help="Path to booking JSON intake.")
    parser.add_argument("--pretty", action="store_true", help="Pretty-print JSON output.")
    args = parser.parse_args()

    try:
        booking = load_booking(args.booking_json)
        errors = validate_booking(booking)
        if errors:
            print(json.dumps({"status": "Draft", "errors": errors}, indent=2))
            return 2
        bundle = build_bundle(booking)
        print(json.dumps(bundle, indent=2 if args.pretty else None))
        return 0
    except BookingError as exc:
        print(json.dumps({"status": "Draft", "errors": [str(exc)]}, indent=2))
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
