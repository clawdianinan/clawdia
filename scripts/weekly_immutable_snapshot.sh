#!/usr/bin/env bash
set -euo pipefail

OPENCLAW_HOME="/Users/clawdia/.openclaw"
SRC_ROOT="$OPENCLAW_HOME/agents"
SNAP_ROOT="$OPENCLAW_HOME/backups/snapshots"
STAMP="$(date +%Y-%m-%d-%H%M%S)"
SNAP_DIR="$SNAP_ROOT/$STAMP"

mkdir -p "$SNAP_DIR"

# Multi-agent snapshot
rsync -a "$SRC_ROOT/" "$SNAP_DIR/agents/"
rsync -a "/Users/clawdia/.openclaw/workspace/memory/" "$SNAP_DIR/memory/" 2>/dev/null || true
cp -f "/Users/clawdia/.openclaw/workspace/MEMORY.md" "$SNAP_DIR/MEMORY.md" 2>/dev/null || true

# Integrity manifest
MANIFEST="$SNAP_DIR/sha256-manifest.txt"
: > "$MANIFEST"
find "$SNAP_DIR" -type f -print0 | sort -z | while IFS= read -r -d '' f; do
  rel="${f#$SNAP_DIR/}"
  hash="$(shasum -a 256 "$f" | awk '{print $1}')"
  echo "$hash  $rel" >> "$MANIFEST"
done

# Mark immutable best-effort (macOS chflags uchg)
if command -v chflags >/dev/null 2>&1; then
  chflags -R uchg "$SNAP_DIR" || true
fi

echo "Immutable snapshot created: $SNAP_DIR"
