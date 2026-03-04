# Codex 5.3 Token Optimization Policy (Reversible)

Date: 2026-03-04
Status: ACTIVE
Owner: Clawdia

## Objective
Reduce token burn while keeping delivery quality high for ongoing tasks.

## Milestones
1. M1 (Policy): enforce compact prompts and terse outputs.
2. M2 (Runtime): lower concurrency and reduce fragmented message handling.
3. M3 (Execution): prefer single-pass deterministic actions, avoid retries/tool chatter.
4. M4 (Review): measure usage after active tasks and decide keep/rollback.

## Active Rules
- Keep prompts compact; include only required context.
- Use terse output formats by default.
- Avoid repeated status polls and redundant tool calls.
- Batch related file reads/writes.
- Prefer one decisive subagent run over multiple overlapping runs.

## Runtime Tweaks (Current)
- `agents.defaults.maxConcurrent = 2`
- `agents.defaults.subagents.maxConcurrent = 4`
- `messages.queue.debounceMs = 2500`
- `messages.inbound.debounceMs = 1800`

## Reversible Toggle
Use:
- `scripts/toggle_codex_optimization.sh on`
- `scripts/toggle_codex_optimization.sh off`

Rollback restores pre-optimization config from backup file:
- `~/.openclaw/openclaw.pre_codex_optimization.json`
