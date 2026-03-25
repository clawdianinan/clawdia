# Skill: Cursor CLI Development

## Purpose
Integrate Cursor CLI (`agent` command) into OpenClaw workflows for terminal-based AI coding.

## Overview
Cursor CLI provides AI-powered coding directly in the terminal with access to multiple models (GPT-5.3-Codex variants, Composer, etc.) through your Cursor subscription.

## Prerequisites

### Installation
```bash
# Already installed via Homebrew Cask
# Binary: /Users/clawdia/.local/bin/agent
# Symlink: /opt/homebrew/bin/cursor-agent (compatibility)
```

### Authentication
```bash
# Check status
agent status

# Login (if needed)
agent login

# View available models
agent models
```

## Available Models (Complete Catalog)

### **Your Preferred Models:**
1. **`auto`** - **YOUR FAVORITE** - Smart selection with GENEROUS limits (Auto + Composer pool)
2. **`composer-2`** - **SECOND CHOICE** - Affordable, balanced (Auto + Composer pool)
3. **`composer-2-fast`** - Faster version

### **Complete Model List (From Cursor Docs):**

#### **Cursor Models (Auto + Composer Pool - Your Main Pool):**
- `auto` - Smart selection, generous limits ($1.25/M input, $6.00/M output)
- `composer-2` - Affordable, balanced ($0.50/M input, $2.50/M output)
- `composer-2-fast` - Faster version
- `composer-1.5` - Hidden by default
- `composer-1` - Hidden by default

#### **OpenAI GPT Family (API Pool):**
- `gpt-5.3-codex` - Flagship coding model ($1.75/M input, $14.00/M output)
- `gpt-5.3-codex-high` - High reasoning variant
- `gpt-5.3-codex-fast` - Faster variant
- `gpt-5.3-codex-low` - Lower cost variant
- `gpt-5.3-codex-xhigh` - Extra high quality
- `gpt-5.2-codex` - GPT-5.2 Codex
- `gpt-5.1-codex-max` - GPT-5.1 Codex Max
- `gpt-5.1-codex-mini` - Smaller variant
- `gpt-5` - GPT-5 base
- `gpt-5-fast` - Faster GPT-5
- `gpt-5-mini` - Smaller GPT-5
- `gpt-5.4` - Latest GPT-5.4
- `gpt-5.4-mini` - Smaller GPT-5.4
- `gpt-5.4-nano` - Smallest, most cost-optimized

#### **Anthropic Claude Family (API Pool):**
- `claude-4.6-opus` - Latest Opus
- `claude-4.6-sonnet` - Latest Sonnet
- `claude-4.5-opus` - Opus 4.5
- `claude-4.5-sonnet` - Sonnet 4.5
- `claude-4.5-haiku` - Haiku 4.5

#### **Google Gemini Family (API Pool):**
- `gemini-3-pro` - Gemini 3 Pro
- `gemini-3.1-pro` - Gemini 3.1 Pro
- `gemini-3-flash` - Gemini 3 Flash
- `gemini-2.5-flash` - Gemini 2.5 Flash
- `gemini-3-pro-image-preview` - Image generation model

#### **Other Models (API Pool):**
- `grok-4.20` - xAI Grok
- `kimi-k2.5` - Moonshot Kimi

## Commands

### Basic Usage
```bash
# Interactive chat mode
agent chat "Fix the bug in this function"

# Non-interactive (script mode)
agent --print "Generate a React component" --output-format text

# With specific model
agent chat "Refactor code" --model gpt-5.3-codex-high

# Resume previous session
agent ls          # List sessions
agent resume      # Resume latest
agent resume 2    # Resume session #2
```

### Advanced Features
```bash
# Custom headers
agent chat "Analyze code" -H "X-Custom-Header: value"

# Workspace isolation
agent chat "Fix bugs" --worktree bugfix-branch

# Stream partial output
agent --print "Generate code" --stream-partial-output --output-format stream-json
```

## Integration with OpenClaw

### For Development Agents (Trinity, Morpheus, Cypher)
```bash
# When terminal-based coding is needed
agent chat "Implement feature based on PRD"

# For complex refactoring
agent --print "Refactor entire module for performance" --output-format text

# For bug fixing
agent chat "Find and fix all bugs in current directory"
```

### Session Management
```bash
# Create new chat (returns ID)
agent create-chat

# List all chats
agent ls

# Resume specific chat
agent resume [chat-id]
```

## Use Cases

### 1. Terminal-Based Refactoring
```bash
# Large-scale code changes
agent chat "Refactor the entire authentication system to use JWT tokens"

# With model specification
agent chat "Optimize database queries" --model gpt-5.3-codex-high
```

### 2. Bug Hunting & Fixing
```bash
# Find bugs in current codebase
agent chat "Find one critical bug and fix it"

# Security scanning
agent chat "Find security vulnerabilities in the code"
```

### 3. Code Generation
```bash
# Generate complete modules
agent --print "Generate a complete user management API with Express.js" --output-format text

# Component generation
agent chat "Create a responsive dashboard component with React and Tailwind"
```

### 4. Documentation
```bash
# Generate documentation
agent chat "Generate comprehensive API documentation for all endpoints"

# Code comments
agent chat "Add detailed comments to all functions in this file"
```

## Model Selection Guide (Official + Your Preferences)

### **Official Usage Pools:**

#### **1. Auto + Composer Pool (Your Preferred)**
- **Significantly more included usage** with Auto or Composer 2
- **Designed for everyday agentic coding** at lower cost
- **Resets monthly** with billing cycle

#### **2. API Pool**
- **Charged at model's API price**
- **Individual plans include at least $20/month** API usage
- **Use only for specific model needs**

### **Primary Choices (Recommended):**
1. **`auto`** - **YOUR FAVORITE** - Smart selection with generous limits ($1.25/M input)
2. **`composer-2`** - **SECOND CHOICE** - Affordable, balanced ($0.50/M input)
3. **`composer-2-fast`** - Faster version when speed is critical

### **For Specific Needs (API Pool):**

#### **Quality Priority:**
- **`gpt-5.3-codex-high`** - High reasoning GPT-5.3 ($1.75/M input)
- **`claude-4.6-opus`** - Highest quality ($5.00/M input, expensive)
- **`claude-4.6-sonnet`** - Balanced Claude ($3.00/M input)

#### **Speed Priority:**
- **`composer-2-fast`** - Fastest Composer variant
- **`gpt-5.3-codex-fast`** - Fast GPT-5.3 variant
- **`gpt-5.4`** - Latest GPT with speed options ($2.50/M input)

#### **Cost Optimization:**
- **`gpt-5.4-nano`** - Cheapest option ($0.20/M input)
- **`composer-2`** - Already affordable ($0.50/M input)
- **`auto`** - Smart cost/quality balance with pool benefits

#### **Latest Features:**
- **`gpt-5.4`** - Latest GPT generation ($2.50/M input)
- **`gemini-3-pro-image-preview`** - Image generation ($2.00/M input + image fees)
- **`gpt-5.3-codex-spark-preview`** - Latest GPT-5.3 features

## Workflow Integration

### Git Worktree Support
```bash
# Create isolated worktree
agent chat "Implement feature" --worktree feature-branch

# With specific base branch
agent chat "Fix bug" --worktree bugfix --worktree-base main
```

### MCP Server Integration
```bash
# Manage MCP servers
agent mcp list
agent mcp install [server-name]
```

### Shell Integration
```bash
# Install shell integration
agent install-shell-integration

# Adds agent command completion to ~/.zshrc
```

## Best Practices

### 1. Start Simple
```bash
# Begin with chat mode
agent chat "Help me understand this code"

# Then move to specific tasks
agent chat "Now refactor this function"
```

### 2. Use Appropriate Model (Your Preferences)
```bash
# Default (your favorite)
agent chat "General task"  # Uses 'auto' with generous limits

# Affordable balanced choice
agent chat "Balanced task" --model composer-2

# Speed critical
agent chat "Quick fix" --model composer-2-fast

# Quality critical  
agent chat "Complex design" --model gpt-5.3-codex-high

# Latest features
agent chat "Innovative solution" --model gpt-5.3-codex-spark-preview
```

### 3. Manage Sessions
```bash
# Regular cleanup
# Sessions persist, manage with ls/resume

# For long-running work
agent chat "Multi-step refactoring"  # Keep session open
```

### 4. Output Formats
```bash
# For scripts/automation
agent --print "Generate code" --output-format text

# For JSON parsing
agent --print "Analyze code" --output-format json

# For streaming
agent --print "Long generation" --output-format stream-json --stream-partial-output
```

## Cost & Limit Considerations (Based on Cursor Docs)

### **Two Usage Pools System:**

#### **1. Auto + Composer Pool (YOUR PREFERRED)**
- **Significantly more included usage** with Auto or Composer 2
- **Designed for everyday agentic coding** at lower cost
- **Resets monthly** with billing cycle
- **Your models**: `auto`, `composer-2`, `composer-2-fast`

#### **2. API Pool**
- **Charged at model's API price**
- **Individual plans include at least $20/month** API usage
- **Used when selecting specific models** (not Auto/Composer)

### **Your Optimized Strategy:**

#### **Primary Usage (Maximize Limits):**
```bash
# Use AUTO for generous limits (default)
agent chat "General task"

# Or explicitly
agent chat "Task" --model auto
```

#### **Secondary (Affordable Quality):**
```bash
# Composer 2 for extended sessions
agent chat "Extended work" --model composer-2

# Fast version when needed
agent chat "Quick task" --model composer-2-fast
```

#### **Specific Needs Only (API Pool - Expensive):**
```bash
# Quality-critical
agent chat "Complex work" --model gpt-5.3-codex-high

# Latest features
agent chat "Innovation" --model gpt-5.3-codex-spark-preview

# Claude for specific reasoning
agent chat "Deep analysis" --model claude-4.6-opus
```

### **Pricing Summary:**

#### **Auto + Composer Pool (Your Main Pool):**
- **`auto`**: $1.25/M input, $6.00/M output
- **`composer-2`**: $0.50/M input, $2.50/M output
- **Generous included usage** in monthly plans

#### **API Pool (Use Sparingly):**
- **GPT-5.3-Codex**: $1.75/M input, $14.00/M output
- **Claude 4.6 Opus**: $5.00/M input, $25.00/M output
- **Gemini 3 Pro**: $2.00/M input, $12.00/M output

### **Plan Comparison:**
| Plan | Price | API Usage Included | Auto + Composer |
|------|-------|-------------------|-----------------|
| **Pro** | $20/mo | $20 | Generous included usage |
| **Pro Plus** | $60/mo | $70 | Generous included usage |
| **Ultra** | $200/mo | $400 | Generous included usage |

### **Key Insight:**
**Your preference for `auto` then `composer-2` is optimal** - it maximizes your included usage limits while maintaining quality! 🎉

## Troubleshooting

### Common Issues

1. **Authentication errors**
   ```bash
   agent logout
   agent login
   ```

2. **Model not available**
   ```bash
   agent models  # Check available models
   agent chat "Task" --model composer-2  # Use available model
   ```

3. **Session errors**
   ```bash
   # List and clean up
   agent ls
   # Resume or start fresh
   ```

4. **Command not found**
   ```bash
   # Check installation
   which agent
   # Should be: /Users/clawdia/.local/bin/agent
   ```

### Performance Tips
- Use `--print` for non-interactive tasks
- Specify model to avoid auto-selection overhead
- Use worktrees for isolated projects
- Close unused sessions

## Integration Examples

### With OpenClaw Agents
```bash
# Trinity (Implementation)
agent chat "Implement the user authentication flow as specified in PRD"

# Morpheus (QA)
agent chat "Find bugs and write tests for this module"

# Cypher (Security)
agent chat "Perform security audit on this codebase"
```

### In Scripts
```bash
#!/bin/bash
# Automated code generation
agent --print "Generate $1 component" --output-format text > "src/components/$1.js"
```

### CI/CD Integration
```bash
# GitHub Actions example
# Use agent --print for automated code reviews
```

## Updates
```bash
# Update Cursor CLI
agent update

# Check version
agent --version
```

## Security Notes
- Cursor CLI can read, modify, and delete files
- Can execute shell commands with approval
- Use only in trusted environments
- Review generated code before committing

---

**Next**: Use `dev-tool-router` to determine when Cursor CLI is the best choice (terminal-based, complex refactoring, etc.).