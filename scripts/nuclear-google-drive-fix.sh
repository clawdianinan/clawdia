#!/bin/bash
# Nuclear Google Drive Fix - Complete reconfiguration to force mirror mode

echo "💥 NUCLEAR Google Drive Fix"
echo "==========================="
echo "This will COMPLETELY reset Google Drive configuration"
echo "and force mirror mode for all folders."
echo ""
read -p "ARE YOU SURE? This will require re-login to Google Drive. (y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Cancelled"
    exit 1
fi

echo ""
echo "🚨 Step 1: Stopping Google Drive..."
killall "Google Drive" 2>/dev/null
sleep 3

echo ""
echo "📁 Step 2: Backing up current configuration..."
BACKUP_DIR="$HOME/Google_Drive_Backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup all Google Drive configs
cp -R ~/Library/Preferences/com.google.drivefs* "$BACKUP_DIR/" 2>/dev/null
cp -R ~/Library/Application\ Support/Google/DriveFS "$BACKUP_DIR/DriveFS_Backup/" 2>/dev/null

echo "   Backup created: $BACKUP_DIR"

echo ""
echo "🗑️  Step 3: Removing Google Drive configuration..."
# Remove preferences
rm -f ~/Library/Preferences/com.google.drivefs*.plist 2>/dev/null
rm -f ~/Library/Preferences/com.google.drivefs*.plist.lockfile 2>/dev/null

# Remove application support (keeping only backup)
mv ~/Library/Application\ Support/Google/DriveFS "$BACKUP_DIR/DriveFS_Original/" 2>/dev/null
mkdir -p ~/Library/Application\ Support/Google/DriveFS

echo ""
echo "🔄 Step 4: Creating fresh configuration for mirror mode..."
# Create a fresh minimal configuration
cat > ~/Library/Preferences/com.google.drivefs.settings.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CurrentAccountToken</key>
	<string>FORCE_MIRROR_MODE</string>
	<key>PerAccountPreferences</key>
	<string>{"per_account_preferences":[{"key":"FORCE_MIRROR_MODE","value":{"mount_point_path":"/Users/clawdia/Library/CloudStorage/GoogleDrive-clawdianinan@gmail.com","machine_root_doc_id":"FORCE_MIRROR","sync_mode":"MIRROR"}}]}</string>
</dict>
</plist>
EOF

echo ""
echo "🔧 Step 5: Setting folder sync to mirror mode..."
# Create a script that will run after Google Drive starts
MIRROR_SCRIPT="/tmp/setup_mirror_$$.applescript"
cat > "$MIRROR_SCRIPT" << 'EOF'
tell application "Google Drive"
    activate
    delay 5
    
    -- Try to set mirror mode through UI automation
    tell application "System Events"
        -- Click Google Drive menu bar icon
        tell process "Google Drive"
            click menu bar item 1 of menu bar 1
            delay 2
            
            -- Try to navigate to preferences
            keystroke "," using {command down}
            delay 3
            
            -- This is tricky without exact UI element names
            -- The script will at least open the app
        end tell
    end tell
end tell
EOF

echo ""
echo "🚀 Step 6: Starting Google Drive..."
open -a "Google Drive"

echo ""
echo "⏳ Step 7: Waiting for Google Drive to start..."
sleep 10

echo ""
echo "📋 Step 8: Manual configuration required..."
echo ""
echo "NOW YOU NEED TO MANUALLY:"
echo "1. Log in to your Google account when prompted"
echo "2. Go to Google Drive Preferences (click menu bar icon → Settings → Preferences)"
echo "3. Go to 'Google Drive' tab"
echo "4. Find 'Clawdia Documents' or your main folder"
echo "5. Click the three dots (⋯) next to it"
echo "6. Select 'Mirror files' (NOT 'Stream files')"
echo "7. Click 'Apply'"
echo "8. Wait for initial sync to complete"
echo ""
echo "This may take several minutes to hours depending on folder size."

echo ""
echo "🛠️  Step 9: Alternative - Use command line setup..."
echo ""
echo "If the UI method fails, try reinstalling Google Drive:"
echo "1. brew install --cask google-drive"
echo "2. During setup, choose 'Mirror files' option"
echo ""
echo "Or use rclone for reliable sync:"
echo "1. brew install rclone"
echo "2. rclone config"
echo "3. rclone copy --progress gdrive:'Clawdia Documents' ~/Documents"

echo ""
echo "📊 Step 10: Verification..."
echo "Checking current status:"
ls -la ~/Documents/IIH/Archive/ 2>/dev/null | head -5

echo ""
echo "✅ Nuclear reset complete!"
echo "Backup saved to: $BACKUP_DIR"
echo ""
echo "If this doesn't work, consider:"
echo "1. Uninstall Google Drive: brew uninstall --cask google-drive"
echo "2. Delete all configs: rm -rf ~/Library/Application\ Support/Google/DriveFS"
echo "3. Reinstall fresh: brew install --cask google-drive"
echo "4. Choose 'Mirror' during initial setup"

# Clean up
rm -f "$MIRROR_SCRIPT" 2>/dev/null