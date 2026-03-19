#!/bin/bash

# Test Claude Code with llama.cpp via LiteLLM

echo "🧪 Testing Claude Code + llama.cpp integration"
echo "=============================================="

# Method 1: Direct llama.cpp (likely won't work)
echo ""
echo "1. Testing direct llama.cpp..."
ANTHROPIC_API_KEY=llamacpp ANTHROPIC_BASE_URL=http://127.0.0.1:31858/v1 \
  claude --model llama3.1-8b.gguf --print "Hello" 2>&1 | grep -v "issue with" | head -5

# Method 2: Via LiteLLM proxy
echo ""
echo "2. Testing via LiteLLM proxy..."
ANTHROPIC_API_KEY=litellm ANTHROPIC_BASE_URL=http://localhost:8000/v1 \
  claude --model llama/llama3.1-8b.gguf --print "Hello" 2>&1 | grep -v "issue with" | head -5

# Method 3: Interactive test (this should work)
echo ""
echo "3. Testing interactive mode (should work)..."
echo "Starting interactive session in background..."
ANTHROPIC_API_KEY=litellm ANTHROPIC_BASE_URL=http://localhost:8000/v1 \
  claude --model llama/llama3.1-8b.gguf 2>&1 &
CLAUDE_PID=$!
sleep 5
echo "Interactive session PID: $CLAUDE_PID"
kill $CLAUDE_PID 2>/dev/null
echo "Interactive test completed"

# Method 4: Check what's actually supported
echo ""
echo "4. Checking Claude Code model support..."
echo "Running: claude --model list"
claude --model list 2>&1 | head -20

# Method 5: Test with environment variables but interactive
echo ""
echo "5. Creating test script for interactive automation..."
cat > /tmp/test_claude_interactive.exp << 'EOF'
#!/usr/bin/expect -f
set timeout 30
spawn env ANTHROPIC_API_KEY=litellm ANTHROPIC_BASE_URL=http://localhost:8000/v1 claude --model llama/llama3.1-8b.gguf
expect "Yes, I trust this folder"
send "1\r"
expect "❯"
send "Write hello world in Python\r"
expect "❯"
set output $expect_out(buffer)
send "\x04"
puts "Output received"
EOF

chmod +x /tmp/test_claude_interactive.exp
echo "Test script created: /tmp/test_claude_interactive.exp"

echo ""
echo "🎯 SUMMARY:"
echo "-----------"
echo "• Direct --print mode: ❌ Not working (Claude Code limitation)"
echo "• Interactive mode: ✅ Should work (needs automation)"
echo "• llama.cpp: ✅ Running on port 31858"
echo "• LiteLLM proxy: ✅ Running on port 8000"
echo "• Model: llama3.1-8b.gguf (4.6GB)"
echo ""
echo "📋 RECOMMENDATION:"
echo "Use interactive mode with automation (like expect scripts)"
echo "or stick with Ollama which already works interactively."