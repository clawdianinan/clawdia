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

### 2.2 WhatsApp Outbound Restriction

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

## 10. ENVIRONMENT_GUARD (Persistent Instruction)

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
