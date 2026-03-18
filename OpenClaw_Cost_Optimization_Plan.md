# OpenClaw Cost Optimization Plan

## Current Analysis

### Observed Cron Job Patterns (from system messages):
1. **Email Auto-Processor** - Runs every 2-5 minutes (high frequency)
2. **Temi Email Processor** - Runs every 2-5 minutes (high frequency)  
3. **Email Priority Monitor** - Runs every 2-5 minutes (high frequency)
4. **Regular Updates** - Runs periodically
5. **Regular Heartbeat** - Runs periodically

### Cost Drivers:
1. **High-frequency cron jobs** - Multiple similar email processors running concurrently
2. **Redundant processing** - Same emails processed multiple times by different jobs
3. **Large context windows** - Email processing with full content extraction
4. **Model switching** - Multiple model calls per job

## Optimization Strategy

### 1. Cron Job Consolidation

**Current:** 5+ separate cron jobs running every few minutes
**Optimized:** 3 consolidated jobs with staggered scheduling

#### Consolidated Schedule:
```
# Consolidated Email Processing (every 10 minutes)
*/10 * * * * /Users/clawdia/.openclaw/workspace/scripts/consolidated-email-processor.sh

# HEARTBEAT Check (every 30 minutes, aligned with quiet hours)
0,30 * * * * /Users/clawdia/.openclaw/workspace/scripts/heartbeat-check.sh

# System Maintenance (hourly)
0 * * * * /Users/clawdia/.openclaw/workspace/scripts/system-maintenance.sh
```

### 2. Email Processing Optimization

**Current Issues:**
- Multiple jobs processing same emails
- Full email content extraction every time
- No deduplication or caching

**Optimizations:**
1. **Single email processor** - One job handles all email types
2. **Email ID tracking** - Track processed emails to avoid reprocessing
3. **Cached summaries** - Store email summaries for quick reference
4. **Batch processing** - Process multiple emails in single model call

### 3. Model Cost Reduction

**Current:** Multiple model calls per job
**Optimized:** Batch processing and model selection

#### Model Selection Strategy:
1. **Primary:** `deepseek/deepseek-chat` (lower cost)
2. **Fallback:** `openai-codex/gpt-5.3-codex` (only for complex tasks)
3. **Free tier:** `openrouter/nvidia/nemotron-3-nano-30b-a3b:free` for non-critical tasks

#### Batch Processing:
- Group similar tasks (email summaries, todo creation)
- Use single model call for batch
- Implement request queuing

### 4. Context Size Optimization

**Current:** Full email content extraction
**Optimized:** Smart context selection

#### Context Strategies:
1. **First 500 chars** for initial classification
2. **Full content** only when needed (attachments, complex analysis)
3. **Cached embeddings** for similarity matching
4. **Incremental updates** instead of full reprocessing

### 5. HEARTBEAT Alignment

**Current:** Separate heartbeat checks
**Optimized:** Integrated with email processing

#### HEARTBEAT Integration:
1. **Email processing** includes IHS Towers check
2. **Priority monitoring** integrated with main processor
3. **Quiet hours** respected (23:00-08:00)
4. **VIP alerts** trigger immediate escalation

## Implementation Plan

### Phase 1: Cron Consolidation (Immediate)
1. Create consolidated email processor script
2. Update cron schedule
3. Test with reduced frequency

### Phase 2: Email Processing Optimization (Day 1)
1. Implement email ID tracking
2. Add caching layer
3. Create batch processing logic

### Phase 3: Model Optimization (Day 2)
1. Update model selection logic
2. Implement batch processing
3. Add free tier fallback

### Phase 4: Context Optimization (Day 3)
1. Implement smart context selection
2. Add caching for embeddings
3. Create incremental update system

## Script Implementation

### 1. Consolidated Email Processor (`consolidated-email-processor.sh`)

```bash
#!/bin/bash
# Consolidated Email Processor
# Runs every 10 minutes, handles all email types

# Load configuration
source ~/.openclaw/workspace/config.sh

# Check quiet hours (23:00-08:00)
CURRENT_HOUR=$(date +%H)
if [[ $CURRENT_HOUR -ge 23 ]] || [[ $CURRENT_HOUR -lt 8 ]]; then
    echo "Quiet hours - skipping non-urgent processing"
    # Only check for IHS Towers emails during quiet hours
    check_ihs_towers_emails
    exit 0
fi

# Process emails in batch
process_emails_batch() {
    # Get unread emails
    # Process in batches of 5
    # Use deepseek model for classification
    # Batch similar tasks
}

# Check IHS Towers emails (highest priority)
check_ihs_towers_emails() {
    # Immediate escalation for IHS Towers
    # Bypass quiet hours
}

# Main execution
main() {
    echo "Starting consolidated email processing at $(date)"
    
    # Check IHS Towers emails first
    check_ihs_towers_emails
    
    # Process other emails in batch
    process_emails_batch
    
    # Generate summary report
    generate_summary_report
}
```

### 2. HEARTBEAT Check (`heartbeat-check.sh`)

```bash
#!/bin/bash
# HEARTBEAT Check
# Runs every 30 minutes, aligned with quiet hours

# Load HEARTBEAT.md rules
source ~/.openclaw/workspace/HEARTBEAT.md

check_heartbeat_conditions() {
    # Check urgent items
    # Check blocked tasks
    # Check deadline risks
    # Check meeting prep gaps
    # Check unresolved high-priority threads
    
    if [[ $all_clear == "true" ]]; then
        echo "HEARTBEAT_OK"
    else
        # Trigger escalation
        escalate_urgent_items
    fi
}

# Respect quiet hours
CURRENT_HOUR=$(date +%H)
if [[ $CURRENT_HOUR -ge 23 ]] || [[ $CURRENT_HOUR -lt 8 ]]; then
    # Only check for critical items during quiet hours
    check_critical_items_only
else
    # Full HEARTBEAT check during business hours
    check_heartbeat_conditions
fi
```

### 3. System Maintenance (`system-maintenance.sh`)

```bash
#!/bin/bash
# System Maintenance
# Runs hourly

# Memory cleanup
cleanup_old_memory_files() {
    # Remove memory files older than 7 days
    # Keep daily summaries
}

# Cache optimization
optimize_caches() {
    # Clear old cache entries
    # Optimize QMD indexes
    # Clean up temporary files
}

# Model cost reporting
generate_cost_report() {
    # Track model usage
    # Identify cost drivers
    # Generate optimization suggestions
}
```

## Cost Reduction Targets

### Current Estimated Costs:
- **Email processing:** ~10-15 calls/hour × $0.001/call = $0.01-0.015/hour
- **Multiple jobs:** 5× multiplier = $0.05-0.075/hour
- **Daily:** $1.20-1.80/day
- **Monthly:** $36-54/month

### Optimized Target:
- **Consolidated processing:** ~2-3 calls/hour
- **Batch processing:** 5-10 emails/call
- **Model selection:** 80% deepseek, 15% openrouter-free, 5% codex
- **Target cost:** $0.30-0.50/day ($9-15/month)

### Savings Potential:
- **Immediate:** 50% reduction from cron consolidation
- **Short-term:** 70% reduction from batch processing
- **Long-term:** 80%+ reduction with full optimization

## Monitoring and Adjustment

### Key Metrics:
1. **Model calls/hour** - Target: <5
2. **Cost/day** - Target: <$0.50
3. **Processing latency** - Target: <30 seconds
4. **Email coverage** - Target: 100% of urgent emails

### Adjustment Triggers:
1. **Cost increase >20%** - Review model selection
2. **Latency >60 seconds** - Optimize batch size
3. **Missed urgent emails** - Adjust frequency
4. **System errors >5%** - Review scripts

## Rollout Plan

### Week 1: Testing
- Run optimized scripts in parallel
- Compare results with current system
- Validate cost savings

### Week 2: Gradual Rollout
- Replace one cron job at a time
- Monitor for regressions
- Adjust as needed

### Week 3: Full Implementation
- Complete cron consolidation
- Enable all optimizations
- Establish monitoring

### Week 4: Review and Adjust
- Analyze cost savings
- Review processing quality
- Make final adjustments

## Risk Mitigation

### Technical Risks:
1. **Email processing delays** - Maintain fallback to old system
2. **Model availability** - Multiple fallback providers
3. **Script errors** - Comprehensive logging and alerts

### Business Risks:
1. **Missed urgent emails** - Maintain IHS Towers priority check
2. **Processing errors** - Manual review queue
3. **System downtime** - Graceful degradation

## Success Criteria

### Primary Metrics:
1. **Cost reduction:** ≥70% monthly savings
2. **Processing coverage:** 100% urgent emails
3. **System stability:** <1% error rate

### Secondary Metrics:
1. **Processing latency:** <30 seconds average
2. **Model efficiency:** >80% deepseek usage
3. **Cache hit rate:** >60% for repeated emails

## Next Steps

1. **Immediate:** Create consolidated scripts
2. **Day 1:** Test with reduced frequency
3. **Day 2:** Implement batch processing
4. **Day 3:** Deploy optimized cron schedule
5. **Day 4:** Monitor and adjust

## Contact
For issues or adjustments, review cron logs and adjust configuration as needed.

Last updated: 2026-02-27
Next review: 2026-03-06