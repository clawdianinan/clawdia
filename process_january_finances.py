#!/usr/bin/env python3
"""
Process January 2026 Financial Data for IIH
Extracts data from bank statement and generates financial summary.
"""

import os
import pandas as pd
import openpyxl
from datetime import datetime
import re

class JanuaryFinancialProcessor:
    def __init__(self, base_dir):
        self.base_dir = base_dir
        self.bank_stmt_path = os.path.join(base_dir, "Bank_Statements", "Account_Statement_ILORIN TECH PARK LTD (3) (2).xlsx")
        self.financial_report_path = os.path.join(base_dir, "Reports", "IIH_Financial_Mgt_Report_Dec25.xlsx")
        self.output_dir = os.path.join(base_dir, "Reports")
        
        # Categorization rules
        self.income_categories = [
            'Facility rentals',
            'Program fees', 
            'Grants',
            'Other income'
        ]
        
        self.expense_categories = [
            'Bank charges',
            'Salaries',
            'Utilities',
            'Office supplies',
            'Maintenance',
            'Marketing',
            'Professional fees',
            'Travel',
            'Other expenses'
        ]
        
        # Keywords for auto-categorization
        self.category_keywords = {
            'Facility rentals': ['hall', 'venue', 'rental', 'space', 'booking'],
            'Program fees': ['program', 'training', 'workshop', 'course', 'fee'],
            'Bank charges': ['bank charge', 'transfer levy', 'commission', 'service charge'],
            'Salaries': ['salary', 'payroll', 'staff', 'employee'],
            'Utilities': ['utility', 'electricity', 'power', 'water', 'internet'],
            'Office supplies': ['stationery', 'supplies', 'office', 'printer', 'toner'],
            'Maintenance': ['maintenance', 'repair', 'service'],
            'Marketing': ['marketing', 'advert', 'promotion', 'branding'],
            'Professional fees': ['consultant', 'legal', 'professional', 'fee'],
            'Travel': ['travel', 'transport', 'fuel', 'mileage']
        }
    
    def load_bank_statement(self):
        """Load and parse the January 2026 bank statement"""
        print("Loading bank statement...")
        
        try:
            # Read the Excel file
            df = pd.read_excel(self.bank_stmt_path, sheet_name='Activity_Statement')
            
            # Find the start of transaction data (skip header rows)
            # Look for row with 'Create Date' in first column
            start_row = None
            for i, row in df.iterrows():
                if isinstance(row.iloc[0], str) and 'Create Date' in str(row.iloc[0]):
                    start_row = i
                    break
            
            if start_row is None:
                print("Could not find transaction data start")
                return pd.DataFrame()
            
            # Extract transactions (skip header row)
            transactions_df = df.iloc[start_row+1:].copy()
            
            # Set column names from header row
            transactions_df.columns = [
                'Create Date', 'Effective Date', 'Check No', 
                'Description', 'Debit Amount', 'Credit Amount', 'Balance'
            ]
            
            # Reset index
            transactions_df = transactions_df.reset_index(drop=True)
            
            # Clean data
            # Remove rows where all values are NaN
            transactions_df = transactions_df.dropna(how='all')
            
            # Convert date columns
            for date_col in ['Create Date', 'Effective Date']:
                transactions_df[date_col] = pd.to_datetime(
                    transactions_df[date_col], errors='coerce', dayfirst=True
                )
            
            # Convert amount columns to numeric
            for amount_col in ['Debit Amount', 'Credit Amount', 'Balance']:
                transactions_df[amount_col] = transactions_df[amount_col].apply(
                    self._clean_amount
                )
            
            print(f"Loaded {len(transactions_df)} transactions from bank statement")
            return transactions_df
            
        except Exception as e:
            print(f"Error loading bank statement: {e}")
            return pd.DataFrame()
    
    def _clean_amount(self, value):
        """Clean amount values (remove currency symbols, commas, convert to float)"""
        if pd.isna(value):
            return 0.0
        
        # Convert to string
        str_value = str(value).strip()
        
        # Remove NGN, commas, and other non-numeric characters (except decimal point)
        str_value = re.sub(r'[^\d.-]', '', str_value)
        
        try:
            return float(str_value) if str_value else 0.0
        except:
            return 0.0
    
    def categorize_transaction(self, description):
        """Categorize transaction based on description"""
        if not isinstance(description, str):
            return 'Other expenses'
        
        desc_lower = description.lower()
        
        # Check each category for keywords
        for category, keywords in self.category_keywords.items():
            for keyword in keywords:
                if keyword in desc_lower:
                    return category
        
        # Default categories based on common patterns
        if any(word in desc_lower for word in ['transfer', 'trsf', 'trf']):
            if 'from' in desc_lower:
                return 'Facility rentals'  # Likely income
            elif 'to' in desc_lower:
                return 'Other expenses'  # Likely expense
        
        return 'Other expenses'
    
    def prepare_transaction_data(self, bank_df):
        """Prepare transaction data in the required format"""
        print("Preparing transaction data...")
        
        transactions = []
        
        for _, row in bank_df.iterrows():
            # Determine if it's income (credit) or expense (debit)
            if row['Credit Amount'] > 0:
                amount = row['Credit Amount']
                is_income = True
            elif row['Debit Amount'] > 0:
                amount = -row['Debit Amount']  # Negative for expenses
                is_income = False
            else:
                continue  # Skip rows with no amount
            
            # Get description
            description = str(row['Description']) if pd.notna(row['Description']) else ''
            
            # Categorize
            category = self.categorize_transaction(description)
            
            # Create transaction record
            transaction = {
                'Trans Date': row['Create Date'].strftime('%Y-%m-%d') if pd.notna(row['Create Date']) else '',
                'Value Date': row['Effective Date'].strftime('%d-%b-%Y') if pd.notna(row['Effective Date']) else '',
                'Transaction Details': description,
                'Category': category,
                'Transactions': amount,
                'Bank': 'Bank01'  # Default bank identifier
            }
            
            transactions.append(transaction)
        
        # Create DataFrame
        df = pd.DataFrame(transactions)
        
        # Sort by date
        if 'Trans Date' in df.columns:
            df['Trans Date'] = pd.to_datetime(df['Trans Date'], errors='coerce')
            df = df.sort_values('Trans Date')
            df['Trans Date'] = df['Trans Date'].dt.strftime('%Y-%m-%d')
        
        print(f"Prepared {len(df)} categorized transactions")
        return df
    
    def generate_summary(self, transaction_df):
        """Generate financial summary from transaction data"""
        print("Generating financial summary...")
        
        if transaction_df.empty:
            return {
                'total_income': 0,
                'total_expenses': 0,
                'net_balance': 0,
                'income_by_category': {},
                'expenses_by_category': {},
                'transaction_count': 0
            }
        
        # Separate income and expenses
        income_df = transaction_df[transaction_df['Transactions'] > 0]
        expenses_df = transaction_df[transaction_df['Transactions'] < 0]
        
        # Calculate totals
        total_income = income_df['Transactions'].sum()
        total_expenses = abs(expenses_df['Transactions'].sum())  # Positive value
        net_balance = total_income - total_expenses
        
        # Breakdown by category
        income_by_category = income_df.groupby('Category')['Transactions'].sum().to_dict()
        expenses_by_category = expenses_df.groupby('Category')['Transactions'].sum().to_dict()
        
        # Convert to positive values for expenses
        expenses_by_category = {k: abs(v) for k, v in expenses_by_category.items()}
        
        return {
            'total_income': total_income,
            'total_expenses': total_expenses,
            'net_balance': net_balance,
            'income_by_category': income_by_category,
            'expenses_by_category': expenses_by_category,
            'transaction_count': len(transaction_df),
            'income_count': len(income_df),
            'expense_count': len(expenses_df)
        }
    
    def create_financial_report(self, transaction_df, summary):
        """Create comprehensive financial report"""
        print("Creating financial report...")
        
        # Create output directory if it doesn't exist
        os.makedirs(self.output_dir, exist_ok=True)
        
        # Output file paths
        output_excel = os.path.join(self.output_dir, "January_2026_Financial_Report.xlsx")
        output_summary = os.path.join(self.output_dir, "January_2026_Financial_Summary.md")
        
        # 1. Save transaction data to Excel
        with pd.ExcelWriter(output_excel, engine='openpyxl') as writer:
            # Save transaction data
            transaction_df.to_excel(writer, sheet_name='Transactions', index=False)
            
            # Create summary sheet
            summary_data = []
            
            # Basic summary
            summary_data.append(['IIH Financial Summary - January 2026', ''])
            summary_data.append(['Report Generated', datetime.now().strftime('%Y-%m-%d %H:%M:%S')])
            summary_data.append(['Report Period', 'January 2026'])
            summary_data.append(['', ''])
            
            summary_data.append(['Financial Overview', ''])
            summary_data.append(['Total Income', f"₦{summary['total_income']:,.2f}"])
            summary_data.append(['Total Expenses', f"₦{summary['total_expenses']:,.2f}"])
            summary_data.append(['Net Balance', f"₦{summary['net_balance']:,.2f}"])
            summary_data.append(['', ''])
            
            summary_data.append(['Transaction Statistics', ''])
            summary_data.append(['Total Transactions', summary['transaction_count']])
            summary_data.append(['Income Transactions', summary['income_count']])
            summary_data.append(['Expense Transactions', summary['expense_count']])
            summary_data.append(['', ''])
            
            # Income breakdown
            summary_data.append(['Income Breakdown', ''])
            for category, amount in summary['income_by_category'].items():
                percentage = (amount / summary['total_income'] * 100) if summary['total_income'] > 0 else 0
                summary_data.append([f"  {category}", f"₦{amount:,.2f} ({percentage:.1f}%)"])
            summary_data.append(['Total Income', f"₦{summary['total_income']:,.2f}"])
            summary_data.append(['', ''])
            
            # Expense breakdown
            summary_data.append(['Expense Breakdown', ''])
            for category, amount in summary['expenses_by_category'].items():
                percentage = (amount / summary['total_expenses'] * 100) if summary['total_expenses'] > 0 else 0
                summary_data.append([f"  {category}", f"₦{amount:,.2f} ({percentage:.1f}%)"])
            summary_data.append(['Total Expenses', f"₦{summary['total_expenses']:,.2f}"])
            
            summary_df = pd.DataFrame(summary_data, columns=['Item', 'Value'])
            summary_df.to_excel(writer, sheet_name='Summary', index=False)
            
            # Auto-adjust column widths
            for sheet_name in writer.sheets:
                worksheet = writer.sheets[sheet_name]
                for column in worksheet.columns:
                    max_length = 0
                    column_letter = column[0].column_letter
                    for cell in column:
                        try:
                            if len(str(cell.value)) > max_length:
                                max_length = len(str(cell.value))
                        except:
                            pass
                    adjusted_width = min(max_length + 2, 50)
                    worksheet.column_dimensions[column_letter].width = adjusted_width
        
        print(f"Excel report saved: {output_excel}")
        
        # 2. Create markdown summary
        md_content = f"""# IIH Financial Summary - January 2026

## Report Information
- **Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
- **Period**: January 2026
- **Data Source**: ILORIN TECH PARK LTD Bank Statement

## Financial Overview
| Metric | Amount (₦) |
|--------|------------|
| **Total Income** | {summary['total_income']:,.2f} |
| **Total Expenses** | {summary['total_expenses']:,.2f} |
| **Net Balance** | {summary['net_balance']:,.2f} |

## Transaction Statistics
- **Total Transactions**: {summary['transaction_count']}
- **Income Transactions**: {summary['income_count']}
- **Expense Transactions**: {summary['expense_count']}

## Income Breakdown
| Category | Amount (₦) | Percentage |
|----------|------------|------------|
"""
        
        for category, amount in summary['income_by_category'].items():
            percentage = (amount / summary['total_income'] * 100) if summary['total_income'] > 0 else 0
            md_content += f"| {category} | {amount:,.2f} | {percentage:.1f}% |\n"
        
        md_content += f"| **Total Income** | **{summary['total_income']:,.2f}** | **100%** |\n\n"
        
        md_content += """## Expense Breakdown
| Category | Amount (₦) | Percentage |
|----------|------------|------------|
"""
        
        for category, amount in summary['expenses_by_category'].items():
            percentage = (amount / summary['total_expenses'] * 100) if summary['total_expenses'] > 0 else 0
            md_content += f"| {category} | {amount:,.2f} | {percentage:.1f}% |\n"
        
        md_content += f"| **Total Expenses** | **{summary['total_expenses']:,.2f}** | **100%** |\n\n"
        
        md_content += """## Notes
1. This report is generated from bank statement data
2. Categories are automatically assigned based on transaction descriptions
3. Manual review recommended for accurate categorization
4. All amounts in Nigerian Naira (₦)

## Files Generated
1. `January_2026_Financial_Report.xlsx` - Complete transaction data + summary
2. `January_2026_Financial_Summary.md` - This summary document

## Next Steps
1. Review categorization for accuracy
2. Match transactions with invoices/receipts
3. Update with IHS template when received
4. Submit to finance department for approval
"""
        
        with open(output_summary, 'w') as f:
            f.write(md_content)
        
        print(f"Markdown summary saved: {output_summary}")
        
        return output_excel, output_summary
    
    def run(self):
        """Main processing pipeline"""
        print("=" * 60)
        print("IIH January 2026 Financial Data Processor")
        print("=" * 60)
        
        # Step 1: Load bank statement
        bank_df = self.load_bank_statement()
        if bank_df.empty:
            print("ERROR: No transaction data found in bank statement")
            return False
        
        # Step 2: Prepare transaction data
        transaction_df = self.prepare_transaction_data(bank_df)
        if transaction_df.empty:
            print("ERROR: No valid transactions to process")
            return False
        
        # Step 3: Generate summary
        summary = self.generate_summary(transaction_df)
        
        # Step 4: Create reports
        excel_file, summary_file = self.create_financial_report(transaction_df, summary)
        
        # Display summary
        print("\n" + "=" * 60)
        print("PROCESSING COMPLETE")
        print("=" * 60)
        print(f"\nFinancial Summary for January 2026:")
        print(f"  Total Income:    ₦{summary['total_income']:,.2f}")
        print(f"  Total Expenses:  ₦{summary['total_expenses']:,.2f}")
        print(f"  Net Balance:     ₦{summary['net_balance']:,.2f}")
        print(f"  Transactions:    {summary['transaction_count']}")
        
        print(f"\nFiles Generated:")
        print(f"  1. {excel_file}")
        print(f"  2. {summary_file}")
        
        print(f"\nNext Steps:")
        print("  1. Review categorization in Excel file")
        print("  2. Match transactions with invoices/receipts")
        print("  3. Update categories as needed")
        print("  4. Wait for IHS template for final formatting")
        
        return True

def main():
    """Main function"""
    # Set base directory
    base_dir = "/Users/clawdia/Documents/IIH/Finances/January_2026"
    
    # Initialize processor
    processor = JanuaryFinancialProcessor(base_dir)
    
    # Run processing
    success = processor.run()
    
    if not success:
        print("\nProcessing failed. Please check the error messages above.")
        return 1
    
    return 0

if __name__ == "__main__":
    exit(main())