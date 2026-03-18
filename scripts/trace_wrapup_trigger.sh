#!/bin/bash
# Trace what triggers the evening wrapup

set -e

LOG_FILE="/tmp/wrapup_trigger_trace.log"
WRAPUP_SCRIPT="/Users/clawdia/.openclaw/workspace/evening_wrapup.sh"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

trace_execution() {
    log "=== Wrapup execution detected ==="
    log "Time: $(date '+%H:%M:%S.%N')"
    log "PID: $$"
    log "PPID: $PPID"
    log "Parent command: $(ps -o command= -p $PPID 2>/dev/null || echo 'unknown')"
    log "Call stack:"
    pstree -p $$ >> "$LOG_FILE" 2>/dev/null || log "  pstree not available"
    log "Environment variables related to scheduling:"
    env | grep -i "cron\|schedule\|job\|timer\|launch" >> "$LOG_FILE" 2>/dev/null || log "  none found"
    log "=== End trace ==="
}

# Main execution
main() {
    log "Starting wrapup trigger trace"
    trace_execution
    
    # Run the actual wrapup script
    exec "$WRAPUP_SCRIPT"
}

main "$@"