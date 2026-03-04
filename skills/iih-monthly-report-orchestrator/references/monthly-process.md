# Monthly Process Reference (with Triggers + Progress)

## Trigger Schedule (Africa/Lagos)
- Day 1 09:00: open cycle, initialize status files for previous month report
- Day 3 17:00: departmental submission deadline snapshot + missing list
- Day 5 10:00: first escalation drafts for missing departments
- Day 6 10:00: finance gate check + blocker escalation draft
- Day 7 12:00: compile full report draft + QA + MD review pack (internal completion target)
- Day 8 09:00: final submission-readiness confirmation (hard deadline)

## Progress % Model
Store in: `reports_status/<YYYY-MM>/progress.json`

Weighted milestones:
1. Department submissions complete (6 departments): 40%
2. Finance gates (10/15/20): 30% (10% each)
3. Report assembly draft complete: 20%
4. QA passed + MD review pack generated: 10%

Formula:
- `progress = submissions_pct*0.40 + gate_pct*0.30 + assembly_pct*0.20 + review_pct*0.10`

Where:
- `submissions_pct = received_departments / 6`
- `gate_pct = passed_gates / 3`
- `assembly_pct = 1 if draft exists else 0`
- `review_pct = 1 if QA pass + MD pack exists else 0`

## State Targets by Day (Calendar Day of New Month)
- By Day 3: target >= 40%
- By Day 5: target >= 65%
- By Day 6: target >= 80%
- By Day 7: target >= 95%
- By Day 8: target = 100%

## Failure Handling
If progress is below target for the day:
- create/update `reports_status/<YYYY-MM>/risk_flags.json`
- create/update `reports_status/<YYYY-MM>/recovery_plan.md`
- generate draft escalation summary for MD review
