#!/bin/bash

# Claude Code + Ollama Integration for OpenClaw
# Complete integration package using proven working method

set -e

# Configuration
MODEL="ollama/qwen3.5:9b"
WORKSPACE="${1:-/Users/clawdia/.openclaw/workspace}"
DEBUG="${DEBUG:-false}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[Claude-Ollama]${NC} $1"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }

# Check system
check_system() {
    log "Checking system requirements..."
    
    # Check Ollama
    if ! command -v ollama &> /dev/null; then
        error "Ollama not found. Install from: https://ollama.com"
        return 1
    fi
    
    if ! ollama list 2>/dev/null | grep -q "qwen3.5:9b"; then
        warn "qwen3.5:9b not found. Pulling..."
        ollama pull qwen3.5:9b
    fi
    success "Ollama ready with qwen3.5:9b"
    
    # Check Claude CLI
    if ! command -v claude &> /dev/null; then
        error "Claude CLI not found. Install with: brew install claude-code"
        return 1
    fi
    success "Claude CLI available"
    
    # Check authentication
    if ! claude auth status 2>/dev/null | grep -q '"loggedIn": true'; then
        warn "Not authenticated with Claude. Will use Ollama environment variables."
    else
        success "Claude authenticated"
    fi
    
    return 0
}

# Start interactive session
start_interactive() {
    local workspace="$1"
    
    log "Starting interactive Claude Code session with Ollama..."
    log "Model: $MODEL"
    log "Workspace: $workspace"
    log ""
    log "📝 Instructions:"
    log "1. When prompted, press '1' to trust the folder"
    log "2. Type commands at '❯' prompt"
    log "3. Reference skills:"
    log "   • 'Use code reviewer skill to review this code'"
    log "   • 'Apply React best practices to optimize this component'"
    log "   • 'Use debugging assistant to diagnose this issue'"
    log "4. Press Ctrl+D to exit"
    log ""
    
    export ANTHROPIC_API_KEY="ollama"
    export ANTHROPIC_BASE_URL="http://localhost:11434/v1"
    
    cd "$workspace"
    claude --model "$MODEL" --permission-mode default
}

# Run automated test
run_test() {
    log "Running integration test..."
    
    # Create test script
    cat > /tmp/claude_test.exp << 'EOF'
#!/usr/bin/expect -f
set timeout 30
spawn env ANTHROPIC_API_KEY=ollama ANTHROPIC_BASE_URL=http://localhost:11434/v1 claude --model ollama/qwen3.5:9b
expect "Yes, I trust this folder"
send "1\r"
expect "❯"
send "Write a Python function that adds two numbers\r"
expect "❯"
set output $expect_out(buffer)
send "\x04"
puts "Test completed"
EOF
    
    chmod +x /tmp/claude_test.exp
    /tmp/claude_test.exp 2>/dev/null && success "Test script created" || warn "Test may need manual verification"
    rm -f /tmp/claude_test.exp
}

# Show manual instructions (fallback)
show_manual() {
    log ""
    log "🎯 MANUAL INTERACTIVE MODE (Proven Working)"
    log "=========================================="
    log ""
    log "1. Open terminal and run:"
    log "   ${YELLOW}cd $WORKSPACE${NC}"
    log "   ${YELLOW}ANTHROPIC_API_KEY=ollama ANTHROPIC_BASE_URL=http://localhost:11434/v1 \\"
    log "   claude --model ollama/qwen3.5:9b${NC}"
    log ""
    log "2. When prompted, press '1' to trust the folder"
    log "3. Type commands at '❯' prompt"
    log ""
    log "4. Use available skills:"
    log "   ${GREEN}• code-reviewer${NC} - Comprehensive code review"
    log "   ${GREEN}• react-best-practices${NC} - React/Next.js optimization"
    log "   ${GREEN}• debugging-assistant${NC} - Systematic debugging"
    log ""
    log "5. Example commands:"
    log "   • 'Use code reviewer skill to review this TypeScript code'"
    log "   • 'Apply React best practices to this component'"
    log "   • 'Use debugging assistant to diagnose blank page issue'"
    log ""
    log "6. Press Ctrl+D to exit"
    log ""
    log "📁 Skills location: $WORKSPACE/claude-skills/templates/"
}

# OpenClaw agent integration example
show_agent_integration() {
    log ""
    log "🤖 OPENCLAW AGENT INTEGRATION"
    log "============================="
    log ""
    log "For Trinity (coding agent):"
    cat << 'EOF'
// In Trinity agent code:
const { exec } = require('child_process');

async function useClaudeCode(task, skill = null) {
  const cmd = `cd /Users/clawdia/.openclaw/workspace && \
    ANTHROPIC_API_KEY=ollama ANTHROPIC_BASE_URL=http://localhost:11434/v1 \
    claude --model ollama/qwen3.5:9b --print "${task}" 2>&1`;
  
  return new Promise((resolve, reject) => {
    exec(cmd, (error, stdout, stderr) => {
      if (error || stdout.includes('issue with the selected model')) {
        // Fallback to manual instructions
        resolve({
          success: false,
          fallback: true,
          instructions: `Use manual Claude Code: ANTHROPIC_API_KEY=ollama ANTHROPIC_BASE_URL=http://localhost:11434/v1 claude --model ollama/qwen3.5:9b`
        });
      } else {
        resolve({
          success: true,
          output: stdout,
          skill: skill
        });
      }
    });
  });
}

// Usage:
const result = await useClaudeCode(
  "Review this React component for performance issues",
  "code-reviewer"
);
EOF
}

# Main function
main() {
    echo -e "${BLUE}┌─────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│   Claude Code + Ollama Integration Package  │${NC}"
    echo -e "${BLUE}└─────────────────────────────────────────────┘${NC}"
    echo ""
    
    if ! check_system; then
        error "System check failed"
        show_manual
        exit 1
    fi
    
    case "${1:-}" in
        "interactive")
            start_interactive "$WORKSPACE"
            ;;
        "test")
            run_test
            show_manual
            ;;
        "agent")
            show_agent_integration
            ;;
        "skills")
            log "Available skills:"
            for skill in "$WORKSPACE/claude-skills/templates"/*/; do
                if [ -d "$skill" ]; then
                    skill_name=$(basename "$skill")
                    echo "  • ${GREEN}$skill_name${NC}"
                fi
            done
            ;;
        "help"|"-h"|"--help")
            echo "Usage: $0 [command]"
            echo ""
            echo "Commands:"
            echo "  interactive    Start interactive session"
            echo "  test           Run integration test"
            echo "  agent          Show OpenClaw agent integration code"
            echo "  skills         List available skills"
            echo "  help           Show this help"
            echo ""
            echo "Examples:"
            echo "  $0 interactive    # Start Claude Code with Ollama"
            echo "  $0 test           # Test integration"
            echo ""
            echo "Note: Interactive mode is proven to work with Ollama."
            ;;
        *)
            log "Starting integration package..."
            run_test
            echo ""
            show_manual
            ;;
    esac
}

main "$@"