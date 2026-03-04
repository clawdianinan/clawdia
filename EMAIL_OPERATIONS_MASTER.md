# EMAIL_OPERATIONS_MASTER.md

Single source of truth for system-wide email operations across all models/agents.

Last updated: 2026-03-04

---

## 1) Scope

This is GLOBAL (not IIH-only).
Use this for:
- IIH operations
- Personal/admin work
- Non-IIH projects
- Cross-account email research and attachment handling

For context-specific policy overlays, also read:
- `EMAIL_PROFILE_IIH.md`
- `EMAIL_PROFILE_GENERAL.md`

---

## 2) Core Operating Principles (All Contexts)

1. Never send email without explicit instruction in the active thread.
2. Always select account context first (before searching/saving/drafting).
3. Keep read/search/extract auditable (cite subject/date/filepath in completion updates).
4. Use tool fallback chain when one method fails.
5. Keep active working files out of archive folders.

---

## 3) Account Directory + Purpose

### Temi accounts
- `temi@iih.ng` — Primary IIH professional mailbox
- `temi.kolawole@iih.ng` — Alternate IIH mailbox (same operational context)
- `temikolawole@icloud.com` — Personal iCloud
- `temikolawole@gmail.com` — Personal Gmail

### Clawdia accounts
- `clawdia.ai@iih.ng` — IIH assistant identity (official IIH work)
- `clawdianinan@icloud.com` — Primary direct communication
- `clawdianinan@gmail.com` — Registrations/integrations/public compatibility

---

## 4) Decision Tree: Pick the Right Profile First

1. Is this IIH/institutional work?
   - Yes -> apply `EMAIL_PROFILE_IIH.md`
   - No -> apply `EMAIL_PROFILE_GENERAL.md`

2. Is action outbound (reply/send/forward)?
   - Yes -> explicit approval required first
   - No -> proceed with read/search/extract

3. Is attachment handling required?
   - Yes -> use attachment workflow in Section 7

4. Is primary tool failing?
   - Yes -> follow fallback matrix in Section 6

---

## 5) Standard Tooling Order (Read/Search/Extract)

Primary path:
1. `fruitmail` (search/sender/body)
2. AppleScript (Mail attachment enumeration)
3. Direct Mail store extraction (`~/Library/Mail/V10/.../Data/Attachments`)

Secondary path:
4. `himalaya` (IMAP checks where configured)
5. `gog` (Google-account scope workflows)

---

## 6) Fallback Matrix (Required)

- If `fruitmail` fails:
  - Use AppleScript query + Mail store file lookup.
- If AppleScript save is inconsistent:
  - Do not rely on save; copy directly from Mail store paths.
- If attachment filename is unknown:
  - Enumerate attachment names first, then `find` exact file.
- If one mailbox is inaccessible:
  - Check mirrored/forwarded copy in paired mailbox (`temi.kolawole@iih.ng` <-> `clawdia.ai@iih.ng`).
- If local Mail DB appears stale:
  - Re-run search with broader date window and verify in alternate tool.

---

## 7) Attachment Handling Standard (Global)

Workflow:
1. Identify target email(s) via subject/sender/date.
2. Validate context by reading body snippet.
3. Enumerate attachment names.
4. Locate files in Mail store.
5. Copy to correct active destination folder.
6. Verify destination listing.
7. Report completion with evidence.

Folder discipline:
- Active working/source files -> active project/report folders
- Archived materials only -> archive folders

For IIH monthly source reports, default active path:
- `/Users/clawdia/My Drive/Clawdia Documents/IIH/Reports/Latest-Monthly-Submissions/<YYYY-MM Source Reports>`

---

## 8) Cross-Context Safety Rules

- Never store secrets or credentials in docs/logs.
- Never mix IIH and personal context in one outbound draft without explicit instruction.
- Never assume ownership from sender identity; use request context.
- For high-risk changes (external send, sensitive financial/compliance content), reconfirm scope.

---

## 9) Reference Docs

- Command-level runbook: `EMAIL_ACCESS_RUNBOOK.md`
- IIH-specific policy overlay: `EMAIL_PROFILE_IIH.md`
- General/non-IIH policy overlay: `EMAIL_PROFILE_GENERAL.md`

---

## 10) Special Skill Recommendation

Yes — create a dedicated skill to enforce consistency.

Proposed skill name: `email-ops`

Why:
- Reduces model drift in account selection and fallback handling
- Standardizes attachment extraction + destination policy
- Enforces send-approval checks before outbound actions
- Gives one reusable protocol for IIH and non-IIH workflows

Use profiles inside the skill:
- `mode=iih`
- `mode=general`
