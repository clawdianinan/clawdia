#!/bin/bash
# Process Health Monitor Dashboard
# Monitors all cron jobs and background processes, provides status dashboard

set -euo pipefail

# Configuration
LOG_DIR="/Users/clawdia/.openclaw/workspace/logs/self_healing"
STATUS_FILE="${LOG_DIR}/status.json"
DASHBOARD_FILE="${LOG_DIR}/dashboard.md"
CRITICAL_THRESHOLD=3  # Consecutive failures before critical

# Ensure directories exist
mkdir -p "$LOG_DIR"

# Function to check if process is running
check_process_running() {
    local process_name=$1
    if pgrep -f "$process_name" >/dev/null; then
        echo "✅ Running"
    else
        echo "❌ Stopped"
    fi
}

# Function to check cron job last run
check_cron_last_run() {
    local job_pattern=$1
    local log_file=${2:-}
    
    if [[ -n "$log_file" && -f "$log_file" ]]; then
        local last_run=$(tail -1 "$log_file" 2>/dev/null | grep -o '[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}' | tail -1 || echo "Never")
        if [[ -z "$last_run" ]]; then
            echo "Never"
        else
            echo "$last_run"
        fi
    else
        echo "No log"
    fi
}

# Function to generate dashboard
generate_dashboard() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    cat > "$DASHBOARD_FILE" << EOF
# Process Health Dashboard
**Last Updated:** $timestamp

## 📊 System Status

### Cron Jobs
| Job | Status | Last Run | Consecutive Failures | Notes |
|-----|--------|----------|---------------------|-------|
EOF

    # Check each cron job
    local jobs=(
        "morning_digest:Morning Digest:8:00 AM:/Users/clawdia/.openclaw/workspace/logs/cron-morning.log"
        "email_processor:Email Processor:Hourly:/Users/clawdia/.openclaw/workspace/logs/cron-email.log"
        "health_monitor:Health Monitor:Every 15min:/Users/clawdia/.openclaw/workspace/logs/cron-health.log"
        "heartbeat:Heartbeat:Every 30min:/Users/clawdia/.openclaw/workspace/logs/cron-heartbeat.log"
        "backup:Weekly Backup:Sun 2 AM:/Users/clawdia/.openclaw/workspace/logs/cron-backup.log"
    )
    
    for job_spec in "${jobs[@]}"; do
        IFS=':' read -r job_id job_name schedule log_file <<< "$job_spec"
        
        # Check status from self-healing system
        local status="Unknown"
        local failures="0"
        local last_run="Never"
        local notes=""
        
        if [[ -f "$STATUS_FILE" ]]; then
            status=$(jq -r ".scripts.\"$job_id\".status // \"Unknown\"" "$STATUS_FILE" 2>/dev/null || echo "Unknown")
            failures=$(check_consecutive_failures "$job_id")
            last_run=$(jq -r ".scripts.\"$job_id\".last_run // \"Never\"" "$STATUS_FILE" 2>/dev/null | cut -d'T' -f1 || echo "Never")
            
            if [[ "$status" == "failed" ]]; then
                local error_msg=$(jq -r ".scripts.\"$job_id\".error // \"\"" "$STATUS_FILE" 2>/dev/null)
                notes="${error_msg:0:50}..."
            fi
            
            # Check if critical
            if [[ $failures -ge $CRITICAL_THRESHOLD ]]; then
                notes="🚨 CRITICAL: $failures consecutive failures"
            fi
        fi
        
        # Get actual last run from log
        local actual_last_run=$(check_cron_last_run "$job_id" "$log_file")
        
        cat >> "$DASHBOARD_FILE" << EOF
| $job_name | $status | $actual_last_run | $failures | $notes |
EOF
    done
    
    cat >> "$DASHBOARD_FILE" << EOF

## 🔧 Background Processes

| Process | Status | PID | Uptime |
|---------|--------|-----|--------|
EOF

    # Check background processes
    local processes=(
        "openclaw:OpenClaw Gateway"
        "node:Node.js Processes"
        "python:Python Scripts"
    )
    
    for process_spec in "${processes[@]}"; do
        IFS=':' read -r process_name display_name <<< "$process_spec"
        
        local status=$(check_process_running "$process_name")
        local pids=$(pgrep -f "$process_name" 2>/dev/null | tr '\n' ',' | sed 's/,$//')
        local uptime=""
        
        if [[ -n "$pids" ]]; then
            # Get uptime for first PID
            local first_pid=$(echo "$pids" | cut -d',' -f1)
            if [[ -n "$first_pid" ]]; then
                uptime=$(ps -o etime= -p "$first_pid" 2>/dev/null | xargs || echo "Unknown")
            fi
        fi
        
        cat >> "$DASHBOARD_FILE" << EOF
| $display_name | $status | ${pids:-None} | $uptime |
EOF
    done
    
    cat >> "$DASHBOARD_FILE" << EOF

## 📈 Health Metrics

### System Resources
\`\`\`
$(top -l 1 | head -10 | tail -5)
\`\`\`

### Disk Usage
\`\`\`
$(df -h / | tail -1)
\`\`\`

### Memory Usage
\`\`\`
$(memory_pressure 2>/dev/null || echo "Memory pressure not available")
\`\`\`

## 🚨 Alerts

EOF

    # Generate alerts
    if [[ -f "$STATUS_FILE" ]]; then
        local critical_jobs=$(jq -r '.scripts | to_entries[] | select(.value.status == "failed") | .key' "$STATUS_FILE" 2>/dev/null || true)
        
        if [[ -n "$critical_jobs" ]]; then
            for job in $critical_jobs; do
                local failure_count=$(check_consecutive_failures "$job")
                if [[ $failure_count -ge $CRITICAL_THRESHOLD ]]; then
                    echo "- **$job**: $failure_count consecutive failures - Requires immediate attention" >> "$DASHBOARD_FILE"
                fi
            done
        fi
    fi
    
    cat >> "$DASHBOARD_FILE" << EOF

## 📋 Recommendations

1. **Review failed jobs** in the table above
2. **Check logs** in \`$LOG_DIR\`
3. **Restart critical processes** if needed
4. **Monitor system resources** for bottlenecks

---

*Dashboard auto-generated by Process Health Monitor*
*Run this script manually or schedule it for regular monitoring*
EOF
    
    echo "Dashboard generated: $DASHBOARD_FILE"
}

# Function to send daily status report
send_daily_report() {
    if ! command -v openclaw >/dev/null 2>&1; then
        echo "OpenClaw not available for reporting"
        return 1
    fi
    
    export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
    
    # Count failures
    local total_failures=0
    local critical_jobs=""
    
    if [[ -f "$STATUS_FILE" ]]; then
        total_failures=$(jq '[.scripts[] | select(.status == "failed")] | length' "$STATUS_FILE" 2>/dev/null || echo "0")
        
        critical_jobs=$(jq -r '.scripts | to_entries[] | select(.value.status == "failed") | "• \(.key): \(.value.error // "Unknown error")" | .[0:50]' "$STATUS_FILE" 2>/dev/null | head -3 | tr '\n' '; ')
    fi
    
    local message="📊 Daily Process Report
Status: $( [[ $total_failures -eq 0 ]] && echo "✅ All systems normal" || echo "⚠️ $total_failures job(s) failing" )
Failed jobs: ${critical_jobs:-None}
View full dashboard: $DASHBOARD_FILE"
    
    openclaw message send --channel imessage --target temikolawole@icloud.com \
        --message "$message" \
        --best-effort 2>/dev/null || true
}

# Main execution
main() {
    echo "Starting Process Health Monitor..."
    
    # Generate dashboard
    generate_dashboard
    
    # Send report if it's morning (8 AM - 10 AM)
    local current_hour=$(date '+%H')
    if [[ $current_hour -ge 8 && $current_hour -lt 10 ]]; then
        echo "Sending daily status report..."
        send_daily_report
    fi
    
    echo "Health monitoring completed"
}

# Helper function (defined here for standalone use)
check_consecutive_failures() {
    local script=$1
    local count=0
    
    if [[ -f "${LOG_DIR}/${script}.failure_count" ]]; then
        count=$(cat "${LOG_DIR}/${script}.failure_count" 2>/dev/null || echo "0")
    fi
    
    echo $count
}

main "$@"