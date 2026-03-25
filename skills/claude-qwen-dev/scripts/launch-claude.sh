#!/bin/bash

# launch-claude.sh - Standardized Claude Code with Qwen3.5:9b launcher
# Enforces PRDForge project rules and provides consistent development workflow

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
MODEL="qwen3.5:9b"
INTEGRATION="claude"

print_header() {
    echo -e "${BLUE}=== Claude-Qwen Development Launcher ===${NC}"
    echo -e "${BLUE}Purpose: Zero-cost development with Claude Code + Qwen3.5:9b${NC}"
    echo ""
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

validate_environment() {
    echo -e "${BLUE}Validating development environment...${NC}"
    
    # Check if Ollama is installed
    if ! command -v ollama &> /dev/null; then
        print_error "Ollama is not installed. Please install Ollama first."
        echo "Visit: https://ollama.com/download"
        exit 1
    fi
    print_success "Ollama installed"
    
    # Check if Ollama is running
    if ! ollama list &> /dev/null; then
        print_warning "Ollama service may not be running. Starting Ollama..."
        ollama serve &
        sleep 3
    fi
    
    # Check if model is available
    if ! ollama list | grep -q "$MODEL"; then
        print_warning "Model $MODEL not found. Pulling..."
        ollama pull "$MODEL"
    fi
    print_success "Model $MODEL available"
    
    # Check if Claude integration is available
    if ! ollama launch --help | grep -q "$INTEGRATION"; then
        print_error "Claude integration not available in Ollama"
        echo "Please update Ollama: ollama update"
        exit 1
    fi
    print_success "Claude integration available"
    
    echo ""
}

check_prdforge_rules() {
    echo -e "${BLUE}Checking PRDForge project rules compliance...${NC}"
    
    # Check if OpenClaw has Ollama configured (should NOT)
    if [ -f "/Users/clawdia/.openclaw/openclaw.json" ]; then
        if grep -q "ollama" "/Users/clawdia/.openclaw/openclaw.json"; then
            print_error "VIOLATION: Ollama configured in OpenClaw (should NOT be)"
            echo "Fix: Remove Ollama from OpenClaw config"
            exit 1
        fi
    fi
    print_success "OpenClaw config compliant (no Ollama)"
    
    # Check for correct command usage
    if [[ "$*" == *"claude --model"* ]]; then
        print_error "VIOLATION: Using 'claude --model' (does NOT work)"
        echo "Fix: Use 'ollama launch claude --model qwen3.5:9b'"
        exit 1
    fi
    print_success "Command syntax correct"
    
    echo ""
}

launch_development() {
    local task="$1"
    
    echo -e "${BLUE}Launching Claude Code with $MODEL...${NC}"
    
    if [ -z "$task" ]; then
        print_warning "No task provided. Launching interactive mode..."
        echo -e "${YELLOW}Interactive Claude Code session starting...${NC}"
        echo -e "${YELLOW}Type your coding tasks directly to Claude Code.${NC}"
        echo ""
        ollama launch "$INTEGRATION" --model "$MODEL"
    else
        print_success "Task: $task"
        echo ""
        echo -e "${YELLOW}Executing task with Claude Code...${NC}"
        ollama launch "$INTEGRATION" --model "$MODEL" -- "$task"
    fi
}

show_usage() {
    echo "Usage: $0 [task]"
    echo ""
    echo "Examples:"
    echo "  $0 \"Fix React component bug in PRDForge\""
    echo "  $0 \"Implement user authentication feature\""
    echo "  $0                          # Interactive mode"
    echo ""
    echo "Environment variables:"
    echo "  MODEL=qwen3.5:9b            # Default model"
    echo "  INTEGRATION=claude          # Default integration"
}

main() {
    print_header
    
    # Parse arguments
    if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        show_usage
        exit 0
    fi
    
    # Validate environment
    validate_environment
    
    # Check PRDForge rules compliance
    check_prdforge_rules "$@"
    
    # Launch development
    launch_development "$*"
    
    echo ""
    print_success "Development session completed"
    echo -e "${BLUE}Remember to:${NC}"
    echo "  1. Commit code to GitHub"
    echo "  2. Update Jira ticket"
    echo "  3. Notify Slack via CHIMAMANDA"
}

# Run main function
main "$@"