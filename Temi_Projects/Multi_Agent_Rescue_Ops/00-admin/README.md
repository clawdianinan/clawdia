# Multi-Agent Rescue Ops
Status: DRAFT (service plans to be revisited)
Owner: Temi
Focus: n8n automation + OpenClaw config/debug + rescue response

## Objective
Launch a lean, high-trust multi-agent service that fixes and stabilizes AI agent operations for clients.

## Multi-Agent Delivery Model
- Orchestrator Agent: intake, routing, quality gates, client updates
- Debug Agent: OpenClaw/n8n diagnostics and root-cause analysis
- Repair Agent: fix implementation and rollback-safe deployment
- Reviewer Agent: validation, acceptance checks, incident closure report

## Installed Skills (safe)
- openclaw-config
- openclaw-mcp-debugger
- incident-commander
- clawops (replacement for suspicious guardrails package)
- production-readiness (replacement for suspicious guardrails package)

## Excluded
- openclaw-ops-guardrails (skipped: suspicious flag)
