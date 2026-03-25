#!/bin/bash

# quick-test.sh - Quick functionality test for Claude-Qwen development
# Tests the basic functionality without extensive validation

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Claude-Qwen Development Quick Test ===${NC}"
echo ""

# Test 1: Basic Ollama functionality
echo -e "${BLUE}1. Testing Ollama basic functionality...${NC}"
if ollama list &> /dev/null; then
    echo -e "${GREEN}✅ Ollama responding${NC}"
else
    echo -e "${RED}❌ Ollama not responding${NC}"
    echo "   Try: ollama serve"
    exit 1
fi

# Test 2: Model availability
echo -e "${BLUE}2. Checking Qwen model...${NC}"
if ollama list | grep -q "qwen3.5:9b"; then
    echo -e "${GREEN}✅ Qwen3.5:9b model available${NC}"
else
    echo -e "${YELLOW}⚠️  Qwen3.5:9b model not found${NC}"
    echo "   Run: ollama pull qwen3.5:9b"
    # Continue anyway - might be first run
fi

# Test 3: Claude integration
echo -e "${BLUE}3. Testing Claude integration...${NC}"
if ollama launch --help 2>&1 | grep -q "claude"; then
    echo -e "${GREEN}✅ Claude integration available${NC}"
else
    echo -e "${RED}❌ Claude integration not found${NC}"
    echo "   Update Ollama: ollama update"
    exit 1
fi

# Test 4: Quick command test (non-interactive)
echo -e "${BLUE}4. Quick command test...${NC}"
echo "   Testing: ollama launch claude --model qwen3.5:9b -- \"test\""
timeout 3 ollama launch claude --model qwen3.5:9b -- "test" 2>&1 | \
    grep -q "Launching\|I'm here\|Error: Input" && \
    echo -e "${GREEN}✅ Command works (expected response received)${NC}" || \
    echo -e "${YELLOW}⚠️  Command test inconclusive (may need interactive)${NC}"

# Test 5: Script functionality
echo -e "${BLUE}5. Testing launch script...${NC}"
if [ -f "./launch-claude.sh" ]; then
    if ./launch-claude.sh --help &> /dev/null; then
        echo -e "${GREEN}✅ Launch script works${NC}"
    else
        echo -e "${YELLOW}⚠️  Launch script help not working${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Launch script not found in current directory${NC}"
fi

echo ""
echo -e "${BLUE}=== Quick Test Summary ===${NC}"
echo ""
echo -e "${GREEN}Ready for development if all checks passed.${NC}"
echo ""
echo -e "${BLUE}Usage examples:${NC}"
echo "  Interactive mode:"
echo "    ollama launch claude --model qwen3.5:9b"
echo ""
echo "  With task:"
echo "    ollama launch claude --model qwen3.5:9b -- \"Write a React component\""
echo ""
echo "  Using script:"
echo "    ./launch-claude.sh \"Fix bug in authentication\""
echo ""
echo -e "${YELLOW}Note: First run may take a moment to load the model.${NC}"
echo -e "${YELLOW}For full validation, run: ./validate-setup.sh${NC}"

exit 0