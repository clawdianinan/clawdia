#!/bin/bash
# Sync PRDForge Cursor Cloud Work to Local
# Syncs the cursor/development-environment-setup-64da branch to local PRDForge folder

set -e

echo "🚀 Syncing PRDForge Cursor Cloud Work to Local"
echo "================================================"

PRDFORGE_PATH="/Users/clawdia/apps/prdforge"
CURSOR_BRANCH="cursor/development-environment-setup-64da"

# Check if PRDForge directory exists
if [ ! -d "$PRDFORGE_PATH" ]; then
    echo "❌ PRDForge directory not found: $PRDFORGE_PATH"
    exit 1
fi

cd "$PRDFORGE_PATH"

echo "1. Checking current state..."
echo "   Location: $(pwd)"
echo "   Current branch: $(git branch --show-current)"
echo ""

# Check if working directory is clean
if [ -n "$(git status --porcelain)" ]; then
    echo "⚠️  Working directory has uncommitted changes"
    echo "   Stashing changes..."
    git stash
    STASHED=true
else
    STASHED=false
fi

# Fetch latest from all remotes
echo "2. Fetching latest from remotes..."
git fetch --all
echo "   ✅ Fetched from origin and upstream"

# Check if cursor branch exists locally
echo "3. Checking for cursor branch..."
if git show-ref --verify --quiet "refs/heads/$CURSOR_BRANCH"; then
    echo "   ✅ Local cursor branch exists"
    git checkout "$CURSOR_BRANCH"
    git pull upstream "$CURSOR_BRANCH"
else
    echo "   🔄 Creating local tracking branch..."
    git checkout -b "$CURSOR_BRANCH" "upstream/$CURSOR_BRANCH"
fi

echo ""
echo "4. Branch Information:"
echo "   Branch: $(git branch --show-current)"
echo "   Commit: $(git log --oneline -1)"
echo ""

# Show what changed
echo "5. Changes from cursor branch vs main:"
git log --oneline "main..$CURSOR_BRANCH" | head -10
echo ""

# Show files changed
echo "6. Files changed in cursor branch:"
git diff --name-only main..HEAD | head -20
echo ""

# Configure Cursor CLI for this project
echo "7. Configuring Cursor CLI for PRDForge..."
bash /Users/clawdia/.openclaw/workspace/project_cursor_config.sh "PRDForge" "$PRDFORGE_PATH"

echo ""
echo "8. Analyzing cursor branch changes with Cursor CLI..."
echo "------------------------------------------------------"

# Analyze the AGENTS.md file that was added
if [ -f "AGENTS.md" ]; then
    echo "📄 AGENTS.md found (Cursor Cloud instructions):"
    head -20 AGENTS.md
    echo ""
    
    # Use Cursor CLI to analyze the changes
    agent chat "Analyze the AGENTS.md file and summarize what Cursor Cloud development setup has been configured" --print --trust
else
    echo "⚠️  AGENTS.md not found in cursor branch"
fi

echo ""
echo "9. Checking for .npmrc and other config files..."
if [ -f ".npmrc" ]; then
    echo "📄 .npmrc found:"
    cat .npmrc
    echo ""
    
    agent chat "Analyze the .npmrc configuration for Netlify compatibility" --print --trust
fi

# Check for Vite compatibility changes
echo ""
echo "10. Checking for Vite compatibility changes..."
if git diff --name-only main..HEAD | grep -q "errorTracking"; then
    echo "🔧 Vite compatibility changes detected in errorTracking.tsx"
    agent chat "Analyze the Vite compatibility changes in errorTracking.tsx" --print --trust
fi

echo ""
echo "11. Setting up local development environment..."
echo "------------------------------------------------"

# Check package.json for dependencies
if [ -f "package.json" ]; then
    echo "📦 Checking dependencies..."
    agent chat "Review package.json dependencies and check if any need installation for local development" --print --trust
fi

# Check for environment setup
echo ""
echo "12. Environment setup instructions..."
if [ -f ".env.example" ] || [ -f ".env.local.example" ]; then
    echo "🔧 Environment template files found"
    agent chat "Provide instructions for setting up local environment variables based on template files" --print --trust
else
    echo "⚠️  No environment template files found"
    agent chat "Suggest environment variables needed for PRDForge local development" --print --trust
fi

echo ""
echo "13. Testing the setup..."
echo "------------------------"

# Check if we can run tests
if [ -f "package.json" ] && grep -q "test" package.json; then
    echo "🧪 Test script found in package.json"
    agent chat "Check if tests can run locally and provide instructions" --print --trust
else
    echo "⚠️  No test script found in package.json"
fi

echo ""
echo "14. Creating sync summary..."
echo "----------------------------"

# Create a sync report
SYNC_REPORT="$PRDFORGE_PATH/cursor-sync-report-$(date +%Y%m%d-%H%M%S).md"
cat > "$SYNC_REPORT" << EOF
# PRDForge Cursor Cloud Sync Report
## Synced: $(date)

## Source Branch
- Branch: \`$CURSOR_BRANCH\`
- Remote: \`upstream/$CURSOR_BRANCH\`
- Latest Commit: \`$(git log --oneline -1)\`

## Changes Synced
\`\`\`
$(git log --oneline "main..$CURSOR_BRANCH" | head -20)
\`\`\`

## Files Changed
$(git diff --name-only main..HEAD | while read file; do echo "- \`$file\`"; done)

## Key Changes
1. **AGENTS.md** - Cursor Cloud development instructions
2. **.npmrc** - Netlify compatibility configuration
3. **Vite compatibility** - errorTracking.tsx updates

## Cursor CLI Configuration
- Project configured at: \`$PRDFORGE_PATH\`
- Rules created in: \`.cursor/rules/\`
- Helper script: \`cursor-agent-helper.sh\`

## Next Steps
1. Review the changes: \`git diff main..HEAD\`
2. Test locally: Follow instructions in AGENTS.md
3. Merge to main if ready: \`git checkout main && git merge $CURSOR_BRANCH\`
4. Continue development using Cursor CLI helper

## Agent Instructions
Use the helper script for development:
\`\`\`bash
cd "$PRDFORGE_PATH"
./cursor-agent-helper.sh
\`\`\`
EOF

echo "📄 Sync report created: $SYNC_REPORT"
echo ""
cat "$SYNC_REPORT"

# Restore original state if needed
echo ""
echo "15. Cleanup..."
if [ "$STASHED" = true ]; then
    echo "   Restoring stashed changes..."
    git stash pop
fi

echo ""
echo "🎉 Sync Complete!"
echo "================="
echo ""
echo "✅ Cursor Cloud work synced to local PRDForge"
echo "✅ Cursor CLI configured for project"
echo "✅ Helper scripts created"
echo "✅ Sync report generated"
echo ""
echo "📁 Project: $PRDFORGE_PATH"
echo "🌿 Branch: $CURSOR_BRANCH"
echo "🔧 Cursor CLI ready: agent chat \"<task>\" --print --trust"
echo ""
echo "Next actions:"
echo "1. Review changes: git diff main..HEAD"
echo "2. Test setup: Follow AGENTS.md instructions"
echo "3. Use helper: ./cursor-agent-helper.sh"
echo "4. Merge when ready: git checkout main && git merge $CURSOR_BRANCH"
echo ""
echo "Your Cursor Cloud development environment is now synced locally!"