# Codex Research Task — Where should LLM input be allowed in Aisha's booking process?

## Context
Aisha is the IIH facility-booking agent. Today the pipeline is largely deterministic Python:
intake -> classify -> deduce intake -> quote -> hold -> invoice -> payment -> finance confirm -> calendar confirm -> release.
Some steps use fixed templates and hard gates. Temi wants to selectively introduce **LLM input** at the right steps — not everywhere.

## The question
Identify which steps in the booking process should allow LLM input (judgement/composition/parsing),
and which must stay deterministic (money, state transitions, gates).

## Scope (read the real code)
- `scripts/iih_booking_agent.py` — classify(), deduce_intake, send_template_response, guards, poll loop
- `scripts/iih_booking_connectors.py` — Zoho/Books/CRM/calendar steps, availability, holds
- `scripts/iih_booking_quote.py` — quote maths, VAT, deposit, day-rate
- `config/templates/*.json` — fixed response templates
- `config/iih_booking_system.json` — policy, gates, rates
- `analysis/codex-booking-review/FINDINGS.md` — the prior review (gates, idempotency, policy rules)

## Business rules that constrain the answer
1. Invoice always required.
2. Every facilitybookings@ email must CC events@iih.ng.
3. Finance must confirm payment before calendar confirmation.
4. Availability must be checked against the events calendar.
5. Only confirmed bookings/blackouts block a date.
6. Sponsorship codes: single-use, expiry-capped, labelled.
7. Quote = rate x days/hours + corkage + deposit + VAT on ALL rentals (Temi's 2026-08-17 decision).
8. `updatedAt` CAS guard on invoicing.
9. No auto-reply to native website/Google Form submissions.
10. No external send without the approval/payment gates.

## What to produce (report only, no code changes)
1. **Step-by-step table** of the current booking pipeline: step name, what it does today, deterministic-or-not.
2. For each step, a verdict: **LLM-appropriate**, **LLM-assisted (human approval)**, or **must stay deterministic** — with a one-line reason.
3. For every LLM-appropriate step: what the LLM would actually do (parse / classify / draft / summarise / extract), what inputs it needs, and what output schema it must return.
4. For every step where LLM output could reach money or state: the **exact guard** that must wrap it (schema validation, allowed-value enum, amount recompute from deterministic source, human approval).
5. Named anti-patterns: where an LLM must NEVER be on the critical path, and why.
6. A recommended **first three steps** to introduce LLM input, ordered by value/risk.

## Constraints
- READ-ONLY. Do not modify any file.
- Be concrete: cite file:line for the current behaviour of each step.
- Keep it terse. No filler. Flag uncertainty.
- Output to `analysis/codex-llm-steps/LLM_STEPS.md`.
