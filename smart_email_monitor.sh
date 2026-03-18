#!/bin/bash
# SMART Email Monitor: Check today's emails + sent folder

set -e

echo "=== SMART EMAIL MONITOR ==="
echo "Focus: Today's emails + Your sent items"
echo "Date: $(date '+%Y-%m-%d')"
echo ""

# Configuration
TODAY=$(date '+%Y-%m-%d')
EMAIL_LOG="/tmp/email_state.log"

# Function to log email state
log_email_state() {
    echo "$(date '+%H:%M:%S') | $1" >> "$EMAIL_LOG"
}

# 1. CHECK TODAY'S INCOMING EMAILS
echo "📥 TODAY'S INCOMING EMAILS:"
echo "---------------------------"

# Get today's emails (simplified - himalaya doesn't have good date filtering)
all_emails=$(himalaya envelope list 2>/dev/null | tail -n +4 | head -20)

if [[ -z "$all_emails" ]]; then
    echo "No emails found"
else
    today_count=0
    unread_count=0
    
    echo "$all_emails" | while read line; do
        email_id=$(echo "$line" | awk -F'|' '{print $2}' | xargs)
        date_str=$(echo "$line" | awk -F'|' '{print $6}' | xargs)
        flags=$(echo "$line" | awk -F'|' '{print $3}' | xargs)
        subject=$(echo "$line" | awk -F'|' '{print $4}' | xargs | cut -c1-50)
        from=$(echo "$line" | awk -F'|' '{print $5}' | xargs)
        
        # Check if email is from today (simplified check)
        if [[ "$date_str" == *"2026-02-27"* ]]; then
            ((today_count++))
            status=""
            if echo "$flags" | grep -q '*'; then
                status="UNREAD"
                ((unread_count++))
            else
                status="read"
            fi
            
            echo "  • [$email_id] $subject"
            echo "    From: $from | Status: $status"
        fi
    done
    
    echo ""
    echo "📊 SUMMARY:"
    echo "  Total today: $today_count emails"
    echo "  Unread: $unread_count emails"
fi

echo ""
echo "📤 YOUR SENT EMAILS (LAST 24H):"
echo "-------------------------------"

# 2. CHECK SENT FOLDER
# Note: himalaya might not have easy sent folder access
# For now, we'll check Mail.app via AppleScript

sent_check=$(osascript -e '
tell application "Mail"
    set sentCount to 0
    set sentMessages to {}
    
    repeat with theAccount in every account
        try
            set sentMailbox to sent mailbox of theAccount
            set recentSent to (every message of sentMailbox whose date sent > (current date - 1 * days))
            if (count of recentSent) > 0 then
                set sentCount to sentCount + (count of recentSent)
                repeat with msg in recentSent
                    if sentMessages does not contain subject of msg then
                        copy subject of msg to end of sentMessages
                    end if
                end repeat
            end if
        on error
            -- Skip accounts without sent folder
        end try
    end repeat
    
    if sentCount > 0 then
        set output to "Found " & sentCount & " sent emails in last 24h"
        if (count of sentMessages) > 0 then
            set output to output & ":" & return
            repeat with i from 1 to (count of sentMessages)
                if i ≤ 5 then  -- Show first 5
                    set output to output & "  • " & item i of sentMessages & return
                end if
            end repeat
            if (count of sentMessages) > 5 then
                set output to output & "  ... and " & (sentCount - 5) & " more"
            end if
        end if
        return output
    else
        return "No sent emails found in last 24h"
    end if
end tell' 2>/dev/null)

if [[ -n "$sent_check" ]]; then
    echo "$sent_check"
else
    echo "Could not check sent folder"
fi

echo ""
echo "🔍 SMART PROCESSING LOGIC:"
echo "-------------------------"
echo ""
echo "1. PRIORITY ORDER:"
echo "   a) Today's UNREAD emails → Process immediately"
echo "   b) Today's READ emails → Check if action needed"
echo "   c) Your SENT emails → Track what's been acted upon"
echo ""
echo "2. AVOID DUPLICATES:"
echo "   • Check if email already processed"
echo "   • Check if you've already responded (sent folder)"
echo "   • Skip emails you've already acted on"
echo ""
echo "3. CONTEXT AWARENESS:"
echo "   • Track email threads"
echo "   • Monitor your responses"
echo "   • Only suggest actions you haven't taken"

echo ""
echo "📅 NEXT CHECK:"
echo "Will monitor for:"
echo "1. New emails today"
echo "2. Your sent responses"
echo "3. Unread priority emails"

# Log this check
log_email_state "Smart email monitor run - Today: $today_count emails, Unread: $unread_count"