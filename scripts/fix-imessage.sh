#!/bin/bash
# iMessage Diagnostic and Fix Script

set -e

echo "🔧 iMessage Diagnostic Tool"
echo "==========================="
echo ""

# Check 1: imsg CLI
echo "1. Checking imsg CLI..."
if command -v imsg >/dev/null 2>&1; then
    echo "   ✅ imsg found: $(which imsg)"
    imsg_version=$(imsg --version 2>/dev/null || echo "unknown")
    echo "   Version: $imsg_version"
else
    echo "   ❌ imsg not found in PATH"
    exit 1
fi

echo ""

# Check 2: OpenClaw iMessage configuration
echo "2. Checking OpenClaw iMessage configuration..."
if [[ -f ~/.openclaw/openclaw.json ]]; then
    imessage_enabled=$(grep -A 5 '"imessage"' ~/.openclaw/openclaw.json | grep '"enabled"' | grep -o 'true\|false' || echo "not found")
    echo "   iMessage enabled: $imessage_enabled"
    
    # Check accounts
    accounts_count=$(grep -c '"allowFrom"' ~/.openclaw/openclaw.json || echo "0")
    echo "   Configured accounts: $accounts_count"
    
    if [[ $accounts_count -gt 0 ]]; then
        echo "   Allowed senders:"
        grep -A 10 '"allowFrom"' ~/.openclaw/openclaw.json | grep -v '"allowFrom"' | grep -v '^\[' | grep -v '\]' | sed 's/^/     - /'
    fi
else
    echo "   ❌ OpenClaw configuration not found"
fi

echo ""

# Check 3: Test message delivery
echo "3. Testing message delivery..."
echo "   Testing to temikolawole@icloud.com..."

# Test with imsg directly
if imsg send --to "temikolawole@icloud.com" --text "iMessage diagnostic test from imsg CLI" >/dev/null 2>&1; then
    echo "   ✅ imsg CLI delivery successful"
else
    echo "   ❌ imsg CLI delivery failed"
fi

echo ""

# Check 4: Chat IDs
echo "4. Checking available chats..."
imsg chats 2>/dev/null | while read -r line; do
    if [[ $line =~ \[([0-9]+)\] ]]; then
        chat_id="${BASH_REMATCH[1]}"
        echo "   Chat ID $chat_id: ${line#*] }"
    fi
done

echo ""

# Check 5: OpenClaw message tool
echo "5. Testing OpenClaw message tool..."
if command -v openclaw >/dev/null 2>&1; then
    echo "   Testing with phone number..."
    if openclaw message send --channel imessage --target "+2348155555222" --message "OpenClaw diagnostic test" --json >/dev/null 2>&1; then
        echo "   ✅ OpenClaw phone delivery successful"
    else
        echo "   ❌ OpenClaw phone delivery failed"
    fi
    
    echo "   Testing with email..."
    if openclaw message send --channel imessage --target "temikolawole@icloud.com" --message "OpenClaw diagnostic test" --json >/dev/null 2>&1; then
        echo "   ✅ OpenClaw email delivery successful"
    else
        echo "   ❌ OpenClaw email delivery failed"
    fi
else
    echo "   ❌ OpenClaw CLI not found"
fi

echo ""

# Check 6: Cron job delivery configuration
echo "6. Checking cron job configuration..."
if openclaw cron list >/dev/null 2>&1; then
    cron_count=$(openclaw cron list 2>/dev/null | grep -c "enabled.*true" || echo "0")
    echo "   Enabled cron jobs: $cron_count"
    
    # Check delivery settings
    echo "   Cron delivery settings:"
    openclaw cron list 2>/dev/null | grep -A 3 -B 3 "delivery" || echo "     No delivery settings found"
else
    echo "   ❌ Unable to check cron jobs"
fi

echo ""

# Fix recommendations
echo "🔧 Fix Recommendations"
echo "====================="

# Check if doctor needs to be run
if grep -q "Doctor changes" ~/.openclaw/openclaw.json 2>/dev/null; then
    echo "1. Run OpenClaw doctor:"
    echo "   openclaw doctor --fix"
    echo ""
fi

# Check for common issues
echo "2. Common issues to check:"
echo "   - Ensure Messages app is running"
echo "   - Check AppleScript permissions for Messages"
echo "   - Verify internet connection"
echo "   - Restart OpenClaw gateway if needed"
echo ""

# Create test script
echo "3. Quick test command:"
echo "   openclaw message send --channel imessage --target \"temikolawole@icloud.com\" --message \"Test message\""
echo ""

echo "✅ Diagnostic complete"
echo ""
echo "If messages still fail:"
echo "1. Check Messages app is open and signed in"
echo "2. Grant terminal full disk access in System Settings"
echo "3. Restart OpenClaw: openclaw gateway restart"
echo ""

exit 0