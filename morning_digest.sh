#!/bin/bash
# Morning Digest Script
# Collects: Calendar, Emails, Todos, Reminders

set -e

# Configuration
LOG_FILE="/tmp/morning_digest.log"
TODAY=$(date '+%Y-%m-%d')
TIME_NOW=$(date '+%H:%M')

# Function to log
log() {
    echo "[$(date '+%H:%M:%S')] $1" >> "$LOG_FILE"
}

# Get today's calendar events (primary: gog, fallback: macOS Calendar)
get_calendar_events() {
    log "Getting calendar events for $TODAY"

    # Primary path: gog (Google Calendar)
    if command -v gog >/dev/null 2>&1; then
        if gog auth list 2>/dev/null | grep -q "default"; then
            local gog_events
            gog_events=$(gog calendar events --today --account default 2>/dev/null || true)
            if [[ -n "${gog_events// }" ]]; then
                echo "$gog_events" | sed 's/^/• /'
                return 0
            else
                echo "• No calendar events today"
                return 0
            fi
        else
            echo "• Calendar auth warning: gog token not configured"
        fi
    else
        echo "• Calendar auth warning: gog CLI not installed"
    fi

    # Fallback: macOS Calendar via AppleScript
    local calendar_events=""
    local apple_script='tell application "Calendar"
        set todayStart to current date
        set time of todayStart to 0
        set todayEnd to todayStart + (1 * days)
        set eventList to ""
        set eventCount to 0
        repeat with cal in calendars
            set calName to name of cal
            if calName contains "IIH" or calName contains "Zoho" or calName contains "temi" or calName contains "temi.kolawole" then
                set theseEvents to (every event of cal whose start date ≥ todayStart and end date ≤ todayEnd)
                repeat with ev in theseEvents
                    set eventCount to eventCount + 1
                    set startTime to start date of ev
                    set summaryText to summary of ev
                    set timeStr to (time string of startTime)
                    set eventList to eventList & "• " & timeStr & " - " & summaryText & "
"
                end repeat
            end if
        end repeat
        if eventCount = 0 then
            return "• No calendar events today"
        else
            return eventList
        end if
    end tell'

    if calendar_events=$(osascript -e "$apple_script" 2>/dev/null); then
        echo "$calendar_events"
    else
        echo "• Calendar fallback unavailable"
    fi
}

# Get accurate email summary
get_email_summary() {
    log "Getting accurate email summary"
    
    if command -v himalaya >/dev/null 2>&1; then
        local unread_count=0
        local iih_count=0
        local external_count=0
        
        # Quick check of recent emails
        if emails_json=$(himalaya envelope list --limit 15 --output json 2>/dev/null); then
            local email_count=$(echo "$emails_json" | jq 'length')
            
            for i in $(seq 0 $((email_count - 1))); do
                local email=$(echo "$emails_json" | jq -r ".[$i]")
                local flags=$(echo "$email" | jq -r '.flags')
                local from=$(echo "$email" | jq -r '.from')
                
                if [[ "$flags" != *"Seen"* ]]; then
                    ((unread_count++))
                    
                    # Categorize emails accurately
                    if [[ "$from" == *"@iih.ng"* ]]; then
                        ((iih_count++))
                    elif [[ "$from" != *"@iih.ng"* ]]; then
                        ((external_count++))
                    fi
                fi
            done
            
            # Generate accurate summary
            if [[ "$unread_count" -eq 0 ]]; then
                echo "📭 No unread emails"
            elif [[ "$iih_count" -gt 0 ]] && [[ "$external_count" -gt 0 ]]; then
                echo "📬 $unread_count unread ($iih_count IIH, $external_count external)"
            elif [[ "$iih_count" -gt 0 ]]; then
                echo "📬 $unread_count unread ($iih_count IIH internal)"
            elif [[ "$external_count" -gt 0 ]]; then
                echo "📬 $unread_count unread ($external_count external)"
            else
                echo "📬 $unread_count unread emails"
            fi
        else
            echo "📧 Email check failed"
        fi
    else
        echo "📧 himalaya not installed"
    fi
}

# Get todo list with smart categorization
get_todos() {
    log "Getting todo list with smart categorization"
    
    local todo_script="scripts/todo.sh"
    
    if [[ -f "$todo_script" ]]; then
        if todos=$(bash "$todo_script" entry list --status=pending 2>/dev/null); then
            local todo_count=$(echo "$todos" | wc -l | tr -d ' ')
            if [[ "$todo_count" -gt 1 ]]; then
                # Count by group
                local temi_count=$(echo "$todos" | grep "Temi" | wc -l)
                local iih_count=$(echo "$todos" | grep "IIH" | wc -l)
                local system_count=$(echo "$todos" | grep "System" | wc -l)
                local inbox_count=$((todo_count - 1 - temi_count - iih_count - system_count))
                
                echo "✅ $((todo_count - 1)) tasks"
                if [[ $temi_count -gt 0 ]]; then
                    echo "  • $temi_count from your emails"
                fi
                if [[ $iih_count -gt 0 ]]; then
                    echo "  • $iih_count IIH internal"
                fi
                if [[ $system_count -gt 0 ]]; then
                    echo "  • $system_count system tasks"
                fi
                
                # Show smart-extracted tasks first
                echo ""
                echo "📋 SMART EXTRACTED TASKS:"
                echo "$todos" | tail -n +2 | grep -E "(Temi|IIH)" | head -3 | while read line; do
                    task_desc=$(echo "$line" | awk -F'|' '{print $4}' | xargs)
                    echo "  • $task_desc"
                done
            else
                echo "✅ No pending tasks"
            fi
        else
            echo "✅ Todo system not initialized"
        fi
    else
        echo "✅ Todo script not found"
    fi
}

# Get reminders
get_reminders() {
    log "Getting reminders"
    
    if command -v remindctl >/dev/null 2>&1; then
        if reminders=$(remindctl list --due "$TODAY" 2>/dev/null); then
            local reminder_count=$(echo "$reminders" | wc -l | tr -d ' ')
            if [[ "$reminder_count" -gt 0 ]]; then
                echo "⏰ $reminder_count reminders due today"
            else
                echo "⏰ No reminders due today"
            fi
        else
            echo "⏰ remindctl not configured"
        fi
    else
        echo "⏰ Apple Reminders not available"
    fi
}

# Generate the full digest
generate_digest() {
    log "Generating morning digest"
    
    local digest="🌅 MORNING DIGEST - $(date '+%A, %B %d, %Y')\n"
    digest+="Generated at: $TIME_NOW\n"
    digest+="────────────────────────\n\n"
    
    # Calendar Section
    digest+="📅 TODAY'S CALENDAR:\n"
    digest+="$(get_calendar_events)\n\n"
    
    # Email Section
    digest+="📧 EMAIL STATUS:\n"
    digest+="$(get_email_summary)\n\n"
    
    # Todo Section
    digest+="✅ TODAY'S TODOS:\n"
    digest+="$(get_todos)\n\n"
    
    # Reminders Section
    digest+="⏰ REMINDERS:\n"
    digest+="$(get_reminders)\n\n"
    
    # Focus suggestion
    digest+="🎯 SUGGESTED FOCUS:\n"
    digest+="1. Check urgent emails first\n"
    digest+="2. Review calendar meetings\n"
    digest+="3. Tackle highest priority todo\n\n"
    
    digest+="💡 Tip: Reply 'update' for a midday check-in"
    
    echo -e "$digest"
}

# Main execution
main() {
    log "=== Morning digest started ==="
    
    local digest
    digest=$(generate_digest)

    # Idempotency guard to avoid duplicate outbound sends
    if printf "%s" "$digest" | /Users/clawdia/.openclaw/workspace/scripts/message_idempotency_guard.sh imessage temikolawole@icloud.com 300; then
        echo -e "$digest"
        log "Morning digest generated successfully"
    else
        log "Duplicate morning digest detected within window; skipping output"
    fi
    
    log "=== Morning digest completed ==="
}

# Run main
main "$@"