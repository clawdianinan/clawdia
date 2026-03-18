#!/bin/bash
# Setup daily maintenance cron job

set -e

SCRIPT_DIR="/Users/clawdia/.openclaw/workspace/scripts"
CRON_JOB="0 2 * * * $SCRIPT_DIR/daily_maintenance.sh > /dev/null 2>&1"
CRON_FILE="/tmp/openclaw_cron_$$"

echo "Setting up daily maintenance cron job..."
echo "Will run at 2:00 AM daily"
echo ""

# Get current crontab
crontab -l 2>/dev/null > "$CRON_FILE" || true

# Check if job already exists
if grep -q "daily_maintenance.sh" "$CRON_FILE"; then
    echo "⚠️  Daily maintenance cron job already exists"
    echo "Current crontab:"
    crontab -l
    exit 0
fi

# Add the new job
echo "# OpenClaw Daily Maintenance - Runs at 2:00 AM" >> "$CRON_FILE"
echo "$CRON_JOB" >> "$CRON_FILE"

# Install new crontab
crontab "$CRON_FILE"

# Cleanup
rm -f "$CRON_FILE"

echo "✅ Daily maintenance cron job installed successfully"
echo ""
echo "Current crontab:"
crontab -l

echo ""
echo "To manually run maintenance:"
echo "  cd $SCRIPT_DIR && ./daily_maintenance.sh"