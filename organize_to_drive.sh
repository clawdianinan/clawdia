#!/bin/bash
# Script to organize workspace files into Google Drive mirror structure
# This prepares files for upload to Google Drive once authentication is fixed

WORKSPACE="/Users/clawdia/.openclaw/workspace"
MIRROR="$WORKSPACE/GoogleDrive_Mirror"
LOG="$WORKSPACE/drive_organization_log_$(date +%Y%m%d_%H%M%S).txt"

echo "Starting Google Drive organization at $(date)" | tee -a "$LOG"
echo "==============================================" | tee -a "$LOG"

# Function to categorize and move a file
organize_file() {
    local file="$1"
    local filename=$(basename "$file")
    
    echo "Processing: $filename" | tee -a "$LOG"
    
    # Categorization logic - ONLY WORK/TASK DOCUMENTS GO TO DRIVE MIRROR
    case "$filename" in
        # IIH Strategic Documents (WORK - GOES TO DRIVE)
        IHS_Logo_*.md|IHS_Logo_*.txt|IIH_KNOWLEDGE_SUMMARY.md|OPENCLAW_TEAM_OPERATING_PLAN*.md)
            dest="$MIRROR/IIH_Operations/Strategic_Documents/"
            echo "  Category: IIH Strategic Documents (Google Drive)" | tee -a "$LOG"
            ;;
        
        # IIH Financial Documents (WORK - GOES TO DRIVE)
        FINANCIAL_*.md|JANUARY_2026_*.md|IIH_*Report*.pdf|IIH_*Report*.md)
            dest="$MIRROR/IIH_Operations/Financial_Reports/"
            echo "  Category: IIH Financial Reports (Google Drive)" | tee -a "$LOG"
            ;;
        
        # IIH Program Documents (WORK - GOES TO DRIVE)
        Program_KPI_*.md|organogram_update_summary_*.md)
            dest="$MIRROR/IIH_Operations/Program_Documents/"
            echo "  Category: IIH Program Documents (Google Drive)" | tee -a "$LOG"
            ;;
        
        # IIH Facility Management (WORK - GOES TO DRIVE)
        Facility_*.md)
            dest="$MIRROR/IIH_Operations/Facility_Management/"
            echo "  Category: IIH Facility Management (Google Drive)" | tee -a "$LOG"
            ;;
        
        # Email and Correspondence (WORK - GOES TO DRIVE)
        EMAIL_*.md|email_*.txt|email_*.md|Zaradeen_*.md)
            dest="$MIRROR/IIH_Operations/Correspondence/"
            echo "  Category: Correspondence (Google Drive)" | tee -a "$LOG"
            ;;
        
        # Agreements and Legal (WORK - GOES TO DRIVE)
        *.pdf|agreement_*.txt|consent_agreement.txt)
            dest="$MIRROR/IIH_Operations/Strategic_Documents/Agreements/"
            echo "  Category: Agreements/Legal (Google Drive)" | tee -a "$LOG"
            ;;
        
        # OpenClaw System Files (STAY LOCAL - NOT FOR DRIVE)
        AGENTS.md|SOUL.md|USER.md|IDENTITY.md|HEARTBEAT.md|MEMORY.md|TOOLS.md|BOOTSTRAP.md|BUILD.md)
            echo "  Category: OpenClaw System (STAYS LOCAL)" | tee -a "$LOG"
            return 0  # Skip - don't copy to mirror
            ;;
        
        # OpenClaw Agent Files (STAY LOCAL - NOT FOR DRIVE)
        AGENT_*.md|AGENT_UPSKILLING_REFERENCE.md|AGENT_ROUTING_PROFILE_*.md)
            echo "  Category: Agent Skills (STAYS LOCAL)" | tee -a "$LOG"
            return 0  # Skip - don't copy to mirror
            ;;
        
        # OpenClaw System Files (STAY LOCAL - NOT FOR DRIVE)
        OPENCLAW_*.md|LOCAL_MODEL_*.md|OLLAMA_*.md|MODEL_*.md|WORKFLOW_AUTO.md)
            echo "  Category: OpenClaw System (STAYS LOCAL)" | tee -a "$LOG"
            return 0  # Skip - don't copy to mirror
            ;;
        
        # Memory and Optimization (STAY LOCAL - NOT FOR DRIVE)
        MEMORY_*.md|OPTIMIZATION_*.md|memory_*.md|qdrant-*.md)
            echo "  Category: Memory System (STAYS LOCAL)" | tee -a "$LOG"
            return 0  # Skip - don't copy to mirror
            ;;
        
        # Workflows and Automation (STAY LOCAL - NOT FOR DRIVE)
        WORKFLOW_*.md|cron-*.md|optimized-cron*.txt)
            echo "  Category: Workflows (STAYS LOCAL)" | tee -a "$LOG"
            return 0  # Skip - don't copy to mirror
            ;;
        
        # Personal Projects Documentation (WORK - GOES TO DRIVE)
        LEARNING.md|LESSONS.md|PROGRESS_SUMMARY.md|TODAY_IMPLEMENTATION_PLAN.md)
            dest="$MIRROR/Personal_Projects/Planning/"
            echo "  Category: Personal Planning (Google Drive)" | tee -a "$LOG"
            ;;
        
        # Default markdown files (CHECK IF WORK OR SYSTEM)
        *.md)
            # Check if it looks like a work document
            if [[ "$filename" =~ (IIH|Report|Analysis|Proposal|Plan|Summary|Draft|Final) ]]; then
                dest="$MIRROR/IIH_Operations/Strategic_Documents/Uncategorized/"
                echo "  Category: Work Document (Google Drive)" | tee -a "$LOG"
            else
                echo "  Category: System File (STAYS LOCAL)" | tee -a "$LOG"
                return 0  # Skip - don't copy to mirror
            fi
            ;;
        
        # Text files (CHECK IF WORK OR SYSTEM)
        *.txt)
            # Check if it looks like work correspondence
            if [[ "$filename" =~ (email|response|draft|template|agreement|consent) ]]; then
                dest="$MIRROR/IIH_Operations/Correspondence/"
                echo "  Category: Work Text (Google Drive)" | tee -a "$LOG"
            else
                echo "  Category: System Text (STAYS LOCAL)" | tee -a "$LOG"
                return 0  # Skip - don't copy to mirror
            fi
            ;;
        
        # Other files
        *)
            echo "  Category: Unknown Type (STAYS LOCAL)" | tee -a "$LOG"
            return 0  # Skip - don't copy to mirror
            ;;
    esac
    
    # Create destination directory if it doesn't exist
    mkdir -p "$dest"
    
    # Copy file (not move, to preserve original)
    cp "$file" "$dest"
    echo "  Copied to: $dest" | tee -a "$LOG"
    echo "  ---" | tee -a "$LOG"
}

# Create uncategorized folders
mkdir -p "$MIRROR/OpenClaw_Workspace/Configuration/Uncategorized"
mkdir -p "$MIRROR/OpenClaw_Workspace/Configuration/Text_Files"
mkdir -p "$MIRROR/IIH_Operations/Strategic_Documents/Agreements"
mkdir -p "$MIRROR/Archives/By_Project/Miscellaneous"

# Process all markdown, text, and PDF files
echo "Processing markdown files..." | tee -a "$LOG"
find "$WORKSPACE" -maxdepth 1 -name "*.md" -type f ! -name ".*" | while read file; do
    organize_file "$file"
done

echo "Processing text files..." | tee -a "$LOG"
find "$WORKSPACE" -maxdepth 1 -name "*.txt" -type f ! -name ".*" | while read file; do
    organize_file "$file"
done

echo "Processing PDF files..." | tee -a "$LOG"
find "$WORKSPACE" -maxdepth 1 -name "*.pdf" -type f ! -name ".*" | while read file; do
    organize_file "$file"
done

# Create summary
echo "" | tee -a "$LOG"
echo "Organization Complete!" | tee -a "$LOG"
echo "======================" | tee -a "$LOG"
echo "Files organized into: $MIRROR" | tee -a "$LOG"
echo "" | tee -a "$LOG"
echo "Folder sizes:" | tee -a "$LOG"
du -sh "$MIRROR"/* | tee -a "$LOG"
echo "" | tee -a "$LOG"
echo "File counts by category:" | tee -a "$LOG"
find "$MIRROR" -type f | sed 's|.*/||' | sort | uniq -c | sort -rn | head -20 | tee -a "$LOG"

echo "" | tee -a "$LOG"
echo "Next steps:" | tee -a "$LOG"
echo "1. Fix gog OAuth authentication" | tee -a "$LOG"
echo "2. Upload organized files to Google Drive" | tee -a "$LOG"
echo "3. Update GOOGLE_DRIVE_DEFAULT_RULE.md with actual folder IDs" | tee -a "$LOG"
echo "4. Set up automatic sync for new files" | tee -a "$LOG"

echo "Log saved to: $LOG" | tee -a "$LOG"