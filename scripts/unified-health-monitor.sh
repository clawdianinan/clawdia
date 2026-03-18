#!/bin/bash
# Unified Health Monitor
# Consolidates: Gateway check, Model availability, QMD health, System metrics
# Runs every 15 minutes

set -e

# Configuration
OPENCLAW_WORKSPACE="/Users/clawdia/.openclaw/workspace"
LOG_FILE="$OPENCLAW_WORKSPACE/logs/health-monitor-$(date +%Y%m%d).log"
ALERT_FILE="$OPENCLAW_WORKSPACE/logs/alerts-$(date +%Y%m%d).log"
STATUS_FILE="$OPENCLAW_WORKSPACE/.health-status"
MAX_ALERT_AGE=86400  # 24 hours

# Check intervals (prevent redundant checks)
GATEWAY_CHECK_INTERVAL=300  # 5 minutes
MODEL_CHECK_INTERVAL=3600   # 1 hour
QMD_CHECK_INTERVAL=7200     # 2 hours
SYSTEM_CHECK_INTERVAL=1800  # 30 minutes

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Ensure directories exist
mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$(dirname "$ALERT_FILE")"
mkdir -p "$(dirname "$STATUS_FILE")"

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

alert() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] ALERT: $message" >> "$ALERT_FILE"
    log "WARN" "Alert triggered: $message"
}

check_last_run() {
    local check_type="$1"
    local interval="$2"
    local last_run_file="$STATUS_FILE.$check_type"
    
    if [ -f "$last_run_file" ]; then
        local last_run=$(cat "$last_run_file")
        local current_time=$(date +%s)
        local time_diff=$((current_time - last_run))
        
        if [ "$time_diff" -lt "$interval" ]; then
            log "DEBUG" "Skipping $check_type check (last run $time_diff seconds ago, interval $interval)"
            return 1
        fi
    fi
    
    date +%s > "$last_run_file"
    return 0
}

check_gateway() {
    log "INFO" "Checking OpenClaw gateway status..."
    
    if command -v openclaw >/dev/null 2>&1; then
        if openclaw gateway status >/dev/null 2>&1; then
            log "INFO" "Gateway is running"
            return 0
        else
            alert "Gateway is not running"
            return 1
        fi
    else
        log "ERROR" "OpenClaw CLI not found"
        return 1
    fi
}

check_models() {
    log "INFO" "Checking model availability..."
    
    # Check default model
    local default_model="deepseek/deepseek-chat"
    
    # Simple curl check to OpenRouter
    if curl -s -X GET "https://openrouter.ai/api/v1/models" \
        -H "Authorization: Bearer $OPENROUTER_API_KEY" 2>/dev/null | \
        grep -q "$default_model"; then
        log "INFO" "Default model ($default_model) is available"
        return 0
    else
        log "WARN" "Default model may not be available"
        return 1
    fi
}

check_qmd() {
    log "INFO" "Checking QMD health..."
    
    local qmd_script="$OPENCLAW_WORKSPACE/skills/qmd/scripts/check-qdrant.sh"
    
    if [ -f "$qmd_script" ]; then
        if bash "$qmd_script" >/dev/null 2>&1; then
            log "INFO" "QMD is healthy"
            return 0
        else
            alert "QMD health check failed"
            return 1
        fi
    else
        log "DEBUG" "QMD script not found, skipping"
        return 0
    fi
}

check_system() {
    log "INFO" "Checking system metrics..."
    
    # Disk usage
    local disk_usage=$(df -h "$OPENCLAW_WORKSPACE" | tail -1 | awk '{print $5}' | sed 's/%//')
    if [ "$disk_usage" -gt 90 ]; then
        alert "Disk usage high: ${disk_usage}%"
    fi
    
    # Memory usage
    local mem_usage=$(memory_pressure | grep "System-wide memory free percentage:" | awk '{print $5}' | sed 's/%//')
    if [ -n "$mem_usage" ] && [ "$mem_usage" -lt 10 ]; then
        alert "Memory pressure high: ${mem_usage}% free"
    fi
    
    # CPU load
    local load_avg=$(sysctl -n vm.loadavg | awk '{print $2}')
    local cpu_cores=$(sysctl -n hw.ncpu)
    local load_percent=$(echo "scale=0; $load_avg * 100 / $cpu_cores" | bc)
    
    if [ "$load_percent" -gt 80 ]; then
        log "WARN" "High CPU load: ${load_percent}%"
    fi
    
    log "INFO" "System metrics: Disk ${disk_usage}%, Load ${load_percent}%"
    return 0
}

# Main execution
main() {
    log "INFO" "=== Starting Unified Health Monitor ==="
    
    # Check gateway (every 5 minutes)
    if check_last_run "gateway" "$GATEWAY_CHECK_INTERVAL"; then
        check_gateway
    fi
    
    # Check models (every hour)
    if check_last_run "models" "$MODEL_CHECK_INTERVAL"; then
        check_models
    fi
    
    # Check QMD (every 2 hours)
    if check_last_run "qmd" "$QMD_CHECK_INTERVAL"; then
        check_qmd
    fi
    
    # Check system (every 30 minutes)
    if check_last_run "system" "$SYSTEM_CHECK_INTERVAL"; then
        check_system
    fi
    
    # Clean old alerts
    if [ -f "$ALERT_FILE" ]; then
        local temp_file=$(mktemp)
        local current_time=$(date +%s)
        
        while IFS= read -r line; do
            if [[ "$line" =~ ^\[([0-9-]+)\ ([0-9:]+)\] ]]; then
                local timestamp="${BASH_REMATCH[1]} ${BASH_REMATCH[2]}"
                local alert_time=$(date -j -f "%Y-%m-%d %H:%M:%S" "$timestamp" +%s 2>/dev/null || echo "0")
                
                if [ "$alert_time" -gt 0 ] && [ $((current_time - alert_time)) -lt "$MAX_ALERT_AGE" ]; then
                    echo "$line" >> "$temp_file"
                fi
            else
                echo "$line" >> "$temp_file"
            fi
        done < "$ALERT_FILE"
        
        mv "$temp_file" "$ALERT_FILE"
    fi
    
    log "INFO" "=== Health Monitor Complete ==="
}

# Run main function
main "$@"