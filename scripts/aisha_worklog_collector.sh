#!/bin/bash
# Aisha Work Log — scheduled collector.
# Rebuilds the append-only work log from all sources and writes the daily digest.
# Idempotent: safe to run repeatedly; never duplicates entries.

set -uo pipefail

WORKSPACE="/Users/clawdia/.openclaw/workspace"
SCRIPT="$WORKSPACE/scripts/aisha_work_log.py"
LOG_DIR="$WORKSPACE/logs/aisha-worklog"
mkdir -p "$LOG_DIR"

STAMP=$(date +%Y-%m-%d)
OUT="$LOG_DIR/collector.log"

{
  echo "=== $(date '+%Y-%m-%d %H:%M:%S %Z') ==="
  /usr/bin/python3 "$SCRIPT" build --since "$(date -v-7d +%Y-%m-%d)" 2>&1 | tail -20
  echo "--- digest $STAMP ---"
  /usr/bin/python3 "$SCRIPT" digest "$STAMP" >/dev/null 2>&1 && echo "digest written: $STAMP.md"
  echo "--- integrity ---"
  /usr/bin/python3 "$SCRIPT" verify 2>&1
} >> "$OUT" 2>&1

# keep the collector log bounded
tail -n 2000 "$OUT" > "$OUT.tmp" && mv "$OUT.tmp" "$OUT"
