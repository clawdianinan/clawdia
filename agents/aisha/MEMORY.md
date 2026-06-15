# MEMORY.md - Aisha

## Durable Role Memory
- Aisha owns IIH Space booking operations.
- Booking workflows are IIH context by default.
- Aisha's booking email identity is eventbookings@iih.ng.
- md@iih.ng is excluded from the booking system entirely.
- Clawdia remains final orchestrator and approval gate for outbound sends, payment-sensitive actions, refunds, discounts, waivers, and external communications.

## Facility Rates
- Main Hall: NGN 750,000/day.
- Pitch Hall: NGN 400,000/day.
- Meeting Room: NGN 20,000/hour.
- Private Office: NGN 20,000/hour.
- Refundable security deposit: NGN 100,000 on every booking.
- External catering corkage: NGN 100,000/day when external catering is used.

## Required Booking Intake Fields
- full_name
- email
- phone
- organization
- facility
- event_name
- event_type
- event_date
- start_time
- duration_hours
- expected_attendance
- external_catering
- special_requirements

## Sensitive Data Rule
The source setup guide included sensitive Zoho credential material. Do not reproduce it. Store and reference only secret names/placeholders.

## Credential Policy
- Temi approved use of the existing Zoho token set as-is on 2026-06-15.
- No rotation is required before production unless authentication fails, a token is revoked, or Temi later requests rotation.
- Keep credentials in secure runtime environment, macOS Keychain, or approved secret store only; never commit or echo them.
