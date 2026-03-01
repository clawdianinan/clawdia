#!/usr/bin/env bash
set -euo pipefail

# Optional offsite sync for backups (requires user-configured target)
# Example target: rclone remote 'secure-backup:openclaw-backups'
TARGET_FILE="/Users/clawdia/.openclaw/workspace/.offsite-backup-target"
SRC="/Users/clawdia/.openclaw/backups"

if [[ ! -f "$TARGET_FILE" ]]; then
  echo "OFFSITE_SYNC: SKIP - no target configured (create $TARGET_FILE)"
  exit 0
fi

TARGET="$(cat "$TARGET_FILE" | tr -d '[:space:]')"
if [[ -z "$TARGET" ]]; then
  echo "OFFSITE_SYNC: SKIP - empty target"
  exit 0
fi

if ! command -v rclone >/dev/null 2>&1; then
  echo "OFFSITE_SYNC: FAIL - rclone not installed"
  exit 1
fi

rclone sync "$SRC" "$TARGET" --transfers 4 --checkers 8 --create-empty-src-dirs

echo "OFFSITE_SYNC: OK - synced $SRC -> $TARGET"
