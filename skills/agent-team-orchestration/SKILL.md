---
name: agent-team-orchestration
description: "Orchestrate multi-agent teams with defined roles, task lifecycles, handoff protocols, and review workflows. Use when: (1) Setting up a team of 2+ agents with different specializations, (2) Defining task routing and lifecycle (inbox → spec → build → review → done), (3) Creating handoff protocols between agents, (4) Establishing review and quality gates, (5) Managing async communication and artifact sharing between agents."
---

# Agent Team Orchestration

Production playbook for running multi-agent teams with clear roles, structured task flow, and quality gates.

## The Team

The named agent team available to clawdia for orchestration:

| Agent | Role | Domain | Tools |
|-------|------|--------|-------|
| **clawdia** | Primary orchestrator | Routes, synthesises, arbitrates | Read, Bash, Glob, Grep, Agent |
| **trinity** | Engineering | Code, architecture, refactors, TDD, PRDs, build errors | Read, Edit, Write, Bash, Glob, Grep |
| **cypher** | Security | Code security review, threat modelling, OWASP, secrets | Read, Grep, Glob, Bash, Write |
| **neo** | Operations & automation | Scripts, cron jobs, automation design, glue code | Bash, Read, Write, Edit, Glob, Grep |
| **fela** | Infrastructure & tooling | Infra config, deployment pipelines, API wiring, env management | Read, Write, Edit, Bash, Glob, Grep |
| **morpheus** | Research & discovery | Market research, competitive intelligence, fact-checking | WebSearch, WebFetch, Read, Grep, Glob |
| **shuri** | Operational strategy | Frameworks, delivery planning, org architecture, process design | Read, Write, Grep, Glob, WebFetch, WebSearch |
| **oracle** | Strategic prediction | Scenario planning, forecasting, risk/opportunity mapping | Read, WebSearch, WebFetch, Grep |
| **nova** | Personal ventures | Product strategy, monetisation, GTM, ecosystem thinking | Read, WebSearch, WebFetch, Grep, Glob |
| **ngozi** | Financial intelligence | Financial modelling, projections, unit economics, fundraising | Read, Write, WebFetch, WebSearch |
| **ade** | Data & analytics | Data analysis, metrics, dashboards, statistical analysis | Read, Write, Bash, Grep, Glob |
| **chimamanda** | Communications | Email drafting, stakeholder messaging, announcement copy | Read, Write |
| **seun** | Media & production | Scripts, content planning, audio/video workflows | Read, Write, WebFetch |
| **ebun** | Voice & thought leadership | Essays, long-form writing, intellectual arguments | Read, Write, WebFetch, WebSearch |
| **femi** | Creative & design | Visual direction, brand identity, UI/UX framing | Read, Write, WebFetch |
| **oprah** | Social & networking | Outreach, relationship mapping, community strategy | Read, Write |
| **ruth** | Legal & compliance | Contract review, regulatory research, ToS drafting | Read, Write, WebFetch, WebSearch |
| **sheba** | Navigation & guidance | Disambiguation, options mapping, decision framing | Read, WebSearch, WebFetch |

### Routing Shortcuts

Common task → agent mappings for clawdia:

| Task type | Primary agent | Support agent |
|-----------|--------------|---------------|
| Build a feature | trinity | fela (infra), cypher (security gate) |
| Research a market | morpheus | nova (strategic lens), oracle (forecasting) |
| Write a strategy doc | shuri | oracle (predictions), ngozi (financials) |
| Security review | cypher | trinity (code context) |
| Deploy / CI/CD | fela | neo (automation scripts) |
| Financial model | ngozi | shuri (strategy context) |
| Investor materials | nova | ngozi (numbers), chimamanda (messaging) |
| Communication draft | chimamanda | ebun (voice/tone), oprah (relationship context) |
| Data analysis | ade | morpheus (research context) |
| Legal review | ruth | shuri (compliance framework) |
| Content production | seun | ebun (voice), femi (design) |

---

## Quick Start: Minimal 2-Agent Team

A builder and a reviewer. The simplest useful team.

### 1. Define Roles

```
Orchestrator (clawdia) — Route tasks, track state, report results
Builder agent          — Execute work, produce artifacts
```

### 2. Spawn a Task

```
1. Create task record (file, DB, or task board)
2. Spawn builder with:
   - Task ID and description
   - Output path for artifacts
   - Handoff instructions (what to produce, where to put it)
3. On completion: review artifacts, mark done, report
```

### 3. Add a Reviewer

```
Builder produces artifact → Reviewer checks it → Orchestrator ships or returns
```

That's the core loop. Everything below scales this pattern.

---

## Core Concepts

### Roles

Every agent has one primary role. Overlap causes confusion.

| Role | Purpose | Model guidance |
|------|---------|---------------|
| **Orchestrator** | Route work, track state, make priority calls | High-reasoning model (handles judgment) |
| **Builder** | Produce artifacts — code, docs, configs | Can use cost-effective models for mechanical work |
| **Reviewer** | Verify quality, push back on gaps | High-reasoning model (catches what builders miss) |
| **Ops** | Cron jobs, standups, health checks, dispatching | Cheapest model that's reliable |

### Task States

Every task moves through a defined lifecycle:

```
Inbox → Assigned → In Progress → Review → Done | Failed
```

**Rules:**
- Orchestrator owns state transitions — don't rely on agents to update their own status
- Every transition gets a comment (who, what, why)
- Failed is a valid end state — capture why and move on

### Handoffs

When work passes between agents, the handoff message includes:

1. **What was done** — summary of changes/output
2. **Where artifacts are** — exact file paths
3. **How to verify** — test commands or acceptance criteria
4. **Known issues** — anything incomplete or risky
5. **What's next** — clear next action for the receiving agent

Bad handoff: *"Done, check the files."*
Good handoff: *"Built auth module at `/shared/artifacts/auth/`. Run `npm test auth` to verify. Known issue: rate limiting not implemented yet. Next: cypher checks error handling edge cases."*

### Reviews

Cross-role reviews prevent quality drift:

- **Builders review specs** — "Is this feasible? What's missing?"
- **Reviewers check builds** — "Does this match the spec? Edge cases?"
- **Orchestrator reviews priorities** — "Is this the right work right now?"

Skip the review step and quality degrades within 3–5 tasks. Every time.

---

## Common Pitfalls

### Spawning without clear artifact output paths
Agent produces great work, but you can't find it. Always specify the exact output path in the spawn prompt.

### No review step = quality drift
"It's a small change, skip review." Do this three times and you have compounding errors.

### Agents not commenting on task progress
Silent agents create coordination blind spots. Require comments at: start, blocker, handoff, completion.

### Not verifying agent capabilities before assigning
Check an agent's tools list before routing — chimamanda has no web access, sheba has no write access, trinity has no web access.

### Orchestrator doing execution work
clawdia routes and tracks — it doesn't build. The moment you start "just quickly doing this one thing," you've lost oversight of the rest of the team.

---

## When NOT to Use This Skill

- **Single-agent setups** — Just follow standard AGENTS.md conventions.
- **One-off task delegation** — Use the Agent tool directly. This skill is for sustained workflows with multiple handoffs.
- **Simple question routing** — If you're just forwarding a question to a specialist, that's a message, not a workflow.

This skill is for **sustained team workflows** — recurring collaboration patterns where agents depend on each other's output over multiple tasks.
