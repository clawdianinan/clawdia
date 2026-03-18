#!/bin/bash
# Monitor GPT-OSS Download Progress

echo "📊 GPT-OSS:20B Download Monitor"
echo "================================="

# Check if download is in progress
if ps aux | grep -q "[o]llama pull gpt-oss"; then
    echo "✅ Download in progress"
    echo ""
    echo "Process info:"
    ps aux | grep "[o]llama pull gpt-oss" | grep -v grep
    echo ""
    echo "To check detailed progress, run:"
    echo "  ollama list"
    echo ""
    echo "Estimated time remaining: ~45-60 minutes total"
    echo "Started at: ~4:30 PM"
    echo "Expected completion: ~5:15-5:30 PM"
else
    echo "❌ No active download found"
    echo ""
    echo "Check if download completed:"
    ollama list | grep -i gpt || echo "GPT-OSS not found"
    echo ""
    echo "If not downloaded, start with:"
    echo "  ollama pull gpt-oss:20b"
fi

echo ""
echo "📈 Current Ollama models:"
ollama list 2>/dev/null || echo "No models installed"

echo ""
echo "🚀 Next steps after download:"
echo "1. Run configuration: ./scripts/configure-gpt-oss.sh"
echo "2. Test model: ollama run gpt-oss:20b 'Hello!'"
echo "3. Configure OpenClaw: python3 scripts/configure-gpt-oss.py"
echo "4. Restart OpenClaw: openclaw gateway restart"