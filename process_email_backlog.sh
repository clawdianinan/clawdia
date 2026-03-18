#!/bin/bash
# Process email backlog - ALL emails

echo "=== PROCESSING EMAIL BACKLOG ==="
echo ""

# List of emails to process (excluding system emails)
email_ids="46 44 43 42 41 40 39 38 37"

for email_id in $email_ids; do
    echo "📧 Processing email ID $email_id"
    
    # Get email info
    email_info=$(himalaya envelope list 2>/dev/null | grep "^| $email_id " | head -1)
    
    if [[ -z "$email_info" ]]; then
        echo "  ✗ Not found"
        continue
    fi
    
    subject=$(echo "$email_info" | awk -F'|' '{print $4}' | xargs)
    from=$(echo "$email_info" | awk -F'|' '{print $5}' | xargs)
    
    echo "  Subject: $subject"
    echo "  From: $from"
    
    # Check if already has todo
    subject_clean=$(echo "$subject" | tr -d '[:punct:]' | tr '[:upper:]' '[:lower:]' | cut -c1-30 | tr -d ' ')
    existing_todo=$(bash scripts/todo.sh entry list --all 2>/dev/null | grep -i "$subject_clean" | head -1)
    
    if [[ -n "$existing_todo" ]]; then
        echo "  ✓ Already processed"
    else
        # Create todo
        if [[ "$from" == *"Temi"* ]]; then
            group="Temi"
            desc="From Temi: $subject"
        elif [[ "$from" == *"@iih.ng"* ]]; then
            group="IIH"
            desc="IIH internal: $subject"
        elif [[ "$subject" == *"Partnership"* ]] || [[ "$subject" == *"Quotation"* ]]; then
            group="External"
            desc="External inquiry: $subject"
        else
            group="Inbox"
            desc="Process: $subject"
        fi
        
        bash scripts/todo.sh entry create "$desc" --group="$group" --status=pending >/dev/null 2>&1
        echo "  ✅ Created todo in '$group' group"
    fi
    
    echo ""
done

echo "=== BACKLOG PROCESSING COMPLETE ==="
echo ""
echo "Current todos:"
bash scripts/todo.sh entry list 2>/dev/null