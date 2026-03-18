#!/bin/bash
# Daily Maintenance Script - Run via cron for system upkeep

set -e

SCRIPT_DIR="/Users/clawdia/.openclaw/workspace/scripts"
LOG_DIR="/Users/clawdia/.openclaw/logs"
MAINTENANCE_LOG="$LOG_DIR/maintenance_$(date +"%Y%m%d").log"

echo "🔧 Daily Maintenance - $(date)" | tee "$MAINTENANCE_LOG"
echo "========================================" | tee -a "$MAINTENANCE_LOG"

# 1. Unified config backup cleanup (both pre-edit and daily backups)
echo "" | tee -a "$MAINTENANCE_LOG"
echo "1. Unified Config Backup Cleanup" | tee -a "$MAINTENANCE_LOG"
echo "---------------------------------" | tee -a "$MAINTENANCE_LOG"
echo "Cleaning both:" | tee -a "$MAINTENANCE_LOG"
echo "- Pre-edit timestamped backups (7 days + first of month)" | tee -a "$MAINTENANCE_LOG"
echo "- Daily comprehensive backups (30 days)" | tee -a "$MAINTENANCE_LOG"
"$SCRIPT_DIR/config_cleanup.sh" 2>&1 | tee -a "$MAINTENANCE_LOG"

# 2. Check disk space
echo "" | tee -a "$MAINTENANCE_LOG"
echo "2. Disk Space Check" | tee -a "$MAINTENANCE_LOG"
echo "-------------------" | tee -a "$MAINTENANCE_LOG"
df -h / | tee -a "$MAINTENANCE_LOG"

# 3. Check OpenClaw gateway status
echo "" | tee -a "$MAINTENANCE_LOG"
echo "3. OpenClaw Status" | tee -a "$MAINTENANCE_LOG"
echo "------------------" | tee -a "$MAINTENANCE_LOG"
if command -v openclaw &> /dev/null; then
    openclaw gateway status 2>&1 | tee -a "$MAINTENANCE_LOG"
else
    echo "OpenClaw CLI not found" | tee -a "$MAINTENANCE_LOG"
fi

# 4. Check backup directory size
echo "" | tee -a "$MAINTENANCE_LOG"
echo "4. Backup Directory Status" | tee -a "$MAINTENANCE_LOG"
echo "--------------------------" | tee -a "$MAINTENANCE_LOG"
BACKUP_DIR="/Users/clawdia/.openclaw/config_backups"
if [ -d "$BACKUP_DIR" ]; then
    echo "Backup directory: $BACKUP_DIR" | tee -a "$MAINTENANCE_LOG"
    du -sh "$BACKUP_DIR" | tee -a "$MAINTENANCE_LOG"
    echo "File count: $(find "$BACKUP_DIR" -name "*.json" -type f | wc -l)" | tee -a "$MAINTENANCE_LOG"
else
    echo "Backup directory not found: $BACKUP_DIR" | tee -a "$MAINTENANCE_LOG"
fi

# 5. Memory file cleanup (optional - keep last 30 days)
echo "" | tee -a "$MAINTENANCE_LOG"
echo "5. Memory File Status" | tee -a "$MAINTENANCE_LOG"
echo "---------------------" | tee -a "$MAINTENANCE_LOG"
MEMORY_DIR="/Users/clawdia/.openclaw/workspace/memory"
if [ -d "$MEMORY_DIR" ]; then
    echo "Memory directory: $MEMORY_DIR" | tee -a "$MAINTENANCE_LOG"
    du -sh "$MEMORY_DIR" | tee -a "$MAINTENANCE_LOG"
    echo "File count: $(find "$MEMORY_DIR" -name "*.md" -type f | wc -l)" | tee -a "$MAINTENANCE_LOG"
    
    # Optional: Clean memory files older than 30 days
    # find "$MEMORY_DIR" -name "*.md" -type f -mtime +30 -delete
    # echo "Cleaned files older than 30 days"
else
    echo "Memory directory not found: $MEMORY_DIR" | tee -a "$MAINTENANCE_LOG"
fi

echo "" | tee -a "$MAINTENANCE_LOG"
echo "✅ Daily maintenance completed at $(date)" | tee -a "$MAINTENANCE_LOG"
echo "Log saved to: $MAINTENANCE_LOG" | tee -a "$MAINTENANCE_LOG"