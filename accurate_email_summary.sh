#!/bin/bash
# Accurate Email Summary Script
# No false claims about specific people

set -e

# Configuration
MAX_EMAILS=10
LOG_FILE="/tmp/accurate_email_summary.log"

# Function to log
log() {
    echo "[$(date '+%H:%M:%S')] $1" >> "$LOG_FILE"
}

# Get accurate email summary
get_accurate_summary() {
    log "Starting accurate email check"
    
    # Get recent emails
    local emails_json
    if ! emails_json=$(himalaya envelope list --limit $MAX_EMAILS --output json 2>/dev/null); then
        echo "❌ Email check failed"
        return 1
    fi
    
    local email_count=$(echo "$emails_json" | jq 'length')
    log "Found $email_count recent emails"
    
    if [[ "$email_count" -eq 0 ]]; then
        echo "📭 No recent emails"
        return 0
    fi
    
    # Accurate counts
    local unread_count=0
    local iih_count=0
    local external_count=0
    local summary="📧 ACCURATE EMAIL SUMMARY $(date '+%H:%M')\n\n"
    
    # Analyze emails without false claims
    for i in $(seq 0 $((email_count - 1))); do
        local email=$(echo "$emails_json" | jq -r ".[$i]")
        local subject=$(echo "$email" | jq -r '.subject')
        local from=$(echo "$email" | jq -r '.from')
        local flags=$(echo "$email" | jq -r '.flags')
        
        # Check if unread
        if [[ "$flags" != *"Seen"* ]]; then
            ((unread_count++))
            
            # Accurate categorization (no false claims about specific people)
            if [[ "$from" == *"@iih.ng"* ]]; then
                ((iih_count++))
                # Don't claim to know specific people unless we have their exact email
                summary+="🏢 IIH: $subject\n"
            elif [[ "$from" == *"@ihstowers.com"* ]]; then
                ((external_count++))
                summary+="📋 IHS: $subject\n"
            else
                ((external_count++))
                # Truncate long subjects
                local short_subject="$subject"
                if [[ ${#short_subject} -gt 40 ]]; then
                    short_subject="${short_subject:0:37}..."
                fi
                summary+="📨 $short_subject\n"
            fi
        fi
    done
    
    # Generate accurate header
    local header=""
    if [[ "$unread_count" -eq 0 ]]; then
        header="📭 No unread emails"
    elif [[ "$iih_count" -gt 0 ]] && [[ "$external_count" -gt 0 ]]; then
        header="📬 $unread_count unread ($iih_count IIH, $external_count external)"
    elif [[ "$iih_count" -gt 0 ]]; then
        header="📬 $unread_count unread ($iih_count IIH)"
    elif [[ "$external_count" -gt 0 ]]; then
        header="📬 $unread_count unread ($external_count external)"
    else
        header="📬 $unread_count unread emails"
    fi
    
    echo -e "$header\n\n$summary"
    log "Accurate summary: $unread_count unread, $iih_count IIH, $external_count external"
}

# Main execution
main() {
    log "=== Accurate email summary started ==="
    
    local output
    output=$(get_accurate_summary)
    local exit_code=$?
    
    if [[ $exit_code -ne 0 ]]; then
        log "ERROR: Email check failed with code $exit_code"
        echo "❌ Email check failed"
    else
        echo -e "$output"
        log "Successfully generated accurate email summary"
    fi
    
    log "=== Accurate email summary completed ==="
}

# Run main
main "$@"