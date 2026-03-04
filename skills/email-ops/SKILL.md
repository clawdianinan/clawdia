---
name: email-ops
description: System-wide email operations protocol for read/search/extract, attachment handling, account-context selection, and failover methods across IIH and non-IIH work. Use when handling any email task (triage, research, attachment retrieval, report-source collection) and when a tool fails and fallback is needed.
---

# Email Ops

Use this skill as the default for all email tasks.

## 1) Select operating profile first

Before any action, classify request:

1. IIH/institutional -> apply rules in `references/profile-iih.md`
2. Non-IIH/personal/general -> apply rules in `references/profile-general.md`

If unclear, ask which context to use.

## 2) Non-negotiables

- Never send email without explicit instruction in current thread.
- Do not mix account contexts unless explicitly required.
- Keep completion updates auditable (subject/date/paths/files).

## 3) Tool execution order

1. `fruitmail` (search/sender/body)
2. AppleScript via Mail app (attachment listing)
3. Direct Mail store extraction (`~/Library/Mail/V10/.../Data/Attachments`)
4. `himalaya` (when configured)
5. `gog` (Google account scope)

## 4) Fallbacks (required)

- `fruitmail` fails -> use AppleScript + Mail store find/copy.
- AppleScript `save` unreliable -> copy files directly from Mail store paths.
- Unknown attachment filename -> list attachment names first, then `find` exact file.
- One mailbox inaccessible -> check forwarded/mirrored copy in paired mailbox.

## 5) Attachment workflow

1. Find target mail by subject/sender/date.
2. Read body for relevance.
3. Enumerate attachment names.
4. Locate file in Mail store.
5. Copy to correct active destination folder.
6. Verify destination listing.
7. Report with evidence.

For command examples and exact sequence, read `references/quickstart.md`.

## 6) Destination discipline

- Active work files -> active project/report folders.
- Archive folders -> archived documents only.
- For IIH monthly report sources, use monthly source folder under:
  `IIH/Reports/Latest-Monthly-Submissions/<YYYY-MM Source Reports>`

## 7) Cross-reference master docs

For workspace-specific policy source of truth:
- `EMAIL_OPERATIONS_MASTER.md`
- `EMAIL_ACCESS_RUNBOOK.md`
