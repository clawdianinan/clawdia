# Agent Tool Quick Reference

## 🎯 ONE-MINUTE DECISION GUIDE

### **Ask Yourself:**

1. **Need images?** → **Nano Banana Pro**
2. **Terminal-based?** → **Cursor CLI** (`agent`)
3. **Quality-critical?** → **Claude Code** (`claude`)
4. **GPT-4 specific?** → **Codex CLI** (`codex`)
5. **Cost-sensitive + urgent?** → **Gemini CLI** (`gemini`)
6. **Cost-sensitive + not urgent?** → **Qwen3.5:9b**
7. **Don't know?** → **Claude Code** (default)

---

## 🚀 ESSENTIAL COMMANDS

### **Claude Code (Quality)**
```bash
# Planning first
claude --permission-mode plan "Design feature"

# Implementation
claude --print "Implement based on plan"

# Continue previous
claude --continue

# With specific model
claude --model claude-sonnet-4-6 --print "Task"
```

### **Cursor CLI (Terminal)**
```bash
# Planning mode
agent chat --mode=plan "Plan implementation"

# Cloud handoff
agent -c "Long-running task"

# Non-interactive
agent --print --output-format text "Generate code"

# Resume sessions
agent ls          # List
agent resume      # Latest
agent resume 2    # Specific
```

### **Codex CLI (OpenAI)**
```bash
# Basic usage
codex "GPT-4 task"

# Full auto (no prompts)
codex --full-auto "Automated fix"

# With API key
export OPENAI_API_KEY="sk-..."
codex "Task"
```

### **Gemini CLI (Cost-effective)**
```bash
# Quick tasks
gemini --model "gemini-2.0-flash" --prompt "Simple fix"

# Quality tasks
gemini --model "gemini-3-pro" --prompt "Complex work"

# With extensions
gemini --extensions code-review --prompt "Review code"
```

### **Qwen3.5:9b (Free)**
```bash
# Free local option
ollama launch claude --model qwen3.5:9b "Draft/learn"
```

---

## 🔑 KEY FEATURES BY TOOL

### **Planning Capabilities:**
- ✅ **Claude Code**: `/plan` mode (Shift+Tab or `/plan`)
- ✅ **Cursor CLI**: `/plan` mode (Shift+Tab or `/plan`)
- ❌ **Others**: No native planning mode

### **Context Management:**
- ✅ **All**: Use `safe_tool_executor.sh` for large context
- ✅ **Claude/Cursor**: `/compress` to free space
- ⚠️ **All**: Keep 70% buffer to prevent overflow

### **Project Integration:**
- ✅ **Cursor CLI**: Reads `.cursor/rules/`, `AGENTS.md`, `CLAUDE.md`
- ✅ **All**: Respect project configs via `project_tool_config.sh`
- ✅ **Claude Code**: Worktree support (`-w` flag)

### **Cost Management:**
- 💰 **Qwen**: Free (local)
- 💰 **Gemini**: Low cost
- 💰💰 **Cursor**: Medium (Auto+Composer pool)
- 💰💰💰 **Claude/Codex**: High (quality premium)

---

## 🎯 WORKFLOW TEMPLATES

### **Template 1: Complex Feature**
```bash
# 1. Plan with Claude
claude --permission-mode plan "Design authentication system"

# 2. Implement with appropriate tool
# If terminal preferred:
agent chat "Implement auth based on plan"
# If quality critical:
claude --print "Implement auth based on plan"
```

### **Template 2: Quick Bug Fix**
```bash
# Cost-sensitive + urgent:
gemini --prompt "Fix login bug in auth.js"

# Or if quality matters:
claude --print "Fix login bug in auth.js"
```

### **Template 3: Learning/Exploration**
```bash
# Free option:
ollama launch claude --model qwen3.5:9b "Explain React hooks"

# Or low-cost:
gemini --prompt "Learn about TypeScript generics"
```

### **Template 4: Automated Task**
```bash
# For CI/CD:
codex --full-auto "Update CHANGELOG"

# Or scriptable:
agent --print --output-format json "Generate config" > config.json
```

---

## ⚠️ COMMON PITFALLS & SOLUTIONS

### **Problem: Context Overflow**
**Solution:**
```bash
# Use safe executor
./safe_tool_executor.sh claude "Task" large_file.txt

# Or trim manually
head -n 500 large_file.txt > context.txt
```

### **Problem: Rate Limits**
**Solution:**
- **Codex**: Currently limited until Mar 21, 2026 23:33
- **Claude**: Can also hit limits - monitor usage
- **Fallback**: Use `smart_model_fallback.py` system

### **Problem: Wrong Tool Choice**
**Solution:**
```bash
# Use smart router
./smart_route_tool.sh "Task" --quality-critical --project ~/myapp

# Or check project config
./project_tool_config.sh get ~/myapp default
```

### **Problem: Poor Output Quality**
**Solution:**
1. **Switch to higher quality tool** (Claude → Cursor/Codex)
2. **Increase effort level**: `claude --effort high`
3. **Provide more context**: Include relevant files
4. **Use `/plan` mode first** for complex tasks

---

## 📊 TOOL MATRIX AT A GLANCE

| Tool | Command | Best For | Cost | Planning | Terminal |
|------|---------|----------|------|----------|----------|
| **Claude** | `claude` | Quality, reasoning | High | ✅ `/plan` | ❌ |
| **Cursor** | `agent` | Terminal, Cloud | Medium | ✅ `/plan` | ✅ |
| **Codex** | `codex` | GPT-4 tasks | High | ❌ | ❌ |
| **Gemini** | `gemini` | Cost-effective | Low | ❌ | ❌ |
| **Qwen** | `ollama...` | Free, learning | Free | ❌ | ❌ |

---

## 🚨 EMERGENCY FALLBACKS

### **If Claude fails:**
```bash
# Try Cursor (similar quality)
agent chat "Task"

# Or Gemini (lower cost)
gemini --model "gemini-3-pro" --prompt "Task"
```

### **If Cursor fails:**
```bash
# Try Claude
claude --print "Task"

# Or local option
ollama launch claude --model qwen3.5:9b "Task"
```

### **If Codex fails (rate limited):**
```bash
# Use smart fallback system
./scripts/setup_gpt_limit_fix.sh

# Then tools will auto-use alternatives
```

### **If all API tools fail:**
```bash
# Use local option
ollama launch claude --model qwen3.5:9b "Task"

# Or wait for limits to reset
```

---

## ✅ AGENT CHECKLIST (30 seconds)

### **Before starting:**
- [ ] **Check**: Project has tool preference?
- [ ] **Check**: Task needs planning (`/plan`)?
- [ ] **Check**: Context size manageable?
- [ ] **Check**: Cost constraints?

### **Command to run:**
```bash
# Use smart router for decision
./smart_route_tool.sh "Your task here" [options]

# Or manually:
# 1. Planning needed? → claude/agent with /plan
# 2. Terminal work? → agent
# 3. Quality critical? → claude
# 4. Cost sensitive? → gemini/qwen
# 5. Default → claude
```

### **After completion:**
- [ ] **Verify**: Output meets requirements?
- [ ] **Check**: No context overflow errors?
- [ ] **Document**: Tool used and why?
- [ ] **Optimize**: Could cheaper tool work next time?

---

**Remember**: When in doubt, start with **Claude Code** and **use `/plan` mode** for complex tasks. The smart routing system (`smart_route_tool.sh`) will help make optimal decisions based on constraints.

**Last Updated**: March 20, 2026  
**Status**: Ready for agent use