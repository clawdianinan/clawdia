#!/usr/bin/env python3
"""
Test the fixed mail attachments script
"""

import sys
import os
from pathlib import Path

# Add the scripts directory to path
sys.path.insert(0, str(Path(__file__).parent / "skills" / "mail-attachments" / "scripts"))

from mail_attachments import MailAttachments

def main():
    print("Testing Fixed Mail Attachments Script")
    print("=" * 50)
    
    ma = MailAttachments(debug=True)
    
    # Test 1: Search for the specific email
    print("\n1. Searching for email ID 298...")
    emails = ma.search_emails(days=1, limit=10)
    
    target_email = None
    for email in emails:
        if email.get('id') == 298:
            target_email = email
            break
    
    if target_email:
        print(f"   Found: {target_email.get('subject')}")
        print(f"   From: {target_email.get('sender_address')}")
        print(f"   Date: {target_email.get('date_received')}")
    else:
        print("   Email 298 not found in recent emails")
        # Try broader search
        print("   Trying broader search...")
        emails = ma.search_emails(days=7, limit=50)
        for email in emails:
            if email.get('id') == 298:
                target_email = email
                print(f"   Found in 7-day search: {email.get('subject')}")
                break
    
    if not target_email:
        print("   ❌ Email 298 not found at all")
        return
    
    # Test 2: Get attachments
    print("\n2. Getting attachments for email 298...")
    attachments = ma.get_attachments_via_applescript(298)
    
    if attachments:
        print(f"   Found {len(attachments)} attachments:")
        for i, att in enumerate(attachments, 1):
            print(f"     {i}. {att.get('name', 'Unknown')} (ID: {att.get('id', 'N/A')})")
        
        # Test 3: Try to download first attachment
        print("\n3. Testing download...")
        test_dir = Path.home() / "Downloads" / "test_email_attachments"
        test_dir.mkdir(exist_ok=True)
        
        first_att = attachments[0]
        att_name = first_att.get('name')
        if att_name:
            print(f"   Attempting to download: {att_name}")
            downloaded = ma.download_attachment(298, att_name, test_dir)
            if downloaded:
                print(f"   ✅ Downloaded: {downloaded}")
            else:
                print(f"   ❌ Download failed")
    else:
        print("   No attachments found or AppleScript error")
        
        # Try alternative approach - check if email has attachments via fruitmail
        print("\n   Checking via fruitmail...")
        email_body = ma.get_email_body(298)
        if email_body:
            # Look for attachment references in body
            if "attachment" in email_body.lower() or ".pdf" in email_body.lower() or ".doc" in email_body.lower():
                print("   Email body mentions attachments")
                print(f"   Body preview: {email_body[:200]}...")
            else:
                print("   No attachment references in email body")
    
    # Test 4: Try with a different email that definitely has attachments
    print("\n4. Searching for any email with attachments...")
    emails_with_attachments = ma.search_emails(days=7, has_attachment=True, limit=5)
    
    if emails_with_attachments:
        print(f"   Found {len(emails_with_attachments)} emails with attachments")
        for i, email in enumerate(emails_with_attachments[:3], 1):
            print(f"     {i}. ID: {email.get('id')}, Subject: {email.get('subject', 'No subject')[:50]}...")
            
            # Test this email
            email_id = email.get('id')
            print(f"       Getting attachments for ID {email_id}...")
            atts = ma.get_attachments_via_applescript(email_id)
            if atts:
                print(f"       Found {len(atts)} attachments")
                for att in atts[:2]:  # Show first 2
                    print(f"         • {att.get('name', 'Unknown')}")
            else:
                print(f"       No attachments found via AppleScript")
    else:
        print("   No emails with attachments found in last 7 days")
    
    print("\n" + "=" * 50)
    print("\nSummary:")
    print("1. AppleScript can access Mail.app accounts ✓")
    print("2. Need to test with actual email that has attachments")
    print("3. If no attachments found, possible reasons:")
    print("   - Email doesn't actually have attachments")
    print("   - AppleScript permissions need to be granted in Script Editor")
    print("   - Email ID might be different than expected")
    
    print("\nNext steps:")
    print("1. Open Script Editor and run the simple test script")
    print("2. If prompted, grant permissions to Mail.app")
    print("3. Try the script with a known email that has attachments")
    print("4. Check Mail.app directly for email 298 attachments")

if __name__ == "__main__":
    main()