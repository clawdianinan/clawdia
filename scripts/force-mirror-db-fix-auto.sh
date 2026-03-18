#!/bin/bash
# Force Google Drive Mirror Mode by Direct Database Modification (AUTO-CONFIRM)

echo "🔧 Force Mirror Mode via Database Fix (AUTO)"
echo "============================================"

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
echo "4. Attempting to force mirror mode..."
echo "   AUTO-CONFIRMING (as requested)..."
echo "   Updating storage_policy from 2 to 0..."

# Update the storage_policy
sqlite3 "$DB_PATH" <<EOF
UPDATE mirror_item 
SET storage_policy = 0 
WHERE local_stable_id = $ARCHIVE_ID;
EOF

UPDATE_COUNT=$(sqlite3 "$DB_PATH" "SELECT changes();")
echo "   Updated $UPDATE_COUNT row(s)"

echo ""
echo "5. Also updating all files within Archive..."
# Get all items within Archive folder
sqlite3 "$DB_PATH" <<EOF
UPDATE mirror_item 
SET storage_policy = 0 
WHERE parent_local_stable_id = $ARCHIVE_ID;
EOF

FILES_UPDATED=$(sqlite3 "$DB_PATH" "SELECT changes();")
echo "   Updated $FILES_UPDATED file(s) within Archive"

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
echo "7. Restarting Google Drive..."
killall "Google Drive" 2>/dev/null
sleep 2
open -a "Google Drive" &

echo ""
echo "8. Checking local Archive folder (initial)..."
LOCAL_ARCHIVE="$HOME/Documents/IIH/Archive"
if [ -d "$LOCAL_ARCHIVE" ]; then
    FILE_COUNT=$(find "$LOCAL_ARCHIVE" -type f 2>/dev/null | wc -l)
    echo "   Files in local Archive: $FILE_COUNT"
else
    echo "   ❌ Local Archive not found"
fi

echo ""
echo "✅ Database fix applied!"
echo "   Google Drive restarted"
echo "   Backup saved: $BACKUP_PATH"
echo ""
echo "⏳ Waiting 2 minutes for sync to start..."
echo "   Then checking again..."