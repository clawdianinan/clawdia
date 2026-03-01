# Email & Productivity Optimization Plan (Phase 0–1)
Date: 2026-03-01
Owner: Clawdia
Status: In Progress (Execution started)

## Scope
Implement P0 and P1 improvements from the audit for:
- email reliability
- delivery dedupe
- calendar operability
- cron delivery hardening
- health monitoring

## Baseline (from audit)
- Email design: 8/10
- Automation reliability: 7/10
- Calendar integration: 4/10
- Fallback continuity: 6.5/10
- Document tooling: 8/10
- Overall: 7/10

---

## Phase 0 (High impact, low risk)

### P0-1 DM session isolation
- [x] Set `session.dmScope=per-channel-peer`
- [ ] Verify persistence after restart and validate no context bleed in new DM thread

### P0-2 Calendar operationalization
- [ ] Authenticate `gog` account (Google Calendar)
- [ ] Add daily `gog` auth health check in digest path
- [ ] Add fallback path when `gog` unavailable (local calendar read)

### P0-3 Outbound idempotency
- [x] Added script `scripts/message_idempotency_guard.sh`
- [x] Applied to `morning_digest.sh`
- [x] Applied to `regular_update.sh`
- [x] Applied to `evening_wrapup.sh`
- [ ] Validate with live duplicate-trigger scenario

### P0-4 Explicit delivery channel for cron jobs
- [x] Morning Digest: channel+to set explicitly
- [x] Evening Wrap-up: channel+to set explicitly
- [x] Daily Memory Maintenance: channel+to set explicitly
- [x] Daily Memory Backup: channel+to set explicitly
- [ ] Weekly maintenance: set explicit delivery policy or keep intentionally silent

---

## Phase 1 (Reliability + cost)

### P1-1 Unified Ops Health Snapshot
- [x] Added script `scripts/reliability_snapshot.py`
- [x] Added cron job: `Ops Health Snapshot` (every 4h)
- [ ] Validate first successful run and delivery quality

### P1-2 HEARTBEAT state-change mode
- [ ] Add state file + delta detection logic
- [ ] Suppress no-change heartbeat chatter
- [ ] Alert only on transitions (new/resolved/degraded)

### P1-3 Email confidence gate in production path
- [x] Added `config/email_classification_policy.json`
- [x] Added `scripts/email_confidence_gate.py`
- [ ] Integrate gate into `scripts/consolidated-email-processor.sh`
- [ ] Enforce draft-only for low-confidence/sensitive external threads

---

## Implementation Log
- 2026-03-01: Added idempotency guard and wired into digest/update/wrap-up scripts.
- 2026-03-01: Hardened cron delivery routing with explicit iMessage target.
- 2026-03-01: Added Ops Health Snapshot cron (4-hour interval).
- 2026-03-01: Created confidence gate + policy for safer email automation.

## Open Items (Need user interaction)
1. `gog` OAuth login (browser/device consent required).

## Validation Checklist
- [ ] No duplicate digest/wrap-up messages across 24h
- [ ] No cron channel ambiguity errors across 24h
- [ ] Calendar section shows true events (not placeholder)
- [ ] Ops snapshot runs and delivers reliably

## Rollback Plan
- Keep prior scripts and backups.
- For idempotency rollback: remove guard calls from 3 scripts.
- For cron delivery rollback: `openclaw cron edit <id> --channel last --to current` (not recommended).
