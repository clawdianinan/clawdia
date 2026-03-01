#!/usr/bin/env bash
set -euo pipefail

WS="/Users/clawdia/.openclaw/workspace"
LOG="$WS/logs/memory-index-refresh-$(date +%Y%m%d).log"
mkdir -p "$WS/logs"

log(){ echo "[$(date '+%F %T')] $*" | tee -a "$LOG"; }

log "Starting memory index refresh"

if [[ -x "$WS/skills/qmd/scripts/reindex-daily.sh" ]]; then
  bash "$WS/skills/qmd/scripts/reindex-daily.sh" >>"$LOG" 2>&1 || true
else
  log "reindex-daily.sh not found; running direct BM25 index refresh"
  (cd "$WS/skills/qmd" && python3 qmd.py index --path "$WS/memory") >>"$LOG" 2>&1 || true
fi

python3 "$WS/scripts/memory_health_check.py" | tee -a "$LOG"
log "Memory index refresh done"
