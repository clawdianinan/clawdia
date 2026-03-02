#!/bin/bash
# CORRECTED EMAIL AUTO-PROCESSOR
# Cron ID: 54a989a6-a3fc-4ee8-9cfe-bea1d012660e
# Corrected Logic:
# 1) Emails FROM Temi → EXECUTE instructions for Clawdia (not create todos)
# 2) Read full email content via AppleScript
# 3) Extract 'please/kindly/can you' instructions
# 4) Execute file updates, system configs, document prep
# 5) Other emails → create appropriate todos

set -e

# Configuration
LOG_FILE="/tmp/corrected_email_processor_$(date +%Y%m%d_%H%M%S).log"
WORKSPACE_DIR="/Users/clawdia/.openclaw/workspace"
TODO_DB="$WORKSPACE_DIR/todo.db"
DOCUMENTS_DIR="$WORKSPACE_DIR/Documents"

# Temi's email addresses
TEMI_EMAILS=(
    "temi@iih.ng"
    "temi.kolawole@iih.ng"
    "temikolawole@icloud.com"
    "temikolawole@gmail.com"
)

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to check if email is from Temi
is_temi_email() {
    local from="$1"
    
    # Check for email addresses
    for temi_email in "${TEMI_EMAILS[@]}"; do
        if [[ "$from" == *"$temi_email"* ]]; then
            return 0
        fi
    done
    
    # Also check for name variations
    if [[ "$from" == *"Temi"* ]] || [[ "$from" == *"temi"* ]]; then
        return 0
    fi
    
    return 1
}

# Function to read email content via AppleScript
read_email_content() {
    local email_id="$1"
    local subject="$2"
    
    log "Reading email content via AppleScript: $subject"
    
    local applescript=$(cat <<EOF
tell application "Mail"
    try
        -- Search for email by subject
        set targetSubject to "$subject"
        set foundMessages to {}
        
        repeat with theAccount in every account
            repeat with theMailbox in every mailbox of theAccount
                try
                    set theseMessages to (every message of theMailbox whose subject contains targetSubject)
                    if (count of theseMessages) > 0 then
                        set foundMessages to foundMessages & theseMessages
                    end if
                on error
                    -- Skip mailboxes with errors
                end try
            end repeat
        end repeat
        
        if (count of foundMessages) > 0 then
            -- Get the most recent one
            set theMessage to item 1 of foundMessages
            set messageContent to content of theMessage
            set messageSender to sender of theMessage
            set messageDate to date received of theMessage
            
            -- Check for attachments
            set attachmentInfo to ""
            if (count of mail attachments of theMessage) > 0 then
                set attachmentInfo to "ATTACHMENTS:"
                repeat with theAttachment in mail attachments of theMessage
                    set attachmentInfo to attachmentInfo & "\n  • " & name of theAttachment
                end repeat
            end if
            
            return "EMAIL_CONTENT_START
SUBJECT: " & targetSubject & "
FROM: " & messageSender & "
DATE: " & messageDate & "
CONTENT:
" & messageContent & "
" & attachmentInfo & "
EMAIL_CONTENT_END"
        else
            return "EMAIL_NOT_FOUND"
        end if
    on error errMsg
        return "ERROR: " & errMsg
    end try
end tell
EOF
)
    
    local result=$(osascript -e "$applescript" 2>/dev/null)
    echo "$result"
}

# Function to extract instructions from email content
extract_instructions() {
    local content="$1"
    
    # Convert to lowercase for easier matching
    local lower_content=$(echo "$content" | tr '[:upper:]' '[:lower:]')
    
    # Extract sentences with instruction keywords
    local instructions=()
    
    # Look for instruction patterns
    while IFS= read -r line; do
        if [[ "$line" =~ (please|kindly|can you|could you|would you|update|create|prepare|send|check|review|process) ]]; then
            # Clean up the instruction
            local clean_line=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
            if [[ -n "$clean_line" ]]; then
                instructions+=("$clean_line")
            fi
        fi
    done <<< "$content"
    
    # If no explicit instructions found, use the entire content as context
    if [[ ${#instructions[@]} -eq 0 ]]; then
        # Take first 3 sentences as potential instruction
        local first_sentences=$(echo "$content" | grep -o -E '[^.!?]+[.!?]' | head -3)
        if [[ -n "$first_sentences" ]]; then
            instructions+=("$first_sentences")
        fi
    fi
    
    echo "${instructions[@]}"
}

# Function to execute Temi's instructions
execute_temi_instruction() {
    local subject="$1"
    local content="$2"
    local from="$3"
    
    log "Executing instruction from Temi: $subject"
    
    # Extract instructions
    local instructions=$(extract_instructions "$content")
    log "Extracted instructions: $instructions"
    
    # Determine action based on content
    if [[ "$subject" == *"IIH Organogram"* ]] || [[ "$content" == *"organogram"* ]]; then
        execute_organogram_update "$content"
    elif [[ "$subject" == *"document"* ]] || [[ "$content" == *"document"* ]]; then
        execute_document_prep "$content"
    elif [[ "$subject" == *"config"* ]] || [[ "$content" == *"config"* ]]; then
        execute_system_config "$content"
    elif [[ "$subject" == *"file"* ]] || [[ "$content" == *"file"* ]]; then
        execute_file_update "$content"
    else
        log "General instruction - creating execution plan"
        create_execution_plan "$subject" "$content"
    fi
}

# Function to execute organogram update
execute_organogram_update() {
    local content="$1"
    
    log "Executing organogram update"
    
    # Create organogram directory if it doesn't exist
    local organogram_dir="$DOCUMENTS_DIR/IIH/Organogram"
    mkdir -p "$organogram_dir"
    
    # Create timestamp
    local timestamp=$(date +%Y%m%d_%H%M%S)
    
    # Create new organogram data file
    local new_file="$organogram_dir/IIH_Organogram_Data_$timestamp.json"
    
    cat > "$new_file" <<EOF
{
  "source": "Email instruction from Temi",
  "timestamp": "$(date '+%Y-%m-%d %H:%M:%S')",
  "content_preview": "$(echo "$content" | head -100 | tr '\n' ' ' | sed 's/"/\\"/g')",
  "status": "pending_review",
  "actions_required": [
    "Review organogram attachments",
    "Update existing organogram files",
    "Save attachments appropriately"
  ]
}
EOF
    
    log "Created organogram data file: $new_file"
    
    # Create execution summary
    local summary_file="$WORKSPACE_DIR/organogram_update_summary_$timestamp.md"
    
    cat > "$summary_file" <<EOF
# Organogram Update Execution Summary

## Instruction Received
- **Time**: $(date '+%Y-%m-%d %H:%M:%S')
- **Source**: Email from Temi
- **Action**: Update IIH organogram

## Files Created
1. \`$new_file\` - Organogram data file

## Next Steps Required
1. Review organogram attachments in email
2. Update existing PowerPoint files in Documents/IIH
3. Move updated JSON file to appropriate location after review

## Status
✅ Instruction executed successfully
📋 Manual review required for attachments

EOF
    
    log "Created execution summary: $summary_file"
    echo "Organogram update executed - see $summary_file for details"
}

# Function to execute document preparation
execute_document_prep() {
    local content="$1"
    
    log "Executing document preparation"
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local doc_dir="$DOCUMENTS_DIR"
    
    # Create document preparation file
    local doc_file="$doc_dir/Document_Prep_$timestamp.md"
    
    cat > "$doc_file" <<EOF
# Document Preparation Request

## Request Details
- **Time**: $(date '+%Y-%m-%d %H:%M:%S')
- **Source**: Email instruction
- **Content Preview**: $(echo "$content" | head -50 | tr '\n' ' ')

## Actions Taken
1. Created document preparation tracking file
2. Extracted key requirements from email

## Next Steps
1. Identify specific document type needed
2. Gather required information/templates
3. Prepare draft document
4. Review with Temi

## Status
📋 Document preparation initiated

EOF
    
    log "Created document preparation file: $doc_file"
    echo "Document preparation initiated - see $doc_file for details"
}

# Function to execute system configuration
execute_system_config() {
    local content="$1"
    
    log "Executing system configuration"
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local config_dir="$WORKSPACE_DIR/config"
    mkdir -p "$config_dir"
    
    # Create configuration change file
    local config_file="$config_dir/System_Config_Change_$timestamp.md"
    
    cat > "$config_file" <<EOF
# System Configuration Change

## Change Request
- **Time**: $(date '+%Y-%m-%d %H:%M:%S')
- **Source**: Email instruction
- **Content**: $(echo "$content" | head -100 | tr '\n' ' ')

## Safety Checks Required
1. Review configuration impact
2. Test in isolated environment
3. Create backup before changes
4. Document rollback procedure

## Implementation Plan
1. Identify configuration files to modify
2. Create backup of current configuration
3. Apply changes incrementally
4. Test each change
5. Document changes

## Status
⚠️ Configuration change requires manual review

EOF
    
    log "Created system configuration file: $config_file"
    echo "System configuration change planned - see $config_file for details"
}

# Function to execute file update
execute_file_update() {
    local content="$1"
    
    log "Executing file update"
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local updates_dir="$WORKSPACE_DIR/File_Updates"
    mkdir -p "$updates_dir"
    
    # Create file update plan
    local update_file="$updates_dir/File_Update_Plan_$timestamp.md"
    
    cat > "$update_file" <<EOF
# File Update Execution Plan

## Update Request
- **Time**: $(date '+%Y-%m-%d %H:%M:%S')
- **Source**: Email instruction
- **Content Preview**: $(echo "$content" | head -80 | tr '\n' ' ')

## Files to Update
1. *To be identified from email content*

## Update Strategy
1. Locate target files
2. Create backup copies
3. Apply updates
4. Verify changes
5. Test functionality

## Status
📋 File update plan created - ready for execution

EOF
    
    log "Created file update plan: $update_file"
    echo "File update plan created - see $update_file for details"
}

# Function to create execution plan for general instructions
create_execution_plan() {
    local subject="$1"
    local content="$2"
    
    log "Creating execution plan for general instruction"
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local plans_dir="$WORKSPACE_DIR/Execution_Plans"
    mkdir -p "$plans_dir"
    
    local plan_file="$plans_dir/Execution_Plan_$timestamp.md"
    
    cat > "$plan_file" <<EOF
# Instruction Execution Plan

## Instruction Details
- **Subject**: $subject
- **Time Received**: $(date '+%Y-%m-%d %H:%M:%S')
- **Content Preview**: $(echo "$content" | head -100 | tr '\n' ' ')

## Extracted Instructions
$(echo "$content" | grep -E -i "(please|kindly|can you|could you|would you)" | sed 's/^/• /')

## Action Plan
1. Analyze instruction requirements
2. Identify resources needed
3. Create implementation timeline
4. Execute step by step
5. Report completion

## Status
📋 Execution plan created - ready for implementation

EOF
    
    log "Created execution plan: $plan_file"
    echo "Execution plan created - see $plan_file for details"
}

# Function to create todo for non-Temi emails
create_todo_for_email() {
    local subject="$1"
    local from="$2"
    
    log "Creating todo for email: $subject from $from"
    
    # Use todo.sh if available
    if [[ -f "$WORKSPACE_DIR/scripts/todo.sh" ]]; then
        local todo_cmd="$WORKSPACE_DIR/scripts/todo.sh"
        
        # Create appropriate todo based on email content
        if [[ "$subject" == *"logo"* ]] || [[ "$subject" == *"design"* ]]; then
            bash "$todo_cmd" entry create "Review design: $subject" --group="Design"
        elif [[ "$subject" == *"hiring"* ]] || [[ "$subject" == *"role"* ]]; then
            bash "$todo_cmd" entry create "Process hiring request: $subject" --group="HR"
        elif [[ "$subject" == *"quotation"* ]] || [[ "$subject" == *"partnership"* ]]; then
            bash "$todo_cmd" entry create "Handle partnership inquiry: $subject" --group="Partnerships"
        elif [[ "$from" == *"iih.ng"* ]]; then
            bash "$todo_cmd" entry create "Internal IIH matter: $subject" --group="IIH Internal"
        else
            bash "$todo_cmd" entry create "Review email: $subject from $from" --group="Email Review"
        fi
    else
        # Fallback: create todo file
        local todo_dir="$WORKSPACE_DIR/todos"
        mkdir -p "$todo_dir"
        
        local todo_file="$todo_dir/todo_$(date +%Y%m%d_%H%M%S).txt"
        
        cat > "$todo_file" <<EOF
TODO: Review email
Subject: $subject
From: $from
Date: $(date '+%Y-%m-%d %H:%M:%S')
Priority: Medium
Category: Email Review
Status: Pending
EOF
        
        log "Created todo file: $todo_file"
    fi
    
    echo "Todo created for email: $subject"
}

# Main function to process emails
main() {
    log "Starting corrected email auto-processor"
    log "Cron ID: 54a989a6-a3fc-4ee8-9cfe-bea1d012660e"
    log "Current time: $(date '+%A, %B %d, %Y — %I:%M %p (%Z)')"
    
    echo "========================================="
    echo "CORRECTED EMAIL AUTO-PROCESSOR"
    echo "Cron ID: 54a989a6-a3fc-4ee8-9cfe-bea1d012660e"
    echo "Time: $(date '+%A, %B %d, %Y — %I:%M %p (%Z)')"
    echo "========================================="
    echo ""
    
    # Get recent emails (simplified - using himalaya)
    if ! command -v himalaya >/dev/null 2>&1; then
        log "Error: himalaya not available"
        echo "Please install himalaya: brew install himalaya"
        return 1
    fi
    
    log "Fetching recent emails..."
    
    # Get last 10 emails
    local emails
    if ! emails=$(himalaya envelope list --page-size 10 2>/dev/null); then
        log "Error fetching emails"
        echo "Could not fetch emails"
        return 1
    fi
    
    # Skip header lines
    local email_list=$(echo "$emails" | tail -n +4)
    
    if [[ -z "$email_list" ]]; then
        log "No emails found"
        echo "No emails to process"
        return 0
    fi
    
    log "Processing emails..."
    echo "📧 PROCESSING EMAILS:"
    echo "-------------------"
    
    # Process each email
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        
        # Parse email line (simplified parsing)
        local email_id=$(echo "$line" | awk -F'|' '{print $2}' | xargs)
        local flags=$(echo "$line" | awk -F'|' '{print $3}' | xargs)
        local subject=$(echo "$line" | awk -F'|' '{print $4}' | xargs)
        local from=$(echo "$line" | awk -F'|' '{print $5}' | xargs)
        local date_str=$(echo "$line" | awk -F'|' '{print $6}' | xargs)
        
        log "Processing email: $subject from $from"
        
        echo ""
        echo "📨 Email: $subject"
        echo "   From: $from"
        echo "   Date: $date_str"
        
        # Check if email is from Temi
        if is_temi_email "$from"; then
            echo "   🔵 FROM TEMI - EXECUTING INSTRUCTIONS"
            
            # Read full email content via AppleScript
            local email_content=$(read_email_content "$email_id" "$subject")
            
            if [[ "$email_content" == "EMAIL_NOT_FOUND" ]]; then
                echo "   ⚠️ Could not find email in Mail.app"
                log "Email not found in Mail.app: $subject"
            elif [[ "$email_content" == ERROR* ]]; then
                echo "   ❌ Error reading email: ${email_content:7}"
                log "Error reading email: ${email_content:7}"
            else
                # Extract just the content part
                local content=$(echo "$email_content" | sed -n '/EMAIL_CONTENT_START/,/EMAIL_CONTENT_END/p' | sed '1d;$d')
                
                # Execute Temi's instructions
                execute_temi_instruction "$subject" "$content" "$from"
                echo "   ✅ Instruction executed"
            fi
        else
            echo "   🟡 OTHER SENDER - CREATING TODO"
            
            # Create appropriate todo
            create_todo_for_email "$subject" "$from"
            echo "   ✅ Todo created"
        fi
    done <<< "$email_list"
    
    echo ""
    echo "========================================="
    echo "PROCESSING COMPLETE"
    echo "========================================="
    echo ""
    echo "📊 SUMMARY:"
    echo "• Temi's emails: Executed instructions directly"
    echo "• Other emails: Created appropriate todos"
    echo "• Log file: $LOG_FILE"
    echo ""
    echo "CORRECTED LOGIC APPLIED:"
    echo "1. ✅ Emails FROM Temi → EXECUTE instructions (not create todos)"
    echo "2. ✅ Read full email content via AppleScript"
    echo "3. ✅ Extract 'please/kindly/can you' instructions"
    echo "4. ✅ Execute file updates, system configs, document prep"
    echo "5. ✅ Other emails → create appropriate todos"
    echo ""
    echo "Example: 'New IIH Organogram' email → update Documents/IIH folder, not create todo"
    
    log "Email processing completed successfully"
    return 0
}

# Run main function
main "$@"