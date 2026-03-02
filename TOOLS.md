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

### 2.1 VIP Alert Rules

WhatsApp VIP contacts:
- HE
- Darwish
- Oladepo

Behavior:
- Trigger immediate emergency escalation when any VIP contact sends a message
- Use emergency format in HEARTBEAT rules
- Do not batch VIP alerts into normal periodic summaries

### 2.2 Email Action Approval Rule

**Rule:** Proactively check IIH email (temi.kolawole@iih.ng) and Mail app regularly. For any email from external parties requiring action or response, always ask for Temi's approval before proceeding.

**Behavior:**
- Regular email monitoring is required
- Never respond to external emails without explicit instruction
- Always seek approval before taking action on external emails
- Internal IIH emails (@iih.ng) can be handled with standard discretion unless flagged as sensitive

### 2.3 WhatsApp Outbound Restriction

- Do not respond to anyone on WhatsApp.
- Keep WhatsApp disconnected unless explicitly re-enabled by Temi.

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

## 16. IIH Document Formatting Rule

- In all IIH documents prepared by Clawdia, body text must be black (no colored text unless explicitly requested).
- Apply official IIH letterhead/header with the correct IIH logo variant (including "Powered by IHS") where applicable.
- Keep outputs publication-ready and visually clean by default.

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
