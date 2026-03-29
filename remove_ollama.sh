#!/bin/bash

# Script to remove Ollama provider from all agent models.json files

echo "Removing Ollama provider from agent models.json files..."

# Find all models.json files with ollama references
FILES=$(grep -l "ollama" /Users/clawdia/.openclaw/agents/*/agent/models.json 2>/dev/null)

for file in $FILES; do
    echo "Processing: $file"
    
    # Create backup
    cp "$file" "$file.backup"
    
    # Remove ollama provider section using sed
    # This removes everything from "ollama": { to the closing } before the next provider
    sed -i '' '/"ollama": {/,/^[[:space:]]*},/d' "$file"
    
    # Also remove any trailing comma before the next provider
    sed -i '' '/^[[:space:]]*"ollama":/d' "$file"
    
    echo "  - Updated"
done

echo "Done! Processed $(echo "$FILES" | wc -w) files."
echo "Backups created with .backup extension"