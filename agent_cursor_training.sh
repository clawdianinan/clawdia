#!/bin/bash
# Cursor CLI Agent Training Script
# Purpose: Train agents on using Cursor CLI within specific projects

set -e  # Exit on error

echo "🔧 Cursor CLI Agent Training"
echo "============================="

# Check prerequisites
echo "1. Checking prerequisites..."
if ! command -v agent &> /dev/null; then
    echo "❌ Cursor CLI not found. Install with: curl https://cursor.com/install -fsS | bash"
    exit 1
fi

echo "✅ Cursor CLI installed: $(agent --version)"

# Check authentication
echo "2. Checking authentication..."
if ! agent status 2>&1 | grep -q "Logged in"; then
    echo "⚠️  Not authenticated. Run: agent login"
    echo "   Or set CURSOR_API_KEY environment variable"
    exit 1
fi

echo "✅ Authenticated"

# Create training project
TRAINING_DIR="/tmp/cursor-agent-training-$(date +%s)"
echo "3. Creating training project at: $TRAINING_DIR"
mkdir -p "$TRAINING_DIR"
cd "$TRAINING_DIR"

# Exercise 1: Initialize a new project
echo ""
echo "📁 Exercise 1: Initialize New Project"
echo "--------------------------------------"
cat > README.md << 'EOF'
# Training Project
This is a training project for Cursor CLI agents.
EOF

agent chat "Initialize a simple Node.js project with Express" --print --trust
echo "✅ Project initialized"

# Exercise 2: Create project structure
echo ""
echo "📁 Exercise 2: Create Project Structure"
echo "----------------------------------------"
agent chat "Create basic project structure: src/, tests/, config/" --print --trust
echo "✅ Project structure created"

# Exercise 3: Add version control
echo ""
echo "📁 Exercise 3: Version Control Setup"
echo "-------------------------------------"
git init
git add .
agent chat "Create initial commit with message 'Initial project setup'" --print --trust
echo "✅ Git initialized and committed"

# Exercise 4: Create feature branch
echo ""
echo "📁 Exercise 4: Feature Branch Workflow"
echo "---------------------------------------"
agent chat "Create feature branch 'feat/user-auth'" --print --trust
echo "✅ Feature branch created"

# Exercise 5: Implement feature
echo ""
echo "📁 Exercise 5: Implement Feature"
echo "---------------------------------"
agent chat "Create user authentication module with login and register endpoints" --print --trust
echo "✅ Feature implemented"

# Exercise 6: Add tests
echo ""
echo "📁 Exercise 6: Testing"
echo "-----------------------"
agent chat "Add unit tests for authentication module" --print --trust
echo "✅ Tests added"

# Exercise 7: Update documentation
echo ""
echo "📁 Exercise 7: Documentation"
echo "----------------------------"
agent chat "Update README with authentication API documentation" --print --trust
echo "✅ Documentation updated"

# Exercise 8: Commit changes
echo ""
echo "📁 Exercise 8: Commit Workflow"
echo "-------------------------------"
agent chat "Stage all changes and commit with message 'feat: add user authentication'" --print --trust
echo "✅ Changes committed"

# Exercise 9: Code review
echo ""
echo "📁 Exercise 9: Code Review"
echo "---------------------------"
agent chat "Review the code for security issues and best practices" --mode=ask --print --trust
echo "✅ Code review completed"

# Exercise 10: Cleanup
echo ""
echo "📁 Exercise 10: Project Cleanup"
echo "--------------------------------"
agent chat "Remove any temporary files and ensure clean project state" --print --trust
echo "✅ Project cleaned up"

# Summary
echo ""
echo "🎉 Training Complete!"
echo "====================="
echo "Agents have learned:"
echo "1. ✅ Project initialization"
echo "2. ✅ Project structure creation"
echo "3. ✅ Git version control"
echo "4. ✅ Feature branch workflow"
echo "5. ✅ Feature implementation"
echo "6. ✅ Test creation"
echo "7. ✅ Documentation"
echo "8. ✅ Commit workflow"
echo "9. ✅ Code review"
echo "10.✅ Project cleanup"

echo ""
echo "📊 Project Stats:"
find . -type f -name "*.js" -o -name "*.json" -o -name "*.md" | wc -l | xargs echo "Files created:"
git log --oneline | wc -l | xargs echo "Commits made:"

echo ""
echo "🚀 Next Steps:"
echo "1. Review the training guide: CURSOR_CLI_AGENT_GUIDE.md"
echo "2. Practice with real projects"
echo "3. Integrate into agent workflows"
echo "4. Set up project-specific rules in .cursor/rules/"

# Cleanup training directory (optional)
echo ""
read -p "Clean up training directory? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cd /
    rm -rf "$TRAINING_DIR"
    echo "🧹 Training directory cleaned up"
else
    echo "📁 Training project preserved at: $TRAINING_DIR"
fi

echo ""
echo "✅ Agent training completed successfully!"