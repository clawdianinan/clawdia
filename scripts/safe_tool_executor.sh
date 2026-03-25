#!/bin/bash

# Safe Tool Executor with Context Management
# Prevents context overflow by maintaining buffers

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default context fraction (70% of available context)
MAX_CONTEXT_FRACTION=0.7

print_header() {
    echo -e "${BLUE}==============================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}==============================================${NC}"
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

# Check if context manager is available
check_prerequisites() {
    if ! command -v python3 &> /dev/null; then
        print_error "Python3 is required but not installed"
        exit 1
    fi
    
    CONTEXT_MANAGER="$HOME/.openclaw/workspace/scripts/context_manager.py"
    if [ ! -f "$CONTEXT_MANAGER" ]; then
        print_error "Context manager not found at: $CONTEXT_MANAGER"
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Prepare context file if needed
prepare_context() {
    local task="$1"
    local context_file="$2"
    
    if [ -z "$context_file" ] || [ ! -f "$context_file" ]; then
        # No context file provided
        echo ""
        return
    fi
    
    # Check file size
    file_size=$(stat -f%z "$context_file" 2>/dev/null || stat -c%s "$context_file" 2>/dev/null)
    if [ "$file_size" -gt 1000000 ]; then  # > 1MB
        print_warning "Context file is large ($((file_size/1024))KB). Will be trimmed."
    fi
    
    # Create a safe copy if needed
    safe_context="/tmp/context_$(date +%s).txt"
    cp "$context_file" "$safe_context"
    echo "$safe_context"
}

# Execute tool with context management
execute_with_context() {
    local tool="$1"
    local task="$2"
    local context_file="$3"
    local model="$4"
    
    print_header "SAFE TOOL EXECUTION"
    echo -e "Tool: ${GREEN}$tool${NC}"
    echo -e "Task: $task"
    if [ -n "$context_file" ]; then
        echo -e "Context: $context_file"
    fi
    if [ -n "$model" ]; then
        echo -e "Model: $model"
    fi
    echo ""
    
    # Prepare context
    local safe_context=""
    if [ -n "$context_file" ] && [ -f "$context_file" ]; then
        safe_context=$(prepare_context "$task" "$context_file")
    fi
    
    # Use context manager to prepare safe prompt
    print_header "CONTEXT MANAGEMENT"
    
    if [ -n "$safe_context" ]; then
        echo "Preparing prompt with context management..."
        safe_prompt=$(python3 "$HOME/.openclaw/workspace/scripts/context_manager.py" \
            "$task" "$safe_context" "${model:-auto}")
        
        # Extract just the prepared prompt (after the stats)
        safe_prompt=$(echo "$safe_prompt" | sed -n '/PREPARED PROMPT/,/CONTEXT USAGE STATS/p' | \
            sed '1d' | sed '$d' | sed '$d' | sed '$d' | sed '$d')
        
        echo -e "${GREEN}✓ Prompt prepared with context safety${NC}"
    else
        safe_prompt="$task"
        echo -e "${YELLOW}⚠️  No context file provided - using task only${NC}"
    fi
    
    # Clean up temp file
    if [ -n "$safe_context" ] && [ -f "$safe_context" ]; then
        rm "$safe_context"
    fi
    
    # Execute the tool
    print_header "EXECUTING TOOL"
    
    case $tool in
        claude)
            echo -e "Command: ${YELLOW}claude --print \"[safe prompt]\"${NC}"
            if [ -n "$model" ] && [ "$model" != "auto" ]; then
                claude --print "$safe_prompt" --model "$model"
            else
                claude --print "$safe_prompt"
            fi
            ;;
        cursor|agent)
            echo -e "Command: ${YELLOW}agent chat \"[safe prompt]\"${NC}"
            if [ -n "$model" ] && [ "$model" != "auto" ]; then
                agent chat "$safe_prompt" --model "$model"
            else
                agent chat "$safe_prompt"
            fi
            ;;
        codex)
            echo -e "Command: ${YELLOW}codex \"[safe prompt]\"${NC}"
            codex "$safe_prompt"
            ;;
        gemini)
            echo -e "Command: ${YELLOW}gemini --prompt \"[safe prompt]\"${NC}"
            gemini --prompt "$safe_prompt"
            ;;
        qwen)
            echo -e "Command: ${YELLOW}ollama launch claude --model qwen3.5:9b \"[safe prompt]\"${NC}"
            ollama launch claude --model qwen3.5:9b "$safe_prompt"
            ;;
        *)
            print_error "Unknown tool: $tool"
            echo "Available tools: claude, cursor, codex, gemini, qwen"
            exit 1
            ;;
    esac
    
    print_success "Tool execution completed with context safety"
}

# Main execution
main() {
    check_prerequisites
    
    if [ $# -lt 2 ]; then
        echo "Usage: $0 <tool> <task> [context_file] [model]"
        echo ""
        echo "Tools:"
        echo "  claude    - Claude Code (supports /plan mode)"
        echo "  cursor    - Cursor CLI (agent command, supports /plan mode)"
        echo "  codex     - Codex CLI"
        echo "  gemini    - Gemini CLI"
        echo "  qwen      - Qwen3.5:9b via Claude Code"
        echo ""
        echo "Examples:"
        echo "  $0 claude \"Fix React bug\" code.txt"
        echo "  $0 cursor \"Plan architecture\" README.md composer-2"
        echo "  $0 gemini \"Generate documentation\""
        echo ""
        exit 1
    fi
    
    tool="$1"
    task="$2"
    context_file="${3:-}"
    model="${4:-auto}"
    
    execute_with_context "$tool" "$task" "$context_file" "$model"
}

# Run main function
main "$@"