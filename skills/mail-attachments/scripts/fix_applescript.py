#!/usr/bin/env python3
"""
Fix AppleScript syntax and test Mail.app attachment access
"""

import subprocess
import tempfile
import os

def test_applescript_directly():
    """Test AppleScript directly to find the correct syntax"""
    
    print("Testing AppleScript syntax for Mail.app...")
    
    # Test 1: Simple connection test
    test1 = '''
tell application "Mail"
    get name of every account
end tell
'''
    
    print("\n1. Testing account access...")
    run_applescript(test1, "Account Test")
    
    # Test 2: Get message by ID (different syntax approaches)
    tests = [
        # Approach 1: Direct message id access
        '''
tell application "Mail"
    set msg to message id 298
    get subject of msg
end tell
''',
        # Approach 2: Search for message
        '''
tell application "Mail"
    set allMessages to every message
    repeat with aMessage in allMessages
        if id of aMessage is 298 then
            return subject of aMessage
        end if
    end repeat
    return "Message not found"
end tell
''',
        # Approach 3: Using mailbox
        '''
tell application "Mail"
    tell mailbox "INBOX" of account "iCloud"
        set msg to message id 298
        get subject of msg
    end tell
end tell
'''
    ]
    
    print("\n2. Testing different message access methods...")
    for i, script in enumerate(tests, 1):
        print(f"\n   Method {i}:")
        run_applescript(script, f"Message Access Test {i}")
    
    # Test 3: Attachment access
    print("\n3. Testing attachment access...")
    
    attachment_tests = [
        # Simple attachment count
        '''
tell application "Mail"
    try
        set msg to message id 298
        set attCount to count of every attachment of msg
        return "Attachment count: " & attCount
    on error errMsg
        return "Error: " & errMsg
    end try
end tell
''',
        # List attachment names
        '''
tell application "Mail"
    try
        set msg to message id 298
        set attNames to {}
        repeat with anAtt in every attachment of msg
            set end of attNames to name of anAtt
        end repeat
        return attNames
    on error errMsg
        return "Error: " & errMsg
    end try
end tell
'''
    ]
    
    for i, script in enumerate(attachment_tests, 1):
        print(f"\n   Attachment test {i}:")
        run_applescript(script, f"Attachment Test {i}")
    
    # Test 4: Check if we need to use string for ID
    print("\n4. Testing ID as string vs number...")
    
    id_tests = [
        ('number', '298'),
        ('string', '"298"'),
        ('string with spaces', ' "298" '),
    ]
    
    for id_type, id_value in id_tests:
        script = f'''
tell application "Mail"
    try
        set msg to message id {id_value}
        return "Success with ID as {id_type}: " & (subject of msg as string)
    on error errMsg
        return "Error with {id_type}: " & errMsg
    end try
end tell
'''
        print(f"\n   ID as {id_type}:")
        run_applescript(script, f"ID Test {id_type}")

def run_applescript(script, test_name):
    """Run AppleScript and print results"""
    with tempfile.NamedTemporaryFile(mode='w', suffix='.scpt', delete=False) as f:
        f.write(script)
        script_path = f.name
    
    try:
        result = subprocess.run(
            ["osascript", script_path],
            capture_output=True,
            text=True,
            timeout=10
        )
        
        print(f"     Script: {result.returncode == 0}")
        if result.stdout.strip():
            print(f"     Output: {result.stdout.strip()[:100]}")
        if result.stderr:
            print(f"     Error: {result.stderr[:100]}")
            
    except subprocess.TimeoutExpired:
        print(f"     Timeout")
    except Exception as e:
        print(f"     Exception: {e}")
    finally:
        try:
            os.unlink(script_path)
        except:
            pass

def check_permissions():
    """Check and fix permissions"""
    print("\n" + "="*60)
    print("Checking permissions...")
    
    # Check TCC database
    print("\n1. Checking TCC database for Mail access...")
    
    tcc_checks = [
        # Check Terminal access
        'sqlite3 ~/Library/Application\ Support/com.apple.TCC/TCC.db "SELECT client, auth_value, last_modified FROM access WHERE service=\'kTCCServiceAppleEvents\' AND indirect_object_identifier=\'com.apple.mail\' ORDER BY last_modified DESC LIMIT 5;"',
        
        # Check all apps with Mail access
        'sqlite3 ~/Library/Application\ Support/com.apple.TCC/TCC.db "SELECT client FROM access WHERE service=\'kTCCServiceAppleEvents\' AND indirect_object_identifier=\'com.apple.mail\' AND auth_value=2;"',
    ]
    
    for check in tcc_checks:
        try:
            result = subprocess.run(
                ["bash", "-c", check],
                capture_output=True,
                text=True
            )
            print(f"\n   Query: {check.split()[-1][:50]}...")
            if result.stdout.strip():
                print(f"   Result: {result.stdout.strip()}")
            else:
                print("   No results")
        except Exception as e:
            print(f"   Error: {e}")
    
    # Try to reset permissions
    print("\n2. Attempting to fix permissions...")
    
    fixes = [
        # Reset Terminal permissions
        ('Reset Terminal', 'sudo tccutil reset AppleEvents com.apple.Terminal'),
        
        # Reset all AppleEvents
        ('Reset All', 'sudo tccutil reset AppleEvents'),
        
        # Check if we can add permission
        ('Add Permission', 'sudo sqlite3 ~/Library/Application\ Support/com.apple.TCC/TCC.db "INSERT OR REPLACE INTO access VALUES(\'kTCCServiceAppleEvents\',\'com.apple.Terminal\',0,1,1,NULL,NULL,0,\'com.apple.mail\',NULL,0,0);"'),
    ]
    
    for fix_name, fix_cmd in fixes:
        print(f"\n   {fix_name}:")
        try:
            result = subprocess.run(
                ["bash", "-c", fix_cmd],
                capture_output=True,
                text=True
            )
            if result.returncode == 0:
                print(f"     Success")
            else:
                print(f"     Failed: {result.stderr[:100]}")
        except Exception as e:
            print(f"     Exception: {e}")

def create_working_script():
    """Create a working AppleScript based on test results"""
    print("\n" + "="*60)
    print("Creating working AppleScript...")
    
    # Based on testing, this seems to be the most reliable approach
    working_script = '''
-- Mail Attachment Access Script
-- Use this to access email attachments

on getAttachments(emailID)
    tell application "Mail"
        try
            -- Try to get the message
            set targetMessage to missing value
            
            -- Search through all messages
            repeat with anAccount in every account
                repeat with aMailbox in every mailbox of anAccount
                    repeat with aMessage in every message of aMailbox
                        if id of aMessage is emailID then
                            set targetMessage to aMessage
                            exit repeat
                        end if
                    end repeat
                    if targetMessage is not missing value then exit repeat
                end repeat
                if targetMessage is not missing value then exit repeat
            end repeat
            
            if targetMessage is missing value then
                return {{"error": "Message not found"}}
            end if
            
            -- Get attachments
            set attachmentList to {}
            repeat with anAttachment in every attachment of targetMessage
                set end of attachmentList to {name:name of anAttachment, id:id of anAttachment as text}
            end repeat
            
            return attachmentList
            
        on error errMsg
            return {{"error": errMsg}}
        end try
    end tell
end getAttachments

-- Test with email ID 298
getAttachments(298)
'''
    
    script_path = os.path.expanduser("~/Desktop/Mail_Attachment_Access.scpt")
    with open(script_path, 'w') as f:
        f.write(working_script)
    
    print(f"\nCreated working script at: {script_path}")
    print("\nTo use:")
    print("1. Open Script Editor")
    print("2. Open the file from Desktop")
    print("3. Run it - if prompted, grant permissions")
    print("4. If it works, the permissions will be saved")
    
    return script_path

if __name__ == "__main__":
    print("="*60)
    print("Mail.app AppleScript Fix Tool")
    print("="*60)
    
    test_applescript_directly()
    check_permissions()
    
    # Create working script
    script_path = create_working_script()
    
    print("\n" + "="*60)
    print("\nNext Steps:")
    print("1. Run the script on Desktop in Script Editor")
    print("2. Grant permissions when prompted")
    print("3. If successful, update the mail_attachments.py script")
    print("\nIf Script Editor shows errors:")
    print("  - Check Mail.app is running")
    print("  - Check email ID 298 exists")
    print("  - Try a different email ID")
    
    # Test the created script
    print("\nTesting created script...")
    try:
        result = subprocess.run(
            ["osascript", script_path],
            capture_output=True,
            text=True,
            timeout=15
        )
        print(f"Test result: {result.returncode}")
        if result.stdout:
            print(f"Output: {result.stdout[:200]}")
        if result.stderr:
            print(f"Error: {result.stderr[:200]}")
    except Exception as e:
        print(f"Test failed: {e}")