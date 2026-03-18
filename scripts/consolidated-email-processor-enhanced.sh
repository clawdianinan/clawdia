# Check for IHS Towers emails (highest priority)
check_ihs_towers_emails() {
    log "INFO" "Checking for IHS Towers emails..."

    local ihs_unread=0
    ihs_unread=$(himalaya envelope list --account iih_temi --page-size 200 --output json 2>/dev/null | jq '[.[] | select((.from.addr // "") | test("ihstowers.com";"i")) | select((.flags|join(",")) | contains("Seen") | not)] | length' 2>/dev/null || echo 0)

    if [[ "$ihs_unread" -gt 0 ]]; then
        log "WARN" "Found $ihs_unread unread IHS Towers email(s) - immediate escalation required"
        send_imessage_alert "$ihs_unread unread email(s) from @ihstowers.com require immediate triage."
        return 1
    else
        log "SUCCESS" "No unread IHS Towers emails found"
        return 0
    fi
}

# Select best available account by priority
select_active_email_account() {
    local accounts=(iih_clawdia iih_temi gmail icloud)
    for acc in "${accounts[@]}"; do
        if himalaya envelope list --account "$acc" --page-size 1 --output json >/dev/null 2>&1; then
            echo "$acc"
            return 0
        fi
    done
    return 1
}

# Get unread emails in batch
get_unread_emails_batch() {
    local limit="$1"

    log "INFO" "Fetching up to $limit unread emails..."

    local acc
    acc=$(select_active_email_account || true)
    if [[ -z "$acc" ]]; then
        log "ERROR" "No accessible email account (Himalaya)."
        echo "[]"
        return 0
    fi

    log "INFO" "Using email account: $acc"
    himalaya envelope list --account "$acc" --page-size "$limit" --output json 2>/dev/null || echo "[]"
}

# Classify email type
classify_email() {
    local email_json="$1"
    
    # Simple classification logic
    # In production: Use model call for complex classification
    
    # Check if from Temi
    if echo "$email_json" | grep -q "temi.kolawole@iih.ng\|temi@iih.ng"; then
        echo "temi_instruction"
    elif echo "$email_json" | grep -q "@iih.ng"; then
        echo "iih_internal"
    else
        echo "external"
    fi
}

# Process Temi's instructions
process_temi_instruction() {
    local email_id="$1"
    local email_content="$2"
    
    log "INFO" "Processing Temi's instruction (Email ID: $email_id)"
    
    # Extract instruction keywords
    local instruction_keywords=("please" "kindly" "can you" "check" "review" "update")
    
    for keyword in "${instruction_keywords[@]}"; do
        if echo "$email_content" | grep -qi "$keyword"; then
            log "INFO" "Found instruction keyword: $keyword"
            # Execute instruction
            execute_temi_instruction "$email_id" "$email_content"
            return 0
        fi
    done
    
    log "WARN" "No clear instruction found in Temi's email"
    return 1
}

# Execute Temi's instruction
execute_temi_instruction() {
    local email_id="$1"
    local email_content="$2"
    
    log "INFO" "Executing instruction from Temi"
    
    # This would trigger appropriate action based on content
    # For now, log the action
    
    # Check for common instruction patterns
    if echo "$email_content" | grep -qi "organogram"; then
        log "INFO" "Action: Update organogram files"
    elif echo "$email_content" | grep -qi "role.*hiring\|hiring.*role"; then
        log "INFO" "Action: Update hiring roles document"
    elif echo "$email_content" | grep -qi "logo\|consent\|IHS"; then
        log "INFO" "Action: Review consent agreement"
    elif echo "$email_content" | grep -qi "budget"; then
        log "INFO" "Action: Process budget file"
    else
        log "INFO" "Action: General instruction execution"
    fi
    
    mark_processed "$email_id"
}

# Evaluate email confidence/risk gate
email_gate() {
    local subject="$1"
    local body="$2"
    local external_flag="$3" # true/false

    if [[ -x "/Users/clawdia/.openclaw/workspace/scripts/email_confidence_gate.py" ]]; then
        if [[ "$external_flag" == "true" ]]; then
            python3 /Users/clawdia/.openclaw/workspace/scripts/email_confidence_gate.py --subject "$subject" --body "$body" --external 2>/dev/null
        else
            python3 /Users/clawdia/.openclaw/workspace/scripts/email_confidence_gate.py --subject "$subject" --body "$body" 2>/dev/null
        fi
    else
        echo '{"recommended_action":"draft_only","confidence":0.0}'
    fi
}

# Process emails in batch with intelligent filtering
process_emails_batch() {
    log "INFO" "Starting batch email processing with intelligent filtering"
    
    # Get unread emails
    local emails_json=$(get_unread_emails_batch $BATCH_SIZE)
    
    # Parse and process each email
    local email_count=$(echo "$emails_json" | jq 'length' 2>/dev/null || echo 0)
    local processed_count=0
    local todos_created=0
    local emails_filtered=0
    
    log "INFO" "Found $email_count unread emails to process"
    
    if [[ "$email_count" -eq 0 ]]; then
        log "INFO" "No unread emails to process"
        return 0
    fi
    
    for i in $(seq 0 $((email_count - 1))); do
        local email=$(echo "$emails_json" | jq -r ".[$i]" 2>/dev/null)
        if [[ -z "$email" ]]; then
            continue
        fi
        
        local email_id=$(echo "$email" | jq -r '.id' 2>/dev/null)
        local subject=$(echo "$email" | jq -r '.subject' 2>/dev/null)
        local from=$(echo "$email" | jq -r '.from' 2>/dev/null)
        
        if [[ -z "$email_id" ]] || [[ "$email_id" == "null" ]]; then
            continue
        fi
        
        # Skip if already processed
        if is_processed "$email_id"; then
            log "INFO" "Email $email_id already processed, skipping"
            continue
        fi
        
        log "INFO" "Processing email $email_id: $subject"
        
        # Get email content
        local email_content=""
        if command -v himalaya >/dev/null 2>&1; then
            email_content=$(himalaya read "$email_id" --output text 2>/dev/null || echo "")
        fi
        
        if [[ -z "$email_content" ]]; then
            log "WARN" "Could not read email $email_id content"
            mark_processed "$email_id"
            continue
        fi
        
        # Classify and process
        local email_type=$(classify_email "$email")
        
        case "$email_type" in
            temi_instruction)
                process_temi_instruction "$email_id" "$email_content"
                processed_count=$((processed_count + 1))
                ;;
            iih_internal)
                # For IIH internal emails, apply filtering
                if should_create_todo "$subject" "$from" "$email_content"; then
                    log "INFO" "Creating todo for IIH internal email: $subject"
                    # Similar to external but with different group
                    local todo_text="IIH Internal: $subject (from $from)"
                    if [[ -x "$OPENCLAW_WORKSPACE/scripts/todo.sh" ]]; then
                        bash "$OPENCLAW_WORKSPACE/scripts/todo.sh" entry add --group "IIH" --text "$todo_text" >/dev/null 2>&1
                        todos_created=$((todos_created + 1))
                    fi
                else
                    log "INFO" "Filtered out IIH internal email: $subject"
                    emails_filtered=$((emails_filtered + 1))
                fi
                mark_processed "$email_id"
                processed_count=$((processed_count + 1))
                ;;
            external)
                process_external_email "$email_id" "$email_content"
                processed_count=$((processed_count + 1))
                todos_created=$((todos_created + 1))
                ;;
            *)
                log "WARN" "Unknown email type: $email_type"
                mark_processed "$email_id"
                processed_count=$((processed_count + 1))
                ;;
        esac
    done
    
    log "INFO" "Batch processing complete: $processed_count emails processed, $todos_created todos created, $emails_filtered emails filtered out"
}

# Generate summary report
generate_summary_report() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local processed_count=$(wc -l < "$PROCESSED_IDS_FILE" 2>/dev/null | tr -d ' ' || echo 0)
    local thread_count=$(wc -l < "$EMAIL_THREAD_TRACKER" 2>/dev/null | tr -d ' ' || echo 0)
    
    cat > "$CACHE_DIR/summary-$(date +%Y%m%d-%H%M).txt" << EOF
Email Processing Summary (Enhanced)
==================================
Timestamp: $timestamp
Total Emails Processed: $processed_count
Active Threads Tracked: $thread_count
IHS Towers Check: $(check_ihs_towers_emails >/dev/null 2>&1 && echo "Clear" || echo "ALERT")
Batch Size: $BATCH_SIZE
Model Used: $MODEL
Filtering: ACTIVE (intelligent pre-filtering)
EOF
    
    log "INFO" "Summary report generated"
}

# Clean up old cache files
cleanup_cache() {
    find "$CACHE_DIR" -name "*.txt" -mtime +7 -delete
    log "INFO" "Cleaned up old cache files"
}

# Test the filtering logic
test_filtering_logic() {
    log "INFO" "Testing filtering logic with sample emails..."
    
    # Test cases that should NOT create todos
    local test_cases_no_todo=(
        "Subject: Undelivered Mail Returned to Sender|From: mailer-daemon@mail.zoho.com|Body: Your message was not delivered"
        "Subject: Delivery Status Notification (Failure)|From: postmaster@example.com|Body: Delivery failed"
        "Subject: Weekly Newsletter|From: newsletter@company.com|Body: Check out our latest updates"
        "Subject: Security Alert|From: security@google.com|Body: New sign-in detected"
        "Subject: Invoice #12345|From: invoices@service.com|Body: Your invoice is attached"
        "Subject: Meeting Invitation|From: calendar@outlook.com|Body: You're invited to a meeting"
    )
    
    # Test cases that SHOULD create todos
    local test_cases_todo=(
        "Subject: Action Required: Project Review|From: client@company.com|Body: Please review the attached proposal"
        "Subject: Urgent: Budget Approval Needed|From: finance@iih.ng|Body: Kindly approve the budget by EOD"
        "Subject: Follow up on our discussion|From: partner@org.com|Body: Can you please send the documents we discussed?"
        "Subject: Issue with the system|From: user@domain.com|Body: I'm having a problem with the login"
        "Subject: Proposal for collaboration|From: potential@partner.com|Body: I'd like to discuss a partnership opportunity"
    )
    
    local passed_tests=0
    local total_tests=0
    
    # Test NO_TODO cases
    for test_case in "${test_cases_no_todo[@]}"; do
        IFS='|' read -r subject from body <<< "$test_case"
        total_tests=$((total_tests + 1))
        
        if ! should_create_todo "$subject" "$from" "$body"; then
            log "SUCCESS" "Test PASSED: Correctly filtered out: $subject"
            passed_tests=$((passed_tests + 1))
        else
            log "ERROR" "Test FAILED: Should have filtered out: $subject"
        fi
    done
    
    # Test TODO cases
    for test_case in "${test_cases_todo[@]}"; do
        IFS='|' read -r subject from body <<< "$test_case"
        total_tests=$((total_tests + 1))
        
        if should_create_todo "$subject" "$from" "$body"; then
            log "SUCCESS" "Test PASSED: Correctly allowed: $subject"
            passed_tests=$((passed_tests + 1))
        else
            log "ERROR" "Test FAILED: Should have allowed: $subject"
        fi
    done
    
    log "INFO" "Filtering test complete: $passed_tests/$total_tests tests passed"
    
    if [[ "$passed_tests" -eq "$total_tests" ]]; then
        log "SUCCESS" "All filtering tests passed!"
        return 0
    else
        log "ERROR" "Some filtering tests failed"
        return 1
    fi
}

# Main execution
main() {
    log "INFO" "Starting enhanced email processor with intelligent filtering at $(date)"
    policy_guard_check
    log "INFO" "Policy source: $MASTER_EMAIL_DOC"
    log "INFO" "Skill source: $EMAIL_SKILL_DOC"
    
    # Run filtering logic test
    if ! test_filtering_logic; then
        log "ERROR" "Filtering logic test failed - proceeding with caution"
    fi

    # Check quiet hours
    if check_quiet_hours; then
        # Only check IHS Towers during quiet hours
        check_ihs_towers_emails
        log "INFO" "Quiet hours - skipping regular processing"
        exit 0
    fi
    
    # Always check IHS Towers first (highest priority)
    if ! check_ihs_towers_emails; then
        log "ERROR" "IHS Towers alert - stopping further processing"
        exit 1
    fi
    
    # Clean up old thread tracking
    cleanup_thread_tracking
    
    # Process emails in batch with intelligent filtering
    process_emails_batch
    
    # Generate summary
    generate_summary_report
    
    # Cleanup
    cleanup_cache
    
    log "SUCCESS" "Enhanced email processing completed successfully"
}

# Run main function
main "$@"