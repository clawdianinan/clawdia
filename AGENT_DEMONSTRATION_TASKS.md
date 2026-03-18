# Agent Demonstration Tasks
Quick tasks to demonstrate each agent's new capabilities

## Trinity (Coding/Implementation) ⚡
**Task 1: Create an automation workflow**
```
"Create a n8n workflow that monitors GitHub issues and sends Telegram notifications when new issues are created with the 'bug' label. Include error handling and retry logic."
```

**Task 2: Build a UI component**
```
"Create a responsive dashboard component with React/Tailwind that shows real-time metrics. Include charts, status indicators, and a dark/light mode toggle."
```

**Task 3: Implement a skill**
```
"Create a skill that automatically formats code according to project-specific linting rules and creates a PR with the changes."
```

## Shuri (IIH Operations/Quality) 📋
**Task 1: Generate a monthly report**
```
"Create a February 2026 monthly report for IIH with the following sections: Executive Summary, Financial Performance, Program Highlights, Operational Metrics, and Next Month Priorities. Use proper IIH branding."
```

**Task 2: Conduct a security audit**
```
"Analyze the current IIH system setup and provide a security audit report covering: access controls, backup procedures, vulnerability assessment, and compliance checklist."
```

**Task 3: Summarize a complex document**
```
"Take this 50-page PDF report and create a 2-page executive summary highlighting key findings, recommendations, and action items."
```

## Ebun (Research/Public Writing) 📖
**Task 1: Create marketing content**
```
"Research the latest AI trends in edtech and create a blog post with 3 custom generated images. Include statistics, case studies, and actionable insights for educators."
```

**Task 2: Analyze video content**
```
"Take this 30-minute webinar video and extract key frames for a social media carousel. Create captions for each frame that tell the story of the webinar."
```

**Task 3: Monitor industry trends**
```
"Set up monitoring for 5 leading tech blogs and create a weekly digest of the most important articles with analysis of how they impact our industry."
```

## Nova (Venture Strategy/Product) 🚀
**Task 1: Analyze competitor strategy**
```
"Analyze 3 competitor Twitter profiles and provide insights on: their content strategy, engagement patterns, target audience, and potential weaknesses we can exploit."
```

**Task 2: Schedule investor meetings**
```
"Create a Calendly schedule for investor meetings over the next 2 weeks. Include buffer times, preparation materials, and follow-up automation."
```

**Task 3: CRM pipeline analysis**
```
"Analyze our current Zoho CRM pipeline and identify: conversion bottlenecks, high-value segments, and opportunities for automation in the sales process."
```

## Cross-Agent Collaboration Demo

### Scenario: Product Launch
**Nova:** "Analyze market opportunity for a new SaaS product in the project management space"
**Ebun:** "Create launch content including blog post, social media carousel, and email sequence"
**Trinity:** "Build landing page with signup form and basic demo functionality"
**Shuri:** "Create project timeline, resource allocation plan, and success metrics dashboard"

### Scenario: Client Project
**Nova:** "Schedule client discovery sessions and analyze client needs"
**Shuri:** "Create project requirements document and statement of work"
**Trinity:** "Implement core features based on requirements"
**Ebun:** "Create user documentation and training materials"

## Quick Test Commands

Test each agent with a simple command:
```bash
# Test Trinity
openclaw sessions_spawn runtime=subagent agentId=trinity task="Create a simple n8n workflow that sends a daily summary email"

# Test Shuri  
openclaw sessions_spawn runtime=subagent agentId=shuri task="Create a one-page monthly report template"

# Test Ebun
openclaw sessions_spawn runtime=subagent agentId=ebun task="Research 3 key AI trends for 2026"

# Test Nova
openclaw sessions_spawn runtime=subagent agentId=nova task="Analyze one competitor's social media strategy"
```

## Expected Outcomes

### Trinity:
- Working code/automation
- Clean, documented implementations
- Reusable components/patterns

### Shuri:
- Professional documents
- Structured analysis
- Actionable recommendations

### Ebun:
- Engaging content
- Visual assets
- Research insights

### Nova:
- Strategic analysis
- Market intelligence
- Business recommendations

## Success Metrics

1. **Time to completion:** 50% faster than before upskilling
2. **Output quality:** Professional, production-ready deliverables
3. **Skill utilization:** Each agent uses 3+ new skills per task
4. **Collaboration efficiency:** Seamless handoffs between agents

---
**Ready for testing:** March 14, 2026
**Status:** Agents upskilled and ready for demonstration