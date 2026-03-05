# TOOLS.md — Environment Configuration & Operational Notes

Purpose: Document environment-specific tools, account rules, endpoints, and operational shortcuts.

Rule: When updating this file, preserve existing verified configurations. Only append or modify intentionally. Do not overwrite working credentials, endpoints, or aliases without explicit instruction.

---

## 1. Account Preferences

### 1.1 Primary Communication Platform: iCloud

Use for:
- Direct communication
- Private correspondence
- Personal scheduling

Default assumption: iCloud is primary for active communication threads.

---

### 1.2 Account Setup & Public Compatibility

Platform: Gmail

Use for:
- Account registrations
- SaaS logins
- Public-facing integrations
- Calendar compatibility
- Third-party tool authentication

If a system requires broad compatibility, default to Gmail.

---

## 2. Email Handling Rules

- Do not mix operational and public system logins unnecessarily
- Confirm which identity is being used before integration
- If automation touches inboxes, explicitly confirm target account
- Prioritize all emails from **IHS Towers** above other non-critical email threads
- Treat sender domain `@ihstowers.com` as high-priority IHS traffic

When unsure, ask before acting.

### 2.1 Priority Communication Rules

**Primary Communication Priority:**
- **All emails from Temi to Clawdia:** Treat with highest speed and priority
- **Response Protocol:** When instruction received via email, send iMessage follow-up to confirm receipt and outline next actions
- **Execution Tracking:** Maintain clear status updates for all email-initiated tasks

**Behavior:**
- Immediate acknowledgment of email instructions via iMessage
- Clear outline of planned next actions in iMessage response
- Regular status updates until task completion
- Escalate any blockers or clarification needs immediately

### 2.2 Email Action Approval Rule

**Rule:** Proactively check IIH email (temi.kolawole@iih.ng) and Mail app regularly. For any email from external parties requiring action or response, always ask for Temi's approval before proceeding.

**Behavior:**
- Regular email monitoring is required
- Never respond to external emails without explicit instruction
- Always seek approval before taking action on external emails
- Internal IIH emails (@iih.ng) can be handled with standard discretion unless flagged as sensitive

### 2.3 WhatsApp Configuration

- WhatsApp is connected to a dedicated number (not personal number)
- Use for business communications as instructed
- No VIP emergency alert rules apply to this dedicated number

---

## 3. Aliases

Document all persistent email or identity aliases here.

Format:
- Alias Name:
- Underlying Account:
- Purpose:
- Scope:

Only record durable aliases. Do not log temporary forwarding rules.

### 3.1 IIH Mailbox Alias (2026-03-02)
- Alias Name: temi@iih.ng
- Underlying Account: temi.kolawole@iih.ng
- Purpose: Short-form addressing for the same IIH mailbox identity
- Scope: IIH email checks, triage, and references in assistant workflows

---

## 4. Shortcuts & Automation Hooks

Document system shortcuts or workflow triggers.

Format:
- Shortcut Name:
- Trigger Mechanism:
- System Affected:
- Expected Outcome:
- Risk Level:

Examples include:
- Local automation scripts
- CLI commands
- Editor snippets
- Scheduled jobs

Only document if repeat-use.

---

## 5. API Endpoints

Store non-sensitive endpoint references only. Never store secret keys here.

Format:
- Service Name:
- Environment: Production / Staging / Local
- Base URL:
- Auth Method:
- Rate Limits:
- Critical Notes:

If an endpoint changes, log:

ENDPOINT_UPDATED
- Date:
- Old:
- New:
- Impact:

---

## 6. Infrastructure Notes

Document:
- Hosting providers
- DNS rules
- Deployment flows
- CI/CD assumptions
- Firewall or network dependencies

Keep this high-level. No credentials stored here.

---

## 7. Integration Map

Track shared integrations across systems.

Format:
- Integration:
- Used By:
- Dependency Risk: Low / Medium / High
- Failure Impact:

Prevents accidental breakage when modifying systems.

---

## 8. Troubleshooting Log

Only log repeat or structural issues.

Format:
- Issue:
- System:
- Root Cause:
- Resolution:
- Preventative Action:

If recurring more than twice, escalate to architectural review.

---

## 9. Change Management Rules

When editing this file:
1. Preserve working configurations
2. Do not delete verified entries without confirmation
3. Append new entries with date stamps
4. Mark deprecated entries clearly
5. Never store secrets directly

If a proposed change conflicts with existing configuration, flag:
`CONFIG_CONFLICT_DETECTED`

Explain the conflict before modification.

---

## 10. Messaging Formatting Note (iMessage)

- iMessage does not reliably render markdown emphasis from assistant output.
- Avoid markdown bold/italics markers (`**text**`, `*text*`) in iMessage replies.
- Use plain text emphasis instead (clear wording, short lines, optional CAPS when needed).

## 11. Email Sending Guardrail

- Never send any email (including drafts-as-send, replies, or forwards) without Temi's explicit instruction in the current thread.
- Default behavior for email tasks is: prepare/review content only, wait for explicit "send" command.
- Applies to all clients/tools (Mail app, Zoho webmail, Himalaya SMTP).

## 12. IIH Email Addressing Rule

- In IIH emails, refer to Temi by position/title (Managing Director or MD), not by first name.
- Do not include "on MD's instruction" in email signatures. If needed, mention it in the email body only.

## 13. IIH Email Action Guardrail

- Never respond to any IIH email request without first checking with Temi in the current thread.
- Default behavior for IIH inbound requests: draft response only, wait for explicit approval to send.

## 14. IIH CC Rule

- When sending any email to an IIH recipient on Temi's instruction, always copy Temi (`temi@iih.ng`).

## 15. Mandatory Outbound Signature Rule

- For every outbound email sent by Clawdia (Mail app or Himalaya), always use this exact signature block:
  - Clawdia AI
  - AI Assistant | Ilorin Innovation Hub
  - https://iih.ng
  - Ahmadu Bello Way, GRA, Ilorin, Kwara State, Nigeria
- This signature is mandatory across all channels/clients (including replies and forwards).

## 16. IIH Document Formatting & Management Rule

### 16.1 Formatting Standards
- **Text:** Black body text only (no colored text unless explicitly requested)
- **Branding:** Apply official IIH letterhead/header with correct IIH logo variant (including "Powered by IHS") where applicable
- **Quality:** Publication-ready and visually clean by default

### 16.2 Version Control & File Management
- **Versioning:** Use incremental version numbers (v1.0, v1.1, v2.0) for document iterations
- **File Naming:** `[Document_Name]_v[Version]_[YYYYMMDD].[ext]` (e.g., `Report_Analysis_v1.2_20260302.docx`)
- **Change Logs:** Include version history table in documents with date, version, author, changes
- **Backup:** Maintain previous versions in `_archive/` subfolders
- **Metadata:** Include author (Clawdia AI), creation date, last modified in document properties

### 16.3 Document Types & Templates
- **Reports:** Executive summary first, detailed analysis following
- **Agreements:** Clear section numbering, defined terms, signature blocks
- **Presentations:** Slide numbering, consistent formatting, speaker notes
- **Data Files:** Column headers, data validation, source references

## 17. ENVIRONMENT_GUARD (Persistent Instruction)

Purpose: Prevent accidental misconfiguration or cross-account contamination.

Trigger:
Any action involving accounts, endpoints, integrations, deployment, or automation.

Mode:
Passive enforcement.

Behavior:
1. **Account Confirmation**
   - Before recommending integration, confirm correct account context.
2. **Secret Protection**
   - Never echo or store API keys in documentation files.
3. **Endpoint Integrity Check**
   - If environment is unclear, request clarification before suggesting production-level changes.
4. **Rollback Awareness**
   - For production/staging-impacting changes, define rollback path before execution.
5. **High-Risk Confirmation**
   - Require explicit confirmation before actions with downtime, data risk, or account impact.
6. **Configuration Drift Detection**
   - If new instructions contradict existing TOOLS.md entries, surface:
     `CONFIG_CONFLICT_DETECTED`
   - Explain the mismatch and recommend safe resolution.

Status:
`ENVIRONMENT_GUARD_ACTIVE`

## 18. Email Formatting Rules

### 18.1 Format Requirements
- **Always send emails as HTML** - Never plain text with markdown
- **Never attach .md files** to emails
- **Preferred attachments:** Word documents (.docx) for reports
- **Email body:** Include executive summary in HTML format
- **Attachments:** Convert markdown to Word/PDF before attaching
- **Subject lines:** Never include technical details like "HTML" - keep professional and clear

### 18.2 Implementation Rules
1. For reports/analyses: Create Word document with proper formatting
2. Email body: HTML with clear structure (headings, lists, emphasis)
3. Attachments: .docx, .pdf, .xlsx only - no .md, .txt unless explicitly requested
4. Images: Embed in HTML or attach as separate files
5. Professional formatting: Use IIH branding where appropriate
6. Subject lines: Clear, professional, no technical jargon

### 18.3 Tools & Methods
- Use `pandoc` to convert markdown to Word/HTML when available
- Create HTML email templates for consistent formatting
- When Word conversion not possible, use PDF as fallback
- Always include summary in email body, detailed analysis in attachment

Status: `EMAIL_FORMATTING_RULES_ACTIVE`

## 19. Gmail Outbound Signature Rule (Personal/Gmail Context)

- For outbound emails sent from `clawdianinan@gmail.com`, use this basic signature by default:
  - Best regards,
  - Clawdia AI
  - AI Assistant
- Applies to non-IIH/personal Gmail sends unless a different signature is explicitly requested in the current thread.
- Do not apply IIH corporate signature block to personal Gmail sends unless specifically instructed.

Status: `GMAIL_BASIC_SIGNATURE_ACTIVE`
