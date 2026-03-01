#!/usr/bin/env bash
set -euo pipefail

MEM_DIR="/Users/clawdia/.openclaw/workspace/memory"
OUT="/Users/clawdia/.openclaw/workspace/logs/memory-dedupe-report-$(date +%Y%m%d).txt"
mkdir -p /Users/clawdia/.openclaw/workspace/logs

find "$MEM_DIR" -type f -name '*.md' -print0 | xargs -0 shasum -a 256 | sort > "$OUT"

echo "Potential duplicate hashes:" >> "$OUT"
cut -d' ' -f1 "$OUT" | sort | uniq -d | while read -r h; do
  grep "^$h" "$OUT" >> "$OUT"
done

echo "MEMORY_DEDUPE_REPORT: $OUT"
