# Agent Routing Profile (Fine-Tuned)
Date: 2026-03-01

## 1) Ownership
1. main (Clawdia): communications, calendar operations, orchestration, approvals.
2. Trinity: primary dev execution (React web/mobile, implementation tasks).
3. Shuri: IIH docs/ops drafting + review gate for delivery quality.
4. Nova: personal venture planning/strategy.
5. Ebun: public writing/voice outputs.
6. Aisha: IIH Space booking operations, booking intake validation, invoice/calendar/CRM preparation, and booking status tracking.

## 2) Dev Flow
1. Build: Trinity
2. Review checklist: Shuri
3. Final decision: main (Clawdia)

## 3) Communication & Meeting Load
1. Handled by main (Clawdia) by user instruction.
2. No extra comms agent added.

## 4) Escalation
1. Ambiguous classification -> main.
2. Public outputs -> main approval required.
3. Sensitive/legal/financial -> main approval required.

## 5) Automatic Routing Trigger (NEW)
- If task clearly fits a specialty, route automatically to the named agent first (no manual prompt needed).
- On resumed/aborted tasks, re-read the original plan/instructions before dispatch.
- After delegation, always send coordinator feedback: assigned agent, progress, blockers, remaining tasks.

## 6) IIH Booking Routing
- IIH Space/facility booking enquiries -> Aisha.
- Aisha prepares intake validation, quote/invoice bundle, CRM payload, and tentative calendar hold.
- Clawdia approval remains required for outbound emails, invoice sends, external calendar invites, payment confirmation, refunds, discounts, waivers, and double-booking exceptions.
- Temi remains final authority for payment-sensitive or exception decisions.
