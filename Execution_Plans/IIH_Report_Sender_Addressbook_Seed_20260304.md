# IIH Monthly Report Sender Addressbook (Seed)

Date generated: 2026-03-04 01:34 GMT+1
Source checked: `iih_clawdia` and `zoho` mailboxes via Himalaya envelope search
Purpose: Seed directory for skill auto-matching (who sends which monthly report)

## Canonical Monthly Report Senders

| Department | Staff Name | Primary Email | Typical Report Subject Patterns | Confidence |
|---|---|---|---|---|
| Programs | Adebola Oladipo | adebola.oladipo@iih.ng | `Programs Report`, `December 2025 Programs Report`, program summary threads | Medium |
| Programs | Zumah Yahaya | zumah.yahaya@iih.ng | programs governance/KPI and program proposal threads, partner program correspondence | Medium |
| Finance | Khadijat Bello | khadijat.bello@iih.ng | `JANUARY 2026 FINANCIAL STATEMENT`, `IIH Bank Statement`, financial statements | High |
| Administration | Maureen Okey | maureen.okey@iih.ng | `Administrative Report – January 2026`, `Administrative Report December 2025` | High |
| Human Resources | Sinachi Onuchukwu | sinachi@iih.ng | `January HR Report`, payroll/NSITF approval/report threads | High |
| Facility Management | Kamil Ahmed | kamil.ahmed@iih.ng | `FACILITY MANAGEMENT -MONTLY REPORT...`, `FEBRUARY 2026 – FACILITY DEPARTMENT REPORT` | High |
| IT & Marketing | Nasiru Muhammed | nasiru.muhammed@iih.ng / nas@iih.ng | `IT & Marketing January 2026 Report`, `December 2025 IT and Marketing Report` | High |

## Notes
1. Some monthly-report packets are forwarded by Temi to Clawdia; skill should classify by original subject/sender when present.
2. Programs department evidence appears in mixed operational threads; use subject-pattern detection + sender mapping.
3. Use this file as initial registry; skill should continuously update with newly observed sender/report pairs.

## Suggested Skill Logic
- Match inbound by:
  1) exact sender email in addressbook,
  2) subject regex pattern,
  3) attachment presence + month keyword,
  4) fallback manual review queue.
- On mismatch, create candidate mapping entry with confidence score instead of auto-overwriting.
