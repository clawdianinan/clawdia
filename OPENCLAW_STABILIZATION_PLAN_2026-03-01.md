# OpenClaw Stabilization Plan (QMD/Qdrant + Email + Messaging)
Date: 2026-03-01
Owner: Clawdia
Status: In Progress

## Objective
Harden the recent OpenClaw upgrades so memory retrieval, email automation, and chat delivery are reliable for production use.

## Success Criteria
- No duplicate user-visible replies in iMessage for repeated/queued inbound events.
- Memory retrieval remains available with graceful fallback when vector/hybrid fails.
- Email classification is confidence-scored with safety gating for sensitive threads.
- Daily health summary surfaces memory/email/messaging status in one place.

---

## Workstreams

### WS1 — Duplicate Message Prevention
Goal: stop double replies and repeated sends from near-identical inbound events.

Tasks
- [x] Add platform-level inbound debounce + collect queue mode for iMessage.
- [ ] Add content-fingerprint dedupe guard at script/workflow level.
- [ ] Add observability log for dropped duplicates.

Progress Notes
- 2026-03-01: Applied gateway config patch:
  - `messages.inbound.debounceMs = 1200`
  - `messages.inbound.byChannel.imessage = 2000`
  - `messages.queue.mode = collect`
  - `messages.queue.debounceMs = 1800`
  - `messages.queue.byChannel.imessage = collect`

---

### WS2 — Memory Stack Hardening (QMD/Qdrant)
Goal: one canonical retrieval path with fallback and health checks.

Tasks
- [x] Create memory health-check script (index presence + recency + fallback verdict).
- [x] Create canonical memory retrieval wrapper with graceful fallback (hybrid -> keyword).
- [ ] Wire memory health check into daily maintenance cron output.
- [ ] Add alert threshold for stale/missing memory index.

Progress Notes
- 2026-03-01: Implemented `scripts/memory_health_check.py`.
- 2026-03-01: Implemented `scripts/memory_query_router.py` (fallback-first design).

---

### WS3 — Email Safety/Confidence Gating
Goal: reduce misclassification risk for sensitive (financial/legal/external) threads.

Tasks
- [x] Add confidence scoring policy file.
- [x] Add classifier helper script for confidence + sensitivity flags.
- [ ] Integrate classifier into active email processor pipeline.
- [ ] Force draft-only when confidence below threshold or sensitivity high.

Progress Notes
- 2026-03-01: Implemented `config/email_classification_policy.json`.
- 2026-03-01: Implemented `scripts/email_confidence_gate.py`.

---

### WS4 — Daily Reliability Dashboard
Goal: one daily compact status report across memory/email/messaging.

Tasks
- [x] Add daily report generator script.
- [ ] Attach to morning digest and evening wrap-up context.
- [ ] Add trend tracking (7-day pass/fail, duplicate rate, stale-index rate).

Progress Notes
- 2026-03-01: Implemented `scripts/reliability_snapshot.py`.

---

## Immediate Validation Checklist (Today)
- [ ] Confirm iMessage duplicate replies reduced after debounce patch.
- [ ] Run memory health check and verify fallback mode output.
- [ ] Run email confidence gate with sample inputs.
- [ ] Run reliability snapshot and verify report output.

## Risks
- Debounce can delay rapid-fire genuine messages slightly.
- Confidence gating without full pipeline integration is advisory until wired into send path.
- Memory router fallback preserves availability but may reduce semantic precision if vector unavailable.

## Next Actions (Execution Order)
1. Validate duplicate-message fix with live iMessage thread.
2. Integrate email confidence gate into `scripts/consolidated-email-processor.sh`.
3. Add memory health check call into daily maintenance job.
4. Wire reliability snapshot into morning digest output.
