#!/bin/bash

# Claude Code Integration Script for OpenClaw
# Uses interactive mode (which works) with Ollama qwen3.5:9b

set -e

# Configuration
MODEL="ollama/qwen3.5:9b"
WORKSPACE="${1:-$PWD}"
COMMAND="${2:-}"
SKILL="${3:-}"
DEBUG="${DEBUG:-false}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[Claude Code]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check Claude CLI
    if ! command -v claude &> /dev/null; then
        error "Claude CLI not found. Install with: brew install claude-code"
        return 1
    fi
    success "Claude CLI available"
    
    # Check authentication
    if ! claude auth status 2>/dev/null | grep -q '"loggedIn": true'; then
        warn "Claude not authenticated. Run: claude auth login"
        warn "Will try with Ollama environment variables..."
    else
        success "Claude authenticated"
    fi
    
    # Check Ollama
    if ! command -v ollama &> /dev/null; then
        error "Ollama not found. Install from: https://ollama.com"
        return 1
    fi
    
    if ! ollama list 2>/dev/null | grep -q "qwen3.5:9b"; then
        error "Ollama model qwen3.5:9b not found. Pull with: ollama pull qwen3.5:9b"
        return 1
    fi
    success "Ollama running with qwen3.5:9b"
    
    return 0
}

# Start interactive Claude Code session
start_interactive_session() {
    local workspace="$1"
    
    log "Starting interactive Claude Code session..."
    log "Model: $MODEL"
    log "Workspace: $workspace"
    log ""
    log "📝 Instructions:"
    log "1. When prompted, press '1' to trust the folder"
    log "2. Type your commands at the '❯' prompt"
    log "3. Press Ctrl+D to exit"
    log ""
    
    # Set environment for Ollama
    export ANTHROPIC_API_KEY="ollama"
    export ANTHROPIC_BASE_URL="http://localhost:11434/v1"
    
    # Start Claude Code
    cd "$workspace"
    claude --model "$MODEL" --permission-mode default
}

# Run a single command (using expect for automation)
run_command() {
    local workspace="$1"
    local command="$2"
    local skill="$3"
    
    log "Running command with Claude Code..."
    log "Command: $command"
    [[ -n "$skill" ]] && log "Skill: $skill"
    
    # Create a temporary script for expect
    local expect_script=$(mktemp)
    cat > "$expect_script" << EOF
#!/usr/bin/expect -f
set timeout 30

# Start Claude Code
spawn env ANTHROPIC_API_KEY=ollama ANTHROPIC_BASE_URL=http://localhost:11434/v1 claude --model $MODEL --permission-mode default

# Wait for security prompt
expect "Yes, I trust this folder"
send "1\r"

# Wait for prompt
expect "❯"

# Send command
send "$command\r"

# Wait for response (look for next prompt)
expect {
    "❯" {
        # Got response and new prompt
        set output \$expect_out(buffer)
        send "\x04"  # Ctrl+D to exit
        exp_continue
    }
    timeout {
        send_user "Timeout waiting for response\\n"
        send "\x04"
        exit 1
    }
    eof {
        # Session ended
    }
}

# Capture all output before exit
set output [string trim \$output]
puts "\$output"
EOF
    
    chmod +x "$expect_script"
    
    # Run expect script
    cd "$workspace"
    local output
    output=$(expect -f "$expect_script" 2>/dev/null || true)
    
    # Clean up
    rm -f "$expect_script"
    
    # Extract just the command response (remove prompts)
    echo "$output" | grep -v "❯" | grep -v "Yes, I trust" | grep -v "spawn" | grep -v "expect" | tail -n +3
    
    return 0
}

# Manual mode instructions
manual_mode() {
    log ""
    log "🎯 MANUAL INTERACTIVE MODE (Fallback)"
    log "This is what you've been using successfully:"
    log ""
    log "1. Open terminal and run:"
    log "   ${YELLOW}ANTHROPIC_API_KEY=ollama ANTHROPIC_BASE_URL=http://localhost:11434/v1 \\"
    log "   claude --model ollama/qwen3.5:9b${NC}"
    log ""
    log "2. When prompted, press '1' to trust the folder"
    log "3. Type your commands at the '❯' prompt"
    log "4. Use skills by referencing them:"
    log "   - 'Use code reviewer skill to review this code'"
    log "   - 'Apply React best practices to this component'"
    log "   - 'Use debugging assistant to diagnose this issue'"
    log ""
    log "5. Press Ctrl+D to exit"
    log ""
    log "📁 Skills available in: $PWD/claude-skills/templates/"
}

# Main function
main() {
    echo -e "${BLUE}┌────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│   Claude Code + OpenClaw Integration   │${NC}"
    echo -e "${BLUE}└────────────────────────────────────────┘${NC}"
    echo ""
    
    # Check prerequisites
    if ! check_prerequisites; then
        error "Prerequisites check failed"
        manual_mode
        exit 1
    fi
    
    # Determine mode
    if [[ -z "$COMMAND" ]]; then
        # Interactive mode
        start_interactive_session "$WORKSPACE"
    else
        # Try to run command automatically
        warn "Note: Automated command execution may not work reliably with Ollama"
        warn "Interactive mode is more reliable for Ollama integration"
        echo ""
        
        read -p "Try automated execution? (y/N): " -n 1 -r
        echo ""
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            run_command "$WORKSPACE" "$COMMAND" "$SKILL"
        else
            manual_mode
        fi
    fi
}

# Handle script arguments
case "${1:-}" in
    ""|"interactive")
        # Interactive mode
        WORKSPACE="${2:-$PWD}"
        main
        ;;
    "run")
        # Run command mode
        WORKSPACE="${2:-$PWD}"
        COMMAND="${3:-}"
        SKILL="${4:-}"
        if [[ -z "$COMMAND" ]]; then
            error "Usage: $0 run <workspace> <command> [skill]"
            exit 1
        fi
        main
        ;;
    "test")
        # Test integration
        log "Testing Claude Code integration..."
        if check_prerequisites; then
            success "All prerequisites met!"
            echo ""
            log "Quick test:"
            run_command "$PWD" "Write 'Hello, World!' in Python" "code-reviewer" 2>/dev/null || true
            echo ""
            success "Test completed"
            manual_mode
        fi
        ;;
    "skills")
        # List available skills
        log "Available Claude Code skills:"
        echo ""
        for skill_dir in "$PWD/claude-skills/templates"/*/; do
            if [[ -d "$skill_dir" ]]; then
                skill_name=$(basename "$skill_dir")
                if [[ -f "$skill_dir/meta.json" ]]; then
                    description=$(jq -r '.description' "$skill_dir/meta.json" 2>/dev/null || echo "No description")
                    echo "  • ${GREEN}$skill_name${NC}: $description"
                else
                    echo "  • ${YELLOW}$skill_name${NC}"
                fi
            fi
        done
        echo ""
        log "Use skills by referencing them in your Claude Code prompts"
        ;;
    "help"|"-h"|"--help")
        echo "Claude Code Integration for OpenClaw"
        echo ""
        echo "Usage:"
        echo "  $0 [interactive] [workspace]  - Start interactive session"
        echo "  $0 run <workspace> <command> [skill] - Run single command"
        echo "  $0 test                         - Test integration"
        echo "  $0 skills                       - List available skills"
        echo "  $0 help                         - Show this help"
        echo ""
        echo "Examples:"
        echo "  $0 interactive ~/my-project     # Interactive session"
        echo "  $0 run . \"Review this code\" code-reviewer"
        echo ""
        echo "Note: Interactive mode works best with Ollama."
        echo "Manual fallback always available."
        ;;
    *)
        error "Unknown command: $1"
        echo "Use: $0 help"
        exit 1
        ;;
esac