# CONFIG_CHANGE_PROTOCOL.md
# Mandatory Config Change Procedure

## Rule
**BEFORE editing ANY OpenClaw configuration file, ALWAYS create a timestamped backup first.**

## Scope
Applies to ALL configuration files:
- `~/.openclaw/openclaw.json` (primary config)
- `~/.openclaw/agents/main/agent/models.json` (agent models)
- `~/.openclaw/agents/main/agent/auth-profiles.json` (auth profiles)
- Any other `.json` or config file in `~/.openclaw/` directories

## Dual Backup System
OpenClaw has TWO complementary backup systems:

### 1. Pre-Edit Timestamped Backups (THIS PROTOCOL)
- **When:** BEFORE each config edit
- **Format:** Individual files with timestamps
- **Location:** `~/.openclaw/config_backups/`
- **Purpose:** Granular rollback for specific changes
- **Retention:** 7 days + first of each month

### 2. Daily Comprehensive Backups (EXISTING SYSTEM)
- **When:** Daily at 4:00 AM via cron
- **Format:** Tar.gz archive of ALL configs
- **Location:** `~/.openclaw/backups/configs/`
- **Purpose:** Disaster recovery, full system restore
- **Retention:** 30 days

## Procedure

### 1. Pre-Change Checklist
```
[ ] Identify exact file to modify
[ ] Document reason for change
[ ] Check if gateway is running (may need restart)
[ ] Run backup script
```

### 2. Backup Command
```bash
cd /Users/clawdia/.openclaw/workspace
./scripts/config_backup.sh <config_file_path> "<reason_for_change>"
```

### 3. Edit File
- Make minimal, focused changes
- Validate JSON syntax before saving
- Test with `openclaw doctor` if applicable

### 4. Post-Change
```
[ ] Restart gateway if needed: `openclaw gateway restart`
[ ] Verify changes work
[ ] Update documentation if config structure changed
```

## Backup Script Details
Location: `/Users/clawdia/.openclaw/workspace/scripts/config_backup.sh`

Backups stored in: `/Users/clawdia/.openclaw/config_backups/`

Format: `<filename>_YYYYMMDD_HHMMSS.json`

## Emergency Rollback
If config breaks the system:
1. Stop gateway: `openclaw gateway stop`
2. Restore from backup: `cp /Users/clawdia/.openclaw/config_backups/<backup_file> <original_path>`
3. Start gateway: `openclaw gateway start`

## Unified Cleanup System
Both backup systems are automatically cleaned up daily to prevent disk clog:

### Pre-Edit Backups Retention:
- Keep last 7 days of backups
- Keep first backup of each month (historical record)

### Daily Comprehensive Backups Retention:
- Keep last 30 days of daily backups

### Cleanup Script:
`/Users/clawdia/.openclaw/workspace/scripts/config_cleanup.sh`

**Runs via:** Daily maintenance script at 2:00 AM

**To run manually:**
```bash
cd /Users/clawdia/.openclaw/workspace
./scripts/config_cleanup.sh
```

**Backup File Format:**
```
openclaw.json_YYYYMMDD_HHMMSS.json      # Config file
openclaw.json_YYYYMMDD_HHMMSS.meta      # Metadata (reason, timestamp, user)
```

**Example:** `openclaw.json_20260317_043958.json`

## Examples

### Example 1: Editing main config
```bash
# BEFORE editing
./scripts/config_backup.sh ~/.openclaw/openclaw.json "Add openai-codex provider"

# THEN edit file
# ...

# AFTER editing
openclaw gateway restart
```

### Example 2: Editing agent models
```bash
./scripts/config_backup.sh ~/.openclaw/agents/main/agent/models.json "Remove duplicate deepseek entry"
```

## Violation Consequences
- **Without backup**: Risk of unrecoverable config corruption
- **Without protocol**: Inconsistent system state, debugging nightmares
- **Best practice**: Always backup, even for trivial changes

## Automated Cleanup Enforcement
- **Daily at 2:00 AM:** `daily_maintenance.sh` runs automatically via cron
- **Retention:** Keeps 7 days + first of each month
- **Logs:** Stored in `/Users/clawdia/.openclaw/logs/maintenance_YYYYMMDD.log`

## Manual Override
To manually clean backups:
```bash
cd /Users/clawdia/.openclaw/workspace
./scripts/config_cleanup.sh
```

To run full maintenance:
```bash
cd /Users/clawdia/.openclaw/workspace
./scripts/daily_maintenance.sh
```

---
**Last Updated**: 2026-03-17  
**Status**: ACTIVE - MANDATORY FOR ALL AGENTS