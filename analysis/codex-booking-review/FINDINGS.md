# IIH Facility Booking Flow — Codex Review Findings

**Reviewer:** Codex CLI 0.153.4 (Morpheus × QA/resilience, Cypher × security, Aisha-policy lane)
**Date:** 2026-09-13
**Scope:** Aisha booking agent — `scripts/iih_booking_agent.py`, `scripts/iih_booking_connectors.py`, `scripts/iih_booking_quote.py`, `config/iih_booking_system.json`, mailbox LaunchAgent.
**Method:** Read-only. Every finding carries file:line evidence.
**Token cost:** 215,241

> Note: Codex completed the analysis with exit 0 but its workspace sandbox rejected the write to this file. This artifact was assembled from Codex's own verified output; no finding below was added or altered by the assembler.

---

## Executive Summary

The scheduled Python booking path is **not** built on the documented authoritative `iih.bookings.*` backend workflow. Confirmation guards that policy requires — invoice, payment, finance sign-off, availability, sponsorship — are enforced only in prose, not in the code path the poll actually executes. The highest-severity items are confirmation bypasses and a quote engine that computes the wrong amount. Priority order from Codex:

> contain confirmation bypasses; make the backend state machine authoritative; correct/freeze quote rules; add `updatedAt` CAS; implement durable outbox/saga idempotency; enforce dual availability and calendar linking; repair mailbox retries/dedup; reduce credential scope and PII exposure.

---

## 1. Critical — Confirmation Bypasses

Both confirmation entry points can confirm a booking with **no** invoice, payment, finance confirmation, availability check, or sponsorship validation:

- `mark_confirmed()` — `scripts/iih_booking_agent.py:1494`
- `calendar-confirmed` — `scripts/iih_booking_connectors.py:1057`

**Impact:** Directly violates policy rules 1, 3, 4, 5. A booking can reach confirmed state without money, without a calendar check, and without finance.

---

## 2. Critical — Authoritative Backend Not Implemented

The documented `iih.bookings.*` workflow is not what the scheduled Python path drives. Invoice creation writes to local SQLite and has **no `updatedAt` guard**:

- `scripts/iih_booking_connectors.py:1020`
- `scripts/iih_booking_agent.py:1454` (`record-invoice`)

**Impact:** Violates rule 8. A client can edit their own booking while an invoice is out; nothing detects the drift, so an invoice can be raised against a booking whose spaces/dates have since changed.

---

## 3. Critical — Quote Calculation Is Materially Wrong

`scripts/iih_booking_quote.py:299`:
- Day-rate quantity is always **1** (multi-day bookings undercharge).
- Catering lines are **absent** entirely.
- Sponsorship is **ignored** in the calculation.
- VAT configuration conflicts with the stated catering-only rule — `config/iih_booking_system.json:207`.

**Impact:** Violates rule 7. Amounts billed do not match the policy formula (rate × days/hours + corkage + deposit + VAT 7.5% on catering only).

---

## 4. High — Non-Atomic, Non-Idempotent Sends and Writes

- SMTP send — `scripts/iih_booking_agent.py:842`
- Zoho workflow — `scripts/iih_booking_connectors.py:1020`

**Impact:** Creates windows for duplicate sends, permanent drops, orphan invoices, and duplicate calendar events. No durable outbox or saga.

---

## 5. High — Reference Collisions / Silent Overwrites

- `booking_reference()` — `scripts/iih_booking_quote.py:277`
- register write — `scripts/iih_booking_connectors.py:753`

Booking references can collide, and `INSERT OR REPLACE` silently overwrites existing records.

---

## 6. High — Mailbox Resilience

- Poll path — `scripts/iih_booking_agent.py:1193`
- Himalaya has **no retry/backoff**.
- Verified evidence: 224 timeout mentions in the error log represent **112 terminal timeout tracebacks**.
- Per-message failures can still mark a poll as *successful*.

**Impact:** Silent drop of inbound booking mail; a green poll can hide a lost message.

---

## 7. High — Rate Limiter Before Deduplication

- `scripts/iih_booking_agent.py:412`

The live DB contains **261 rate-limit quarantine rows for only 27 distinct messages** — the limiter fires before dedup, so legitimate messages get quarantined repeatedly.

---

## 8. Security Findings

| Finding | Evidence |
|---|---|
| Fail-open email authentication | `scripts/iih_booking_agent.py:395` |
| Recipient injection via reply-all | `scripts/iih_booking_agent.py:284` |
| Broadly exposed calendar/log PII | `scripts/iih_booking_connectors.py:470` |
| Apparently site-wide admin/write booking token | `config/iih_booking_system.json:401` |

---

## 9. Policy Compliance Matrix

| Rule | Result |
|---|---|
| 1 (invoice always required) | **FAIL** |
| 2 (CC events@iih.ng) | PARTIAL |
| 3 (finance confirm before calendar) | **FAIL** |
| 4 (check events calendar) | **FAIL** |
| 5 (only confirmed/blackout block) | **FAIL** |
| 6 (sponsor codes single-use/capped) | FAIL locally; remote enforcement unverified |
| 7 (quote formula) | **FAIL** |
| 8 (`updatedAt` guard) | **FAIL** |
| 9 (no reply to form submissions) | PASS for recognised Google Form mail; native website intake absent |
| 10 (no send without gates) | **FAIL** |

---

## 10. Runtime Drift

- Installed polling is **30 minutes**; documentation/config still specify **10 minutes** (`~/Library/LaunchAgents/ng.iih.booking-agent.plist:24`) — doc drift introduced by today's interval change; config should be updated to match.
- The autoresponder **kill switch is ignored**.
- The **watchdog is unscheduled**.

---

## 11. Recommended Priority Order

1. **Contain confirmation bypasses** — gate `mark_confirmed()` and `calendar-confirmed` behind invoice + payment + finance + availability + sponsorship checks.
2. **Make the backend state machine authoritative** — the scheduled path should drive `iih.bookings.*`, not a parallel local SQLite state.
3. **Correct/freeze quote rules** — fix day-quantity, add catering lines, handle sponsorship, reconcile VAT config.
4. **Add `updatedAt` CAS** on invoice recording (rule 8).
5. **Durable outbox / saga idempotency** for SMTP and Zoho writes.
6. **Enforce dual availability + calendar linking.**
7. **Repair mailbox retries/dedup** — add retry/backoff; run dedup before rate limiting.
8. **Reduce credential scope and PII exposure** — narrow the booking token, redact calendar/log PII, harden email auth (fail closed), sanitise reply-all recipients.
