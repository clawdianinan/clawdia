#!/usr/bin/env bash
set -euo pipefail

BASE="/Users/clawdia/.openclaw/backups/sessions"
ARCHIVE_DIR="$BASE/archive"
mkdir -p "$ARCHIVE_DIR"

# Compress backup folders older than 30 days, keep originals by default for safety.
find "$BASE" -mindepth 1 -maxdepth 1 -type d -name "20*" -mtime +30 | while read -r d; do
  b="$(basename "$d")"
  tarfile="$ARCHIVE_DIR/${b}.tar.gz"
  if [[ ! -f "$tarfile" ]]; then
    tar -czf "$tarfile" -C "$BASE" "$b"
    echo "ARCHIVED: $b -> $tarfile"
  fi
done

echo "RETENTION: OK"
