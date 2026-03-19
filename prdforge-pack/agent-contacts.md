# PRDForge Launch - Agent Contact Directory

## Agent Email Addresses (Gmail +alias format)

### Core Team (Gmail +alias format)
**Note:** All `+agent` emails route to `clawdianinan@gmail.com` with agent-specific labels.

1. **Clawdia** (Owner/Orchestrator)
   - Email: `clawdianinan@gmail.com` (original owner email)
   - Role: Multi-agent coordination, risk gates, final approvals
   - Slack: @clawdia
   - **Gmail Label:** (Main inbox)

2. **Trinity** (Technical Builder)
   - Email: `clawdianinan+trinity@gmail.com` → routes to main inbox
   - Role: Coding, implementation, debugging, technical architecture
   - Slack: @trinity
   - **Model Rule:** Local Qwen via Claude Code for all development work
   - **Gmail Label:** "Agent: Trinity"

3. **Fela** (Visual & Creative)
   - Email: `clawdianinan+fela@gmail.com` → routes to main inbox
   - Role: Graphics, brand expressions, campaign creatives, layout systems
   - Slack: @fela
   - **Gmail Label:** "Agent: Fela"

4. **Shuri** (Operations & Quality)
   - Email: `clawdianinan+shuri@gmail.com` → routes to main inbox
   - Role: IIH operations docs, structured analysis, quality review, checklists
   - Slack: @shuri
   - **Gmail Label:** "Agent: Shuri"

5. **Ebun** (Research & Narrative)
   - Email: `clawdianinan+ebun@gmail.com` → routes to main inbox
   - Role: Research synthesis, public writing, narrative outputs, documentation
   - Slack: @ebun
   - **Gmail Label:** "Agent: Ebun"

6. **Nova** (Strategy & Planning)
   - Email: `clawdianinan+nova@gmail.com` → routes to main inbox
   - Role: Venture strategy, product direction, launch sequencing, risk assessment
   - Slack: @nova
   - **Gmail Label:** "Agent: Nova"

7. **Sheba** (Business & Monetization)
   - Email: `clawdianinan+sheba@gmail.com` → routes to main inbox
   - Role: Pricing strategy, revenue modeling, billing systems, commercial operations
   - Slack: @sheba
   - **Gmail Label:** "Agent: Sheba"

## Slack Workspace
- **URL:** `clawdiasagents.slack.com`
- **Team:** "Clawdia's Agents"
- **Owner:** `clawdianinan@gmail.com` (Clawdia primary account)

## Channel Structure
- `#prdforge-launch` - Main project channel
- `#phase1-stabilization` - Technical updates (Trinity)
- `#phase2-qa-uat` - Testing progress (Shuri)
- `#phase3-commercial` - Billing validation (Sheba)
- `#phase4-gtm` - Launch marketing (Fela, Ebun, Nova)
- `#agent-coordination` - Daily standups (All agents)
- `#decisions` - Key decisions (Clawdia)
- `#blockers` - Issues needing attention

## Communication Protocol
1. **Daily Standup:** 9 AM Africa/Lagos in `#agent-coordination`
2. **Task Updates:** Post completion to relevant channel
3. **Blockers:** Immediate post to `#blockers`
4. **Decisions:** Document in `#decisions`
5. **Phase Transitions:** Announce in `#prdforge-launch`

## Model Usage Rules
- **Development Work (Trinity):** Local Qwen via Claude Code (`ollama/qwen3.5:9b`)
- **Non-Development Work:** Default models (DeepSeek acceptable)
- **Cloud Models:** Only when explicitly instructed
- **Current Restriction:** Codex unavailable until March 21st

## Invitation Process
1. Send Slack invites to all agent emails
2. Each agent joins with their designated email
3. Assign to appropriate channels
4. Set up notification preferences

---
**Created:** 2026-03-18  
**For:** PRDForge Launch Team Coordination  
**Workspace:** clawdiasagents.slack.com