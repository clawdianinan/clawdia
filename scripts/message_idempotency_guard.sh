#!/usr/bin/env bash
set -euo pipefail

# Usage: message_idempotency_guard.sh <channel> <target> <window_seconds>
# Reads message body from STDIN and exits:
# 0 => message is NEW (safe to send)
# 2 => duplicate within window (skip send)

CHANNEL="${1:-unknown}"
TARGET="${2:-unknown}"
WINDOW="${3:-300}"

STATE_DIR="/Users/clawdia/.openclaw/workspace/.msg-idempotency"
mkdir -p "$STATE_DIR"

BODY="$(cat)"
NORM="$(printf "%s" "$BODY" | tr '\n' ' ' | sed 's/[[:space:]]\+/ /g' | sed 's/^ //; s/ $//')"
KEY_SRC="${CHANNEL}|${TARGET}|${NORM}"
KEY="$(printf "%s" "$KEY_SRC" | shasum -a 256 | awk '{print $1}')"
STAMP_FILE="$STATE_DIR/$KEY"
NOW="$(date +%s)"

# Cleanup stale entries (older than 2 days)
find "$STATE_DIR" -type f -mtime +2 -delete 2>/dev/null || true

if [[ -f "$STAMP_FILE" ]]; then
  LAST="$(cat "$STAMP_FILE" 2>/dev/null || echo 0)"
  if [[ $((NOW - LAST)) -lt $WINDOW ]]; then
    # Log duplicate detection (to stderr to avoid interfering with pipe)
    echo "DUPLICATE_DETECTED: Message to $TARGET via $CHANNEL within ${WINDOW}s window" >&2
    exit 2
  fi
fi

echo "$NOW" > "$STAMP_FILE"
echo "NEW_MESSAGE: Storing idempotency key $KEY" >&2
exit 0
