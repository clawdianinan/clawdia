#!/usr/bin/env bash
set -euo pipefail

# Generic Ollama JSON-safe wrapper
# Works across models that expose "thinking" and break strict JSON parsers.
#
# Usage:
#   echo 'Return JSON with key ok=true' | scripts/ollama_json_safe.sh qwen3:4b
#   scripts/ollama_json_safe.sh qwen3:4b "Return JSON with keys status and value"
#
# Env overrides:
#   OLLAMA_HOST (default: http://127.0.0.1:11434)
#   OLLAMA_TIMEOUT (default: 120)
#   OLLAMA_THINK (default: false)
#   OLLAMA_STREAM (default: false)

MODEL="${1:-qwen3:4b}"
PROMPT="${2:-}"
OLLAMA_HOST="${OLLAMA_HOST:-http://127.0.0.1:11434}"
OLLAMA_TIMEOUT="${OLLAMA_TIMEOUT:-120}"
OLLAMA_THINK="${OLLAMA_THINK:-false}"
OLLAMA_STREAM="${OLLAMA_STREAM:-false}"

if [[ -z "$PROMPT" ]]; then
  PROMPT="$(cat)"
fi

if [[ -z "$PROMPT" ]]; then
  echo "ERROR: no prompt provided" >&2
  exit 2
fi

REQ=$(python3 - "$MODEL" "$OLLAMA_STREAM" "$OLLAMA_THINK" "$PROMPT" <<'PY'
import json, sys
model = sys.argv[1]
stream = sys.argv[2].lower() == 'true'
think = sys.argv[3].lower() == 'true'
prompt = sys.argv[4]
print(json.dumps({
  "model": model,
  "stream": stream,
  "think": think,
  "format": "json",
  "prompt": prompt
}))
PY
)

RAW=$(curl -sS --max-time "$OLLAMA_TIMEOUT" \
  -H 'Content-Type: application/json' \
  -d "$REQ" \
  "$OLLAMA_HOST/api/generate")

# Extract .response and validate it as JSON
RESP=$(python3 - "$RAW" <<'PY'
import json,sys
raw=sys.argv[1]
obj=json.loads(raw)
print(obj.get('response',''))
PY
)

python3 - "$RESP" <<'PY'
import json,sys
text=sys.argv[1].strip()
json.loads(text)
print(text)
PY
