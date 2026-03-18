#!/bin/bash

echo "=== Google Drive Sync Status Check ==="
echo "Current time: $(date)"
echo

# 1. Check if Google Drive is running
echo "1. Google Drive Process Status:"
if pgrep -f "Google Drive" > /dev/null; then
    echo "   ✅ Google Drive is running"
    DRIVE_PID=$(pgrep -f "Google Drive" | head -1)
    echo "   Process ID: $DRIVE_PID"
else
    echo "   ❌ Google Drive is NOT running"
    echo "   Starting Google Drive..."
    open -a "Google Drive"
    sleep 5
fi

# 2. Check mount point
echo
echo "2. Google Drive Mount Point:"
if [ -d "$HOME/Google Drive" ]; then
    echo "   ✅ Google Drive folder exists: $HOME/Google Drive"
    echo "   Contents:"
    ls -la "$HOME/Google Drive/My Drive/" | head -10
else
    echo "   ❌ Google Drive folder NOT found at $HOME/Google Drive"
fi

# 3. Check sync logs for errors
echo
echo "3. Recent Sync Logs (last 10 lines):"
LOG_FILE="$HOME/Library/Application Support/Google/DriveFS/Logs/drive_fs.txt"
if [ -f "$LOG_FILE" ]; then
    tail -10 "$LOG_FILE" | grep -E "(error|Error|ERROR|warning|Warning|WARNING|sync|Sync|SYNC)" || echo "   No recent errors found in logs"
else
    echo "   ❌ Log file not found: $LOG_FILE"
fi

# 4. Check for the specific error about Documents folder
echo
echo "4. Checking for Documents folder conflict:"
if grep -q "Can.t add path.*Documents" "$LOG_FILE" 2>/dev/null; then
    echo "   ⚠️  Found Documents folder conflict error"
    echo "   Error message:"
    grep -a "Can.t add path.*Documents" "$LOG_FILE" | tail -1
    echo
    echo "   Solution: Remove the conflicting sync folder from Google Drive preferences"
    echo "   Manual steps:"
    echo "   1. Open Google Drive app"
    echo "   2. Click Google Drive menu → Preferences"
    echo "   3. Go to 'Folders from this Mac' tab"
    echo "   4. Find '/Users/clawdia/Documents' and click 'Remove'"
    echo "   5. Click 'Done'"
else
    echo "   ✅ No Documents folder conflict found"
fi

# 5. Check sync activity
echo
echo "5. Recent Sync Activity:"
tail -20 "$LOG_FILE" 2>/dev/null | grep -E "(download|upload|sync|Sync|SYNC)" | tail -5 || echo "   No recent sync activity found"

# 6. Check network connectivity
echo
echo "6. Network Connectivity to Google:"
if ping -c 2 -W 2 drive.google.com > /dev/null 2>&1; then
    echo "   ✅ Can reach drive.google.com"
else
    echo "   ❌ Cannot reach drive.google.com - check network"
fi

# 7. Check disk space
echo
echo "7. Disk Space:"
df -h / | tail -1

# 8. Recommendations
echo
echo "=== Recommendations ==="
echo "1. If Documents folder conflict exists:"
echo "   - Remove conflicting folder from Google Drive preferences"
echo "   - Or choose a different folder to sync"
echo
echo "2. To force a sync check:"
echo "   - Quit Google Drive (Command+Q)"
echo "   - Restart Google Drive"
echo "   - Check sync status in menu bar icon"
echo
echo "3. To check sync status in UI:"
echo "   - Click Google Drive menu bar icon"
echo "   - Look for sync status and errors"
echo
echo "4. Alternative sync method:"
echo "   - Use Google Drive web interface: https://drive.google.com"
echo "   - Upload files directly if local sync has issues"

echo
echo "=== Quick Fix Commands ==="
echo "# Restart Google Drive:"
echo "pkill -f 'Google Drive' && sleep 3 && open -a 'Google Drive'"
echo
echo "# Check sync folder configuration:"
echo "ls -la '$HOME/Library/Application Support/Google/DriveFS/'*/local_folders/ 2>/dev/null"
echo
echo "# Monitor sync logs:"
echo "tail -f '$HOME/Library/Application Support/Google/DriveFS/Logs/drive_fs.txt' | grep -E '(error|sync)'"