# Local Model Reliability Recovery Plan (Post-Sandbox Revert)
Date: 2026-03-02
Owner: Clawdia

## Objective
Restore reliable local-model behavior for:
1) strict JSON responses
2) tool call formatting/parsing
3) stable fallback usage in OpenClaw

## Constraints
- Keep sandboxing disabled for now.
- Preserve cloud-first reliability path.
- Minimize invasive config churn.

## Phase 1 — Baseline + Guardrails (Immediate)
1. Keep local model as fallback only (`ollama/qwen3:4b` at end of chain).
2. Enforce JSON-safe path for local validation (`scripts/ollama_json_safe.sh`).
3. Validate with two tests:
   - `scripts/ollama_validate.py` (strict JSON schema)
   - `scripts/ollama_toolcall_test.py` (function/tool-call shape)
4. Capture pass/fail into log artifact.

## Phase 2 — Prompt/Protocol Hardening (No sandbox)
1. Apply strict tool-call prompt template (single function call, no prose).
2. Set `think=false` for local test calls to reduce malformed output.
3. Use deterministic settings for local tests (low temperature if applicable).
4. Add retry-on-parse-fail wrapper before declaring model failure.

## Phase 3 — Routing Policy
1. Keep cloud (`deepseek`) as primary for user-facing reliability.
2. Use local model only for:
   - non-critical helper tasks
   - cheap background validation
3. Auto-escalate to cloud when:
   - JSON parse fails >1 retry
   - tool call schema mismatch

## Phase 4 — Acceptance Criteria
Local model is considered fixed enough when all hold:
1. JSON validator passes >= 10/10 consecutive runs.
2. Tool-call test passes >= 10/10 consecutive runs.
3. No malformed tool payload in smoke checks over 24h cron window.

## Rollback
If local reliability regresses:
1. Keep local model in fallback-only position.
2. Disable local tool-call usage paths temporarily.
3. Continue cloud-first execution until next tuning cycle.
