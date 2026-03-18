# Data Model Notes

## Core Entities
1. Program
2. Cohort
3. Application
4. Applicant Team
5. Startup
6. Mentor
7. Session
8. Milestone
9. Budget
10. BudgetLineItem
11. Disbursement
12. KPIRecord
13. DocumentArtifact
14. Partner
15. Report

## Key Relationships
- Program has many Cohorts
- Cohort has many Applications, Startups, Sessions, Milestones
- Startup has many KPIRecords, MentorAssignments, Disbursements
- Budget belongs to Program/Cohort and has many LineItems
- Milestone can require many DocumentArtifacts

## Required Status Fields
- ProgramStatus (draft, active, paused, completed)
- ApplicationStatus (submitted, shortlisted, interviewed, accepted, rejected)
- MilestoneStatus (not_started, in_progress, at_risk, completed, verified)
- DisbursementStatus (planned, pending_approval, released, blocked)

## Audit & Traceability
- created_by, updated_by, timestamps
- approval history for budget/disbursement actions
- evidence links for compliance-critical actions

## KPI Schema (starter)
- startup_id
- date
- metric_name
- metric_value
- target_value
- source (self-reported/verified/system)

