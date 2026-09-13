# Codex Review Brief — IIH Facility Booking Flow (Aisha)

## Objective
Perform a full code + process review of the IIH facility booking system operated by the Aisha agent, and produce prioritised, actionable recommendations.

## Scope (files under review)
Primary implementation:
- `scripts/iih_booking_agent.py` (1664 lines) — mailbox poll, classification, auto-respond, thread state
- `scripts/iih_booking_connectors.py` (1192 lines) — SMTP/IMAP/Himalaya/Zoho connectors, signature handling
- `scripts/iih_booking_quote.py` (447 lines) — quote/rate/VAT/deposit calculation
- `scripts/iih_booking_keychain_setup.py` (124 lines) — secret management

Configuration & templates:
- `config/iih_booking_system.json`
- `config/templates/new_enquiry_ack.json`, `reply_ack.json`

Runtime wrappers:
- `~/Library/LaunchAgents/ng.iih.booking-agent.plist` (poll every 30 min, `poll --limit 10 --auto-respond`)
- Workspace agent policy: `aisha/AGENTS.md`, `aisha/SOUL.md`, `aisha/TOOLS.md`

## Business rules that MUST hold (from IIH policy)
1. Invoice is ALWAYS required for a facility booking.
2. Every email from `facilitybookings@iih.ng` must CC `events@iih.ng` (unless Temi says otherwise in-thread).
3. Customer payment proof must be confirmed with `finance@iih.ng` BEFORE final calendar confirmation.
4. Availability must be checked against the `events@iih.ng` shared calendar before invoicing/confirming.
5. Only CONFIRMED bookings and blackouts block a date; tentative holds are placed via `iih.bookings.block` while invoicing.
6. Sponsorship codes are single-use, expiry-capped (<=120 days), label required; deposit/catering/corkage still chargeable.
7. Quote = rate x days/hours + corkage (if external catering) + refundable deposit + VAT 7.5% on catering lines ONLY.
8. A client can edit their own booking while an invoice is out — invoice recording must guard against `updatedAt` drift.
9. Never reply to website/Google Form submissions via email; native form submissions are complete intake.
10. No external email may be sent without the approval/payment gates in policy.

## Deliverables required from you
1. **Flow map** — end-to-end: intake -> classify -> quote -> hold -> invoice -> payment -> finance confirm -> calendar confirm -> release. Note every state transition and its guard.
2. **Defect list** — bugs, race conditions, idempotency gaps, error handling holes, silent-failure paths. Severity: Critical / High / Medium / Low. Cite file + line.
3. **Policy-compliance findings** — any place code can violate rules 1–10 above.
4. **Resilience findings** — the `himalaya` connector has historically timed out at 30s (224 historical TimeoutExpired events). Assess retry/timeout/backoff handling.
5. **Security review** — secret handling, credential storage, injection surfaces (email body -> shell/SQL), PII exposure in logs.
6. **Prioritised recommendations** — ordered by (impact x likelihood) / effort, each with a concrete fix sketch.

## Constraints
- READ-ONLY. Do not modify any file.
- Report file:line for every finding.
- Be specific and terse. No filler. Flag uncertainty explicitly.
- Output to `analysis/codex-booking-review/FINDINGS.md`.
