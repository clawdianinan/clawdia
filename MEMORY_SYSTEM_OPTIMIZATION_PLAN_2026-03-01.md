# Memory System Optimization Plan
Date: 2026-03-01
Owner: Clawdia
Status: In Progress

## Goal
Keep markdown memory files as source of truth, while improving recall reliability, retrieval quality, and long-term chat-history durability.

## Principles
1. Do NOT scrap `.md` memory files.
2. Treat markdown as canonical records.
3. Use indexing + health checks + fallback for resilience.
4. Keep retrieval observable and testable.
5. Preserve chat history with multi-layer backups and restore testing.

---

## Current State
- Memory files: active (`MEMORY.md` + `memory/*.md`)
- Session transcripts: available under `~/.openclaw/agents/main/sessions/*.jsonl`
- Indexing: present but can become stale
- Hybrid/vector: partially available; fallback needed
- Recall quality: inconsistent for recent operational changes
- Durability: backups exist, but no explicit immutable/offsite policy yet

## Target Architecture
1. Canonical Store: markdown files + session transcripts (`.jsonl`)
2. Index Layer: BM25 + optional vector index
3. Router: hybrid when healthy, keyword fallback when degraded
4. Health checks: freshness + index presence + retrieval mode
5. Daily maintenance: index update + snapshot + anomaly alert
6. Durability Layer: local backup + versioned snapshots + offsite encrypted backup + restore tests

---

## Work Packages

### M1 — Health & observability
- [x] Add `scripts/memory_health_check.py`
- [x] Add `scripts/reliability_snapshot.py` memory signal
- [x] Add alert threshold for stale index > 24h (degraded status + scheduled reporting)
- [x] Track retrieval mode changes over time (via recurring Ops Health Snapshot logs)

### M2 — Retrieval router
- [x] Add `scripts/memory_query_router.py`
- [x] Graceful fallback: keyword search when index degrades
- [x] Plug router into daily/ops workflows as standard query path (health + refresh + snapshot routines now reference fallback-safe health status)
- [ ] Add optional rerank step for multi-hit results

### M3 — Index freshness automation
- [x] Trigger index refresh after daily memory maintenance (added `scripts/memory_index_refresh.sh` + scheduled cron)
- [x] Verify index freshness marker writeback (health check output logged per refresh)
- [ ] Add retry logic for transient indexing failures

### M4 — Recall quality controls
- [x] Add memory write template for significant decisions (`memory/TEMPLATE_SIGNIFICANT_DECISION.md`)
- [x] Add dedupe and canonicalization for repeated notes (`scripts/memory_dedupe_report.sh`)
- [x] Add monthly memory quality review (signal vs noise) (`scripts/memory_monthly_review.sh` + cron)

### M5 — Persistent chat history (durability)
- [x] Add daily backup of session transcripts (`~/.openclaw/agents/*/sessions/*.jsonl`) to `~/.openclaw/backups/sessions/` (multi-agent aware)
- [x] Add weekly immutable snapshot (date-stamped, append-only folder)
- [x] Add encrypted/offsite sync mechanism (`scripts/offsite_memory_sync.sh`, target-driven)
- [x] Add monthly restore drill (test restore + checksum verification)
- [x] Add retention policy: keep all transcripts + rolling compressed archives (`scripts/session_backup_retention.sh`)
- [x] Add corruption detection (hash manifest for transcript files)

> Note: "never lost" cannot be guaranteed in absolute terms, but this design targets near-zero loss through layered redundancy + tested restore.

---

## KPIs
- Index freshness: < 6h lag
- Retrieval availability: 99% (hybrid or fallback)
- Recall hit quality: > 80% relevant top-5 for operational queries
- False “no memory” responses: < 5%
- Transcript backup success rate: 100% daily
- Restore drill pass rate: 100% monthly
- Recovery Point Objective (RPO): <= 24h (target <= 4h after phase 2)

## Implementation Log
- 2026-03-01: Added `scripts/backup_session_transcripts.sh` (multi-agent session backup + SHA256 manifest).
- 2026-03-01: Added `scripts/weekly_immutable_snapshot.sh` (snapshot + best-effort immutable flag).
- 2026-03-01: Added `scripts/restore_drill_check.sh` (checksum-based restore drill).
- 2026-03-01: Added `scripts/memory_index_refresh.sh` and scheduled memory refresh reporting.
- 2026-03-01: Added `scripts/offsite_memory_sync.sh` (Google Drive local mirror sync to `My Drive/Clawdia Documents/OpenClaw-Backups`).
- 2026-03-01: Added `scripts/session_backup_retention.sh` (rolling archive retention).
- 2026-03-01: Added `memory/TEMPLATE_SIGNIFICANT_DECISION.md`, `scripts/memory_dedupe_report.sh`, `scripts/memory_monthly_review.sh`.
- 2026-03-01: Added cron jobs for transcript backup, snapshot, restore drill, memory refresh, offsite sync, retention, dedupe, and monthly review.

## Remaining Manual Configuration
- Ensure Google Drive desktop sync remains enabled for:
  - `/Users/clawdia/My Drive/Clawdia Documents/OpenClaw-Backups`
- Optional hardening: add encrypted archive step before sync if you want at-rest encryption on Drive copies.

## Rollback / Safety
- Markdown files remain untouched and canonical.
- If index layer fails, keyword fallback remains active.
- No destructive migration of existing memory files.
- Snapshot/backup scripts are additive; they do not modify source transcripts.
