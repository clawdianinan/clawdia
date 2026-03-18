#!/bin/bash
# OpenClaw Gateway Watchdog
# Monitors and automatically restarts OpenClaw if it stops

set -euo pipefail

# Configuration
GATEWAY_PROCESS="openclaw gateway"
MAX_RESTART_ATTEMPTS=3
RESTART_COOLDOWN=300  # 5 minutes between restart attempts
LOG_FILE="/Users/clawdia/.openclaw/workspace/logs/gateway-watchdog.log"
STATE_FILE="/Users/clawdia/.openclaw/workspace/logs/gateway-state.json"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Function to log
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to check if OpenClaw is running
check_openclaw_running() {
    if pgrep -f "$GATEWAY_PROCESS" >/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to get gateway status
get_gateway_status() {
    if command -v openclaw >/dev/null 2>&1; then
        export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
        if openclaw gateway status 2>&1 | grep -q "running"; then
            echo "running"
        else
            echo "stopped"
        fi
    else
        echo "cli_not_found"
    fi
}

# Function to restart OpenClaw
restart_openclaw() {
    log "Attempting to restart OpenClaw gateway..."
    
    export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
    
    # Try to stop if running
    if check_openclaw_running; then
        log "Stopping existing OpenClaw process..."
        openclaw gateway stop 2>/dev/null || true
        sleep 2
    fi
    
    # Start OpenClaw
    log "Starting OpenClaw gateway..."
    if openclaw gateway start 2>&1 | tee -a "$LOG_FILE"; then
        log "OpenClaw gateway started successfully"
        return 0
    else
        log "Failed to start OpenClaw gateway"
        return 1
    fi
}

# Function to update state
update_state() {
    local status=$1
    local action=${2:-""}
    local timestamp=$(date -Iseconds)
    
    cat > "$STATE_FILE" << EOF
{
  "status": "$status",
  "last_action": "$action",
  "last_check": "$timestamp",
  "restart_attempts": $(get_restart_attempts),
  "last_restart": "$(get_last_restart)"
}
EOF
}

# Function to get restart attempts
get_restart_attempts() {
    if [[ -f "/tmp/openclaw_restart_attempts" ]]; then
        cat "/tmp/openclaw_restart_attempts"
    else
        echo "0"
    fi
}

# Function to increment restart attempts
increment_restart_attempts() {
    local current=$(get_restart_attempts)
    echo $((current + 1)) > "/tmp/openclaw_restart_attempts"
}

# Function to reset restart attempts
reset_restart_attempts() {
    echo "0" > "/tmp/openclaw_restart_attempts"
}

# Function to get last restart time
get_last_restart() {
    if [[ -f "/tmp/openclaw_last_restart" ]]; then
        cat "/tmp/openclaw_last_restart"
    else
        echo "never"
    fi
}

# Function to update last restart time
update_last_restart() {
    date -Iseconds > "/tmp/openclaw_last_restart"
}

# Function to check if we should attempt restart
should_attempt_restart() {
    local attempts=$(get_restart_attempts)
    
    # Check max attempts
    if [[ $attempts -ge $MAX_RESTART_ATTEMPTS ]]; then
        log "Max restart attempts ($MAX_RESTART_ATTEMPTS) reached. Waiting for cooldown."
        return 1
    fi
    
    # Check cooldown
    local last_restart=$(get_last_restart)
    if [[ "$last_restart" != "never" ]]; then
        local last_restart_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S%z" "$last_restart" "+%s" 2>/dev/null || echo 0)
        local current_epoch=$(date "+%s")
        local time_since_restart=$((current_epoch - last_restart_epoch))
        
        if [[ $time_since_restart -lt $RESTART_COOLDOWN ]]; then
            log "Still in cooldown period. $((RESTART_COOLDOWN - time_since_restart)) seconds remaining."
            return 1
        fi
    fi
    
    return 0
}

# Function to send HITL alert
send_alert() {
    local message=$1
    
    log "Sending HITL alert: $message"
    
    if command -v openclaw >/dev/null 2>&1; then
        export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
        openclaw message send --channel imessage --target temikolawole@icloud.com \
            --message "🚨 OpenClaw Alert: $message" \
            --best-effort 2>/dev/null || true
    fi
}

# Main watchdog logic
main() {
    log "=== OpenClaw Gateway Watchdog Check ==="
    
    # Check if OpenClaw is running
    if check_openclaw_running; then
        log "OpenClaw gateway is running ✓"
        update_state "running" "monitoring"
        reset_restart_attempts
        return 0
    else
        log "OpenClaw gateway is NOT running ✗"
        update_state "stopped" "detected"
        
        # Get detailed status
        local detailed_status=$(get_gateway_status)
        log "Detailed status: $detailed_status"
        
        # Check if we should attempt restart
        if should_attempt_restart; then
            log "Attempting automatic restart..."
            
            # Attempt restart
            if restart_openclaw; then
                log "Restart successful"
                update_state "running" "restarted"
                update_last_restart
                increment_restart_attempts
                
                # Send success alert if this was after failures
                local attempts=$(get_restart_attempts)
                if [[ $attempts -gt 1 ]]; then
                    send_alert "Gateway recovered after $attempts attempts"
                fi
                
                return 0
            else
                log "Restart failed"
                update_state "stopped" "restart_failed"
                increment_restart_attempts
                update_last_restart
                
                # Send alert if max attempts reached
                local attempts=$(get_restart_attempts)
                if [[ $attempts -ge $MAX_RESTART_ATTEMPTS ]]; then
                    send_alert "Gateway restart failed $attempts times. Manual intervention needed."
                fi
                
                return 1
            fi
        else
            log "Skipping restart (cooldown or max attempts)"
            return 1
        fi
    fi
}

# Run main function
main "$@"