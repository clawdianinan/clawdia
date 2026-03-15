#!/bin/bash
# Evening Wrap-up Script
# End of day summary - Ensures single execution with file locking

set -e

# Configuration
LOG_FILE="/tmp/evening_wrapup.log"
TIME_NOW=$(date '+%H:%M')
LOCK_FILE="/tmp/evening_wrapup.lock"
LOCK_TIMEOUT=300  # 5 minutes in seconds
DAILY_MARKER_FILE="/tmp/evening_wrapup.$(date +%Y%m%d).marker"

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

# Robust file locking to ensure single execution
acquire_lock() {
    local lockfile="$1"
    local timeout="$2"
    local pid=$$
    local start_time=$(date +%s)
    
    while true; do
        # Try to create lock file with our PID
        if (set -o noclobber; echo "$pid" > "$lockfile") 2>/dev/null; then
            log "Lock acquired for PID $pid"
            return 0
        fi
        
        # Check if lock is stale (process no longer running)
        local locked_pid
        if locked_pid=$(cat "$lockfile" 2>/dev/null); then
            if ! kill -0 "$locked_pid" 2>/dev/null; then
                # Process is dead, remove stale lock
                rm -f "$lockfile"
                log "Removed stale lock from dead PID $locked_pid"
                continue
            fi
        fi
        
        # Check timeout
        local current_time=$(date +%s)
        if [[ $((current_time - start_time)) -ge $timeout ]]; then
            log "ERROR: Could not acquire lock within $timeout seconds"
            return 1
        fi
        
        # Wait before retry
        sleep 1
    done
}

release_lock() {
    local lockfile="$1"
    local pid=$$
    
    # Only remove if we own the lock
    local locked_pid
    if locked_pid=$(cat "$lockfile" 2>/dev/null); then
        if [[ "$locked_pid" -eq "$pid" ]]; then
            rm -f "$lockfile"
            log "Lock released for PID $pid"
        else
            log "WARN: Lock file owned by different PID $locked_pid, not releasing"
        fi
    fi
}

# Check if already executed today
already_executed_today() {
    if [[ -f "$DAILY_MARKER_FILE" ]]; then
        local marker_time
        marker_time=$(cat "$DAILY_MARKER_FILE" 2>/dev/null || echo 0)
        local current_time=$(date +%s)
        
        # If marker is from today and less than 4 hours ago, skip
        if [[ $((current_time - marker_time)) -lt 14400 ]]; then  # 4 hours
            return 0
        fi
    fi
    return 1
}

# Mark as executed today
mark_executed_today() {
    date +%s > "$DAILY_MARKER_FILE"
    log "Marked as executed today: $DAILY_MARKER_FILE"
}

# Clean up old marker files (older than 2 days)
cleanup_old_markers() {
    find /tmp -name "evening_wrapup.*.marker" -mtime +2 -delete 2>/dev/null || true
}

# Check if it's evening time (6 PM to 11 PM)
is_evening_time() {
    local current_hour=$(date '+%H')
    if [[ "$current_hour" -ge 18 ]] && [[ "$current_hour" -lt 23 ]]; then
        return 0
    fi
    return 1
}

# Main execution
main() {
    log "=== Evening wrap-up started ==="
    
    # Clean up old markers
    cleanup_old_markers
    
    # Check if already executed today
    if already_executed_today; then
        log "Already executed today, skipping"
        echo "Evening wrap-up already executed today. Skipping."
        return 0
    fi
    
    # Acquire lock to ensure single execution
    if ! acquire_lock "$LOCK_FILE" "$LOCK_TIMEOUT"; then
        log "ERROR: Could not acquire lock, another instance may be running"
        echo "ERROR: Evening wrap-up is already running. Please wait."
        return 1
    fi
    
    # Ensure lock is released on exit
    trap 'release_lock "$LOCK_FILE"' EXIT
    
    # Only run during evening hours (6 PM - 11 PM)
    if ! is_evening_time; then
        local current_hour=$(date '+%H')
        log "Not evening time (current hour: $current_hour), skipping wrap-up"
        echo "Not evening time (current hour: $current_hour). Wrap-up only runs between 6 PM and 11 PM."
        return 0
    fi
    
    local wrapup
    wrapup=$(generate_wrapup)

    # Idempotency guard to avoid duplicate outbound sends
    # Temporarily disable errexit to handle exit code 2 gracefully
    set +e
    printf "%s" "$wrapup" | /Users/clawdia/.openclaw/workspace/scripts/message_idempotency_guard.sh imessage temikolawole@icloud.com 300
    local guard_exit=$?
    set -e
    
    if [[ $guard_exit -eq 0 ]]; then
        echo -e "$wrapup"
        log "Evening wrap-up generated and sent successfully"
        # Mark as executed today only if successfully sent
        mark_executed_today
    elif [[ $guard_exit -eq 2 ]]; then
        log "Duplicate evening wrap-up detected within window; skipping send (normal operation)"
        # Still output the wrapup for logging/debugging
        echo -e "$wrapup"
        # Also mark as executed since we attempted to send
        mark_executed_today
    else
        log "ERROR: Idempotency guard failed with exit code $guard_exit"
        echo -e "$wrapup"
        # Don't mark as executed on error
    fi
    
    log "=== Evening wrap-up completed ==="
}

# Run main
main "$@"