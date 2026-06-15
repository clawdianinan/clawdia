---
name: "iih-booking-system"
description: "IIH Space booking workflow with approved existing Zoho token use."
---

# IIH Booking System Skill

## Purpose

Use this skill for Ilorin Innovation Hub facility booking operations: intake validation, quote/invoice preparation, CRM preparation, tentative calendar hold preparation, and booking status tracking.

## Owner

Primary agent: Aisha, IIH Booking Operations Agent.

Clawdia remains orchestrator and approval gate. Temi remains final authority for payment-sensitive or exception decisions.

## Scope

Use this skill when the request involves:
- IIH Space or facility booking enquiries
- Main Hall, Pitch Hall, Meeting Room, or Private Office bookings
- booking form validation
- booking invoice/quote preparation
- tentative calendar hold preparation
- booking payment follow-up
- booking cancellation or refund review

Do not use this skill for non-IIH venue booking unless the user explicitly asks to adapt it.

## Security Rule

Never expose, save, repeat, or transform live credentials, refresh tokens, app passwords, OAuth codes, client secrets, or API keys. Store only secret variable names/placeholders in documents, committed config, skill text, and chat summaries.

Temi approved using the existing Zoho token set as-is on 2026-06-15. No pre-production rotation is required unless authentication fails, a token is revoked, or Temi later requests rotation.

Required secret names:
- `ZOHO_CLIENT_ID`
- `ZOHO_CLIENT_SECRET`
- `ZOHO_REFRESH_TOKEN`
- `ZOHO_BOOKS_ORG_ID`
- `ZOHO_APP_PASSWORD`
- `ZOHO_EMAIL`
- `ZOHO_FROM`

Credentials may be used from secure runtime environment variables, macOS Keychain, or another approved secret store only. Do not commit or echo values.

## Required Booking Fields

Every booking must include:
- `full_name`
- `email`
- `phone`
- `organization`
- `facility`
- `event_name`
- `event_type`
- `event_date` as `YYYY-MM-DD`
- `start_time` as 24-hour `HH:MM`
- `duration_hours`
- `expected_attendance`
- `external_catering`
- `special_requirements`

If required data is missing, keep status `Draft` and ask only for the missing fields.

## Facility Rates

- Main Hall: NGN 750,000/day
- Pitch Hall: NGN 400,000/day
- Meeting Room: NGN 20,000/hour
- Private Office: NGN 20,000/hour
- Refundable security deposit: NGN 100,000 on every booking
- External catering corkage: NGN 100,000/day when external catering is used

Rules:
- Always add the refundable security deposit.
- Add external catering corkage when `external_catering` is true.
- Main Hall and Pitch Hall are one full-day unit unless Temi approves otherwise.
- Meeting Room and Private Office use `duration_hours`.

## Status Model

Use these statuses exactly:
1. `Draft`
2. `Pending Availability`
3. `Tentative`
4. `Invoice Sent`
5. `Payment Pending`
6. `Confirmed`
7. `Cancelled`
8. `Refund Review`

## Workflow

1. Validate intake.
2. Check facility/date/time conflict before invoice preparation.
3. Prepare quote and invoice line items.
4. Prepare Zoho Books contact and invoice payloads.
5. Prepare Zoho CRM contact update with lead source `IIH Space Booking Form`.
6. Prepare tentative calendar hold in timezone `Africa/Lagos`.
7. Send nothing until approval is explicit in the current thread.
8. Mark booking `Confirmed` only after verified payment evidence, Zoho payment status, or explicit Temi approval.

## Approval Gates

Explicit approval is required for:
- sending invoice emails
- sending acknowledgement/follow-up emails
- creating external calendar invites
- marking bookings as confirmed
- refunds or security deposit decisions
- discounts, waivers, or rate exceptions
- responding to third-party booking enquiries

## Email Rules

- Use `Warm regards,`.
- Keep booking emails warm, professional, and precise.
- Include facility, event date, invoice/payment deadline, and booking status.
- CC `events@iih.ng` on invoice emails.
- Direct enquiries to `eventbookings@iih.ng`.

## Output Format

For every booking preparation run, return a concise operations bundle:

```json
{
  "status": "Tentative",
  "booking_reference": "IIH-BOOK-YYYYMMDD-CLIENT",
  "quote": {
    "currency": "NGN",
    "line_items": [],
    "total": 0
  },
  "approval_required": [],
  "next_actions": []
}
```

## Local Helper

When available in the workspace, use:

```bash
python3 scripts/iih_booking_quote.py documents/IIH/Bookings/sample_booking.json --pretty
```

This helper performs a dry run only. It does not send emails, create invoices, write CRM records, or create calendar invites.

## Escalation

Escalate to Clawdia/Temi when:
- payment evidence is unclear
- facility/time conflicts exist
- client requests refund, discount, waiver, or rate exception
- booking requires external communication
- integration credentials fail
- requested action would modify Zoho, calendar, or client-facing state without current approval
