# Memory System Optimization Plan
Date: 2026-03-01
Owner: Clawdia
Status: In Progress

## Goal
Keep markdown memory files as source of truth, while improving recall reliability and retrieval quality.

## Principles
1. Do NOT scrap `.md` memory files.
2. Treat markdown as canonical records.
3. Use indexing + health checks + fallback for resilience.
4. Keep retrieval observable and testable.

---

## Current State
- Memory files: active (`MEMORY.md` + `memory/*.md`)
- Indexing: present but can become stale
- Hybrid/vector: partially available; fallback needed
- Recall quality: inconsistent for recent operational changes

## Target Architecture
1. Canonical Store: markdown files
2. Index Layer: BM25 + optional vector index
3. Router: hybrid when healthy, keyword fallback when degraded
4. Health checks: freshness + index presence + retrieval mode
5. Daily maintenance: index update + snapshot + anomaly alert

---

## Work Packages

### M1 — Health & observability
- [x] Add `scripts/memory_health_check.py`
- [x] Add `scripts/reliability_snapshot.py` memory signal
- [ ] Add alert threshold for stale index > 24h
- [ ] Track retrieval mode changes over time

### M2 — Retrieval router
- [x] Add `scripts/memory_query_router.py`
- [x] Graceful fallback: keyword search when index degrades
- [ ] Plug router into daily/ops workflows as standard query path
- [ ] Add optional rerank step for multi-hit results

### M3 — Index freshness automation
- [ ] Trigger index refresh after daily memory maintenance
- [ ] Verify index freshness marker writeback
- [ ] Add retry logic for transient indexing failures

### M4 — Recall quality controls
- [ ] Add memory write template for significant decisions
- [ ] Add dedupe and canonicalization for repeated notes
- [ ] Add monthly memory quality review (signal vs noise)

---

## KPIs
- Index freshness: < 6h lag
- Retrieval availability: 99% (hybrid or fallback)
- Recall hit quality: > 80% relevant top-5 for operational queries
- False “no memory” responses: < 5%

## Rollback / Safety
- Markdown files remain untouched and canonical.
- If index layer fails, keyword fallback remains active.
- No destructive migration of existing memory files.
