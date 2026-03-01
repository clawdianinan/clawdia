#!/bin/bash
# Evening Wrap-up Script
# End of day summary

set -e

# Configuration
LOG_FILE="/tmp/evening_wrapup.log"
TIME_NOW=$(date '+%H:%M')

# Function to log
log() {
    echo "[$(date '+%H:%M:%S')] $1" >> "$LOG_FILE"
}

# Get today's accomplishments
get_accomplishments() {
    log "Checking accomplishments"
    
    local todo_script="scripts/todo.sh"
    local done_count=0
    
    if [[ -f "$todo_script" ]]; then
        if todos=$(bash "$todo_script" entry list --status=done 2>/dev/null); then
            done_count=$(echo "$todos" | wc -l | tr -d ' ')
            if [[ "$done_count" -gt 1 ]]; then
                echo "🎉 Completed $((done_count - 1)) tasks today"
                echo "$todos" | tail -n +2 | head -3 | while read line; do
                    echo "  • $(echo "$line" | cut -d'|' -f4 | xargs)"
                done
            else
                echo "📝 No tasks marked as done today"
            fi
        fi
    fi
    
    # If no done tasks, check pending
    if [[ "$done_count" -le 1 ]]; then
        if [[ -f "$todo_script" ]]; then
            if todos=$(bash "$todo_script" entry list --status=pending 2>/dev/null); then
                local pending_count=$(echo "$todos" | wc -l | tr -d ' ')
                if [[ "$pending_count" -gt 1 ]]; then
                    echo "📋 $((pending_count - 1)) tasks carried to tomorrow"
                fi
            fi
        fi
    fi
}

# Get accurate email summary
get_email_summary() {
    log "Getting accurate evening email summary"
    
    if command -v himalaya >/dev/null 2>&1; then
        if emails_json=$(himalaya envelope list --limit 20 --output json 2>/dev/null); then
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
                echo "📧 All emails addressed"
            elif [[ "$iih_count" -gt 0 ]]; then
                echo "📧 $unread_count unread remaining ($iih_count IIH)"
            else
                echo "📧 $unread_count unread emails remaining"
            fi
        fi
    fi
}

# Generate wrap-up
generate_wrapup() {
    log "Generating evening wrap-up"
    
    local wrapup="🌙 EVENING WRAP-UP - $(date '+%A, %B %d')\n"
    wrapup+="Time: $TIME_NOW\n"
    wrapup+="────────────────────\n\n"
    
    wrapup+="$(get_accomplishments)\n\n"
    wrapup+="$(get_email_summary)\n\n"
    
    # Tomorrow preview
    wrapup+="🔮 TOMORROW PREVIEW:\n"
    wrapup+="• Review morning digest at 7:00 AM\n"
    wrapup+="• Check for urgent emails first\n"
    wrapup+="• Plan top 3 priorities\n\n"
    
    wrapup+="💤 Good night! Rest well for tomorrow."
    
    echo -e "$wrapup"
}

# Main execution
main() {
    log "=== Evening wrap-up started ==="
    
    local wrapup
    wrapup=$(generate_wrapup)

    # Idempotency guard to avoid duplicate outbound sends
    if printf "%s" "$wrapup" | /Users/clawdia/.openclaw/workspace/scripts/message_idempotency_guard.sh imessage temikolawole@icloud.com 300; then
        echo -e "$wrapup"
        log "Evening wrap-up generated successfully"
    else
        log "Duplicate evening wrap-up detected within window; skipping output"
    fi
    
    log "=== Evening wrap-up completed ==="
}

# Run main
main "$@"