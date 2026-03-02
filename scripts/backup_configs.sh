#!/bin/bash
# Daily Config Files Backup
# Purpose: Backup critical OpenClaw configuration files daily

set -e

# Configuration
BACKUP_DIR="$HOME/.openclaw/backups/configs"
DATE=$(date +%Y-%m-%d)
BACKUP_PATH="$BACKUP_DIR/config-backup-$DATE.tar.gz"
RETENTION_DAYS=30  # Keep 30 days of config backups

# Files to backup
CONFIG_FILES=(
    # Core system configuration
    "$HOME/.openclaw/openclaw.json"
    "$HOME/.openclaw/email_config.json"
    "$HOME/.openclaw/exec-approvals.json"
    "$HOME/.openclaw/.env"
    
    # Agent configurations (all agents)
    "$HOME/.openclaw/agents/main/agent/models.json"
    "$HOME/.openclaw/agents/main/agent/auth.json"
    "$HOME/.openclaw/agents/main/agent/auth-profiles.json"
    "$HOME/.openclaw/agents/Ebun/agent/models.json"
    "$HOME/.openclaw/agents/Nova/agent/models.json"
    "$HOME/.openclaw/agents/Shuri/agent/models.json"
    "$HOME/.openclaw/agents/Trinity/agent/models.json"
    
    # Cron configuration
    "$HOME/.openclaw/cron/jobs.json"
    
    # Device and identity configuration
    "$HOME/.openclaw/devices/paired.json"
    "$HOME/.openclaw/identity/device.json"
    "$HOME/.openclaw/identity/device-auth.json"
    
    # Credential configurations
    "$HOME/.openclaw/credentials/imessage-default-allowFrom.json"
    "$HOME/.openclaw/credentials/imessage-pairing.json"
    "$HOME/.openclaw/credentials/telegram-default-allowFrom.json"
    "$HOME/.openclaw/credentials/telegram-pairing.json"
    "$HOME/.openclaw/credentials/whatsapp-default-allowFrom.json"
    "$HOME/.openclaw/credentials/whatsapp-pairing.json"
    
    # Subagents and session management
    "$HOME/.openclaw/subagents/runs.json"
    
    # Workspace core files
    "$HOME/.openclaw/workspace/TOOLS.md"
    "$HOME/.openclaw/workspace/HEARTBEAT.md"
    "$HOME/.openclaw/workspace/AGENTS.md"
    "$HOME/.openclaw/workspace/SOUL.md"
    "$HOME/.openclaw/workspace/USER.md"
    "$HOME/.openclaw/workspace/IDENTITY.md"
    "$HOME/.openclaw/workspace/MEMORY.md"
    
    # Workspace configuration files
    "$HOME/.openclaw/workspace/auth-profiles.json"
    "$HOME/.openclaw/workspace/.openclaw/workspace-state.json"
    "$HOME/.openclaw/workspace/config/email_classification_policy.json"
    "$HOME/.openclaw/workspace/zoho_mail_config.md"
    "$HOME/.openclaw/workspace/optimized-cron-config.txt"
    
    # Skill configuration files
    "$HOME/.openclaw/workspace/skills/qmd/config.json"
    "$HOME/.openclaw/workspace/skills/qmd/vector_metadata.json"
    "$HOME/.openclaw/workspace/skills/mail/_meta.json"
    "$HOME/.openclaw/workspace/skills/mail/.clawhub/origin.json"
    "$HOME/.openclaw/workspace/skills/mail/sending.md"
    "$HOME/.openclaw/workspace/skills/mail/himalaya.md"
    "$HOME/.openclaw/workspace/skills/mail/apple-mail.md"
    "$HOME/.openclaw/workspace/skills/office-document-specialist-suite/_meta.json"
    "$HOME/.openclaw/workspace/skills/office-document-specialist-suite/.clawhub/origin.json"
    "$HOME/.openclaw/workspace/skills/apple-mail-search-safe/_meta.json"
    "$HOME/.openclaw/workspace/skills/apple-mail-search-safe/.clawhub/origin.json"
    "$HOME/.openclaw/workspace/skills/calendly-api/_meta.json"
    "$HOME/.openclaw/workspace/skills/calendly-api/.clawhub/origin.json"
    "$HOME/.openclaw/workspace/skills/zoho-crm/_meta.json"
    "$HOME/.openclaw/workspace/skills/zoho-crm/.clawhub/origin.json"
    "$HOME/.openclaw/workspace/skills/github/_meta.json"
    "$HOME/.openclaw/workspace/skills/github/.clawhub/origin.json"
    "$HOME/.openclaw/workspace/skills/todo-management/_meta.json"
    "$HOME/.openclaw/workspace/skills/todo-management/.clawhub/origin.json"
    "$HOME/.openclaw/workspace/skills/todo-management/README.md"
    "$HOME/.openclaw/workspace/skills/n8n-workflow-automation/_meta.json"
    "$HOME/.openclaw/workspace/skills/n8n-workflow-automation/.clawhub/origin.json"
    "$HOME/.openclaw/workspace/skills/n8n-workflow-automation/assets/runbook-template.md"
    "$HOME/.openclaw/workspace/skills/frontend-design/_meta.json"
    "$HOME/.openclaw/workspace/skills/frontend-design/.clawhub/origin.json"
    "$HOME/.openclaw/workspace/skills/trello/_meta.json"
    "$HOME/.openclaw/workspace/skills/trello/.clawhub/origin.json"
    "$HOME/.openclaw/workspace/skills/snail-mail/_meta.json"
    "$HOME/.openclaw/workspace/skills/snail-mail/.clawhub/origin.json"
    "$HOME/.openclaw/workspace/skills/graphic-design/_meta.json"
    "$HOME/.openclaw/workspace/skills/graphic-design/.clawhub/origin.json"
    "$HOME/.openclaw/workspace/skills/mail-attachments/_meta.json"
    "$HOME/.openclaw/workspace/skills/mail-attachments/.clawhub/origin.json"
    
    # System skill configuration files
    "/opt/homebrew/lib/node_modules/openclaw/skills/himalaya/references/configuration.md"
    
    # Policy files
    "$HOME/.openclaw/policies/CORE_RULES.md"
    "$HOME/.openclaw/policies/ROUTING.md"
    "$HOME/.openclaw/policies/TEAM_POLICY.md"
    
    # Update check
    "$HOME/.openclaw/update-check.json"
)

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

echo "========================================"
echo "Daily Config Backup - $(date)"
echo "========================================"

# Check which files exist
EXISTING_FILES=()
for file in "${CONFIG_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        EXISTING_FILES+=("$file")
        echo "✓ Found: $(basename "$file")"
    else
        echo "✗ Missing: $(basename "$file")"
    fi
done

if [ ${#EXISTING_FILES[@]} -eq 0 ]; then
    echo "ERROR: No config files found to backup!"
    exit 1
fi

echo "----------------------------------------"
echo "Backing up ${#EXISTING_FILES[@]} config files..."

# Create backup
tar -czf "$BACKUP_PATH" "${EXISTING_FILES[@]}"

# Verify backup
if [[ -f "$BACKUP_PATH" ]]; then
    BACKUP_SIZE=$(du -h "$BACKUP_PATH" | cut -f1)
    echo "✅ Backup created: $BACKUP_PATH"
    echo "   Size: $BACKUP_SIZE"
    echo "   Files: ${#EXISTING_FILES[@]}"
    
    # Show backup contents
    echo "   Contents:"
    tar -tzf "$BACKUP_PATH" | while read -r line; do
        echo "     - $line"
    done
else
    echo "❌ ERROR: Backup file not created!"
    exit 1
fi

echo "----------------------------------------"
echo "Cleaning up old backups (keeping $RETENTION_DAYS days)..."

# Count backups before cleanup
BACKUP_COUNT_BEFORE=$(find "$BACKUP_DIR" -name "config-backup-*.tar.gz" | wc -l | tr -d ' ')

# Remove backups older than RETENTION_DAYS
find "$BACKUP_DIR" -name "config-backup-*.tar.gz" -mtime +$RETENTION_DAYS -delete

# Count backups after cleanup
BACKUP_COUNT_AFTER=$(find "$BACKUP_DIR" -name "config-backup-*.tar.gz" | wc -l | tr -d ' ')

echo "   Before: $BACKUP_COUNT_BEFORE backups"
echo "   After:  $BACKUP_COUNT_AFTER backups"
echo "   Removed: $((BACKUP_COUNT_BEFORE - BACKUP_COUNT_AFTER)) old backups"

echo "----------------------------------------"
echo "Current backups in $BACKUP_DIR:"
ls -lh "$BACKUP_DIR"/config-backup-*.tar.gz 2>/dev/null || echo "   No backups found"

echo "========================================"
echo "Config backup completed successfully!"
echo "========================================"