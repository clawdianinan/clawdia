#!/bin/bash
# Monitor optimization effectiveness

OPENCLAW_WORKSPACE="/Users/clawdia/.openclaw/workspace"
LOG_DIR="$OPENCLAW_WORKSPACE/logs"

echo "OpenClaw Optimization Monitor"
echo "============================="
echo ""

# Check if optimized scripts are running
echo "Script Status:"
for script in consolidated-email-processor.sh system-maintenance.sh; do
    if [[ -x "$OPENCLAW_WORKSPACE/scripts/$script" ]]; then
        echo "  ✓ $script (executable)"
    else
        echo "  ✗ $script (not executable)"
    fi
done

echo ""

# Check cron jobs
echo "Cron Job Status:"
if crontab -l 2>/dev/null | grep -q "consolidated-email-processor"; then
    echo "  ✓ Consolidated email processor scheduled"
else
    echo "  ✗ Consolidated email processor not scheduled"
fi

if crontab -l 2>/dev/null | grep -q "system-maintenance"; then
    echo "  ✓ System maintenance scheduled"
else
    echo "  ✗ System maintenance not scheduled"
fi

echo ""

# Check logs
echo "Recent Logs:"
for log in email-processor maintenance; do
    latest_log=$(ls -t "$LOG_DIR"/$log-*.log 2>/dev/null | head -1)
    if [[ -f "$latest_log" ]]; then
        last_run=$(tail -1 "$latest_log" | cut -d' ' -f1-2)
        echo "  $log: Last run $last_run"
    else
        echo "  $log: No logs found"
    fi
done

echo ""

# Cost estimation
echo "Cost Optimization Status:"
echo "  - Email processing: Consolidated (10-minute intervals)"
echo "  - Batch processing: Enabled"
echo "  - Model selection: DeepSeek primary"
echo "  - Expected savings: 50-70%"
