#!/usr/bin/env bash

# dev-tool-router - Intelligent development tool routing system
# Automatically selects the best tool for coding tasks based on constraints

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
CONFIG_FILE="$ROOT_DIR/skills/dev-tool-router/config/default.json"
LOG_FILE="/tmp/dev-tool-router-$(date +%Y%m%d-%H%M%S).log"

# Default constraints
COST_SENSITIVE=false
TIME_SENSITIVE=false
QUALITY_CRITICAL=false
TERMINAL_BASED=false
DEBUG=false

# Tool availability
TOOL_CURSOR=false
TOOL_CLAUDE=false
TOOL_OLLAMA=false
TOOL_CODEX=false

# Parse command line arguments
parse_args() {
    local task=""
    local constraints=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --constraints)
                constraints="$2"
                shift 2
                ;;
            --debug)
                DEBUG=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            --version|-v)
                echo "dev-tool-router v1.0.0"
                exit 0
                ;;
            *)
                if [[ -z "$task" ]]; then
                    task="$1"
                else
                    task="$task $1"
                fi
                shift
                ;;
        esac
    done
    
    # Parse constraints
    if [[ -n "$constraints" ]]; then
        IFS=',' read -ra CONSTRAINT_ARRAY <<< "$constraints"
        for constraint in "${CONSTRAINT_ARRAY[@]}"; do
            case "$constraint" in
                cost_sensitive=true) COST_SENSITIVE=true ;;
                cost_sensitive=false) COST_SENSITIVE=false ;;
                time_sensitive=true) TIME_SENSITIVE=true ;;
                time_sensitive=false) TIME_SENSITIVE=false ;;
                quality_critical=true) QUALITY_CRITICAL=true ;;
                quality_critical=false) QUALITY_CRITICAL=false ;;
                terminal_based=true) TERMINAL_BASED=true ;;
                terminal_based=false) TERMINAL_BASED=false ;;
                *)
                    echo "Warning: Unknown constraint: $constraint" >&2
                    ;;
            esac
        done
    fi
    
    if [[ -z "$task" ]]; then
        echo "Error: No task provided" >&2
        show_help
        exit 1
    fi
    
    echo "$task"
}

# Show help message
show_help() {
    cat << EOF
dev-tool-router - Intelligent development tool routing system

Usage: $0 [options] <task_description>

Options:
  --constraints <constraints>  Comma-separated constraints:
                               cost_sensitive=true|false
                               time_sensitive=true|false  
                               quality_critical=true|false
                               terminal_based=true|false
  --debug                      Enable debug output
  --help, -h                   Show this help message
  --version, -v                Show version

Examples:
  $0 "Fix authentication bug" --constraints "time_sensitive=true,quality_critical=true"
  $0 "Refactor utility functions" --constraints "cost_sensitive=true"
  $0 "Create CLI tool for data processing" --constraints "terminal_based=true"

Default constraints:
  cost_sensitive=false
  time_sensitive=false
  quality_critical=false
  terminal_based=false
EOF
}

# Detect available tools
detect_tools() {
    log "Detecting available tools..."
    
    # Check for Cursor CLI
    if command -v agent >/dev/null 2>&1; then
        TOOL_CURSOR=true
        log "✓ Cursor CLI (agent) detected"
    else
        log "✗ Cursor CLI not found"
    fi
    
    # Check for Claude Code
    if command -v claude >/dev/null 2>&1; then
        TOOL_CLAUDE=true
        log "✓ Claude Code detected"
    else
        log "✗ Claude Code not found"
    fi
    
    # Check for Ollama Qwen
    if command -v ollama >/dev/null 2>&1; then
        if ollama list | grep -q "qwen3.5:9b"; then
            TOOL_OLLAMA=true
            log "✓ Ollama Qwen3.5:9b detected"
        else
            log "✗ Ollama Qwen3.5:9b not installed"
        fi
    else
        log "✗ Ollama not found"
    fi
    
    # Check for Codex CLI
    if command -v codex >/dev/null 2>&1; then
        TOOL_CODEX=true
        log "✓ Codex CLI detected"
    else
        log "✗ Codex CLI not found"
    fi
}

# Analyze task
analyze_task() {
    local task="$1"
    
    log "Analyzing task: $task"
    
    local is_urgent=false
    local is_complex=false
    local is_cost_sensitive=$COST_SENSITIVE
    local requires_quality=$QUALITY_CRITICAL
    local is_terminal_based=$TERMINAL_BASED
    
    # Urgent tasks (bugs, fixes, urgent)
    if [[ "$task" =~ (bug|fix|urgent|critical|emergency|production) ]]; then
        is_urgent=true
        log "  → Task is urgent"
    fi
    
    # Complex tasks (implement, feature, long descriptions)
    if [[ "$task" =~ (implement|feature|architecture|design|system) ]] || \
       [[ ${#task} -gt 100 ]]; then
        is_complex=true
        log "  → Task is complex"
    fi
    
    # Quality critical tasks (security, auth, payment)
    if [[ "$task" =~ (security|auth|authentication|payment|financial|compliance) ]]; then
        requires_quality=true
        log "  → Task requires high quality"
    fi
    
    # Terminal-based tasks (terminal, cli, script)
    if [[ "$task" =~ (terminal|cli|command.*line|script|bash|shell) ]]; then
        is_terminal_based=true
        log "  → Task is terminal-based"
    fi
    
    # Override with explicit constraints
    if [[ "$TIME_SENSITIVE" == "true" ]]; then
        is_urgent=true
        log "  → Time sensitive constraint applied"
    fi
    
    if [[ "$QUALITY_CRITICAL" == "true" ]]; then
        requires_quality=true
        log "  → Quality critical constraint applied"
    fi
    
    if [[ "$TERMINAL_BASED" == "true" ]]; then
        is_terminal_based=true
        log "  → Terminal based constraint applied"
    fi
    
    echo "$is_urgent:$is_complex:$is_cost_sensitive:$requires_quality:$is_terminal_based"
}

# Select tool based on analysis
select_tool() {
    local analysis="$1"
    IFS=':' read -r is_urgent is_complex is_cost_sensitive requires_quality is_terminal_based <<< "$analysis"
    
    log "Selecting tool based on analysis:"
    log "  Urgent: $is_urgent"
    log "  Complex: $is_complex"
    log "  Cost sensitive: $is_cost_sensitive"
    log "  Quality critical: $requires_quality"
    log "  Terminal based: $is_terminal_based"
    
    # Decision logic
    if [[ "$is_terminal_based" == "true" ]] && [[ "$TOOL_CURSOR" == "true" ]]; then
        echo "cursor"
        return 0
    fi
    
    if [[ "$is_urgent" == "true" ]] || [[ "$requires_quality" == "true" ]]; then
        if [[ "$TOOL_CLAUDE" == "true" ]]; then
            echo "claude"
            return 0
        elif [[ "$TOOL_CODEX" == "true" ]]; then
            echo "codex"
            return 0
        fi
    fi
    
    if [[ "$is_cost_sensitive" == "true" ]] && [[ "$TOOL_OLLAMA" == "true" ]]; then
        echo "ollama"
        return 0
    fi
    
    if [[ "$TOOL_CLAUDE" == "true" ]]; then
        echo "claude"
        return 0
    fi
    
    if [[ "$TOOL_CODEX" == "true" ]]; then
        echo "codex"
        return 0
    fi
    
    if [[ "$TOOL_CURSOR" == "true" ]]; then
        echo "cursor"
        return 0
    fi
    
    if [[ "$TOOL_OLLAMA" == "true" ]]; then
        echo "ollama"
        return 0
    fi
    
    echo "none"
    return 1
}

# Execute task with selected tool
execute_task() {
    local tool="$1"
    local task="$2"
    
    log "Executing task with $tool: $task"
    
    case "$tool" in
        cursor)
            # Cursor CLI with print mode for non-interactive use
            echo "Running with Cursor CLI..."
            agent -p "$task" --output-format text
            ;;
        claude)
            # Claude Code
            echo "Running with Claude Code..."
            claude "$task"
            ;;
        ollama)
            # Ollama Qwen with timeout
            echo "Running with Ollama Qwen3.5:9b (timeout: 30s)..."
            timeout 30 ollama run qwen3.5:9b "$task" || {
                echo "Ollama timed out, falling back to Claude Code..."
                if [[ "$TOOL_CLAUDE" == "true" ]]; then
                    claude "$task"
                else
                    echo "Error: No fallback tool available"
                    return 1
                fi
            }
            ;;
        codex)
            # Codex CLI
            echo "Running with Codex CLI..."
            codex exec "$task"
            ;;
        *)
            echo "Error: No suitable tool found for task"
            return 1
            ;;
    esac
}

# Log message
log() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    if [[ "$DEBUG" == "true" ]]; then
        echo "[$timestamp] $message" >&2
    fi
    
    echo "[$timestamp] $message" >> "$LOG_FILE"
}

# Main function
main() {
    local task=$(parse_args "$@")
    
    log "=== dev-tool-router started ==="
    log "Task: $task"
    log "Constraints: cost_sensitive=$COST_SENSITIVE, time_sensitive=$TIME_SENSITIVE, quality_critical=$QUALITY_CRITICAL, terminal_based=$TERMINAL_BASED"
    
    # Detect available tools
    detect_tools
    
    # Analyze task
    local analysis=$(analyze_task "$task")
    
    # Select tool
    local selected_tool=$(select_tool "$analysis")
    
    if [[ "$selected_tool" == "none" ]]; then
        echo "Error: No development tools available. Please install at least one of:"
        echo "  - Cursor CLI (agent)"
        echo "  - Claude Code (claude)"
        echo "  - Ollama with Qwen3.5:9b"
        echo "  - Codex CLI (codex)"
        log "No tools available, exiting"
        exit 1
    fi
    
    log "Selected tool: $selected_tool"
    echo "Selected tool: $selected_tool"
    
    # Execute task
    if execute_task "$selected_tool" "$task"; then
        log "Task completed successfully"
        echo "Task completed with $selected_tool"
    else
        log "Task execution failed"
        echo "Task execution failed with $selected_tool"
        exit 1
    fi
    
    log "=== dev-tool-router finished ==="
}

# Run main function
main "$@"