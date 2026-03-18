#!/bin/bash
# Mail notification handler for OpenClaw
# This script should be triggered when Mail app receives a new email
# It will check if the email is from Temi and process it immediately

set -e

# Configuration
LOG_FILE="/tmp/mail_notification_handler.log"
OPENCLAW_CLI="/opt/homebrew/bin/openclaw"

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Function to trigger OpenClaw email processing
trigger_email_processing() {
    log "Triggering immediate email processing"
    
    # Run the Temi Email Processor cron job immediately
    if command -v "$OPENCLAW_CLI" >/dev/null 2>&1; then
        # We can trigger the cron job or run a direct agent command
        "$OPENCLAW_CLI" cron run --id d18a4267-9138-4d4f-8de4-0d6f013cac51 2>&1 | tee -a "$LOG_FILE"
    else
        log "Error: OpenClaw CLI not found at $OPENCLAW_CLI"
    fi
}

# Function to check if notification is from Mail app
is_mail_notification() {
    local notification_info="$1"
    
    # Check if it's from Mail app
    if echo "$notification_info" | grep -q "Mail"; then
        return 0
    fi
    
    return 1
}

# Main function - can be called from notification automation
main() {
    log "Mail notification handler started"
    
    # Check if we have notification info passed as argument
    if [[ $# -gt 0 ]]; then
        notification_info="$*"
        log "Received notification: $notification_info"
        
        if is_mail_notification "$notification_info"; then
            log "Mail notification detected, triggering processing"
            trigger_email_processing
        else
            log "Ignoring non-Mail notification"
        fi
    else
        # No arguments, just trigger processing (for manual testing)
        log "No notification info, triggering processing anyway"
        trigger_email_processing
    fi
    
    log "Handler completed"
}

# Run main function
main "$@"