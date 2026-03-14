#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$HOME/.openclaw/workspace}"
SRC="$ROOT/agents/_recovery/templates"
DST="$ROOT/agents"

if [[ ! -d "$SRC/sheba" || ! -d "$SRC/fela" ]]; then
  echo "❌ Recovery templates not found in: $SRC"
  exit 1
fi

mkdir -p "$DST/sheba" "$DST/fela"

for agent in sheba fela; do
  cp "$SRC/$agent/IDENTITY.md"  "$DST/$agent/IDENTITY.md"
  cp "$SRC/$agent/SOUL.md"      "$DST/$agent/SOUL.md"
  cp "$SRC/$agent/MEMORY.md"    "$DST/$agent/MEMORY.md"
  cp "$SRC/$agent/TOOLS.md"     "$DST/$agent/TOOLS.md"
  cp "$SRC/$agent/TASKS.md"     "$DST/$agent/TASKS.md"
  cp "$SRC/$agent/HEARTBEAT.md" "$DST/$agent/HEARTBEAT.md"
  echo "✅ Restored $agent core profile files"
done

echo

echo "Done. Validate with:"
echo "  ls -la $DST/sheba"
echo "  ls -la $DST/fela"
