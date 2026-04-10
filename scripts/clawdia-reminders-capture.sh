#!/bin/zsh
set -euo pipefail

TITLE="${1:-}"
DUE="${2:-}"
LIST="${CLAWDIA_REMINDER_LIST:-Clawdia}"

if [[ -z "$TITLE" ]]; then
  echo "Usage: clawdia-reminders-capture.sh \"Title\" [due]" >&2
  exit 1
fi

if [[ -n "$DUE" ]]; then
  remindctl add --title "$TITLE" --list "$LIST" --due "$DUE"
else
  remindctl add --title "$TITLE" --list "$LIST"
fi
