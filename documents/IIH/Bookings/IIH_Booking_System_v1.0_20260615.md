# IIH Booking System v1.0

Author: Clawdia AI  
Owner: Aisha, IIH Booking Operations Agent  
Date: 2026-06-15  
Context: IIH Space facility bookings

## 1. Objective

The IIH Booking System standardizes facility booking operations for Ilorin Innovation Hub. It converts booking enquiries into validated booking records, prepares invoice and CRM actions, creates tentative calendar holds, and tracks the booking through payment confirmation.

The system is intentionally approval-gated. It can prepare actions automatically, but outbound messages, invoice sends, payment confirmation, refunds, discounts, and exceptions require explicit approval unless Temi has already instructed that exact action in the current thread.

## 2. Assigned Agent

Aisha is assigned as the dedicated IIH Booking Operations Agent.

Aisha owns:
- booking intake validation
- facility/rate application
- invoice bundle preparation
- CRM/contact preparation
- tentative calendar hold preparation
- booking status tracking
- escalation of conflicts, payment issues, refunds, discounts, and exceptions

Clawdia remains the orchestrator and approval gate.

## 3. Booking Status Model

Use these statuses exactly:

1. `Draft` - enquiry received but incomplete.
2. `Pending Availability` - intake complete, awaiting conflict/availability check.
3. `Tentative` - slot is available and a tentative hold can be prepared.
4. `Invoice Sent` - invoice has been sent after approval.
5. `Payment Pending` - invoice sent, payment not confirmed.
6. `Confirmed` - payment evidence has been verified or explicitly approved.
7. `Cancelled` - booking cancelled.
8. `Refund Review` - cancellation/refund decision requires review.

## 4. Required Booking Schema

```json
{
  "full_name": "Client Full Name",
  "email": "client@example.com",
  "phone": "+234...",
  "organization": "Client Company Name",
  "facility": "Main Hall | Pitch Hall | Meeting Room | Private Office",
  "event_name": "Name of the Event",
  "event_type": "Conference | Workshop | Meeting | Other",
  "event_date": "YYYY-MM-DD",
  "start_time": "HH:MM",
  "duration_hours": 8,
  "expected_attendance": 100,
  "external_catering": false,
  "special_requirements": "Optional notes"
}
```

## 5. Approved Facility Rates

| Facility | Billing Mode | Rate |
|---|---:|---:|
| Main Hall | Full day | NGN 750,000/day |
| Pitch Hall | Full day | NGN 400,000/day |
| Meeting Room | Hourly | NGN 20,000/hour |
| Private Office | Hourly | NGN 20,000/hour |
| Refundable Security Deposit | Per booking | NGN 100,000 |
| External Catering Corkage | Conditional | NGN 100,000/day |

Rules:
- Always add the refundable security deposit.
- Add external catering corkage when `external_catering` is true.
- Main Hall and Pitch Hall are billed as one full-day unit unless Temi approves a different rule.
- Meeting Room and Private Office are billed by `duration_hours`.

## 6. Secret Handling

Do not store credentials in documents or agent memory. Configure these as environment secrets only:

- `ZOHO_CLIENT_ID`
- `ZOHO_CLIENT_SECRET`
- `ZOHO_REFRESH_TOKEN`
- `ZOHO_BOOKS_ORG_ID`
- `ZOHO_APP_PASSWORD`
- `ZOHO_EMAIL`
- `ZOHO_FROM`

The source setup guide exposed live-looking credentials. Rotate the Zoho OAuth client secret, refresh token, and mail app password before production use.

## 7. Workflow

### Step 1 - Intake

Aisha validates that all required booking fields are present and well-formed.

If required fields are missing, Aisha returns a short missing-fields list and keeps the booking in `Draft`.

### Step 2 - Availability

Aisha checks facility/date/time overlap before preparing invoice actions.

If availability cannot be checked from the current system state, Aisha marks the booking `Pending Availability` and asks Clawdia to run or approve the availability check.

### Step 3 - Quote and Invoice Bundle

Aisha calculates:
- facility line item
- refundable security deposit
- external catering corkage, if applicable
- invoice due date, normally 7 days from invoice date
- draft invoice email body

### Step 4 - Zoho Books and CRM Preparation

Aisha prepares:
- find/create Zoho Books contact action
- invoice creation payload
- invoice email payload
- find/create/update Zoho CRM contact payload

No external write happens without approval.

### Step 5 - Calendar Hold

Aisha prepares a tentative calendar hold:
- title format: `[TENTATIVE] {facility} - {event_name}`
- timezone: Africa/Lagos
- attendees: events@iih.ng and the client
- reminder: 24 hours before

Calendar invites are external communications and require approval before sending.

### Step 6 - Payment Confirmation

Only mark a booking `Confirmed` when one of these is true:
- payment evidence has been verified
- Zoho Books payment status confirms payment
- Temi explicitly approves confirmation

Confirmed calendar title format:
`[CONFIRMED] {facility} - {event_name}`

## 8. Approval Gates

Explicit approval is required for:
- sending invoice emails
- sending acknowledgement/follow-up emails
- creating external calendar invites
- marking bookings as confirmed
- refunds or security deposit decisions
- discounts, waivers, or rate exceptions
- responding to third-party booking enquiries

## 9. Client Email Draft Standard

Use `Warm regards,`.

For IIH booking emails:
- keep tone warm and professional
- include facility, event date, invoice/payment deadline, and booking status
- CC events@iih.ng on invoice emails
- direct enquiries to eventbookings@iih.ng

## 10. Operational Bundle Output

For each booking, Aisha should return:

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

## 11. Production Readiness Checklist

- Zoho secrets rotated and stored only as environment secrets.
- Booking form captures the required schema.
- Availability source of truth is selected.
- Aisha has a booking register path or database.
- Dry-run invoice payload tested.
- Dry-run calendar payload tested.
- Explicit approval flow confirmed.
- Events team handoff confirmed with Maureen/events@iih.ng.
