#!/bin/bash
# Enhanced Email Processor for IIH
# Features:
# 1. IIH email segregation (IIH matters use IIH emails only)
# 2. IIH address book integration (recognize staff by name)
# 3. Monthly report processing context
# 4. Smart email routing based on content

set -e

# Configuration
LOG_FILE="/tmp/enhanced_email_processor.log"
IIH_ADDRESS_BOOK="$HOME/.openclaw/workspace/iih_address_book.json"
MAX_EMAILS=20

# Load IIH address book
load_iih_address_book() {
    if [[ -f "$IIH_ADDRESS_BOOK" ]]; then
        IIH_STAFF=$(jq -r '.iih_staff | to_entries[] | "\(.key):\(.value.name):\(.value.emails[])"' "$IIH_ADDRESS_BOOK" 2>/dev/null)
        IIH_EMAILS=$(jq -r '.iih_staff[].emails[]' "$IIH_ADDRESS_BOOK" 2>/dev/null)
        IIH_DOMAINS=$(jq -r '.iih_email_domains[]' "$IIH_ADDRESS_BOOK" 2>/dev/null)
    else
        echo "Warning: IIH address book not found at $IIH_ADDRESS_BOOK"
        IIH_STAFF=""
        IIH_EMAILS=""
        IIH_DOMAINS="@iih.ng"
    fi
}

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Check if email is from IIH domain
is_iih_email() {
    local email="$1"
    for domain in $IIH_DOMAINS; do
        if [[ "$email" == *"$domain" ]]; then
            return 0
        fi
    done
    return 1
}

# Check if email is from Temi (USER)
is_temi_email() {
    local email="$1"
    local temi_emails=(
        "temi@iih.ng"
        "temi.kolawole@iih.ng"
        "temikolawole@icloud.com"
        "temikolawole@gmail.com"
    )
    
    for temi_email in "${temi_emails[@]}"; do
        if [[ "$email" == *"$temi_email"* ]]; then
            return 0
        fi
    done
    return 1
}

# Resolve IIH staff name to email
resolve_iih_staff() {
    local name="$1"
    
    # Convert to lowercase for matching
    local lower_name=$(echo "$name" | tr '[:upper:]' '[:lower:]')
    
    # Check for direct matches in address book
    while IFS=: read -r key staff_name email; do
        local lower_staff=$(echo "$staff_name" | tr '[:upper:]' '[:lower:]')
        if [[ "$lower_name" == *"$key"* ]] || [[ "$lower_staff" == *"$lower_name"* ]]; then
            echo "$email"
            return 0
        fi
    done <<< "$IIH_STAFF"
    
    # Common name mappings
    case "$lower_name" in
        *adebola*|*programs*)
            echo "adebola.oladipo@iih.ng"
            ;;
        *khadijat*|*finance*)
            echo "khadijat.bello@iih.ng"
            ;;
        *maureen*|*admin*)
            echo "maureen.okey@iih.ng"
            ;;
        *sinachi*|*hr*|*human*)
            echo "sinachi@iih.ng"
            ;;
        *kamil*|*facility*)
            echo "kamil.ahmed@iih.ng"
            ;;
        *nas*|*it*|*marketing*)
            echo "nas@iih.ng"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Check if email content is IIH-related
is_iih_related() {
    local subject="$1"
    local body="$2"
    
    local iih_keywords=(
        "IIH" "Ilorin Innovation Hub"
        "monthly report" "financial report"
        "program" "facility" "finance" "hr" "it" "marketing"
        "adebola" "khadijat" "maureen" "sinachi" "kamil" "nas"
        "staff" "department" "meeting" "budget" "invoice"
    )
    
    local combined="$subject $body"
    local lower_combined=$(echo "$combined" | tr '[:upper:]' '[:lower:]')
    
    for keyword in "${iih_keywords[@]}"; do
        local lower_keyword=$(echo "$keyword" | tr '[:upper:]' '[:lower:]')
        if [[ "$lower_combined" == *"$lower_keyword"* ]]; then
            return 0
        fi
    done
    
    return 1
}

# Check if email is about monthly reports
is_monthly_report_email() {
    local subject="$1"
    local body="$2"
    
    local report_keywords=(
        "monthly report" "departmental report"
        "report submission" "report deadline"
        "financial report" "program report"
        "reminder" "submission"
    )
    
    local lower_subject=$(echo "$subject" | tr '[:upper:]' '[:lower:]')
    local lower_body=$(echo "$body" | tr '[:upper:]' '[:lower:]')
    
    for keyword in "${report_keywords[@]}"; do
        local lower_keyword=$(echo "$keyword" | tr '[:upper:]' '[:lower:]')
        if [[ "$lower_subject" == *"$lower_keyword"* ]] || [[ "$lower_body" == *"$lower_keyword"* ]]; then
            return 0
        fi
    done
    
    return 1
}

# Process monthly report instructions
process_monthly_report_instruction() {
    local body="$1"
    local from="$2"
    
    log "Processing monthly report instruction from $from"
    
    # Extract action items
    local actions=()
    
    # Check for specific instructions
    if [[ "$body" == *"send reminder"* ]] || [[ "$body" == *"remind"* ]]; then
        actions+=("send_reminder")
    fi
    
    if [[ "$body" == *"check status"* ]] || [[ "$body" == *"status"* ]]; then
        actions+=("check_status")
    fi
    
    if [[ "$body" == *"compile"* ]] || [[ "$body" == *"finalize"* ]]; then
        actions+=("compile_report")
    fi
    
    if [[ "$body" == *"financial"* ]] && [[ "$body" == *"report"* ]]; then
        actions+=("process_financial")
    fi
    
    # If no specific actions detected, assume general monthly report task
    if [[ ${#actions[@]} -eq 0 ]]; then
        actions+=("monthly_report_general")
    fi
    
    echo "Monthly report actions identified: ${actions[*]}"
    
    # Here you would implement the actual monthly report processing
    # For now, just log and return
    for action in "${actions[@]}"; do
        case "$action" in
            send_reminder)
                echo "Action: Send monthly report reminders to departments"
                ;;
            check_status)
                echo "Action: Check monthly report submission status"
                ;;
            compile_report)
                echo "Action: Compile monthly report from departmental submissions"
                ;;
            process_financial)
                echo "Action: Process financial section for monthly report"
                ;;
            monthly_report_general)
                echo "Action: Handle general monthly report task"
                ;;
        esac
    done
    
    return 0
}

# Process email based on classification
process_email() {
    local email_id="$1"
    local subject="$2"
    local from="$3"
    local body="$4"
    
    log "Processing email: $subject from $from"
    
    # Classification logic
    if is_temi_email "$from"; then
        log "Email from Temi - processing instructions"
        
        # Check if it's IIH-related
        if is_iih_related "$subject" "$body"; then
            log "IIH-related email from Temi"
            
            # Check for monthly report instructions
            if is_monthly_report_email "$subject" "$body"; then
                process_monthly_report_instruction "$body" "$from"
            else
                echo "IIH instruction from Temi: $subject"
                # Process general IIH instruction
            fi
        else
            echo "Personal instruction from Temi: $subject"
            # Process personal instruction
        fi
        
    elif is_iih_email "$from"; then
        log "Email from IIH staff: $from"
        
        if is_monthly_report_email "$subject" "$body"; then
            log "Monthly report email from IIH staff"
            echo "Monthly report submission from IIH staff: $subject"
            # Handle departmental report submission
        else
            echo "IIH internal email: $subject from $from"
            # Route to appropriate person or handle
        fi
        
    elif is_iih_related "$subject" "$body"; then
        log "External email about IIH matters"
        echo "External email about IIH: $subject from $from"
        echo "This should be handled with IIH email addresses only"
        # Suggest using IIH email for response
        
    else
        log "External non-IIH email"
        echo "External email requiring review: $subject from $from"
        # Refer to Temi
    fi
}

# Get email body using himalaya
get_email_body() {
    local email_id="$1"
    
    if ! command -v himalaya >/dev/null 2>&1; then
        log "Error: himalaya not installed"
        echo ""
        return 1
    fi
    
    local email_content
    if ! email_content=$(himalaya message read "$email_id" --output json 2>/dev/null); then
        log "Error reading email $email_id"
        echo ""
        return 1
    fi
    
    # Extract body - the output is plain text, not JSON
    local body=$(echo "$email_content" | head -5000)
    echo "$body"
}

# Main function
main() {
    log "Starting enhanced email processor"
    
    # Load IIH address book
    load_iih_address_book
    
    # Get recent emails
    if ! command -v himalaya >/dev/null 2>&1; then
        log "Error: himalaya not available"
        echo "Please install himalaya: brew install himalaya"
        return 1
    fi
    
    local emails_json
    if ! emails_json=$(himalaya envelope list --page-size $MAX_EMAILS --output json 2>/dev/null); then
        log "Error fetching emails"
        return 1
    fi
    
    local email_count=$(echo "$emails_json" | jq 'length')
    log "Found $email_count emails to process"
    
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
        
        log "Processing email ID $email_id: $subject"
        
        # Get email body
        local body=$(get_email_body "$email_id")
        if [[ -z "$body" ]]; then
            log "Skipping email $email_id - could not read body"
            continue
        fi
        
        # Process the email
        process_email "$email_id" "$subject" "$from" "$body"
        
        echo "" # Separator
    done
    
    log "Enhanced email processing completed"
    return 0
}

# Run main function
main "$@"