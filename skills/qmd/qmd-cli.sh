#!/bin/bash
# QMD CLI wrapper for easy use

QMD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON="python3"

help() {
    echo "QMD CLI - Queryable Memory Database"
    echo ""
    echo "Usage: qmd <command> [options]"
    echo ""
    echo "Commands:"
    echo "  index [path]          Index documents (default: workspace)"
    echo "  search <query>        Search indexed documents"
    echo "  list                  List indexed documents"
    echo "  clear                 Clear index"
    echo "  memory <query>        Search memory files specifically"
    echo "  context <task>        Get relevant context for a task"
    echo "  test                  Test QMD functionality"
    echo "  help                  Show this help"
    echo ""
    echo "Examples:"
    echo "  qmd index ~/Documents"
    echo "  qmd search 'financial report'"
    echo "  qmd memory 'IHS Towers'"
    echo "  qmd context 'prepare monthly report'"
}

index() {
    local path="${1:-}"
    if [ -n "$path" ]; then
        "$PYTHON" "$QMD_DIR/qmd.py" index --path "$path"
    else
        "$PYTHON" "$QMD_DIR/qmd.py" index
    fi
}

search() {
    if [ $# -eq 0 ]; then
        echo "Error: Search query required"
        echo "Usage: qmd search <query>"
        exit 1
    fi
    "$PYTHON" "$QMD_DIR/qmd.py" search "$@"
}

list() {
    "$PYTHON" "$QMD_DIR/qmd.py" list
}

clear() {
    "$PYTHON" "$QMD_DIR/qmd.py" clear
}

memory() {
    if [ $# -eq 0 ]; then
        echo "Error: Search query required"
        echo "Usage: qmd memory <query>"
        exit 1
    fi
    "$PYTHON" "$QMD_DIR/openclaw_integration.py" search "$@"
}

context() {
    if [ $# -eq 0 ]; then
        echo "Error: Task description required"
        echo "Usage: qmd context <task>"
        exit 1
    fi
    "$PYTHON" "$QMD_DIR/openclaw_integration.py" context "$@"
}

test() {
    echo "Running QMD tests..."
    "$PYTHON" "$QMD_DIR/test_qmd.py"
}

# Main command dispatcher
case "${1:-}" in
    index)
        shift
        index "$@"
        ;;
    search)
        shift
        search "$@"
        ;;
    list)
        list
        ;;
    clear)
        clear
        ;;
    memory)
        shift
        memory "$@"
        ;;
    context)
        shift
        context "$@"
        ;;
    test)
        test
        ;;
    help|--help|-h)
        help
        ;;
    *)
        if [ $# -eq 0 ]; then
            help
        else
            echo "Unknown command: $1"
            echo "Use 'qmd help' for usage information"
            exit 1
        fi
        ;;
esac