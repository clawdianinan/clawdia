#!/usr/bin/env python3
import json
import sys

# Read JSON from stdin
data = json.load(sys.stdin)

# Filter for IIH-related emails
iih_emails = []
for email in data:
    sender = email.get('sender', '').lower()
    subject = email.get('subject', '').lower()
    
    # Check if sender is from IIH domain or subject contains IIH
    if '@iih.ng' in sender or 'iih' in subject:
        iih_emails.append(email)

# Print filtered results
for email in iih_emails:
    print(f"ID: {email['id']} | Date: {email['date']} | Sender: {email['sender']} | Subject: {email['subject']}")