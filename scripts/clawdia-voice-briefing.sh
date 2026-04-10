#!/bin/zsh
set -euo pipefail

VOICE="${CLAWDIA_VOICE_NAME:-Samantha}"
RATE="${CLAWDIA_VOICE_RATE:-185}"

if [[ $# -gt 0 ]]; then
  TEXT="$*"
else
  TEXT="$(cat)"
fi

if [[ -z "${TEXT// }" ]]; then
  echo "Usage: clawdia-voice-briefing.sh \"Text to speak\"" >&2
  exit 1
fi

say -v "$VOICE" -r "$RATE" "$TEXT"
