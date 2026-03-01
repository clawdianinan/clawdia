#!/bin/bash
# Regular Update Script
# Quick status check every 3 hours

set -e

# Configuration
LOG_FILE="/tmp/regular_update.log"
TIME_NOW=$(date '+%H:%M')

# Function to log
log() {
    echo "[$(date '+%H:%M:%S')] $1" >> "$LOG_FILE"
}

# Accurate email check
quick_email_check() {
    if command -v himalaya >/dev/null 2>&1; then
        if emails_json=$(himalaya envelope list --limit 8 --output json 2>/dev/null); then
            local unread_count=0
            local iih_count=0
            local email_count=$(echo "$emails_json" | jq 'length')
            
            for i in $(seq 0 $((email_count - 1))); do
                local email=$(echo "$emails_json" | jq -r ".[$i]")
                local flags=$(echo "$email" | jq -r '.flags')
                local from=$(echo "$email" | jq -r '.from')
                
                if [[ "$flags" != *"Seen"* ]]; then
                    ((unread_count++))
                    if [[ "$from" == *"@iih.ng"* ]]; then
                        ((iih_count++))
                    fi
                fi
            done
            
            # Accurate reporting
            if [[ "$unread_count" -eq 0 ]]; then
                echo "📭 No new emails"
            elif [[ "$iih_count" -gt 0 ]]; then
                echo "📬 $unread_count new ($iih_count IIH)"
            else
                echo "📬 $unread_count new emails"
            fi
        else
            echo "📧 Email check failed"
        fi
    else
        echo "📧 Email system offline"
    fi
}

# Quick todo check
quick_todo_check() {
    local todo_script="scripts/todo.sh"
    
    if [[ -f "$todo_script" ]]; then
        if todos=$(bash "$todo_script" entry list --status=pending 2>/dev/null); then
            local todo_count=$(echo "$todos" | wc -l | tr -d ' ')
            if [[ "$todo_count" -gt 1 ]]; then
                echo "✅ $((todo_count - 1)) tasks pending"
            else
                echo "✅ All tasks completed"
            fi
        else
            echo "✅ Todo check failed"
        fi
    else
        echo "✅ Todo system offline"
    fi
}

# Next calendar event from macOS Calendar
next_calendar_event() {
    # AppleScript to get next event
    local apple_script='tell application "Calendar"
        set now to current date
        set later to now + (12 * hours)
        
        set nextEvent to missing value
        set nextTime to missing value
        
        repeat with cal in calendars
            set calName to name of cal
            if calName contains "IIH" or calName contains "Zoho" or calName contains "temi" or calName contains "temi.kolawole" then
                set theseEvents to (every event of cal whose start date ≥ now and start date ≤ later)
                if (count of theseEvents) > 0 then
                    set ev to first item of theseEvents
                    set nextEvent to summary of ev
                    set nextTime to start date of ev
                    exit repeat
                end if
            end if
        end repeat
        
        if nextEvent is missing value then
            return "📅 No upcoming events"
        else
            set timeStr to (time string of nextTime)
            return "📅 Next: " & timeStr & " - " & nextEvent
        end if
    end tell'
    
    # Execute AppleScript
    local result
    if result=$(osascript -e "$apple_script" 2>/dev/null); then
        echo "$result"
    else
        echo "📅 Calendar check failed"
    fi
}

# Generate update
generate_update() {
    log "Generating regular update"
    
    local update="🔄 STATUS UPDATE - $TIME_NOW\n"
    update+="────────────────\n\n"
    
    update+="$(quick_email_check)\n"
    update+="$(quick_todo_check)\n"
    update+="$(next_calendar_event)\n\n"
    
    update+="💡 Reply 'digest' for full details"
    
    echo -e "$update"
}

# Main execution
main() {
    log "=== Regular update started ==="
    
    local update
    update=$(generate_update)

    # Idempotency guard to avoid duplicate outbound sends
    if printf "%s" "$update" | /Users/clawdia/.openclaw/workspace/scripts/message_idempotency_guard.sh imessage temikolawole@icloud.com 180; then
        echo -e "$update"
        log "Regular update generated successfully"
    else
        log "Duplicate regular update detected within window; skipping output"
    fi
    
    log "=== Regular update completed ==="
}

# Run main
main "$@"