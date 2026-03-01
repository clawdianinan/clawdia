#!/usr/bin/env bash
set -euo pipefail

# Rollback for Ollama validator integration
# 1) Restore Ops Health Snapshot payload to pre-validator version
# 2) Optionally remove validator helper scripts

echo "[1/2] Restoring Ops Health Snapshot cron payload..."
openclaw cron update --job-id b968812c-67a0-4335-93b3-a088df3f2782 --patch '{
  "payload": {
    "kind": "agentTurn",
    "model": "deepseek/deepseek-chat",
    "message": "Generate ops health snapshot now. Run python3 /Users/clawdia/.openclaw/workspace/scripts/reliability_snapshot.py and summarize key status (memory/email/messaging/cost) in <=8 lines."
  }
}' || true

echo "[2/2] Validator scripts left in place for optional reuse:"
echo "  - scripts/ollama_json_safe.sh"
echo "  - scripts/ollama_validate.py"
echo "  - scripts/ollama_toolcall_test.py"
echo "To remove them: rm -f <files>"

echo "Rollback complete."