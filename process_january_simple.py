#!/usr/bin/env python3
"""
Simple January 2026 Financial Data Processor
Uses only standard libraries - no pandas required.
"""

import os
import csv
import re
from datetime import datetime
from collections import defaultdict

class SimpleFinancialProcessor:
    def __init__(self, base_dir):
        self.base_dir = base_dir
        self.bank_stmt_path = os.path.join(base_dir, "Bank_Statements", "Account_Statement_ILORIN TECH PARK LTD (3) (2).xlsx")
        self.output_dir = os.path.join(base_dir, "Reports")
        
        # Categorization rules
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
    
    def clean_amount(self, value):
        """Clean amount values"""
        if not value:
            return 0.0
        
        # Convert to string
        str_value = str(value).strip()
        
        # Remove NGN, commas, and other non-numeric characters
        str_value = re.sub(r'[^\d.-]', '', str_value)
        
        try:
            return float(str_value) if str_value else 0.0
        except:
            return 0.0
    
    def parse_excel_simple(self):
        """Parse Excel file without pandas"""
        print("Parsing bank statement...")
        
        transactions = []
        
        try:
            # Try to use openpyxl if available
            import openpyxl
            
            wb = openpyxl.load_workbook(self.bank_stmt_path, read_only=True, data_only=True)
            ws = wb['Activity_Statement']
            
            # Find start of transaction data
            start_row = None
            for row in ws.iter_rows(min_row=1, max_row=50, values_only=True):
                if row and isinstance(row[0], str) and 'Create Date' in row[0]:
                    start_row = ws.iter_rows().index(row) + 1
                    break
            
            if start_row is None:
                print("Could not find transaction data")
                return []
            
            # Read transactions
            for row in ws.iter_rows(min_row=start_row+1, values_only=True):
                # Skip empty rows
                if not any(row):
                    continue
                
                # Extract data
                create_date = row[0]
                effective_date = row[1]
                description = str(row[3]) if row[3] else ''
                debit = self.clean_amount(row[4])
                credit = self.clean_amount(row[5])
                
                # Skip if no amount
                if debit == 0 and credit == 0:
                    continue
                
                # Determine amount and type
                if credit > 0:
                    amount = credit
                    is_income = True
                else:
                    amount = -debit  # Negative for expenses
                    is_income = False
                
                # Categorize
                category = self.categorize_transaction(description)
                
                # Format dates
                trans_date = ''
                value_date = ''
                
                if create_date:
                    if isinstance(create_date, datetime):
                        trans_date = create_date.strftime('%Y-%m-%d')
                    else:
                        trans_date = str(create_date)
                
                if effective_date:
                    if isinstance(effective_date, datetime):
                        value_date = effective_date.strftime('%d-%b-%Y')
                    else:
                        value_date = str(effective_date)
                
                transaction = {
                    'Trans Date': trans_date,
                    'Value Date': value_date,
                    'Transaction Details': description,
                    'Category': category,
                    'Transactions': amount,
                    'Bank': 'Bank01'
                }
                
                transactions.append(transaction)
            
            print(f"Parsed {len(transactions)} transactions")
            return transactions
            
        except ImportError:
            print("openpyxl not available. Trying CSV fallback...")
            return self.fallback_parse()
        except Exception as e:
            print(f"Error parsing Excel: {e}")
            return []
    
    def fallback_parse(self):
        """Fallback parsing method"""
        print("Using fallback parsing (manual data entry required)")
        print("\nSince we can't parse Excel without libraries, here's the process:")
        print("1. Open the bank statement Excel file")
        print("2. Export to CSV or copy transaction data")
        print("3. Use the template CSV at: /Users/clawdia/Documents/IIH/Finances/January_2026/Data/transactions_template.csv")
        return []
    
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
    
    def generate_summary(self, transactions):
        """Generate financial summary"""
        print("Generating financial summary...")
        
        if not transactions:
            return {
                'total_income': 0,
                'total_expenses': 0,
                'net_balance': 0,
                'income_by_category': {},
                'expenses_by_category': {},
                'transaction_count': 0
            }
        
        # Initialize counters
        total_income = 0
        total_expenses = 0
        income_by_category = defaultdict(float)
        expenses_by_category = defaultdict(float)
        
        # Process transactions
        for tx in transactions:
            amount = tx['Transactions']
            
            if amount > 0:  # Income
                total_income += amount
                income_by_category[tx['Category']] += amount
            else:  # Expense (negative)
                total_expenses += abs(amount)
                expenses_by_category[tx['Category']] += abs(amount)
        
        net_balance = total_income - total_expenses
        
        return {
            'total_income': total_income,
            'total_expenses': total_expenses,
            'net_balance': net_balance,
            'income_by_category': dict(income_by_category),
            'expenses_by_category': dict(expenses_by_category),
            'transaction_count': len(transactions),
            'income_count': sum(1 for tx in transactions if tx['Transactions'] > 0),
            'expense_count': sum(1 for tx in transactions if tx['Transactions'] < 0)
        }
    
    def save_transactions_csv(self, transactions):
        """Save transactions to CSV"""
        csv_path = os.path.join(self.output_dir, "January_2026_Transactions.csv")
        
        # Define column order
        columns = ['Trans Date', 'Value Date', 'Transaction Details', 'Category', 'Transactions', 'Bank']
        
        with open(csv_path, 'w', newline='') as csvfile:
            writer = csv.DictWriter(csvfile, fieldnames=columns)
            writer.writeheader()
            
            for tx in transactions:
                writer.writerow(tx)
        
        print(f"Transactions saved to: {csv_path}")
        return csv_path
    
    def create_summary_report(self, summary):
        """Create summary report"""
        print("Creating summary report...")
        
        # Create output directory
        os.makedirs(self.output_dir, exist_ok=True)
        
        # Create markdown summary
        md_path = os.path.join(self.output_dir, "January_2026_Financial_Summary.md")
        
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

## Next Steps
1. Review categorization for accuracy
2. Match transactions with invoices/receipts
3. Update with IHS template when received
4. Submit to finance department for approval

## Files Generated
1. `January_2026_Transactions.csv` - Complete transaction data
2. `January_2026_Financial_Summary.md` - This summary document
"""
        
        with open(md_path, 'w') as f:
            f.write(md_content)
        
        print(f"Summary report saved: {md_path}")
        return md_path
    
    def run(self):
        """Main processing pipeline"""
        print("=" * 60)
        print("IIH January 2026 Financial Data Processor (Simple)")
        print("=" * 60)
        
        # Parse transactions
        transactions = self.parse_excel_simple()
        
        if not transactions:
            print("\nNo transactions parsed. Possible reasons:")
            print("1. Excel parsing libraries not available")
            print("2. Bank statement format not recognized")
            print("3. No transaction data found")
            
            print("\nAlternative approach:")
            print("1. Open the bank statement manually")
            print("2. Copy data to the template CSV:")
            print("   /Users/clawdia/Documents/IIH/Finances/January_2026/Data/transactions_template.csv")
            print("3. Run the processing again")
            return False
        
        # Generate summary
        summary = self.generate_summary(transactions)
        
        # Save transactions to CSV
        csv_file = self.save_transactions_csv(transactions)
        
        # Create summary report
        summary_file = self.create_summary_report(summary)
        
        # Display results
        print("\n" + "=" * 60)
        print("PROCESSING COMPLETE")
        print("=" * 60)
        print(f"\nFinancial Summary for January 2026:")
        print(f"  Total Income:    ₦{summary['total_income']:,.2f}")
        print(f"  Total Expenses:  ₦{summary['total_expenses']:,.2f}")
        print(f"  Net Balance:     ₦{summary['net_balance']:,.2f}")
        print(f"  Transactions:    {summary['transaction_count']}")
        
        print(f"\nFiles Generated:")
        print(f"  1. {csv_file}")
        print(f"  2. {summary_file}")
        
        print(f"\nNext Steps:")
        print("  1. Review categorization in CSV file")
        print("  2. Match transactions with invoices/receipts")
        print("  3. Update categories as needed")
        print("  4. Wait for IHS template for final formatting")
        
        return True

def main():
    """Main function"""
    # Set base directory
    base_dir = "/Users/clawdia/Documents/IIH/Finances/January_2026"
    
    # Initialize processor
    processor = SimpleFinancialProcessor(base_dir)
    
    # Run processing
    success = processor.run()
    
    if not success:
        print("\nProcessing incomplete. Manual steps required.")
        print("\nPlease:")
        print("1. Install pandas and openpyxl: pip3 install pandas openpyxl")
        print("2. OR manually extract data from bank statement")
        print("3. Use the provided template CSV for data entry")
        return 1
    
    return 0

if __name__ == "__main__":
    exit(main())