#!/usr/bin/env python3
"""IIH booking — FINAL EVENT NOTIFICATION (internal only).

Per Temi, 22 Sep 2026: once finance confirms a booking, complete it concretely
and send a FINAL EVENT NOTIFICATION to the internal team. This is NOT a client
email. It goes to events@iih.ng and everyone@iih.ng only.

Sending rules that still apply:
  - Internal recipients only. Never the client, never md@iih.ng.
  - Approved HTML/logo signature (it is an IIH operational communication).
  - This fires once per booking. Tracked by a marker file so a re-run does not
    double-send.

Usage:
  python3 send_final_event_notification.py --booking-json <file> [--send]
"""
from __future__ import annotations

import argparse
import datetime as dt
import json
import smtplib
import ssl
import subprocess
import sys
from email.message import EmailMessage
from email.utils import formataddr, make_msgid
from pathlib import Path

SMTP_HOST = "smtp.zoho.com"
SMTP_PORT = 587
SMTP_USER = "facilitybookings@iih.ng"
KEYCHAIN_SERVICE = "iih-booking-ZOHO_APP_PASSWORD"
KEYCHAIN_ACCOUNT = "iih-booking"

SIGNATURE = Path(
    "/Users/clawdia/.openclaw/workspace/documents/IIH/Bookings/aisha_signature.html"
)
LOGO = Path("/Users/clawdia/.openclaw/workspace/documents/IIH/Bookings/iih_logo.png")
SENT_MARKER_DIR = Path("/Users/clawdia/.openclaw/workspace/documents/IIH/Bookings/.notifications")

INTERNAL_TO = "events@iih.ng"
INTERNAL_CC = "everyone@iih.ng"


def smtp_password() -> str:
    return subprocess.check_output(
        ["security", "find-generic-password", "-s", KEYCHAIN_SERVICE, "-a", KEYCHAIN_ACCOUNT, "-w"],
        text=True,
    ).strip()


def weekday(date_str: str) -> str:
    """Day of week for an ISO date. Never trusted from memory (Temi, 31 Aug 2026)."""
    d = dt.date.fromisoformat(date_str)
    return d.strftime("%A %d %B %Y")


def build(booking: dict) -> EmailMessage:
    ref = booking["reference"]
    client = booking.get("client", {})
    event = booking.get("event", {})
    sched = booking.get("schedule", {})
    fin = booking.get("finance", {})

    when = weekday(sched["eventDay"])
    msg = EmailMessage()
    msg["From"] = formataddr(("IIH Facility Bookings", SMTP_USER))
    msg["To"] = INTERNAL_TO
    msg["Cc"] = INTERNAL_CC
    msg["Subject"] = f"[CONFIRMED] {event.get('name')} — {when} — {booking.get('spaceNames', [''])[0]} ({ref})"
    msg["Message-ID"] = make_msgid(domain="iih.ng")

    body = f"""<div style="font-family: Arial, sans-serif; font-size: 14px; color: #333; line-height: 1.6;">
<p><strong>Booking confirmed.</strong> Payment has been received and confirmed by Finance. Please make arrangements accordingly.</p>

<table cellpadding="6" cellspacing="0" border="0" style="font-size: 13px; border-collapse: collapse;">
<tr><td><strong>Reference</strong></td><td>{ref}</td></tr>
<tr><td><strong>Event</strong></td><td>{event.get('name')}</td></tr>
<tr><td><strong>Client</strong></td><td>{client.get('organization')} — {client.get('name')}</td></tr>
<tr><td><strong>Date</strong></td><td>{when}</td></tr>
<tr><td><strong>Time</strong></td><td>{sched.get('dailyStartTime')} – {sched.get('dailyEndTime')} (Africa/Lagos)</td></tr>
<tr><td><strong>Space</strong></td><td>{', '.join(booking.get('spaceNames', []))}</td></tr>
<tr><td><strong>Expected attendance</strong></td><td>{event.get('expectedAttendance')}</td></tr>
<tr><td><strong>Seating</strong></td><td>{booking.get('setup', {}).get('seatingArrangement') or 'Not specified'}</td></tr>
<tr><td><strong>Catering</strong></td><td>{booking.get('setup', {}).get('cateringRequired') or 'No'}</td></tr>
<tr><td><strong>Invoice</strong></td><td>{fin.get('invoiceNumber')} — NGN {fin.get('quoteAmount'):,.2f}</td></tr>
</table>

<p style="margin-top:14px;"><strong>Internal note.</strong> The client has been told the booking is confirmed and that proof of payment completes it. Client contact details are held in the booking record, not on the internal calendar.</p>
</div>
{SIGNATURE.read_text()}"""

    msg.set_content("Please view this email in an HTML-capable client.")
    msg.add_alternative(body, subtype="html")
    html_part = msg.get_payload()[1]
    html_part.add_related(LOGO.read_bytes(), maintype="image", subtype="png", cid="<iih_logo>")
    return msg


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("booking_json")
    ap.add_argument("--send", action="store_true")
    args = ap.parse_args()

    booking = json.loads(Path(args.booking_json).read_text())
    ref = booking["reference"]

    SENT_MARKER_DIR.mkdir(parents=True, exist_ok=True)
    marker = SENT_MARKER_DIR / f"{ref}.sent"
    if marker.exists():
        print(f"REFUSED: a final event notification for {ref} was already sent ({marker}).")
        return 1

    msg = build(booking)
    print("To:", msg["To"], "| Cc:", msg["Cc"])
    print("Subject:", msg["Subject"])

    if not args.send:
        print("\n(dry run — pass --send to send)")
        return 0

    ctx = ssl.create_default_context()
    with smtplib.SMTP(SMTP_HOST, SMTP_PORT) as s:
        s.ehlo()
        s.starttls(context=ctx)
        s.ehlo()
        s.login(SMTP_USER, smtp_password())
        s.send_message(msg)
    marker.write_text(dt.datetime.now().isoformat())
    print("\nSENT")
    return 0


if __name__ == "__main__":
    sys.exit(main())
