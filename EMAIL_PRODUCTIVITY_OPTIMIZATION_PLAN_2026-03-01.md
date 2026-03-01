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
- [x] Verify persistence after restart and validate no context bleed in new DM thread (config applied; restart verified)

### P0-2 Calendar operationalization
- [x] Authenticate `gog` account (Google Calendar)
- [x] Add daily `gog` auth health check in digest path
- [x] Add fallback path when `gog` unavailable (local calendar read)

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
- [x] Add state file + delta detection logic
- [x] Suppress no-change heartbeat chatter
- [x] Alert only on transitions (new/resolved/degraded)

### P1-3 Email confidence gate in production path
- [x] Added `config/email_classification_policy.json`
- [x] Added `scripts/email_confidence_gate.py`
- [x] Integrate gate into `scripts/consolidated-email-processor.sh`
- [x] Enforce draft-only for low-confidence/sensitive external threads

---

## Implementation Log
- 2026-03-01: Added idempotency guard and wired into digest/update/wrap-up scripts.
- 2026-03-01: Hardened cron delivery routing with explicit iMessage target.
- 2026-03-01: Added Ops Health Snapshot cron (4-hour interval).
- 2026-03-01: Created confidence gate + policy for safer email automation.
- 2026-03-01: Integrated confidence gate into consolidated email processor (external low-confidence/sensitive -> draft-only).
- 2026-03-01: Enabled gog auth and upgraded morning digest calendar logic (gog primary + local calendar fallback).
- 2026-03-01: Implemented HEARTBEAT state-change suppression in `scripts/heartbeat-check.sh`.

## Access Matrix (Current Verified State)

### Google Workspace (`gog`)
- `clawdianinan@gmail.com` (default): ✅ Authenticated (calendar scope available)

### Himalaya Accounts (`~/.config/himalaya/config.toml`)
- `gmail` (`clawdianinan@gmail.com`): ❌ IMAP auth failed (invalid credentials)
- `icloud` (`clawdianinan@icloud.com`): ❌ IMAP auth failed (authentication failed)
- `zoho` (`temi.kolawole@iih.ng`): ✅ IMAP+SMTP OK
- `iih_clawdia` (`clawdia.ai@iih.ng`): ✅ IMAP+SMTP OK (default account)

### Channel/Delivery Accounts
- iMessage: ✅ enabled (default + custom-1)
- WhatsApp: ✅ linked
- Telegram: ✅ configured

## Custom Skills Audit (Email/Productivity related)
- `mail`: installed
- `apple-mail-search-safe`: installed
- `himalaya-fixed`: installed
- `local-email`: installed
- `mail-attachments`: installed
- `todo-management`: installed
- `qmd`: installed
- `office-document-specialist-suite`: installed

## Open Items (Need user interaction)
1. Refresh credentials for Himalaya `gmail` and `icloud` keychain entries.
2. Confirm whether `temi.kolawole@iih.ng` and/or `clawdia.ai@iih.ng` should be primary inbound processing account for automated flows.

## Validation Checklist
- [ ] No duplicate digest/wrap-up messages across 24h
- [ ] No cron channel ambiguity errors across 24h
- [ ] Calendar section shows true events (not placeholder)
- [ ] Ops snapshot runs and delivers reliably

## Next Phase (P1.5 / P2 Immediate)
1. **Multi-account inbox normalization**
   - Add account priority order: `iih_clawdia` + `zoho` (IIH) first, then personal accounts.
   - Build account health probe output into digest (OK/DEGRADED per account).
2. **Credential repair for failed accounts**
   - Re-save `himalaya-gmail` and `himalaya-icloud` keychain secrets and re-run doctor.
3. **Skill reliability telemetry**
   - Add daily skill success report (invocations, failures, avg runtime) for mail/productivity skills.
4. **Fallback continuity**
   - If Himalaya fails, fallback to Apple Mail search skill; if both fail, produce explicit degraded-mode alert.

## Rollback Plan
- Keep prior scripts and backups.
- For idempotency rollback: remove guard calls from 3 scripts.
- For cron delivery rollback: `openclaw cron edit <id> --channel last --to current` (not recommended).
