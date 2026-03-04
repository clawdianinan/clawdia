# IIH Monthly Report Process → OpenClaw Skill Conversion Plan

Date: 2026-03-04
Owner: Clawdia (orchestrator)

## 1) Objective
Convert `MONTHLY_REPORT_PROCESS.md` into a reusable OpenClaw skill that can:
1. Trigger the monthly reporting cycle on schedule
2. Track departmental submissions and financial checklist gates
3. Draft reminders/escalations automatically
4. Compile a standardized monthly report draft for MD review
5. Enforce IIH communication and approval guardrails

## 2) Scope
In scope:
- Departmental intake tracking (Programs, Finance, Admin, HR, Facility, IT/Marketing)
- Deadline logic and reminders (Day 3/5/7/10/15/20/25)
- Financial-template gate checks
- Report assembly template + QA checklist
- Handoff package to MD (review-ready, no unauthorized sending)

Out of scope (v1):
- Auto-sending external emails without approval
- Direct accounting system writebacks
- Full BI dashboards

## 3) Skill Design
Skill name: `iih-monthly-report-orchestrator`

Proposed structure:
- `skills/iih-monthly-report-orchestrator/SKILL.md`
- `skills/iih-monthly-report-orchestrator/references/monthly-process.md`
- `skills/iih-monthly-report-orchestrator/references/report-template.md`
- `skills/iih-monthly-report-orchestrator/references/department-checklists.md`
- `skills/iih-monthly-report-orchestrator/references/qa-gates.md`
- `skills/iih-monthly-report-orchestrator/scripts/build_status_table.sh`
- `skills/iih-monthly-report-orchestrator/scripts/generate_report_skeleton.py`

## 4) Workflow Mapping (from current process)
Phase A — Intake monitoring
- Day 1–3: detect submissions, mark received/missing
- Day 5: first reminder to missing departments (copy MD)
- Day 7: second urgent reminder (copy MD)

Phase B — Finance gate management
- Day 10: all source docs received
- Day 15: validation 100% complete
- Day 20: IHS template population complete

Phase C — Compilation
- Day 25: compile report sections + executive summary + conclusion
- Generate MD review bundle (draft report + issue list + missing items)

## 5) Guardrails (must enforce)
- Never send external emails without explicit instruction in-thread
- For IIH requests, draft first; await approval before send
- Always CC `temi@iih.ng` for IIH outbound where applicable
- Use mandatory IIH signature block for outbound emails

## 6) Data Model (v1 lightweight)
Status entities:
- `department_submission_status`
- `financial_checklist_status`
- `report_assembly_status`
- `risk_flags` (missing docs, deadline breach, data inconsistency)

## 7) Deliverables
1. New skill folder + SKILL.md
2. Reference docs for process, templates, QA gates
3. Two helper scripts (status table, report skeleton)
4. Test run on one reporting month
5. Operator runbook (inside SKILL.md only, no extra docs)

## 8) Implementation Plan (agent routing)
1. Shuri: translate process + checklists into structured references and QA gates
2. Trinity: implement scripts + validate deterministic outputs
3. Ebun: polish narrative sections (Executive Summary/Conclusion templates)
4. Main (Clawdia): final integration + guardrail validation + sign-off

## 9) Success Criteria
- <10 minutes to produce monthly status snapshot
- All gate dates visible with pass/fail status
- One-command generation of report skeleton
- Zero unauthorized outbound sends
- MD receives clear review-ready draft and unresolved issues list

## 10) Immediate next action
Start skill scaffolding using the skill-creator flow and map `MONTHLY_REPORT_PROCESS.md` into references + gates first.

---

## 11) Expanded Skill Blueprint (Implementation-Ready)

### 11.0 Addressbook/Directory Requirement (NEW)
The skill must maintain a persistent sender directory to identify which staff member submits each departmental report.

Required file:
- `reports_status/addressbook/report_senders.json`

Required fields per entry:
- `department`
- `staffName`
- `primaryEmail`
- `alternateEmails[]`
- `expectedSubjectPatterns[]`
- `lastSeenAt`
- `confidenceScore` (0-1)
- `status` (`active|needs_review`)

Behavior:
1. On each monthly cycle, classify incoming report emails against this addressbook.
2. If matched, mark submission to the mapped department automatically.
3. If unmatched, add a candidate entry with `needs_review` status.
4. Support multiple approved senders per department (primary + delegates, e.g., Programs).
5. Do not auto-reassign canonical sender mapping without explicit confirmation.
6. Keep a monthly snapshot in `reports_status/<YYYY-MM>/sender_match_log.json`.

### 11.1 Trigger Phrases (for SKILL.md description)
Use this skill when the user asks to:
- prepare/compile IIH monthly report,
- track monthly departmental submissions,
- send reminder/escalation drafts for missing monthly reports,
- integrate finance template outputs into monthly report,
- generate MD review pack for IHS submission.

### 11.2 Inputs
Required:
- Reporting month (e.g., February 2026)
- Current business day in cycle
- Department submission states (received/missing)
- Financial checklist status and template completion status

Optional:
- Prior month report (for continuity section)
- MD office updates for Section 3.6
- Last unresolved action list

### 11.3 Outputs
Primary outputs:
1. `Reports/IIH_Monthly_Report_<YYYY-MM>_Draft_v1.0.md`
2. `Reports/IIH_Monthly_Report_<YYYY-MM>_MD_Review_Pack_v1.0.md`
3. `Reports/IIH_Monthly_Report_<YYYY-MM>_Missing_Items_v1.0.md`

Operational outputs:
1. `reports_status/<YYYY-MM>/submission_status.json`
2. `reports_status/<YYYY-MM>/financial_gates.json`
3. `reports_status/<YYYY-MM>/risk_flags.json`
4. `reports_status/<YYYY-MM>/activity_log.md`

### 11.4 Folder Layout (inside skill)
- `skills/iih-monthly-report-orchestrator/SKILL.md`
- `skills/iih-monthly-report-orchestrator/references/monthly-process.md`
- `skills/iih-monthly-report-orchestrator/references/department-checklists.md`
- `skills/iih-monthly-report-orchestrator/references/financial-gates.md`
- `skills/iih-monthly-report-orchestrator/references/report-structure-template.md`
- `skills/iih-monthly-report-orchestrator/references/email-templates.md`
- `skills/iih-monthly-report-orchestrator/references/qa-checklist.md`
- `skills/iih-monthly-report-orchestrator/scripts/build_status_table.sh`
- `skills/iih-monthly-report-orchestrator/scripts/render_report_skeleton.py`
- `skills/iih-monthly-report-orchestrator/scripts/generate_reminder_draft.py`
- `skills/iih-monthly-report-orchestrator/scripts/validate_gate_state.py`

---

## 12) State Machine (Monthly Cycle)

### 12.1 States
- `INIT` → cycle opened
- `INTAKE_IN_PROGRESS` → day 1–7 submissions/reminders
- `FINANCE_COLLECTION` → day 1–10 financial docs collection
- `FINANCE_VALIDATION` → day 11–15 validation
- `TEMPLATE_POPULATION` → day 16–20 IHS template population
- `REPORT_ASSEMBLY` → day 21–25 drafting and integration
- `MD_REVIEW_READY` → pack generated
- `CLOSED` → approved/finalized

### 12.2 Transition Rules
- Cannot enter `TEMPLATE_POPULATION` unless financial docs are complete.
- Cannot enter `REPORT_ASSEMBLY` unless `validate_gate_state.py` returns pass for day-20 gate.
- Cannot enter `CLOSED` unless unresolved issues list is empty or explicitly waived by MD.

---

## 13) Data Contract (JSON)

### 13.1 `submission_status.json`
```json
{
  "reportMonth": "2026-02",
  "departments": {
    "programs": {"owner": "Adebola Oladipo", "status": "received", "receivedAt": "2026-03-03T10:15:00+01:00"},
    "finance": {"owner": "Khadijat Bello", "status": "pending", "receivedAt": null},
    "admin": {"owner": "Maureen", "status": "received", "receivedAt": "2026-03-02T16:20:00+01:00"},
    "hr": {"owner": "Sinachi Onuchukwu", "status": "pending", "receivedAt": null},
    "facility": {"owner": "Kamil Ahmed", "status": "pending", "receivedAt": null},
    "it_marketing": {"owner": "Nas", "status": "received", "receivedAt": "2026-03-03T11:05:00+01:00"}
  }
}
```

### 13.2 `financial_gates.json`
```json
{
  "reportMonth": "2026-02",
  "gate10_documents_received": false,
  "gate15_validation_complete": false,
  "gate20_template_populated": false,
  "lastUpdated": "2026-03-04T01:00:00+01:00"
}
```

### 13.3 `risk_flags.json`
```json
{
  "reportMonth": "2026-02",
  "risks": [
    {"code": "MISSING_DEPARTMENT_SUBMISSION", "severity": "high", "department": "finance"},
    {"code": "FINANCIAL_GATE_DELAY", "severity": "high", "gate": "gate10_documents_received"}
  ]
}
```

---

## 14) Reminder & Escalation Logic

### 14.1 Reminder Cadence
- Day 5: first reminder for missing departments
- Day 7: second reminder (urgent)
- Day 10: finance-specific escalation if source docs incomplete

### 14.2 Message Policy
- Generate draft only by default.
- Send only after explicit instruction in current thread.
- For IIH outbound, copy `temi@iih.ng` where required.

### 14.3 Draft Naming
- `drafts/reminder_day5_<dept>_<YYYY-MM>.md`
- `drafts/reminder_day7_<dept>_<YYYY-MM>.md`
- `drafts/finance_escalation_day10_<YYYY-MM>.md`

---

## 15) QA / Acceptance Checks

### 15.1 Structural QA
- All mandatory report sections present (1–4 + 3.1–3.6)
- Department rows complete in activity table
- Dates and month labels consistent

### 15.2 Financial QA
- Template extraction fields populated
- KPI and budget-vs-actual sections present
- No orphan references to missing docs

### 15.3 Governance QA
- No outbound send action executed without explicit approval
- MD copy rules preserved where applicable
- Signature block correctness verified

### 15.4 Quality Gate Script
`validate_gate_state.py` must return pass before MD review pack generation.

---

## 16) Cron + Operational Hooks (Optional)

### 16.1 Proposed jobs
- Daily 09:00: check intake + gate status
- Day 5 10:00: generate first reminders
- Day 7 10:00: generate second reminders
- Day 10 10:00: finance escalation draft
- Day 25 12:00: compile report skeleton + missing-items report

### 16.2 Safety
- Cron should generate drafts/reports only.
- Human approval required for sends.

---

## 17) Agent Routing for Build-Out

### 17.1 Shuri (process + control)
- Build references (`financial-gates`, `qa-checklist`, `department-checklists`)
- Define validation criteria and compliance checks

### 17.2 Trinity (scripts + deterministic tooling)
- Implement shell/python scripts
- Add idempotent file writes and clear error output

### 17.3 Ebun (report language quality)
- Refine executive summary and conclusion templates
- Ensure report tone is board/MD appropriate

### 17.4 Main (integration + signoff)
- Validate guardrails and routing
- Final packaging + publish skill

---

## 18) Build Phases & Timeline

### Phase 1 (Day 1)
- Scaffold skill structure
- Move process doc into references
- Create JSON contracts

### Phase 2 (Day 2)
- Implement scripts and dry-run test month
- Produce first report skeleton

### Phase 3 (Day 3)
- QA rules + reminder draft generation
- MD review pack generation

### Phase 4 (Day 4)
- Package skill (`.skill`)
- Pilot in one monthly cycle
- Capture improvements into v1.1

---

## 19) Risks & Mitigations
- **Risk:** inconsistent departmental formatting
  - **Mitigation:** normalize with section templates + parser guards
- **Risk:** delayed finance docs
  - **Mitigation:** explicit gate status + auto-escalation drafts
- **Risk:** accidental outbound send
  - **Mitigation:** hard guardrail in SKILL.md + review step before any send
- **Risk:** report version confusion
  - **Mitigation:** strict file naming/versioning convention

---

## 20) Definition of Done (Skill v1)
1. Skill folder complete with SKILL.md + references + scripts
2. Dry run produces report skeleton, status tables, missing-items file
3. QA script validates structure and gate readiness
4. Reminder drafts generated by date logic
5. Manual send-approval flow enforced end-to-end
6. Pilot month completed with MD review-ready output