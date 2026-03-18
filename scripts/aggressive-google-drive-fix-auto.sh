#!/bin/bash
# Aggressive Google Drive Fix - Uninstall, clean, reinstall with mirror mode (AUTO)

echo "💥 AGGRESSIVE Google Drive Fix (AUTO)"
echo "====================================="

echo "AUTO-CONFIRMING as requested..."
echo "Starting aggressive fix..."

echo ""
echo "🛑 Step 1: Stopping Google Drive..."
killall "Google Drive" 2>/dev/null
pkill -f "Google Drive" 2>/dev/null
sleep 3

echo ""
echo "📦 Step 2: Uninstalling Google Drive..."
if command -v brew &> /dev/null; then
    echo "   Using Homebrew to uninstall..."
    brew uninstall --cask google-drive 2>/dev/null || echo "   Not installed via Homebrew"
else
    echo "   Homebrew not found"
fi

# Manual removal
echo "   Manual removal..."
rm -rf "/Applications/Google Drive.app" 2>/dev/null || true

echo ""
echo "🗑️  Step 3: Removing ALL configuration..."
echo "   Removing preferences..."
rm -rf ~/Library/Preferences/com.google.drivefs* 2>/dev/null
rm -rf ~/Library/Preferences/ByHost/com.google.drivefs* 2>/dev/null

echo "   Removing application support..."
rm -rf ~/Library/Application\ Support/Google/DriveFS 2>/dev/null
rm -rf ~/Library/Application\ Support/Google/Drive 2>/dev/null

echo "   Removing caches..."
rm -rf ~/Library/Caches/com.google.drivefs* 2>/dev/null
rm -rf ~/Library/Caches/Google/DriveFS 2>/dev/null

echo "   Removing logs..."
rm -rf ~/Library/Logs/GoogleDriveFS 2>/dev/null
rm -rf ~/Library/Logs/Google\ Drive 2>/dev/null

echo "   Removing cloud storage mount..."
rm -rf ~/Library/CloudStorage/GoogleDrive-* 2>/dev/null

echo ""
echo "🔍 Step 4: Verifying clean state..."
echo "   Checking for remaining Google Drive files..."
REMAINING=$(find ~/Library -name "*google*drive*" -type f 2>/dev/null | wc -l)
echo "   Remaining files: $REMAINING"

echo ""
echo "🔄 Step 5: Reinstalling Google Drive..."
if command -v brew &> /dev/null; then
    echo "   Installing via Homebrew..."
    brew install --cask google-drive
else
    echo "   ❌ Homebrew not available"
    echo "   Please download and install from:"
    echo "   https://www.google.com/drive/download/"
    echo ""
    echo "   After manual installation, continue with Step 8"
    exit 1
fi

echo ""
echo "🚀 Step 6: Starting Google Drive..."
open -a "Google Drive" 2>/dev/null || open "/Applications/Google Drive.app" 2>/dev/null

echo ""
echo "⏳ Step 7: Waiting for startup..."
sleep 10

echo ""
echo "🎯 Step 8: CRITICAL - Setup Instructions"
echo "========================================"
echo ""
echo "NOW YOU MUST MANUALLY:"
echo ""
echo "1. Log in with your Google account (clawdianinan@gmail.com)"
echo ""
echo "2. During initial setup, you'll see sync options:"
echo "   • 'Stream files' - Files download on demand (DON'T CHOOSE)"
echo "   • 'Mirror files' - Files stay on computer (CHOOSE THIS)"
echo ""
echo "3. Select 'Mirror files' for reliability"
echo ""
echo "4. Choose which folders to sync:"
echo "   • Make sure 'Clawdia Documents' is selected"
echo "   • Or your main documents folder"
echo ""
echo "5. The local folder should be: ~/Documents"
echo ""
echo "6. Wait for initial sync to complete"
echo "   This may take time depending on folder size"
echo ""
echo "7. Verify Archive folder has content:"
echo "   ls -la ~/Documents/IIH/Archive/"
echo ""

echo "📝 Step 9: Post-install check..."
echo "Checking Archive folder now (will be empty until sync):"
ls -la ~/Documents/IIH/Archive/ 2>/dev/null | head -3

echo ""
echo "✅ Aggressive fix complete!"
echo "Google Drive has been reinstalled fresh."
echo "Follow the setup instructions above to enable Mirror mode."