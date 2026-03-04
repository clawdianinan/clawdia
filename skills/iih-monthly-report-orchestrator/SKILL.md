---
name: iih-monthly-report-orchestrator
description: Orchestrate IIH monthly report operations end-to-end: track departmental submissions, maintain sender addressbook (name/department/email mapping), enforce finance gates (Day 10/15/20), generate reminder/escalation drafts (Day 5/7/10), and assemble MD review pack by Day 25. Use when user asks to compile monthly report, monitor missing submissions, identify who sends which report, or prepare IHS-ready draft outputs.
---

# IIH Monthly Report Orchestrator

1. Read `references/monthly-process.md` and `references/department-checklists.md` first.
2. Use `references/financial-gates.md` to enforce Day 10/15/20 prerequisites.
3. Maintain sender directory in `reports_status/addressbook/report_senders.json`.
4. Save cycle artifacts under `reports_status/<YYYY-MM>/`.

## Safety + Guardrails
- Draft-only by default for reminders and external messages.
- Never send outbound email without explicit instruction in current thread.
- For IIH outbound on MD instruction, copy `temi@iih.ng` where required.

## Sender Addressbook Logic
1. Load `reports_status/addressbook/report_senders.json`.
2. Match incoming report email by sender + subject pattern.
3. If unmatched, append candidate with `status: needs_review` and confidence score.
4. Support multiple approved senders per department.

## Tooling with Fallbacks
Primary email query method:
- Himalaya account queries (`himalaya envelope list ...`).

Fallbacks when Himalaya or account access fails:
1. Use Apple Mail search skill (`apple-mail-search`) for mailbox lookup.
2. If both unavailable, parse latest forwarded monthly-report emails already saved in workspace artifacts.
3. If still blocked, generate a "manual verification required" queue file under `reports_status/<YYYY-MM>/manual_queue.md`.

## Output Contract
Generate:
- `Reports/IIH_Monthly_Report_<YYYY-MM>_Draft_v1.0.md`
- `Reports/IIH_Monthly_Report_<YYYY-MM>_MD_Review_Pack_v1.0.md`
- `Reports/IIH_Monthly_Report_<YYYY-MM>_Missing_Items_v1.0.md`
- `reports_status/<YYYY-MM>/submission_status.json`
- `reports_status/<YYYY-MM>/financial_gates.json`
- `reports_status/<YYYY-MM>/risk_flags.json`
- `reports_status/<YYYY-MM>/sender_match_log.json`

## Trigger Enforcement
Use `references/monthly-process.md` trigger schedule as authoritative.
- Run trigger checks at defined day/time windows.
- On each trigger, update progress via `scripts/calc_progress.py` and write `reports_status/<YYYY-MM>/progress.json`.
- If progress falls below target for current day, append risk + recovery actions.

## Execution Order
1. Intake scan + sender classification.
2. Deadline-driven reminder draft generation.
3. Finance gate validation.
4. Progress % recomputation.
5. Report assembly and QA.
6. MD review pack generation.
