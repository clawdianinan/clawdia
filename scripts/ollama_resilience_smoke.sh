#!/usr/bin/env bash
set -euo pipefail

# Ollama resilience smoke test with retry + model fallback
# Output is concise and machine/agent readable.

WS="/Users/clawdia/.openclaw/workspace"
VALIDATOR="$WS/scripts/ollama_validate.py"
TOOLTEST="$WS/scripts/ollama_toolcall_test.py"

RETRIES="${OLLAMA_RETRIES:-2}"
# Preferred order; any unavailable model is skipped.
PREFERRED_MODELS=(qwen3:4b llama3.2:3b mistral:7b)

INSTALLED=()
while IFS= read -r line; do
  [[ -n "$line" ]] && INSTALLED+=("$line")
done < <(ollama list 2>/dev/null | awk 'NR>1 {print $1}')
if [[ ${#INSTALLED[@]} -eq 0 ]]; then
  echo "OLLAMA_RESILIENCE_FAIL: no installed models"
  exit 2
fi

# Build fallback chain from preferred intersection + first installed catch-all
MODELS=()
for m in "${PREFERRED_MODELS[@]}"; do
  for i in "${INSTALLED[@]}"; do
    [[ "$m" == "$i" ]] && MODELS+=("$m")
  done
done

# ensure at least one model
if [[ ${#MODELS[@]} -eq 0 ]]; then
  MODELS+=("${INSTALLED[0]}")
fi

json_prompt='Return strict JSON: {"status":"ok","value":42}'

attempt_model() {
  local model="$1"
  local try=1
  while (( try <= RETRIES )); do
    if python3 "$VALIDATOR" --model "$model" --prompt "$json_prompt" --require status --require value --expect status:string --expect value:number >/tmp/ollama-validate.out 2>/tmp/ollama-validate.err; then
      if python3 "$TOOLTEST" >/tmp/ollama-tool.out 2>/tmp/ollama-tool.err; then
        echo "OLLAMA_RESILIENCE_OK: model=$model try=$try"
        return 0
      fi
    fi
    ((try++))
  done
  return 1
}

for m in "${MODELS[@]}"; do
  if attempt_model "$m"; then
    exit 0
  fi
done

echo "OLLAMA_RESILIENCE_FAIL: all models/retries exhausted"
# Print concise diagnostics
[[ -f /tmp/ollama-validate.err ]] && echo "VALIDATOR_ERR: $(tail -n 1 /tmp/ollama-validate.err)"
[[ -f /tmp/ollama-tool.err ]] && echo "TOOLCALL_ERR: $(tail -n 1 /tmp/ollama-tool.err)"
exit 1
