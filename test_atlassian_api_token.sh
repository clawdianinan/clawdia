#!/bin/bash

echo "=== Testing ATLASSIAN_API_TOKEN Configuration ==="
echo ""

# Method 1: Source from .env.atlassian
if [ -f .env.atlassian ]; then
    source .env.atlassian
    if [ -n "$ATLASSIAN_API_TOKEN" ]; then
        echo "✅ Method 1: Sourced from .env.atlassian"
        echo "   ATLASSIAN_API_TOKEN length: ${#ATLASSIAN_API_TOKEN}"
    else
        echo "❌ Method 1: ATLASSIAN_API_TOKEN not found in .env.atlassian"
    fi
fi

echo ""

# Method 2: Extract from .env.atlassian directly
if [ -f .env.atlassian ]; then
    TOKEN=$(grep '^ATLASSIAN_API_TOKEN=' .env.atlassian | cut -d'=' -f2)
    if [ -n "$TOKEN" ]; then
        echo "✅ Method 2: Extracted from .env.atlassian"
        echo "   Token length: ${#TOKEN}"
        echo "   First 10 chars: ${TOKEN:0:10}..."
    else
        echo "❌ Method 2: Could not extract token from .env.atlassian"
    fi
fi

echo ""

# Method 3: Check shell profile
if grep -q "ATLASSIAN_API_TOKEN=" ~/.zshrc; then
    echo "✅ Method 3: Found in ~/.zshrc"
    echo "   Line: $(grep 'ATLASSIAN_API_TOKEN=' ~/.zshrc | head -1 | cut -c1-50)..."
else
    echo "❌ Method 3: Not found in ~/.zshrc"
fi

echo ""
echo "=== Configuration Summary ==="
echo "Environment variable: ATLASSIAN_API_TOKEN"
echo "Configuration files:"
echo "  1. .env.atlassian (local)"
echo "  2. ~/.zshrc (persistent)"
echo "  3. memory/2026-03-18-0415.md (documentation)"
echo ""
echo "To use in new shell sessions:"
echo "  source ~/.zshrc  # or restart terminal"
echo "  echo \$ATLASSIAN_API_TOKEN"