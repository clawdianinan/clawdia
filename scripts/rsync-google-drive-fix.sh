#!/bin/bash
# Rsync Google Drive fix - Copy files from cloud to local as temporary solution

echo "📁 Rsync Google Drive Fix"
echo "========================"

SOURCE="/Users/clawdia/Google Drive/My Drive/Clawdia Documents/IIH"
DEST="/Users/clawdia/Documents/IIH"

echo "Source: $SOURCE"
echo "Destination: $DEST"

# Check if source exists
if [ ! -d "$SOURCE" ]; then
    echo "❌ Source directory not found: $SOURCE"
    exit 1
fi

# Check if destination exists
if [ ! -d "$DEST" ]; then
    echo "❌ Destination directory not found: $DEST"
    echo "Creating destination..."
    mkdir -p "$DEST"
fi

echo ""
echo "1. Dry run (showing what would be copied)..."
rsync -avn --progress --exclude=".*" "$SOURCE/" "$DEST/" 2>/dev/null | head -20

echo ""
echo "2. Actual sync (this will copy files)..."
read -p "Continue? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Starting sync..."
    rsync -av --progress --exclude=".*" "$SOURCE/" "$DEST/"
    
    echo ""
    echo "✅ Sync complete!"
    echo ""
    echo "Files copied to local:"
    find "$DEST" -type f -name "*.md" -o -name "*.txt" -o -name "*.docx" -o -name "*.xlsx" 2>/dev/null | head -10
else
    echo "❌ Sync cancelled"
fi

echo ""
echo "3. Checking Archive folder specifically..."
ARCHIVE_SOURCE="$SOURCE/Archive"
ARCHIVE_DEST="$DEST/Archive"

if [ -d "$ARCHIVE_SOURCE" ]; then
    echo "   Source Archive: $(find "$ARCHIVE_SOURCE" -type f 2>/dev/null | wc -l) files"
    echo "   Dest Archive: $(find "$ARCHIVE_DEST" -type f 2>/dev/null | wc -l) files"
    
    if [ -d "$ARCHIVE_DEST" ] && [ $(find "$ARCHIVE_DEST" -type f 2>/dev/null | wc -l) -eq 0 ]; then
        echo ""
        echo "   ⚠️  Archive folder is empty locally"
        echo "   To fix just Archive:"
        echo "   rsync -av \"$ARCHIVE_SOURCE/\" \"$ARCHIVE_DEST/\""
    fi
fi

echo ""
echo "📝 Notes:"
echo "• This is a one-time copy, not continuous sync"
echo "• For continuous sync, fix Google Drive 'Mirror' setting"
echo "• Run this script periodically if Google Drive remains in Stream mode"
echo ""
echo "To automate (run daily at 2 AM):"
echo "0 2 * * * /Users/clawdia/.openclaw/workspace/scripts/rsync-google-drive-fix.sh"