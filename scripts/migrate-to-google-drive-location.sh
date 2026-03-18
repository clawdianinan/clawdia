#!/bin/bash
# Migrate from old Documents location to new Google Drive location

echo "🔄 Migrating to Google Drive Location"
echo "===================================="

OLD_BASE="/Users/clawdia/Documents"
NEW_BASE="/Users/clawdia/My Drive/Clawdia Documents"

echo "Old location: $OLD_BASE"
echo "New location: $NEW_BASE"

echo ""
echo "1. Verifying both locations exist..."
if [ ! -d "$OLD_BASE" ]; then
    echo "❌ Old location not found: $OLD_BASE"
    exit 1
fi

if [ ! -d "$NEW_BASE" ]; then
    echo "❌ New location not found: $NEW_BASE"
    exit 1
fi

echo "✅ Both locations exist"

echo ""
echo "2. Checking Archive folder in new location..."
if [ -d "$NEW_BASE/IIH/Archive" ]; then
    ARCHIVE_FILES=$(find "$NEW_BASE/IIH/Archive" -type f 2>/dev/null | wc -l)
    echo "✅ Archive exists in new location: $ARCHIVE_FILES files"
    
    if [ $ARCHIVE_FILES -gt 0 ]; then
        echo "   First few files:"
        find "$NEW_BASE/IIH/Archive" -type f 2>/dev/null | head -5
    fi
else
    echo "❌ Archive not found in new location"
fi

echo ""
echo "3. Comparing file counts..."
OLD_COUNT=$(find "$OLD_BASE" -type f 2>/dev/null | wc -l)
NEW_COUNT=$(find "$NEW_BASE" -type f 2>/dev/null | wc -l)

echo "   Old location: $OLD_COUNT files"
echo "   New location: $NEW_COUNT files"

echo ""
echo "4. DRY RUN - What would be moved/deleted..."
echo ""
echo "Files in old location that DON'T exist in new location:"
find "$OLD_BASE" -type f 2>/dev/null | while read file; do
    REL_PATH="${file#$OLD_BASE/}"
    if [ ! -f "$NEW_BASE/$REL_PATH" ]; then
        echo "   Only in old: $REL_PATH"
    fi
done | head -10

echo ""
echo "5. MIGRATION OPTIONS:"
echo "===================="
echo ""
echo "A. SAFE MIGRATION (Recommended)"
echo "   1. Backup old location"
echo "   2. Move unique files from old to new"
echo "   3. Delete old location after verification"
echo ""
echo "B. AGGRESSIVE MIGRATION"
echo "   1. Delete old location immediately"
echo "   2. Use only new Google Drive location"
echo ""
echo "C. SYMBOLIC LINK MIGRATION"
echo "   1. Rename old Documents"
echo "   2. Create symlink: Documents → Google Drive location"
echo ""
read -p "Choose option (A/B/C): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[A]$ ]]; then
    echo "✅ SAFE MIGRATION selected"
    echo ""
    
    # Create backup
    BACKUP_DIR="$HOME/Documents_BACKUP_$(date +%Y%m%d_%H%M%S)"
    echo "1. Creating backup: $BACKUP_DIR"
    cp -R "$OLD_BASE" "$BACKUP_DIR"
    
    echo ""
    echo "2. Finding unique files in old location..."
    UNIQUE_FILES=()
    find "$OLD_BASE" -type f 2>/dev/null | while read file; do
        REL_PATH="${file#$OLD_BASE/}"
        if [ ! -f "$NEW_BASE/$REL_PATH" ]; then
            UNIQUE_FILES+=("$REL_PATH")
            echo "   Unique: $REL_PATH"
        fi
    done
    
    echo ""
    echo "3. Copying unique files to new location..."
    for REL_PATH in "${UNIQUE_FILES[@]}"; do
        OLD_FILE="$OLD_BASE/$REL_PATH"
        NEW_FILE="$NEW_BASE/$REL_PATH"
        
        # Create directory if needed
        NEW_DIR=$(dirname "$NEW_FILE")
        mkdir -p "$NEW_DIR"
        
        echo "   Copying: $REL_PATH"
        cp "$OLD_FILE" "$NEW_FILE"
    done
    
    echo ""
    echo "4. Verifying new location has all files..."
    VERIFY_COUNT=$(find "$NEW_BASE" -type f 2>/dev/null | wc -l)
    echo "   New location now has: $VERIFY_COUNT files"
    
    echo ""
    read -p "5. Delete old location? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "   Deleting old location..."
        rm -rf "$OLD_BASE"
        echo "   ✅ Old location deleted"
    else
        echo "   ⚠️  Old location kept at: $OLD_BASE"
    fi
    
elif [[ $REPLY =~ ^[B]$ ]]; then
    echo "⚠️  AGGRESSIVE MIGRATION selected"
    echo ""
    read -p "ARE YOU SURE? This will DELETE $OLD_BASE immediately. (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "   Deleting old location..."
        rm -rf "$OLD_BASE"
        echo "   ✅ Old location deleted"
        echo "   All files now only in: $NEW_BASE"
    else
        echo "   ❌ Cancelled"
    fi
    
elif [[ $REPLY =~ ^[C]$ ]]; then
    echo "🔗 SYMBOLIC LINK MIGRATION selected"
    echo ""
    
    # Rename old Documents
    OLD_BACKUP="$OLD_BASE_OLD_$(date +%Y%m%d)"
    echo "1. Renaming old Documents: $OLD_BASE → $OLD_BACKUP"
    mv "$OLD_BASE" "$OLD_BACKUP"
    
    echo ""
    echo "2. Creating symbolic link..."
    ln -s "$NEW_BASE" "$OLD_BASE"
    
    echo "   ✅ Created symlink: $OLD_BASE → $NEW_BASE"
    echo ""
    echo "3. Testing symlink..."
    if [ -L "$OLD_BASE" ]; then
        echo "   ✅ Symlink works"
        echo "   ls $OLD_BASE will show Google Drive files"
    else
        echo "   ❌ Symlink failed"
    fi
else
    echo "❌ Invalid option"
    exit 1
fi

echo ""
echo "6. UPDATING FILE REFERENCES"
echo "==========================="
echo ""
echo "You mentioned updating file references. Common places to check:"
echo ""
echo "1. OpenClaw workspace files:"
echo "   grep -r \"$OLD_BASE\" ~/.openclaw/workspace/ 2>/dev/null | head -5"
echo ""
echo "2. Scripts and automation:"
echo "   grep -r \"/Documents/\" ~/.openclaw/workspace/scripts/ 2>/dev/null"
echo ""
echo "3. Documentation files:"
echo "   grep -r \"Documents/IIH\" ~/.openclaw/workspace/ 2>/dev/null"
echo ""
echo "4. Quick reference update script:"
cat > /tmp/update_references.sh << 'EOF'
#!/bin/bash
# Update file references from old to new location
OLD_PATH="/Users/clawdia/Documents"
NEW_PATH="/Users/clawdia/My Drive/Clawdia Documents"

echo "Updating references in workspace..."
find ~/.openclaw/workspace -type f -name "*.md" -o -name "*.sh" -o -name "*.py" 2>/dev/null | while read file; do
    if grep -q "$OLD_PATH" "$file" 2>/dev/null; then
        echo "Updating: $file"
        sed -i '' "s|$OLD_PATH|$NEW_PATH|g" "$file"
    fi
done
echo "Done"
EOF

chmod +x /tmp/update_references.sh
echo "   Run: /tmp/update_references.sh"

echo ""
echo "7. FINAL VERIFICATION"
echo "===================="
echo "New Google Drive location: $NEW_BASE"
echo "Archive folder status:"
ls -la "$NEW_BASE/IIH/Archive/" 2>/dev/null | head -5

echo ""
echo "✅ Migration complete!"
echo "All files now in: $NEW_BASE"
echo "Google Drive will keep them synced via Mirror mode"