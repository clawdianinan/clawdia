#!/bin/bash

# validate-setup.sh - Validate Claude-Qwen development environment
# Checks all prerequisites for zero-cost development

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
        if [ -n "$3" ]; then
            echo -e "${YELLOW}   Fix: $3${NC}"
        fi
    fi
}

echo -e "${BLUE}=== Claude-Qwen Development Environment Validation ===${NC}"
echo ""

# 1. Check Ollama installation
echo -e "${BLUE}1. Ollama Installation${NC}"
if command -v ollama &> /dev/null; then
    OLLAMA_VERSION=$(ollama --version 2>/dev/null || echo "unknown")
    print_result 0 "Ollama installed ($OLLAMA_VERSION)"
else
    print_result 1 "Ollama not installed" "Install from https://ollama.com/download"
fi

# 2. Check Ollama service
echo -e "${BLUE}2. Ollama Service${NC}"
if ollama list &> /dev/null; then
    print_result 0 "Ollama service running"
else
    print_result 1 "Ollama service not responding" "Run: ollama serve"
fi

# 3. Check Qwen model
echo -e "${BLUE}3. Qwen3.5:9b Model${NC}"
if ollama list | grep -q "qwen3.5:9b"; then
    print_result 0 "Qwen3.5:9b model available"
else
    print_result 1 "Qwen3.5:9b model not found" "Run: ollama pull qwen3.5:9b"
fi

# 4. Check Claude integration
echo -e "${BLUE}4. Claude Integration${NC}"
if ollama launch --help 2>&1 | grep -q "claude"; then
    print_result 0 "Claude integration available"
else
    print_result 1 "Claude integration not found" "Update Ollama: ollama update"
fi

# 5. Check OpenClaw config compliance
echo -e "${BLUE}5. OpenClaw Configuration${NC}"
if [ -f "/Users/clawdia/.openclaw/openclaw.json" ]; then
    if grep -q "ollama" "/Users/clawdia/.openclaw/openclaw.json"; then
        print_result 1 "Ollama configured in OpenClaw (VIOLATION)" "Remove Ollama from OpenClaw config"
    else
        print_result 0 "OpenClaw config compliant (no Ollama)"
    fi
else
    print_result 0 "OpenClaw config file not found (ok)"
fi

# 6. Check command correctness
echo -e "${BLUE}6. Command Validation${NC}"
WRONG_CMD="claude --model qwen3.5:9b"
if command -v claude &> /dev/null; then
    if $WRONG_CMD "test" 2>&1 | grep -q "command not found\|not found"; then
        print_result 0 "'claude --model' correctly fails"
    else
        print_result 1 "'claude --model' might work (unexpected)" "Use 'ollama launch claude --model qwen3.5:9b'"
    fi
else
    print_result 0 "'claude' command not found (correct)"
fi

# 7. Check correct command works
echo -e "${BLUE}7. Correct Command Test${NC}"
timeout 5 ollama launch claude --model qwen3.5:9b -- "test" 2>&1 | grep -q "Launching\|I'm here" && \
    print_result 0 "Correct command works: ollama launch claude --model qwen3.5:9b" || \
    print_result 1 "Correct command test failed" "Check Ollama service and model"

echo ""
echo -e "${BLUE}=== Validation Summary ===${NC}"

# Count results
TOTAL=7
SUCCESS=$(grep -c "✅" <<< "$(tail -$TOTAL)")
FAILURES=$((TOTAL - SUCCESS))

if [ $FAILURES -eq 0 ]; then
    echo -e "${GREEN}🎉 All $TOTAL checks passed! Environment ready for development.${NC}"
    echo ""
    echo -e "${GREEN}Ready to use:${NC}"
    echo "  ./launch-claude.sh \"Your coding task\""
    echo "  ollama launch claude --model qwen3.5:9b"
elif [ $FAILURES -le 2 ]; then
    echo -e "${YELLOW}⚠️  $SUCCESS/$TOTAL checks passed. $FAILURES issues need fixing.${NC}"
    echo ""
    echo -e "${YELLOW}Review the failed checks above and fix before development.${NC}"
else
    echo -e "${RED}❌ Only $SUCCESS/$TOTAL checks passed. $FAILURES critical issues.${NC}"
    echo ""
    echo -e "${RED}Fix all issues before attempting development work.${NC}"
fi

echo ""
echo -e "${BLUE}Next steps after validation:${NC}"
echo "1. Fix any failed checks above"
echo "2. Test with: ./launch-claude.sh \"Write a simple function\""
echo "3. Follow PRDForge workflow: Jira → Code → GitHub → Slack"

exit $FAILURES