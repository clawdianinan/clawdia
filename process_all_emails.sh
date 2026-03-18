#!/bin/bash
# Process ALL emails and create smart todos

set -e

# Configuration
TODO_SCRIPT="scripts/todo.sh"
MAX_EMAILS=20
LOG_FILE="/tmp/process_all_emails.log"

# Function to log
log() {
    echo "[$(date '+%H:%M:%S')] $1" >> "$LOG_FILE"
}

# Check if email already has a todo
email_already_processed() {
    local subject="$1"
    local subject_clean=$(echo "$subject" | tr -d '[:punct:]' | tr '[:upper:]' '[:lower:]' | cut -c1-40 | tr -d ' ')
    
    # Check todos for similar subject
    if bash "$TODO_SCRIPT" entry list --all 2>/dev/null | grep -i "$subject_clean" >/dev/null; then
        return 0  # Already processed
    fi
    
    return 1  # Not processed
}

# Create todo from email
create_todo_from_email() {
    local email_id="$1"
    local subject="$2"
    local from="$3"
    local flags="$4"
    
    log "Creating todo from email $email_id: $subject"
    
    # Determine group
    local group="Inbox"
    if [[ "$from" == *"@iih.ng"* ]]; then
        group="IIH"
    elif [[ "$from" == *"Temi"* ]] || [[ "$from" == *"temi"* ]]; then
        group="Temi"
    elif [[ "$from" == *"@ihstowers.com"* ]]; then
        group="IHS"
    fi
    
    # Determine status
    local status="pending"
    if [[ "$subject" == *"URGENT"* ]] || [[ "$subject" == *"urgent"* ]] || [[ "$flags" == *"!"* ]]; then
        status="in_progress"
    fi
    
    # Create smart todo description
    local todo_desc=""
    local lower_subject=$(echo "$subject" | tr '[:upper:]' '[:lower:]')
    
    if [[ "$lower_subject" == *"organogram"* ]]; then
        todo_desc="Review and implement: $subject"
    elif [[ "$lower_subject" == *"report"* ]]; then
        todo_desc="Review report: $subject"
    elif [[ "$lower_subject" == *"meeting"* ]] || [[ "$lower_subject" == *"call"* ]]; then
        todo_desc="Prepare for: $subject"
    elif [[ "$lower_subject" == *"financial"* ]] || [[ "$lower_subject" == *"invoice"* ]]; then
        todo_desc="Process financial: $subject"
    elif [[ "$from" == *"@iih.ng"* ]]; then
        todo_desc="IIH internal: $subject"
    elif [[ "$from" == *"Temi"* ]]; then
        todo_desc="From Temi: $subject"
    else
        todo_desc="Process email: $subject"
    fi
    
    # Create the todo
    echo "  Creating: $todo_desc"
    bash "$TODO_SCRIPT" entry create "$todo_desc" --group="$group" --status="$status" >/dev/null 2>&1
}

# Main processing
main() {
    log "=== Processing ALL emails started ==="
    
    echo "PROCESSING ALL EMAILS"
    echo "====================="
    echo ""
    
    # Get all recent emails
    echo "Fetching emails..."
    emails=$(himalaya envelope list 2>/dev/null | tail -n +4 | head -$MAX_EMAILS)
    
    if [[ -z "$emails" ]]; then
        echo "No emails found"
        return 0
    fi
    
    email_count=$(echo "$emails" | wc -l)
    echo "Found $email_count emails to process"
    echo ""
    
    processed_count=0
    skipped_count=0
    
    # Process each email
    echo "$emails" | while read line; do
        # Parse email line
        email_id=$(echo "$line" | awk -F'|' '{print $2}' | xargs)
        flags=$(echo "$line" | awk -F'|' '{print $3}' | xargs)
        subject=$(echo "$line" | awk -F'|' '{print $4}' | xargs)
        from=$(echo "$line" | awk -F'|' '{print $5}' | xargs)
        
        # Skip if already processed
        if email_already_processed "$subject"; then
            ((skipped_count++))
            continue
        fi
        
        # Skip certain types
        if [[ "$subject" == *"Mail Delivery"* ]] || [[ "$from" == *"mailer-daemon"* ]]; then
            ((skipped_count++))
            continue
        fi
        
        # Create todo
        echo "📧 [$email_id] $subject"
        echo "   From: $from"
        create_todo_from_email "$email_id" "$subject" "$from" "$flags"
        ((processed_count++))
        echo ""
    done
    
    echo "=== PROCESSING COMPLETE ==="
    echo "Processed: $processed_count emails"
    echo "Skipped: $skipped_count (already processed or system)"
    echo ""
    
    # Show current todo count
    echo "CURRENT TODO STATUS:"
    bash "$TODO_SCRIPT" entry list 2>/dev/null | head -10
    
    log "=== Processing ALL emails completed ==="
}

# Run main
main "$@"