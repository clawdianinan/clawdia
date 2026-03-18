#!/bin/bash
# Update crontab with daily config backup

set -e

# Create temporary crontab file
TEMP_CRON=$(mktemp)

# Get current crontab
crontab -l > "$TEMP_CRON" 2>/dev/null || echo "# OpenClaw Cron Configuration" > "$TEMP_CRON"

# Remove existing daily config backup if present
grep -v "backup_configs.sh" "$TEMP_CRON" > "${TEMP_CRON}.tmp" && mv "${TEMP_CRON}.tmp" "$TEMP_CRON"

# Remove empty lines at end
sed -i '' '/^$/d' "$TEMP_CRON" 2>/dev/null || sed -i '/^$/d' "$TEMP_CRON"

# Add daily config backup at 4 AM
echo "" >> "$TEMP_CRON"
echo "# Daily Config Backup (4 AM)" >> "$TEMP_CRON"
echo "0 4 * * * /Users/clawdia/.openclaw/workspace/scripts/backup_configs.sh >> /Users/clawdia/.openclaw/workspace/logs/cron-config-backup.log 2>&1" >> "$TEMP_CRON"

# Install updated crontab
crontab "$TEMP_CRON"

# Clean up
rm -f "$TEMP_CRON"

echo "✅ Crontab updated successfully!"
echo ""
echo "New cron jobs:"
echo "--------------"
crontab -l | grep -v "^#" | grep -v "^$"