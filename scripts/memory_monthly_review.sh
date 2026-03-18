#!/usr/bin/env bash
set -euo pipefail

WS="/Users/clawdia/.openclaw/workspace"
OUT="$WS/logs/memory-monthly-review-$(date +%Y%m%d).md"
mkdir -p "$WS/logs"

count=$(find "$WS/memory" -type f -name '*.md' | wc -l | tr -d ' ')
size=$(du -sh "$WS/memory" | awk '{print $1}')

cat > "$OUT" <<EOF
# Memory Monthly Review
Date: $(date)

- Memory files: $count
- Memory dir size: $size
- Health status:
$(python3 "$WS/scripts/memory_health_check.py")

## Recommendations
- Archive low-signal notes older than 90 days.
- Ensure significant decisions are recorded using TEMPLATE_SIGNIFICANT_DECISION.md.
- Review duplicate patterns from dedupe report.

## Model Status
$(bash "$WS/scripts/model_resilience_check.sh" 2>/dev/null || echo "Model check not available")
EOF

echo "MEMORY_MONTHLY_REVIEW: $OUT"
