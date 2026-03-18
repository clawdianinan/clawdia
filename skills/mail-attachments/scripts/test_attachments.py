#!/usr/bin/env python3
"""
Test script for Mail Attachments skill
"""

import sys
import os
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent))

from mail_attachments import MailAttachments

def test_basic_functionality():
    """Test basic functionality of the mail attachments skill"""
    print("=== Testing Mail Attachments Skill ===\n")
    
    ma = MailAttachments(debug=True)
    
    # Test 1: Search for recent emails with attachments
    print("1. Searching for recent emails with attachments...")
    emails = ma.search_emails(days=7, has_attachment=True, limit=5)
    
    if emails:
        print(f"   Found {len(emails)} emails with attachments")
        for i, email in enumerate(emails, 1):
            print(f"   {i}. ID: {email.get('id')}, Subject: {email.get('subject', 'No subject')[:50]}...")
        
        # Test 2: Get attachments for first email
        first_email_id = emails[0]['id']
        print(f"\n2. Getting attachments for email ID {first_email_id}...")
        
        attachments = ma.get_attachments_via_applescript(first_email_id)
        if attachments:
            print(f"   Found {len(attachments)} attachments:")
            for att in attachments:
                print(f"     • {att.get('name', 'Unknown')}")
            
            # Test 3: Download first attachment (if any)
            if attachments:
                test_dir = Path.home() / "Downloads" / "test_attachments"
                test_dir.mkdir(exist_ok=True)
                
                print(f"\n3. Testing download to {test_dir}...")
                downloaded = ma.download_all_attachments(first_email_id, test_dir)
                
                if downloaded:
                    print(f"   Downloaded {len(downloaded)} files:")
                    for path in downloaded:
                        print(f"     ✓ {os.path.basename(path)}")
                else:
                    print("   No files downloaded (might be permission issue)")
        else:
            print("   No attachments found (or AppleScript access issue)")
    
    else:
        print("   No emails found with attachments in last 7 days")
    
    # Test 4: Search for specific types
    print("\n4. Testing search filters...")
    
    # Search for PDFs
    pdf_emails = ma.search_emails(days=30, attachment_type="pdf", limit=3)
    if pdf_emails:
        print(f"   Found {len(pdf_emails)} emails with PDF attachments")
    
    # Search by sender
    test_sender = ma.search_emails(days=7, sender="@", limit=2)
    if test_sender:
        print(f"   Found {len(test_sender)} emails from senders with '@'")
    
    print("\n=== Testing Complete ===")
    print("\nCommon issues and solutions:")
    print("1. If 'No attachments found' but fruitmail shows attachments:")
    print("   - Check Mail.app is running")
    print("   - Grant Terminal automation access to Mail.app")
    print("   - System Preferences → Security & Privacy → Privacy → Automation")
    print("   - Check 'Mail' for Terminal")
    print("\n2. If fruitmail not found:")
    print("   - Install: npm install -g apple-mail-search-cli")
    print("\n3. If AppleScript errors:")
    print("   - Try: sudo tccutil reset AppleEvents")
    print("   - Then re-grant permissions")

def test_permissions():
    """Test AppleScript permissions"""
    print("\n=== Testing AppleScript Permissions ===")
    
    # Simple AppleScript test
    test_script = '''
    tell application "Mail"
        get name of every account
    end tell
    '''
    
    try:
        import subprocess
        result = subprocess.run(
            ["osascript", "-e", test_script],
            capture_output=True,
            text=True
        )
        
        if result.returncode == 0:
            print("✓ AppleScript access to Mail.app is working")
            if result.stdout.strip():
                print(f"  Mail accounts: {result.stdout.strip()}")
        else:
            print("✗ AppleScript access failed")
            print(f"  Error: {result.stderr}")
            
    except Exception as e:
        print(f"✗ AppleScript test failed: {e}")

def test_fruitmail_installation():
    """Test fruitmail installation"""
    print("\n=== Testing fruitmail Installation ===")
    
    try:
        import subprocess
        result = subprocess.run(
            ["fruitmail", "--version"],
            capture_output=True,
            text=True
        )
        
        if result.returncode == 0:
            print(f"✓ fruitmail installed: {result.stdout.strip()}")
        else:
            print("✗ fruitmail not working properly")
            print(f"  Error: {result.stderr}")
            
    except FileNotFoundError:
        print("✗ fruitmail not found in PATH")
        print("  Install with: npm install -g apple-mail-search-cli")

if __name__ == "__main__":
    print("Mail Attachments Skill Test Suite")
    print("=" * 40)
    
    test_fruitmail_installation()
    test_permissions()
    test_basic_functionality()
    
    print("\nTo use this skill in your workflows:")
    print("1. Import: from mail_attachments import MailAttachments")
    print("2. Create instance: ma = MailAttachments()")
    print("3. Search: emails = ma.search_emails(days=7, has_attachment=True)")
    print("4. Download: ma.download_attachment(email_id, 'filename.pdf')")
    
    # Example integration
    print("\nExample integration with email auto-processor:")
    print('''
# In your email processing script:
from mail_attachments import MailAttachments

ma = MailAttachments()

# Find emails needing attachment processing
emails = ma.search_emails(
    sender="@iih.ng",
    has_attachment=True,
    days=30
)

for email in emails:
    # Download attachments
    downloaded = ma.download_all_attachments(
        email['id'],
        output_dir="~/Documents/IIH/Attachments/"
    )
    
    # Process each downloaded file
    for file_path in downloaded:
        if file_path.endswith('.pdf'):
            # Process PDF
            pass
        elif file_path.endswith('.docx'):
            # Process Word doc
            pass
    ''')