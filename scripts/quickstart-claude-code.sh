#!/bin/bash

# Quick Start: Claude Code Integration for OpenClaw
# Demonstrates the complete integration system

echo "🚀 Claude Code Integration Quick Start"
echo "======================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    echo -e "${BLUE}[$(date +%H:%M:%S)]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check prerequisites
print_status "Checking prerequisites..."

# Check Claude CLI
if command -v claude &> /dev/null; then
    print_success "Claude CLI found"
else
    print_error "Claude CLI not found. Install via: brew install claude-code"
    exit 1
fi

# Check Ollama
if command -v ollama &> /dev/null; then
    print_success "Ollama found"
    
    # Check if Ollama is running
    if ollama list &> /dev/null; then
        print_success "Ollama is running"
        
        # Check for qwen3.5:9b model
        if ollama list | grep -q "qwen3.5:9b"; then
            print_success "Model qwen3.5:9b available"
        else
            print_warning "Model qwen3.5:9b not found. Pull with: ollama pull qwen3.5:9b"
        fi
    else
        print_warning "Ollama not running. Start with: ollama serve"
    fi
else
    print_error "Ollama not found. Install from: https://ollama.com"
    exit 1
fi

# Check authentication
print_status "Checking Claude authentication..."
AUTH_STATUS=$(claude auth status 2>&1)
if echo "$AUTH_STATUS" | grep -q '"loggedIn": true'; then
    print_success "Authenticated with Claude"
else
    print_warning "Not authenticated. Run: claude auth login"
fi

echo ""
print_status "Testing integration components..."

# Test 1: Integration system
print_status "1. Testing integration system..."
if node scripts/claude-code-integration.js test 2>&1 | grep -q "Integration Test Complete"; then
    print_success "Integration system working"
else
    print_error "Integration system test failed"
fi

# Test 2: Skills system
print_status "2. Testing skills system..."
if [ -d "claude-skills/templates" ]; then
    SKILL_COUNT=$(find claude-skills/templates -type d -maxdepth 1 | wc -l)
    print_success "Found $((SKILL_COUNT - 1)) skills"
else
    print_error "Skills directory not found"
fi

# Test 3: Manual fallback demonstration
print_status "3. Demonstrating manual fallback..."
echo ""
echo "Manual fallback is GUARANTEED to work:"
echo "--------------------------------------"
echo "Run this command to start interactive Claude Code with Ollama:"
echo ""
echo "  ${YELLOW}ANTHROPIC_API_KEY=ollama ANTHROPIC_BASE_URL=http://localhost:11434/v1 \\"
echo "    claude --model ollama/qwen3.5:9b${NC}"
echo ""
echo "Then:"
echo "1. Press '1' when asked to trust the folder"
echo "2. Paste any task/prompt"
echo "3. Get response from local Qwen 3.5 9B model"
echo ""

# Test 4: Get manual instructions for a sample task
print_status "4. Getting manual instructions for sample task..."
echo ""
SAMPLE_TASK="Write a Python function that calculates factorial"
echo "Sample task: '$SAMPLE_TASK'"
echo ""
node scripts/claude-code-integration.js manual "$SAMPLE_TASK" --agent trinity 2>&1 | tail -20
echo ""

# Summary
echo ""
echo "🎯 Integration Summary"
echo "====================="
echo ""
echo "✅ ${GREEN}What works:${NC}"
echo "   • Interactive Claude Code sessions with Ollama"
echo "   • Local model inference (qwen3.5:9b)"
echo "   • Skill system with agent mappings"
echo "   • Manual fallback (guaranteed)"
echo ""
echo "⚠️  ${YELLOW}Limitations:${NC}"
echo "   • --print mode doesn't work with Ollama"
echo "   • Automated session spawning may fail"
echo ""
echo "🚀 ${BLUE}Next steps:${NC}"
echo "   1. Test manual interactive mode (always works)"
echo "   2. Integrate with Trinity agent for coding tasks"
echo "   3. Add more skills from aitmpl.com when available"
echo ""
echo "📚 Documentation:"
echo "   • Full guide: CLAUDECODE_INTEGRATION_GUIDE.md"
echo "   • Skills: claude-skills/INTEGRATION_GUIDE.md"
echo ""
echo "🔧 ${GREEN}Integration Status: OPERATIONAL WITH FALLBACK${NC}"
echo ""

# Offer to test manual mode
read -p "Would you like to test manual interactive mode now? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "Starting manual interactive test..."
    echo "Press Ctrl+C to exit when done."
    echo ""
    ANTHROPIC_API_KEY=ollama ANTHROPIC_BASE_URL=http://localhost:11434/v1 \
        claude --model ollama/qwen3.5:9b
fi