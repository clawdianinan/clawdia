#!/bin/bash
# Config Backup Script - Run BEFORE editing any OpenClaw config files
# Usage: ./config_backup.sh <config_file_path> <reason_for_change>

set -e

CONFIG_FILE="$1"
REASON="$2"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

if [ -z "$CONFIG_FILE" ]; then
    echo "ERROR: No config file specified"
    echo "Usage: $0 <config_file_path> <reason_for_change>"
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Config file not found: $CONFIG_FILE"
    exit 1
fi

# Create backup directory if it doesn't exist
BACKUP_DIR="/Users/clawdia/.openclaw/config_backups"
mkdir -p "$BACKUP_DIR"

# Extract filename without path
FILENAME=$(basename "$CONFIG_FILE")
BACKUP_FILE="$BACKUP_DIR/${FILENAME}_${TIMESTAMP}.json"

# Create backup
cp "$CONFIG_FILE" "$BACKUP_FILE"

# Create metadata file
META_FILE="$BACKUP_DIR/${FILENAME}_${TIMESTAMP}.meta"
echo "Backup created: $TIMESTAMP" > "$META_FILE"
echo "Original: $CONFIG_FILE" >> "$META_FILE"
echo "Backup: $BACKUP_FILE" >> "$META_FILE"
echo "Reason: ${REASON:-No reason provided}" >> "$META_FILE"
echo "User: $(whoami)" >> "$META_FILE"
echo "Host: $(hostname)" >> "$META_FILE"

echo "✅ Config backup created:"
echo "   Original: $CONFIG_FILE"
echo "   Backup: $BACKUP_FILE"
echo "   Reason: ${REASON:-No reason provided}"
echo "   Metadata: $META_FILE"

# List recent backups for this file
echo ""
echo "📋 Recent backups for $FILENAME:"
find "$BACKUP_DIR" -name "${FILENAME}_*.json" -type f | sort -r | head -5