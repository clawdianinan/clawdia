# Errors Log

Non-obvious command failures, tool/API issues, exceptions, and recurring operational problems.

**Areas**: frontend | backend | infra | tests | docs | config
**Statuses**: pending | in_progress | resolved | wont_fix | promoted

## When to log here

Use this file when the failure is worth remembering, not for every routine error.

Good candidates:
- required real debugging or investigation
- likely to recur
- revealed an environment or tooling gotcha
- should influence future troubleshooting steps

## Entry template

```markdown
## [ERR-YYYYMMDD-XXX] error-name

**Logged**: ISO-8601 timestamp
**Priority**: low | medium | high | critical
**Status**: pending
**Area**: frontend | backend | infra | tests | docs | config

### Summary
One-line description of what failed

### Error
```
Raw error message or representative output
```

## [ERR-20260315-001] context-overflow-prompt-too-large

**Logged**: 2026-03-15T00:31:00+01:00
**Priority**: high
**Status**: pending
**Area**: config

### Summary
Session failures occurred when prompt/context exceeded model limits.

### Error
```
prompt too large for the model
```

### Context
Large accumulated conversation + tool output caused context overflow and degraded delivery reliability.

### Suggested Fix
Use context compaction strategies early (`/new`, `/reset`, compact summaries, scoped snippets), and reduce tool-output bloat before long multi-step runs.

### Metadata
- Reproducible: yes
- Related Files: LEARNING.md
- See Also: LRN-20260315-001

---

### Context
What command, tool, API, or workflow was involved

### Suggested Fix
What to try next time or how to prevent recurrence

### Metadata
- Reproducible: yes | no | unknown
- Related Files: path/to/file.ext
- See Also: ERR-20260313-001

---
```
