# OpenClaw Team Operating Plan (Innovation Hub + Product Development)
Date: 2026-03-01
Owner: Clawdia
Status: Drafted (ready for execution)

## 1) Context Fit Assessment

## Work Profile
- High-volume documentation + formal reporting
- Multi-account email operations (IIH + personal)
- Calendar/meeting-heavy coordination
- Continuous product development (web/mobile, React-heavy)
- Need parallel execution across admin + delivery + engineering

## Setup Readiness (Current)
- Core channels: operational (iMessage/WhatsApp/Telegram)
- Email: all key Himalaya accounts healthy (iih_clawdia, zoho, gmail, icloud)
- Memory durability: significantly improved (backup/snapshot/restore stack)
- Cron automation: active, reduced-noise baseline
- Model routing: cloud-first and cost-aware

## Key Gap Remaining
- Agent team topology is under-specified for your scale (currently generic 5-agent set).

---

## 2) Agent Team Design (Target)

### A. Executive Ops Layer
1. `chief-of-staff` (new)
   - Purpose: task triage, priority arbitration, escalation management
   - Inputs: inbox summaries, calendar, deadlines, strategic priorities
   - Outputs: daily top-3, risk alerts, delegation bundles

2. `comms-ops` (new)
   - Purpose: email drafting/QA/routing guardrails
   - Focus: IIH external comms, reminders, follow-ups, approvals

3. `meeting-ops` (new)
   - Purpose: meeting prep, agenda packs, notes-to-action conversion
   - Focus: convert meetings into executable tasks and owner tracking

### B. Knowledge & Documentation Layer
4. `docs-lead` (new)
   - Purpose: document standardization, template governance, publication-ready outputs
   - Tools: office-document-specialist-suite, nano-pdf, formatting rules

5. `memory-curator` (new)
   - Purpose: durable decision extraction + memory quality review
   - Focus: high-signal memory curation, dedupe, index health

### C. Product Engineering Layer
6. `web-engineer` (new)
   - Purpose: React web app delivery
   - Mode: ACP harness (Codex/Claude/Cursor) for implementation threads

7. `mobile-engineer` (new)
   - Purpose: React Native/mobile delivery
   - Mode: ACP harness + issue/PR workflow

8. `qa-release` (new)
   - Purpose: smoke tests, regression checks, release notes, deployment checklists

9. `integrations-engineer` (new)
   - Purpose: API/webhook integrations, automation glue, reliability scripts

### D. Creative/Media Layer
10. `content-lab` (new)
   - Purpose: social graphic/video pipeline (Remotion + assets + captions)
   - Focus: reusable templates + scheduled content runs

---

## 3) Routing Rules (Who handles what)

- Email-heavy operational tasks -> `comms-ops`
- Calendar + meeting prep -> `meeting-ops`
- Reporting/document production -> `docs-lead`
- Strategic priority conflicts -> `chief-of-staff`
- Long-term memory curation -> `memory-curator`
- React web builds -> `web-engineer`
- React mobile builds -> `mobile-engineer`
- PR review/release hardening -> `qa-release`
- External integration reliability -> `integrations-engineer`
- Social media media ops -> `content-lab`

Escalation:
- Anything public/sensitive/legal/financial -> main (Clawdia) approval gate.

---

## 4) Skill/Tool Requirements by Agent

### Existing skills to map immediately
- Email: mail, apple-mail-search-safe, local-email, mail-attachments, himalaya-fixed
- Docs: office-document-specialist-suite, nano-pdf
- PM: todo-management
- Memory: qmd + memory scripts
- Dev: coding-agent, github
- Design/media: graphic-design, video-frames, frontend-design

### New skill candidate
- `cursor-cli` (found in ClawHub)
  - Status: available but flagged suspicious by VirusTotal insight
  - Action: do NOT install automatically; require manual review + explicit approval (`--force`).

---

## 5) Execution Plan

### Phase T0 (Today)
- [ ] Define and add new agent IDs in config (team structure)
- [ ] Assign default model strategy per agent (cost-aware)
- [ ] Map task routing policy into AGENTS/ROUTING docs

### Phase T1 (This week)
- [ ] Enable meeting pipeline (calendar -> prep brief -> action list -> todo)
- [ ] Enable documentation QA workflow (draft -> format -> final)
- [ ] Enable engineering dual-track (web/mobile) with QA gate

### Phase T2 (Next)
- [ ] Enable social content pipeline with Remotion templates
- [ ] Add per-agent metrics dashboard (throughput, success rate, cycle time)

---

## 6) Model Allocation (Cost/Performance)

- Main orchestration: `deepseek/deepseek-chat` default
- High-complexity architecture/code: `openai-codex/gpt-5.3-codex` on-demand
- Reliability fallback: `openrouter/auto`, `litellm/auto`
- Keep local models as manual emergency only (no automatic production fallback)

---

## 7) Multi-Agent Safety & Governance

- Separate session scope per sender/channel (already enabled)
- Explicit approval gate for outbound sensitive comms
- Best-effort delivery with explicit channel targets
- Audit logs for all cron/agent outputs

---

## 8) Alignment with Original Agent Creation Prompts (Important)

1. Existing setup already follows the original intent:
   1.1 `main` is orchestrator/final approver.
   1.2 `shuri`, `trinity`, `nova`, `ebun` map to the originally defined functional lanes.
   1.3 Shared governance exists in your root docs (SOUL/HEARTBEAT) and should remain centralized to avoid duplication.
2. To preserve your anti-bloat rule, do not create a large new agent fleet immediately.
3. Keep the original four specialist agents and tune behavior/routing before adding new agents.
4. Any new agent must be justified by sustained workload not solvable by improved routing.

## 9) Lean Agent Recommendation (Based on your prompt history + current workload)

1. Keep and tune existing agents (no new agent for comms/calendar):
   1.1 `main` (Clawdia) -> comms/calendar load owner + final approvals.
   1.2 `shuri` -> IIH docs/ops/reporting + structured review gate.
   1.3 `trinity` -> all dev execution (web + mobile), avoid splitting into many dev agents.
   1.4 `nova` -> personal venture strategy.
   1.5 `ebun` -> public writing/thought leadership.
2. Development scaling model:
   2.1 Use one primary dev agent (`trinity`) + temporary task branches/subsessions.
   2.2 Review path: `shuri` performs scope/risk/test checklist review; `main` approves ship/no-ship.
   2.3 Add a dedicated QA agent only when release frequency makes this a bottleneck.

## 10) Cursor CLI Skill Decision

1. `cursor-cli` exists on ClawHub but is flagged suspicious.
2. Recommended policy:
   2.1 Do not install with `--force` until manual code review.
   2.2 If approved, sandbox usage and restrict to dev folders only.

## 11) Recommended Next Actions (Immediate)

1. You provide names for any optional new agents.
2. I will map those names to strict roles and update agent config minimally.
3. We then run a 7-day pilot with current core agents before adding more.
4. Decide on Cursor skill after explicit security review.
