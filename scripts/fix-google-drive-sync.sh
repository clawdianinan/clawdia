#!/bin/bash
# Fix Google Drive Sync - Ensure Mirroring not Streaming

echo "🔧 Google Drive Sync Fix Script"
echo "================================"

# Check Google Drive status
echo "1. Checking Google Drive status..."
if ps aux | grep -q "[G]oogle Drive"; then
    echo "✅ Google Drive is running"
else
    echo "❌ Google Drive is not running"
    echo "   Starting Google Drive..."
    open -a "Google Drive"
    sleep 5
fi

# Check the problematic folder
echo ""
echo "2. Checking IIH Archive folder..."
LOCAL_ARCHIVE="/Users/clawdia/Documents/IIH/Archive"
CLOUD_ARCHIVE="/Users/clawdia/Google Drive/My Drive/Clawdia Documents/IIH/Archive"

if [ -d "$LOCAL_ARCHIVE" ]; then
    echo "✅ Local Archive folder exists: $LOCAL_ARCHIVE"
    LOCAL_COUNT=$(find "$LOCAL_ARCHIVE" -type f 2>/dev/null | wc -l)
    echo "   Files in local Archive: $LOCAL_COUNT"
else
    echo "❌ Local Archive folder not found: $LOCAL_ARCHIVE"
fi

if [ -d "$CLOUD_ARCHIVE" ]; then
    echo "✅ Cloud Archive folder exists: $CLOUD_ARCHIVE"
    CLOUD_COUNT=$(find "$CLOUD_ARCHIVE" -type f 2>/dev/null | wc -l)
    echo "   Files in cloud Archive: $CLOUD_COUNT"
    
    # List cloud files
    echo ""
    echo "   Cloud Archive contents:"
    ls -la "$CLOUD_ARCHIVE/" 2>/dev/null | head -20
else
    echo "❌ Cloud Archive folder not found: $CLOUD_ARCHIVE"
fi

echo ""
echo "3. Checking Google Drive sync mode..."
echo ""
echo "⚠️  MANUAL ACTION REQUIRED:"
echo "=========================="
echo "The Archive folder appears to be in 'Stream' mode (files show as placeholders)."
echo ""
echo "To fix this, you need to:"
echo ""
echo "1. Open Google Drive app (click the Google Drive icon in menu bar)"
echo "2. Click Settings (gear icon) → Preferences"
echo "3. Go to 'Google Drive' tab"
echo "4. Find 'Clawdia Documents' folder"
echo "5. Click the three dots (⋯) next to it"
echo "6. Select 'Mirror files' instead of 'Stream files'"
echo "7. Click 'Apply' and wait for sync to complete"
echo ""
echo "Alternatively, you can:"
echo "1. Right-click the 'Clawdia Documents' folder in Finder"
echo "2. Select 'Google Drive' → 'Available offline'"
echo ""
echo "After changing to Mirror mode:"
echo "1. Files will download locally"
echo "2. The Archive folder will show actual files, not placeholders"
echo "3. All changes will sync both ways"

echo ""
echo "4. Quick fix attempt (forcing download)..."
echo ""
echo "Trying to force download of Archive contents..."
# Try to access files to trigger download
for file in "$CLOUD_ARCHIVE"/*; do
    if [ -f "$file" ]; then
        echo "   Accessing: $(basename "$file")"
        cat "$file" > /dev/null 2>&1
    fi
done

echo ""
echo "5. Checking sync status after fix attempt..."
if [ -d "$LOCAL_ARCHIVE" ]; then
    NEW_LOCAL_COUNT=$(find "$LOCAL_ARCHIVE" -type f 2>/dev/null | wc -l)
    echo "   Files in local Archive now: $NEW_LOCAL_COUNT"
    if [ $NEW_LOCAL_COUNT -gt $LOCAL_COUNT ]; then
        echo "   ✅ Some files downloaded"
    else
        echo "   ⚠️  No new files downloaded (still in Stream mode)"
    fi
fi

echo ""
echo "📋 Summary:"
echo "=========="
echo "• Local Archive: $LOCAL_ARCHIVE"
echo "• Cloud Archive: $CLOUD_ARCHIVE"
echo "• Issue: Files are 'streamed' (placeholders) not 'mirrored' (downloaded)"
echo "• Solution: Change Google Drive sync setting to 'Mirror files'"
echo ""
echo "💡 Tip: After changing to Mirror mode, it may take time to download all files."
echo "       Check Google Drive icon in menu bar for sync progress."