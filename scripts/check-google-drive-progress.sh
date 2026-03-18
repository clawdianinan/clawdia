#!/bin/bash
# Check Google Drive Sync Progress

echo "📊 Google Drive Sync Progress Check"
echo "==================================="

echo "1. Google Drive status:"
if ps aux | grep -q "[G]oogle Drive"; then
    echo "✅ Running"
else
    echo "❌ Not running"
    echo "   Start with: open -a 'Google Drive'"
fi

echo ""
echo "2. Archive folder status:"
ARCHIVE_PATH="$HOME/Documents/IIH/Archive"
if [ -d "$ARCHIVE_PATH" ]; then
    FILE_COUNT=$(find "$ARCHIVE_PATH" -type f 2>/dev/null | wc -l)
    echo "✅ Exists"
    echo "   Files: $FILE_COUNT"
    
    if [ $FILE_COUNT -gt 0 ]; then
        echo "   ✅ Files are downloading!"
        echo "   First few files:"
        find "$ARCHIVE_PATH" -type f 2>/dev/null | head -5
    else
        echo "   ⚠️  Still empty"
        echo "   Check Google Drive setup completed Mirror mode"
    fi
else
    echo "❌ Not found"
    echo "   Path: $ARCHIVE_PATH"
fi

echo ""
echo "3. Google Drive setup verification:"
echo "   Check menu bar for Google Drive icon"
echo "   Click it → Check sync status"
echo ""
echo "4. If Archive remains empty after 10+ minutes:"
echo "   a. Click Google Drive menu bar icon"
echo "   b. Settings → Preferences"
echo "   c. Google Drive tab"
echo "   d. Find 'Clawdia Documents'"
echo "   e. Click ⋯ → 'Mirror files'"
echo "   f. Apply and wait"

echo ""
echo "5. Quick fix if Mirror mode fails:"
echo "   Run rsync backup:"
echo "   ./scripts/rsync-google-drive-fix.sh"

echo ""
echo "📈 Current Archive contents:"
ls -la "$ARCHIVE_PATH/" 2>/dev/null || echo "   Archive folder not accessible"