# BUILD.md — Engineering Mode of Operation

Purpose: Define how work moves from idea to shipped output with speed, structure, and quality.

## 1) Build Cycle (Default)

1. Define outcome
- What must be true when this is done?
- What does success look like in production or in handoff?

2. Scope the minimum shippable slice
- Separate must-have vs nice-to-have.
- Keep first delivery narrow and testable.

3. Design before coding
- Confirm module boundaries.
- Confirm data/auth/billing implications.
- Identify migration and rollback path.

4. Execute in short tracked steps
- Break into clear tasks with owners/dependencies.
- Report progress in grouped checkbox updates.

5. Validate and ship
- Test functional behavior and edge cases.
- Confirm no cross-system regressions.
- Package release notes + next actions.

---

## 2) Delivery Cadence

## 2.1 Daily Sprint Rhythm
- Sprint planning: 10–15 mins
- Execution block(s): deep work windows
- Midpoint check: blockers + re-sequencing
- End-of-day close: shipped, pending, blocked, next

## 2.2 Update Format (Required)
- Use grouped sections
- Use checkbox status style
- Keep updates concise and decision-oriented

Example:
- ✅ Completed
- ☐ In progress
- ⚠️ Blocked (reason + unblock path)

---

## 3) PRD → Build Flow

1. Objective
2. Constraints
3. Scope (v1)
4. Architecture sketch
5. Task breakdown
6. Risks + mitigations
7. Definition of done

---

## 4) Definition of Done

A task is done only when:
- Functionality works as specified
- Integration impact is checked
- Critical edge cases are tested
- Documentation/notes are updated
- Handoff is clear (what changed, what’s next)

---

## 5) Escalation Rules During Build

Escalate only for:
- Missing credentials/auth approval
- Irreversible or high-risk action
- Conflicting product decisions
- Unknown dependency that blocks execution

For everything else: try alternative paths and continue.

---

## 6) Architecture Discipline

Before adding new components:
- Check if module already exists
- Check duplication risk
- Prefer shared abstractions
- Flag technical debt and migration cost early

Keep solutions:
- Auth-first
- Version-aware
- Migration-safe
- Reusable where practical

---

## 7) Shipping Checklist

- ☐ Scope locked for this iteration
- ☐ Dependencies resolved
- ☐ Core path tested
- ☐ Regression risks reviewed
- ☐ Rollback path known
- ☐ Output packaged for stakeholder review
- ☐ Next-step queue prepared
