#!/bin/bash
# Unified IHS Towers Email Monitor
# Checks ALL IIH accounts for IHS emails and consolidates results

set -e

LOG_FILE="/tmp/ihs_email_monitor_$(date +%Y%m%d_%H%M%S).log"
ACCOUNTS=("iih_clawdia" "iih_temi")
IHS_DOMAINS="@ihstowers.com"

echo "=== IHS Towers Email Monitor $(date) ===" | tee "$LOG_FILE"

for account in "${ACCOUNTS[@]}"; do
    echo "" | tee -a "$LOG_FILE"
    echo "🔍 Checking account: $account" | tee -a "$LOG_FILE"
    
    # Search for IHS emails in this account
    if himalaya envelope list -a "$account" "from @ihstowers.com" 2>/dev/null | head -20; then
        echo "✅ Found IHS emails in $account" | tee -a "$LOG_FILE"
    else
        echo "❌ No IHS emails found in $account or error" | tee -a "$LOG_FILE"
    fi
done

echo "" | tee -a "$LOG_FILE"
echo "=== Monitor Complete ===" | tee -a "$LOG_FILE"

# Send alert if new IHS emails found
if grep -q "Found IHS emails" "$LOG_FILE"; then
    echo "🚨 ALERT: New IHS emails detected!" | tee -a "$LOG_FILE"
    # Could integrate with OpenClaw notification system here
fi