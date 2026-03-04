# Innovation App Research Plan (IIH as First Client)

Date: 2026-03-04
Owner: Clawdia (main) + delegated research inputs

## Objective
Build evidence-backed requirements for an innovation/program operations app that fits IIH workflows across:
1) Partner-led programs
2) In-house programs
3) Hybrid co-delivery programs

## New System Update: Email Ops Skill (Mandatory for Research Email Work)

A dedicated system-wide skill now exists:
- `skills/email-ops/SKILL.md`

Use it for all research email retrieval/triage/extraction so models do not drift.

### How to use in this research
1. Classify context first:
   - IIH -> apply `EMAIL_PROFILE_IIH.md`
   - Non-IIH/general -> apply `EMAIL_PROFILE_GENERAL.md`
2. Execute retrieval in standard order:
   - fruitmail -> AppleScript attachment listing -> Mail store extraction
3. Apply fallback if tool fails (defined in skill/master doc).
4. Save active source attachments to active folders (not archive).
5. Log evidence in findings: subject, date, sender, attachment filename/path.

## Source of Truth Docs (Email)
- `EMAIL_OPERATIONS_MASTER.md` (global policy + fallback + automation integration)
- `EMAIL_ACCESS_RUNBOOK.md` (command-level steps)
- `EMAIL_PROFILE_IIH.md` (IIH policy overlay)
- `EMAIL_PROFILE_GENERAL.md` (general overlay)

## Research Workstreams
1. Program evidence extraction from email threads + attachments
2. Program classification (partner-led/in-house/hybrid)
3. Workflow mapping (intake -> planning -> execution -> reporting -> governance)
4. MVP schema and permission model for IIH first-client deployment

## Immediate Execution Notes
- Use `email-ops` skill as default for all email-based research tasks.
- Do not create parallel email process rules in subagent notes/scripts.
- Any script automation should reference master docs (no duplicate policy logic).
