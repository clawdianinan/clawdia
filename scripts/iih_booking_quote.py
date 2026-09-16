#!/usr/bin/env python3
"""Validate IIH booking intake and generate a dry-run operations bundle."""

from __future__ import annotations

import argparse
import json
import re
from datetime import date, datetime, timedelta
from pathlib import Path
from typing import Any


WORKSPACE_DIR = Path(__file__).resolve().parent.parent
CONFIG_PATH = WORKSPACE_DIR / "config" / "iih_booking_system.json"

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
    "end_time",
    "expected_attendance",
    "av_needs",
    "setup_needs",
    "refreshment_selection",
    "sensitive_content_flag",
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
        "billing_mode": "day",
        "rate_ngn": 25000,
        "item_id": "6104627000000151001",
        "available": False,
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

STANDARD_PAYMENT_NOTES = (
    "Account Name: Ilorin Tech Park Ltd (formerly Ilorin Innovation Hub Ltd) \n"
    "Account Number: 1310169029\n"
    "Bank Name: Zenith Bank"
)


class BookingError(ValueError):
    pass


def load_config() -> dict[str, Any]:
    with CONFIG_PATH.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def facility_config(config: dict[str, Any], facility: str) -> dict[str, Any]:
    facilities = config.get("facilities") or {}
    if facility in facilities:
        item = dict(facilities[facility])
        item.setdefault("item_id", item.get("zoho_books_item_id"))
        return item
    if facility in FACILITIES:
        return dict(FACILITIES[facility])
    return {}


def fee_config(config: dict[str, Any], key: str, fallback: dict[str, Any]) -> dict[str, Any]:
    fee = dict((config.get("fees") or {}).get(key) or fallback)
    if "zoho_books_item_id" in fee:
        fee.setdefault("item_id", fee["zoho_books_item_id"])
    return fee


def load_booking(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as handle:
        data = json.load(handle)
    if not isinstance(data, dict):
        raise BookingError("Booking input must be a JSON object.")
    return data


def parse_local_dt(event_date: str, time_text: str) -> datetime:
    return datetime.strptime(f"{event_date} {time_text}", "%Y-%m-%d %H:%M")


def booking_times(booking: dict[str, Any]) -> tuple[datetime | None, datetime | None, list[str]]:
    errors: list[str] = []
    event_date = str(booking.get("event_date", ""))
    start_time = str(booking.get("start_time", ""))
    end_time = str(booking.get("end_time", ""))
    start: datetime | None = None
    end: datetime | None = None
    if event_date and start_time:
        try:
            start = parse_local_dt(event_date, start_time)
        except ValueError:
            errors.append("start_time must use HH:MM in 24-hour time.")
    if event_date and end_time:
        try:
            end = parse_local_dt(event_date, end_time)
        except ValueError:
            errors.append("end_time must use HH:MM in 24-hour time.")
    elif start and booking.get("duration_hours") not in ("", None):
        try:
            end = start + timedelta(hours=float(booking["duration_hours"]))
        except (TypeError, ValueError):
            errors.append("duration_hours must be numeric when end_time is absent.")
    return start, end, errors


def duration_hours(booking: dict[str, Any]) -> float:
    start, end, errors = booking_times(booking)
    if errors or not start or not end:
        return float(booking.get("duration_hours") or 0)
    return (end - start).total_seconds() / 3600


def intake_flags(booking: dict[str, Any], config: dict[str, Any] | None = None) -> list[dict[str, str]]:
    config = config or load_config()
    policy = config.get("event_policy") or {}
    flags: list[dict[str, str]] = []
    required = policy.get("required_booking_fields") or REQUIRED_FIELDS
    for field in required:
        if booking.get(field) in ("", None):
            flags.append({"code": "missing_required_field", "field": str(field), "severity": "block"})

    event_date = str(booking.get("event_date", ""))
    start, end, time_errors = booking_times(booking)
    for error in time_errors:
        flags.append({"code": "invalid_time", "message": error, "severity": "block"})

    if event_date:
        try:
            day = datetime.strptime(event_date, "%Y-%m-%d").strftime("%A")
            if day in set(policy.get("blackout_days") or ["Sunday"]):
                flags.append({"code": "blackout_day", "message": "Sunday bookings are not permitted.", "severity": "block"})
        except ValueError:
            flags.append({"code": "invalid_event_date", "message": "event_date must use YYYY-MM-DD.", "severity": "block"})

    if start and end:
        if end <= start:
            flags.append({"code": "end_before_start", "message": "end_time must be after start_time.", "severity": "block"})
        opening = parse_local_dt(event_date, str(policy.get("operating_start") or "09:00"))
        closing = parse_local_dt(event_date, str(policy.get("operating_end") or "18:00"))
        grace = timedelta(minutes=int(policy.get("grace_minutes") or 0))
        setup_minutes = int(booking.get("setup_minutes") or 0)
        setup_start = start - timedelta(minutes=setup_minutes)
        if setup_start < opening or start < opening or end + grace > closing:
            flags.append(
                {
                    "code": "outside_operating_window",
                    "message": "All setup, event activity, and grace time must fit within 09:00 to 18:00.",
                    "severity": "block",
                }
            )

    facility_name = str(booking.get("facility") or "")
    facility = facility_config(config, facility_name)
    if facility_name and not facility:
        flags.append({"code": "unsupported_facility", "message": f"Unsupported facility: {facility_name}", "severity": "block"})
    elif facility.get("available") is False:
        flags.append({"code": "facility_unavailable", "message": f"{facility_name} is currently unavailable.", "severity": "block"})
    else:
        capacity = facility.get("capacity")
        attendance_value = booking.get("expected_attendance")
        if attendance_value not in ("", None):
            try:
                attendance = int(attendance_value)
                if capacity is None:
                    flags.append({"code": "capacity_unset", "message": f"Capacity is unset for {facility_name}.", "severity": "escalate"})
                elif attendance > int(capacity):
                    flags.append({"code": "attendance_exceeds_capacity", "message": "Expected attendance exceeds facility capacity.", "severity": "block"})
            except (TypeError, ValueError):
                flags.append({"code": "invalid_attendance", "message": "expected_attendance must be numeric.", "severity": "block"})

    for threshold_key, code in (("usher_threshold", "usher_threshold_unset"), ("insurance_threshold", "insurance_threshold_unset")):
        if policy.get(threshold_key) is None and booking.get("expected_attendance") not in ("", None):
            flags.append({"code": code, "message": f"{threshold_key} must be set by the MD before automated validation.", "severity": "escalate"})

    return flags


def validate_booking(booking: dict[str, Any]) -> list[str]:
    config = load_config()
    errors: list[str] = []
    missing = [field for field in REQUIRED_FIELDS if field not in booking or booking[field] in ("", None)]
    if missing:
        errors.append(f"Missing required fields: {', '.join(missing)}")

    facility = booking.get("facility")
    facility_info = facility_config(config, str(facility)) if facility else {}
    if facility and not facility_info:
        errors.append(f"Unsupported facility: {facility}")
    elif facility and facility_info.get("available") is False:
        errors.append(f"{facility} is currently unavailable.")

    email = str(booking.get("email", ""))
    if email and not re.match(r"^[^@\s]+@[^@\s]+\.[^@\s]+$", email):
        errors.append("Email is not valid.")

    event_date = str(booking.get("event_date", ""))
    if event_date:
        try:
            datetime.strptime(event_date, "%Y-%m-%d")
        except ValueError:
            errors.append("event_date must use YYYY-MM-DD.")

    start, end, time_errors = booking_times(booking)
    errors.extend(time_errors)
    if start and end and end <= start:
        errors.append("end_time must be after start_time.")
    if not end and booking.get("duration_hours") in ("", None):
        errors.append("end_time is required unless duration_hours is provided.")

    try:
        attendance = int(booking.get("expected_attendance", 0))
        if attendance <= 0:
            errors.append("expected_attendance must be greater than zero.")
    except (TypeError, ValueError):
        errors.append("expected_attendance must be numeric.")

    catering_mode = booking.get("catering_mode")
    if catering_mode not in (None, "hub", "external", "none"):
        errors.append("catering_mode must be hub, external, or none.")
    if "external_catering" in booking and not isinstance(booking.get("external_catering"), bool):
        errors.append("external_catering must be true or false.")

    if "discount_percentage" in booking:
        try:
            dp = float(booking["discount_percentage"])
            if dp < 0 or dp > 100:
                errors.append("discount_percentage must be between 0 and 100.")
        except (TypeError, ValueError):
            errors.append("discount_percentage must be numeric.")

    if "discount_amount" in booking:
        try:
            da = float(booking["discount_amount"])
            if da < 0:
                errors.append("discount_amount must be zero or positive.")
        except (TypeError, ValueError):
            errors.append("discount_amount must be numeric.")

    return errors


def booking_reference(booking: dict[str, Any]) -> str:
    raw_name = re.sub(r"[^A-Za-z0-9]+", "", str(booking["organization"] or booking["full_name"]))
    client = (raw_name[:8] or "CLIENT").upper()
    return f"IIH-BOOK-{booking['event_date'].replace('-', '')}-{client}"


def tax_fields(config: dict[str, Any], tax_category: str) -> dict[str, Any]:
    vat = (config.get("fees") or {}).get("vat") or {}
    if tax_category in set(vat.get("exclude") or []):
        return {"tax_category": tax_category, "taxable": False}
    if tax_category not in set(vat.get("apply_to") or []):
        return {"tax_category": tax_category, "taxable": False}
    fields: dict[str, Any] = {
        "tax_category": tax_category,
        "taxable": True,
        "tax_percentage": float(vat.get("rate_percent") or (float(vat.get("rate") or 0) * 100)),
    }
    if vat.get("zoho_books_tax_id"):
        fields["tax_id"] = vat["zoho_books_tax_id"]
    return fields


def build_quote(booking: dict[str, Any]) -> dict[str, Any]:
    config = load_config()
    facility = facility_config(config, booking["facility"])
    # Quantity depends on the facility's billing mode:
    #   hour -> billed per hour of the booking window
    #   day  -> billed per event day (was hard-coded to 1, which undercharged
    #           every multi-day booking)
    event_days = max(1, int(booking.get("event_days") or 1))
    if facility["billing_mode"] == "hour":
        quantity: float | int = duration_hours(booking)
    else:
        quantity = event_days
    if isinstance(quantity, float) and quantity.is_integer():
        quantity = int(quantity)
    security_deposit = fee_config(config, "refundable_security_deposit", SECURITY_DEPOSIT)
    # Per Temi (2026-09-15): the refundable security deposit is per booked space per day,
    # not flat. A 2-day Main Hall booking therefore carries NGN 200,000, not 100,000.
    # This matches the website backend (DEPOSIT_BASIS = per_space_day). The config key
    # `billing_basis` states the basis explicitly; default to per_space_per_day so an
    # older config cannot silently under-quote a multi-day booking.
    deposit_basis = security_deposit.get("billing_basis") or "per_space_per_day"
    if deposit_basis == "per_space_per_day":
        deposit_quantity = event_days * max(1, len(booking.get("spaces") or [booking.get("facility")]))
    else:
        deposit_quantity = 1
    corkage = fee_config(config, "external_catering_corkage", EXTERNAL_CATERING)
    catering_mode = booking.get("catering_mode") or ("external" if booking.get("external_catering") else "hub")

    line_items: list[dict[str, Any]] = [
        {
            "name": booking["facility"],
            "item_id": facility.get("item_id") or facility.get("zoho_books_item_id"),
            "description": (
                f"{booking['event_name']} | {booking['event_date']} {booking['start_time']}"
                + (f" | {event_days} days" if facility["billing_mode"] != "hour" and event_days > 1 else "")
            ),
            "quantity": quantity,
            "rate": facility["rate_ngn"],
            "amount": quantity * facility["rate_ngn"],
            **tax_fields(config, "facility_rental"),
        },
        {
            "name": security_deposit.get("name") or "Refundable Security Deposit",
            "item_id": security_deposit.get("item_id") or security_deposit.get("zoho_books_item_id"),
            "description": (
                "Refundable security deposit (NGN 100,000 per space per day)"
                if deposit_basis == "per_space_per_day" and deposit_quantity > 1
                else None
            ),
            "quantity": deposit_quantity,
            "rate": security_deposit["rate_ngn"],
            "amount": deposit_quantity * security_deposit["rate_ngn"],
            **tax_fields(config, "refundable_security_deposit"),
        },
    ]

    if catering_mode == "external":
        line_items.append(
            {
                "name": corkage.get("name") or EXTERNAL_CATERING["name"],
                "description": "IIH Policy: NGN 100,000/day for external catering",
                "quantity": event_days,
                "rate": corkage["rate_ngn"],
                "amount": event_days * corkage["rate_ngn"],
                **tax_fields(config, "external_catering_corkage"),
            }
        )

    # Apply discount if specified — discount applies only to facility/fee items, not to
    # refundable security deposits.
    discount_percentage = booking.get("discount_percentage", 0)
    discount_amount = booking.get("discount_amount", 0)
    if discount_percentage and not discount_amount:
        # Calculate discount on non-deposit, non-fee items only
        chargeable_total = sum(
            item["amount"]
            for item in line_items
            if item["name"] not in {"Refundable Security Deposit"}
        )
        discount_amount = round(chargeable_total * discount_percentage / 100)
    if discount_amount > 0:
        desc = f"{discount_percentage}% discount" if discount_percentage else "Special discount"
        line_items.append(
            {
                "name": "Discount",
                "description": desc,
                "quantity": 1,
                "rate": -discount_amount,
                "amount": -discount_amount,
            }
        )

    return {
        "currency": "NGN",
        "line_items": line_items,
        "total": sum(item["amount"] for item in line_items),
        "vat_rate_percent": ((config.get("fees") or {}).get("vat") or {}).get("rate_percent"),
        "catering_mode": catering_mode,
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
            "notes": STANDARD_PAYMENT_NOTES,
            "terms": "",
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
            "duration_hours": duration_hours(booking),
            "attendees": ["events@iih.ng", booking["email"]],
        },
        "intake_flags": intake_flags(booking),
        "pre_event_obligations": {
            "agenda_due_date": (datetime.strptime(booking["event_date"], "%Y-%m-%d").date() - timedelta(days=3)).isoformat(),
            "attendee_list_due_before_event": True,
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
