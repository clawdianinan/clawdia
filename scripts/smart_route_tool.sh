#!/bin/bash

# Smart Tool Router with Three Separate Fixes:
# 1. Context Management (prevents overflow)
# 2. Claude Code /plan mode awareness
# 3. Project-specific overrides

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Paths
SAFE_EXECUTOR="$HOME/.openclaw/workspace/scripts/safe_tool_executor.sh"
PROJECT_CONFIG="$HOME/.openclaw/workspace/scripts/project_tool_config.sh"
ROUTER_DIR="$HOME/.openclaw/workspace/skills/dev-tool-router"

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

# Check prerequisites
check_prerequisites() {
    local missing=()
    
    [ ! -f "$SAFE_EXECUTOR" ] && missing+=("safe_tool_executor.sh")
    [ ! -f "$PROJECT_CONFIG" ] && missing+=("project_tool_config.sh")
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${RED}Missing required scripts:${NC}"
        for item in "${missing[@]}"; do
            echo "  - $item"
        done
        exit 1
    fi
    
    print_success "All prerequisites available"
}

# Get project-specific tool (Fix #3)
get_project_specific_tool() {
    local project_path="$1"
    local default_tool="$2"
    
    if [ -n "$project_path" ] && [ -d "$project_path" ]; then
        local project_tool=$("$PROJECT_CONFIG" get "$project_path" "$default_tool")
        echo "$project_tool"
    else
        echo "$default_tool"
    fi
}

# Select tool based on constraints (original logic)
select_tool_by_constraints() {
    local needs_images="$1"
    local terminal_based="$2"
    local quality_critical="$3"
    local openai_ecosystem="$4"
    local cost_sensitive="$5"
    local time_sensitive="$6"
    local needs_planning="$7"
    
    # Fix #1: Context management handled by safe_executor
    
    # Fix #2: Both Claude and Cursor have /plan mode
    if [ "$needs_planning" = true ]; then
        if [ "$terminal_based" = true ]; then
            echo "cursor"
            return
        else
            echo "claude"  # Claude also has /plan mode
            return
        fi
    fi
    
    # Original decision logic
    if [ "$needs_images" = true ]; then
        echo "nano-banana-pro"
        return
    fi
    
    if [ "$terminal_based" = true ]; then
        echo "cursor"
        return
    fi
    
    if [ "$quality_critical" = true ]; then
        echo "claude"
        return
    fi
    
    if [ "$openai_ecosystem" = true ]; then
        echo "codex"
        return
    fi
    
    if [ "$cost_sensitive" = true ]; then
        if [ "$time_sensitive" = true ]; then
            echo "gemini"
        else
            echo "qwen"
        fi
        return
    fi
    
    # Default
    echo "claude"
}

# Get tool command with all fixes applied
get_tool_command() {
    local tool="$1"
    local task="$2"
    local needs_planning="$3"
    local context_file="$4"
    
    case $tool in
        qwen|gemini|codex)
            echo "$SAFE_EXECUTOR $tool \"$task\" ${context_file:+\"$context_file\"}"
            ;;
        claude|cursor)
            local cmd="$SAFE_EXECUTOR $tool \"$task\" ${context_file:+\"$context_file\"}"
            if [ "$needs_planning" = true ]; then
                echo -e "${YELLOW}# Note: $tool has /plan mode${NC}"
                echo "# After starting, type: /plan"
                echo "$cmd"
            else
                echo "$cmd"
            fi
            ;;
        "nano-banana-pro")
            echo "# Use nano-banana-pro skill for image generation"
            echo "# Prompt: $task"
            ;;
        *)
            echo -e "${RED}# Unknown tool: $tool${NC}"
            ;;
    esac
}

# Main function
main() {
    check_prerequisites
    
    # Parse arguments
    local TASK=""
    local CONTEXT_FILE=""
    local PROJECT_PATH=""
    local NEEDS_IMAGES=false
    local TERMINAL_BASED=false
    local QUALITY_CRITICAL=false
    local OPENAI_ECOSYSTEM=false
    local COST_SENSITIVE=false
    local TIME_SENSITIVE=false
    local NEEDS_PLANNING=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --task)
                TASK="$2"
                shift 2
                ;;
            --context)
                CONTEXT_FILE="$2"
                shift 2
                ;;
            --project)
                PROJECT_PATH="$2"
                shift 2
                ;;
            --needs-images)
                NEEDS_IMAGES=true
                shift
                ;;
            --terminal-based)
                TERMINAL_BASED=true
                shift
                ;;
            --quality-critical)
                QUALITY_CRITICAL=true
                shift
                ;;
            --openai-ecosystem)
                OPENAI_ECOSYSTEM=true
                shift
                ;;
            --cost-sensitive)
                COST_SENSITIVE=true
                shift
                ;;
            --time-sensitive)
                TIME_SENSITIVE=true
                shift
                ;;
            --needs-planning)
                NEEDS_PLANNING=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                # Assume it's the task if no flag
                if [ -z "$TASK" ]; then
                    TASK="$1"
                fi
                shift
                ;;
        esac
    done
    
    if [ -z "$TASK" ]; then
        echo -e "${RED}Error: Task is required${NC}"
        show_help
        exit 1
    fi
    
    print_header "SMART TOOL ROUTING"
    echo -e "Task: ${GREEN}$TASK${NC}"
    
    # Select tool by constraints
    local SELECTED_TOOL=$(select_tool_by_constraints \
        "$NEEDS_IMAGES" "$TERMINAL_BASED" "$QUALITY_CRITICAL" \
        "$OPENAI_ECOSYSTEM" "$COST_SENSITIVE" "$TIME_SENSITIVE" \
        "$NEEDS_PLANNING")
    
    # Apply project override (Fix #3)
    if [ -n "$PROJECT_PATH" ]; then
        local PROJECT_TOOL=$(get_project_specific_tool "$PROJECT_PATH" "$SELECTED_TOOL")
        if [ "$PROJECT_TOOL" != "$SELECTED_TOOL" ]; then
            echo -e "${BLUE}📁 Project override applied${NC}"
            SELECTED_TOOL="$PROJECT_TOOL"
        fi
    fi
    
    echo -e "Selected tool: ${GREEN}$SELECTED_TOOL${NC}"
    
    # Show reasoning
    case $SELECTED_TOOL in
        qwen)
            echo "Reasoning: Free via Claude Code for cost-sensitive tasks"
            ;;
        gemini)
            echo "Reasoning: Low-cost API for cost-sensitive time-sensitive tasks"
            ;;
        "nano-banana-pro")
            echo "Reasoning: Image generation required"
            ;;
        claude)
            if [ "$NEEDS_PLANNING" = true ]; then
                echo "Reasoning: Claude Code (Tier 1) with /plan mode for planning"
            else
                echo "Reasoning: Claude Code (Tier 1) for quality-critical work"
            fi
            ;;
        codex)
            echo "Reasoning: Codex CLI (Tier 3) for GPT-4/OpenAI ecosystem"
            ;;
        cursor)
            if [ "$NEEDS_PLANNING" = true ]; then
                echo "Reasoning: Cursor CLI (Tier 2) with /plan mode for terminal planning"
            else
                echo "Reasoning: Cursor CLI (Tier 2) for terminal-based work"
            fi
            ;;
    esac
    
    # Get command (with Fix #1 & #2)
    echo ""
    print_header "RECOMMENDED COMMAND"
    local CMD=$(get_tool_command "$SELECTED_TOOL" "$TASK" "$NEEDS_PLANNING" "$CONTEXT_FILE")
    echo "$CMD"
    
    # Context management note (Fix #1)
    if [ -n "$CONTEXT_FILE" ]; then
        echo ""
        echo -e "${YELLOW}📝 Context management: Using 70% buffer to prevent overflow${NC}"
    fi
}

show_help() {
    echo "Smart Tool Router with Three Fixes"
    echo ""
    echo "Usage: $0 [options] <task>"
    echo ""
    echo "Options:"
    echo "  --task <text>          Task description (required)"
    echo "  --context <file>       Context file to include"
    echo "  --project <path>       Project path for overrides"
    echo "  --needs-images         Task requires image generation"
    echo "  --terminal-based       Prefer terminal-based tool"
    echo "  --quality-critical     Quality is critical (use Tier 1)"
    echo "  --openai-ecosystem     Requires OpenAI/GPT-4"
    echo "  --cost-sensitive       Cost is a concern"
    echo "  --time-sensitive       Time is critical"
    echo "  --needs-planning       Task requires planning (/plan mode)"
    echo "  --help                 Show this help"
    echo ""
    echo "Three Fixes Applied:"
    echo "  1. Context Management - Prevents overflow with 70% buffer"
    echo "  2. /plan Mode Awareness - Both Claude & Cursor support planning"
    echo "  3. Project Overrides - Project-specific tool preferences"
    echo ""
    echo "Examples:"
    echo "  $0 \"Fix bug\" --cost-sensitive --time-sensitive"
    echo "  $0 \"Plan feature\" --needs-planning --project ~/myapp"
    echo "  $0 \"Generate logo\" --needs-images"
}

# Run main
main "$@"