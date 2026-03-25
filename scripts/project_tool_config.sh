#!/bin/bash

# Project Tool Configuration
# Allows project-specific tool overrides

set -e

PROJECT_CONFIG_DIR="$HOME/.openclaw/project_configs"
mkdir -p "$PROJECT_CONFIG_DIR"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

get_project_config() {
    local project_path="$1"
    local project_name=$(basename "$project_path")
    local config_file="$PROJECT_CONFIG_DIR/${project_name}.json"
    
    if [ -f "$config_file" ]; then
        echo "$config_file"
    else
        echo ""
    fi
}

get_project_tool() {
    local project_path="$1"
    local default_tool="$2"
    
    local config_file=$(get_project_config "$project_path")
    
    if [ -n "$config_file" ]; then
        # Read preferred tool from config
        local preferred_tool=$(jq -r '.preferred_tool // empty' "$config_file" 2>/dev/null || echo "")
        
        if [ -n "$preferred_tool" ]; then
            echo -e "${BLUE}📁 Project override: Using $preferred_tool (from project config)${NC}"
            echo "$preferred_tool"
            return
        fi
    fi
    
    # Check for project-specific hints
    if [ -f "$project_path/package.json" ]; then
        # Node.js project
        echo -e "${YELLOW}📦 Node.js project detected${NC}"
        echo "$default_tool"
    elif [ -f "$project_path/Pipfile" ] || [ -f "$project_path/requirements.txt" ]; then
        # Python project
        echo -e "${YELLOW}🐍 Python project detected${NC}"
        echo "$default_tool"
    elif [ -f "$project_path/Cargo.toml" ]; then
        # Rust project
        echo -e "${YELLOW}🦀 Rust project detected${NC}"
        echo "claude"  # Claude good for Rust
    elif [ -f "$project_path/go.mod" ]; then
        # Go project
        echo -e "${YELLOW}🐹 Go project detected${NC}"
        echo "claude"  # Claude good for Go
    else
        echo "$default_tool"
    fi
}

set_project_tool() {
    local project_path="$1"
    local tool="$2"
    
    local project_name=$(basename "$project_path")
    local config_file="$PROJECT_CONFIG_DIR/${project_name}.json"
    
    # Create or update config
    if [ ! -f "$config_file" ]; then
        echo "{\"preferred_tool\": \"$tool\"}" > "$config_file"
    else
        jq ".preferred_tool = \"$tool\"" "$config_file" > "${config_file}.tmp" && mv "${config_file}.tmp" "$config_file"
    fi
    
    echo -e "${GREEN}✅ Project tool set to: $tool${NC}"
    echo "Config saved to: $config_file"
}

list_project_configs() {
    echo -e "${BLUE}📁 Project Configurations:${NC}"
    
    if [ ! -d "$PROJECT_CONFIG_DIR" ] || [ -z "$(ls -A "$PROJECT_CONFIG_DIR")" ]; then
        echo "No project configurations found."
        return
    fi
    
    for config in "$PROJECT_CONFIG_DIR"/*.json; do
        local project_name=$(basename "$config" .json)
        local tool=$(jq -r '.preferred_tool // "default"' "$config" 2>/dev/null || echo "default")
        echo "  $project_name: $tool"
    done
}

# Main function
main() {
    case "${1:-}" in
        "set")
            if [ $# -lt 3 ]; then
                echo "Usage: $0 set <project_path> <tool>"
                echo "Tools: claude, cursor, codex, gemini, qwen"
                exit 1
            fi
            set_project_tool "$2" "$3"
            ;;
        "get")
            if [ $# -lt 3 ]; then
                echo "Usage: $0 get <project_path> <default_tool>"
                exit 1
            fi
            get_project_tool "$2" "$3"
            ;;
        "list")
            list_project_configs
            ;;
        "help"|"")
            echo "Project Tool Configuration"
            echo ""
            echo "Usage:"
            echo "  $0 set <project_path> <tool>    Set preferred tool for project"
            echo "  $0 get <project_path> <default> Get tool for project (with fallback)"
            echo "  $0 list                         List all project configurations"
            echo ""
            echo "Example:"
            echo "  $0 set ~/projects/myapp claude"
            echo "  $0 get ~/projects/myapp cursor"
            exit 0
            ;;
        *)
            echo "Unknown command: $1"
            echo "Use: $0 help"
            exit 1
            ;;
    esac
}

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed."
    echo "Install with: brew install jq"
    exit 1
fi

main "$@"