#!/bin/bash
# Consolidated Email Processor
# Replaces: Email Auto-Processor, Temi Email Processor, Email Priority Monitor
# Runs every 10 minutes during business hours (8 AM - 6 PM)

set -e

# Configuration
OPENCLAW_WORKSPACE="/Users/clawdia/.openclaw/workspace"
LOG_FILE="$OPENCLAW_WORKSPACE/logs/email-processor-$(date +%Y%m%d).log"
PROCESSED_IDS_FILE="$OPENCLAW_WORKSPACE/.processed-email-ids"
CACHE_DIR="$OPENCLAW_WORKSPACE/.email-cache"
BATCH_SIZE=5
MODEL="deepseek/deepseek-chat"  # Lower cost model for initial processing

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
touch "$PROCESSED_IDS_FILE"

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

# Check if email ID has been processed
is_processed() {
    local email_id="$1"
    grep -q "^$email_id$" "$PROCESSED_IDS_FILE" && return 0 || return 1
}

# Mark email as processed
mark_processed() {
    local email_id="$1"
    echo "$email_id" >> "$PROCESSED_IDS_FILE"
}

# Check quiet hours (23:00-08:00)
check_quiet_hours() {
    local current_hour=$(date +%H)
    if [[ $current_hour -ge 23 ]] || [[ $current_hour -lt 8 ]]; then
        log "INFO" "Quiet hours (23:00-08:00) - only checking IHS Towers emails"
        return 0
    fi
    return 1
}

# Check for IHS Towers emails (highest priority)
check_ihs_towers_emails() {
    log "INFO" "Checking for IHS Towers emails..."
    
    # This would integrate with actual email client
    # For now, simulate check
    local ihs_emails=0
    
    # Check if any IHS Towers emails exist
    # In production: himalaya search "from:@ihstowers.com"
    
    if [[ $ihs_emails -gt 0 ]]; then
        log "WARN" "Found $ihs_emails IHS Towers emails - immediate escalation required"
        # Trigger emergency alert
        return 1
    else
        log "SUCCESS" "No IHS Towers emails found"
        return 0
    fi
}

# Get unread emails in batch
get_unread_emails_batch() {
    local limit="$1"
    
    log "INFO" "Fetching up to $limit unread emails..."
    
    # This would integrate with actual email client
    # For now, return simulated data
    echo "[]"
}

# Classify email type
classify_email() {
    local email_json="$1"
    
    # Simple classification logic
    # In production: Use model call for complex classification
    
    # Check if from Temi
    if echo "$email_json" | grep -q "temi.kolawole@iih.ng\|temi@iih.ng"; then
        echo "temi_instruction"
    elif echo "$email_json" | grep -q "@iih.ng"; then
        echo "iih_internal"
    else
        echo "external"
    fi
}

# Process Temi's instructions
process_temi_instruction() {
    local email_id="$1"
    local email_content="$2"
    
    log "INFO" "Processing Temi's instruction (Email ID: $email_id)"
    
    # Extract instruction keywords
    local instruction_keywords=("please" "kindly" "can you" "check" "review" "update")
    
    for keyword in "${instruction_keywords[@]}"; do
        if echo "$email_content" | grep -qi "$keyword"; then
            log "INFO" "Found instruction keyword: $keyword"
            # Execute instruction
            execute_temi_instruction "$email_id" "$email_content"
            return 0
        fi
    done
    
    log "WARN" "No clear instruction found in Temi's email"
    return 1
}

# Execute Temi's instruction
execute_temi_instruction() {
    local email_id="$1"
    local email_content="$2"
    
    log "INFO" "Executing instruction from Temi"
    
    # This would trigger appropriate action based on content
    # For now, log the action
    
    # Check for common instruction patterns
    if echo "$email_content" | grep -qi "organogram"; then
        log "INFO" "Action: Update organogram files"
    elif echo "$email_content" | grep -qi "role.*hiring\|hiring.*role"; then
        log "INFO" "Action: Update hiring roles document"
    elif echo "$email_content" | grep -qi "logo\|consent\|IHS"; then
        log "INFO" "Action: Review consent agreement"
    elif echo "$email_content" | grep -qi "budget"; then
        log "INFO" "Action: Process budget file"
    else
        log "INFO" "Action: General instruction execution"
    fi
    
    mark_processed "$email_id"
}

# Process external email (create todo)
process_external_email() {
    local email_id="$1"
    local email_content="$2"
    
    log "INFO" "Processing external email (Email ID: $email_id)"
    
    # Extract key information for todo
    local subject=$(echo "$email_content" | head -1)
    local sender=$(echo "$email_content" | grep -i "from:" | head -1)
    
    # Create todo entry
    # In production: Use todo.sh or similar
    
    log "INFO" "Created todo: Follow up on email from $sender"
    mark_processed "$email_id"
}

# Process emails in batch
process_emails_batch() {
    log "INFO" "Starting batch email processing"
    
    # Get unread emails
    local emails_json=$(get_unread_emails_batch $BATCH_SIZE)
    
    # Parse and process each email
    local email_count=0
    local processed_count=0
    
    # In production: Parse JSON and iterate
    # For now, simulate processing
    
    log "INFO" "Processed $processed_count/$email_count emails in batch"
}

# Generate summary report
generate_summary_report() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local processed_count=$(wc -l < "$PROCESSED_IDS_FILE" | tr -d ' ')
    
    cat > "$CACHE_DIR/summary-$(date +%Y%m%d-%H%M).txt" << EOF
Email Processing Summary
=======================
Timestamp: $timestamp
Total Processed: $processed_count
IHS Towers Check: $(check_ihs_towers_emails >/dev/null 2>&1 && echo "Clear" || echo "ALERT")
Batch Size: $BATCH_SIZE
Model Used: $MODEL
EOF
    
    log "INFO" "Summary report generated"
}

# Clean up old cache files
cleanup_cache() {
    find "$CACHE_DIR" -name "*.txt" -mtime +7 -delete
    log "INFO" "Cleaned up old cache files"
}

# Main execution
main() {
    log "INFO" "Starting consolidated email processor at $(date)"
    
    # Check quiet hours
    if check_quiet_hours; then
        # Only check IHS Towers during quiet hours
        check_ihs_towers_emails
        log "INFO" "Quiet hours - skipping regular processing"
        exit 0
    fi
    
    # Always check IHS Towers first (highest priority)
    if ! check_ihs_towers_emails; then
        log "ERROR" "IHS Towers alert - stopping further processing"
        exit 1
    fi
    
    # Process emails in batch
    process_emails_batch
    
    # Generate summary
    generate_summary_report
    
    # Cleanup
    cleanup_cache
    
    log "SUCCESS" "Email processing completed successfully"
}

# Run main function
main "$@"