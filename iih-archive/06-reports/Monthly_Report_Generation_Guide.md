# IIH Monthly Report Generation Guide

## Overview

This guide details the step-by-step process for generating the Ilorin Innovation Hub (IIH) Monthly Report. The report consolidates departmental inputs and financial data into a single unified document submitted to IHS Nigeria.

---

## Input Files Checklist

Before starting, confirm that all required input files have been received and placed in the correct folders.

### Departmental Reports (PDF)

- [ ] **Administrative Report** — `Administrative Report [Month] [Year].pdf`
  - Source: Administration & Hospitality Department
  - Contents: Front desk operations, event support, procurement, vendor coordination, departmental recommendations

- [ ] **Facility Department Report** — `[MONTH] [YEAR] FACILITY DEPARTMENT REPORT.pdf`
  - Source: Facility Management Department
  - Contents: Infrastructure updates, maintenance activities, security incidents, furniture/equipment procurement, power systems

- [ ] **Programs Report** — `[Month] [Year] Programs Report.pdf`
  - Source: Programs Department
  - Contents: Programme descriptions, participation metrics, partner activities (CcHUB, Future Africa, IIH), upcoming events

- [ ] **HR Report** — `[Month] HR Report [Year].pdf`
  - Source: Human Resources Department
  - Contents: Workforce summary (permanent, contract, NYSC, interns), onboarding/exits, statutory compliance, staff queries

- [ ] **IT & Marketing Report** — `Summary of IT and Marketing [Month] [Year] Report.pdf`
  - Source: IT & Marketing Department
  - Contents: Technical support activities, digital marketing output, uptime statistics, infrastructure updates

### Financial Source Files

- [ ] **Financial Management Report (Excel)** — `IIH_Financial_Mgt_Report_[MonthCode].xlsx`
  - Source: Finance team
  - Location: `Financials/` folder
  - Key sheets used:
    - `GL_Transactions` — All general ledger transactions (primary data source for income and expenditure)
    - `MoM Transactions` — Month-over-month summary pivot
    - `SCI` — Statement of Comprehensive Income
    - `Trial Balance` — Zoho Books trial balance
    - `Chart of Accounts` — Category mapping reference
    - `ApprovedBudget_2025` — Budget reference for variance analysis

- [ ] **Bank Statement (PremiumTrust)** — `ILORIN TECH PARK LTD-[MONTH] STATEMENT.pdf`
  - Source: PremiumTrust Bank
  - Contents: Debits, credits, and closing balance for the reporting month

- [ ] **Bank Statement (Zenith)** — `Account_Statement_ILORIN TECH PARK LTD.xlsx`
  - Source: Zenith Bank
  - Contents: Debits, credits, and closing balance for the reporting month
  - Note: This is often the primary source for income/credit classification when GL_Transactions contains only expense entries

### Optional Files

- [ ] **Cafeteria P&L Report** — `BOA_Foods_PnL_[Month]_[Year].pdf`
  - Source: BOA Foods Restaurant
  - Contents: Revenue, cost of sales, gross profit, net earnings
  - Note: Include the Cafeteria Operations section only if this report is provided

---

## Step-by-Step Report Generation Process

### Step 1: Collect and Organize Input Files

1. Create a folder named `[Month] [Year] Departmental Reports - All Input Files`
2. Place all departmental PDF reports in this folder
3. Place all financial source files in the `Financials/` folder
4. Verify all files in the checklist above are present

### Step 2: Extract Financial Data

**From `GL_Transactions` sheet:**

1. Open the Financial Management Report Excel file
2. Navigate to the `GL_Transactions` sheet
3. Filter transactions by the reporting month and year (column: `Trans Date`)
4. Classify each transaction:
   - **Income categories**: Facility rentals, Guest entertainment (income), Donations, IHS Payment
   - **Expense categories**: Salaries and Employee Wages, Repairs and Maintenance, Furniture and Equipment, Air Travel Expense, Staff pension, etc.
   - Use the `Category per Zoho` column (column E) as the primary category; fall back to `Category` column (column D) if Zoho category is blank
5. Sum amounts by category to produce:
   - **Income Breakdown** by category
   - **Expenditure Breakdown** by category
6. Identify any KAIS (Kwara AI Summit) transactions and separate them as out-of-budget/restricted expenses

**From Bank Statements (if income is not in GL_Transactions):**

1. Open the Zenith bank statement
2. Identify all credit entries for the reporting month
3. Classify credits into: Facility rentals, Event hosting income, Partner funding, Cafeteria revenue, Refunds
4. Cross-reference with GL_Transactions to avoid double-counting

**Compile Financial Summary:**

| Item | Source |
|------|--------|
| Total Reportable Income | GL_Transactions income categories + Bank statement credits |
| Total Operational Expenditure | GL_Transactions expense categories (excluding KAIS) |
| Net Position | Income minus Expenditure |
| KAIS (if applicable) | Separate line item, out-of-budget |

### Step 3: Extract Departmental Content

For each departmental PDF report:

1. Read the full report content
2. Identify key sections, activities, achievements, and metrics
3. Structure the content into bullet points and sub-sections
4. Cross-reference dates and event names across reports for consistency
5. Verify workforce numbers (HR), participant counts (Programs), and financial figures match

### Step 4: Build the Report Document

Create `IIH Report [Month] [Year].docx` with the following structure:

#### Header
- Title: "Ilorin Innovation Hub – Monthly Report"
- Submitted to: IHS Nigeria
- Reporting Period: [Month] [Year]
- Submitted by: Managing Director
- Date of Submission: [Date]

#### Section 1: Executive Summary
- Synthesize highlights from all departmental reports
- Include: programme delivery highlights, operational achievements, financial overview, strategic initiatives
- Mention key metrics: total participants, female participation rate, workforce size, major expenditures

#### Section 2: Programs & Events Report
- **Month Overview**: Total participants, female participation %, strategic focus
- **Key Activities Conducted**: 5-column table (Programme/Event, Format, Key Metrics, Focus Area, Outcomes/Impact)
- **Participation Metrics**: 2-column table (Metric, Value) with registration counts, attendance, gender breakdown
- **Projected Impact**: Bullet points on expected outcomes
- **Upcoming Activities**: Bullet points organized by partner (IIH, CcHUB, Future Africa)

#### Section 3: Operations Report
- **3.1 Finances**
  - Introductory paragraph on financial overview
  - Income Breakdown table (3 columns: Category, Details, Amount)
  - Expenditure Breakdown table (3 columns: Category, Details, Amount)
  - Financial Summary table (2 columns: Item, Amount)
  - KAIS table if applicable (3 columns, with note about KWSG funding)
- **3.2 Cafeteria Operations & Profit Sharing** (if Cafeteria P&L is available)
- **3.3 Administration** — from Admin PDF, with sub-sections and bullet points
- **3.4 Human Resources (HR)** — Workforce Summary + Key Activities
- **3.5 Facility Management & Infrastructure** — Key activities, security incidents, infrastructure updates
- **3.6 IT & Marketing** — Technical Support + Digital Marketing sub-sections
- **3.7 Managing Director's Office** — Strategic initiatives, partnerships, upcoming events

#### Section 4: Conclusion
- Summary of month's achievements
- Key challenges and how they were addressed
- Priorities for the upcoming month

### Step 5: Apply Formatting

Apply consistent formatting throughout the document:

| Element | Font | Size | Weight | Color |
|---------|------|------|--------|-------|
| Title (H1) | Avenir Book | 24pt | Bold | Black |
| Main Sections (H2) | Avenir Book | 18pt | Bold | Black |
| Sub-sections (H3) | Avenir Book | 14pt | Bold | Black |
| Sub-sub-sections (H4) | Avenir Book | 12pt | Bold | Black |
| Body text | Avenir Book | 11pt | Normal | Black |
| Table cells | Avenir Book | 10pt | Normal (Bold for headers) | Black |

- Use `List Paragraph` style for bullet points
- Use `Table Grid` style for all tables
- Ensure all text uses `RGBColor(0, 0, 0)` (pure black)

### Step 6: Quality Checks

Before submission, verify:

- [ ] All sections are populated with content (no placeholders or "[To be filled]")
- [ ] All tables have correct data and are in the correct sections
- [ ] Financial figures are internally consistent (Income - Expenditure = Net Position)
- [ ] No duplicate tables or sections
- [ ] Event dates are consistent across all sections
- [ ] Workforce numbers match the HR report
- [ ] Programme participant counts match the Programs report
- [ ] KAIS expenses (if any) are clearly marked as out-of-budget
- [ ] Document opens without errors in Microsoft Word
- [ ] Font is consistently Avenir Book in black throughout
- [ ] Heading sizes follow the specified hierarchy
- [ ] No incomplete sentences or cut-off text

### Step 7: Save and Submit

1. Save the final report as `IIH Report [Month] [Year].docx` in the main Reports folder
2. Review one final time in Microsoft Word for visual appearance
3. Submit to IHS Nigeria

---

## Financial Data Reference

### Key Sheets in the Financial Management Report

| Sheet | Purpose | When to Use |
|-------|---------|-------------|
| `GL_Transactions` | All general ledger entries | Primary source for income/expenditure classification |
| `MoM Transactions` | Monthly pivot summary | Quick cross-check of monthly totals |
| `SCI` | Statement of Comprehensive Income | Verify overall P&L figures |
| `SFP` | Statement of Financial Position | Balance sheet reference |
| `SCF` | Statement of Cash Flows | Cash flow verification |
| `Trial Balance` | Zoho Books trial balance | Category mapping and balance verification |
| `Chart of Accounts` | Account definitions | Map GL categories to report categories |
| `ApprovedBudget_2025` | Monthly budget by category | Budget vs actual comparison |
| `Recon` | Bank reconciliation | Verify bank balances match GL |
| `FAR` | Fixed Asset Register | Track capital expenditure |
| `invoice_details` | Invoice listing | Verify receivables and payments |

### Common Expense Category Mappings

| GL / Zoho Category | Report Category |
|---------------------|-----------------|
| Salaries and Employee Wages | Staff salaries & wages |
| Staff pension + Staff NHF | Staff pension & NHF |
| Staff welfare + Employee related costs | Staff welfare & employee costs |
| Furniture and Equipment | Furniture & equipment |
| Air Travel Expense | Air travel & conferences |
| Travel expense - Local | Local travel |
| Repairs and Maintenance | Repairs & maintenance |
| Fuel/Diesel Expenses + Fuel/Mileage Expenses | Fuel & diesel |
| Janitorial Expense | Janitorial services |
| Office Supplies | Office supplies |
| Guest entertainment | Guest entertainment |
| IT and Internet Expenses + Software expense | IT, internet & software |
| Bank Fees and Charges | Bank fees & charges |
| Other Expenses + Uncategorized | Other expenses |

### Income Classification Guide

| Source | Classification | Notes |
|--------|---------------|-------|
| Venue booking / Hall rental | Facility rentals | Regular revenue |
| Ministry / Government conference | Event hosting income | One-time event income |
| IHS Payment / Street Capital | Partner operational funding | Recurring operational funding |
| BOA Foods / Cafeteria | Cafeteria revenue | Only if Cafeteria section included |
| Flight refund / Reversal | Refunds/Reversals | Track separately |
| KWSG / KAIS | Out-of-budget (restricted) | Never include in operational totals |

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| GL_Transactions has no income entries | Check Zenith and PremiumTrust bank statements for credits |
| Document won't open after generation | Re-save using python-docx; check for XML corruption |
| Formatting lost after editing | Re-apply the formatting script (Avenir Book, sizes, colors) |
| Financial totals don't match | Cross-reference GL_Transactions with MoM Transactions and SCI sheets |
| KAIS expenses mixed with operational | Filter by description keywords ("KAIS", "Kwara AI Summit") and separate |
| Category mapping unclear | Reference the Chart of Accounts sheet for official account definitions |
