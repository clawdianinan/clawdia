# January 2026 Financial Processing Plan

## Status
- ✅ Financial documents forwarded to clawdia.ai@iih.ng (15:44 GMT+1)
- ✅ Directory structure created: `/Documents/IIH/Finances/January_2026/`
- ⏳ Awaiting email with actual document attachments
- ⏳ Awaiting IHS monthly Excel template for refinement

## Directory Structure Created
```
/Documents/IIH/Finances/January_2026/
├── Bank_Statements/      # For bank statement PDFs
├── Invoices/             # For invoice documents
├── Receipts/             # For receipt documents
└── Reports/              # For generated reports
```

## Processing Steps

### 1. File Organization
When documents arrive:
- Save all files to appropriate subdirectories
- Rename files with consistent naming convention: `YYYY-MM-DD_Description_Type.pdf`
- Create inventory of all documents received

### 2. Data Extraction
Based on existing financial report structure:
- Extract transaction data from bank statements
- Match invoices/receipts to transactions
- Follow "Sheet2 (2)" format from existing report:
  - Trans Date
  - Value Date
  - Transaction Details
  - Category
  - Transactions (amount: negative for expenses, positive for income)
  - Bank

### 3. Categorization Framework
Initial categories from existing report:
- **Income Categories:**
  - Facility rentals
  - Program fees
  - Grants
  - Other income

- **Expense Categories:**
  - Bank charges
  - Salaries
  - Utilities
  - Office supplies
  - Maintenance
  - Marketing
  - Professional fees
  - Travel
  - Other expenses

### 4. Summary Generation
Create summary report with:
- Total Income
- Total Expenses
- Net Balance (Income - Expenses)
- Breakdown by category
- Comparison to previous period (if available)

### 5. Template Refinement
When IHS monthly Excel template arrives:
- Map extracted data to IHS template format
- Ensure compliance with IHS reporting requirements
- Add any additional fields required

## Next Actions
1. Monitor email for January financial document attachments
2. Download and organize documents when received
3. Begin data extraction once documents are available
4. Watch for IHS monthly Excel template email
5. Generate preliminary summary for review

## Notes
- Existing financial report template available at: `/Documents/IIH/January_2026_Reports/06_Finance/202512_IIH_FinancialReport_Reviewed LATEST.xlsx`
- Follow same structure for consistency
- Ensure all amounts include proper sign convention (negative for expenses)