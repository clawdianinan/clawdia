#!/bin/bash
# One-time setup for GPT-5.3-Codex rate limit fix
# For: Codex usage limit reached, resets Mar 21, 2026 11:33 PM

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SCRIPT="$SCRIPT_DIR/smart_model_fallback.py"
INTEGRATION_SCRIPT="$SCRIPT_DIR/integrate_smart_fallback.sh"

echo "=============================================="
echo "GPT-5.3-Codex Rate Limit Fix Setup"
echo "=============================================="
echo ""
echo "Issue: Codex usage limit reached"
echo "Reset: Mar 21, 2026 11:33 PM (tomorrow night)"
echo ""

# Step 1: Record the rate limit with correct reset time
echo "📝 Step 1: Recording rate limit..."
python3 "$PYTHON_SCRIPT" record \
  "openai-codex/gpt-5.3-codex" \
  "Codex usage limit reached. Limit resets on Mar 21, 2026 11:33 PM. You're out of Codex messages." \
  --retry-after "2026-03-21T23:33:00"

echo ""
echo "✅ Rate limit recorded successfully!"
echo ""

# Step 2: Show current status
echo "📊 Step 2: Current status..."
python3 "$PYTHON_SCRIPT" status

echo ""
echo "=============================================="
echo "Next Steps:"
echo "=============================================="
echo ""
echo "1. The system now knows GPT-5.3-Codex is rate-limited"
echo "2. Best available model: deepseek/deepseek-chat"
echo "3. Rate limit will auto-clear after: 2026-03-21 23:33"
echo ""
echo "To update OpenClaw configuration to use DeepSeek:"
echo "  cd ~/.openclaw/workspace/scripts"
echo "  ./integrate_smart_fallback.sh update"
echo ""
echo "This will:"
echo "  - Make DeepSeek the primary model"
echo "  - Keep GPT-5.3-Codex in fallbacks (at the end)"
echo "  - Restart OpenClaw gateway"
echo ""
echo "To check status anytime:"
echo "  ./integrate_smart_fallback.sh status"
echo ""
echo "After limit resets tomorrow night:"
echo "  ./integrate_smart_fallback.sh clear"
echo "  ./integrate_smart_fallback.sh update"
echo ""
echo "=============================================="