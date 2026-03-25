#!/bin/bash
# Project Cursor Configuration Script
# Purpose: Set up Cursor CLI configuration for specific projects

set -e

PROJECT_NAME="$1"
PROJECT_PATH="$2"

if [ -z "$PROJECT_NAME" ] || [ -z "$PROJECT_PATH" ]; then
    echo "Usage: $0 <project-name> <project-path>"
    echo "Example: $0 my-app /path/to/my-app"
    exit 1
fi

if [ ! -d "$PROJECT_PATH" ]; then
    echo "❌ Project path does not exist: $PROJECT_PATH"
    exit 1
fi

echo "🔧 Configuring Cursor CLI for project: $PROJECT_NAME"
echo "Project path: $PROJECT_PATH"
echo ""

cd "$PROJECT_PATH"

# 1. Create .cursor directory structure
echo "1. Creating .cursor directory structure..."
mkdir -p .cursor/rules
mkdir -p .cursor/context

# 2. Create project-specific rules
echo "2. Creating project-specific rules..."
cat > .cursor/rules/project-context.md << EOF
# Project: $PROJECT_NAME
# Path: $PROJECT_PATH

## Project Type
$(if [ -f "package.json" ]; then
    echo "- Type: Node.js/JavaScript"
    echo "- Package Manager: $(grep -q '"workspaces"' package.json && echo "npm workspaces" || echo "npm")"
elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
    echo "- Type: Python"
    echo "- Package Manager: $(if [ -f "pyproject.toml" ]; then echo "poetry"; else echo "pip"; fi)"
elif [ -f "Cargo.toml" ]; then
    echo "- Type: Rust"
    echo "- Package Manager: Cargo"
elif [ -f "go.mod" ]; then
    echo "- Type: Go"
    echo "- Package Manager: Go modules"
else
    echo "- Type: Unknown (detecting...)"
fi)

## Detected Framework
$(if [ -f "package.json" ]; then
    if grep -q '"react"' package.json; then
        echo "- Framework: React"
    elif grep -q '"vue"' package.json; then
        echo "- Framework: Vue"
    elif grep -q '"angular"' package.json; then
        echo "- Framework: Angular"
    elif grep -q '"express"' package.json; then
        echo "- Framework: Express.js"
    elif grep -q '"next"' package.json; then
        echo "- Framework: Next.js"
    fi
fi)

## Code Standards
- Follow existing project patterns
- Maintain consistent formatting
- Add appropriate error handling
- Include tests for new features
- Update documentation when changing APIs

## Agent Instructions
1. Always work within project context
2. Respect existing architecture patterns
3. Update tests when modifying code
4. Document significant changes
5. Follow git workflow conventions
EOF

# 3. Create git integration rules
echo "3. Creating git integration rules..."
cat > .cursor/rules/git-workflow.md << 'EOF'
# Git Workflow Rules

## Branch Naming
- feat/: New features
- fix/: Bug fixes  
- docs/: Documentation
- style/: Code style changes
- refactor/: Code refactoring
- test/: Test updates
- chore: Maintenance tasks

## Commit Messages
- Use conventional commits format
- Start with type: feat, fix, docs, style, refactor, test, chore
- Keep first line under 50 characters
- Provide detailed description in body

## Pull Requests
- Reference issue numbers
- Include testing instructions
- Update documentation
- Follow code review guidelines
EOF

# 4. Create technology-specific rules
echo "4. Creating technology-specific rules..."

if [ -f "package.json" ]; then
    cat > .cursor/rules/javascript.md << 'EOF'
# JavaScript/TypeScript Rules

## Code Style
- Use ES6+ features
- Prefer const over let
- Use arrow functions for callbacks
- Follow Airbnb style guide

## TypeScript (if used)
- Use strict mode
- Define interfaces for complex objects
- Avoid any type
- Use proper type guards

## Testing
- Use Jest for unit tests
- Mock external dependencies
- Test edge cases
- Maintain high test coverage
EOF
fi

if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
    cat > .cursor/rules/python.md << 'EOF'
# Python Rules

## Code Style
- Follow PEP 8
- Use type hints
- Write docstrings
- Use virtual environments

## Testing
- Use pytest
- Mock external services
- Test with different Python versions
- Use coverage reporting
EOF
fi

# 5. Create agent workflow examples
echo "5. Creating agent workflow examples..."
cat > .cursor/rules/agent-workflows.md << EOF
# Agent Workflow Examples

## Adding New Feature
\`\`\`bash
# 1. Checkout feature branch
git checkout -b feat/new-feature

# 2. Implement feature with Cursor CLI
agent chat "Implement [feature description]" --print --trust

# 3. Add tests
agent chat "Add tests for new feature" --print --trust

# 4. Update documentation
agent chat "Update README with new feature docs" --print --trust

# 5. Commit changes
git add .
agent chat "Generate commit message for new feature" --print --trust
\`\`\`

## Fixing Bug
\`\`\`bash
# 1. Reproduce issue
agent chat "Analyze bug report #[number]" --mode=ask --print --trust

# 2. Identify root cause
agent chat "Find root cause in codebase" --mode=ask --print --trust

# 3. Fix bug
agent chat "Fix the identified bug" --print --trust

# 4. Add regression test
agent chat "Add test to prevent regression" --print --trust

# 5. Verify fix
agent chat "Run test suite to verify fix" --print --trust
\`\`\`

## Code Review
\`\`\`bash
# Review specific changes
agent chat "Review changes in file [filename] for quality and security" --mode=ask --print --trust

# Review pull request
agent chat "Review PR #[number] for code quality issues" --mode=ask --print --trust
\`\`\`
EOF

# 6. Create project context file
echo "6. Creating project context file..."
cat > .cursor/context/project-info.json << EOF
{
  "projectName": "$PROJECT_NAME",
  "projectPath": "$PROJECT_PATH",
  "configuredAt": "$(date -Iseconds)",
  "cursorVersion": "$(agent --version 2>/dev/null || echo 'unknown')",
  "rules": [
    "project-context.md",
    "git-workflow.md",
    "agent-workflows.md"
  ]
}
EOF

# 7. Create agent helper script
echo "7. Creating agent helper script..."
cat > cursor-agent-helper.sh << 'EOF'
#!/bin/bash
# Cursor Agent Helper for $PROJECT_NAME

set -e

PROJECT_NAME="$PROJECT_NAME"
PROJECT_PATH="$(pwd)"

# Function to run agent with project context
run_agent() {
    local task="$1"
    local mode="${2:-chat}"
    local output_format="${3:-text}"
    
    echo "🔧 Running agent task: $task"
    echo "   Mode: $mode | Output: $output_format"
    echo ""
    
    agent chat "$task" --print --trust --output-format "$output_format"
}

# Function for feature development
new_feature() {
    local feature_name="$1"
    local description="$2"
    
    if [ -z "$feature_name" ]; then
        echo "Usage: new_feature <branch-name> <description>"
        return 1
    fi
    
    echo "🚀 Starting new feature: $feature_name"
    echo "Description: $description"
    echo ""
    
    # Create branch
    git checkout -b "feat/$feature_name"
    
    # Implement feature
    run_agent "Implement feature: $description. Follow project rules in .cursor/rules/"
    
    echo ""
    echo "✅ Feature implementation complete"
    echo "Next steps:"
    echo "1. Add tests: run_agent 'Add tests for $description'"
    echo "2. Update docs: run_agent 'Update documentation for $description'"
    echo "3. Commit: git add . && agent chat 'Generate commit message for $description' --print --trust"
}

# Function for bug fixes
fix_bug() {
    local bug_id="$1"
    local description="$2"
    
    if [ -z "$bug_id" ]; then
        echo "Usage: fix_bug <bug-id> <description>"
        return 1
    fi
    
    echo "🐛 Fixing bug: $bug_id"
    echo "Description: $description"
    echo ""
    
    # Create fix branch
    git checkout -b "fix/$bug_id"
    
    # Analyze and fix
    run_agent "Analyze and fix bug: $description. Check for similar issues in codebase." --mode=ask
    run_agent "Implement fix for bug: $description"
    run_agent "Add regression test for bug: $description"
    
    echo ""
    echo "✅ Bug fix complete"
}

# Function for code review
code_review() {
    local target="$1"
    
    if [ -z "$target" ]; then
        echo "Usage: code_review <file|pr-number|'staged'>"
        return 1
    fi
    
    echo "🔍 Code review: $target"
    echo ""
    
    if [ "$target" = "staged" ]; then
        run_agent "Review staged changes for code quality, security, and best practices" --mode=ask
    elif [[ "$target" =~ ^[0-9]+$ ]]; then
        run_agent "Review pull request #$target for code quality and security issues" --mode=ask
    else
        run_agent "Review file $target for code quality and improvement opportunities" --mode=ask
    fi
}

# Main menu
if [ $# -eq 0 ]; then
    echo "📋 Cursor Agent Helper - $PROJECT_NAME"
    echo "========================================"
    echo ""
    echo "Available commands:"
    echo "  run_agent <task> [mode] [output-format]  - Run agent with task"
    echo "  new_feature <name> <description>         - Start new feature"
    echo "  fix_bug <id> <description>               - Fix bug"
    echo "  code_review <target>                     - Review code"
    echo ""
    echo "Project: $PROJECT_NAME"
    echo "Path: $PROJECT_PATH"
    echo ""
fi
EOF

chmod +x cursor-agent-helper.sh

# 8. Create README for agents
echo "8. Creating agent README..."
cat > AGENTS.md << EOF
# Agent Instructions for $PROJECT_NAME

## Project Overview
- **Name**: $PROJECT_NAME
- **Path**: $PROJECT_PATH
- **Configured**: $(date)

## Cursor CLI Configuration
This project has been configured for Cursor CLI agent usage with:
- Project-specific rules in \`.cursor/rules/\`
- Git workflow guidelines
- Technology-specific standards
- Agent helper scripts

## Quick Start for Agents

### 1. Navigate to Project
\`\`\`bash
cd "$PROJECT_PATH"
\`\`\`

### 2. Use Agent Helper
\`\`\`bash
./cursor-agent-helper.sh
\`\`\`

### 3. Common Tasks

#### Add Feature
\`\`\`bash
./cursor-agent-helper.sh new_feature "user-profile" "Add user profile editing"
\`\`\`

#### Fix Bug
\`\`\`bash
./cursor-agent-helper.sh fix_bug "login-error" "Fix login timeout issue"
\`\`\`

#### Code Review
\`\`\`bash
./cursor-agent-helper.sh code_review "staged"
./cursor-agent-helper.sh code_review "src/components/User.js"
\`\`\`

## Project Rules
Cursor CLI will automatically apply rules from:
- \`.cursor/rules/project-context.md\`
- \`.cursor/rules/git-workflow.md\`
- \`.cursor/rules/agent-workflows.md\`
- Technology-specific rules (\`.cursor/rules/javascript.md\`, etc.)

## Git Integration
- Follow branch naming conventions
- Use conventional commits
- Reference issues in commit messages
- Update documentation with changes

## Agent Best Practices
1. Always work in feature branches
2. Run tests before committing
3. Update documentation
4. Follow existing code patterns
5. Use the helper script for consistency

## Troubleshooting
- **Authentication**: Run \`agent login\` or set \`CURSOR_API_KEY\`
- **Workspace trust**: Use \`--trust\` flag
- **Project context**: Ensure you're in correct directory
EOF

# Summary
echo ""
echo "✅ Configuration Complete!"
echo "=========================="
echo ""
echo "Project: $PROJECT_NAME"
echo "Path: $PROJECT_PATH"
echo ""
echo "Created:"
echo "  📁 .cursor/rules/ - Project-specific rules"
echo "  📁 .cursor/context/ - Project context files"
echo "  📄 cursor-agent-helper.sh - Agent helper script"
echo "  📄 AGENTS.md - Agent instructions"
echo ""
echo "Next Steps:"
echo "1. Review the configuration: cat AGENTS.md"
echo "2. Test the helper: ./cursor-agent-helper.sh"
echo "3. Train agents on project-specific workflows"
echo "4. Commit configuration to version control"
echo ""
echo "Agents can now use:"
echo "  agent chat \"<task>\" --print --trust --cwd \"$PROJECT_PATH\""