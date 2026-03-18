#!/usr/bin/env python3
"""
Test specific email ID for attachment access
"""

import sys
import os
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent))

from mail_attachments import MailAttachments

def test_email_298():
    """Test email ID 298 (MAIDGURI HUB- LOGO)"""
    print("Testing Email ID 298: MAIDGURI HUB- LOGO")
    print("=" * 50)
    
    ma = MailAttachments(debug=True)
    
    # First, let's check what fruitmail says about this email
    print("\n1. Getting email info from fruitmail...")
    emails = ma.search_emails(days=1, limit=10)
    
    target_email = None
    for email in emails:
        if email.get('id') == 298:
            target_email = email
            break
    
    if target_email:
        print(f"   Found email: {target_email.get('subject')}")
        print(f"   From: {target_email.get('sender_name')} <{target_email.get('sender_address')}>")
        print(f"   Date: {target_email.get('date_received')}")
        print(f"   Has attachment: {target_email.get('has_attachment', False)}")
    else:
        print("   Email 298 not found in recent emails")
        return
    
    # Try AppleScript with different approaches
    print("\n2. Testing AppleScript access...")
    
    # Approach 1: Simple AppleScript to check if Mail.app is accessible
    simple_test = '''
    tell application "Mail"
        get count of messages
    end tell
    '''
    
    try:
        import subprocess
        result = subprocess.run(
            ["osascript", "-e", simple_test],
            capture_output=True,
            text=True
        )
        print(f"   Mail.app message count: {result.stdout.strip()}")
    except Exception as e:
        print(f"   Simple AppleScript failed: {e}")
    
    # Approach 2: Try to get attachments with corrected AppleScript
    print("\n3. Trying to get attachments...")
    
    # Let's write a simpler AppleScript to a file and run it
    applescript = '''
tell application "Mail"
    try
        set theMessage to message id 298
        set attachmentCount to count of every attachment of theMessage
        return "Attachments found: " & attachmentCount
    on error errMsg
        return "Error: " & errMsg
    end try
end tell
'''
    
    # Write to temp file
    import tempfile
    with tempfile.NamedTemporaryFile(mode='w', suffix='.scpt', delete=False) as f:
        f.write(applescript)
        script_path = f.name
    
    try:
        result = subprocess.run(
            ["osascript", script_path],
            capture_output=True,
            text=True
        )
        print(f"   Result: {result.stdout.strip()}")
        if result.stderr:
            print(f"   Error: {result.stderr}")
    finally:
        os.unlink(script_path)
    
    # Approach 3: Try to open the email in Mail.app
    print("\n4. Trying to open email in Mail.app...")
    open_result = ma.open_email_in_mail(298)
    print(f"   Open result: {open_result}")
    
    # Approach 4: Try different AppleScript syntax
    print("\n5. Testing alternative AppleScript syntax...")
    
    alt_script = '''
tell application "Mail"
    set msgID to 298
    set allMessages to every message
    repeat with aMessage in allMessages
        if id of aMessage is msgID then
            set atts to every attachment of aMessage
            set attNames to {}
            repeat with anAtt in atts
                set end of attNames to name of anAtt
            end repeat
            return attNames
        end if
    end repeat
    return "Message not found"
end tell
'''
    
    with tempfile.NamedTemporaryFile(mode='w', suffix='.scpt', delete=False) as f:
        f.write(alt_script)
        script_path = f.name
    
    try:
        result = subprocess.run(
            ["osascript", script_path],
            capture_output=True,
            text=True
        )
        print(f"   Alternative script result: {result.stdout.strip()}")
    finally:
        os.unlink(script_path)

def check_permissions():
    """Check and fix permissions"""
    print("\n" + "=" * 50)
    print("Checking permissions...")
    
    # Check if Terminal has Automation access
    print("\n1. Checking Terminal automation access...")
    
    # This command lists all apps with Mail access
    check_cmd = '''
    sqlite3 ~/Library/Application\ Support/com.apple.TCC/TCC.db "SELECT client FROM access WHERE service='kTCCServiceAppleEvents' AND indirect_object_identifier='com.apple.mail' AND auth_value=2;"
    '''
    
    try:
        result = subprocess.run(
            ["bash", "-c", check_cmd],
            capture_output=True,
            text=True
        )
        if "Terminal" in result.stdout or "com.apple.Terminal" in result.stdout:
            print("   ✓ Terminal has Mail automation access")
        else:
            print("   ✗ Terminal does NOT have Mail automation access")
            print("   Run: sudo tccutil reset AppleEvents com.apple.Terminal")
            print("   Then grant access in System Preferences")
    except Exception as e:
        print(f"   Could not check permissions: {e}")
    
    # Try to reset permissions
    print("\n2. Attempting to reset permissions...")
    try:
        result = subprocess.run(
            ["sudo", "tccutil", "reset", "AppleEvents", "com.apple.Terminal"],
            capture_output=True,
            text=True
        )
        print(f"   Reset command executed: {result.returncode == 0}")
    except Exception as e:
        print(f"   Could not reset permissions (may need password): {e}")

if __name__ == "__main__":
    test_email_298()
    check_permissions()
    
    print("\n" + "=" * 50)
    print("\nNext steps:")
    print("1. If permissions need resetting, run the sudo command above")
    print("2. Open System Preferences → Security & Privacy → Privacy → Automation")
    print("3. Check 'Mail' for Terminal")
    print("4. Restart Terminal and test again")
    print("\nAlternative: Use AppleScript Editor to test:")
    print("   Open Script Editor")
    print("   Paste: tell app \"Mail\" to get every attachment of message id 298")
    print("   Run it - if it works, grant permissions when prompted")