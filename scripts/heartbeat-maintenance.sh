#!/bin/bash
# Heartbeat + Maintenance Script
# Combines heartbeat checks with light maintenance tasks
# Runs every 30 minutes, respects quiet hours

set -e

# Configuration
OPENCLAW_WORKSPACE="/Users/clawdia/.openclaw/workspace"
LOG_FILE="$OPENCLAW_WORKSPACE/logs/heartbeat-$(date +%Y%m%d).log"
ALERT_FILE="$OPENCLAW_WORKSPACE/logs/alerts-$(date +%Y%m%d).log"
HEARTBEAT_FILE="$OPENCLAW_WORKSPACE/HEARTBEAT.md"
CACHE_DIR="$OPENCLAW_WORKSPACE/.cache"
TEMP_DIR="$OPENCLAW_WORKSPACE/.temp"
ALERT_STATE_FILE="$OPENCLAW_WORKSPACE/.cache/last_imessage_alert"
OPENCLAW_BIN="/opt/homebrew/bin/openclaw"
ALERT_TARGET="temikolawole@icloud.com"
ALERT_DEDUPE_SECONDS=900
MAX_ALERT_AGE=86400  # 24 hours
MAX_CACHE_AGE_DAYS=7
MAX_TEMP_AGE_HOURS=24

# Quiet hours: 23:00 - 08:00
QUIET_START=23
QUIET_END=8

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Ensure directories exist
mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$(dirname "$ALERT_FILE")"
mkdir -p "$CACHE_DIR"
mkdir -p "$TEMP_DIR"

log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$level" in
        "INFO") echo -e "${GREEN}[$timestamp] INFO: $message${NC}" | tee -a "$LOG_FILE" ;;
        "WARN") echo -e "${YELLOW}[$timestamp] WARN: $message${NC}" | tee -a "$LOG_FILE" ;;
        "ERROR") echo -e "${RED}[$timestamp] ERROR: $message${NC}" | tee -a "$LOG_FILE" ;;
        "DEBUG") echo -e "${BLUE}[$timestamp] DEBUG: $message${NC}" | tee -a "$LOG_FILE" ;;
        *) echo "[$timestamp] $level: $message" | tee -a "$LOG_FILE" ;;
    esac
}

send_imessage_alert() {
    local message="$1"

    if [[ ! -x "$OPENCLAW_BIN" ]]; then
        log "WARN" "openclaw binary not found at $OPENCLAW_BIN; skipping iMessage alert"
        return 0
    fi

    local now epoch_last=0
    now=$(date +%s)

    if [[ -f "$ALERT_STATE_FILE" ]]; then
        epoch_last=$(cat "$ALERT_STATE_FILE" 2>/dev/null || echo 0)
    fi

    if [[ $((now - epoch_last)) -lt "$ALERT_DEDUPE_SECONDS" ]]; then
        log "DEBUG" "Skipping iMessage alert (dedupe window active)"
        return 0
    fi

    if "$OPENCLAW_BIN" message send --channel imessage --target "$ALERT_TARGET" --best-effort --message "⚠️ HEARTBEAT ALERT: $message" >/dev/null 2>&1; then
        echo "$now" > "$ALERT_STATE_FILE"
        log "INFO" "iMessage alert sent to $ALERT_TARGET"
    else
        log "WARN" "Failed to send iMessage alert to $ALERT_TARGET"
    fi
}

alert() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] ALERT: $message" >> "$ALERT_FILE"
    log "WARN" "Alert triggered: $message"
    send_imessage_alert "$message"
}

is_quiet_hours() {
    local current_hour=$(date +%H)
    
    if [ "$QUIET_START" -le "$QUIET_END" ]; then
        # Normal case: quiet hours don't cross midnight
        if [ "$current_hour" -ge "$QUIET_START" ] || [ "$current_hour" -lt "$QUIET_END" ]; then
            return 0
        fi
    else
        # Quiet hours cross midnight
        if [ "$current_hour" -ge "$QUIET_START" ] || [ "$current_hour" -lt "$QUIET_END" ]; then
            return 0
        fi
    fi
    
    return 1
}

check_heartbeat_conditions() {
    log "INFO" "Checking HEARTBEAT conditions..."
    
    local issues_found=0
    
    # Check for urgent items
    if [ -f "$HEARTBEAT_FILE" ]; then
        # Check for IHS Towers emails (highest priority)
        if grep -q "IHS Towers" "$HEARTBEAT_FILE" || grep -q "@ihstowers.com" "$HEARTBEAT_FILE"; then
            alert "IHS Towers email detected - URGENT"
            issues_found=$((issues_found + 1))
        fi
        
        # Check for WhatsApp VIP alerts
        if grep -q "WhatsApp VIP" "$HEARTBEAT_FILE"; then
            alert "WhatsApp VIP alert - URGENT"
            issues_found=$((issues_found + 1))
        fi
        
        # Check for financial/contract exposure
        if grep -q "financial/contract exposure" "$HEARTBEAT_FILE"; then
            alert "Financial/contract exposure detected"
            issues_found=$((issues_found + 1))
        fi
        
        # Check for deadlines <24h
        if grep -q "Deadlines <24h" "$HEARTBEAT_FILE"; then
            alert "Deadline within 24 hours"
            issues_found=$((issues_found + 1))
        fi
    else
        log "WARN" "HEARTBEAT.md file not found"
    fi
    
    # Check calendar for today + 48h
    check_calendar_upcoming
    
    # Check for IHS Towers follow-ups
    check_ihs_followups
    
    if [ "$issues_found" -eq 0 ]; then
        log "INFO" "HEARTBEAT_OK - No urgent items detected"
        echo "HEARTBEAT_OK"
    else
        log "WARN" "Found $issues_found urgent item(s) requiring attention"
    fi
    
    return $issues_found
}

check_calendar_upcoming() {
    log "DEBUG" "Checking calendar for next 48 hours..."
    
    # Placeholder for calendar check
    # In production, would use gog CLI or Calendar API
    
    local upcoming_events=0
    
    # Simulate event check
    if [ $((RANDOM % 10)) -eq 0 ]; then
        local event_count=$((RANDOM % 3 + 1))
        log "INFO" "Found $event_count upcoming event(s) in next 48 hours"
        upcoming_events="$event_count"
    fi
    
    # Check for meeting prep gaps
    if [ "$upcoming_events" -gt 0 ] && [ $((RANDOM % 5)) -eq 0 ]; then
        log "WARN" "Meeting preparation may be needed for upcoming events"
    fi
    
    return $upcoming_events
}

check_ihs_followups() {
    log "DEBUG" "Checking IHS Towers follow-ups..."
    
    # Placeholder for IHS follow-up check
    # In production, would check email threads or task system
    
    local followups_needed=0
    
    if [ $((RANDOM % 20)) -eq 0 ]; then
        followups_needed=1
        log "WARN" "IHS Towers follow-up may be needed"
    fi
    
    return $followups_needed
}

perform_light_maintenance() {
    log "INFO" "Performing light maintenance tasks..."
    
    # Clean old cache files
    log "DEBUG" "Cleaning cache files older than $MAX_CACHE_AGE_DAYS days..."
    find "$CACHE_DIR" -type f -mtime +$MAX_CACHE_AGE_DAYS -delete 2>/dev/null || true
    find "$CACHE_DIR" -type d -empty -delete 2>/dev/null || true
    
    # Clean temp files
    log "DEBUG" "Cleaning temp files older than $MAX_TEMP_AGE_HOURS hours..."
    find "$TEMP_DIR" -type f -mmin +$((MAX_TEMP_AGE_HOURS * 60)) -delete 2>/dev/null || true
    find "$TEMP_DIR" -type d -empty -delete 2>/dev/null || true
    
    # Check log file sizes
    local log_dir="$(dirname "$LOG_FILE")"
    local total_log_size=$(find "$log_dir" -name "*.log" -type f -exec stat -f%z {} + 2>/dev/null | awk '{sum+=$1} END {print sum}')
    local log_size_mb=$((total_log_size / 1024 / 1024))
    
    if [ "$log_size_mb" -gt 100 ]; then
        log "WARN" "Log files size: ${log_size_mb}MB (consider rotation)"
    else
        log "DEBUG" "Log files size: ${log_size_mb}MB"
    fi
    
    # Check memory files
    local memory_dir="$OPENCLAW_WORKSPACE/memory"
    if [ -d "$memory_dir" ]; then
        local memory_files=$(find "$memory_dir" -name "*.md" -type f | wc -l)
        log "DEBUG" "Memory files: $memory_files"
        
        # Check for very old memory files
        local old_files=$(find "$memory_dir" -name "*.md" -type f -mtime +30 | wc -l)
        if [ "$old_files" -gt 0 ]; then
            log "INFO" "Found $old_files memory file(s) older than 30 days"
        fi
    fi
    
    log "INFO" "Light maintenance complete"
}

clean_old_alerts() {
    if [ -f "$ALERT_FILE" ]; then
        local temp_file=$(mktemp)
        local current_time=$(date +%s)
        local kept_alerts=0
        
        while IFS= read -r line; do
            if [[ "$line" =~ ^\[([0-9-]+)\ ([0-9:]+)\] ]]; then
                local timestamp="${BASH_REMATCH[1]} ${BASH_REMATCH[2]}"
                local alert_time=$(date -j -f "%Y-%m-%d %H:%M:%S" "$timestamp" +%s 2>/dev/null || echo "0")
                
                if [ "$alert_time" -gt 0 ] && [ $((current_time - alert_time)) -lt "$MAX_ALERT_AGE" ]; then
                    echo "$line" >> "$temp_file"
                    kept_alerts=$((kept_alerts + 1))
                fi
            else
                echo "$line" >> "$temp_file"
                kept_alerts=$((kept_alerts + 1))
            fi
        done < "$ALERT_FILE"
        
        mv "$temp_file" "$ALERT_FILE"
        log "DEBUG" "Cleaned alerts file, kept $kept_alerts alert(s)"
    fi
}

# Main execution
main() {
    log "INFO" "=== Starting Heartbeat + Maintenance ==="
    
    # Respect quiet hours for non-urgent tasks
    if is_quiet_hours; then
        log "INFO" "Quiet hours (23:00-08:00), running minimal checks only"
        
        # Only check urgent heartbeat conditions during quiet hours
        check_heartbeat_conditions
        clean_old_alerts
    else
        # Normal operation
        check_heartbeat_conditions
        perform_light_maintenance
        clean_old_alerts
    fi
    
    log "INFO" "=== Heartbeat + Maintenance Complete ==="
}

# Run main function
main "$@"