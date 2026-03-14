# Feature Requests

Missing capabilities or recurring workflow frictions that should become features, scripts, or skills.

**Areas**: frontend | backend | infra | tests | docs | config
**Statuses**: pending | in_progress | resolved | wont_fix | promoted

## When to log here

Use this file when the user asks for something the current workflow or tooling cannot yet do well.

Examples:
- a missing export format
- a repeated manual step that should be automated
- a capability gap that keeps surfacing across sessions

## Entry template

```markdown
## [FEAT-YYYYMMDD-XXX] capability-name

**Logged**: ISO-8601 timestamp
**Priority**: low | medium | high | critical
**Status**: pending
**Area**: frontend | backend | infra | tests | docs | config

### Requested Capability
What the user wanted to do

### Summary
One-line summary of the request

### User Context
Why the capability matters

### Complexity Estimate
simple | medium | complex

### Suggested Implementation
Concrete starting point for building it

### Metadata
- Frequency: first_time | recurring
- Related Features: existing-feature-name

---
```

## [FEAT-20260315-001] context-manager-skill

**Logged**: 2026-03-15T00:31:00+01:00
**Priority**: high
**Status**: pending
**Area**: config

### Requested Capability
Intelligent context compression system that preserves critical memory while preventing token overflow.

### Summary
Need a `context-manager` capability for model-aware history compaction and tool-output bloat control.

### User Context
Long-running operational sessions can exceed context limits, causing failures and delivery interruptions.

### Complexity Estimate
medium

### Suggested Implementation
Create/maintain a `context-manager` skill with importance scoring, model-aware token thresholds, summary checkpoints, and optional `/compact` workflow integration.

### Metadata
- Frequency: recurring
- Related Features: self-improvement, session-management

---
