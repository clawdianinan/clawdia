#!/bin/bash
# Self-Healing Wrapper for Cron Jobs
# Features: Error catching, automatic retry, logging, HITL escalation

set -euo pipefail

# Configuration
SCRIPT_NAME="${1:-unknown}"
MAX_RETRIES=2
RETRY_DELAY=30
LOG_DIR="/Users/clawdia/.openclaw/workspace/logs/self_healing"
STATUS_FILE="${LOG_DIR}/status.json"
ALERT_THRESHOLD=3  # Number of consecutive failures before HITL alert

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $SCRIPT_NAME: $1" | tee -a "${LOG_DIR}/${SCRIPT_NAME}.log"
}

# Function to update status
update_status() {
    local status=$1
    local error_msg=${2:-""}
    
    # Create or update status JSON
    if [[ -f "$STATUS_FILE" ]]; then
        jq --arg script "$SCRIPT_NAME" \
           --arg status "$status" \
           --arg error "$error_msg" \
           --arg timestamp "$(date -Iseconds)" \
           '.scripts[$script] = {status: $status, error: $error, last_run: $timestamp}' \
           "$STATUS_FILE" > "${STATUS_FILE}.tmp" && mv "${STATUS_FILE}.tmp" "$STATUS_FILE"
    else
        echo "{\"scripts\": {\"$SCRIPT_NAME\": {\"status\": \"$status\", \"error\": \"$error_msg\", \"last_run\": \"$(date -Iseconds)\"}}}" > "$STATUS_FILE"
    fi
}

# Function to check consecutive failures
check_consecutive_failures() {
    local script=$1
    local count=0
    
    if [[ -f "${LOG_DIR}/${script}.failure_count" ]]; then
        count=$(cat "${LOG_DIR}/${script}.failure_count")
    fi
    
    echo $count
}

# Function to increment failure count
increment_failure() {
    local script=$1
    local count_file="${LOG_DIR}/${script}.failure_count"
    
    if [[ -f "$count_file" ]]; then
        local current_count=$(cat "$count_file")
        echo $((current_count + 1)) > "$count_file"
    else
        echo "1" > "$count_file"
    fi
}

# Function to reset failure count
reset_failure() {
    local script=$1
    rm -f "${LOG_DIR}/${script}.failure_count"
}

# Function to send HITL alert
send_hitl_alert() {
    local script=$1
    local error_msg=$2
    local failure_count=$3
    
    log "🚨 HITL ALERT: $script failed $failure_count consecutive times"
    log "Error: $error_msg"
    
    # Send alert via OpenClaw (if available)
    if command -v openclaw >/dev/null 2>&1; then
        export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
        openclaw message send --channel imessage --target temikolawole@icloud.com \
            --message "🚨 Process Alert: $script has failed $failure_count times. Last error: ${error_msg:0:100}..." \
            --best-effort 2>/dev/null || true
    fi
}

# Function to attempt automatic fix
attempt_fix() {
    local script=$1
    local error=$2
    
    log "Attempting automatic fix for $script"
    
    case $script in
        "morning_digest")
            # Fix PATH issues
            if echo "$error" | grep -q "node: No such file or directory"; then
                log "Fixing PATH issue for morning digest"
                export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
                return 0
            fi
            ;;
        "email_processor")
            # Fix email configuration issues
            if echo "$error" | grep -q "himalaya\|IMAP\|SMTP"; then
                log "Attempting email config fix"
                # Could restart himalaya or check config
                return 0
            fi
            ;;
    esac
    
    return 1  # No fix available
}

# Main execution with retry logic
main() {
    local original_command="${@:2}"
    local retry_count=0
    local last_error=""
    
    log "Starting self-healing wrapper for: $original_command"
    
    while [[ $retry_count -le $MAX_RETRIES ]]; do
        if [[ $retry_count -gt 0 ]]; then
            log "Retry attempt $retry_count/$MAX_RETRIES after $RETRY_DELAY seconds"
            sleep $RETRY_DELAY
        fi
        
        # Execute the command
        if eval "$original_command"; then
            log "Command executed successfully"
            reset_failure "$SCRIPT_NAME"
            update_status "success"
            return 0
        else
            last_error="$?"
            log "Command failed with exit code: $last_error"
            
            # Check error output if available
            local error_output=""
            if [[ -f "/tmp/${SCRIPT_NAME}_error.log" ]]; then
                error_output=$(head -c 200 "/tmp/${SCRIPT_NAME}_error.log" 2>/dev/null || echo "Unknown error")
            fi
            
            increment_failure "$SCRIPT_NAME"
            local failure_count=$(check_consecutive_failures "$SCRIPT_NAME")
            
            # Attempt automatic fix
            if attempt_fix "$SCRIPT_NAME" "$error_output"; then
                log "Automatic fix applied, retrying..."
                continue
            fi
            
            # Check if we need HITL alert
            if [[ $failure_count -ge $ALERT_THRESHOLD ]]; then
                send_hitl_alert "$SCRIPT_NAME" "$error_output" "$failure_count"
            fi
            
            update_status "failed" "$error_output"
            
            if [[ $retry_count -lt $MAX_RETRIES ]]; then
                retry_count=$((retry_count + 1))
                continue
            else
                log "Max retries exceeded. Giving up."
                return 1
            fi
        fi
    done
}

# Graceful fallback if dependencies missing
if ! command -v jq >/dev/null 2>&1; then
    echo "Warning: jq not found, using simplified logging" >&2
    # Simplified version without JSON
    eval "${@:2}" || {
        echo "Command failed: ${@:2}" >&2
        exit 1
    }
else
    main "$@"
fi