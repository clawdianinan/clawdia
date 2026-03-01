#!/usr/bin/env bash
set -euo pipefail

OPENCLAW_HOME="/Users/clawdia/.openclaw"
SRC_ROOT="$OPENCLAW_HOME/agents"
DEST_ROOT="$OPENCLAW_HOME/backups/sessions"
STAMP="$(date +%Y-%m-%d)"
DEST_DIR="$DEST_ROOT/$STAMP"
MANIFEST="$DEST_DIR/sha256-manifest.txt"

mkdir -p "$DEST_DIR"

# Multi-agent: include all agents/*/sessions
SESSION_DIRS="$(find "$SRC_ROOT" -type d -path "*/sessions" 2>/dev/null | sort)"

if [[ -z "$SESSION_DIRS" ]]; then
  echo "No session directories found under $SRC_ROOT"
  exit 0
fi

copied=0
while IFS= read -r d; do
  [[ -z "$d" ]] && continue
  agent_name="$(echo "$d" | awk -F'/' '{print $(NF-1)}')"
  target="$DEST_DIR/$agent_name"
  mkdir -p "$target"
  rsync -a --delete "$d/" "$target/"
  copied=$((copied+1))
done <<< "$SESSION_DIRS"

# Build integrity manifest
: > "$MANIFEST"
find "$DEST_DIR" -type f -name '*.jsonl' -print0 | sort -z | while IFS= read -r -d '' f; do
  rel="${f#$DEST_DIR/}"
  hash="$(shasum -a 256 "$f" | awk '{print $1}')"
  echo "$hash  $rel" >> "$MANIFEST"
done

echo "Backup complete: $DEST_DIR"
echo "Session sets copied: $copied"
echo "Manifest: $MANIFEST"
