#!/bin/bash
# OpenClaw Heartbeat Check Script
# Runs HEARTBEAT checks and reports status

set -e

# Configuration
OPENCLAW_WORKSPACE="/Users/clawdia/.openclaw/workspace"
HEARTBEAT_FILE="$OPENCLAW_WORKSPACE/HEARTBEAT.md"
LOG_FILE="$OPENCLAW_WORKSPACE/logs/heartbeat-$(date +%Y%m%d).log"
ALERT_FILE="$OPENCLAW_WORKSPACE/logs/alerts-$(date +%Y%m%d).log"
MAX_ALERT_AGE=86400  # 24 hours in seconds

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$(dirname "$ALERT_FILE")"

log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$level" in
        INFO)
            echo -e "${BLUE}[INFO]${NC} $message"
            ;;
        WARN)
            echo -e "${YELLOW}[WARN]${NC} $message"
            ;;
        ERROR)
            echo -e "${RED}[ERROR]${NC} $message"
            ;;
        SUCCESS)
            echo -e "${GREEN}[SUCCESS]${NC} $message"
            ;;
    esac
    
    # Log to file
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

alert() {
    local alert_type="$1"
    local message="$2"
    local priority="${3:-medium}"
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local alert_entry="[$timestamp] [$priority] [$alert_type] $message"
    
    echo "$alert_entry" >> "$ALERT_FILE"
    log "WARN" "ALERT: $message"
}

check_heartbeat_file() {
    if [ ! -f "$HEARTBEAT_FILE" ]; then
        alert "FILE_MISSING" "HEARTBEAT.md file not found" "high"
        return 1
    fi
    
    log "INFO" "HEARTBEAT.md file exists"
    return 0
}

check_urgent_escalations() {
    log "INFO" "Checking urgent escalation triggers..."
    
    local triggers=0
    
    # Check for IHS Towers emails (simulated check)
    # In production, this would check email
    if ls "$OPENCLAW_WORKSPACE/memory"/*.md >/dev/null 2>&1; then
        if grep -r -i "ihstowers\|@ihstowers.com" "$OPENCLAW_WORKSPACE/memory"/*.md 2>/dev/null | grep -i "urgent\|priority\|escalat" > /dev/null; then
            alert "IHS_TOWERS" "Potential IHS Towers urgent email detected" "high"
            triggers=$((triggers + 1))
        fi
    fi
    
    # Check for financial/contract exposure
    if ls "$OPENCLAW_WORKSPACE"/*.md >/dev/null 2>&1; then
        if grep -r -i "financial exposure\|contract risk\|deadline.*<24h" "$OPENCLAW_WORKSPACE"/*.md 2>/dev/null > /dev/null; then
            alert "FINANCIAL_RISK" "Financial/contract exposure detected" "high"
            triggers=$((triggers + 1))
        fi
    fi
    
    if [ $triggers -eq 0 ]; then
        log "SUCCESS" "No urgent escalation triggers found"
    else
        log "WARN" "Found $triggers urgent escalation trigger(s)"
    fi
    
    return $triggers
}

check_daily_checks() {
    log "INFO" "Running daily checks..."
    
    local issues=0
    
    # Check email triage (simulated)
    # This would normally check email clients
    log "INFO" "Email triage check skipped (requires email client integration)"
    
    # Check calendar (simulated)
    # This would normally sync with calendar
    log "INFO" "Calendar check skipped (requires calendar integration)"
    
    # Check IHS Towers follow-ups
    if [ -f "$OPENCLAW_WORKSPACE/memory"/*.md ]; then
        local ihs_followups=$(grep -r -i "IHS Towers\|ihstowers" "$OPENCLAW_WORKSPACE/memory"/*.md 2>/dev/null | wc -l)
        if [ $ihs_followups -gt 0 ]; then
            log "INFO" "Found $ihs_followups IHS Towers references in memory"
        fi
    fi
    
    if [ $issues -eq 0 ]; then
        log "SUCCESS" "Daily checks completed"
    else
        log "WARN" "Daily checks found $issues issue(s)"
    fi
    
    return $issues
}

check_quiet_hours() {
    local current_hour=$(date +%H)
    local current_minute=$(date +%M)
    local current_time=$((current_hour * 100 + current_minute))
    
    # Quiet hours: 23:00-08:00
    if [ $current_time -ge 2300 ] || [ $current_time -lt 800 ]; then
        log "INFO" "Currently in quiet hours (23:00-08:00)"
        return 0
    else
        log "INFO" "Outside quiet hours"
        return 1
    fi
}

check_heartbeat_ok_conditions() {
    log "INFO" "Checking HEARTBEAT_OK conditions..."

    local violations=0
    local state_file="$OPENCLAW_WORKSPACE/logs/heartbeat-state.json"

    # Check for urgent items
    check_urgent_escalations > /dev/null || violations=$((violations + 1))

    # Check for blocked tasks (simulated)
    log "INFO" "Blocked tasks check skipped (requires task system integration)"
    log "INFO" "Deadline risks check skipped (requires deadline tracking)"
    log "INFO" "Meeting prep check skipped (requires calendar integration)"
    log "INFO" "Thread resolution check skipped (requires communication integration)"

    local new_state="ok"
    if [ $violations -gt 0 ]; then
        new_state="alert"
    fi

    local old_state="unknown"
    if [ -f "$state_file" ]; then
        old_state=$(cat "$state_file" 2>/dev/null || echo "unknown")
    fi

    echo "$new_state" > "$state_file"

    if [ "$new_state" = "ok" ]; then
        log "SUCCESS" "HEARTBEAT_OK conditions met"
        # State-change mode: only emit explicit OK when transitioned or on demand
        if [ "$old_state" != "ok" ] || [ "${1:-}" = "force" ]; then
            echo "HEARTBEAT_OK"
        fi
        return 0
    else
        log "WARN" "HEARTBEAT conditions not met ($violations violations)"
        return 1
    fi
}

check_system_health() {
    log "INFO" "Checking system health..."
    
    # Check disk space
    local disk_usage=$(df -h "$OPENCLAW_WORKSPACE" | tail -1 | awk '{print $5}' | sed 's/%//')
    if [ $disk_usage -gt 90 ]; then
        alert "DISK_SPACE" "Disk usage at ${disk_usage}%" "high"
    elif [ $disk_usage -gt 80 ]; then
        alert "DISK_SPACE" "Disk usage at ${disk_usage}%" "medium"
    else
        log "INFO" "Disk usage: ${disk_usage}%"
    fi
    
    # Check memory usage
    local memory_usage=$(memory_pressure | grep -oE 'System-wide memory free percentage: [0-9]+' | grep -oE '[0-9]+')
    if [ -n "$memory_usage" ] && [ $memory_usage -lt 10 ]; then
        alert "MEMORY" "System memory low: ${memory_usage}% free" "high"
    fi
    
    # Check OpenClaw gateway (simulated)
    # This would check if OpenClaw gateway is running
    log "INFO" "OpenClaw gateway check skipped (requires gateway monitoring)"
    
    log "SUCCESS" "System health check completed"
}

check_recent_alerts() {
    log "INFO" "Checking recent alerts..."
    
    if [ ! -f "$ALERT_FILE" ]; then
        log "INFO" "No alert file found"
        return 0
    fi
    
    local current_time=$(date +%s)
    local recent_alerts=0
    
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            # Extract timestamp from log line
            local log_time=$(echo "$line" | grep -oE '\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\]' | tr -d '[]')
            if [ -n "$log_time" ]; then
                local log_timestamp=$(date -j -f "%Y-%m-%d %H:%M:%S" "$log_time" +%s 2>/dev/null || date -d "$log_time" +%s 2>/dev/null)
                if [ -n "$log_timestamp" ]; then
                    local age=$((current_time - log_timestamp))
                    if [ $age -lt $MAX_ALERT_AGE ]; then
                        recent_alerts=$((recent_alerts + 1))
                    fi
                fi
            fi
        fi
    done < "$ALERT_FILE"
    
    if [ $recent_alerts -gt 0 ]; then
        log "WARN" "Found $recent_alerts alert(s) in last 24 hours"
        # Show recent alerts
        tail -5 "$ALERT_FILE" | while read alert_line; do
            log "INFO" "Recent alert: $alert_line"
        done
    else
        log "SUCCESS" "No recent alerts"
    fi
}

cleanup_old_logs() {
    log "INFO" "Cleaning up old logs..."
    
    local log_dir="$(dirname "$LOG_FILE")"
    local alert_dir="$(dirname "$ALERT_FILE")"
    
    # Remove logs older than 7 days
    find "$log_dir" -name "heartbeat-*.log" -mtime +7 -delete 2>/dev/null || true
    find "$alert_dir" -name "alerts-*.log" -mtime +7 -delete 2>/dev/null || true
    
    log "SUCCESS" "Old logs cleaned up"
}

main() {
    log "INFO" "=== OpenClaw Heartbeat Check Started ==="
    log "INFO" "Timestamp: $(date)"
    log "INFO" "Workspace: $OPENCLAW_WORKSPACE"
    
    # Run checks
    check_heartbeat_file
    check_system_health
    check_urgent_escalations
    check_daily_checks
    check_quiet_hours
    check_heartbeat_ok_conditions
    check_recent_alerts
    cleanup_old_logs
    
    log "INFO" "=== OpenClaw Heartbeat Check Completed ==="
    
    # Summary
    local log_size=$(wc -l < "$LOG_FILE" 2>/dev/null || echo 0)
    local alert_size=$(wc -l < "$ALERT_FILE" 2>/dev/null || echo 0)
    
    log "INFO" "Log file: $LOG_FILE ($log_size lines)"
    log "INFO" "Alert file: $ALERT_FILE ($alert_size lines)"
    
    exit 0
}

# Handle command line arguments
case "${1:-}" in
    test)
        echo "=== Heartbeat Check Test ==="
        check_heartbeat_file
        check_heartbeat_ok_conditions
        ;;
    alerts)
        if [ -f "$ALERT_FILE" ]; then
            echo "=== Recent Alerts ==="
            tail -20 "$ALERT_FILE"
        else
            echo "No alert file found"
        fi
        ;;
    logs)
        if [ -f "$LOG_FILE" ]; then
            echo "=== Recent Logs ==="
            tail -20 "$LOG_FILE"
        else
            echo "No log file found"
        fi
        ;;
    quiet)
        check_quiet_hours && echo "IN_QUIET_HOURS" || echo "ACTIVE_HOURS"
        ;;
    *)
        main
        ;;
esac