# OpenClaw Cron Jobs Configuration

## Purpose
Automated scheduling for OpenClaw maintenance, QMD operations, and business processes.

## Active Baseline (Implemented)
Current live crontab follows this consolidated baseline:
- Unified health monitor: every 15 minutes
- Email processor: hourly (all day, every day)
- Heartbeat + maintenance: every 30 minutes
- Daily cleanup/config backup, weekly backup, monthly log rotation
- Skill update check daily at noon

Note: legacy/older examples below are reference patterns; use live crontab as source of truth.

## Job Categories

### 1. System Maintenance
```
# Daily memory cleanup (6 AM)
0 6 * * * /Users/clawdia/.openclaw/workspace/scripts/cleanup-memory.sh

# Weekly workspace backup (Sunday 2 AM)
0 2 * * 0 /Users/clawdia/.openclaw/workspace/scripts/backup-workspace.sh

# Monthly log rotation (1st of month, 3 AM)
0 3 1 * * /Users/clawdia/.openclaw/workspace/scripts/rotate-logs.sh
```

### 2. QMD Operations
```
# Ensure Qdrant service is running (every hour)
0 * * * * /Users/clawdia/.openclaw/workspace/skills/qmd/scripts/check-qdrant.sh

# Daily QMD reindexing (2 AM)
0 2 * * * /Users/clawdia/.openclaw/workspace/skills/qmd/scripts/reindex-daily.sh

# Weekly full reindex (Sunday 3 AM)
0 3 * * 0 /Users/clawdia/.openclaw/workspace/skills/qmd/scripts/reindex-full.sh

# Vector embedding generation (4 AM daily)
0 4 * * * /Users/clawdia/.openclaw/workspace/skills/qmd/scripts/generate-embeddings.sh
```

### 3. Business Operations
```
# Email monitoring (hourly, all day)
0 * * * * /Users/clawdia/.openclaw/workspace/scripts/consolidated-email-processor.sh

# Calendar sync (every hour)
0 * * * * /Users/clawdia/.openclaw/workspace/scripts/sync-calendar.sh

# Heartbeat check (every 2 hours)
0 */2 * * * /Users/clawdia/.openclaw/workspace/scripts/heartbeat-check.sh

# Deadline reminders (8 AM daily)
0 8 * * * /Users/clawdia/.openclaw/workspace/scripts/check-deadlines.sh
```

### 4. OpenClaw Specific
```
# Gateway health check (every 15 minutes)
*/15 * * * * /Users/clawdia/.openclaw/workspace/scripts/check-gateway.sh

# Model availability check (hourly)
0 * * * * /Users/clawdia/.openclaw/workspace/scripts/check-models.sh

# Skill updates check (daily at noon)
0 12 * * * /Users/clawdia/.openclaw/workspace/scripts/check-skill-updates.sh
```

## Script Locations

### Maintenance Scripts (`/scripts/`)
- `cleanup-memory.sh` - Remove old memory files
- `backup-workspace.sh` - Backup workspace to external location
- `rotate-logs.sh` - Rotate and compress log files
- `check-gateway.sh` - Verify OpenClaw gateway health
- `check-models.sh` - Check AI model availability
- `check-skill-updates.sh` - Check for skill updates

### QMD Scripts (`/skills/qmd/scripts/`)
- `check-qdrant.sh` - Ensure Qdrant service is running
- `reindex-daily.sh` - Daily incremental reindex
- `reindex-full.sh` - Weekly full reindex
- `generate-embeddings.sh` - Generate vector embeddings
- `sync-indexes.sh` - Sync BM25 and vector indexes

### Business Scripts (`/scripts/`)
- `consolidated-email-processor.sh` - Unified email monitoring (IHS priority + policy-guarded processing)
- `sync-calendar.sh` - Sync calendar events
- `heartbeat-check.sh` - Run HEARTBEAT checks
- `check-deadlines.sh` - Check upcoming deadlines

## Installation

### Method 1: Crontab
```bash
# Backup existing crontab
crontab -l > ~/crontab.backup

# Install new crontab
crontab /Users/clawdia/.openclaw/workspace/cron-jobs.txt
```

### Method 2: Launchd (macOS)
```bash
# Create launchd plist for each job
/Users/clawdia/.openclaw/workspace/scripts/create-launchd-jobs.sh
```

### Method 3: Systemd Timer (Linux)
```bash
# Create systemd timer units
/Users/clawdia/.openclaw/workspace/scripts/create-systemd-timers.sh
```

## Monitoring

### Log Locations
- Cron job logs: `/Users/clawdia/.openclaw/logs/cron/`
- QMD logs: `/Users/clawdia/.openclaw/workspace/skills/qmd/qmd.log`
- System logs: `/Users/clawdia/.openclaw/logs/system/`

### Health Checks
```bash
# Check cron job status
/Users/clawdia/.openclaw/workspace/scripts/check-cron-status.sh

# View recent logs
/Users/clawdia/.openclaw/workspace/scripts/view-cron-logs.sh

# Test all jobs
/Users/clawdia/.openclaw/workspace/scripts/test-cron-jobs.sh
```

## Priority Implementation Order

### Phase 1: Critical Jobs (Immediate)
1. `check-qdrant.sh` - Qdrant service health
2. `heartbeat-check.sh` - System health monitoring
3. `consolidated-email-processor.sh` - IHS Towers-priority email monitoring

### Phase 2: Maintenance Jobs (Week 1)
4. `cleanup-memory.sh` - Memory management
5. `reindex-daily.sh` - QMD daily updates
6. `check-gateway.sh` - OpenClaw gateway health

### Phase 3: Business Jobs (Week 2)
7. `sync-calendar.sh` - Calendar synchronization
8. `check-deadlines.sh` - Deadline reminders
9. `generate-embeddings.sh` - Vector embeddings

### Phase 4: Backup Jobs (Week 3)
10. `backup-workspace.sh` - Regular backups
11. `rotate-logs.sh` - Log management
12. `reindex-full.sh` - Weekly full reindex

## Testing

### Dry Run
```bash
# Test scripts without execution
/Users/clawdia/.openclaw/workspace/scripts/test-all-jobs.sh --dry-run
```

### Manual Execution
```bash
# Run each job manually to verify
for script in /Users/clawdia/.openclaw/workspace/scripts/*.sh; do
    echo "Testing: $(basename $script)"
    bash -n "$script" && echo "✓ Syntax OK" || echo "✗ Syntax error"
done
```

### Integration Test
```bash
# Test full workflow
/Users/clawdia/.openclaw/workspace/scripts/test-integration.sh
```

## Troubleshooting

### Common Issues
1. **Permission errors** - Ensure scripts are executable: `chmod +x *.sh`
2. **Path issues** - Use absolute paths in scripts
3. **Logging failures** - Check log directory permissions
4. **Service dependencies** - Verify Qdrant/OpenClaw are running

### Debug Mode
```bash
# Run with debug output
CRON_DEBUG=1 /Users/clawdia/.openclaw/workspace/scripts/check-qdrant.sh
```

### Notification Setup
Configure notifications for:
- Job failures
- Qdrant service down
- IHS Towers emails detected
- Deadline warnings

## Security Considerations

### File Permissions
```bash
# Set secure permissions
chmod 750 /Users/clawdia/.openclaw/workspace/scripts/*.sh
chmod 640 /Users/clawdia/.openclaw/workspace/cron-jobs.md
```

### Credential Management
- Never store credentials in scripts
- Use environment variables or secure vault
- Rotate API keys regularly

### Audit Logging
```bash
# Enable audit logging
/Users/clawdia/.openclaw/workspace/scripts/enable-audit.sh
```

## Updates
This configuration should be reviewed and updated monthly.

Last updated: 2026-02-27
Next review: 2026-03-27