#!/bin/bash
# Emergency Archive Fix - Force sync or manual copy

echo "🚨 EMERGENCY Archive Folder Fix"
echo "==============================="

CLOUD_ARCHIVE="/Users/clawdia/Google Drive/My Drive/Clawdia Documents/IIH/Archive"
LOCAL_ARCHIVE="/Users/clawdia/Documents/IIH/Archive"

echo "Cloud: $CLOUD_ARCHIVE"
echo "Local: $LOCAL_ARCHIVE"

echo ""
echo "1. Checking current status..."
if [ -d "$CLOUD_ARCHIVE" ]; then
    CLOUD_FILES=$(find "$CLOUD_ARCHIVE" -type f 2>/dev/null | wc -l)
    echo "✅ Cloud Archive exists: $CLOUD_FILES files"
else
    echo "❌ Cloud Archive not found"
    exit 1
fi

if [ -d "$LOCAL_ARCHIVE" ]; then
    LOCAL_FILES=$(find "$LOCAL_ARCHIVE" -type f 2>/dev/null | wc -l)
    echo "✅ Local Archive exists: $LOCAL_FILES files"
else
    echo "❌ Local Archive not found"
    mkdir -p "$LOCAL_ARCHIVE"
    echo "   Created local Archive folder"
fi

echo ""
echo "2. OPTION A: Force Google Drive Mirror Mode"
echo "=========================================="
echo ""
echo "You MUST manually change Google Drive to Mirror mode:"
echo ""
echo "1. Click Google Drive icon in menu bar (top right)"
echo "2. Click Settings (gear icon) → Preferences"
echo "3. Go to 'Google Drive' tab"
echo "4. Find 'Clawdia Documents' folder"
echo "5. Click the three dots (⋯) next to it"
echo "6. Select 'Mirror files' (NOT 'Stream files')"
echo "7. Click 'Apply'"
echo "8. Wait for sync (check menu bar icon for progress)"
echo ""
read -p "Have you done this? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "✅ Good! Wait 5-10 minutes for sync to start"
    echo "   Then check: ls -la $LOCAL_ARCHIVE/"
else
    echo "⚠️  You MUST do this for proper sync"
fi

echo ""
echo "3. OPTION B: Immediate Manual Copy (Workaround)"
echo "=============================================="
echo ""
echo "While waiting for Mirror mode, copy files manually:"
echo ""
read -p "Copy Archive files now? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Copying files from cloud to local..."
    
    # Check if files are accessible (not streamed)
    if [ -f "$CLOUD_ARCHIVE/00-CONTEXT.md" ]; then
        echo "✅ Files are accessible, copying..."
        rsync -av --progress "$CLOUD_ARCHIVE/" "$LOCAL_ARCHIVE/" 2>/dev/null
        
        NEW_COUNT=$(find "$LOCAL_ARCHIVE" -type f 2>/dev/null | wc -l)
        echo ""
        echo "✅ Copied $NEW_COUNT files"
        echo "   Files in Archive now:"
        find "$LOCAL_ARCHIVE" -type f 2>/dev/null | head -10
    else
        echo "❌ Files are streamed (not accessible)"
        echo "   You must enable Mirror mode first (Option A)"
    fi
fi

echo ""
echo "4. OPTION C: Direct Database Hack"
echo "================================="
echo ""
echo "Advanced: Force Mirror mode via database edit"
read -p "Try database hack? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Attempting database modification..."
    
    DB_PATH="$HOME/Library/Application Support/Google/DriveFS/116832538812718317023/mirror_sqlite.db"
    if [ -f "$DB_PATH" ]; then
        # Backup
        cp "$DB_PATH" "$DB_PATH.backup.$(date +%s)"
        
        # Try to update
        sqlite3 "$DB_PATH" <<EOF
UPDATE mirror_item 
SET storage_policy = 0 
WHERE local_filename = 'Archive';
EOF
        
        echo "✅ Database updated"
        echo "   Restarting Google Drive..."
        killall "Google Drive" 2>/dev/null
        sleep 2
        open -a "Google Drive" &
        echo "   Google Drive restarted"
    else
        echo "❌ Database not found"
    fi
fi

echo ""
echo "5. Final Check"
echo "=============="
echo "Current Archive status:"
ls -la "$LOCAL_ARCHIVE/" 2>/dev/null | head -10

echo ""
echo "📋 Summary:"
echo "1. MUST enable Mirror mode in Google Drive settings"
echo "2. Manual copy available as temporary fix"
echo "3. Check again in 10 minutes after enabling Mirror mode"
echo ""
echo "Run check again: ./scripts/check-google-drive-progress.sh"