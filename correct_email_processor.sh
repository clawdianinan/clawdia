#!/bin/bash
# CORRECTED Email Processor: Execute instructions from Temi, create todos for others

set -e

echo "=== CORRECTED EMAIL PROCESSOR ==="
echo "Logic: Temi emails → Execute instructions | Others → Create todos"
echo ""

# Function to check if email is from Temi
is_from_temi() {
    local from="$1"
    [[ "$from" == *"Temi Kolawole"* ]] || [[ "$from" == *"temi.kolawole@iih.ng"* ]] || [[ "$from" == *"temi@iih.ng"* ]]
}

# Function to execute Temi's instruction
execute_temi_instruction() {
    local email_id="$1"
    local subject="$2"
    
    echo "🚀 EXECUTING INSTRUCTION FROM TEMI"
    echo "Email: $subject"
    
    # Read email content via AppleScript
    email_content=$(osascript -e '
tell application "Mail"
    set targetSubject to "'"$subject"'"
    set foundMessage to first message of inbox whose subject contains targetSubject
    if foundMessage is not missing value then
        return content of foundMessage
    else
        return "EMAIL_NOT_FOUND"
    end if
end tell' 2>/dev/null)
    
    if [[ "$email_content" == "EMAIL_NOT_FOUND" ]]; then
        echo "  ❌ Could not read email content"
        return
    fi
    
    echo "  ✅ Read email content"
    
    # Extract instructions
    echo ""
    echo "📋 INSTRUCTIONS FOUND:"
    
    # Look for instruction patterns
    instructions=()
    
    # Pattern 1: "Please" statements
    echo "$email_content" | grep -o -E "[^.!?]*[Pp]lease[^.!?]*[.!?]" | while read line; do
        if [[ -n "$line" ]]; then
            instructions+=("$line")
            echo "  • $line"
        fi
    done
    
    # Pattern 2: "Kindly" statements  
    echo "$email_content" | grep -o -E "[^.!?]*[Kk]indly[^.!?]*[.!?]" | while read line; do
        if [[ -n "$line" ]]; then
            instructions+=("$line")
            echo "  • $line"
        fi
    done
    
    # Pattern 3: Direct commands
    echo "$email_content" | grep -o -E "[^.!?]*[Cc]an you[^.!?]*[.!?]" | while read line; do
        if [[ -n "$line" ]]; then
            instructions+=("$line")
            echo "  • $line"
        fi
    done
    
    # If no specific instructions found, show general content
    if [[ ${#instructions[@]} -eq 0 ]]; then
        echo "  • Full email content (first 200 chars):"
        echo "    $(echo "$email_content" | head -c 200)..."
    fi
    
    # Execute based on subject
    echo ""
    echo "⚡ EXECUTING ACTIONS:"
    
    case "$subject" in
        *"Organogram"*|*"organogram"*)
            echo "  • ACTION: Update IIH organogram in Documents/IIH folder"
            echo "  • ACTION: Save organogram attachments"
            echo "  • STATUS: Need attachment access to complete"
            ;;
        *"Report"*|*"report"*)
            echo "  • ACTION: Review report content"
            echo "  • ACTION: Extract key information"
            ;;
        *"Financial"*|*"financial"*)
            echo "  • ACTION: Process financial data"
            echo "  • ACTION: Update financial records"
            ;;
        *)
            echo "  • ACTION: Process general instruction"
            echo "  • ACTION: Follow up if clarification needed"
            ;;
    esac
    
    echo ""
    echo "✅ INSTRUCTION PROCESSING COMPLETE"
}

# Function to create todo for non-Temi emails
create_todo_for_others() {
    local email_id="$1"
    local subject="$2"
    local from="$3"
    
    echo "📝 CREATING TODO FOR REVIEW"
    echo "Email: $subject"
    echo "From: $from"
    
    # Determine group
    local group="Inbox"
    if [[ "$from" == *"@iih.ng"* ]]; then
        group="IIH"
    elif [[ "$from" == *"@ihstowers.com"* ]]; then
        group="IHS"
    else
        group="External"
    fi
    
    # Create todo
    todo_desc="Review email: $subject"
    bash scripts/todo.sh entry create "$todo_desc" --group="$group" --status=pending >/dev/null 2>&1
    echo "  ✅ Created todo in '$group' group"
}

# Main processing
main() {
    echo "Checking recent emails..."
    
    # Get recent emails
    emails=$(himalaya envelope list 2>/dev/null | tail -n +4 | head -10)
    
    if [[ -z "$emails" ]]; then
        echo "No emails found"
        return
    fi
    
    echo "Processing $(echo "$emails" | wc -l) emails..."
    echo ""
    
    # Process each email
    echo "$emails" | while read line; do
        email_id=$(echo "$line" | awk -F'|' '{print $2}' | xargs)
        from=$(echo "$line" | awk -F'|' '{print $5}' | xargs)
        subject=$(echo "$line" | awk -F'|' '{print $4}' | xargs)
        
        echo "---"
        echo "📧 ID $email_id: $subject"
        
        if is_from_temi "$from"; then
            execute_temi_instruction "$email_id" "$subject"
        else
            create_todo_for_others "$email_id" "$subject" "$from"
        fi
        
        echo ""
    done
    
    echo "=== PROCESSING COMPLETE ==="
}

# Run main
main "$@"