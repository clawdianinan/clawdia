#!/usr/bin/env python3
import sys
import os
sys.path.insert(0, '/Users/clawdia/.openclaw/workspace/skills/mail-attachments/scripts')
from mail_attachments import MailAttachments

ma = MailAttachments(debug=True)

# Search for the email with Maiduguri logo
print("Searching for email with subject containing 'MAIDGURI'...")
emails = ma.search(subject="MAIDGURI", days=30)
print(f"Found {len(emails)} emails")

for email in emails:
    print(f"\nEmail ID: {email['id']}")
    print(f"Subject: {email['subject']}")
    print(f"Date: {email['date']}")
    print(f"Sender: {email['sender']}")
    
    # Get attachments
    attachments = ma.get_attachments(email['id'])
    print(f"Attachments: {len(attachments)}")
    
    for att in attachments:
        print(f"  - {att['name']} ({att['size']} bytes)")
        
        # Download attachment
        output_dir = "/Users/clawdia/.openclaw/workspace/ihs_logo_attachments"
        os.makedirs(output_dir, exist_ok=True)
        
        saved_path = ma.download_attachment(
            email['id'], 
            att['name'], 
            output_dir
        )
        print(f"    Downloaded to: {saved_path}")