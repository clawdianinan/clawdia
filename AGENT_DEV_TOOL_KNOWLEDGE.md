# Agent Development Tool Knowledge Base

## 🎯 PURPOSE
This document provides agents with comprehensive knowledge about development tools, their capabilities, workflows, and best practices.

## 📚 TOOL CATALOG

### 1. CLAUDE CODE (Pro)
**Primary Use**: Quality-critical work, complex reasoning, planning

#### **Key Features:**
- **`/plan` mode**: Design approach before coding (Shift+Tab or `/plan`)
- **Multiple modes**: Agent, Plan, Ask (rotate with Shift+Tab)
- **Worktree support**: Isolated git worktrees for parallel sessions
- **MCP integration**: Model Context Protocol for extended functionality
- **Remote control**: Control from Claude.ai or Claude app

#### **Essential Commands:**
```bash
# Interactive with initial prompt
claude "Explain this project"

# Print mode (non-interactive)
claude --print "Fix bug in auth.js"

# Continue previous conversation
claude --continue
claude -c

# Resume specific session
claude --resume "auth-refactor"

# With specific model
claude --model claude-sonnet-4-6 --print "Complex task"

# Plan mode from start
claude --permission-mode plan "Design architecture"
```

#### **Workflow Patterns:**

**Planning Workflow:**
```bash
# Start in plan mode
claude --permission-mode plan "Design user authentication system"

# After plan is approved, switch to implementation
# Type: /agent (to switch to agent mode)
# Or: Shift+Tab to rotate modes
```

**Parallel Development:**
```bash
# Terminal 1: Feature development
claude -w feature-auth "Implement auth flow"

# Terminal 2: Code review (different worktree)
claude -w review-auth "Review auth changes"

# Terminal 3: Documentation
claude -w docs-auth "Update API docs"
```

**Context Management:**
```bash
# Add additional directories
claude --add-dir ../shared ../lib "Analyze dependencies"

# Custom system prompt
claude --append-system-prompt "Always use TypeScript" "Refactor to TS"

# Limit API usage
claude --print --max-budget-usd 5.00 "Generate tests"
```

#### **Agent Tips:**
1. **Start with `/plan`** for complex tasks
2. **Use worktrees** for parallel work
3. **Monitor context** - use `/compress` to free space
4. **Set effort level** with `--effort high` for critical work
5. **Use `--print` mode** for automation/scripts

---

### 2. CURSOR CLI (`agent`)
**Primary Use**: Terminal-based work, planning, Cursor ecosystem

#### **Key Features:**
- **`/plan` mode**: Detailed implementation planning (Shift+Tab or `/plan`)
- **Three modes**: Agent, Plan, Ask (rotate with Shift+Tab)
- **Cloud Agent**: Handoff to cloud for continuous execution
- **MCP support**: Automatic `mcp.json` configuration detection
- **Rules system**: `.cursor/rules` directory for project-specific guidance

#### **Essential Commands:**
```bash
# Interactive chat
agent chat "Fix the bug in this function"

# Non-interactive (script mode)
agent --print "Generate React component" --output-format text

# Plan mode from start
agent chat --mode=plan "Design database schema"

# Cloud handoff
agent -c "Refactor auth module and add tests"

# List sessions
agent ls

# Resume latest
agent resume

# Resume specific
agent resume 2
```

#### **Workflow Patterns:**

**Planning → Implementation:**
```bash
# Start with planning
agent chat --mode=plan "Implement user dashboard"

# After plan approval, switch to implementation
# Type: /agent (or Shift+Tab)

# Or start directly in agent mode
agent chat "Implement based on approved plan"
```

**Cloud Continuation:**
```bash
# Start in cloud mode
agent -c "Long-running refactoring"

# Check status at: cursor.com/agents
# Resume later with same session ID
```

**Project Rules:**
```bash
# Cursor reads these automatically:
# - .cursor/rules/ directory
# - AGENTS.md at project root
# - CLAUDE.md at project root

# Example AGENTS.md:
# # Commands
# - `npm run build`: Build the project
# - `npm run typecheck`: Run typechecker
# 
# # Code style
# - Use ES modules (import/export)
# - Destructure imports when possible
```

#### **Agent Tips:**
1. **Use `--mode=plan`** for complex tasks
2. **Leverage Cloud Agent** for long-running work
3. **Set up project rules** in `.cursor/rules/`
4. **Use `--print --output-format json`** for script integration
5. **Monitor context** with `/compress`

---

### 3. CODEX CLI (OpenAI)
**Primary Use**: GPT-4 specific tasks, OpenAI ecosystem

#### **Key Features:**
- **OpenAI integration**: Direct GPT-4/GPT-5 access
- **Cloud tasks**: Launch Codex Cloud tasks from terminal
- **Environment support**: Choose different environments
- **Automation**: Scriptable with `exec` command

#### **Essential Commands:**
```bash
# Basic usage
codex "Implement OpenAI API wrapper"

# Full auto mode (bypasses prompts)
codex --full-auto "Fix failing tests"

# With API key (instead of OAuth)
export OPENAI_API_KEY="sk-..."
codex "Task using API key"

# Exec command for automation
codex exec "Update CHANGELOG"

# OSS mode
codex exec --oss "Fix open source issues"
```

#### **Workflow Patterns:**

**CI/CD Integration:**
```bash
# GitHub Actions example
# .github/workflows/codex.yml
- name: Run Codex
  run: |
    npm i -g @openai/codex
    codex exec --full-auto "Update CHANGELOG"
  env:
    OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
```

**Project Automation:**
```bash
# Script for regular tasks
#!/bin/bash
codex --full-auto "Run tests and fix any failures"
codex "Update documentation based on recent changes"
```

#### **Agent Tips:**
1. **Use `--full-auto`** for automated workflows
2. **Set `OPENAI_API_KEY`** for CI/CD environments
3. **Use `exec` command** for scriptable automation
4. **Monitor rate limits** - Codex has usage limits

---

### 4. GEMINI CLI (Google)
**Primary Use**: Cost-sensitive tasks, balanced quality

#### **Key Features:**
- **Google Gemini models**: Access to Gemini 3 Pro, Flash, etc.
- **Cost-effective**: Lower pricing than OpenAI/Anthropic
- **Image generation**: Via Nano Banana Pro skill
- **Extensions system**: Code-review, security-scan, etc.

#### **Essential Commands:**
```bash
# Basic prompt
gemini --prompt "Write a React component"

# With model specification
gemini --model "gemini-2.0-flash" --prompt "Quick fix"

# Interactive prompt
gemini --prompt-interactive "Start code review"

# Sandbox mode (safer)
gemini --sandbox --prompt "Analyze risky code"

# With extensions
gemini --extensions code-review,security-scan --prompt "Review code"
```

#### **Workflow Patterns:**

**Cost-Optimized Development:**
```bash
# Use faster/cheaper models for simple tasks
gemini --model "gemini-2.0-flash" --prompt "Fix typos"

# Use better models for complex work
gemini --model "gemini-3-pro" --prompt "Design architecture"

# Batch related tasks
gemini --prompt "1. Fix bug 2. Write test 3. Update docs"
```

**Security Scanning:**
```bash
# Use security extension
gemini --extensions security-scan --prompt "Scan for vulnerabilities"

# Sandbox for unknown code
gemini --sandbox --prompt "Execute third-party code"
```

#### **Agent Tips:**
1. **Use `gemini-2.0-flash`** for speed/cost balance
2. **Enable extensions** for specialized tasks
3. **Use `--sandbox`** for untrusted code
4. **Monitor Google AI Studio** for usage/quota

---

### 5. QWEN3.5:9B (via Claude Code)
**Primary Use**: Free local option, cost-sensitive non-urgent tasks

#### **Key Features:**
- **Completely free**: Local inference, no API costs
- **Via Claude Code**: Uses Claude Code interface
- **6.6GB model**: Requires local storage
- **Slower but free**: Good for drafting/learning

#### **Essential Commands:**
```bash
# Launch via Claude Code
ollama launch claude --model qwen3.5:9b "Explain this code"

# For extended sessions
ollama launch claude --model qwen3.5:9b --continue

# With context file
cat context.txt | ollama launch claude --model qwen3.5:9b "Analyze"
```

#### **Workflow Patterns:**

**Learning/Drafting:**
```bash
# Use for non-urgent learning
ollama launch claude --model qwen3.5:9b "Explain React hooks"

# Draft documentation
ollama launch claude --model qwen3.5:9b "Draft README for project"

# Code exploration
ollama launch claude --model qwen3.5:9b "Explore this codebase structure"
```

#### **Agent Tips:**
1. **Use for learning** not production work
2. **Be patient** - local inference is slower
3. **Great for drafting** before using paid tools
4. **Monitor memory usage** - 6.6GB model

---

### 6. NANO BANANA PRO (Image Generation)
**Primary Use**: Image generation/editing via Gemini 3 Pro Image

#### **Key Features:**
- **Gemini 3 Pro Image**: Google's image generation model
- **Same API key**: Uses `GEMINI_API_KEY`
- **Skill-based**: Use `nano-banana-pro` skill
- **Low cost**: Image generation at API rates

#### **Usage:**
```bash
# Use the skill directly
# Prompt: "Generate app logo with tech theme"

# Or via routing system
./route-tool.sh "Generate logo" --needs-images
```

---

## 🎯 DECISION FRAMEWORK

### **When to Use Which Tool:**

| Task Type | Primary Tool | Secondary | Why |
|-----------|--------------|-----------|-----|
| **Quality-critical** | Claude Code | Cursor CLI | Best reasoning, `/plan` mode |
| **Terminal + planning** | Cursor CLI | Claude Code | Terminal integration, Cloud Agent |
| **GPT-4 specific** | Codex CLI | - | OpenAI ecosystem requirement |
| **Cost-sensitive, urgent** | Gemini CLI | - | Low cost, decent speed |
| **Cost-sensitive, non-urgent** | Qwen3.5:9b | - | Free, local |
| **Image generation** | Nano Banana Pro | - | Gemini 3 Pro Image |
| **Unknown/General** | Claude Code | Gemini CLI | Default reliable choice |

### **Context Management Rules:**
1. **Always use 70% buffer** - Prevent overflow errors
2. **Use `/compress`** when context is full (Cursor/Claude)
3. **Trim large files** before including as context
4. **Monitor token usage** in tool outputs

### **Planning Workflow:**
1. **Start with `/plan` mode** for complex tasks
2. **Get approval** before implementation
3. **Break into phases** for large projects
4. **Document assumptions** and constraints

### **Cost Optimization:**
1. **Free first**: Qwen for drafting/learning
2. **Low cost**: Gemini for general work
3. **Premium only**: Claude/Codex for critical work
4. **Monitor usage**: Track API consumption

---

## 🔧 INTEGRATION PATTERNS

### **For Agent Teams:**

#### **Trinity (Implementation):**
```bash
# Start with planning
claude --permission-mode plan "Implement feature X"

# After approval, implement
claude --print "Implement based on plan" > implementation.txt

# Or use Cursor for terminal work
agent chat --mode=plan "Terminal-based implementation"
```

#### **Morpheus (QA/Testing):**
```bash
# Use Gemini for cost-effective testing
gemini --extensions test-gen --prompt "Generate tests for module"

# Or Claude for complex test scenarios
claude --print "Design comprehensive test suite"
```

#### **Cypher (Security):**
```bash
# Security scanning with Gemini
gemini --extensions security-scan --prompt "Scan for vulnerabilities"

# Or detailed analysis with Claude
claude --effort high --print "Security audit of auth system"
```

#### **Fela (Design/Images):**
```bash
# Image generation
# Use nano-banana-pro skill for logos/graphics

# Or describe to other tools
claude --print "Design UI mockup description for implementation"
```

### **Project-Specific Configuration:**

#### **Create `.cursor/rules/` for Cursor:**
```bash
mkdir -p .cursor/rules
cat > .cursor/rules/typescript.md << 'EOF'
# TypeScript Rules
- Use strict mode
- Prefer interfaces over types
- No `any` type allowed
- Use async/await over callbacks
EOF
```

#### **Create `AGENTS.md` for project context:**
```bash
cat > AGENTS.md << 'EOF'
# Project Guidelines
## Commands
- `npm run build`: Build project
- `npm run test`: Run tests
- `npm run lint`: Lint code

## Code Style
- Use functional components in React
- Prefer named exports
- Write comprehensive JSDoc comments

## Workflow
- Always run tests before committing
- Update documentation with features
- Follow existing patterns
EOF
```

---

## 🚀 QUICK REFERENCE

### **Starting Projects:**
```bash
# Complex project - start with planning
claude --permission-mode plan "Design new feature"

# Terminal-focused - use Cursor
agent chat --mode=plan "Terminal implementation"

# Cost-sensitive - use Gemini
gemini --prompt "Initial implementation draft"

# Free option - use Qwen
ollama launch claude --model qwen3.5:9b "Project exploration"
```

### **Context Management:**
```bash
# Always use safe executor for large context
./safe_tool_executor.sh claude "Task" large_context.txt

# Or trim manually first
head -n 1000 large_file.txt > context_snippet.txt
```

### **Monitoring & Optimization:**
1. **Track usage**: Each tool has dashboard/CLI for monitoring
2. **Set budgets**: Use `--max-budget-usd` flags where available
3. **Cache responses**: Reuse similar queries when possible
4. **Batch work**: Group related tasks to reduce API calls

---

## 📊 PERFORMANCE METRICS

| Tool | Speed | Cost | Quality | Best For |
|------|-------|------|---------|----------|
| **Claude Code** | Fast | High | Excellent | Complex reasoning, planning |
| **Cursor CLI** | Fast | Medium | Excellent | Terminal work, Cloud Agent |
| **Codex CLI** | Fast | High | Excellent | GPT-4 specific tasks |
| **Gemini CLI** | Fast | Low | Good | Cost-effective general work |
| **Qwen3.5:9b** | Slow | Free | Fair | Drafting, learning, exploration |

---

## 🎯 AGENT CHECKLIST

### **Before Starting Work:**
- [ ] **Check project configs** for tool preferences
- [ ] **Assess task complexity** to choose appropriate tool
- [ ] **Consider cost constraints** for tool selection
- [ ] **Plan context management** for large inputs

### **During Execution:**
- [ ] **Use `/plan` mode** for complex tasks
- [ ] **Monitor context usage** to prevent overflow
- [ ] **Follow project rules** from `.cursor/rules/` or `AGENTS.md`
- [ ] **Document decisions** for future reference

### **After Completion:**
- [ ] **Review output quality** against requirements
- [ ] **Check for errors** or warnings
- [ ] **Update documentation** if needed
- [ ] **Log tool usage** for optimization

---

**Updated**: March 20, 2026  
**Status**: Comprehensive agent knowledge base ready for use  
**Next**: Agents should reference this document before starting development work