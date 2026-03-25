#!/usr/bin/env bash

# Test script for dev-tool-router
# Demonstrates different tool selections based on task types

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROUTER_SCRIPT="$SCRIPT_DIR/route-task.sh"

echo "=== Testing dev-tool-router ==="
echo

# Test 1: Urgent bug fix (should select Claude Code)
echo "Test 1: Urgent bug fix"
echo "Task: 'Fix production authentication bug that allows unauthorized access'"
echo "Constraints: time_sensitive=true,quality_critical=true"
echo
"$ROUTER_SCRIPT" "Fix production authentication bug that allows unauthorized access" \
  --constraints "time_sensitive=true,quality_critical=true" --debug 2>&1 | grep -E "(Selected tool|Running with|Task completed)" || true
echo "---"
echo

# Test 2: Cost-sensitive task (should select Ollama if available)
echo "Test 2: Cost-sensitive task"
echo "Task: 'Refactor utility functions to improve readability'"
echo "Constraints: cost_sensitive=true"
echo
"$ROUTER_SCRIPT" "Refactor utility functions to improve readability" \
  --constraints "cost_sensitive=true" --debug 2>&1 | grep -E "(Selected tool|Running with|Task completed)" || true
echo "---"
echo

# Test 3: Terminal-based task (should select Cursor CLI)
echo "Test 3: Terminal-based task"
echo "Task: 'Create a bash script to automate deployment'"
echo "Constraints: terminal_based=true"
echo
"$ROUTER_SCRIPT" "Create a bash script to automate deployment" \
  --constraints "terminal_based=true" --debug 2>&1 | grep -E "(Selected tool|Running with|Task completed)" || true
echo "---"
echo

# Test 4: Complex feature (should select Claude Code)
echo "Test 4: Complex feature"
echo "Task: 'Implement real-time notification system with WebSocket support'"
echo "Constraints: quality_critical=true"
echo
"$ROUTER_SCRIPT" "Implement real-time notification system with WebSocket support" \
  --constraints "quality_critical=true" --debug 2>&1 | grep -E "(Selected tool|Running with|Task completed)" || true
echo "---"
echo

# Test 5: Default (no constraints, should select Claude Code as default)
echo "Test 5: Default task"
echo "Task: 'Write documentation for new API endpoints'"
echo "Constraints: none"
echo
"$ROUTER_SCRIPT" "Write documentation for new API endpoints" \
  --debug 2>&1 | grep -E "(Selected tool|Running with|Task completed)" || true
echo "---"
echo

echo "=== Test complete ==="
echo "Check /tmp/dev-tool-router-*.log for detailed logs"