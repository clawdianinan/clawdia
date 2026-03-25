# Skill: Development Tool Router

## Purpose
Intelligent routing between development tools based on task requirements, constraints, and cost optimization.

## Quick Decision Guide

### When to use which tool (Updated Priorities):

| Situation | Recommended Tool | Tier | Why | Command Example |
|-----------|-----------------|------|-----|-----------------|
| **Quality-critical code** | Claude Code (Pro) | 1 | Highest quality, subscription, **has `/plan` mode** | `claude --print "refactor complex function"` |
| **Terminal + planning** | Cursor CLI | 2 | `/plan` mode, terminal integration | `agent chat "plan and implement feature"` |
| **GPT-4 specific tasks** | Codex CLI | 3 | OpenAI ecosystem | `codex "implement OpenAI API wrapper"` |
| **Cost-sensitive, time-sensitive** | Gemini CLI | 4 | Low cost API | `gemini --prompt "fix bug quickly"` |
| **Cost-sensitive, non-urgent** | Qwen3.5:9b (via Claude) | 5 | Free via Claude Code | `ollama launch claude --model qwen3.5:9b` |
| **Image generation** | Nano Banana Pro | - | Gemini 3 Pro Image | Use `nano-banana-pro` skill |
| **Unknown requirements** | Claude Code (Pro) | 1 | Default reliable choice | `claude --print "implement feature"` |

### Constraint Cheat Sheet:
```
cost_sensitive=true    → Try Ollama first, then Gemini
time_sensitive=true    → Use Claude Code (API)
quality_critical=true  → Use Claude Code (API)
complexity=high        → Use Claude Code (API)
terminal_based=true    → Use Cursor CLI
openai_ecosystem=true  → Use Codex CLI
needs_images=true      → Use Nano Banana Pro
default                → Use Gemini CLI (balanced)
```

## Tool Capabilities Reference (Updated Priorities)

### 1. Claude Code (Pro) - Tier 1
- **Access**: Claude Code Pro subscription
- **Cost**: Subscription-based (can hit rate limits)
- **Speed**: Fast
- **Best for**: Quality-critical work, complex reasoning, **planning (`/plan` mode)**
- **Rate Limit Risk**: HIGH (similar to Codex)
- **Command**: `claude --print "complex task"` (then use `/plan` for planning)

### 2. Cursor CLI (`agent`) - Tier 2
- **Access**: Cursor subscription
- **Cost**: Unknown (subscription-based)
- **Speed**: Fast
- **Best for**: Terminal integration, `/plan` mode, Cursor workflows
- **Special Feature**: `/plan` mode for structured planning
- **Command**: `agent chat "terminal-based task"`

### 3. Codex CLI - Tier 3
- **Access**: ChatGPT Pro subscription
- **Cost**: Subscription-based (rate limited currently)
- **Speed**: Fast
- **Best for**: GPT-4 specific tasks, OpenAI ecosystem
- **Rate Limit Risk**: HIGH (currently limited until Mar 21, 2026 23:33)
- **Command**: `codex "OpenAI-related task"`

### 4. Gemini CLI - Tier 4
- **Access**: API Key (`GEMINI_API_KEY` required)
- **Cost**: Low (API usage, generous limits)
- **Speed**: Fast
- **Best for**: Cost-sensitive time-sensitive tasks
- **Rate Limit Risk**: Low
- **Command**: `gemini --prompt "your task here"`

### 5. Qwen3.5:9b (via Claude Code) - Tier 5
- **Access**: Local Ollama via Claude Code interface
- **Cost**: FREE
- **Speed**: Slow (local inference)
- **Best for**: Cost-sensitive non-urgent tasks, drafting, learning
- **Limits**: 6.6 GB model, slower response
- **Command**: `ollama launch claude --model qwen3.5:9b "task"`

### 6. Nano Banana Pro (Image Generation)
- **Access**: API Key (uses `GEMINI_API_KEY`)
- **Cost**: Low (API usage)
- **Best for**: Image generation, editing
- **Model**: Gemini 3 Pro Image
- **Usage**: Use `nano-banana-pro` skill

## Routing Logic Implementation

### Decision Algorithm:
```python
# Pseudo-code for tool selection
def select_tool(task, constraints):
    # Image generation
    if constraints.get("needs_images"):
        return "nano-banana-pro"
    
    # Cost optimization
    if constraints.get("cost_sensitive"):
        if constraints.get("time_sensitive"):
            return "gemini"  # Low cost, decent speed
        else:
            return "ollama"  # Free, but slower
    
    # Quality focus
    if constraints.get("quality_critical"):
        if constraints.get("openai_ecosystem"):
            return "codex"
        else:
            return "claude"
    
    # Terminal integration
    if constraints.get("terminal_based"):
        return "cursor"
    
    # Default balanced choice
    return "gemini"
```

### Usage Examples:

```bash
# Cost-sensitive bug fix
dev-tool-route "Fix React component bug" --cost-sensitive

# Quality-critical feature
dev-tool-route "Implement authentication system" --quality-critical

# Image generation
dev-tool-route "Generate logo for app" --needs-images

# Terminal-based refactor
dev-tool-route "Refactor codebase" --terminal-based
```

## Integration with Agent Team

### Development Family:
- **Trinity**: Uses this router for feature implementation
- **Morpheus**: Uses for QA/testing tasks
- **Cypher**: Uses for security scanning

### Design Family:
- **Fela**: Uses Nano Banana Pro for image generation

### All Agents:
- Check this router before starting development work
- Follow recommended tool selection
- Report tool performance for optimization

## Cost & Priority Optimization Strategy

### Tier 1: Premium Quality (Subscription)
- **Tool**: Claude Code (Pro)
- **Use when**: Quality-critical work, complex reasoning
- **Risk**: Can hit rate limits (like Codex)
- **Priority**: Highest quality output

### Tier 2: Terminal & Planning (Subscription)
- **Tool**: Cursor CLI (`agent`)
- **Use when**: Terminal-based work, needs `/plan` mode
- **Special**: Structured planning capability
- **Priority**: Preferred for terminal workflows

### Tier 3: OpenAI Ecosystem (Subscription)
- **Tool**: Codex CLI
- **Use when**: GPT-4 specific tasks, OpenAI integration
- **Risk**: Currently rate limited (until Mar 21, 2026 23:33)
- **Priority**: For OpenAI-specific requirements

### Tier 4: Cost-Effective API
- **Tool**: Gemini CLI
- **Use when**: Cost-sensitive but time-sensitive tasks
- **Advantage**: Low cost, generous API limits
- **Priority**: Budget-conscious time-sensitive work

### Tier 5: Zero Cost (Local)
- **Tool**: Qwen3.5:9b (via Claude Code)
- **Use when**: Cost-sensitive non-urgent tasks, drafting
- **Command**: `ollama launch claude --model qwen3.5:9b`
- **Priority**: Free option when time allows

### Special: Image Generation
- **Tool**: Nano Banana Pro
- **Use when**: Image generation/editing needed
- **Model**: Gemini 3 Pro Image
- **Cost**: Low API usage

## Setup & Configuration

### Required Environment:
```bash
# Gemini API Key (for Gemini CLI & Nano Banana Pro)
export GEMINI_API_KEY="your_key_here"

# OpenAI API Key (for Codex CLI)
export OPENAI_API_KEY="your_key_here"

# Claude API Key (for Claude Code)
# Configured in ~/.anthropic/config.json
```

### Verification Commands:
```bash
# Test Gemini
gemini --prompt "3 + 3 ="

# Test Claude
claude --version

# Test Codex
codex --version

# Test Cursor
agent --version

# Test Ollama
ollama run qwen3.5:9b "hello"
```

## Performance Tracking

### Metrics to Monitor:
1. **Cost per task** - API usage tracking
2. **Time to completion** - Speed comparison
3. **Quality score** - Code review results
4. **Success rate** - Task completion percentage

### Optimization Feedback Loop:
1. Record tool performance for each task
2. Adjust routing logic based on results
3. Update cost/quality trade-offs
4. Improve decision algorithm

## Troubleshooting

### Common Issues:

1. **Gemini API Key not set**
   ```bash
   export GEMINI_API_KEY="your_key"
   # Add to ~/.zshrc for persistence
   ```

2. **Ollama model not installed**
   ```bash
   ollama pull qwen3.5:9b
   ```

3. **Cursor CLI not authenticated**
   ```bash
   agent login
   ```

4. **Claude Code not working**
   ```bash
   # Check configuration
   cat ~/.anthropic/config.json
   ```

## Updates & Maintenance

### Version History:
- **v1.0** (2026-03-20): Initial release with 6 tools
- **Future**: Add more tools, refine routing logic

### Contribution:
Report tool performance, suggest improvements, add new tools to matrix.

---

**Next Step**: Create specific tool skills (cursor-dev, gemini-dev) for detailed integration.