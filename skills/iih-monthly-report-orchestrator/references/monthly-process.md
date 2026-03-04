# Monthly Process Reference (with Triggers + Progress)

## Trigger Schedule (Africa/Lagos)
- Day 1 09:00: open cycle, initialize status files
- Day 3 17:00: submission deadline check snapshot
- Day 5 10:00: generate first reminder drafts for missing departments
- Day 7 10:00: generate second/urgent reminder drafts
- Day 10 10:00: finance gate 10 check + escalation draft if failed
- Day 15 10:00: finance gate 15 check + escalation draft if failed
- Day 20 10:00: finance gate 20 check + block/allow assembly
- Day 25 12:00: compile report draft + MD review pack + missing items

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

## State Targets by Day
- By Day 5: target >= 35%
- By Day 10: target >= 50%
- By Day 15: target >= 65%
- By Day 20: target >= 80%
- By Day 25: target = 100%

## Failure Handling
If progress is below target for the day:
- create/update `reports_status/<YYYY-MM>/risk_flags.json`
- create/update `reports_status/<YYYY-MM>/recovery_plan.md`
- generate draft escalation summary for MD review
