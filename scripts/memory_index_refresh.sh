#!/usr/bin/env bash
set -euo pipefail

WS="/Users/clawdia/.openclaw/workspace"
LOG="$WS/logs/memory-index-refresh-$(date +%Y%m%d).log"
mkdir -p "$WS/logs"

log(){ echo "[$(date '+%F %T')] $*" | tee -a "$LOG"; }

log "Starting memory index refresh"

if [[ -x "$WS/skills/qmd/scripts/reindex-daily.sh" ]]; then
  bash "$WS/skills/qmd/scripts/reindex-daily.sh" >>"$LOG" 2>&1 || true
fi

# NOTE: direct qmd.py indexing can crash on this host due to local runtime issues;
# keep refresh stable by relying on reindex script + health verification.
python3 "$WS/scripts/memory_health_check.py" | tee -a "$LOG"
log "Memory index refresh done"
