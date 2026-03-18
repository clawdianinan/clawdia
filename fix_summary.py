#!/usr/bin/env python3
import openpyxl
from openpyxl import load_workbook
from openpyxl.utils import get_column_letter

# Load the workbook
wb = load_workbook('IIH_Roles_and_Grades_20260224_FINAL_CORRECTED_20260224_1839.xlsx')
ws_sum = wb['Summary']
ws_rev = wb['Revised']

print("=== FIXING SUMMARY SHEET ===\n")

# First, let's understand the Revised sheet structure
# Gender is column H (8), Origin is column I (9)
# We need to count based on certain conditions

# Find the last row in Revised sheet
last_row = ws_rev.max_row
print(f"Revised sheet has {last_row} rows")

# Count total rows (excluding header)
total_entries = last_row - 1  # minus header
print(f"Total entries: {total_entries}")

# Let's manually count to understand the data
male_count = 0
female_count = 0
kwara_count = 0
non_kwara_count = 0

core_staff_male = 0
core_staff_female = 0
core_staff_kwara = 0
core_staff_non_kwara = 0

all_staff_male = 0
all_staff_female = 0
all_staff_kwara = 0
all_staff_non_kwara = 0

# We need to understand what counts as "core staff" vs "all staff"
# Looking at the data, it seems "core staff" excludes interns/corpers
# Interns/Corpers might be marked in column A or have specific indicators

for row in range(2, last_row + 1):
    gender = ws_rev.cell(row=row, column=8).value  # Column H
    origin = ws_rev.cell(row=row, column=9).value  # Column I
    role = ws_rev.cell(row=row, column=1).value    # Column A (IIH Role)
    name = ws_rev.cell(row=row, column=7).value    # Column G (Name)
    
    # Check if this is core staff (not intern/corper)
    # Based on the data preview, interns/corpers might be marked differently
    # Let's check for "intern" or "corper" in the role
    is_core = True
    if role and isinstance(role, str):
        role_lower = role.lower()
        if 'intern' in role_lower or 'corper' in role_lower or 'nysc' in role_lower:
            is_core = False
    
    # Count gender
    if gender == 'M':
        male_count += 1
        all_staff_male += 1
        if is_core:
            core_staff_male += 1
    elif gender == 'F':
        female_count += 1
        all_staff_female += 1
        if is_core:
            core_staff_female += 1
    
    # Count origin
    if origin == 'Kwara':
        kwara_count += 1
        all_staff_kwara += 1
        if is_core:
            core_staff_kwara += 1
    elif origin and origin != 'TBD':  # Count as non-Kwara if it's specified but not Kwara
        non_kwara_count += 1
        all_staff_non_kwara += 1
        if is_core:
            core_staff_non_kwara += 1

print(f"Gender counts - Male: {male_count}, Female: {female_count}")
print(f"Origin counts - Kwara: {kwara_count}, Non-Kwara: {non_kwara_count}")
print(f"Core staff gender - Male: {core_staff_male}, Female: {core_staff_female}")
print(f"Core staff origin - Kwara: {core_staff_kwara}, Non-Kwara: {core_staff_non_kwara}")

# Now let's update the summary sheet
print("\n=== UPDATING SUMMARY SHEET ===")

# First, let's add percentage columns to Gender Distribution
# Current structure:
# Row 10: "Gender Distribution"
# Row 11: "Group", "Male", "Female"
# Row 12: "Core Staff" 
# Row 13: "All (Core+Interns+Corpers)"

# We need to add "Male %" and "Female %" columns
# Let's add them in columns D and E (since C is Female)

# Update headers
ws_sum['D11'] = 'Male %'
ws_sum['E11'] = 'Female %'

print("Added 'Male %' and 'Female %' headers")

# Now let's add formulas for Core Staff (row 12)
# Male count formula for core staff
ws_sum['B12'] = f'=COUNTIFS(Revised!H:H,"M",Revised!A:A,"<>*intern*",Revised!A:A,"<>*corper*",Revised!A:A,"<>*NYSC*")'

# Female count formula for core staff  
ws_sum['C12'] = f'=COUNTIFS(Revised!H:H,"F",Revised!A:A,"<>*intern*",Revised!A:A,"<>*corper*",Revised!A:A,"<>*NYSC*")'

# Male percentage for core staff
ws_sum['D12'] = '=IF(B12+C12>0, B12/(B12+C12), 0)'
ws_sum['D12'].number_format = '0.0%'

# Female percentage for core staff
ws_sum['E12'] = '=IF(B12+C12>0, C12/(B12+C12), 0)'
ws_sum['E12'].number_format = '0.0%'

print("Added Core Staff gender formulas")

# Now for All Staff (row 13)
# Male count for all staff
ws_sum['B13'] = '=COUNTIF(Revised!H:H,"M")'

# Female count for all staff
ws_sum['C13'] = '=COUNTIF(Revised!H:H,"F")'

# Male percentage for all staff
ws_sum['D13'] = '=IF(B13+C13>0, B13/(B13+C13), 0)'
ws_sum['D13'].number_format = '0.0%'

# Female percentage for all staff
ws_sum['E13'] = '=IF(B13+C13>0, C13/(B13+C13), 0)'
ws_sum['E13'].number_format = '0.0%'

print("Added All Staff gender formulas")

# Now let's also fix the Origin Distribution formulas which are empty
# Row 17: Core Staff
ws_sum['B17'] = f'=COUNTIFS(Revised!I:I,"Kwara",Revised!A:A,"<>*intern*",Revised!A:A,"<>*corper*",Revised!A:A,"<>*NYSC*")'
ws_sum['C17'] = f'=COUNTIFS(Revised!I:I,"<>",Revised!I:I,"<>Kwara",Revised!I:I,"<>TBD",Revised!A:A,"<>*intern*",Revised!A:A,"<>*corper*",Revised!A:A,"<>*NYSC*")'
ws_sum['E17'] = '=IF(B17+C17>0, B17/(B17+C17), 0)'
ws_sum['E17'].number_format = '0.0%'
ws_sum['F17'] = '=IF(B17+C17>0, C17/(B17+C17), 0)'
ws_sum['F17'].number_format = '0.0%'

print("Fixed Core Staff origin formulas")

# Row 18: All Staff
ws_sum['B18'] = '=COUNTIF(Revised!I:I,"Kwara")'
ws_sum['C18'] = '=COUNTIFS(Revised!I:I,"<>",Revised!I:I,"<>Kwara",Revised!I:I,"<>TBD")'
ws_sum['E18'] = '=IF(B18+C18>0, B18/(B18+C18), 0)'
ws_sum['E18'].number_format = '0.0%'
ws_sum['F18'] = '=IF(B18+C18>0, C18/(B18+C18), 0)'
ws_sum['F18'].number_format = '0.0%'

print("Fixed All Staff origin formulas")

# Also fix the population counts if they're empty
# These are likely in B5, B6, B7, B8
if not ws_sum['B5'].value:  # Total Core Staff
    ws_sum['B5'] = '=COUNTIFS(Revised!A:A,"<>*intern*",Revised!A:A,"<>*corper*",Revised!A:A,"<>*NYSC*")'

if not ws_sum['B6'].value:  # Total Interns
    ws_sum['B6'] = '=COUNTIF(Revised!A:A,"*intern*")'

if not ws_sum['B7'].value:  # Total Corpers  
    ws_sum['B7'] = '=COUNTIF(Revised!A:A,"*corper*") + COUNTIF(Revised!A:A,"*NYSC*")'

if not ws_sum['B8'].value:  # Total People (All)
    ws_sum['B8'] = '=COUNTA(Revised!A:A)-1'  # minus header

print("Fixed population count formulas")

# Save the updated workbook
output_file = 'IIH_Roles_and_Grades_20260224_FINAL_CORRECTED_WITH_GENDER_PERCENTAGES.xlsx'
wb.save(output_file)

print(f"\n✅ Saved updated workbook as: {output_file}")
print("\n=== SUMMARY OF CHANGES ===")
print("1. Added 'Male %' and 'Female %' columns to Gender Distribution section")
print("2. Added formulas for gender counts and percentages")
print("3. Fixed origin distribution formulas")
print("4. Fixed population count formulas")
print("\nGender percentages now match the format of origin percentages.")