#!/bin/bash
# Weekly Workspace Backup
# Purpose: Full workspace backup every Sunday

set -e

BACKUP_DIR="$HOME/.openclaw/backups/workspace"
DATE=$(date +%Y-%m-%d)
BACKUP_PATH="$BACKUP_DIR/workspace-backup-$DATE.tar.gz"
RETENTION_WEEKS=8  # Keep 8 weeks of workspace backups

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

echo "========================================"
echo "Weekly Workspace Backup - $(date)"
echo "========================================"

echo "Backing up workspace directory..."
tar -czf "$BACKUP_PATH" \
  -C "$HOME/.openclaw" \
  --exclude="backups" \
  --exclude="sandboxes" \
  --exclude="node_modules" \
  --exclude=".git" \
  --exclude="*.log" \
  --exclude="*.tmp" \
  workspace/

# Verify backup
if [[ -f "$BACKUP_PATH" ]]; then
    BACKUP_SIZE=$(du -h "$BACKUP_PATH" | cut -f1)
    echo "✅ Workspace backup created: $BACKUP_PATH"
    echo "   Size: $BACKUP_SIZE"
    
    # Show backup size breakdown
    echo "   Directory breakdown:"
    du -sh "$HOME/.openclaw/workspace"/* 2>/dev/null | while read -r line; do
        echo "     $line"
    done
else
    echo "❌ ERROR: Workspace backup file not created!"
    exit 1
fi

echo "----------------------------------------"
echo "Cleaning up old backups (keeping $RETENTION_WEEKS weeks)..."

# Count backups before cleanup
BACKUP_COUNT_BEFORE=$(find "$BACKUP_DIR" -name "workspace-backup-*.tar.gz" | wc -l | tr -d ' ')

# Remove backups older than RETENTION_WEEKS
find "$BACKUP_DIR" -name "workspace-backup-*.tar.gz" -mtime +$((RETENTION_WEEKS * 7)) -delete

# Count backups after cleanup
BACKUP_COUNT_AFTER=$(find "$BACKUP_DIR" -name "workspace-backup-*.tar.gz" | wc -l | tr -d ' ')

echo "   Before: $BACKUP_COUNT_BEFORE backups"
echo "   After:  $BACKUP_COUNT_AFTER backups"
echo "   Removed: $((BACKUP_COUNT_BEFORE - BACKUP_COUNT_AFTER)) old backups"

echo "----------------------------------------"
echo "Current workspace backups:"
ls -lh "$BACKUP_DIR"/workspace-backup-*.tar.gz 2>/dev/null || echo "   No workspace backups found"

echo "========================================"
echo "Weekly workspace backup completed!"
echo "========================================"