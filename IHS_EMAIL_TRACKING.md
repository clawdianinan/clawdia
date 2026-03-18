# IHS Towers Email Tracking System

## Purpose
Track all emails from @ihstowers.com domains across ALL IIH accounts to prevent missed communications.

## Accounts to Monitor
1. **iih_clawdia** (clawdia.ai@iih.ng) - Default assistant account
2. **iih_temi** (temi.kolawole@iih.ng) - Primary MD account (WHERE IHS EMAILS ACTUALLY ARRIVE)

## Monitoring Protocol

### Daily Check (HEARTBEAT)
```bash
# Run unified monitor
~/.openclaw/workspace/scripts/unified_email_monitor.sh

# Or manually check both accounts
himalaya envelope list -a iih_temi "from @ihstowers.com"
himalaya envelope list -a iih_clawdia "from @ihstowers.com"
```

### Escalation Rules
1. **ANY IHS email** → Immediate triage
2. **Canceled meetings/updates** → Same-day follow-up
3. **Presentation materials** → 24-hour review deadline
4. **Meeting invitations** → 48-hour response deadline

## Failure Prevention

### Technical Safeguards
1. **Cross-account aggregation** - Always check BOTH accounts
2. **Search syntax validation** - Use `from @ihstowers.com` (space, not colon)
3. **Account switching** - Explicit `-a <account>` parameter
4. **Logging** - All checks logged with timestamps

### Process Safeguards
1. **HEARTBEAT integration** - Mandatory in daily checks
2. **Validation step** - Confirm no IHS emails before marking HEARTBEAT_OK
3. **Escalation trigger** - Missed IHS emails = system failure alert

## Recovery Protocol

If IHS emails are missed:
1. **Immediate** - Run unified monitor to assess scope
2. **Triage** - Categorize by urgency/date
3. **Action** - Process oldest/most urgent first
4. **Prevention** - Update monitoring to prevent recurrence

## Last Check Status
- **Last check:** $(date)
- **Accounts checked:** iih_clawdia, iih_temi
- **IHS emails found:** [COUNT]
- **Status:** [OK/ALERT]

## Configuration
Default himalaya accounts in ~/.config/himalaya/config.toml:
```toml
[accounts.iih_clawdia]
# ... existing config

[accounts.iih_temi]  
# ... existing config
```