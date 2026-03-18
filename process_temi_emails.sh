#!/bin/bash
# Process Temi's emails automatically
# This script checks for emails from Temi Kolawole and processes instructions
# Emails from other sources are referred to Temi for next action

set -e

# Configuration
LOG_FILE="/tmp/clawdia_email_processor.log"
MAX_EMAILS_TO_PROCESS=10

# Temi's known email addresses (USER emails)
TEMI_EMAILS=(
    "temi@iih.ng"
    "temi.kolawole@iih.ng"
    "temikolawole@icloud.com"
    "temikolawole@gmail.com"
)

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Function to check if email is from Temi
is_from_temi() {
    local from="$1"
    for temi_email in "${TEMI_EMAILS[@]}"; do
        if [[ "$from" == *"$temi_email"* ]]; then
            return 0
        fi
    done
    return 1
}

# Function to process email from Temi
process_temi_email() {
    local email_id="$1"
    local subject="$2"
    local from="$3"
    
    log "Processing email from Temi: ID=$email_id, Subject='$subject', From='$from'"
    
    # Get email body
    local body=$(himalaya read "$email_id" --output json | jq -r '.body.text // .body.html // ""' | head -1000)
    
    if [[ -z "$body" ]]; then
        log "Warning: Could not extract body from email $email_id"
        return 1
    fi
    
    log "Email body preview: ${body:0:200}..."
    
    # Here we would process the instruction in the email
    # For now, just log it and create a task
    echo "📧 Email from Temi processed:
From: $from
Subject: $subject
Body preview: ${body:0:200}...

Instruction detected in email. This would be processed automatically by Clawdia."
    
    # Mark as read (optional)
    # himalaya flag "$email_id" --read
    
    return 0
}

# Function to refer non-Temi email to Temi
refer_to_temi() {
    local email_id="$1"
    local subject="$2"
    local from="$3"
    
    log "Referring email to Temi: ID=$email_id, Subject='$subject', From='$from'"
    
    echo "📧 Email requires Temi's attention:
From: $from
Subject: $subject

This email is from an external source and requires your review."
    
    # We could send a notification via Telegram/WhatsApp here
    # For now, just log it
}

# Main execution
main() {
    log "Starting email processing run"
    
    # Get recent unread emails
    local emails_json
    if ! emails_json=$(himalaya envelope list --limit $MAX_EMAILS_TO_PROCESS --output json 2>/dev/null); then
        log "Error: Failed to fetch emails with himalaya"
        return 1
    fi
    
    # Check if we got any emails
    local email_count=$(echo "$emails_json" | jq 'length')
    log "Found $email_count recent emails to process"
    
    if [[ "$email_count" -eq 0 ]]; then
        log "No emails to process"
        return 0
    fi
    
    # Process each email
    for i in $(seq 0 $((email_count - 1))); do
        local email=$(echo "$emails_json" | jq -r ".[$i]")
        local email_id=$(echo "$email" | jq -r '.id')
        local subject=$(echo "$email" | jq -r '.subject')
        local from=$(echo "$email" | jq -r '.from')
        local is_read=$(echo "$email" | jq -r '.flags | contains("Seen")')
        
        # Skip already read emails if we want to process only new ones
        # if [[ "$is_read" == "true" ]]; then
        #     continue
        # fi
        
        log "Processing email ID $email_id: From='$from', Subject='$subject', Read=$is_read"
        
        if is_from_temi "$from"; then
            process_temi_email "$email_id" "$subject" "$from"
        else
            refer_to_temi "$email_id" "$subject" "$from"
        fi
    done
    
    log "Email processing run completed"
    return 0
}

# Run main function
main "$@"