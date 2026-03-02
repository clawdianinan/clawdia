#!/usr/bin/env python3
import json
import os

# Path to cron jobs file
cron_file = "/Users/clawdia/.openclaw/cron/jobs.json"

# Read the current cron jobs
with open(cron_file, 'r') as f:
    data = json.load(f)

# Find and update the email auto-processor job
for job in data['jobs']:
    if job['id'] == '54a989a6-a3fc-4ee8-9cfe-bea1d012660e':
        print(f"Found email auto-processor job: {job['name']}")
        
        # Update the payload message
        job['payload']['message'] = """Execute the corrected email auto-processor logic: 
1) Check for new emails from Temi's accounts (temi@iih.ng, temi.kolawole@iih.ng, temikolawole@icloud.com, temikolawole@gmail.com). 
2) For emails FROM Temi: read full content via AppleScript, extract 'please/kindly/can you' instructions, and EXECUTE them directly (file updates, system configs, document prep). 
3) For other emails: create appropriate todos. 
Example: 'New IIH Organogram' email → update Documents/IIH folder, not create todo. 
Use the corrected_email_auto_processor.sh script at /Users/clawdia/.openclaw/workspace/corrected_email_auto_processor.sh."""
        
        # Update the timestamp
        job['updatedAtMs'] = 1772418714485
        
        print("Updated email auto-processor job payload")
        break

# Write back the updated cron jobs
with open(cron_file, 'w') as f:
    json.dump(data, f, indent=2)

print(f"Successfully updated {cron_file}")