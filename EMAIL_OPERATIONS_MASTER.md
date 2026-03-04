# EMAIL_OPERATIONS_MASTER.md

Single source of truth for email operations across models/agents.

Last updated: 2026-03-04

## 1) Objectives
- Keep all email handling consistent across models.
- Prevent account mixups.
- Preserve prior operating rules (approval, formatting, signature, priority routing).
- Provide fallback methods when one tool fails.

## 2) Accounts and Purpose Map

User accounts (Temi)
- temi@iih.ng: Primary IIH professional mailbox.
- temi.kolawole@iih.ng: Alternate IIH mailbox (same operational context).
- temikolawole@icloud.com: Personal iCloud.
- temikolawole@gmail.com: Personal Gmail.

Assistant accounts (Clawdia)
- clawdia.ai@iih.ng: Official IIH assistant identity for IIH matters.
- clawdianinan@icloud.com: Primary communication channel.
- clawdianinan@gmail.com: Registrations/integrations and public compatibility.

Operational preference rules
- IIH work: default to IIH mailboxes.
- Public integration compatibility: prefer Gmail context.
- Do not mix account contexts without explicit need.

## 3) Non-negotiable Guardrails

Approvals and sending
- Never send any email without Temi’s explicit instruction in current thread.
- For IIH inbound requests, draft/review only until explicit send approval.
- For external-party emails requiring action, ask Temi before responding.

IIH composition rules
- Address Temi by title (Managing Director / MD), not first name, in IIH emails.
- Always CC temi@iih.ng on IIH outbound emails sent on instruction.
- Mandatory outbound signature block:
  Clawdia AI
  AI Assistant | Ilorin Innovation Hub
  https://iih.ng
  Ahmadu Bello Way, GRA, Ilorin, Kwara State, Nigeria

Formatting rules
- Send as HTML when sending is authorized.
- Never attach .md files to email.
- Prefer .docx/.pdf/.xlsx attachments.
- Include executive summary in email body for reports.

Priority rules
- IHS Towers emails/domains are highest priority and escalated immediately.
- Time-sensitive (<24h) items remain in urgent reminders until resolved.

## 4) Tool Order and Fallback Matrix

Primary read/search path (Apple Mail local)
1) fruitmail search/sender/body (fast metadata + body access)
2) AppleScript via Mail app for attachment listing
3) Direct file extraction from Mail store: ~/Library/Mail/V10/.../Data/Attachments

Secondary path
4) himalaya (IMAP/SMTP CLI) for mailbox checks where configured
5) gog gmail commands for Google account scopes where relevant

If one tool fails
- fruitmail fails: use AppleScript query + Mail store path find/copy
- AppleScript save is inconsistent: skip save, copy files directly from Mail store
- Mail store filename unknown: enumerate attachment names first, then find exact file
- One mailbox inaccessible: check forwarded copy in paired mailbox (temi.kolawole@iih.ng <-> clawdia.ai@iih.ng)

## 5) Attachment Handling Standard

Canonical active monthly source folder
- /Users/clawdia/My Drive/Clawdia Documents/IIH/Reports/Latest-Monthly-Submissions/<YYYY-MM Source Reports>

Archive rule
- IIH/Archive is for archived documents only (not active monthly source collection).

Attachment workflow
1) Find target email(s) with subject/sender/date filters.
2) Read body for context and ensure report relevance.
3) List attachment names.
4) Locate attachment files in Mail store.
5) Copy to active monthly source folder.
6) Verify destination listing and filenames.
7) Report completion with evidence (subject/date/file names/paths).

## 6) Quick Commands

- fruitmail search --days 7 --limit 30
- fruitmail search --subject "REQUEST FOR STATEMENT" --days 7 --limit 20
- fruitmail sender "zumah" --limit 50
- fruitmail body <id>
- osascript (Mail attachment listing)
- find ~/Library/Mail/V10 -type f -name "*keyword*" 2>/dev/null | head
- mkdir -p "<monthly-source-folder>"
- cp -f "<mail-store-file>" "<monthly-source-folder>/"
- ls -la "<monthly-source-folder>"

## 7) Consolidation Notes

This file consolidates email-related rules previously spread across:
- TOOLS.md (email guardrails, formatting, account preferences)
- IDENTITY.md (assistant account purposes)
- USER.md (Temi account map)
- EMAIL_ACCESS_RUNBOOK.md (tooling execution details)

Use this master first, then EMAIL_ACCESS_RUNBOOK.md for command-level execution.

## 8) Should there be a dedicated skill?

Recommendation: Yes, useful if email operations will be repeated by many models.

Proposed skill: "iih-email-ops"
- Purpose: enforce account context, search strategy, attachment extraction, and guardrails.
- Includes: fallback matrix, destination-folder policy, send-approval checks, and completion report template.
- Benefit: reduces model drift and repeated mistakes.

When to create now
- Create immediately if multiple models/subagents will keep running email research + report assembly.
- Defer if this remains occasional and current runbook usage is sufficient.
