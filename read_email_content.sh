#!/bin/bash
# Read FULL email content and extract instructions

set -e

echo "=== READING FULL EMAIL CONTENT ==="
echo ""

# Try to read email ID 46 (your organogram email)
echo "Attempting to read email ID 46 (New IIH Organogram)..."

# Method 1: Try himalaya read command
echo "Method 1: Using himalaya read command..."
email_content=$(himalaya read 46 2>&1)

if [[ $? -eq 0 ]] && [[ -n "$email_content" ]]; then
    echo "✅ Successfully read email content"
    echo ""
    echo "=== EMAIL CONTENT (first 500 chars) ==="
    echo "$email_content" | head -c 500
    echo "..."
    echo "======================================"
else
    echo "❌ Could not read with himalaya read"
    echo "Error: $email_content"
fi

echo ""
echo "=== INSTRUCTION PROCESSING NEEDED ==="
echo ""
echo "PROBLEM: himalaya CLI doesn't provide easy access to full email body"
echo ""
echo "SOLUTIONS:"
echo ""
echo "1. USE APPLE MAIL SCRIPTING (Recommended)"
cat << 'EOF'
   Use AppleScript to read emails directly from Mail.app:
   
   tell application "Mail"
     set theMessage to first message of inbox whose subject contains "New IIH Organogram"
     set emailBody to content of theMessage
     return emailBody
   end tell
EOF

echo ""
echo "2. CONFIGURE HIMALAYA PROPERLY"
echo "   himalaya needs proper configuration to output full message content"
echo "   Current issue: Only shows headers, not body"

echo ""
echo "3. USE PYTHON IMAP LIBRARY"
echo "   Write Python script to connect directly to IMAP and read emails"

echo ""
echo "=== IMMEDIATE ACTION ==="
echo ""
echo "Since I can't read the full email content via himalaya, I need to:"
echo ""
echo "1. Ask you: What instruction was in the 'New IIH Organogram' email?"
echo "2. Implement that instruction immediately"
echo "3. Set up proper email content reading for future"

echo ""
echo "Please tell me what instruction was in your email so I can execute it now."