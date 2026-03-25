#!/bin/bash

# dev-tool-router core decision logic
# Version: 0.1.0

set -e

# Configuration
DEBUG=${DEBUG:-0}
LOG_FILE="${LOG_FILE:-/tmp/dev-tool-router.log}"
MAX_OLLAMA_WAIT=30  # seconds to wait for Ollama response

# Tool paths
CLAUDE_PATH=$(which claude 2>/dev/null || echo "")
CODEX_PATH=$(which codex 2>/dev/null || echo "")
OLLAMA_PATH=$(which ollama 2>/dev/null || echo "")
CURSOR_PATH=$(which cursor 2>/dev/null || echo "")

# Logging function
log() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    if [ "$DEBUG" -eq 1 ] || [ "$level" = "ERROR" ]; then
        echo "[$level] $message" >&2
    fi
}

# Check tool availability
check_tool_availability() {
    local tool=$1
    
    case $tool in
        "claude")
            if [ -n "$CLAUDE_PATH" ]; then
                log "INFO" "Claude Code available at: $CLAUDE_PATH"
                return 0
            else
                log "WARN" "Claude Code not found"
                return 1
            fi
            ;;
        "codex")
            if [ -n "$CODEX_PATH" ]; then
                # Check if Codex has hit usage limit
                if codex exec "test" 2>&1 | grep -q "usage limit"; then
                    log "WARN" "Codex usage limit reached"
                    return 2  # Special code for limit reached
                fi
                log "INFO" "Codex available at: $CODEX_PATH"
                return 0
            else
                log "WARN" "Codex not found"
                return 1
            fi
            ;;
        "ollama")
            if [ -n "$OLLAMA_PATH" ]; then
                # Check if Ollama is running and has Qwen model
                if ollama list 2>/dev/null | grep -q "qwen3.5:9b"; then
                    log "INFO" "Ollama available with Qwen3.5:9b"
                    return 0
                else
                    log "WARN" "Ollama available but Qwen3.5:9b model not found"
                    return 1
                fi
            else
                log "WARN" "Ollama not found"
                return 1
            fi
            ;;
        "cursor")
            if [ -n "$CURSOR_PATH" ]; then
                log "INFO" "Cursor CLI available at: $CURSOR_PATH"
                return 0
            else
                log "WARN" "Cursor CLI not found"
                return 1
            fi
            ;;
        *)
            log "ERROR" "Unknown tool: $tool"
            return 1
            ;;
    esac
}

# Estimate task complexity (simple heuristic)
estimate_complexity() {
    local task="$1"
    local words=$(echo "$task" | wc -w | tr -d ' ')
    
    if [ "$words" -lt 10 ]; then
        echo "low"
    elif [ "$words" -lt 25 ]; then
        echo "medium"
    else
        echo "high"
    fi
}

# Main tool selection function
select_dev_tool() {
    local task="$1"
    local constraints="$2"
    
    log "INFO" "Selecting tool for task: $task"
    log "INFO" "Constraints: $constraints"
    
    # Parse constraints
    local cost_sensitive=0
    local time_sensitive=0
    local quality_critical=0
    
    if echo "$constraints" | grep -qi "cost_sensitive=true"; then
        cost_sensitive=1
    fi
    if echo "$constraints" | grep -qi "time_sensitive=true"; then
        time_sensitive=1
    fi
    if echo "$constraints" | grep -qi "quality_critical=true"; then
        quality_critical=1
    fi
    
    # Estimate complexity
    local complexity=$(estimate_complexity "$task")
    log "INFO" "Estimated complexity: $complexity"
    
    # Decision logic
    if [ "$time_sensitive" -eq 1 ] || [ "$quality_critical" -eq 1 ]; then
        # Urgent or quality-critical: use Claude Code (fast, reliable)
        log "INFO" "Time/quality critical - selecting Claude Code"
        echo "claude"
        return 0
    fi
    
    if [ "$cost_sensitive" -eq 1 ] && [ "$time_sensitive" -eq 0 ]; then
        # Cost-sensitive but not time-sensitive: try Ollama
        log "INFO" "Cost-sensitive, not time-sensitive - trying Ollama"
        echo "ollama"
        return 0
    fi
    
    if [ "$complexity" = "high" ]; then
        # High complexity: use Claude Code for better reasoning
        log "INFO" "High complexity - selecting Claude Code"
        echo "claude"
        return 0
    fi
    
    # Default: Claude Code (most reliable)
    log "INFO" "Default selection: Claude Code"
    echo "claude"
}

# Execute task with selected tool
execute_with_tool() {
    local tool=$1
    local task="$2"
    local output_file="${3:-/tmp/tool-output.txt}"
    
    log "INFO" "Executing with tool: $tool"
    
    case $tool in
        "claude")
            echo "$task" | claude 2>&1 | tee "$output_file"
            return $?
            ;;
        "codex")
            codex exec "$task" 2>&1 | tee "$output_file"
            return $?
            ;;
        "ollama")
            # Use timeout for Ollama
            timeout $MAX_OLLAMA_WAIT ollama run qwen3.5:9b "$task" 2>&1 | tee "$output_file"
            local exit_code=$?
            if [ $exit_code -eq 124 ]; then
                log "WARN" "Ollama timed out after ${MAX_OLLAMA_WAIT}s"
                echo "ERROR: Ollama timed out. Consider using Claude Code instead." >> "$output_file"
            fi
            return $exit_code
            ;;
        "cursor")
            # Cursor CLI not working - outputs JavaScript source instead of AI responses
            log "WARN" "Cursor CLI not functional for AI tasks (outputs JS source)"
            echo "ERROR: Cursor CLI not functional for AI coding tasks. Use Claude Code instead." | tee "$output_file"
            return 1
            ;;
        *)
            log "ERROR" "Cannot execute with unknown tool: $tool"
            echo "ERROR: Unknown tool: $tool" | tee "$output_file"
            return 1
            ;;
    esac
}

# Main routing function
route_task() {
    local task="$1"
    shift
    local constraints=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --constraints)
                constraints="$2"
                shift 2
                ;;
            --output)
                local output_file="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done
    
    # Select tool
    local selected_tool=$(select_dev_tool "$task" "$constraints")
    
    # Check tool availability
    check_tool_availability "$selected_tool"
    local availability=$?
    
    # Handle special cases
    if [ "$selected_tool" = "codex" ] && [ $availability -eq 2 ]; then
        log "WARN" "Codex limit reached, falling back to Claude Code"
        selected_tool="claude"
        check_tool_availability "$selected_tool"
        availability=$?
    fi
    
    if [ $availability -ne 0 ]; then
        log "ERROR" "Selected tool $selected_tool not available"
        echo "ERROR: Tool $selected_tool not available or not working"
        return 1
    fi
    
    # Execute task
    local output_file="${output_file:-/tmp/tool-output-$(date +%s).txt}"
    execute_with_tool "$selected_tool" "$task" "$output_file"
    
    log "INFO" "Task completed with tool: $selected_tool"
    log "INFO" "Output saved to: $output_file"
    
    echo "Tool used: $selected_tool"
    echo "Output file: $output_file"
}

# If script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [ $# -lt 1 ]; then
        echo "Usage: $0 <task_description> [--constraints \"key=value\"] [--output /path/to/output]"
        echo ""
        echo "Examples:"
        echo "  $0 \"Fix bug in React component\" --constraints \"time_sensitive=true\""
        echo "  $0 \"Refactor utility functions\" --constraints \"cost_sensitive=true\""
        exit 1
    fi
    
    route_task "$@"
fi