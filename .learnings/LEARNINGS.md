# Learnings Log

Corrections, knowledge gaps, best practices, and durable project conventions.

**Categories**: correction | knowledge_gap | best_practice | insight
**Areas**: frontend | backend | infra | tests | docs | config
**Statuses**: pending | in_progress | resolved | wont_fix | promoted | promoted_to_skill

## When to log here

Use this file when a lesson should change future behaviour.

Examples:
- the user corrected a wrong assumption
- a project convention was discovered
- a workaround or prevention rule emerged from debugging
- a better workflow or tool usage pattern was identified

## Entry template

```markdown
## [LRN-YYYYMMDD-XXX] category

**Logged**: ISO-8601 timestamp
**Priority**: low | medium | high | critical
**Status**: pending
**Area**: frontend | backend | infra | tests | docs | config

### Summary
One-line summary of the learning

### Details
What happened, what was wrong or surprising, and what is now known to be true

### Suggested Action
Specific prevention rule, fix, or workflow change

### Metadata
- Source: conversation | error | user_feedback | docs | simplify-and-harden
- Related Files: path/to/file.ext
- Tags: tag1, tag2
- See Also: LRN-20260313-001
- Pattern-Key: stable.pattern.key
- Recurrence-Count: 1
- First-Seen: 2026-03-13
- Last-Seen: 2026-03-13

---
```

## Promotion fields

When the learning becomes durable project memory:

```markdown
**Status**: promoted
**Promoted**: CLAUDE.md
```

When it becomes a reusable skill:

```markdown
**Status**: promoted_to_skill
**Skill-Path**: skills/skill-name
```

## [LRN-20260315-001] best_practice

**Logged**: 2026-03-15T00:31:00+01:00
**Priority**: high
**Status**: pending
**Area**: config

### Summary
Merged legacy `LEARNING.md` operational rules into the new `.learnings` system as durable guidance.

### Details
Legacy learnings included channel routing rules, execution reliability checkpoints, and workflow guardrails. To avoid split-brain memory, these were migrated into structured `.learnings` entries and linked to existing system files (`AGENTS.md`, `TOOLS.md`, `SOUL.md`) where applicable.

### Suggested Action
Use `.learnings/*` as the single active capture system for new lessons; treat `LEARNING.md` as legacy source material.

### Metadata
- Source: docs
- Related Files: LEARNING.md, .learnings/LEARNINGS.md, AGENTS.md, TOOLS.md, SOUL.md
- Tags: migration, self-improvement, memory-hygiene
- Pattern-Key: learning.system.unification
- Recurrence-Count: 1
- First-Seen: 2026-03-15
- Last-Seen: 2026-03-15

---

## [LRN-20260315-002] best_practice

**Logged**: 2026-03-15T00:31:00+01:00
**Priority**: high
**Status**: pending
**Area**: docs

### Summary
Delegated-task updates must include evidence-backed completion status before declaring done.

### Details
A prior failure mode was premature success reporting in delegated runs. Durable rule: only report completion when one of these exists — explicit completion artifacts, explicit sub-agent completion, or checkpoint proof with file-level evidence.

### Suggested Action
Apply evidence-first status checks in all delegated workflows and keep update format consistent (assigned agent, done, remaining, blockers, next check).

### Metadata
- Source: docs
- Related Files: LEARNING.md, AGENTS.md
- Tags: delegation, reliability, reporting
- Pattern-Key: delegation.completion.evidence_gate
- Recurrence-Count: 1
- First-Seen: 2026-03-15
- Last-Seen: 2026-03-15

---
