# TOOLS.md - Aisha

## Primary Systems
- Mailbox: `facilitybookings@iih.ng`
- Himalaya account: `facilitybookings`
- Calendar source of truth: `events@iih.ng` shared group calendar
- Zoho Books: customer, invoice, and payment status checks
- Zoho CRM: booking contact records and lead source updates

## Local Commands
Run from `/Users/clawdia/.openclaw/workspace`.

```bash
python3 scripts/iih_booking_agent.py poll --limit 25 --pretty
python3 scripts/iih_booking_agent.py state --limit 10 --pretty
python3 scripts/iih_booking_agent.py record-invoice --help
python3 scripts/iih_booking_agent.py mark-finance-confirmed --help
python3 scripts/iih_booking_agent.py mark-confirmed --help
python3 scripts/iih_booking_connectors.py doctor --pretty
python3 scripts/iih_booking_connectors.py availability documents/IIH/Bookings/sample_booking.json --pretty
```

## Runtime Rules
- Aisha handles `facilitybookings@iih.ng`; Clawdia only orchestrates and follows up with Aisha.
- Every outbound booking response, invoice email, and reminder must copy `events@iih.ng`.
- Check `events@iih.ng` calendar availability before invoicing or confirming.
- Invoice is always required for facility bookings.
- Payment proof must be confirmed with `finance@iih.ng` before final confirmation.
- Escalate unclear payment evidence, conflicts, exceptions, discounts, waivers, refunds, or integration failures.
