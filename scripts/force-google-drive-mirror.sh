#!/bin/bash
# Force Google Drive to Mirror specific folders

echo "🔄 Force Google Drive Mirror Script"
echo "==================================="

# Define the folder to mirror
TARGET_FOLDER="Clawdia Documents"
CLOUD_PATH="/Users/clawdia/Google Drive/My Drive/$TARGET_FOLDER"
LOCAL_PATH="/Users/clawdia/Documents"

echo "Target folder: $TARGET_FOLDER"
echo "Cloud path: $CLOUD_PATH"
echo "Local mirror: $LOCAL_PATH"

# Method 1: Check if we can use Google Drive CLI
echo ""
echo "1. Checking for Google Drive CLI tools..."
if command -v drive &> /dev/null; then
    echo "✅ Google Drive CLI found"
    echo "   Try: drive sync download $CLOUD_PATH"
elif command -v gdrive &> /dev/null; then
    echo "✅ gdrive CLI found"
    echo "   Try: gdrive download --recursive <folder-id>"
else
    echo "⚠️  No Google Drive CLI found"
fi

# Method 2: Force download by accessing files
echo ""
echo "2. Forcing download of critical files..."
if [ -d "$CLOUD_PATH/IIH/Archive" ]; then
    echo "   Found IIH/Archive folder"
    
    # Create a script to access all files
    ACCESS_SCRIPT="/tmp/force_download_$$.sh"
    cat > "$ACCESS_SCRIPT" << 'EOF'
#!/bin/bash
# Force Google Drive to download files by accessing them
CLOUD_DIR="$1"
MAX_FILES=50
COUNT=0

find "$CLOUD_DIR" -type f | while read file; do
    if [ $COUNT -ge $MAX_FILES ]; then
        break
    fi
    echo "Accessing: $file"
    # Try to read first few bytes to trigger download
    head -c 100 "$file" > /dev/null 2>&1
    COUNT=$((COUNT + 1))
    sleep 0.1
done
EOF
    
    chmod +x "$ACCESS_SCRIPT"
    echo "   Running file access script..."
    "$ACCESS_SCRIPT" "$CLOUD_PATH/IIH/Archive" &
    ACCESS_PID=$!
    sleep 5
    kill $ACCESS_PID 2>/dev/null
    rm -f "$ACCESS_SCRIPT"
fi

# Method 3: Check for alternative sync methods
echo ""
echo "3. Alternative sync methods..."
echo ""
echo "Option A: Use rsync to copy from cloud to local (one-time)"
echo "  rsync -av --progress \"$CLOUD_PATH/\" \"$LOCAL_PATH/\""
echo ""
echo "Option B: Use rclone (if configured)"
echo "  rclone copy gdrive:\"$TARGET_FOLDER\" \"$LOCAL_PATH\""
echo ""
echo "Option C: Manual download via Google Drive web"
echo "  1. Go to https://drive.google.com"
echo "  2. Navigate to '$TARGET_FOLDER/IIH/Archive'"
echo "  3. Select all files/folders"
echo "  4. Click Download (Google will create a zip)"
echo "  5. Extract to '$LOCAL_PATH/IIH/Archive'"

# Method 4: Check Google Drive API
echo ""
echo "4. Google Drive API status..."
if [ -f ~/.config/rclone/rclone.conf ]; then
    echo "✅ rclone configured"
    echo "   Try: rclone ls gdrive:\"$TARGET_FOLDER/IIH\""
else
    echo "⚠️  rclone not configured"
    echo "   Install: brew install rclone"
    echo "   Configure: rclone config"
fi

# Method 5: Direct file system check
echo ""
echo "5. Current sync status..."
echo ""
echo "Checking file types in cloud folder:"
find "$CLOUD_PATH/IIH/Archive" -type f -name "*.md" -o -name "*.txt" 2>/dev/null | head -5 | while read file; do
    if [ -f "$file" ]; then
        SIZE=$(stat -f%z "$file" 2>/dev/null || echo "unknown")
        echo "  $(basename "$file"): $SIZE bytes"
        
        # Check if it's a placeholder
        if [ "$SIZE" = "0" ] || [ "$SIZE" = "unknown" ]; then
            echo "    ⚠️  Likely a placeholder (streamed file)"
        else
            echo "    ✅ Actual file (downloaded)"
        fi
    fi
done

echo ""
echo "6. Recommended solution:"
echo "========================"
echo ""
echo "I. QUICK FIX (Manual):"
echo "   1. Open Google Drive app (menu bar icon)"
echo "   2. Settings → Preferences → Google Drive tab"
echo "   3. Find '$TARGET_FOLDER'"
echo "   4. Click ⋯ → 'Mirror files'"
echo "   5. Apply and wait for sync"
echo ""
echo "II. ALTERNATIVE FIX (Command line):"
echo "   1. Stop Google Drive: killall 'Google Drive'"
echo "   2. Backup settings: cp ~/Library/Preferences/com.google.drivefs.settings.plist ~/Library/Preferences/com.google.drivefs.settings.plist.backup"
echo "   3. Delete settings: rm ~/Library/Preferences/com.google.drivefs.settings.plist"
echo "   4. Restart Google Drive: open -a 'Google Drive'"
echo "   5. Reconfigure with 'Mirror' mode"
echo ""
echo "III. EMERGENCY FIX (Direct copy):"
echo "   # Copy everything from cloud to local"
echo "   cp -R \"$CLOUD_PATH/IIH/Archive\" \"$LOCAL_PATH/IIH/Archive_NEW\""
echo "   # Then merge with existing"
echo "   rsync -av \"$LOCAL_PATH/IIH/Archive_NEW/\" \"$LOCAL_PATH/IIH/Archive/\""
echo ""
echo "⚠️  WARNING: Method II will reset all Google Drive settings!"
echo "            Only use if other methods fail."

echo ""
echo "📊 Status check:"
ls -la "$LOCAL_PATH/IIH/Archive/" 2>/dev/null | head -5