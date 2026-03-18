#!/bin/bash
# Fast Email Summary Script
# Designed to run quickly and deliver to iMessage

set -e

# Configuration
MAX_EMAILS=5  # Only check most recent 5 emails for speed
LOG_FILE="/tmp/fast_email_summary.log"

# Function to log
log() {
    echo "[$(date '+%H:%M:%S')] $1" >> "$LOG_FILE"
}

# Get quick email summary
get_email_summary() {
    log "Starting fast email check"
    
    # Get recent emails quickly
    local emails_json
    if ! emails_json=$(himalaya envelope list --limit $MAX_EMAILS --output json 2>/dev/null); then
        echo "❌ Email check failed"
        return 1
    fi
    
    local email_count=$(echo "$emails_json" | jq 'length')
    log "Found $email_count recent emails"
    
    if [[ "$email_count" -eq 0 ]]; then
        echo "📭 No recent emails found"
        return 0
    fi
    
    # Count unread
    local unread_count=0
    local urgent_count=0
    local summary="📧 EMAIL SUMMARY $(date '+%H:%M')\n\n"
    
    # Quick analysis
    for i in $(seq 0 $((email_count - 1))); do
        local email=$(echo "$emails_json" | jq -r ".[$i]")
        local subject=$(echo "$email" | jq -r '.subject')
        local from=$(echo "$email" | jq -r '.from')
        local flags=$(echo "$email" | jq -r '.flags')
        
        # Check if unread
        if [[ "$flags" != *"Seen"* ]]; then
            ((unread_count++))
            
            # Check for urgency
            local urgent=false
            if [[ "$from" == *"@ihstowers.com"* ]]; then
                urgent=true
                ((urgent_count++))
                summary+="🚨 URGENT (IHS): $subject\n"
            elif [[ "$subject" =~ [Uu][Rr][Gg][Ee][Nn][Tt] ]] || [[ "$subject" =~ [Ii][Mm][Mm][Ee][Dd][Ii][Aa][Tt][Ee] ]]; then
                urgent=true
                ((urgent_count++))
                summary+="⚠️  URGENT: $subject\n"
            fi
            
            if ! $urgent; then
                # Truncate long subjects
                local short_subject="$subject"
                if [[ ${#short_subject} -gt 40 ]]; then
                    short_subject="${short_subject:0:37}..."
                fi
                summary+="• $short_subject\n"
            fi
        fi
    done
    
    # Add summary header
    local header=""
    if [[ "$urgent_count" -gt 0 ]]; then
        header="📬 $unread_count new emails ($urgent_count URGENT)"
    else
        header="📬 $unread_count new emails"
    fi
    
    echo -e "$header\n\n$summary"
    log "Summary generated: $unread_count unread, $urgent_count urgent"
}

# Main execution
main() {
    log "=== Fast email summary started ==="
    
    # Run email check (without timeout for now)
    local output
    output=$(get_email_summary)
    local exit_code=$?
    
    if [[ $exit_code -ne 0 ]]; then
        log "ERROR: Email check failed with code $exit_code"
        echo "❌ Email check failed"
    else
        echo -e "$output"
        log "Successfully generated email summary"
    fi
    
    log "=== Fast email summary completed ==="
}

# Run main
main "$@"