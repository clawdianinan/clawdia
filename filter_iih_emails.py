#!/usr/bin/env python3
import json
import sys

# Read the JSON data
with open('/tmp/emails_today.json', 'r') as f:
    emails = json.load(f)

# Filter for IIH/IHS related emails
iih_emails = []
for email in emails:
    sender = email.get('sender', '').lower()
    subject = email.get('subject', '').lower()
    mailbox = email.get('mailbox', '')
    
    # Check if it's IIH/IHS related
    if ('iih' in sender or 'ihstowers' in sender or 
        'iih' in subject or 'ihs' in subject or
        'temi.kolawole@iih.ng' in sender or
        'clawdia.ai@iih.ng' in sender or
        'admin@iih.ng' in sender):
        iih_emails.append(email)

# Print results
print(f"Found {len(iih_emails)} IIH/IHS related emails from today:")
for email in iih_emails:
    print(f"ID: {email['id']}, Date: {email['date']}, Sender: {email['sender']}, Subject: {email['subject']}, Mailbox: {email['mailbox']}")