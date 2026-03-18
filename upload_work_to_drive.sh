#!/bin/bash
# Upload work/task documents to Google Drive
# ONLY for work documents - NOT for OpenClaw system files

WORKSPACE="/Users/clawdia/.openclaw/workspace"
LOG="$WORKSPACE/drive_upload_log_$(date +%Y%m%d_%H%M%S).txt"

echo "Google Drive Work Document Upload" | tee -a "$LOG"
echo "=================================" | tee -a "$LOG"
echo "Date: $(date)" | tee -a "$LOG"
echo "" | tee -a "$LOG"

# Function to check if file is work document (not system file)
is_work_document() {
    local file="$1"
    local filename=$(basename "$file")
    
    # System files that should NOT be uploaded
    local system_files=(
        "AGENTS.md" "SOUL.md" "USER.md" "IDENTITY.md"
        "HEARTBEAT.md" "MEMORY.md" "TOOLS.md" "BOOTSTRAP.md"
        "BUILD.md" "WORKFLOW_AUTO.md"
    )
    
    # Check if it's a known system file
    for sysfile in "${system_files[@]}"; do
        if [[ "$filename" == "$sysfile" ]]; then
            return 1  # Not a work document
        fi
    done
    
    # Check filename patterns
    if [[ "$filename" =~ ^AGENT_ ]] || \
       [[ "$filename" =~ ^OPENCLAW_ ]] || \
       [[ "$filename" =~ ^LOCAL_MODEL_ ]] || \
       [[ "$filename" =~ ^OLLAMA_ ]] || \
       [[ "$filename" =~ ^MODEL_ ]] || \
       [[ "$filename" =~ ^MEMORY_ ]] || \
       [[ "$filename" =~ ^OPTIMIZATION_ ]] || \
       [[ "$filename" =~ ^WORKFLOW_ ]] || \
       [[ "$filename" =~ ^cron- ]] || \
       [[ "$filename" =~ memory_ ]] || \
       [[ "$filename" =~ qdrant- ]]; then
        return 1  # Not a work document
    fi
    
    # Work document patterns
    if [[ "$filename" =~ (IIH|IHS|Report|Analysis|Proposal|Plan|Summary|Draft|Final|Financial|Program|Facility|EMAIL|email|agreement|consent|Zaradeen) ]] || \
       [[ "$filename" =~ \.pdf$ ]] || \
       [[ "$filename" =~ organogram_update_summary_ ]]; then
        return 0  # Is a work document
    fi
    
    # Default: assume it's a work document if we're not sure
    # But log it for review
    echo "  WARNING: Uncertain classification for: $filename" | tee -a "$LOG"
    return 0
}

# Function to determine Google Drive folder
get_drive_folder() {
    local filename="$1"
    
    case "$filename" in
        # IIH Strategic Documents
        IHS_Logo_*|IIH_KNOWLEDGE_SUMMARY.md|OPENCLAW_TEAM_OPERATING_PLAN*.md)
            echo "1PnjclSsciOzQZ-H-XsUNUkD_BZ8KeAQN"  # IIH folder
            ;;
        
        # IIH Financial Documents
        FINANCIAL_*|JANUARY_2026_*|IIH_*Report*)
            echo "166Pq6eSKzb7Ig7fBTgir1aUZE5F_fEs_"  # Finance folder
            ;;
        
        # IIH Program Documents
        Program_KPI_*|organogram_update_summary_*)
            echo "1PnjclSsciOzQZ-H-XsUNUkD_BZ8KeAQN"  # IIH folder
            ;;
        
        # Agreements and Legal
        *.pdf|agreement_*|consent_agreement*)
            echo "1PnjclSsciOzQZ-H-XsUNUkD_BZ8KeAQN"  # IIH folder
            ;;
        
        # Default: IIH folder
        *)
            echo "1PnjclSsciOzQZ-H-XsUNUkD_BZ8KeAQN"  # IIH folder
            ;;
    esac
}

# Main upload function
upload_work_document() {
    local file="$1"
    local filename=$(basename "$file")
    
    echo "Processing: $filename" | tee -a "$LOG"
    
    # Check if it's a work document
    if ! is_work_document "$file"; then
        echo "  SKIPPED: OpenClaw system file (stays local)" | tee -a "$LOG"
        echo "  ---" | tee -a "$LOG"
        return 0
    fi
    
    # Get destination folder
    local folder_id=$(get_drive_folder "$filename")
    
    # Upload to Google Drive
    echo "  Uploading to Google Drive..." | tee -a "$LOG"
    
    if GOG_ACCOUNT=clawdianinan@gmail.com gog drive upload "$file" --name "$filename" --parent "$folder_id" --json 2>/dev/null; then
        echo "  ✅ SUCCESS: Uploaded to Google Drive" | tee -a "$LOG"
    else
        echo "  ❌ FAILED: Upload failed" | tee -a "$LOG"
    fi
    
    echo "  ---" | tee -a "$LOG"
}

# Process files
echo "Starting upload process..." | tee -a "$LOG"
echo "" | tee -a "$LOG"

# Process markdown files
echo "Processing markdown files..." | tee -a "$LOG"
find "$WORKSPACE" -maxdepth 1 -name "*.md" -type f ! -name ".*" | while read file; do
    upload_work_document "$file"
done

# Process text files
echo "" | tee -a "$LOG"
echo "Processing text files..." | tee -a "$LOG"
find "$WORKSPACE" -maxdepth 1 -name "*.txt" -type f ! -name ".*" | while read file; do
    upload_work_document "$file"
done

# Process PDF files
echo "" | tee -a "$LOG"
echo "Processing PDF files..." | tee -a "$LOG"
find "$WORKSPACE" -maxdepth 1 -name "*.pdf" -type f ! -name ".*" | while read file; do
    upload_work_document "$file"
done

echo "" | tee -a "$LOG"
echo "Upload process complete!" | tee -a "$LOG"
echo "Log saved to: $LOG" | tee -a "$LOG"
echo "" | tee -a "$LOG"
echo "Remember:" | tee -a "$LOG"
echo "- Work/task documents → Google Drive" | tee -a "$LOG"
echo "- OpenClaw system files → Local workspace" | tee -a "$LOG"
echo "- Check GOOGLE_DRIVE_DEFAULT_RULE.md for details" | tee -a "$LOG"