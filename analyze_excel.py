#!/usr/bin/env python3
import openpyxl
from openpyxl import load_workbook

# Load the workbook
wb = load_workbook('IIH_Roles_and_Grades_20260224_FINAL_CORRECTED_20260224_1839.xlsx', data_only=True)
ws = wb['Summary']

print("=== CURRENT SUMMARY SHEET STRUCTURE ===\n")

# Find all non-empty cells with their values
data_cells = {}
for row in ws.iter_rows(min_row=1, max_row=30, min_col=1, max_col=10):
    for cell in row:
        if cell.value is not None:
            data_cells[f"{cell.coordinate}"] = cell.value

print("Key cells with data:")
for coord, value in sorted(data_cells.items()):
    print(f"{coord}: {value}")

print("\n=== GENDER DISTRIBUTION SECTION ===")
# Gender section is around rows 10-13
for row in ws.iter_rows(min_row=10, max_row=13, min_col=1, max_col=5, values_only=True):
    print(row)

print("\n=== ORIGIN DISTRIBUTION SECTION ===")
# Origin section is around rows 15-18
for row in ws.iter_rows(min_row=15, max_row=18, min_col=1, max_col=7, values_only=True):
    print(row)

print("\n=== CHECKING FORMULAS ===")
# Check if cells have formulas
print("Checking B12 (Core Staff Male count):", ws['B12'].value)
print("Checking C12 (Core Staff Female count):", ws['C12'].value)
print("Checking B13 (All Staff Male count):", ws['B13'].value)
print("Checking C13 (All Staff Female count):", ws['C13'].value)

print("\nChecking E17 (Core Staff Kwara %):", ws['E17'].value)
print("Checking F17 (Core Staff Non-Kwara %):", ws['F17'].value)
print("Checking E18 (All Staff Kwara %):", ws['E18'].value)
print("Checking F18 (All Staff Non-Kwara %):", ws['F18'].value)

# Let's also check what formulas exist
print("\n=== FORMULA CHECK ===")
for cell in ['B12', 'C12', 'B13', 'C13', 'B17', 'C17', 'B18', 'C18', 'E17', 'F17', 'E18', 'F18']:
    cell_obj = ws[cell]
    if cell_obj.value and isinstance(cell_obj.value, str) and cell_obj.value.startswith('='):
        print(f"{cell}: FORMULA = {cell_obj.value}")
    else:
        print(f"{cell}: VALUE = {cell_obj.value}")