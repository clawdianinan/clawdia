#!/bin/bash
# Development Tool Router Script
# Routes tasks to appropriate development tools based on constraints

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_usage() {
    echo "Development Tool Router"
    echo ""
    echo "Usage: $0 [task description] [options]"
    echo ""
    echo "Options:"
    echo "  --cost-sensitive      Prioritize low/no cost tools"
    echo "  --time-sensitive      Prioritize fast tools"
    echo "  --quality-critical    Prioritize high-quality output"
    echo "  --terminal-based      Use terminal-integrated tools"
    echo "  --openai-ecosystem    Use OpenAI/GPT-4 tools"
    echo "  --needs-images        Route to image generation"
    echo "  --simple              Simple task (use cost-effective tools)"
    echo "  --complex             Complex task (use high-quality tools)"
    echo "  --list-tools          List all available tools"
    echo "  --help                Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 \"Fix bug in React component\" --cost-sensitive --time-sensitive"
    echo "  $0 \"Generate app logo\" --needs-images"
    echo "  $0 \"Refactor authentication system\" --quality-critical"
    echo "  $0 \"Terminal-based code cleanup\" --terminal-based"
}

parse_constraints() {
    COST_SENSITIVE=false
    TIME_SENSITIVE=false
    QUALITY_CRITICAL=false
    TERMINAL_BASED=false
    OPENAI_ECOSYSTEM=false
    NEEDS_IMAGES=false
    SIMPLE_TASK=false
    COMPLEX_TASK=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --cost-sensitive)
                COST_SENSITIVE=true
                shift
                ;;
            --time-sensitive)
                TIME_SENSITIVE=true
                shift
                ;;
            --quality-critical)
                QUALITY_CRITICAL=true
                shift
                ;;
            --terminal-based)
                TERMINAL_BASED=true
                shift
                ;;
            --openai-ecosystem)
                OPENAI_ECOSYSTEM=true
                shift
                ;;
            --needs-images)
                NEEDS_IMAGES=true
                shift
                ;;
            --simple)
                SIMPLE_TASK=true
                shift
                ;;
            --complex)
                COMPLEX_TASK=true
                shift
                ;;
            --list-tools)
                list_tools
                exit 0
                ;;
            --help)
                show_usage
                exit 0
                ;;
            -*)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
            *)
                TASK="$1"
                shift
                ;;
        esac
    done
}

list_tools() {
    echo "Available Development Tools:"
    echo ""
    echo "1. Ollama Qwen3.5:9b (Local)"
    echo "   Cost: FREE | Speed: Slow | Best for: Cost-sensitive coding"
    echo "   Command: ollama launch claude --model qwen3.5:9b"
    echo ""
    echo "2. Gemini CLI"
    echo "   Cost: Low | Speed: Fast | Best for: General coding, balanced"
    echo "   Command: gemini --prompt \"[task]\""
    echo ""
    echo "3. Nano Banana Pro (Image Generation)"
    echo "   Cost: Low | Best for: Image generation/editing"
    echo "   Use: nano-banana-pro skill"
    echo ""
    echo "4. Claude Code (API)"
    echo "   Cost: Medium | Speed: Fast | Best for: Quality-critical work"
    echo "   Command: claude --print \"[task]\""
    echo ""
    echo "5. Codex CLI"
    echo "   Cost: Medium | Speed: Fast | Best for: GPT-4/OpenAI tasks"
    echo "   Command: codex \"[task]\""
    echo ""
    echo "6. Cursor CLI (agent)"
    echo "   Cost: Unknown | Speed: Fast | Best for: Terminal integration"
    echo "   Command: agent chat \"[task]\""
}

select_tool() {
    local task="$1"
    
    log_info "Task: $task"
    log_info "Constraints:"
    log_info "  Cost sensitive: $COST_SENSITIVE"
    log_info "  Time sensitive: $TIME_SENSITIVE"
    log_info "  Quality critical: $QUALITY_CRITICAL"
    log_info "  Terminal based: $TERMINAL_BASED"
    log_info "  OpenAI ecosystem: $OPENAI_ECOSYSTEM"
    log_info "  Needs images: $NEEDS_IMAGES"
    log_info "  Simple task: $SIMPLE_TASK"
    log_info "  Complex task: $COMPLEX_TASK"
    
    # Decision logic (updated priorities)
    if [ "$NEEDS_IMAGES" = true ]; then
        echo "nano-banana-pro"
        return 0
    fi
    
    # Terminal-based or needs planning (Cursor has /plan mode)
    if [ "$TERMINAL_BASED" = true ]; then
        echo "cursor"
        return 0
    fi
    
    # Quality-critical (Tier 1: Claude Code Pro)
    if [ "$QUALITY_CRITICAL" = true ] || [ "$COMPLEX_TASK" = true ]; then
        echo "claude"
        return 0
    fi
    
    # OpenAI ecosystem (Tier 3: Codex CLI)
    if [ "$OPENAI_ECOSYSTEM" = true ]; then
        echo "codex"
        return 0
    fi
    
    # Cost-sensitive (Tier 4: Gemini, Tier 5: Qwen via Claude)
    if [ "$COST_SENSITIVE" = true ]; then
        if [ "$TIME_SENSITIVE" = true ]; then
            echo "gemini"  # Low cost API, decent speed
        else
            echo "qwen"    # Free via Claude Code (ollama launch claude --model qwen3.5:9b)
        fi
        return 0
    fi
    
    # Simple tasks (use Gemini)
    if [ "$SIMPLE_TASK" = true ]; then
        echo "gemini"  # Cost-effective for simple tasks
        return 0
    fi
    
    # Default: Claude Code Pro (your Tier 1 preference)
    echo "claude"
}

get_tool_command() {
    local tool="$1"
    local task="$2"
    local needs_planning="$3"
    
    # Use safe executor by default
    local safe_executor="$HOME/.openclaw/workspace/scripts/safe_tool_executor.sh"
    
    case $tool in
        qwen)
            echo "$safe_executor qwen \"$task\""
            ;;
        gemini)
            echo "$safe_executor gemini \"$task\""
            ;;
        "nano-banana-pro")
            echo "# Use nano-banana-pro skill for image generation"
            echo "# Prompt: $task"
            ;;
        claude)
            if [ "$needs_planning" = true ]; then
                echo "# Claude Code with /plan mode"
                echo "# Use: claude --print \"$task\""
                echo "# Then type: /plan"
                echo "$safe_executor claude \"$task\""
            else
                echo "$safe_executor claude \"$task\""
            fi
            ;;
        codex)
            echo "$safe_executor codex \"$task\""
            ;;
        cursor)
            if [ "$needs_planning" = true ]; then
                echo "# Cursor CLI with /plan mode"
                echo "# Use: agent chat \"$task\""
                echo "# Then type: /plan"
                echo "$safe_executor cursor \"$task\""
            else
                echo "$safe_executor cursor \"$task\""
            fi
            ;;
        *)
            echo "# Unknown tool: $tool"
            ;;
    esac
}

main() {
    if [ $# -eq 0 ]; then
        show_usage
        exit 1
    fi
    
    TASK=""
    parse_constraints "$@"
    
    if [ -z "$TASK" ]; then
        log_error "No task description provided"
        show_usage
        exit 1
    fi
    
    log_info "Selecting appropriate tool..."
    SELECTED_TOOL=$(select_tool "$TASK")
    
    # Clear any extra output from select_tool
    SELECTED_TOOL=$(echo "$SELECTED_TOOL" | tail -1)
    
    log_success "Selected tool: $SELECTED_TOOL"
    
    COMMAND=$(get_tool_command "$SELECTED_TOOL" "$TASK")
    
    echo ""
    echo "Recommended command:"
    echo "  $COMMAND"
    echo ""
    
    # Show reasoning
    case $SELECTED_TOOL in
        qwen)
            echo "Reasoning: Free via Claude Code (ollama launch claude --model qwen3.5:9b) for cost-sensitive tasks."
            ;;
        gemini)
            echo "Reasoning: Low-cost API option for cost-sensitive tasks."
            ;;
        "nano-banana-pro")
            echo "Reasoning: Image generation required, using Gemini 3 Pro Image."
            ;;
        claude)
            echo "Reasoning: Claude Code Pro (Tier 1) for quality-critical work."
            ;;
        codex)
            echo "Reasoning: Codex CLI (Tier 3) for GPT-4/OpenAI ecosystem tasks."
            ;;
        cursor)
            echo "Reasoning: Cursor CLI (Tier 2) with /plan mode for terminal-based work."
            ;;
    esac
    
    echo ""
    log_info "To execute immediately, copy the command above."
}

# Run main function with all arguments
main "$@"