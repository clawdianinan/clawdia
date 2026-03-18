#!/bin/bash
# Update file references from old Documents location to new Google Drive location

echo "📝 Updating File References"
echo "==========================="

OLD_PATH="/Users/clawdia/Documents"
NEW_PATH="/Users/clawdia/My Drive/Clawdia Documents"

echo "Old: $OLD_PATH"
echo "New: $NEW_PATH"

echo ""
echo "1. Checking for references to old location..."
echo ""
echo "Searching in workspace files..."

# Find files containing old path
FOUND_FILES=$(grep -r "$OLD_PATH" ~/.openclaw/workspace/ 2>/dev/null | head -20)
if [ -n "$FOUND_FILES" ]; then
    echo "Found references in:"
    echo "$FOUND_FILES"
else
    echo "No references found to old path"
fi

echo ""
echo "2. Checking for '/Documents/' pattern..."
DOCS_REFS=$(grep -r "/Documents/" ~/.openclaw/workspace/ 2>/dev/null | grep -v ".git" | head -10)
if [ -n "$DOCS_REFS" ]; then
    echo "Found '/Documents/' references:"
    echo "$DOCS_REFS"
fi

echo ""
echo "3. Checking specific file types..."
echo ""
echo "Markdown files (.md):"
grep -l "/Documents/" ~/.openclaw/workspace/*.md 2>/dev/null

echo ""
echo "Script files (.sh):"
grep -l "/Documents/" ~/.openclaw/workspace/scripts/*.sh 2>/dev/null

echo ""
echo "4. UPDATE OPTIONS:"
echo "================="
echo ""
echo "A. Dry run (show what would change)"
echo "B. Update all references automatically"
echo "C. Update specific files only"
echo ""
read -p "Choose option (A/B/C): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[A]$ ]]; then
    echo "🔍 DRY RUN - Showing changes that would be made:"
    echo ""
    find ~/.openclaw/workspace -type f \( -name "*.md" -o -name "*.sh" -o -name "*.py" -o -name "*.txt" \) 2>/dev/null | while read file; do
        if grep -q "$OLD_PATH\|/Documents/" "$file" 2>/dev/null; then
            echo "File: $file"
            grep -n "$OLD_PATH\|/Documents/" "$file" 2>/dev/null | while read line; do
                echo "  Line $line"
                # Show what it would become
                NEW_LINE=$(echo "$line" | sed "s|$OLD_PATH|$NEW_PATH|g" | sed "s|/Documents/|/My Drive/Clawdia Documents/|g")
                echo "  → $NEW_LINE"
            done
            echo ""
        fi
    done
    
elif [[ $REPLY =~ ^[B]$ ]]; then
    echo "🔄 UPDATING ALL REFERENCES..."
    echo ""
    
    COUNT=0
    find ~/.openclaw/workspace -type f \( -name "*.md" -o -name "*.sh" -o -name "*.py" -o -name "*.txt" -o -name "*.json" \) 2>/dev/null | while read file; do
        if grep -q "$OLD_PATH\|/Documents/" "$file" 2>/dev/null; then
            echo "Updating: $file"
            # Backup original
            cp "$file" "$file.backup.$(date +%s)"
            # Update paths
            sed -i '' "s|$OLD_PATH|$NEW_PATH|g" "$file"
            sed -i '' "s|/Documents/|/My Drive/Clawdia Documents/|g" "$file"
            COUNT=$((COUNT + 1))
        fi
    done
    
    echo ""
    echo "✅ Updated $COUNT files"
    echo "Backups created with .backup.<timestamp> extension"
    
elif [[ $REPLY =~ ^[C]$ ]]; then
    echo "🎯 UPDATE SPECIFIC FILES"
    echo ""
    echo "Files found with references:"
    find ~/.openclaw/workspace -type f \( -name "*.md" -o -name "*.sh" -o -name "*.py" -o -name "*.txt" \) 2>/dev/null | while read file; do
        if grep -q "$OLD_PATH\|/Documents/" "$file" 2>/dev/null; then
            echo "  $file"
        fi
    done
    
    echo ""
    read -p "Enter file path to update (or 'all' for all): " FILE_PATH
    if [ "$FILE_PATH" = "all" ]; then
        echo "Updating all files..."
        find ~/.openclaw/workspace -type f \( -name "*.md" -o -name "*.sh" -o -name "*.py" -o -name "*.txt" \) 2>/dev/null | while read file; do
            if grep -q "$OLD_PATH\|/Documents/" "$file" 2>/dev/null; then
                echo "  Updating: $file"
                cp "$file" "$file.backup.$(date +%s)"
                sed -i '' "s|$OLD_PATH|$NEW_PATH|g" "$file"
                sed -i '' "s|/Documents/|/My Drive/Clawdia Documents/|g" "$file"
            fi
        done
    elif [ -f "$FILE_PATH" ]; then
        echo "Updating: $FILE_PATH"
        cp "$FILE_PATH" "$FILE_PATH.backup.$(date +%s)"
        sed -i '' "s|$OLD_PATH|$NEW_PATH|g" "$FILE_PATH"
        sed -i '' "s|/Documents/|/My Drive/Clawdia Documents/|g" "$FILE_PATH"
        echo "✅ Updated"
    else
        echo "❌ File not found"
    fi
else
    echo "❌ Invalid option"
fi

echo ""
echo "5. COMMON FILES TO CHECK:"
echo "========================"
echo ""
echo "Critical files that likely need updates:"
echo ""
echo "1. DOCUMENT_LOCATIONS.md"
echo "   Location: $OLD_BASE/IIH/DOCUMENT_LOCATIONS.md"
echo "   Should point to new Google Drive location"
echo ""
echo "2. Scripts that access Documents:"
echo "   ~/.openclaw/workspace/scripts/*.sh"
echo ""
echo "3. Memory files:"
echo "   ~/.openclaw/workspace/memory/*.md"
echo ""
echo "4. Configuration files:"
echo "   ~/.openclaw/workspace/*.md (AGENTS.md, MEMORY.md, etc.)"
echo ""
echo "5. Email attachment scripts:"
echo "   Check scripts that save attachments to Documents"

echo ""
echo "6. VERIFICATION:"
echo "================"
echo "Run grep to verify updates:"
echo "grep -r \"$NEW_PATH\" ~/.openclaw/workspace/ 2>/dev/null | head -5"

echo ""
echo "✅ Reference update complete!"
echo "Remember to also update any:"
echo "- Manual notes"
echo "- Other scripts outside workspace"
echo "- Application configurations"
echo "- Bookmarked paths"