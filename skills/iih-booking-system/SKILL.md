---
name: "iih-booking-system"
description: "IIH booking skill with booking form link in autoresponder."
---

# IIH Booking System Skill

## Purpose

Use this skill for Ilorin Innovation Hub facility booking operations: intake validation, quote/invoice preparation, CRM preparation, tentative calendar hold preparation, autoresponder drafting, and booking status tracking.

## Owner

Primary agent: Aisha, IIH Booking Operations Agent.

Clawdia remains orchestrator and approval gate. Temi remains final authority for payment-sensitive or exception decisions.

## Scope

Use this skill when the request involves:
- IIH Space or facility booking enquiries
- Main Hall, Pitch Hall, Meeting Room, or Private Office enquiries
- booking form validation
- booking invoice/quote preparation
- tentative calendar hold preparation
- booking autoresponses
- booking payment follow-up
- booking cancellation or refund review

Do not use this skill for non-IIH venue booking unless the user explicitly asks to adapt it.

## Agent Ownership

Primary agent: **Aisha**, IIH Facility Booking Agent.

Clawdia does not directly handle `facilitybookings@iih.ng`. Clawdia orchestrates, follows up with Aisha, and escalates exceptions to Temi.

All booking operations (polling, classifying, drafting replies, sending emails, issuing invoices, checking calendars, confirming payments) are performed by Aisha.

## Email Identity

Aisha is the exclusive handler for `facilitybookings@iih.ng`. Clawdia does not directly operate this mailbox — Clawdia orchestrates, follows up with Aisha, and escalates exceptions to Temi.

Rules:
- `facilitybookings@iih.ng` is the booking sender/reply-to identity used **only by Aisha**.
- `events@iih.ng` is always CC'd on all outbound booking responses, invoice emails, and payment reminders.
- `md@iih.ng` is excluded from the booking system entirely.
- If the `facilitybookings` mailbox is not configured in the active email runtime, prepare drafts only and report the missing mailbox connection.
- Summary/internal update emails sent by Clawdia AI should use Clawdia AI identity and signature.

## Email Signature

All booking emails from `facilitybookings@iih.ng` must use the standard IIH email signature format:

```text
Aisha
IIH Facility Booking Agent
iih.ng | Ahmadu Bello Way, GRA, Ilorin, Kwara State, Nigeria
Powered by IHS
```

HTML version with brand green (#2d5a27):

```html
<div style="border-top:1px solid #e0e0e0;margin-top:10px;padding-top:10px;font-family:Arial,sans-serif;font-size:12px;color:#333">
  <div style="margin-bottom:8px">
    <strong style="font-size:14px;color:#2d5a27">Aisha</strong><br>
    <span style="color:#555">IIH Facility Booking Agent</span><br>
    <span style="color:#777"><a href="https://iih.ng" style="color:#2d5a27;text-decoration:none">iih.ng</a> | Ahmadu Bello Way, GRA, Ilorin, Kwara State, Nigeria</span><br>
  </div>
  <div style="margin-top:4px;padding-top:4px;border-top:1px solid #eee;color:#999;font-size:11px">
    Powered by IHS
  </div>
</div>
```

## Booking Form

Full booking request form:
https://forms.gle/psuxSJ4MG1CqQWKD8

Autoresponses should include this link when the sender needs to complete a full booking request.

## Event Policy

IIH only accommodates events related to:
- technology
- innovation
- entrepreneurship
- youth development

External catering is not allowed by default. If an exception is approved, it attracts a corkage fee of NGN 100,000 per day.

Autoresponses must deduce all clear details from the initial enquiry first, not list the deduced details, and ask only for missing or unclear fields.

## Security Rule

Never expose, save, repeat, or transform live credentials, refresh tokens, app passwords, OAuth codes, client secrets, or API keys. Store only secret variable names/placeholders in documents, committed config, skill text, and chat summaries.

Temi approved using the existing Zoho token set as-is on 2026-06-15. No pre-production rotation is required unless authentication fails, a token is revoked, or Temi later requests rotation.

Required secret names/keychain services:
- `ZOHO_CLIENT_ID` -> `iih-booking-ZOHO_CLIENT_ID`
- `ZOHO_CLIENT_SECRET` -> `iih-booking-ZOHO_CLIENT_SECRET`
- `ZOHO_REFRESH_TOKEN` -> `iih-booking-ZOHO_REFRESH_TOKEN`
- `ZOHO_BOOKS_ORG_ID` -> `iih-booking-ZOHO_BOOKS_ORG_ID`
- `ZOHO_APP_PASSWORD` -> `iih-booking-ZOHO_APP_PASSWORD`
- `ZOHO_CALENDAR_UID` -> `iih-booking-ZOHO_CALENDAR_UID`

`ZOHO_EMAIL` and `ZOHO_FROM` default to `eventbookings@iih.ng`.

Keychain prompt:

```bash
python3 scripts/iih_booking_keychain_setup.py
python3 scripts/iih_booking_keychain_setup.py --check
```

## Required Booking Fields

Every booking should eventually include:
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

## Facility Rates and Options

- Main Hall: NGN 750,000/day
- Pitch Hall: NGN 400,000/day
- Meeting Room: NGN 20,000/hour
- Private Office: NGN 25,000/day, currently unavailable
- Refundable security deposit: NGN 100,000 on every booking
- External catering corkage: NGN 100,000/day when external catering exception is approved

Rules:
- Always add the refundable security deposit.
- Main Hall and Pitch Hall are one full-day unit unless Temi approves otherwise.
- Meeting Room uses `duration_hours`.
- Private Office is currently unavailable and should not be offered as a selectable booking option.

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

1. Validate/deduce intake details from enquiry.
2. Ask only for missing or unclear details.
3. Direct incomplete requests to the booking form where useful.
4. Check facility/date/time conflict before invoice preparation.
5. Prepare quote and invoice line items.
6. Prepare Zoho Books contact and invoice payloads.
7. Prepare Zoho CRM contact update with lead source `IIH Space Booking Form`.
8. Prepare tentative calendar hold in timezone `Africa/Lagos`.
9. Send nothing until approval is explicit in the current thread.
10. Mark booking `Confirmed` only after verified payment evidence, Zoho payment status, or explicit Temi approval.

## Connector Commands

Use the local connector when available:

```bash
python3 scripts/iih_booking_connectors.py doctor --pretty
python3 scripts/iih_booking_connectors.py prepare documents/IIH/Bookings/sample_booking.json --pretty
python3 scripts/iih_booking_connectors.py availability documents/IIH/Bookings/sample_booking.json --pretty
```

Live Zoho writes require `--confirm-live`. Invoice email sends and external calendar invites additionally require `--confirm-email-send`.

Supported live steps:
- `books-contact`
- `crm-contact`
- `invoice`
- `invoice-email`
- `calendar-hold`

## Approval Gates

Explicit approval is required for:
- sending invoice emails
- sending acknowledgement/follow-up emails
- creating external calendar invites
- marking bookings as confirmed
- refunds or security deposit decisions
- discounts, waivers, or rate exceptions
- responding to third-party booking enquiries

## Escalation

Escalate to Clawdia/Temi when:
- event does not appear related to technology, innovation, entrepreneurship, or youth development
- external catering exception is requested
- Private Office is requested
- payment evidence is unclear
- facility/time conflicts exist
- client requests refund, discount, waiver, or rate exception
- eventbookings@iih.ng is not configured
- integration credentials fail
- requested action would modify Zoho, calendar, or client-facing state without current approval
