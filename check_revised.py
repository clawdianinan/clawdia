#!/usr/bin/env python3
import openpyxl
from openpyxl import load_workbook

wb = load_workbook('IIH_Roles_and_Grades_20260224_FINAL_CORRECTED_20260224_1839.xlsx', data_only=True)

# Check the Revised sheet
if 'Revised' in wb.sheetnames:
    ws_rev = wb['Revised']
    print("=== REVISED SHEET PREVIEW ===")
    
    # Print header row
    headers = []
    for cell in ws_rev[1]:  # First row
        headers.append(cell.value)
    print("Headers:", headers)
    
    # Look for gender and origin columns
    gender_col = None
    origin_col = None
    for idx, header in enumerate(headers, 1):
        if header and isinstance(header, str):
            if 'gender' in header.lower():
                gender_col = idx
                print(f"Gender column found: {header} (column {idx})")
            if 'origin' in header.lower() or 'state' in header.lower():
                origin_col = idx
                print(f"Origin column found: {header} (column {idx})")
    
    # Show some sample data
    print("\nSample data (first 10 rows):")
    for i, row in enumerate(ws_rev.iter_rows(min_row=1, max_row=11, values_only=True), 1):
        print(f"Row {i}: {row}")
        
    # Check if there are formulas in the summary sheet that reference Revised sheet
    print("\n=== CHECKING SUMMARY SHEET FORMULAS ===")
    ws_sum = wb['Summary']
    
    # Check a few key cells for formulas
    check_cells = ['B5', 'B6', 'B7', 'B8', 'B12', 'C12', 'B13', 'C13', 'B17', 'C17', 'B18', 'C18']
    for cell_ref in check_cells:
        cell = ws_sum[cell_ref]
        if cell.value:
            print(f"{cell_ref}: {cell.value}")
            if isinstance(cell.value, str) and 'Revised' in cell.value:
                print(f"  -> References Revised sheet")
        else:
            print(f"{cell_ref}: EMPTY")
    
    # Let's check the actual formula bar by looking at cell.data_type
    print("\n=== CHECKING CELL TYPES ===")
    for cell_ref in check_cells:
        cell = ws_sum[cell_ref]
        if cell.value:
            print(f"{cell_ref}: {cell.value} (type: {type(cell.value).__name__})")
            if cell.data_type == 'f':  # Formula
                print(f"  -> Is a formula")
        else:
            print(f"{cell_ref}: EMPTY")