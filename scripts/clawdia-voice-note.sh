#!/bin/zsh
set -euo pipefail

AUDIO_FILE="${1:-}"
VAULT_ROOT="${CLAWDIA_VAULT_ROOT:-/Users/clawdia/My Drive/Clawdia Documents/ClawdiaVault}"
INBOX_DIR="$VAULT_ROOT/Inbox"
STAMP="$(date '+%Y-%m-%d-%H%M')"

if [[ -z "$AUDIO_FILE" || ! -f "$AUDIO_FILE" ]]; then
  echo "Usage: clawdia-voice-note.sh /path/to/audio.m4a" >&2
  exit 1
fi

mkdir -p "$INBOX_DIR"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

whisper "$AUDIO_FILE" --model turbo --output_format txt --output_dir "$TMP_DIR" >/dev/null 2>&1
TRANSCRIPT_FILE="$TMP_DIR/$(basename "$AUDIO_FILE" | sed 's/\.[^.]*$//').txt"
OUTPUT_FILE="$INBOX_DIR/Voice Note $STAMP.md"

{
  echo "# Voice Note $STAMP"
  echo
  echo "Source: $(basename "$AUDIO_FILE")"
  echo "Created: $(date '+%Y-%m-%d %H:%M')"
  echo
  echo "## Transcript"
  echo
  cat "$TRANSCRIPT_FILE"
  echo
  echo "## Next Actions"
  echo
  echo "- [ ] Review transcript"
  echo "- [ ] Convert useful items into reminders or project notes"
} > "$OUTPUT_FILE"

echo "$OUTPUT_FILE"
