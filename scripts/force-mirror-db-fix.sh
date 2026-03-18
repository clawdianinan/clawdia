#!/bin/bash
# Force Google Drive Mirror Mode by Direct Database Modification

echo "🔧 Force Mirror Mode via Database Fix"
echo "======================================"

DB_PATH="$HOME/Library/Application Support/Google/DriveFS/116832538812718317023/mirror_sqlite.db"
BACKUP_PATH="$DB_PATH.backup.$(date +%s)"

echo "Database: $DB_PATH"

# Check if we can access the database
if [ ! -f "$DB_PATH" ]; then
    echo "❌ Database not found: $DB_PATH"
    exit 1
fi

echo ""
echo "1. Creating backup..."
cp "$DB_PATH" "$BACKUP_PATH"
echo "   Backup: $BACKUP_PATH"

echo ""
echo "2. Finding Archive folder..."
ARCHIVE_ID=$(sqlite3 "$DB_PATH" "SELECT local_stable_id FROM mirror_item WHERE local_filename = 'Archive' AND parent_local_stable_id = (SELECT local_stable_id FROM mirror_item WHERE local_filename = 'IIH');" 2>/dev/null)

if [ -z "$ARCHIVE_ID" ]; then
    echo "❌ Archive folder not found in database"
    exit 1
fi

echo "   Archive folder ID: $ARCHIVE_ID"

echo ""
echo "3. Current Archive status..."
sqlite3 "$DB_PATH" <<EOF
SELECT 
    local_filename,
    storage_policy,
    local_size,
    cloud_size,
    local_type,
    cloud_type
FROM mirror_item 
WHERE local_stable_id = $ARCHIVE_ID;
EOF

echo ""
echo "4. Checking storage_policy values..."
echo "   Sample files with different policies:"
sqlite3 "$DB_PATH" <<EOF
SELECT 
    local_filename,
    storage_policy,
    local_size > 0 as has_local_content
FROM mirror_item 
WHERE local_size > 0 
LIMIT 5;
EOF

echo ""
echo "5. Attempting to force mirror mode..."
echo "   This is experimental - Google Drive may overwrite changes"
read -p "   Continue? (y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Cancelled"
    exit 1
fi

# Try to update the storage_policy
# Based on observation: files with local_size > 0 have storage_policy 0
# Folders with local_size = 0 have storage_policy 2
# Let's try setting Archive to 0

sqlite3 "$DB_PATH" <<EOF
UPDATE mirror_item 
SET storage_policy = 0 
WHERE local_stable_id = $ARCHIVE_ID;
EOF

UPDATE_COUNT=$(sqlite3 "$DB_PATH" "SELECT changes();")
echo "   Updated $UPDATE_COUNT row(s)"

echo ""
echo "6. New Archive status..."
sqlite3 "$DB_PATH" <<EOF
SELECT 
    local_filename,
    storage_policy,
    local_size,
    cloud_size
FROM mirror_item 
WHERE local_stable_id = $ARCHIVE_ID;
EOF

echo ""
echo "7. Also updating all files within Archive..."
# Get all items within Archive folder
sqlite3 "$DB_PATH" <<EOF
UPDATE mirror_item 
SET storage_policy = 0 
WHERE parent_local_stable_id = $ARCHIVE_ID;
EOF

FILES_UPDATED=$(sqlite3 "$DB_PATH" "SELECT changes();")
echo "   Updated $FILES_UPDATED file(s) within Archive"

echo ""
echo "8. Restarting Google Drive..."
killall "Google Drive" 2>/dev/null
sleep 2
open -a "Google Drive" &

echo ""
echo "9. Waiting for sync..."
sleep 10

echo ""
echo "10. Checking local Archive folder..."
LOCAL_ARCHIVE="$HOME/Documents/IIH/Archive"
if [ -d "$LOCAL_ARCHIVE" ]; then
    echo "   Local Archive exists"
    FILE_COUNT=$(find "$LOCAL_ARCHIVE" -type f 2>/dev/null | wc -l)
    echo "   Files in local Archive: $FILE_COUNT"
    
    if [ $FILE_COUNT -gt 0 ]; then
        echo "   ✅ Files found! First few:"
        find "$LOCAL_ARCHIVE" -type f 2>/dev/null | head -5
    else
        echo "   ⚠️  Still empty"
    fi
else
    echo "   ❌ Local Archive not found"
fi

echo ""
echo "📋 Summary:"
echo "=========="
echo "• Database modified: storage_policy set to 0 for Archive"
echo "• Google Drive restarted"
echo "• Backup saved: $BACKUP_PATH"
echo ""
echo "⚠️  Note: Google Drive may revert changes if it detects inconsistency"
echo "      Check Google Drive sync status in menu bar"
echo ""
echo "If this doesn't work, try the nuclear option:"
echo "  ./scripts/nuclear-google-drive-fix.sh"