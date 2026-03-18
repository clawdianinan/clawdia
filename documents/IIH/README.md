# IIH Roles and Grades Documentation

## Files Created:
1. **IIH_Roles_and_Grades.csv** - CSV template for staff directory
2. **IIH_Roles_and_Grades_TEMPLATE.md** - Detailed structure guide
3. **create_excel.py** - Python script to generate Excel file (requires pandas)
4. **New_Roles_for_Hiring.md** - Placeholder for new hiring roles (awaiting attachments)

## Organogram Files (Updated: February 27, 2026):
The latest IIH organogram structure has been saved in the `organogram/` directory:

1. **IIH Organogram.drawio (1).pdf** - Draw.io PDF version
2. **IIH Organogram.drawio.png** - Draw.io PNG version  
3. **IIH Organogram.jpg** - JPG version
4. **1749122382045004_1686933120.png** - Additional organogram image

Location: `/Users/clawdia/.openclaw/workspace/Documents/IIH/organogram/`

## How to Create the Excel File:

### Option 1: Manual Creation in Excel
1. Open **IIH_Roles_and_Grades.csv** in Excel
2. Save as `IIH_Roles_and_Grades.xlsx`
3. Create additional sheets:
   - **Grade Structure** (grading levels, salary ranges)
   - **Departments** (departmental structure)
   - **State Analysis** (state of origin breakdown)

### Option 2: Install pandas and run script
```bash
pip install pandas openpyxl
cd /Users/clawdia/.openclaw/workspace/documents/IIH
python3 create_excel.py
```

## Current Data Status:

### Staff with Confirmed State of Origin:
1. **Amidat Olalere** - Kwara State ✓
2. **Emmanuel Farayade** - Oyo State ✓

### Pending Information:
- Position titles for all staff
- Department assignments  
- Grade levels
- Remaining state of origin data
- Salary ranges for grade structure
- Department heads and staff counts

## Document Structure Requirements:

### 1. Staff Directory Sheet
- Employee ID (IIH-XXX format)
- Full Name
- Position
- Department
- Grade Level (G1-G8)
- State of Origin **(recently updated)**
- Date of Joining
- Employment Status
- Contact Information

### 2. Grade Structure Sheet
- Grade Levels (G1-G8)
- Position Titles
- Salary Ranges (Min-Max)
- Key Responsibilities
- Qualifications Required
- Reporting Lines

### 3. Departments Sheet
- Department Names
- Head of Department
- Number of Staff
- Key Functions
- Budget Codes

### 4. State of Origin Analysis
- State breakdown
- Staff counts per state
- Percentage distribution
- Key positions per state

## Next Actions:
1. Complete the Excel file with all sheets
2. Populate with current staff data
3. Review grade levels and salary ranges
4. Update organizational structure based on new organogram
5. Regular quarterly maintenance
6. Review and update organogram as organizational changes occur

## File Location:
`/Users/clawdia/.openclaw/workspace/documents/IIH/`