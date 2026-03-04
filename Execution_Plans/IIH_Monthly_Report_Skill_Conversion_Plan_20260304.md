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