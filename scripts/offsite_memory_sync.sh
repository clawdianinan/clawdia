#!/usr/bin/env bash
set -euo pipefail

# Google Drive local folder sync (no rclone)
SRC="/Users/clawdia/.openclaw/backups"
TARGET="/Users/clawdia/My Drive/Clawdia Documents/OpenClaw-Backups"

if [[ ! -d "$TARGET" ]]; then
  echo "GDRIVE_SYNC: FAIL - target folder not found: $TARGET"
  exit 1
fi

# Keep mirror current
rsync -a --delete "$SRC/" "$TARGET/"

echo "GDRIVE_SYNC: OK - synced $SRC -> $TARGET"
