# Cursor CLI Quick Reference for Agents

## 🎯 Core Principle
**Always work within project context.** Navigate to project directory first, or use `--cwd` flag.

## 📋 Basic Commands

### Authentication & Setup
```bash
# Check if logged in
agent status

# Login (if needed)
agent login

# Set API key (for automation)
export CURSOR_API_KEY=your_key_here
```

### Project Context
```bash
# Navigate to project FIRST
cd /path/to/project

# Or use --cwd flag
agent chat "<task>" --print --trust --cwd /path/to/project
```

### Basic Task Execution
```bash
# Standard format
agent chat "<describe task>" --print --trust

# With JSON output for parsing
agent chat "<task>" --print --trust --output-format json

# Analysis mode (no changes)
agent chat "<analyze>" --mode=ask --print --trust

# Planning mode
agent chat "<plan>" --mode=plan --print --trust
```

## 🔗 Linking to Local Projects

### Step 1: Project Configuration
```bash
# Run configuration script
bash /Users/clawdia/.openclaw/workspace/project_cursor_config.sh "Project Name" "/path/to/project"

# This creates:
# - .cursor/rules/ - Project rules
# - cursor-agent-helper.sh - Helper script
# - AGENTS.md - Instructions
```

### Step 2: Use Project Helper
```bash
cd /path/to/project
./cursor-agent-helper.sh

# Common helper commands:
./cursor-agent-helper.sh new_feature "feature-name" "description"
./cursor-agent-helper.sh fix_bug "bug-id" "description"
./cursor-agent-helper.sh code_review "staged"
```

### Step 3: Project-Specific Workflows
```bash
# Feature development
git checkout -b feat/feature-name
agent chat "Implement feature according to project rules" --print --trust
agent chat "Add tests for new feature" --print --trust
git add . && git commit -m "feat: description"

# Bug fixes
git checkout -b fix/bug-id
agent chat "Analyze and fix bug #id" --print --trust
agent chat "Add regression test" --print --trust

# Code review
agent chat "Review changes in file.js" --mode=ask --print --trust
```

## 📁 Project Structure Awareness

### Always Check
```bash
# Before starting, understand project
agent chat "Analyze project structure and main components" --mode=ask --print --trust

# Check dependencies
agent chat "Review package.json/requirements.txt" --mode=ask --print --trust
```

### Respect Existing Patterns
- Follow project's coding style
- Use existing directory structure
- Maintain consistent naming conventions
- Update tests when modifying code

## 🔄 Git Integration

### Standard Workflow
```bash
# 1. Start from clean state
git status

# 2. Create feature branch
git checkout -b feat/description

# 3. Implement with Cursor CLI
agent chat "Implement feature" --print --trust

# 4. Stage changes
git add .

# 5. Commit (Cursor can help)
agent chat "Generate commit message" --print --trust

# 6. Push to remote
git push origin feat/description
```

### Commit Message Convention
```
feat: add user authentication
fix: resolve login timeout issue
docs: update API documentation
style: format code according to guidelines
refactor: simplify payment processing
test: add unit tests for auth service
chore: update dependencies
```

## 🛠️ Agent-Specific Workflows

### Trinity (Development)
```bash
# Feature implementation
agent chat "Implement [feature] following project architecture" --print --trust

# Code refactoring
agent chat "Refactor [module] to improve performance/maintainability" --print --trust
```

### Morpheus (QA/Testing)
```bash
# Test generation
agent chat "Generate comprehensive tests for [component]" --print --trust

# Bug hunting
agent chat "Find edge cases and potential bugs in [module]" --mode=ask --print --trust
```

### Cypher (Security)
```bash
# Security audit
agent chat "Scan [codebase] for security vulnerabilities" --print --trust

# Code hardening
agent chat "Add security measures to [component]" --print --trust
```

### Fela (Design/Content)
```bash
# UI/UX implementation
agent chat "Create [component] with modern design patterns" --print --trust

# Content generation
agent chat "Generate [content] following brand guidelines" --print --trust
```

## ⚠️ Common Issues & Solutions

### 1. "Authentication required"
```bash
# Check status
agent status

# Login or set API key
agent login
# OR
export CURSOR_API_KEY=your_key
```

### 2. "Workspace trust required"
```bash
# Add --trust flag
agent chat "<task>" --print --trust
```

### 3. "Project not found"
```bash
# Use absolute path with --cwd
agent chat "<task>" --print --trust --cwd /absolute/path/to/project

# Or navigate first
cd /path/to/project
agent chat "<task>" --print --trust
```

### 4. "Output parsing issues"
```bash
# Use JSON format
agent chat "<task>" --print --trust --output-format json
```

## 📊 Monitoring & Best Practices

### Log Agent Activities
```bash
# Create log file
LOGFILE="cursor-agent-$(date +%Y%m%d-%H%M%S).log"

# Run with logging
agent chat "<task>" --print --trust 2>&1 | tee "$LOGFILE"
```

### Safety Measures
```bash
# Backup before major changes
agent chat "Create backup of critical files" --print --trust

# Test in isolation
git stash
agent chat "<test change>" --print --trust
git stash pop
```

### Performance Tips
```bash
# Batch related tasks
agent chat "1. Fix lint errors\n2. Add type hints\n3. Update docs" --print --trust

# Use specific file context
agent chat "Update src/components/Button.js to add new prop" --print --trust
```

## 🚀 Quick Start Checklist

### For New Projects
1. ✅ Navigate: `cd /path/to/project`
2. ✅ Configure: Run project configuration script
3. ✅ Analyze: `agent chat "Analyze project structure" --mode=ask --print --trust`
4. ✅ Implement: Use helper script or direct commands
5. ✅ Commit: Follow git workflow

### For Existing Projects
1. ✅ Check: `agent status` and project location
2. ✅ Update: Ensure .cursor/rules/ exists
3. ✅ Context: Understand project with analysis mode
4. ✅ Execute: Work within project rules
5. ✅ Verify: Run tests and check changes

## 📞 Support Resources

### Documentation
- `CURSOR_CLI_AGENT_GUIDE.md` - Comprehensive training guide
- `AGENTS.md` in project root - Project-specific instructions
- `.cursor/rules/` - Project rules and conventions

### Helper Scripts
- `cursor-agent-helper.sh` - Project helper
- `agent_cursor_training.sh` - Training exercises
- `project_cursor_config.sh` - Configuration setup

### Testing Commands
```bash
# Test Cursor CLI is working
agent chat "Hello, test response" --print --trust

# Test project context
cd /path/to/project
agent chat "List main project files" --print --trust
```

---

**Remember**: Always work within project context, follow project rules, and maintain version control discipline. Use helper scripts for consistency across agents.