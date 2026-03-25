# Cursor CLI Agent Training Guide

## 🎯 Purpose
Train OpenClaw agents to use Cursor CLI for development within specific projects/repositories, linking to local versions with proper context management.

## 📦 Prerequisites
- Cursor CLI installed: `agent --version` shows `2026.03.18-f6873f7` or later
- Authentication: `agent status` shows logged in status
- Workspace trust: Use `--trust` flag for automated operations

## 🚀 Core Commands for Agents

### 1. **Basic Command Structure**
```bash
# General format
agent chat "<task>" --print --trust [--output-format json] [--mode=ask|plan]

# With project context
agent chat "<task>" --print --trust --cwd /path/to/project
```

### 2. **Project-Specific Operations**

#### **Navigate to Project Directory**
```bash
# Always change to project directory first
cd /path/to/project

# Or use --cwd flag
agent chat "List project files" --print --trust --cwd /path/to/project
```

#### **Load Project Context**
```bash
# Read project structure
agent chat "Analyze project structure and main entry points" --print --trust

# Understand dependencies
agent chat "Review package.json/requirements.txt and summarize dependencies" --print --trust
```

#### **Project-Specific Rules**
Cursor CLI automatically reads:
- `.cursor/rules/` directory
- `AGENTS.md` at project root
- `CLAUDE.md` at project root

## 🔗 Linking to Local Version Control

### 1. **Git Integration**

#### **Check Git Status**
```bash
agent chat "Check git status and show uncommitted changes" --print --trust
```

#### **Review Changes**
```bash
agent chat "Review git diff for staged changes" --print --trust
```

#### **Commit Messages**
```bash
agent chat "Generate descriptive commit message for current changes" --print --trust
```

### 2. **Branch Management**

#### **Create Feature Branch**
```bash
agent chat "Create a new feature branch for user authentication" --print --trust
```

#### **Merge Assistance**
```bash
agent chat "Help resolve merge conflicts in package.json" --print --trust
```

## 📁 Project Context Management

### 1. **Project Initialization**

#### **New Project Setup**
```bash
# Initialize new project with Cursor CLI
agent chat "Initialize a new Node.js project with Express and TypeScript" --print --trust
```

#### **Existing Project Analysis**
```bash
# Analyze existing project
agent chat "Analyze project structure, identify main components and architecture" --print --trust
```

### 2. **File Operations with Context**

#### **Read Project Files**
```bash
# Read specific file with context
agent chat "Read and analyze src/index.js to understand entry point" --print --trust
```

#### **Modify Files**
```bash
# Update file with understanding of project context
agent chat "Update config.js to add new environment variables" --print --trust
```

#### **Create New Files**
```bash
# Create file in correct project structure
agent chat "Create new component in src/components/ with proper imports" --print --trust
```

## 🛠️ Agent Workflows by Project Type

### 1. **Node.js/TypeScript Projects**

```bash
# Package.json management
agent chat "Add new dependency to package.json and update imports" --print --trust

# TypeScript configuration
agent chat "Update tsconfig.json for better type checking" --print --trust

# Test setup
agent chat "Configure Jest testing for new component" --print --trust
```

### 2. **Python Projects**

```bash
# Virtual environment
agent chat "Set up virtual environment and install dependencies" --print --trust

# Requirements management
agent chat "Update requirements.txt with new packages" --print --trust

# Django/Flask specific
agent chat "Add new route to Flask app with proper structure" --print --trust
```

### 3. **React/Next.js Projects**

```bash
# Component creation
agent chat "Create new React component with TypeScript and Storybook" --print --trust

# API routes
agent chat "Add new API route to Next.js app with proper error handling" --print --trust

# State management
agent chat "Implement Redux slice for user authentication" --print --trust
```

## 🔄 Version Control Integration

### 1. **Git Workflow Automation**

#### **Feature Development**
```bash
# Start feature
agent chat "Create feature branch 'feat/user-auth' from main" --print --trust

# Make changes
agent chat "Implement user authentication middleware" --print --trust

# Stage changes
agent chat "Stage all changes for commit" --print --trust

# Commit
agent chat "Commit changes with message 'feat: add user authentication'" --print --trust
```

#### **Pull Request Preparation**
```bash
# Update branch
agent chat "Update feature branch with latest main" --print --trust

# Generate PR description
agent chat "Generate pull request description with changes and testing notes" --print --trust
```

### 2. **Local vs Remote Sync**

#### **Check Remote Status**
```bash
agent chat "Check if local branch is ahead/behind remote" --print --trust
```

#### **Sync Changes**
```bash
agent chat "Pull latest changes from remote and merge" --print --trust
```

## 📋 Agent Training Examples

### Example 1: **Add Feature to Existing Project**

```bash
# 1. Navigate to project
cd /projects/my-app

# 2. Analyze current state
agent chat "Analyze current codebase structure and identify where to add new feature" --print --trust

# 3. Create feature branch
agent chat "Create git branch 'feat/new-feature'" --print --trust

# 4. Implement feature
agent chat "Implement new dashboard widget showing user analytics" --print --trust

# 5. Update tests
agent chat "Add unit tests for new dashboard widget" --print --trust

# 6. Update documentation
agent chat "Update README with new feature documentation" --print --trust

# 7. Commit changes
agent chat "Commit all changes with descriptive message" --print --trust
```

### Example 2: **Fix Bug in Project**

```bash
# 1. Navigate to project
cd /projects/buggy-app

# 2. Reproduce issue
agent chat "Read bug report #42 and identify affected files" --print --trust

# 3. Analyze code
agent chat "Analyze src/components/BuggyComponent.js to find root cause" --print --trust

# 4. Fix bug
agent chat "Fix null pointer exception in BuggyComponent" --print --trust

# 5. Add regression test
agent chat "Add test to prevent regression of bug #42" --print --trust

# 6. Verify fix
agent chat "Run existing tests to ensure no regression" --print --trust
```

### Example 3: **Refactor Project**

```bash
# 1. Navigate to project
cd /projects/legacy-app

# 2. Analysis phase
agent chat "Analyze codebase for refactoring opportunities" --mode=ask --print --trust

# 3. Create refactor plan
agent chat "Create step-by-step refactoring plan" --mode=plan --print --trust

# 4. Execute refactor
agent chat "Refactor callback hell to async/await in API module" --print --trust

# 5. Update dependencies
agent chat "Update outdated dependencies safely" --print --trust

# 6. Verify functionality
agent chat "Run full test suite after refactoring" --print --trust
```

## 🎮 Practical Exercises for Agents

### Exercise 1: **Clone and Setup Project**
```bash
# Clone repository
git clone https://github.com/example/project.git
cd project

# Install dependencies
agent chat "Install project dependencies based on package.json" --print --trust

# Setup environment
agent chat "Configure environment variables from .env.example" --print --trust

# Run tests
agent chat "Run test suite to verify setup" --print --trust
```

### Exercise 2: **Add New Endpoint**
```bash
# In existing API project
agent chat "Add new POST /api/users endpoint with validation" --print --trust

# Update documentation
agent chat "Update API documentation with new endpoint" --print --trust

# Add tests
agent chat "Add integration tests for new endpoint" --print --trust
```

### Exercise 3: **Code Review**
```bash
# Review pull request
agent chat "Review PR #123 for code quality and security issues" --mode=ask --print --trust

# Generate review comments
agent chat "Generate constructive code review comments" --print --trust

# Suggest improvements
agent chat "Suggest specific improvements for the PR" --print --trust
```

## ⚙️ Configuration for Different Agents

### **Trinity (Core Development)**
```bash
# Focus: Implementation
agent chat "Implement feature according to spec" --print --trust

# Use: --mode=plan for complex features
agent chat "Plan architecture for new microservice" --mode=plan --print --trust
```

### **Morpheus (QA/Testing)**
```bash
# Focus: Testing
agent chat "Generate comprehensive test suite" --print --trust

# Use: --mode=ask for analysis
agent chat "Find edge cases in payment processing" --mode=ask --print --trust
```

### **Cypher (Security)**
```bash
# Focus: Security
agent chat "Scan for security vulnerabilities" --print --trust

# Use: Specific security rules
agent chat "Check for SQL injection vulnerabilities" --print --trust
```

## 🔧 Advanced: Project-Specific Rules

### Create `.cursor/rules/` Directory
```bash
# Project-specific rules
mkdir -p .cursor/rules

# Create rule file
cat > .cursor/rules/project-context.md << 'EOF'
# Project Context Rules

## Project: My Application
- Type: React/TypeScript
- State Management: Redux Toolkit
- Testing: Jest + React Testing Library
- Styling: Tailwind CSS

## Conventions
- Use functional components with hooks
- Write TypeScript interfaces for all props
- Follow Airbnb ESLint rules
- Use absolute imports from src/
EOF
```

### Link to Local Git Hooks
```bash
# Pre-commit hook using Cursor CLI
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# Run Cursor CLI for code review
agent chat "Review staged changes for code quality" --print --trust
EOF
chmod +x .git/hooks/pre-commit
```

## 📊 Monitoring & Logging

### Track Agent Activities
```bash
# Log file for agent actions
LOGFILE="/var/log/cursor-agent-$(date +%Y%m%d).log"

# Run command with logging
agent chat "Perform task" --print --trust 2>&1 | tee -a "$LOGFILE"
```

### Performance Metrics
```bash
# Time execution
time agent chat "Run complex refactoring" --print --trust
```

## 🚨 Error Handling & Recovery

### Safe Execution
```bash
# With error handling
if agent chat "Perform risky operation" --print --trust; then
    echo "Success"
else
    echo "Failed - check logs"
    # Recovery logic
    agent chat "Restore from backup" --print --trust
fi
```

### Backup Before Changes
```bash
# Create backup
agent chat "Create backup of critical files before modification" --print --trust
```

## 🎯 Quick Reference Card

```bash
# Basic: agent chat "<task>" --print --trust
# Project: agent chat "<task>" --print --trust --cwd /path
# Analysis: agent chat "<task>" --mode=ask --print --trust
# Planning: agent chat "<task>" --mode=plan --print --trust
# JSON output: agent chat "<task>" --print --trust --output-format json

# Git integration: Always run from project root
# Project rules: Use .cursor/rules/ for context
# Local linking: Use absolute paths for reliability
```

## 📞 Support & Troubleshooting

### Common Issues
1. **Authentication failed**: Run `agent login`
2. **Workspace trust required**: Add `--trust` flag
3. **Project not found**: Use `--cwd` with absolute path
4. **Output parsing issues**: Use `--output-format json`

### Debug Mode
```bash
# Verbose output
agent chat "Debug task" --print --trust --verbose
```

---

**Training Complete**: Agents are now equipped to use Cursor CLI within specific projects/repos with proper local version linking.