#!/usr/bin/env python3
import openpyxl
from openpyxl import load_workbook

wb = load_workbook('IIH_Roles_and_Grades_20260224_FINAL_CORRECTED_WITH_GENDER_PERCENTAGES.xlsx', data_only=False)  # Keep formulas
ws_sum = wb['Summary']

print("=== VERIFYING UPDATED SUMMARY SHEET ===\n")

print("=== GENDER DISTRIBUTION SECTION (Rows 10-13) ===")
for row in ws_sum.iter_rows(min_row=10, max_row=13, min_col=1, max_col=6, values_only=True):
    print(row)

print("\n=== ORIGIN DISTRIBUTION SECTION (Rows 15-18) ===")
for row in ws_sum.iter_rows(min_row=15, max_row=18, min_col=1, max_col=7, values_only=True):
    print(row)

print("\n=== FORMULA CHECK ===")
print("Core Staff Gender:")
print(f"  B12 (Male count): {ws_sum['B12'].value}")
print(f"  C12 (Female count): {ws_sum['C12'].value}")
print(f"  D12 (Male %): {ws_sum['D12'].value}")
print(f"  E12 (Female %): {ws_sum['E12'].value}")

print("\nAll Staff Gender:")
print(f"  B13 (Male count): {ws_sum['B13'].value}")
print(f"  C13 (Female count): {ws_sum['C13'].value}")
print(f"  D13 (Male %): {ws_sum['D13'].value}")
print(f"  E13 (Female %): {ws_sum['E13'].value}")

print("\nCore Staff Origin:")
print(f"  B17 (Kwara count): {ws_sum['B17'].value}")
print(f"  C17 (Non-Kwara count): {ws_sum['C17'].value}")
print(f"  E17 (Kwara %): {ws_sum['E17'].value}")
print(f"  F17 (Non-Kwara %): {ws_sum['F17'].value}")

print("\nAll Staff Origin:")
print(f"  B18 (Kwara count): {ws_sum['B18'].value}")
print(f"  C18 (Non-Kwara count): {ws_sum['C18'].value}")
print(f"  E18 (Kwara %): {ws_sum['E18'].value}")
print(f"  F18 (Non-Kwara %): {ws_sum['F18'].value}")

print("\n=== POPULATION COUNTS ===")
print(f"  B5 (Total Core Staff): {ws_sum['B5'].value}")
print(f"  B6 (Total Interns): {ws_sum['B6'].value}")
print(f"  B7 (Total Corpers): {ws_sum['B7'].value}")
print(f"  B8 (Total People All): {ws_sum['B8'].value}")

# Let's calculate what the values should be based on formulas
print("\n=== EXPECTED CALCULATIONS ===")
print("Note: These are formula-based and will calculate when Excel opens the file")
print("Gender percentages should appear similar to origin percentage format")