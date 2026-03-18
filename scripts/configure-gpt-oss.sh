#!/bin/bash
# GPT-OSS OpenClaw Configuration Script

set -e

echo "🔍 Checking if GPT-OSS is downloaded..."
if ollama list | grep -q "gpt-oss"; then
    echo "✅ GPT-OSS found in Ollama"
    
    echo "📝 Updating OpenClaw configuration..."
    python3 /Users/clawdia/.openclaw/workspace/scripts/configure-gpt-oss.py
    
    echo ""
    echo "🎉 Configuration complete!"
    echo ""
    echo "Quick test:"
    echo "  ollama run gpt-oss:20b 'What is 2+2?'"
    echo ""
    echo "OpenClaw test:"
    echo "  openclaw chat --model ollama/gpt-oss:20b 'Hello from GPT-OSS!'"
else
    echo "❌ GPT-OSS not found in Ollama"
    echo ""
    echo "Download it first:"
    echo "  ollama pull gpt-oss:20b"
    echo ""
    echo "Check download progress:"
    echo "  ps aux | grep 'ollama pull'"
    echo ""
    echo "Current download status:"
    ollama list
fi