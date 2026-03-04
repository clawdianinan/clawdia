#!/bin/bash
# Email monitoring script for IHS Towers and priority emails
# Simplified version - in production would integrate with email clients

set -e

# DEPRECATED: unified into scripts/consolidated-email-processor.sh
# Keep this shim to avoid cron breakage.
if [[ -x "/Users/clawdia/.openclaw/workspace/scripts/consolidated-email-processor.sh" ]]; then
  echo "[DEPRECATED] check-emails.sh -> consolidated-email-processor.sh" >&2
  EMAIL_CONTEXT_MODE="${EMAIL_CONTEXT_MODE:-iih}" exec /Users/clawdia/.openclaw/workspace/scripts/consolidated-email-processor.sh "$@"
fi

# Configuration
OPENCLAW_WORKSPACE="/Users/clawdia/.openclaw/workspace"
LOG_FILE="$OPENCLAW_WORKSPACE/logs/email-check-$(date +%Y%m%d).log"
ALERT_FILE="$OPENCLAW_WORKSPACE/logs/alerts-$(date +%Y%m%d).log"
LAST_CHECK_FILE="$OPENCLAW_WORKSPACE/.last-email-check"

# Priority domains and senders
PRIORITY_DOMAINS=("ihstowers.com" "iih.ng")
PRIORITY_SENDERS=("HE" "Darwish" "Oladepo" "Suleman Ibrahim" "Mathias Amuta")
PRIORITY_KEYWORDS=("urgent" "priority" "escalat" "deadline" "financial" "contract" "meeting")

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Ensure directories exist
mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$(dirname "$ALERT_FILE")"

log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$level" in
        INFO) echo -e "${BLUE}[INFO]${NC} $message" ;;
        WARN) echo -e "${YELLOW}[WARN]${NC} $message" ;;
        ERROR) echo -e "${RED}[ERROR]${NC} $message" ;;
        SUCCESS) echo -e "${GREEN}[SUCCESS]${NC} $message" ;;
    esac
    
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

alert() {
    local alert_type="$1"
    local message="$2"
    local priority="${3:-medium}"
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local alert_entry="[$timestamp] [$priority] [EMAIL:$alert_type] $message"
    
    echo "$alert_entry" >> "$ALERT_FILE"
    log "WARN" "EMAIL ALERT: $message"
}

update_last_check() {
    date +%s > "$LAST_CHECK_FILE"
    log "INFO" "Updated last check timestamp"
}

get_last_check_time() {
    if [ -f "$LAST_CHECK_FILE" ]; then
        cat "$LAST_CHECK_FILE"
    else
        echo "0"
    fi
}

check_ihs_towers_emails() {
    log "INFO" "Checking for IHS Towers emails..."
    
    # This is a simulated check
    # In production, this would query email clients (Mail.app, Gmail, etc.)
    
    local found_emails=0
    
    # Check memory files for recent IHS Towers references
    if [ -d "$OPENCLAW_WORKSPACE/memory" ]; then
        local recent_files=$(find "$OPENCLAW_WORKSPACE/memory" -name "*.md" -mtime -1 2>/dev/null | head -10)
        
        for file in $recent_files; do
            if grep -i "ihstowers\|@ihstowers.com" "$file" 2>/dev/null | grep -i "email\|inbox\|message" > /dev/null; then
                local file_date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$file")
                local subject=$(grep -i "subject\|title" "$file" | head -1 | cut -d: -f2- | sed 's/^[ \t]*//;s/[ \t]*$//')
                
                if [ -n "$subject" ]; then
                    alert "IHS_TOWERS" "IHS Towers email detected: $subject (from $file_date)" "high"
                    found_emails=$((found_emails + 1))
                else
                    alert "IHS_TOWERS" "IHS Towers email reference in $file" "medium"
                    found_emails=$((found_emails + 1))
                fi
            fi
        done
    fi
    
    if [ $found_emails -eq 0 ]; then
        log "SUCCESS" "No IHS Towers emails detected in recent memory"
    else
        log "WARN" "Found $found_emails IHS Towers email reference(s)"
    fi
    
    return $found_emails
}

check_priority_senders() {
    log "INFO" "Checking for priority sender emails..."
    
    local found_emails=0
    
    # Check for VIP senders
    for sender in "${PRIORITY_SENDERS[@]}"; do
        if [ -d "$OPENCLAW_WORKSPACE/memory" ]; then
            local sender_files=$(grep -r -l -i "$sender" "$OPENCLAW_WORKSPACE/memory"/*.md 2>/dev/null | head -5)
            
            for file in $sender_files; do
                if grep -i "email\|message\|whatsapp" "$file" > /dev/null; then
                    local file_date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$file")
                    alert "VIP_SENDER" "Message from $sender detected in $file ($file_date)" "high"
                    found_emails=$((found_emails + 1))
                fi
            done
        fi
    done
    
    if [ $found_emails -eq 0 ]; then
        log "SUCCESS" "No priority sender emails detected"
    else
        log "WARN" "Found $found_emails priority sender email(s)"
    fi
    
    return $found_emails
}

check_priority_keywords() {
    log "INFO" "Checking for emails with priority keywords..."
    
    local found_emails=0
    
    for keyword in "${PRIORITY_KEYWORDS[@]}"; do
        if [ -d "$OPENCLAW_WORKSPACE/memory" ]; then
            local keyword_files=$(grep -r -l -i "$keyword" "$OPENCLAW_WORKSPACE/memory"/*.md 2>/dev/null | head -5)
            
            for file in $keyword_files; do
                if grep -i "email\|inbox" "$file" > /dev/null; then
                    local file_date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$file")
                    local context=$(grep -i "$keyword" "$file" | head -1 | cut -c1-100)
                    
                    alert "PRIORITY_KEYWORD" "Email with '$keyword': $context... (from $file_date)" "medium"
                    found_emails=$((found_emails + 1))
                fi
            done
        fi
    done
    
    if [ $found_emails -eq 0 ]; then
        log "SUCCESS" "No emails with priority keywords detected"
    else
        log "WARN" "Found $found_emails email(s) with priority keywords"
    fi
    
    return $found_emails
}

check_email_clients() {
    log "INFO" "Checking email client status..."
    
    # Check Mail.app (macOS)
    if pgrep -x "Mail" > /dev/null; then
        log "INFO" "Mail.app is running"
        
        # Check if Mail.app is accessible
        if osascript -e 'application "Mail" is running' 2>/dev/null; then
            log "SUCCESS" "Mail.app is accessible via AppleScript"
        else
            log "WARN" "Mail.app is running but not accessible via AppleScript"
        fi
    else
        log "WARN" "Mail.app is not running"
    fi
    
    # Check for other email clients
    local email_clients=("Mail" "Outlook" "Spark" "Airmail")
    local running_clients=0
    
    for client in "${email_clients[@]}"; do
        if pgrep -x "$client" > /dev/null; then
            log "INFO" "$client is running"
            running_clients=$((running_clients + 1))
        fi
    done
    
    if [ $running_clients -eq 0 ]; then
        alert "EMAIL_CLIENT" "No email clients are running" "medium"
    else
        log "SUCCESS" "$running_clients email client(s) running"
    fi
}

simulate_email_check() {
    log "INFO" "Running simulated email check..."
    
    # This simulates checking for new emails
    # In production, this would integrate with actual email APIs
    
    local last_check=$(get_last_check_time)
    local current_time=$(date +%s)
    local time_since_check=$((current_time - last_check))
    
    log "INFO" "Time since last check: $time_since_check seconds"
    
    # Simulate finding emails based on time
    if [ $time_since_check -gt 3600 ]; then # More than 1 hour
        log "INFO" "Simulating email fetch (long interval)"
        
        # Simulate IHS Towers email (20% chance)
        if [ $((RANDOM % 5)) -eq 0 ]; then
            alert "SIMULATED_IHS" "Simulated IHS Towers email: Monthly report review required" "high"
        fi
        
        # Simulate VIP email (30% chance)
        if [ $((RANDOM % 3)) -eq 0 ]; then
            local vip_senders=("HE" "Darwish" "Oladepo")
            local random_vip=${vip_senders[$RANDOM % ${#vip_senders[@]}]}
            alert "SIMULATED_VIP" "Simulated message from $random_vip: Need to discuss urgent matter" "high"
        fi
    fi
    
    update_last_check
}

cleanup_old_logs() {
    log "INFO" "Cleaning up old email logs..."
    
    local log_dir="$(dirname "$LOG_FILE")"
    find "$log_dir" -name "email-check-*.log" -mtime +7 -delete 2>/dev/null || true
    
    log "SUCCESS" "Old email logs cleaned up"
}

generate_report() {
    log "INFO" "Generating email check report..."
    
    local total_alerts=0
    local high_priority=0
    local medium_priority=0
    
    if [ -f "$ALERT_FILE" ]; then
        total_alerts=$(grep -c "\[EMAIL:" "$ALERT_FILE" 2>/dev/null || echo 0)
        high_priority=$(grep -c "\[EMAIL:.*\] .* \[high\]" "$ALERT_FILE" 2>/dev/null || echo 0)
        medium_priority=$(grep -c "\[EMAIL:.*\] .* \[medium\]" "$ALERT_FILE" 2>/dev/null || echo 0)
    fi
    
    local report="=== Email Check Report ===
Timestamp: $(date)
Total email alerts: $total_alerts
High priority alerts: $high_priority
Medium priority alerts: $medium_priority
Last check: $(date -r "$LAST_CHECK_FILE" 2>/dev/null || echo "Never")
Log file: $LOG_FILE"
    
    echo "$report"
    log "INFO" "Report generated"
}

main() {
    log "INFO" "=== Email Check Started ==="
    log "INFO" "Timestamp: $(date)"
    log "INFO" "Workspace: $OPENCLAW_WORKSPACE"
    
    # Run checks
    check_email_clients
    check_ihs_towers_emails
    check_priority_senders
    check_priority_keywords
    simulate_email_check
    cleanup_old_logs
    generate_report
    
    log "INFO" "=== Email Check Completed ==="
    
    exit 0
}

# Handle command line arguments
case "${1:-}" in
    test)
        echo "=== Email Check Test ==="
        check_ihs_towers_emails
        check_priority_senders
        generate_report
        ;;
    report)
        generate_report
        ;;
    alerts)
        if [ -f "$ALERT_FILE" ]; then
            echo "=== Email Alerts ==="
            grep "\[EMAIL:" "$ALERT_FILE" | tail -20
        else
            echo "No email alerts found"
        fi
        ;;
    clients)
        check_email_clients
        ;;
    simulate)
        simulate_email_check
        ;;
    *)
        main
        ;;
esac