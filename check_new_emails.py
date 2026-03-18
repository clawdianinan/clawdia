#!/usr/bin/env python3
import json
from datetime import datetime

# Read the JSON data
with open('/tmp/emails_today.json', 'r') as f:
    emails = json.load(f)

# Last check was at 5:40 PM (17:40)
last_check_time = datetime.strptime("2026-03-02 17:40:00", "%Y-%m-%d %H:%M:%S")

# Filter for IIH/IHS related emails after last check
new_iih_emails = []
for email in emails:
    sender = email.get('sender', '').lower()
    subject = email.get('subject', '').lower()
    mailbox = email.get('mailbox', '')
    
    # Parse email date
    email_time = datetime.strptime(email['date'], "%Y-%m-%d %H:%M:%S")
    
    # Check if it's IIH/IHS related AND after last check
    if (('iih' in sender or 'ihstowers' in sender or 
         'iih' in subject or 'ihs' in subject or
         'temi.kolawole@iih.ng' in sender or
         'clawdia.ai@iih.ng' in sender or
         'admin@iih.ng' in sender) and
        email_time > last_check_time):
        new_iih_emails.append(email)

# Print results
print(f"Found {len(new_iih_emails)} new IIH/IHS related emails since 5:40 PM:")
for email in new_iih_emails:
    print(f"ID: {email['id']}, Date: {email['date']}, Sender: {email['sender']}, Subject: {email['subject']}, Mailbox: {email['mailbox']}")