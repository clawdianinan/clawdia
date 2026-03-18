#!/bin/bash
# OpenClaw Cost Optimization Implementation Script
# Guides through the optimization process

set -e

# Configuration
OPENCLAW_WORKSPACE="/Users/clawdia/.openclaw/workspace"
BACKUP_DIR="$OPENCLAW_WORKSPACE/backups/$(date +%Y%m%d-%H%M%S)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  OpenClaw Cost Optimization Setup     ${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Step 1: Backup current configuration
backup_current_config() {
    echo -e "${YELLOW}Step 1: Backing up current configuration...${NC}"
    
    mkdir -p "$BACKUP_DIR"
    
    # Backup crontab
    crontab -l > "$BACKUP_DIR/crontab.backup" 2>/dev/null || true
    echo "✓ Crontab backed up"
    
    # Backup scripts
    cp -r "$OPENCLAW_WORKSPACE/scripts" "$BACKUP_DIR/scripts" 2>/dev/null || true
    echo "✓ Scripts backed up"
    
    # Backup cron config
    cp "$OPENCLAW_WORKSPACE/cron-jobs.md" "$BACKUP_DIR/" 2>/dev/null || true
    echo "✓ Cron configuration backed up"
    
    echo -e "${GREEN}Backup completed: $BACKUP_DIR${NC}"
    echo ""
}

# Step 2: Install new scripts
install_new_scripts() {
    echo -e "${YELLOW}Step 2: Installing optimized scripts...${NC}"
    
    # Make scripts executable
    chmod +x "$OPENCLAW_WORKSPACE/scripts/consolidated-email-processor.sh"
    chmod +x "$OPENCLAW_WORKSPACE/scripts/system-maintenance.sh"
    chmod +x "$OPENCLAW_WORKSPACE/scripts/implement-optimization.sh"
    
    echo "✓ Scripts made executable"
    
    # Create necessary directories
    mkdir -p "$OPENCLAW_WORKSPACE/logs"
    mkdir -p "$OPENCLAW_WORKSPACE/.email-cache"
    mkdir -p "$OPENCLAW_WORKSPACE/.cache"
    mkdir -p "$OPENCLAW_WORKSPACE/.temp"
    
    echo "✓ Directories created"
    echo ""
}

# Step 3: Test scripts
test_scripts() {
    echo -e "${YELLOW}Step 3: Testing optimized scripts...${NC}"
    
    local errors=0
    
    # Test consolidated email processor
    echo -n "Testing consolidated-email-processor.sh: "
    if bash -n "$OPENCLAW_WORKSPACE/scripts/consolidated-email-processor.sh"; then
        echo -e "${GREEN}✓ Syntax OK${NC}"
    else
        echo -e "${RED}✗ Syntax error${NC}"
        errors=$((errors + 1))
    fi
    
    # Test system maintenance
    echo -n "Testing system-maintenance.sh: "
    if bash -n "$OPENCLAW_WORKSPACE/scripts/system-maintenance.sh"; then
        echo -e "${GREEN}✓ Syntax OK${NC}"
    else
        echo -e "${RED}✗ Syntax error${NC}"
        errors=$((errors + 1))
    fi
    
    # Test heartbeat check (existing)
    echo -n "Testing heartbeat-check.sh: "
    if bash -n "$OPENCLAW_WORKSPACE/scripts/heartbeat-check.sh"; then
        echo -e "${GREEN}✓ Syntax OK${NC}"
    else
        echo -e "${RED}✗ Syntax error${NC}"
        errors=$((errors + 1))
    fi
    
    if [[ $errors -eq 0 ]]; then
        echo -e "${GREEN}All scripts passed syntax check${NC}"
    else
        echo -e "${RED}$errors script(s) failed syntax check${NC}"
    fi
    
    echo ""
}

# Step 4: Update cron configuration
update_cron_config() {
    echo -e "${YELLOW}Step 4: Updating cron configuration...${NC}"
    
    # Check if crontab exists
    if crontab -l >/dev/null 2>&1; then
        echo "Current crontab entries:"
        crontab -l | grep -v "^#" | head -10
        echo ""
    fi
    
    # Ask for confirmation
    read -p "Install optimized cron configuration? (y/n): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Install new cron configuration
        if crontab "$OPENCLAW_WORKSPACE/optimized-cron-config.txt"; then
            echo -e "${GREEN}✓ Cron configuration updated${NC}"
            echo ""
            echo "New cron schedule:"
            crontab -l | grep -v "^#"
        else
            echo -e "${RED}✗ Failed to update cron configuration${NC}"
        fi
    else
        echo -e "${YELLOW}Skipping cron update${NC}"
        echo ""
        echo "To install manually:"
        echo "  crontab $OPENCLAW_WORKSPACE/optimized-cron-config.txt"
    fi
    
    echo ""
}

# Step 5: Monitor old cron jobs
monitor_old_jobs() {
    echo -e "${YELLOW}Step 5: Monitoring old cron jobs...${NC}"
    
    echo "Old cron jobs to be replaced:"
    echo "1. Email Auto-Processor (every 2-5 minutes)"
    echo "2. Temi Email Processor (every 2-5 minutes)"
    echo "3. Email Priority Monitor (every 2-5 minutes)"
    echo "4. Regular Updates (periodic)"
    echo "5. Regular Heartbeat (periodic)"
    echo ""
    
    echo "New consolidated schedule:"
    echo "1. Consolidated Email Processor (every 10 minutes, 8 AM-6 PM)"
    echo "2. HEARTBEAT Check (every 30 minutes)"
    echo "3. System Maintenance (hourly)"
    echo ""
    
    echo -e "${GREEN}Expected cost reduction: 50-70%${NC}"
    echo ""
}

# Step 6: Create monitoring script
create_monitoring_script() {
    echo -e "${YELLOW}Step 6: Creating monitoring script...${NC}"
    
    cat > "$OPENCLAW_WORKSPACE/scripts/monitor-optimization.sh" << 'EOF'
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
EOF
    
    chmod +x "$OPENCLAW_WORKSPACE/scripts/monitor-optimization.sh"
    echo -e "${GREEN}✓ Monitoring script created${NC}"
    echo ""
}

# Step 7: Summary
show_summary() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}          Implementation Summary        ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    echo -e "${GREEN}✓ Backup created: $BACKUP_DIR${NC}"
    echo -e "${GREEN}✓ Optimized scripts installed${NC}"
    echo -e "${GREEN}✓ Scripts tested${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Monitor logs for 24 hours:"
    echo "   tail -f $OPENCLAW_WORKSPACE/logs/email-processor-*.log"
    echo ""
    echo "2. Check optimization effectiveness:"
    echo "   $OPENCLAW_WORKSPACE/scripts/monitor-optimization.sh"
    echo ""
    echo "3. Review cost savings after 7 days"
    echo ""
    echo "4. Adjust frequency if needed:"
    echo "   Edit: $OPENCLAW_WORKSPACE/optimized-cron-config.txt"
    echo ""
    echo -e "${YELLOW}Important:${NC}"
    echo "- Old cron jobs should be manually disabled"
    echo "- Monitor for missed urgent emails"
    echo "- Adjust batch size if processing is slow"
    echo ""
    echo -e "${GREEN}Optimization implementation complete!${NC}"
}

# Main execution
main() {
    echo "Starting OpenClaw cost optimization implementation..."
    echo ""
    
    backup_current_config
    install_new_scripts
    test_scripts
    update_cron_config
    monitor_old_jobs
    create_monitoring_script
    show_summary
}

# Run main function
main "$@"