#!/bin/bash
# Unified Config Backup Cleanup Script - Run daily to prevent clog
# Cleans both: Pre-edit timestamped backups AND daily comprehensive backups

set -e

# ==================== CONFIGURATION ====================
# 1. Pre-edit timestamped backups (my new system)
PRE_EDIT_BACKUP_DIR="/Users/clawdia/.openclaw/config_backups"
PRE_EDIT_RETENTION_DAYS=7  # Keep last 7 days + first of each month

# 2. Daily comprehensive backups (existing system)
DAILY_BACKUP_DIR="/Users/clawdia/.openclaw/backups/configs"
DAILY_RETENTION_DAYS=30  # Keep 30 days of daily backups

echo "🧹 Unified Config Backup Cleanup"
echo "========================================"
echo ""

# ==================== PART 1: PRE-EDIT BACKUPS ====================
echo "1. Pre-Edit Timestamped Backups"
echo "   -----------------------------"
echo "   Directory: $PRE_EDIT_BACKUP_DIR"
echo "   Retention: Last $PRE_EDIT_RETENTION_DAYS days + first of each month"

PRE_EDIT_DELETED=0
PRE_EDIT_KEPT=0

if [ ! -d "$PRE_EDIT_BACKUP_DIR" ]; then
    echo "   ⚠️  Directory not found. Skipping."
else
    # Count files before cleanup
    PRE_EDIT_FILES_BEFORE=$(find "$PRE_EDIT_BACKUP_DIR" -name "*.json" -type f | wc -l)
    echo "   Files before: $PRE_EDIT_FILES_BEFORE"
    
    if [ "$PRE_EDIT_FILES_BEFORE" -eq 0 ]; then
        echo "   ✅ No files to clean."
    else
        # Keep track of files to preserve
        PRESERVE_FILE="/tmp/config_backups_preserve_$$.txt"
        touch "$PRESERVE_FILE"
        
        # Keep all files from last $PRE_EDIT_RETENTION_DAYS days
        CUTOFF_DATE=$(date -v-${PRE_EDIT_RETENTION_DAYS}d +"%Y%m%d")
        
        # Identify first backup of each month to keep (historical record)
        find "$PRE_EDIT_BACKUP_DIR" -name "*.json" -type f | while read -r file; do
            # Extract date from filename: openclaw.json_20260317_043958.json
            filename=$(basename "$file")
            if [[ $filename =~ _([0-9]{8})_[0-9]{6}\.json$ ]]; then
                filedate="${BASH_REMATCH[1]}"
                filemonth="${filedate:0:6}" # YYYYMM
                
                # Check if this is the earliest file for this month
                month_file="/tmp/month_${filemonth}_$$.txt"
                if [ ! -f "$month_file" ] || [ "$filedate" -lt "$(cat "$month_file")" ]; then
                    echo "$filedate" > "$month_file"
                    echo "$file" >> "$PRESERVE_FILE"
                fi
            fi
        done
        
        # Delete old files (except preserved ones)
        find "$PRE_EDIT_BACKUP_DIR" -name "*.json" -type f | while read -r file; do
            filename=$(basename "$file")
            
            # Check if file should be preserved (first of month)
            if grep -q "^$file$" "$PRESERVE_FILE"; then
                PRE_EDIT_KEPT=$((PRE_EDIT_KEPT + 1))
                continue
            fi
            
            # Extract date and check if older than retention
            if [[ $filename =~ _([0-9]{8})_[0-9]{6}\.json$ ]]; then
                filedate="${BASH_REMATCH[1]}"
                
                if [ "$filedate" -lt "$CUTOFF_DATE" ]; then
                    # Also delete corresponding .meta file
                    meta_file="${file%.json}.meta"
                    rm -f "$file"
                    rm -f "$meta_file"
                    PRE_EDIT_DELETED=$((PRE_EDIT_DELETED + 1))
                else
                    PRE_EDIT_KEPT=$((PRE_EDIT_KEPT + 1))
                fi
            else
                # File doesn't match pattern, keep it
                PRE_EDIT_KEPT=$((PRE_EDIT_KEPT + 1))
            fi
        done
        
        # Cleanup temp files
        rm -f "$PRESERVE_FILE"
        rm -f /tmp/month_*_$$.txt 2>/dev/null || true
        
        PRE_EDIT_FILES_AFTER=$(find "$PRE_EDIT_BACKUP_DIR" -name "*.json" -type f | wc -l)
        echo "   Deleted: $PRE_EDIT_DELETED files"
        echo "   Kept: $PRE_EDIT_KEPT files"
        echo "   Files after: $PRE_EDIT_FILES_AFTER"
    fi
fi

# ==================== PART 2: DAILY COMPREHENSIVE BACKUPS ====================
echo ""
echo "2. Daily Comprehensive Backups"
echo "   ----------------------------"
echo "   Directory: $DAILY_BACKUP_DIR"
echo "   Retention: Last $DAILY_RETENTION_DAYS days"

DAILY_DELETED=0
DAILY_KEPT=0

if [ ! -d "$DAILY_BACKUP_DIR" ]; then
    echo "   ⚠️  Directory not found. Skipping."
else
    # Count files before cleanup
    DAILY_FILES_BEFORE=$(find "$DAILY_BACKUP_DIR" -name "config-backup-*.tar.gz" -type f | wc -l)
    echo "   Files before: $DAILY_FILES_BEFORE"
    
    if [ "$DAILY_FILES_BEFORE" -eq 0 ]; then
        echo "   ✅ No files to clean."
    else
        # Remove backups older than RETENTION_DAYS
        find "$DAILY_BACKUP_DIR" -name "config-backup-*.tar.gz" -type f -mtime +$DAILY_RETENTION_DAYS | while read -r file; do
            rm -f "$file"
            DAILY_DELETED=$((DAILY_DELETED + 1))
            echo "     Deleted: $(basename "$file")"
        done
        
        DAILY_FILES_AFTER=$(find "$DAILY_BACKUP_DIR" -name "config-backup-*.tar.gz" -type f | wc -l)
        DAILY_KEPT=$((DAILY_FILES_BEFORE - DAILY_DELETED))
        echo "   Deleted: $DAILY_DELETED files"
        echo "   Kept: $DAILY_KEPT files"
        echo "   Files after: $DAILY_FILES_AFTER"
    fi
fi

# ==================== SUMMARY ====================
echo ""
echo "========================================"
echo "✅ Cleanup Summary"
echo "========================================"
echo "Pre-edit backups:"
echo "  - Deleted: $PRE_EDIT_DELETED files"
echo "  - Kept: $PRE_EDIT_KEPT files"
echo ""
echo "Daily comprehensive backups:"
echo "  - Deleted: $DAILY_DELETED files"
echo "  - Kept: $DAILY_KEPT files"
echo ""
echo "Total deleted: $((PRE_EDIT_DELETED + DAILY_DELETED)) files"

# Show disk usage
echo ""
echo "📊 Disk Usage:"
if [ -d "$PRE_EDIT_BACKUP_DIR" ]; then
    echo "  Pre-edit backups: $(du -sh "$PRE_EDIT_BACKUP_DIR" | cut -f1)"
fi
if [ -d "$DAILY_BACKUP_DIR" ]; then
    echo "  Daily backups: $(du -sh "$DAILY_BACKUP_DIR" | cut -f1)"
fi