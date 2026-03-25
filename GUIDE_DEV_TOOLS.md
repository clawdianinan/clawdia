# GUIDE: Development Tools for OpenClaw Agents

## 🎯 Purpose
This guide helps OpenClaw agents select the right development tool for each task, balancing cost, speed, and quality.

## 📋 Quick Decision Guide

### When to use which tool:

| Situation | Recommended Tool | Why |
|-----------|-----------------|-----|
| **Urgent bug fix** | Claude Code (API) | Fast, reliable |
| **Cost-sensitive task** | Ollama Qwen3.5:9b | Free, but slow |
| **Complex feature** | Claude Code (API) | Best reasoning |
| **Simple refactor** | Ollama Qwen (if time) | Save cost |
| **Terminal/CLI work** | Cursor CLI | Native terminal integration |
| **Codex available** | Codex CLI | When limits allow |
| **Unknown requirements** | Claude Code (API) | Default reliable |

### Constraint Cheat Sheet:
```
cost_sensitive=true    → Try Ollama first
time_sensitive=true    → Use Claude Code
quality_critical=true  → Use Claude Code
complexity=high        → Use Claude Code
terminal_based=true    → Use Cursor CLI
```

## 🛠️ Available Tools

### 1. Claude Code (API) - PRIMARY
- **Command:** `claude`
- **Cost:** Claude Pro subscription
- **Speed:** Fast (~10s response)
- **Quality:** High
- **Best for:** Most development tasks

### 2. Ollama Qwen3.5:9b - COST-SAVING
- **Command:** `ollama run qwen3.5:9b`
- **Cost:** FREE (local)
- **Speed:** Slow (>30s, may timeout)
- **Quality:** Medium
- **Best for:** Non-urgent, cost-sensitive tasks

### 3. Codex CLI - ALTERNATIVE
- **Command:** `codex exec`
- **Cost:** ChatGPT Pro subscription
- **Speed:** Fast
- **Quality:** High
- **Warning:** Has usage limits that can block work

### 4. Cursor CLI - TERMINAL AI ASSISTANT
- **Command:** `agent`
- **Cost:** Cursor subscription/API key required
- **Speed:** Fast (~5-10s response)
- **Quality:** High
- **Best for:** Terminal-based coding, CLI tool development, automation scripts
- **Features:** Interactive sessions, print mode for automation, MCP support

## 🔧 How to Use the Tool Router

### Basic Usage:
```bash
# From workspace root:
./skills/dev-tool-router/scripts/route-task.sh "Your task description"

# With constraints:
./skills/dev-tool-router/scripts/route-task.sh \
  "Fix authentication bug" \
  --constraints "time_sensitive=true,quality_critical=true"

# Cost-sensitive task:
./skills/dev-tool-router/scripts/route-task.sh \
  "Refactor utility functions" \
  --constraints "cost_sensitive=true"
```

### From Agent Code:
```javascript
// Example agent task delegation
const task = "Implement user profile feature";
const constraints = "complexity=high,quality_critical=true";

// Use the router
const { selectedTool, command } = await selectDevTool(task, constraints);

// Execute based on tool selection
if (selectedTool === 'claude') {
    await executeClaudeTask(task);
} else if (selectedTool === 'ollama') {
    await executeOllamaTask(task);
}
```

## 📊 Decision Flow for Agents

### Step 1: Analyze Task
```javascript
const analysis = {
    isUrgent: task.includes('bug') || task.includes('fix') || task.includes('urgent'),
    isComplex: task.includes('implement') || task.includes('feature') || task.length > 100,
    isCostSensitive: !task.includes('production') && !task.includes('critical'),
    requiresQuality: task.includes('security') || task.includes('auth') || task.includes('payment')
};
```

### Step 2: Apply Constraints
- **Default:** `cost_sensitive=false, time_sensitive=false, quality_critical=false`
- **Override based on analysis above**

### Step 3: Select Tool
```javascript
// Use the router's logic
const tool = select_dev_tool(task, constraints);
```

### Step 4: Execute with Fallback
```javascript
try {
    await executeWithTool(tool, task);
} catch (error) {
    if (tool === 'ollama' && error.includes('timeout')) {
        // Fallback to Claude Code
        await executeWithTool('claude', task);
    } else if (tool === 'codex' && error.includes('limit')) {
        // Fallback to Claude Code
        await executeWithTool('claude', task);
    }
}
```

## 💰 Cost Optimization Tips

### 1. Maximize Ollama Usage
- Use for: Documentation, simple refactors, code reviews
- Avoid for: Production bugs, complex features, time-sensitive work

### 2. Monitor Codex Limits
- Check before use: `codex exec "test" 2>&1 | grep -q "usage limit"`
- If limit reached: Automatically fallback to Claude Code

### 3. Batch Similar Tasks
- Group Ollama tasks (slower but free)
- Reserve Claude Code for urgent/important tasks

### 4. Quality vs Cost Trade-off
```
High Quality Needed: Claude Code or Codex
Medium Quality OK: Ollama Qwen
Don't Know: Start with Ollama, fallback if poor quality
```

## 🚨 Common Scenarios & Solutions

### Scenario 1: Production Bug
```
Task: "Fix payment processing bug in production"
Analysis: Urgent, quality-critical, not cost-sensitive
Tool: Claude Code (API)
Reason: Fast, reliable, high-quality output
```

### Scenario 2: Documentation Update
```
Task: "Update API documentation with new endpoints"
Analysis: Not urgent, not quality-critical, cost-sensitive
Tool: Ollama Qwen3.5:9b
Reason: Free, can wait for response
```

### Scenario 3: New Feature
```
Task: "Implement real-time notification system"
Analysis: Complex, quality-important, moderately urgent
Tool: Claude Code (API)
Reason: Best for complex reasoning, reliable output
```

### Scenario 4: Code Review
```
Task: "Review PR #45 for security issues"
Analysis: Quality-critical, moderately urgent
Tool: Claude Code (API) [or Codex if available]
Reason: Need thorough security analysis
```

## 📈 Performance Monitoring

### What to Track:
1. **Tool selection accuracy** - Was right tool chosen?
2. **Task completion rate** - Did tool successfully complete task?
3. **Time per task** - How long did each tool take?
4. **Cost efficiency** - Cost per successful task

### Optimization Loop:
```
1. Collect usage data
2. Identify patterns (e.g., Ollama too slow for X tasks)
3. Adjust decision algorithm
4. Test improved selections
```

## 🔍 Troubleshooting

### Problem: Ollama times out
```
Solution: 
1. Increase timeout (currently 30s)
2. Fallback to Claude Code
3. Log issue for optimization
```

### Problem: Codex limit reached
```
Solution:
1. Automatically switch to Claude Code
2. Log limit hit for cost tracking
3. Schedule task for after limit reset
```

### Problem: Poor output quality
```
Solution:
1. Retry with higher-quality tool (Claude Code)
2. Provide more specific instructions
3. Break task into smaller pieces
```

### Problem: Tool not available
```
Solution:
1. Check installation: `which claude`, `which ollama`, etc.
2. Install missing tools
3. Fallback to available tool
```

## 🎯 Best Practices for Agents

### 1. Always Use the Router
```bash
# DON'T hardcode tool selection
# claude "task"  # BAD

# DO use the router
./route-task.sh "task" --constraints "..."  # GOOD
```

### 2. Provide Clear Constraints
```bash
# BAD: No constraints
./route-task.sh "Fix something"

# GOOD: Clear constraints
./route-task.sh "Fix production auth bug" --constraints "time_sensitive=true,quality_critical=true"
```

### 3. Implement Fallbacks
```javascript
// Always have a fallback plan
try {
    await executeWithSelectedTool(task);
} catch (error) {
    await fallbackToClaudeCode(task);
}
```

### 4. Log Tool Usage
```bash
# Enable logging for optimization
DEBUG=1 ./route-task.sh "task" 2>&1 | tee /tmp/tool-log.txt
```

### 5. Review and Optimize
- Regularly review which tools work best for which tasks
- Update constraints based on experience
- Share learnings with other agents

## 📚 Integration with Existing Workflows

### PRDForge Development:
```bash
# Follow PRDForge rules first
# Then use tool router for coding tasks

# Example PRDForge task:
./skills/dev-tool-router/scripts/route-task.sh \
  "Fix edge function returning non-2xx status" \
  --constraints "time_sensitive=true,quality_critical=true"
```

### Agent Team Coordination:
- **Trinity (Development):** Uses router for all coding tasks
- **Morpheus (QA):** Uses Claude Code for test creation
- **Cypher (Security):** Uses Claude Code for security reviews
- **Shuri (Ops):** Monitors tool usage and costs

## 🔄 Continuous Improvement

### Feedback Loop:
1. **Agents:** Use tools, encounter issues, provide feedback
2. **Router:** Collects usage data, identifies patterns
3. **Optimization:** Adjusts decision algorithm
4. **Deployment:** Updates router, informs agents

### Contribution:
- Found a better tool for specific task? Update the guide!
- Discovered cost-saving pattern? Share with team!
- Having consistent issues? Report for optimization!

---

## 🚀 Getting Started

### For New Agents:
1. Read this guide completely
2. Test with simple tasks first
3. Learn constraint meanings
4. Practice fallback scenarios
5. Join optimization discussions

### First Tasks to Try:
```bash
# 1. Simple task (cost-sensitive)
./route-task.sh "Create Python function to calculate factorial" --constraints "cost_sensitive=true"

# 2. Urgent task  
./route-task.sh "Fix React component rendering bug" --constraints "time_sensitive=true"

# 3. Quality-critical task
./route-task.sh "Implement JWT authentication" --constraints "quality_critical=true"
```

---

**Remember:** The goal is **cost optimization WITHOUT compromising code quality**. When in doubt, choose reliability over cost savings for production work.

**Last Updated:** 2026-03-20  
**Status:** ACTIVE - All agents must follow this guide