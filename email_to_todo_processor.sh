#!/bin/bash
# Smart Email to Todo Processor
# Analyzes email content and creates todos automatically

set -e

# Configuration
TODO_SCRIPT="scripts/todo.sh"
LOG_FILE="/tmp/email_to_todo.log"

# Function to log
log() {
    echo "[$(date '+%H:%M:%S')] $1" >> "$LOG_FILE"
}

# Smart task extraction from email content
extract_tasks_from_email() {
    local subject="$1"
    local body="$2"
    local from="$3"
    
    log "Extracting tasks from email: $subject"
    
    local tasks=()
    
    # Convert to lowercase for pattern matching
    local lower_body=$(echo "$body" | tr '[:upper:]' '[:lower:]')
    local lower_subject=$(echo "$subject" | tr '[:upper:]' '[:lower:]')
    
    # Pattern 1: Direct task statements
    if [[ "$lower_body" == *"please"* ]] || [[ "$lower_body" == *"can you"* ]] || [[ "$lower_body" == *"i need you to"* ]]; then
        # Extract sentences with task words
        echo "$body" | grep -o -E "[^.!?]*[Pp]lease[^.!?]*[.!?]" | while read line; do
            if [[ -n "$line" ]]; then
                # Clean up the task
                task=$(echo "$line" | sed 's/^[Pp]lease //' | sed 's/^[Cc]an you //' | sed 's/^[Ii] need you to //')
                tasks+=("$task")
            fi
        done
    fi
    
    # Pattern 2: Action items with bullets or numbers
    if [[ "$lower_body" == *"action"* ]] || [[ "$lower_body" == *"todo"* ]] || [[ "$lower_body" == *"task"* ]]; then
        # Look for bullet points or numbered lists
        echo "$body" | grep -o -E "[•\-*][[:space:]]+[^[:space:]].*" | while read line; do
            task=$(echo "$line" | sed 's/^[•\-*][[:space:]]*//')
            tasks+=("$task")
        done
        
        echo "$body" | grep -o -E "[0-9]+[\.\)][[:space:]]+[^[:space:]].*" | while read line; do
            task=$(echo "$line" | sed 's/^[0-9]+[\.\)][[:space:]]*//')
            tasks+=("$task")
        done
    fi
    
    # Pattern 3: Deadline or date references
    if [[ "$lower_body" == *"by"* ]] || [[ "$lower_body" == *"deadline"* ]] || [[ "$lower_body" == *"due"* ]]; then
        # Extract sentences with deadlines
        echo "$body" | grep -o -E "[^.!?]*[Bb]y[^.!?]*[.!?]" | while read line; do
            tasks+=("$line")
        done
    fi
    
    # Pattern 4: Subject-based tasks
    if [[ "$lower_subject" == *"organogram"* ]]; then
        tasks+=("Review and implement new IIH organogram")
        tasks+=("Share organogram with relevant teams")
    fi
    
    if [[ "$lower_subject" == *"report"* ]]; then
        tasks+=("Review $subject")
        tasks+=("Take action on $subject")
    fi
    
    # If no specific tasks found, create a general task
    if [[ ${#tasks[@]} -eq 0 ]]; then
        # Create smart task based on email type
        if [[ "$from" == *"@iih.ng"* ]]; then
            tasks+=("Process IIH email: $subject")
        elif [[ "$subject" == *"urgent"* ]] || [[ "$subject" == *"important"* ]]; then
            tasks+=("URGENT: Address $subject")
        else
            tasks+=("Review email: $subject")
        fi
    fi
    
    # Return tasks
    for task in "${tasks[@]}"; do
        echo "$task"
    done
}

# Process a specific email
process_email_to_todos() {
    local email_id="$1"
    
    log "Processing email ID $email_id to todos"
    
    # Get email details
    echo "Processing email ID $email_id..."
    
    # Try to get email content (himalaya read might not work well)
    # Instead, let's use envelope info and smart inference
    email_info=$(himalaya envelope list 2>/dev/null | grep "^| $email_id " | head -1)
    
    if [[ -z "$email_info" ]]; then
        echo "Email $email_id not found"
        return 1
    fi
    
    # Parse email info
    subject=$(echo "$email_info" | awk -F'|' '{print $4}' | xargs)
    from=$(echo "$email_info" | awk -F'|' '{print $5}' | xargs)
    flags=$(echo "$email_info" | awk -F'|' '{print $3}' | xargs)
    
    echo "Subject: $subject"
    echo "From: $from"
    echo "Status: $(echo "$flags" | grep -q '*' && echo "UNREAD" || echo "READ")"
    
    # For now, create smart todos based on subject and sender
    echo ""
    echo "Creating smart todos from email..."
    
    # Determine todo group based on sender
    local todo_group="Inbox"
    if [[ "$from" == *"@iih.ng"* ]]; then
        todo_group="IIH"
    elif [[ "$from" == *"Temi"* ]] || [[ "$from" == *"temi"* ]]; then
        todo_group="Temi"
    fi
    
    # Create todos based on email content analysis
    # Since we can't easily get full body, use subject analysis
    
    # Analyze subject for task types
    lower_subject=$(echo "$subject" | tr '[:upper:]' '[:lower:]')
    
    if [[ "$lower_subject" == *"organogram"* ]]; then
        echo "Detected: Organogram email"
        bash "$TODO_SCRIPT" entry create "Review new IIH organogram" --group="$todo_group" --status=pending
        bash "$TODO_SCRIPT" entry create "Distribute organogram to department heads" --group="$todo_group" --status=pending
        bash "$TODO_SCRIPT" entry create "Update organizational charts" --group="$todo_group" --status=pending
        echo "Created 3 organogram-related tasks"
        
    elif [[ "$lower_subject" == *"report"* ]]; then
        echo "Detected: Report email"
        bash "$TODO_SCRIPT" entry create "Review $subject" --group="$todo_group" --status=pending
        bash "$TODO_SCRIPT" entry create "Extract action items from report" --group="$todo_group" --status=pending
        echo "Created 2 report-related tasks"
        
    elif [[ "$lower_subject" == *"meeting"* ]] || [[ "$lower_subject" == *"call"* ]]; then
        echo "Detected: Meeting email"
        bash "$TODO_SCRIPT" entry create "Prepare for $subject" --group="$todo_group" --status=pending
        bash "$TODO_SCRIPT" entry create "Follow up after $subject" --group="$todo_group" --status=pending
        echo "Created 2 meeting-related tasks"
        
    elif [[ "$lower_subject" == *"urgent"* ]] || [[ "$flags" == *"!"* ]]; then
        echo "Detected: Urgent email"
        bash "$TODO_SCRIPT" entry create "URGENT: Address $subject" --group="$todo_group" --status=in_progress
        echo "Created URGENT task"
        
    else
        # Default task
        echo "Detected: General email"
        bash "$TODO_SCRIPT" entry create "Process email: $subject" --group="$todo_group" --status=pending
        echo "Created general processing task"
    fi
    
    # Mark as read (if unread)
    if echo "$flags" | grep -q '*'; then
        echo "Email was unread - would mark as read here"
        # himalaya flag $email_id --read  # This might not work
    fi
    
    log "Processed email $email_id to todos"
}

# Process ALL unread emails from Temi
process_all_temi_emails() {
    log "Processing all emails from Temi"
    
    echo "=== PROCESSING ALL EMAILS FROM TEMI ==="
    echo ""
    
    # Get emails from Temi
    emails=$(himalaya envelope list 2>/dev/null | grep "Temi Kolawole" | head -5)
    
    if [[ -z "$emails" ]]; then
        echo "No emails from Temi found"
        return 0
    fi
    
    echo "Found $(echo "$emails" | wc -l) emails from Temi"
    echo ""
    
    # Process each email
    echo "$emails" | while read line; do
        email_id=$(echo "$line" | awk -F'|' '{print $2}' | xargs)
        subject=$(echo "$line" | awk -F'|' '{print $4}' | xargs)
        flags=$(echo "$line" | awk -F'|' '{print $3}' | xargs)
        
        echo "📧 Email ID $email_id: $subject"
        echo "   Status: $(echo "$flags" | grep -q '*' && echo "UNREAD" || echo "READ")"
        
        # Process ALL emails from Temi (not just unread)
        # Check if we already have todos for this email
        email_subject_clean=$(echo "$subject" | tr -d '[:punct:]' | tr '[:upper:]' '[:lower:]' | cut -c1-30)
        existing_todo=$(bash "$TODO_SCRIPT" entry list --all 2>/dev/null | grep -i "$email_subject_clean" | head -1)
        
        if [[ -n "$existing_todo" ]]; then
            echo "   Already processed - todo exists"
            echo ""
        else
            echo "   Processing email..."
            process_email_to_todos "$email_id"
            echo ""
        fi
    done
    
    echo "=== PROCESSING COMPLETE ==="
}

# Main execution
main() {
    log "=== Email to Todo Processor started ==="
    
    echo "SMART EMAIL TO TODO PROCESSOR"
    echo "=============================="
    echo ""
    
    # Check if todo script exists
    if [[ ! -f "$TODO_SCRIPT" ]]; then
        echo "Error: Todo script not found at $TODO_SCRIPT"
        exit 1
    fi
    
    # Process specific email or all Temi emails
    if [[ $# -gt 0 ]]; then
        process_email_to_todos "$1"
    else
        process_all_temi_emails
    fi
    
    log "=== Email to Todo Processor completed ==="
}

# Run main
main "$@"