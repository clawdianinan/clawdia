#!/bin/bash
# Initialize memory system

echo "Initializing OpenClaw Memory System..."
echo ""

# Create index
cd "$HOME/.openclaw/workspace"
python3 .memory_index/index_memory.py index

echo ""
echo "Memory system initialized!"
echo ""
echo "Usage:"
echo "  ./memory_search index          # Re-index all memory"
echo "  ./memory_search search <query> # Search memory"
echo "  ./memory_search stats          # Show statistics"
echo ""
