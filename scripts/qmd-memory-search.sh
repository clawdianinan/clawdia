#!/bin/bash
# QMD Memory Search Wrapper for OpenClaw
# Provides memory search functionality using local QMD instead of OpenAI embeddings

set -e

QMD_DIR="/Users/clawdia/.openclaw/workspace/skills/qmd"
DEFAULT_LIMIT=10

# Function to search memory using QMD
search_memory() {
    local query="$1"
    local limit="${2:-$DEFAULT_LIMIT}"
    
    if [ -z "$query" ]; then
        echo "Error: Query is required"
        return 1
    fi
    
    echo "🔍 Searching memory for: '$query' (limit: $limit)"
    echo "---"
    
    cd "$QMD_DIR" && python3 qmd.py search "$query" --limit "$limit"
}

# Function to get specific memory file content
get_memory() {
    local path="$1"
    local from="${2:-1}"
    local lines="${3:-50}"
    
    if [ ! -f "$path" ]; then
        echo "Error: File not found: $path"
        return 1
    fi
    
    echo "📄 Reading: $path (lines $from-$((from + lines - 1)))"
    echo "---"
    
    sed -n "${from},$((from + lines - 1))p" "$path"
}

# Function to index memory files
index_memory() {
    echo "📚 Indexing memory files..."
    cd "$QMD_DIR" && python3 qmd.py index-memory
    echo "✅ Memory indexing complete"
}

# Function to test QMD integration
test_qmd() {
    echo "🧪 Testing QMD integration..."
    cd "$QMD_DIR" && python3 qmd.py test-memory
}

# Main command handler
case "${1:-help}" in
    search)
        search_memory "$2" "$3"
        ;;
    get)
        get_memory "$2" "$3" "$4"
        ;;
    index)
        index_memory
        ;;
    test)
        test_qmd
        ;;
    help|--help|-h)
        echo "QMD Memory Search Wrapper"
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "Commands:"
        echo "  search <query> [limit]   - Search memory for query"
        echo "  get <path> [from] [lines] - Get specific memory file content"
        echo "  index                    - Index memory files"
        echo "  test                     - Test QMD integration"
        echo ""
        echo "Examples:"
        echo "  $0 search 'IHS Towers email' 5"
        echo "  $0 get /Users/clawdia/.openclaw/workspace/MEMORY.md 1 20"
        echo "  $0 index"
        ;;
    *)
        echo "Unknown command: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac