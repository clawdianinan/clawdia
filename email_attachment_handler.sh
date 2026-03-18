#!/bin/bash
# Email Attachment Handler: Download and process attachments

set -e

echo "=== EMAIL ATTACHMENT HANDLER ==="
echo ""

# Configuration
DOWNLOAD_DIR="$HOME/Downloads/email_attachments"
PROCESSED_LOG="$HOME/.email_attachments_processed.log"

# Create directories
mkdir -p "$DOWNLOAD_DIR"

# Function to log processed attachments
log_processed() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $1" >> "$PROCESSED_LOG"
}

# Function to check if attachment already processed
is_processed() {
    local filename="$1"
    grep -q "$filename" "$PROCESSED_LOG" 2>/dev/null
}

# Function to process organogram attachments
process_organogram_attachment() {
    local filepath="$1"
    local filename="$2"
    
    echo "  Processing organogram: $filename"
    
    # Check file type
    if [[ "$filename" == *.pdf ]] || [[ "$filename" == *.png ]] || [[ "$filename" == *.jpg ]]; then
        echo "  • File type: $(file "$filepath" | cut -d: -f2-)"
        
        # Copy to Documents/IIH folder
        dest_dir="$HOME/Documents/IIH/Organogram_Attachments_$(date '+%Y%m%d')"
        mkdir -p "$dest_dir"
        
        cp "$filepath" "$dest_dir/"
        echo "  • Copied to: $dest_dir/"
        
        # Check if this is an update to existing organogram
        if [[ "$filename" == *"Organogram"* ]]; then
            echo "  • Detected as organogram file"
            echo "  • ACTION: Compare with existing organogram files"
            
            # Find existing organogram files
            existing_files=$(find ~/Documents/IIH -name "*organogram*" -o -name "*Organogram*" 2>/dev/null | head -5)
            if [[ -n "$existing_files" ]]; then
                echo "  • Found existing organogram files:"
                echo "$existing_files" | while read existing; do
                    echo "    - $(basename "$existing")"
                done
            fi
        fi
        
        return 0
    else
        echo "  • Skipping non-organogram file type"
        return 1
    fi
}

# Main function to process email attachments
process_email_attachments() {
    local email_id="$1"
    local subject="$2"
    
    echo "📧 Processing attachments for email: $subject"
    
    # Download attachments
    echo "  Downloading attachments..."
    download_output=$(himalaya attachment download "$email_id" 2>&1)
    
    if echo "$download_output" | grep -q "Downloaded"; then
        echo "  ✅ Attachments downloaded"
        
        # Parse downloaded files from output
        downloaded_files=$(echo "$download_output" | grep "Downloading" | sed 's/.*Downloading "//' | sed 's/"…//')
        
        if [[ -z "$downloaded_files" ]]; then
            # Try to find recently downloaded files
            downloaded_files=$(find ~/Downloads -name "*" -mmin -2 2>/dev/null | head -5)
        fi
        
        if [[ -n "$downloaded_files" ]]; then
            echo "  Found $(echo "$downloaded_files" | wc -l) files:"
            
            # Process each downloaded file
            processed_count=0
            echo "$downloaded_files" | while read filepath; do
                if [[ -f "$filepath" ]]; then
                    filename=$(basename "$filepath")
                    
                    # Check if already processed
                    if is_processed "$filename"; then
                        echo "  • $filename (already processed)"
                    else
                        echo "  • $filename"
                        
                        # Process based on email subject
                        if [[ "$subject" == *"Organogram"* ]]; then
                            if process_organogram_attachment "$filepath" "$filename"; then
                                log_processed "$filename"
                                ((processed_count++))
                            fi
                        else
                            echo "    General attachment - logged"
                            log_processed "$filename"
                            ((processed_count++))
                        fi
                    fi
                fi
            done
            
            echo "  ✅ Processed $processed_count new attachments"
        else
            echo "  ❌ Could not identify downloaded files"
        fi
    else
        echo "  ❌ No attachments found or download failed"
        echo "  Error output: $download_output"
    fi
}

# Check for emails with attachments
check_emails_with_attachments() {
    echo "Checking for emails with attachments..."
    
    # Get recent emails
    emails=$(himalaya envelope list 2>/dev/null | tail -n +4 | head -10)
    
    if [[ -z "$emails" ]]; then
        echo "No emails found"
        return
    fi
    
    # Check each email
    echo "$emails" | while read line; do
        email_id=$(echo "$line" | awk -F'|' '{print $2}' | xargs)
        subject=$(echo "$line" | awk -F'|' '{print $4}' | xargs)
        flags=$(echo "$line" | awk -F'|' '{print $3}' | xargs)
        
        # Check if email has attachment flag (@)
        if echo "$flags" | grep -q '@'; then
            echo ""
            echo "📎 Email ID $email_id has attachments: $subject"
            process_email_attachments "$email_id" "$subject"
        fi
    done
}

# Main execution
main() {
    echo "1. Checking for emails with attachments..."
    check_emails_with_attachments
    
    echo ""
    echo "2. Processing downloaded organogram files..."
    
    # Check for organogram files in Downloads
    organogram_files=$(find ~/Downloads -name "*Organogram*" -o -name "*organogram*" 2>/dev/null | head -5)
    
    if [[ -n "$organogram_files" ]]; then
        echo "Found organogram files in Downloads:"
        echo "$organogram_files" | while read file; do
            echo "  • $(basename "$file")"
        done
        
        echo ""
        echo "3. Next steps for organogram update:"
        echo "   a) Compare new files with existing organograms"
        echo "   b) Update organogram data in Documents/IIH"
        echo "   c) Integrate new structure into existing files"
    else
        echo "No organogram files found in Downloads"
    fi
    
    echo ""
    echo "=== ATTACHMENT HANDLING SYSTEM READY ==="
    echo "• Can download email attachments"
    • Can detect organogram files
    • Can process and organize attachments
    • Logs processed files to avoid duplicates
}

# Run main
main "$@"