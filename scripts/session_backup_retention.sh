#!/usr/bin/env bash
set -euo pipefail

BASE="/Users/clawdia/.openclaw/backups/sessions"
ARCHIVE_DIR="$BASE/archive"
mkdir -p "$ARCHIVE_DIR"

# 1. Archive directories older than 30 days and delete originals
echo "Archiving session backups older than 30 days..."
find "$BASE" -mindepth 1 -maxdepth 1 -type d -name "20*" -mtime +30 | while read -r d; do
  b="$(basename "$d")"
  tarfile="$ARCHIVE_DIR/${b}.tar.gz"
  if [[ ! -f "$tarfile" ]]; then
    tar -czf "$tarfile" -C "$BASE" "$b"
    echo "ARCHIVED: $b -> $tarfile"
    # Delete original directory after successful archiving
    rm -rf "$d"
    echo "  Deleted original directory: $b"
  fi
done

# 2. Enforce maximum 10 session backups total (directories + archives)
echo "\nEnforcing maximum 10 session backups total..."
session_items=()
# Directories (session backup folders)
while IFS= read -r dir; do
    [[ -n "$dir" ]] && session_items+=("$dir")
done < <(find "$BASE" -maxdepth 1 -type d -name "20*" | xargs -I {} stat -f "%m %N" {} | sort -rn | cut -d' ' -f2-)

# Archive tarballs
while IFS= read -r tarball; do
    [[ -n "$tarball" ]] && session_items+=("$tarball")
done < <(find "$ARCHIVE_DIR" -name "*.tar.gz" -type f | xargs -I {} stat -f "%m %N" {} | sort -rn | cut -d' ' -f2-)

count=${#session_items[@]}
echo "Found $count session backups (directories + archives)"
if [[ $count -gt 10 ]]; then
    echo "Keeping 10 newest, deleting $((count - 10)) oldest..."
    for ((i=10; i<count; i++)); do
        item="${session_items[$i]}"
        echo "  Deleting: $(basename "$item")"
        if [[ -d "$item" ]]; then
            rm -rf "$item"
        else
            rm -f "$item"
        fi
    done
    echo "Session retention applied"
else
    echo "No cleanup needed (≤10 backups)"
fi

echo "\nRETENTION: OK"
