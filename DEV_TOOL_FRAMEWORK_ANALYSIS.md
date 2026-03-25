# DEV TOOL FRAMEWORK ANALYSIS & PLAN
**Date:** 2026-03-20  
**Goal:** Create intelligent tool routing system for OpenClaw agents  
**Priority:** Cost optimization + Code quality

## 📊 CURRENT TOOL INVENTORY

### 1. Cursor CLI (INSTALLATION ISSUE)
- **Status:** Installed `cursor-cli` package but appears to be Node.js server/agent
- **Binary:** `cursor-agent` outputs JavaScript source instead of AI responses
- **Cost:** Unknown (described as "most generous" but CLI functionality unclear)
- **Models:** Unknown via CLI
- **Best For:** Unknown - requires investigation of actual Cursor IDE AI capabilities
- **Limits:** Unknown - may require GUI/IDE usage

### 2. Claude Code with Qwen3.5:9b (EXISTING WORKFLOW)
- **Command:** `ollama launch claude --model qwen3.5:9b`
- **Cost:** ZERO (local Ollama)
- **Model:** Qwen3.5:9b (6.6 GB)
- **Best For:** Local development, quick fixes, standard coding tasks
- **Limits:** Local only, Qwen3.5:9b capabilities
- **Skill:** `claude-qwen-dev` already exists

### 3. Claude Code (API)
- **Version:** 2.1.76
- **Path:** `/opt/homebrew/bin/claude`
- **Cost:** Medium (Claude Pro subscription, might upgrade)
- **Models:** Claude 3.5 Sonnet, Claude 3 Opus, etc.
- **Best For:** Quality-critical work, complex reasoning
- **Limits:** Subscription-based API limits

### 4. Codex CLI (ChatGPT Pro)
- **Version:** 0.104.0
- **Path:** `/opt/homebrew/bin/codex`
- **Cost:** Medium (ChatGPT Pro subscription)
- **Models:** GPT-4, GPT-4 Turbo, etc.
- **Best For:** OpenAI-specific tasks, GPT-4 capabilities
- **Limits:** ChatGPT Pro API limits

### 5. OpenClaw Orchestration
- **Models:** `openai-codex/gpt-5.3-codex`, Deepseek, OpenRouter
- **Cost:** Variable (API-based)
- **Best For:** Planning, coordination, agent management
- **Limits:** API costs, not for coding

### 6. Other Ollama Models
- **Llama3.1:8b:** 4.9 GB (alternative local model)
- **Available:** Could be used with Claude Code or directly

## 🎯 PRIORITY MATRIX: COST vs QUALITY

### Tier 1: Zero-Cost Local (Priority for routine work)
```
Tool: Claude Code + Qwen3.5:9b
Cost: $0
Quality: Good (Qwen3.5:9b)
Use Case: 80% of development tasks
```

### Tier 2: Cost-Optimized Cloud (Priority for complex work)
```
Tool: Cursor CLI
Cost: Low (most generous limits)
Quality: Very Good (auto model selection)
Use Case: Complex features, refactoring, bug fixes
```

### Tier 3: Quality-First Cloud (For critical work)
```
Option A: Claude Code (API)
Cost: Medium
Quality: Excellent (Claude 3.5 Sonnet/Opus)
Use Case: Architecture decisions, critical bug fixes

Option B: Codex CLI
Cost: Medium  
Quality: Excellent (GPT-4)
Use Case: OpenAI-specific needs, GPT-4 strengths
```

### Tier 4: Orchestration Only
```
Tool: OpenClaw
Cost: Variable
Use: Planning, coordination, NOT coding
```

## 🔄 DECISION FLOW ALGORITHM

### Primary Decision Tree:
```
IF task_requires_coding:
  IF zero_cost_acceptable AND local_ok:
    → TIER 1: Claude Code + Qwen3.5:9b
    
  ELSE IF complex_refactoring OR large_scale:
    → TIER 2: Cursor CLI (cost-optimized cloud)
    
  ELSE IF quality_critical OR architecture:
    → TIER 3A: Claude Code (API) OR TIER 3B: Codex CLI
    
  ELSE:
    → DEFAULT: Claude Code + Qwen3.5:9b

ELSE IF task_requires_planning:
  → OpenClaw orchestration
```

### Secondary Considerations:
1. **File Size:** Large files → Cursor CLI (better context handling)
2. **Complexity:** High complexity → Claude Code (API) for reasoning
3. **Urgency:** Time-sensitive → Cursor CLI (fastest turnaround)
4. **Budget:** Near limit → Claude Code + Qwen (zero cost)

## 🛠️ PROPOSED SKILL ARCHITECTURE

### Core Skill: `dev-tool-router`
- **Purpose:** Intelligent tool selection engine
- **Input:** Task description, constraints, priorities
- **Output:** Recommended tool + invocation command
- **Features:** Cost tracking, success rate monitoring

### Integration Skills:
1. **`cursor-dev`** - Cursor CLI integration
2. **`claude-qwen-dev`** - Enhanced existing skill  
3. **`claude-api-dev`** - Claude API integration
4. **`codex-dev`** - Codex CLI integration
5. **`tool-usage-tracker`** - Cost/performance monitoring

### Agent Education:
- **Guide:** `/Users/clawdia/.openclaw/workspace/GUIDE_DEV_TOOLS.md`
- **Examples:** Real task → tool mappings
- **Best Practices:** When to override auto-selection

## 📈 COST OPTIMIZATION STRATEGY

### Primary Goal: Maximize Tier 1 Usage
- Default to Claude Code + Qwen for routine tasks
- Only escalate to paid tools when necessary
- Track monthly usage to stay within limits

### Fallback Chain:
```
Tier 1 (Free) → Tier 2 (Low Cost) → Tier 3 (Medium Cost)
```

### Monitoring:
- Track tool usage by agent
- Monitor cost accumulation
- Alert when approaching limits
- Optimize based on success rates

## 🚀 IMPLEMENTATION PHASES

### Phase 1: Foundation (This Week)
- [x] Install Cursor CLI
- [ ] Create comprehensive tool audit (THIS DOCUMENT)
- [ ] Design decision algorithm
- [ ] Create `dev-tool-router` skill skeleton

### Phase 2: Skill Development (Next Week)
- [ ] Build `cursor-dev` skill
- [ ] Enhance `claude-qwen-dev` skill
- [ ] Create `tool-usage-tracker` skill
- [ ] Test basic routing scenarios

### Phase 3: Agent Integration (Week 3)
- [ ] Update agent routing protocols
- [ ] Integrate with existing PRDForge rules
- [ ] Create agent education materials
- [ ] Run pilot with PRDForge tasks

### Phase 4: Optimization (Week 4+)
- [ ] Monitor usage patterns
- [ ] Refine decision algorithm
- [ ] Add cost prediction
- [ ] Create reporting system

## 🔍 KEY RESEARCH NEEDS

### To Be Determined:
1. **Cursor CLI Limits:** Exact API limits, cost structure
2. **Claude Pro Limits:** Current usage, upgrade implications  
3. **Codex Limits:** ChatGPT Pro API remaining capacity
4. **Tool Performance:** Benchmark each tool with standardized tasks
5. **Integration Complexity:** How well each tool integrates with OpenClaw

### Immediate Next Actions:
1. **Test Cursor CLI** with real coding task
2. **Document exact commands** for each tool
3. **Create cost tracking baseline**
4. **Design skill interfaces**

## 📋 SUCCESS METRICS

### Primary Metrics:
1. **Cost Reduction:** % decrease in paid tool usage
2. **Quality Maintenance:** Bug rate, code review pass rate
3. **Velocity:** Task completion time
4. **Agent Satisfaction:** Tool selection accuracy

### Secondary Metrics:
1. **Tool Utilization:** Distribution across tiers
2. **Fallback Rate:** % of tasks needing escalation
3. **Error Rate:** Tool invocation failures
4. **Learning Curve:** Agent adoption speed

## ⚠️ RISKS & MITIGATIONS

### Risk 1: Over-optimization for cost
- **Mitigation:** Quality gates, manual override option

### Risk 2: Tool integration complexity
- **Mitigation:** Start simple, iterate based on feedback

### Risk 3: Agent confusion
- **Mitigation:** Clear documentation, examples, fallback paths

### Risk 4: Changing tool limits
- **Mitigation:** Flexible architecture, regular audits

## 🎯 IMMEDIATE NEXT STEPS

1. **Create `dev-tool-router` skill skeleton**
2. **Test each tool with standardized task**
3. **Document exact invocation patterns**
4. **Design agent education materials**
5. **Create Phase 1 implementation plan**

---

**Status:** ANALYSIS COMPLETE - READY FOR IMPLEMENTATION PLANNING