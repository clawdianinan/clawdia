#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$HOME/.openclaw/workspace}"
AGENTS_DIR="$ROOT/agents"
RECOVERY_DIR="$AGENTS_DIR/_recovery"
TEMPLATES_DIR="$RECOVERY_DIR/templates"
INDEX_FILE="$RECOVERY_DIR/agents.index"

if [[ ! -f "$INDEX_FILE" ]]; then
  echo "❌ Missing agents index: $INDEX_FILE"
  echo "Run backup first: bash agents/_recovery/scripts/backup_all_agents.sh"
  exit 1
fi

mkdir -p "$AGENTS_DIR"

while IFS= read -r agent; do
  [[ -z "$agent" ]] && continue
  src="$TEMPLATES_DIR/$agent"
  dst="$AGENTS_DIR/$agent"

  if [[ ! -d "$src" ]]; then
    echo "⚠️ Missing template for $agent, skipping"
    continue
  fi

  mkdir -p "$dst"
  rsync -a "$src/" "$dst/"
  echo "✅ Restored: $agent"
done < "$INDEX_FILE"

echo
echo "Restore complete."
echo "Validate with: ls -la $AGENTS_DIR/<agent-name>"