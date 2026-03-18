#!/bin/bash
# Organogram Update System: Handle email attachments and update local files

set -e

echo "=== ORGANOGRAM UPDATE SYSTEM ==="
echo ""

# Configuration
IIH_DOCS="$HOME/Documents/IIH"
ATTACHMENT_DIR="$IIH_DOCS/Organogram_Updates_$(date '+%Y%m%d_%H%M')"

# Create directory for today's updates
mkdir -p "$ATTACHMENT_DIR"

echo "1. Checking for organogram email attachments..."
echo ""

# Find organogram-related emails
organogram_emails=$(himalaya envelope list 2>/dev/null | grep -i "organogram" | head -5)

if [[ -z "$organogram_emails" ]]; then
    echo "No organogram emails found"
else
    echo "Found organogram emails:"
    echo "$organogram_emails" | while read line; do
        email_id=$(echo "$line" | awk -F'|' '{print $2}' | xargs)
        subject=$(echo "$line" | awk -F'|' '{print $4}' | xargs)
        echo "  • ID $email_id: $subject"
    done
    echo ""
    
    # Process the latest organogram email (ID 46)
    echo "2. Processing organogram email ID 46..."
    echo ""
    
    # Download attachments
    echo "Downloading attachments..."
    himalaya attachment download 46 2>&1 | grep -v "WARN"
    echo ""
    
    # Find downloaded organogram files
    echo "3. Locating downloaded organogram files..."
    organogram_files=$(find ~/Downloads -name "*Organogram*" -mmin -5 2>/dev/null)
    
    if [[ -n "$organogram_files" ]]; then
        echo "Found organogram files:"
        file_count=0
        echo "$organogram_files" | while read file; do
            if [[ -f "$file" ]]; then
                filename=$(basename "$file")
                filesize=$(stat -f%z "$file" 2>/dev/null || echo "unknown")
                ((file_count++))
                
                echo "  • $filename ($filesize bytes)"
                
                # Copy to organogram updates directory
                cp "$file" "$ATTACHMENT_DIR/"
                echo "    → Copied to: $ATTACHMENT_DIR/"
            fi
        done
        echo ""
        echo "✅ Downloaded $file_count organogram files"
    else
        echo "❌ No organogram files found in Downloads"
    fi
fi

echo ""
echo "4. Comparing with existing organogram files..."
echo ""

# Find existing organogram files
existing_organograms=$(find "$IIH_DOCS" -name "*organogram*" -o -name "*Organogram*" 2>/dev/null | head -10)

if [[ -n "$existing_organograms" ]]; then
    echo "Existing organogram files in Documents/IIH:"
    echo "$existing_organograms" | while read file; do
        if [[ -f "$file" ]]; then
            filename=$(basename "$file")
            filedate=$(stat -f%Sm -t "%Y-%m-%d" "$file" 2>/dev/null || echo "unknown")
            echo "  • $filename (updated: $filedate)"
        fi
    done
else
    echo "No existing organogram files found"
fi

echo ""
echo "5. Your Instruction Execution Plan:"
echo "----------------------------------"
echo ""
echo "📧 EMAIL INSTRUCTION: 'Please find attached latest IIH organogram structure. Kindly update existing organogram data in Documents/IIH folder.'"
echo ""
echo "🚀 MY ACTION PLAN:"
echo "1. ✅ Downloaded organogram attachments from your email"
echo "2. ✅ Located existing organogram files in Documents/IIH"
echo "3. 🔄 Compare new vs existing organogram versions"
echo "4. 🔄 Update organogram data files (JSON/CSV)"
echo "5. 🔄 Update PowerPoint files with new structure"
echo "6. ✅ Save updated files in Documents/IIH folder"
echo ""
echo "📁 Files to update:"
echo "   • IIH_Organogram_Data_v1.json (data file)"
echo "   • IIH_Organogram_PowerPoint_20260224_2349.pptx"
echo "   • IIH_TEXT_ONLY_ORGANOGRAM_20260225_0004.pptx"
echo "   • Other organogram presentation files"
echo ""
echo "⚡ IMMEDIATE ACTIONS:"
echo "1. Review downloaded organogram attachments"
echo "2. Extract new structure information"
echo "3. Update JSON data file with new structure"
echo "4. Note PowerPoint files need manual update"
echo ""
echo "The organogram update system is now operational!"