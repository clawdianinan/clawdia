#!/bin/bash
# Corrected Email Processor Wrapper
# Uses the corrected email auto-processor with adaptive scheduling
# Cron ID: 54a989a6-a3fc-4ee8-9cfe-bea1d012660e

set -e

# Configuration
OPENCLAW_WORKSPACE="/Users/clawdia/.openclaw/workspace"
CORRECTED_PROCESSOR="$OPENCLAW_WORKSPACE/corrected_email_auto_processor.sh"
LOG_FILE="$OPENCLAW_WORKSPACE/logs/corrected-email-processor-$(date +%Y%m%d).log"
STATUS_FILE="$OPENCLAW_WORKSPACE/.corrected-email-status"

# Quiet hours: 23:00 - 08:00
QUIET_START=23
QUIET_END=8

# Colors for logging
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Ensure directories exist
mkdir -p "$(dirname "$LOG_FILE")"
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

should_process() {
    # Check if corrected processor exists
    if [ ! -f "$CORRECTED_PROCESSOR" ]; then
        log "ERROR" "Corrected processor not found: $CORRECTED_PROCESSOR"
        return 1
    fi
    
    # Check if corrected processor is executable
    if [ ! -x "$CORRECTED_PROCESSOR" ]; then
        log "ERROR" "Corrected processor is not executable: $CORRECTED_PROCESSOR"
        return 1
    fi
    
    # For cron job 54a989a6-a3fc-4ee8-9cfe-bea1d012660e, always process
    # regardless of time to ensure corrected logic is applied
    log "INFO" "Cron job 54a989a6-a3fc-4ee8-9cfe-bea1d012660e - processing emails regardless of time"
    
    return 0
}

run_corrected_processor() {
    log "INFO" "Running corrected email auto-processor..."
    log "INFO" "Cron ID: 54a989a6-a3fc-4ee8-9cfe-bea1d012660e"
    
    echo "========================================="
    echo "CORRECTED EMAIL AUTO-PROCESSOR"
    echo "Cron ID: 54a989a6-a3fc-4ee8-9cfe-bea1d012660e"
    echo "Time: $(date '+%A, %B %d, %Y — %I:%M %p (%Z)')"
    echo "========================================="
    
    # Run the corrected processor
    if "$CORRECTED_PROCESSOR"; then
        log "INFO" "Corrected email processor completed successfully"
        
        # Save status
        echo "last_run=$(date +%s)" > "$STATUS_FILE"
        echo "status=success" >> "$STATUS_FILE"
        echo "timestamp=$(date '+%Y-%m-%d %H:%M:%S')" >> "$STATUS_FILE"
        
        return 0
    else
        log "ERROR" "Corrected email processor failed"
        
        # Save error status
        echo "last_run=$(date +%s)" > "$STATUS_FILE"
        echo "status=error" >> "$STATUS_FILE"
        echo "timestamp=$(date '+%Y-%m-%d %H:%M:%S')" >> "$STATUS_FILE"
        
        return 1
    fi
}

# Main execution
main() {
    log "INFO" "=== Starting Corrected Email Processor Wrapper ==="
    
    # Always process for cron job 54a989a6-a3fc-4ee8-9cfe-bea1d012660e
    # to ensure corrected logic is applied regardless of time
    
    # Run the corrected processor
    if run_corrected_processor; then
        log "INFO" "=== Corrected Email Processing Complete ==="
        echo ""
        echo "CORRECTED LOGIC APPLIED:"
        echo "1. ✅ Emails FROM Temi → EXECUTE instructions (not create todos)"
        echo "2. ✅ Read full email content via AppleScript"
        echo "3. ✅ Extract 'please/kindly/can you' instructions"
        echo "4. ✅ Execute file updates, system configs, document prep"
        echo "5. ✅ Other emails → create appropriate todos"
        echo ""
        echo "Example: 'New IIH Organogram' email → update Documents/IIH folder, not create todo"
    else
        log "ERROR" "=== Corrected Email Processing Failed ==="
        return 1
    fi
    
    return 0
}

# Run main function
main "$@"