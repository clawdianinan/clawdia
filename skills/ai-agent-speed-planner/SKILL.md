---
name: ai-agent-speed-planner
description: Convert human-timeline plans into AI-agent-speed execution plans with parallelized tracks, short decision gates, and measurable completion checkpoints. Use when the user asks to accelerate execution, compress timelines from days/weeks to minutes/hours, remove unnecessary waiting, or enforce rapid build/review/deploy cadence.
---

# AI Agent Speed Planner

## Objective
Produce execution plans optimized for agent speed, not human pacing.

## Operating Rules
1. Replace calendar durations with deliverable gates.
2. Default to parallel workstreams when dependencies allow.
3. Break tasks into micro-batches (5-30 minute units).
4. Define approval points only where risk is material.
5. Require evidence-based completion for each gate.

## Speed Conversion Framework
For any input plan, rewrite into:

1. **Target Outcome**
   - Exact deliverable definition
   - Done criteria (binary)

2. **Constraint Check**
   - Hard constraints: approvals, legal, payment, production risk
   - Soft constraints: preferences, formatting, sequencing

3. **Parallel Tracks**
   - Track A: Strategy/analysis
   - Track B: Execution/build
   - Track C: QA/risk checks
   - Track D: Packaging/comms

4. **Gate Timings (Agent Speed Defaults)**
   - Gate 1 (Scoping): 5-10 min
   - Gate 2 (First artifacts): 10-20 min
   - Gate 3 (Validation): 10-15 min
   - Gate 4 (Delivery): 5-10 min

5. **Decision Policy**
   - Escalate only on high-risk/irreversible actions
   - Continue autonomously on low-risk reversible actions

## Output Format
Always output in this structure:

### Objective

### Compressed Plan (Agent-Speed)
- Phase 1 (Now, 0-10 min):
- Phase 2 (10-30 min):
- Phase 3 (30-60 min):

### Parallelization Map
- Track A:
- Track B:
- Track C:
- Track D:

### Approval Gates
- Gate X: reason + required approver

### Success Metrics
- Metric 1:
- Metric 2:
- Metric 3:

### Immediate Next 3 Actions
1.
2.
3.

## Anti-Patterns (Disallowed)
- Multi-day timelines without hard dependency justification
- Sequential execution where parallelism is possible
- Vague tasks without evidence checkpoints
- Frequent status chatter instead of artifact delivery

## Quick Compression Prompts
Use internally when user says “move faster”:
- “Compress this plan to a 60-minute agent run.”
- “Show only dependency-true blockers; parallelize the rest.”
- “Convert milestones into evidence gates.”
