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

# Keep only last 10 backups
echo "Cleaning up old backups..."
# List tar.gz files sorted by modification time (newest first), keep first 10
tmpfile=$(mktemp)
find "$BACKUP_DIR" -name "memory-backup-*.tar.gz" -type f -exec stat -f "%m %N" {} \; | sort -rn | cut -d' ' -f2- > "$tmpfile"
total=$(wc -l < "$tmpfile" | tr -d ' ')
if [[ $total -gt 10 ]]; then
    tail -n +11 "$tmpfile" | while read -r file; do
        rm -f "$file"
    done
fi
rm -f "$tmpfile"

echo "Backup completed: $BACKUP_PATH"
echo "Backup size: $(du -h "$BACKUP_PATH" | cut -f1)"