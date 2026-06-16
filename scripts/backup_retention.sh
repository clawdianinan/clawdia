#!/usr/bin/env bash
set -euo pipefail

# Backup Retention Script
# Keep maximum 10 backups per category (memory, sessions, snapshots)
# Delete older backups beyond limit

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "=== DRY RUN - No files will be deleted ==="
fi

OPENCLAW_BACKUPS="$HOME/.openclaw/backups"

echo "=== Backup Retention Enforcement ==="
echo "Enforcing maximum 10 backups per category"
if [[ "$DRY_RUN" == true ]]; then
    echo "DRY RUN MODE - No deletions"
fi
echo ""

# Memory backups (tar.gz files)
MEMORY_DIR="$OPENCLAW_BACKUPS/memory"
if [[ -d "$MEMORY_DIR" ]]; then
    echo "Memory backups:"
    # List tar.gz files sorted by modification time (newest first)
    memory_files=($(find "$MEMORY_DIR" -name "memory-backup-*.tar.gz" -type f | xargs -I {} stat -f "%m %N" {} | sort -rn | cut -d' ' -f2-))
    count=${#memory_files[@]}
    echo "  Found $count memory backups"
    if [[ $count -gt 10 ]]; then
        echo "  Keeping 10 newest, deleting $((count - 10)) oldest..."
        for ((i=10; i<count; i++)); do
            file="${memory_files[$i]}"
            echo "    Deleting: $(basename "$file")"
            if [[ "$DRY_RUN" == false ]]; then
                rm -f "$file"
            fi
        done
        echo "  Memory retention applied"
    else
        echo "  No cleanup needed (≤10 backups)"
    fi
fi

echo ""

# Session backups (directories and archive tarballs)
SESSION_DIR="$OPENCLAW_BACKUPS/sessions"
if [[ -d "$SESSION_DIR" ]]; then
    echo "Session backups:"
    # Get all session backups: directories and archive tarballs
    session_items=()
    # Directories (session backup folders)
    while IFS= read -r dir; do
        [[ -n "$dir" ]] && session_items+=("$dir")
    done < <(find "$SESSION_DIR" -maxdepth 1 -type d -name "20*" | xargs -I {} stat -f "%m %N" {} | sort -rn | cut -d' ' -f2-)
    
    # Archive tarballs
    ARCHIVE_DIR="$SESSION_DIR/archive"
    if [[ -d "$ARCHIVE_DIR" ]]; then
        while IFS= read -r tarball; do
            [[ -n "$tarball" ]] && session_items+=("$tarball")
        done < <(find "$ARCHIVE_DIR" -name "*.tar.gz" -type f | xargs -I {} stat -f "%m %N" {} | sort -rn | cut -d' ' -f2-)
    fi
    
    count=${#session_items[@]}
    echo "  Found $count session backups (directories + archives)"
    if [[ $count -gt 10 ]]; then
        echo "  Keeping 10 newest, deleting $((count - 10)) oldest..."
        for ((i=10; i<count; i++)); do
            item="${session_items[$i]}"
            echo "    Deleting: $(basename "$item")"
            if [[ "$DRY_RUN" == false ]]; then
                if [[ -d "$item" ]]; then
                    rm -rf "$item"
                else
                    rm -f "$item"
                fi
            fi
        done
        echo "  Session retention applied"
    else
        echo "  No cleanup needed (≤10 backups)"
    fi
fi

echo ""

# Snapshot backups (immutable snapshot directories)
SNAPSHOT_DIR="$OPENCLAW_BACKUPS/snapshots"
if [[ -d "$SNAPSHOT_DIR" ]]; then
    echo "Snapshot backups:"
    # List snapshot directories sorted by modification time
    snapshot_dirs=($(find "$SNAPSHOT_DIR" -maxdepth 1 -type d -name "20*" | xargs -I {} stat -f "%m %N" {} | sort -rn | cut -d' ' -f2-))
    count=${#snapshot_dirs[@]}
    echo "  Found $count snapshot backups"
    if [[ $count -gt 10 ]]; then
        echo "  Keeping 10 newest, deleting $((count - 10)) oldest..."
        for ((i=10; i<count; i++)); do
            dir="${snapshot_dirs[$i]}"
            echo "    Deleting: $(basename "$dir")"
            if [[ "$DRY_RUN" == false ]]; then
                # Remove immutable flag first (if set)
                if command -v chflags >/dev/null 2>&1; then
                    chflags -R nouchg "$dir" 2>/dev/null || true
                fi
                rm -rf "$dir"
            fi
        done
        echo "  Snapshot retention applied"
    else
        echo "  No cleanup needed (≤10 backups)"
    fi
fi

echo ""
echo "=== Backup Retention Complete ==="
echo "Current backup counts after cleanup:"
echo "  Memory: $(find "$MEMORY_DIR" -name "*.tar.gz" -type f 2>/dev/null | wc -l | tr -d ' ')"
echo "  Sessions: $(find "$SESSION_DIR" -maxdepth 1 -type d -name "20*" 2>/dev/null | wc -l | tr -d ' ')"
if [[ -d "$ARCHIVE_DIR" ]]; then
    echo "  Session archives: $(find "$ARCHIVE_DIR" -name "*.tar.gz" -type f 2>/dev/null | wc -l | tr -d ' ')"
fi
echo "  Snapshots: $(find "$SNAPSHOT_DIR" -maxdepth 1 -type d -name "20*" 2>/dev/null | wc -l | tr -d ' ')"