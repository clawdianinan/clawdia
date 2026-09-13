# Where Should LLM Input Be Allowed in Aisha's Booking Process?

**Reviewer:** Codex CLI 0.153.4 (read-only)
**Date:** 2026-09-13
**Token cost:** 128,501

> Codex completed the analysis (exit 0) but its sandbox rejected the write to this file. This artifact is assembled from Codex's own verified output; nothing was added or altered.

---

## Core Conclusion

| Verdict | Steps |
|---|---|
| **LLM-appropriate** | request classification; free-text intake extraction; missing-field deduction; read-only operational summaries |
| **LLM-assisted (human approval)** | ambiguous thread linking; client-response drafting; payment-proof parsing |
| **Must stay deterministic** | authentication, validation, availability, quote/VAT/deposit/corkage, sponsorship, holds, invoices, payment recording, Finance confirmation, calendar confirmation, state transitions, releases |

---

## The Required LLM Boundary

Every LLM touchpoint must pass through this chain — no exceptions:

```text
LLM proposal
→ strict schema + source-span validation
→ deterministic authoritative lookup/recalculation
→ human approval where required
→ updatedAt CAS + allowed transition
→ idempotent transactional command + audit
```

**Rule of thumb:** the LLM may *propose*; it may never *decide* anything that touches money or state.

---

## Output Contracts (what each LLM step must return)

- **Classification:** enum request type, confidence, evidence spans, review flag, advisory action.
- **Intake extraction:** typed candidate fields, source quote per field, confidence, missing fields, conflicts, clarification questions; **unstated values stay null**.
- **Thread matching:** ranked IDs from deterministically retrieved candidates; **mandatory human selection**.
- **Drafting:** purpose, subject/body, authoritative facts used, required policy elements; **no recipients, no send command**.
- **Payment parsing:** claimed invoice, payer, amount, date, reference, source excerpts, ambiguity flags; **always `requires_finance_confirmation: true`**.
- **Summary:** verified facts, unverified claims, blocking gates, recommended next action; **read-only**.

---

## Named Anti-Patterns (never allow)

- **Semantic calculator** — LLM-generated prices, VAT, deposits, discounts or refunds.
- **Natural-language state machine** — "looks paid/available, so confirm."
- **Evidence-by-string** — model prose satisfying Finance / availability / sponsorship gates.
- **Calendar oracle** — model-inferred availability.
- **Sponsor-code oracle** — model deciding validity, expiry, cap or redemption.
- **Autonomous mailer** — model-controlled recipients, attachments or SMTP.
- **Silent field completion** — inventing missing dates, times, spaces or catering choices.
- **Fuzzy thread binder** — auto-joining similar-looking clients/bookings.
- **LLM finance approver** — treating OCR or a receipt image as cleared funds.
- **Model-controlled reconciliation** — deciding whether to retry invoice/calendar writes.

---

## Critical Gaps Found in Current Code

These must be closed **before** the corresponding LLM step is safe to introduce:

1. `deduce_intake` is not implemented — exists only as a next-action string (`scripts/iih_booking_agent.py:678-680`).
2. Scheduled poll reads email but does not ingest native website booking rows (`scripts/iih_booking_agent.py:43-45`, `1393-1423`).
3. Local availability blocks every non-cancelled booking and active hold, contrary to the confirmed/blackout rule, and skips the required dual-source backend+calendar check (`scripts/iih_booking_connectors.py:716-750`; `config/iih_booking_system.json:564-590`).
4. Invoice CAS is **optional** and therefore bypassable (`scripts/iih_booking_agent.py:1559-1583`, `1957-1961`).
5. Local quote `total` excludes VAT despite adding tax metadata; accepts unauthorised raw discounts (`scripts/iih_booking_quote.py:317-380`).
6. Sponsorship validation absent locally; only `sponsor_code_id` storage exists (`scripts/iih_booking_agent.py:1045-1058`).
7. Availability and Finance gates can be satisfied with arbitrary or empty evidence strings (`scripts/iih_booking_agent.py:1760-1822`, `1875-1904`; `scripts/iih_booking_connectors.py:1067-1080`).
8. Payment proof amount is never matched against the authoritative invoice total (`scripts/iih_booking_agent.py:1825-1872`).
9. Connector's independent confirmed-calendar path does not require an invoice ID (`scripts/iih_booking_connectors.py:1060-1087`).

---

## Recommended First Three Introductions (ordered by value/risk)

1. **Request classification in shadow mode** — log the LLM's proposed class beside the deterministic one; change nothing until agreement is high.
2. **Provenance-bearing free-text intake extraction + missing-field deduction** — LLM proposes typed fields with source spans; deterministic validation decides what enters state.
3. **Human-approved client drafts + internal escalation summaries** — grounded in deterministic availability and quote results; never sent by the model.

**Do not start with payment-proof parsing** until the amount-matching, evidence-provenance and Finance-confirmation gates are strengthened.
