#!/usr/bin/env python3
"""IIH booking — FINAL EVENT NOTIFICATION, on finance confirmation.

Per Temi, 22 Sep 2026: when finance confirms a booking, complete it concretely
and send the final event notification to BOTH the client and the team. This is
a regular occurrence on every finance-confirmed booking.

TWO sends, deliberately separate, because the two audiences need different
things and the standing email rules differ for each:

  1. CLIENT  — a same-thread confirmation reply.
       To: the client            Cc: events@iih.ng
       Preserves In-Reply-To/References from the client's last message, so it
       lands in the thread they already have. Uses the approved HTML/logo
       signature. Says the booking is confirmed and what happens next; contains
       NO internal detail (staffing, setup notes, the internal readiness list).

  2. TEAM    — an internal readiness notice.
       To: events@iih.ng         Cc: everyone@iih.ng
       Client is NOT copied. This carries the operational detail the team needs
       to prepare: setup, catering, attendance, space, timing.

Each send is tracked with its own marker so a re-run cannot double-send either.

Usage:
  python3 send_final_event_notification.py <booking.json> [--send] [--client-only] [--team-only]
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
MARKER_DIR = Path(
    "/Users/clawdia/.openclaw/workspace/documents/IIH/Bookings/.notifications"
)

EVENTS = "events@iih.ng"
EVERYONE = "everyone@iih.ng"


def smtp_password() -> str:
    return subprocess.check_output(
        ["security", "find-generic-password", "-s", KEYCHAIN_SERVICE, "-a", KEYCHAIN_ACCOUNT, "-w"],
        text=True,
    ).strip()


def weekday(date_str: str) -> str:
    """Day of week for an ISO date — computed, never trusted from memory.

    Temi, 31 Aug 2026: a date's weekday is verifiable and must be verified.
    """
    return dt.date.fromisoformat(date_str).strftime("%A %d %B %Y")


def _attach_html(msg: EmailMessage, html: str) -> None:
    msg.set_content("Please view this email in an HTML-capable client.")
    msg.add_alternative(html, subtype="html")
    msg.get_payload()[1].add_related(
        LOGO.read_bytes(), maintype="image", subtype="png", cid="<iih_logo>"
    )


def build_client(b: dict) -> EmailMessage:
    """Client-facing confirmation. Same thread, Cc Events, no internal detail."""
    ref = b["reference"]
    event = b.get("event", {})
    sched = b.get("schedule", {})
    when = weekday(sched["eventDay"])
    space = ", ".join(b.get("spaceNames", []))

    msg = EmailMessage()
    msg["From"] = formataddr(("Aisha", SMTP_USER))
    msg["To"] = b["client"]["email"]
    msg["Cc"] = EVENTS
    msg["Subject"] = f"Re: {event.get('name')} — booking confirmed ({ref})"
    msg["Message-ID"] = make_msgid(domain="iih.ng")
    # Thread into the client's existing conversation when we know it.
    if b.get("clientThread", {}).get("messageId"):
        msg["In-Reply-To"] = b["clientThread"]["messageId"]
        refs = b["clientThread"].get("references") or ""
        msg["References"] = " ".join((refs + " " + b["clientThread"]["messageId"]).split())

    html = f"""<div style="font-family: Arial, sans-serif; font-size: 14px; color: #333; line-height: 1.6;">
<p>Dear {b['client'].get('name', '').split()[0]},</p>

<p>Thank you — we have received and confirmed your payment, and your booking is now <strong>confirmed</strong>. Our team is making arrangements for your event.</p>

<table cellpadding="6" cellspacing="0" border="0" style="font-size: 13px; border-collapse: collapse; border: 1px solid #ddd;">
<tr><td style="border-bottom:1px solid #eee;"><strong>Reference</strong></td><td style="border-bottom:1px solid #eee;">{ref}</td></tr>
<tr><td style="border-bottom:1px solid #eee;"><strong>Event</strong></td><td style="border-bottom:1px solid #eee;">{event.get('name')}</td></tr>
<tr><td style="border-bottom:1px solid #eee;"><strong>Date</strong></td><td style="border-bottom:1px solid #eee;">{when}</td></tr>
<tr><td style="border-bottom:1px solid #eee;"><strong>Time</strong></td><td style="border-bottom:1px solid #eee;">{sched.get('dailyStartTime')} – {sched.get('dailyEndTime')} (Africa/Lagos)</td></tr>
<tr><td><strong>Space</strong></td><td>{space}</td></tr>
</table>

<p style="margin-top:14px;">If anything above needs changing, please reply to this email and we will assist. We look forward to hosting you.</p>
</div>
{SIGNATURE.read_text()}"""
    _attach_html(msg, html)
    return msg


def build_team(b: dict) -> EmailMessage:
    """Internal readiness notice. Client NOT copied."""
    ref = b["reference"]
    client = b.get("client", {})
    event = b.get("event", {})
    sched = b.get("schedule", {})
    fin = b.get("finance", {})
    setup = b.get("setup", {})
    when = weekday(sched["eventDay"])

    msg = EmailMessage()
    msg["From"] = formataddr(("IIH Facility Bookings", SMTP_USER))
    msg["To"] = EVENTS
    msg["Cc"] = EVERYONE
    msg["Subject"] = f"[CONFIRMED] {event.get('name')} — {when} — {', '.join(b.get('spaceNames', []))} ({ref})"
    msg["Message-ID"] = make_msgid(domain="iih.ng")

    html = f"""<div style="font-family: Arial, sans-serif; font-size: 14px; color: #333; line-height: 1.6;">
<p><strong>Booking confirmed.</strong> Payment received and confirmed by Finance. Please make arrangements accordingly.</p>

<table cellpadding="6" cellspacing="0" border="0" style="font-size: 13px; border-collapse: collapse;">
<tr><td><strong>Reference</strong></td><td>{ref}</td></tr>
<tr><td><strong>Event</strong></td><td>{event.get('name')}</td></tr>
<tr><td><strong>Client</strong></td><td>{client.get('organization')} — {client.get('name')}</td></tr>
<tr><td><strong>Date</strong></td><td>{when}</td></tr>
<tr><td><strong>Time</strong></td><td>{sched.get('dailyStartTime')} – {sched.get('dailyEndTime')} (Africa/Lagos)</td></tr>
<tr><td><strong>Space</strong></td><td>{', '.join(b.get('spaceNames', []))}</td></tr>
<tr><td><strong>Expected attendance</strong></td><td>{event.get('expectedAttendance')}</td></tr>
<tr><td><strong>Seating</strong></td><td>{setup.get('seatingArrangement') or 'Not specified'}</td></tr>
<tr><td><strong>Catering</strong></td><td>{setup.get('cateringRequired') or 'No'}</td></tr>
<tr><td><strong>Invoice</strong></td><td>{fin.get('invoiceNumber')}</td></tr>
</table>

<p style="margin-top:14px;"><strong>Internal note.</strong> The client has been notified separately on their own thread. Client contact details are held in the booking record, not on the internal calendar.</p>
</div>
{SIGNATURE.read_text()}"""
    _attach_html(msg, html)
    return msg


def _send(msg: EmailMessage) -> None:
    ctx = ssl.create_default_context()
    with smtplib.SMTP(SMTP_HOST, SMTP_PORT) as s:
        s.ehlo()
        s.starttls(context=ctx)
        s.ehlo()
        s.login(SMTP_USER, smtp_password())
        s.send_message(msg)


def _dispatch(msg, marker: Path, live: bool, label: str) -> bool:
    print(f"--- {label} ---")
    print("To:", msg["To"], "| Cc:", msg["Cc"])
    print("Subject:", msg["Subject"])
    if marker.exists():
        print(f"REFUSED: {label} already sent for this booking ({marker}).")
        return False
    if not live:
        print("(dry run)")
        return True
    _send(msg)
    MARKER_DIR.mkdir(parents=True, exist_ok=True)
    marker.write_text(dt.datetime.now().isoformat())
    print("SENT")
    return True


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("booking_json")
    ap.add_argument("--send", action="store_true")
    ap.add_argument("--client-only", action="store_true")
    ap.add_argument("--team-only", action="store_true")
    args = ap.parse_args()

    b = json.loads(Path(args.booking_json).read_text())
    ref = b["reference"]
    MARKER_DIR.mkdir(parents=True, exist_ok=True)

    ok = True
    if not args.team_only:
        ok &= _dispatch(build_client(b), MARKER_DIR / f"{ref}.client.sent", args.send, "CLIENT")
        print()
    if not args.client_only:
        _dispatch(build_team(b), MARKER_DIR / f"{ref}.team.sent", args.send, "TEAM")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
