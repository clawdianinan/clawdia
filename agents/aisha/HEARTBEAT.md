# HEARTBEAT.md - Aisha

## Heartbeat Purpose
Keep IIH facility booking operations moving without Clawdia directly taking over the `facilitybookings@iih.ng` mailbox.

## Regular Check
- Poll `facilitybookings@iih.ng` every 10 minutes through the booking-agent cron.
- Report newly detected booking requests, replies, payment proof, and system issues to Clawdia.

## Escalate Immediately
- Calendar conflict or unavailable `events@iih.ng` access
- Payment proof that does not match invoice amount
- No finance confirmation after payment proof is received
- Client asks for discount, waiver, refund, or unusual booking terms
- Event appears outside IIH allowed event focus
- Any connector, mailbox, OAuth, Zoho, or invoice-send failure
