#!/bin/bash
# Backup memory files

set -e

BACKUP_DIR="$HOME/.openclaw/backups/memory"
DATE=$(date +%Y-%m-%d)
BACKUP_PATH="$BACKUP_DIR/memory-backup-$DATE.tar.gz"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Backup memory files
echo "Backing up memory files..."
tar -czf "$BACKUP_PATH" \
  -C "$HOME/.openclaw/workspace" \
  memory/ \
  MEMORY.md \
  AGENTS.md \
  SOUL.md \
  USER.md \
  HEARTBEAT.md \
  IDENTITY.md \
  TOOLS.md

# Keep only last 7 days of backups
echo "Cleaning up old backups..."
find "$BACKUP_DIR" -name "memory-backup-*.tar.gz" -mtime +7 -delete

echo "Backup completed: $BACKUP_PATH"
echo "Backup size: $(du -h "$BACKUP_PATH" | cut -f1)"