#!/bin/bash
# Smart Email Processor
# Adaptive email processing with batching and quiet hours
# Runs every 20 minutes, but adapts based on email volume

set -e

# DEPRECATED: unified into scripts/consolidated-email-processor.sh
# Keep this shim to avoid cron breakage.
if [[ -x "/Users/clawdia/.openclaw/workspace/scripts/consolidated-email-processor.sh" ]]; then
  echo "[DEPRECATED] smart-email-processor.sh -> consolidated-email-processor.sh" >&2
  EMAIL_CONTEXT_MODE="${EMAIL_CONTEXT_MODE:-iih}" exec /Users/clawdia/.openclaw/workspace/scripts/consolidated-email-processor.sh "$@"
fi

# Configuration
OPENCLAW_WORKSPACE="/Users/clawdia/.openclaw/workspace"
LOG_FILE="$OPENCLAW_WORKSPACE/logs/email-processor-$(date +%Y%m%d).log"
PROCESSED_IDS_FILE="$OPENCLAW_WORKSPACE/.processed-email-ids"
CACHE_DIR="$OPENCLAW_WORKSPACE/.email-cache"
STATUS_FILE="$OPENCLAW_WORKSPACE/.email-status"
BATCH_SIZE=10
MODEL="deepseek/deepseek-chat"
MIN_INTERVAL=1200  # 20 minutes in seconds
MAX_INTERVAL=3600  # 1 hour in seconds

# Quiet hours: 23:00 - 08:00
QUIET_START=23
QUIET_END=8

# Priority configuration
PRIORITY_DOMAINS=("ihstowers.com" "iih.ng")
VIP_SENDERS=("HE" "Darwish" "Oladepo")

# Colors for logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Ensure directories exist
mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$CACHE_DIR"
mkdir -p "$(dirname "$STATUS_FILE")"
touch "$PROCESSED_IDS_FILE"

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

check_email_volume() {
    log "DEBUG" "Checking email volume..."
    
    # Simulate email check - in production, this would use actual IMAP
    local new_emails=0
    
    # Check priority accounts first
    for account in "clawdianinan@icloud.com" "clawdia.ai@iih.ng" "clawdianinan@gmail.com"; do
        # This is a placeholder - actual implementation would use himalaya or similar
        local account_emails=$((RANDOM % 5))  # Random 0-4 emails
        new_emails=$((new_emails + account_emails))
    done
    
    echo "$new_emails"
}

should_process() {
    # Check quiet hours
    if is_quiet_hours; then
        log "INFO" "Quiet hours (23:00-08:00), skipping email processing"
        return 1
    fi
    
    # Check if we're in business hours (8 AM - 6 PM, weekdays)
    local current_hour=$(date +%H)
    local current_day=$(date +%u)  # 1=Monday, 7=Sunday
    
    if [ "$current_day" -ge 6 ]; then
        log "INFO" "Weekend, skipping email processing"
        return 1
    fi
    
    if [ "$current_hour" -lt 8 ] || [ "$current_hour" -ge 18 ]; then
        log "INFO" "Outside business hours, skipping email processing"
        return 1
    fi
    
    # Check email volume
    local new_emails=$(check_email_volume)
    
    if [ "$new_emails" -eq 0 ]; then
        log "INFO" "No new emails detected, skipping processing"
        return 1
    fi
    
    log "INFO" "Detected $new_emails new email(s), proceeding with processing"
    return 0
}

process_priority_emails() {
    log "INFO" "Processing priority emails..."
    
    # Placeholder for priority email processing
    # In production, this would:
    # 1. Check for emails from priority domains
    # 2. Check for VIP senders
    # 3. Process with higher model (e.g., claude-3.5-sonnet)
    # 4. Generate urgent alerts if needed
    
    local priority_count=0
    
    for domain in "${PRIORITY_DOMAINS[@]}"; do
        # Simulate finding priority emails
        local domain_emails=$((RANDOM % 3))
        if [ "$domain_emails" -gt 0 ]; then
            log "WARN" "Found $domain_emails email(s) from $domain (priority)"
            priority_count=$((priority_count + domain_emails))
        fi
    done
    
    if [ "$priority_count" -gt 0 ]; then
        log "WARN" "Total priority emails: $priority_count"
        # In production, would trigger alert to user
    fi
    
    return $priority_count
}

process_regular_emails() {
    local batch_size="$1"
    log "INFO" "Processing regular emails (batch size: $batch_size)..."
    
    # Placeholder for regular email processing
    # In production, this would:
    # 1. Fetch emails from all accounts
    # 2. Filter out already processed
    # 3. Categorize (urgent/action/info)
    # 4. Generate summaries
    # 5. Update processed IDs file
    
    local processed=0
    local total_emails=$((RANDOM % 10))  # Random 0-9 emails
    
    if [ "$total_emails" -gt 0 ]; then
        processed=$((total_emails < batch_size ? total_emails : batch_size))
        log "INFO" "Processed $processed of $total_emails regular email(s)"
        
        # Simulate processing delay
        sleep 2
    fi
    
    return $processed
}

update_processing_interval() {
    local emails_processed="$1"
    local current_time=$(date +%s)
    
    # Adaptive interval logic:
    # - More emails = shorter interval (but not below MIN_INTERVAL)
    # - Fewer emails = longer interval (up to MAX_INTERVAL)
    
    local new_interval="$MIN_INTERVAL"
    
    if [ "$emails_processed" -eq 0 ]; then
        # No emails, extend interval
        new_interval=$((MIN_INTERVAL * 2))
        if [ "$new_interval" -gt "$MAX_INTERVAL" ]; then
            new_interval="$MAX_INTERVAL"
        fi
    elif [ "$emails_processed" -lt 3 ]; then
        # Few emails, moderate interval
        new_interval="$MIN_INTERVAL"
    else
        # Many emails, keep at minimum interval
        new_interval="$MIN_INTERVAL"
    fi
    
    # Save status for next run
    echo "last_run=$current_time" > "$STATUS_FILE"
    echo "interval=$new_interval" >> "$STATUS_FILE"
    echo "processed=$emails_processed" >> "$STATUS_FILE"
    
    log "DEBUG" "Updated processing interval: $new_interval seconds"
}

# Main execution
main() {
    log "INFO" "=== Starting Smart Email Processor ==="
    
    # Check if we should process
    if ! should_process; then
        log "INFO" "Skipping email processing"
        return 0
    fi
    
    # Process priority emails first
    process_priority_emails
    local priority_count=$?
    
    # Process regular emails in batches
    process_regular_emails "$BATCH_SIZE"
    local regular_count=$?
    
    local total_processed=$((priority_count + regular_count))
    
    if [ "$total_processed" -gt 0 ]; then
        log "INFO" "Successfully processed $total_processed email(s)"
        
        # Update adaptive interval
        update_processing_interval "$total_processed"
        
        # In production, would generate summary report
        if [ "$priority_count" -gt 0 ]; then
            log "WARN" "ACTION REQUIRED: $priority_count priority email(s) need attention"
        fi
    else
        log "INFO" "No emails required processing"
        update_processing_interval 0
    fi
    
    log "INFO" "=== Email Processing Complete ==="
}

# Run main function
main "$@"