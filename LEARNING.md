# LEARNING.md — Ongoing Instruction & System Evolution

> Legacy file: merged into `.learnings/LEARNINGS.md`, `.learnings/ERRORS.md`, and `.learnings/FEATURE_REQUESTS.md` on 2026-03-15. Use `.learnings/` as the active system of record.

Purpose: Store evolving preferences, new rules, and system improvements without bloating core config files. This file captures what we're learning and implementing in real-time.

---

## 1. Communication Channel Learning

### 1.1 iMessage Address Mapping
- **Primary iMessage:** temikolawole@icloud.com (default)
- **Alternate iMessage:** temikolawole@gmail.com
- **Phone iMessage:** +2348155555222
- **Rule:** When sending iMessage notifications, use temikolawole@icloud.com as primary target

### 1.2 Email Auto-Processor Delivery Issue
- **Problem:** Auto-processor results not reaching iMessage properly
- **Root Cause:** Delivery routing mismatch
- **Solution:** Ensure system messages target correct iMessage address
- **Status:** Needs implementation fix

---

## 2. Context Management System

### 2.1 Context Overflow Problem
- **Error:** "prompt too large for the model"
- **Trigger:** Conversation history, code, or data exceeds model token capacity
- **Impact:** System messages fail to deliver properly

### 2.2 Smart Context Compression Strategy
We need a skill that:
1. **Auto-compacts chat history** based on importance scoring
2. **Works within different model context sizes** (adapts to runtime model)
3. **Preserves critical information** while pruning low-value content
4. **Integrates with OpenClaw's session management**

### 2.3 Implementation Priorities
1. Create `context-manager` skill for intelligent compression
2. Implement importance scoring for message retention
3. Add model-aware context size limits
4. Create `/compact` command integration
5. Prevent silent tool output bloat

### 2.4 Key Strategies Identified
- **Start Fresh:** `/new` or `/reset` for clean sessions
- **Summarize:** `/compact` command for older turns
- **Context Engineering:** Feed only necessary snippets
- **Break Up Tasks:** Smaller, independent prompts
- **Large Context Models:** Switch when available
- **Tool Output Management:** Monitor for silent bloat

---

## 3. Skill Development Philosophy

### 3.1 New Rule: Skill Creation Priority
- **Before using existing skills:** Consider creating a new skill first
- **Rationale:** Ensures we don't install potentially dodgy third-party skills
- **Benefit:** We can vouch for and control the quality of skills we create
- **Exception:** Only use existing skills when creation is impractical or unnecessary

### 3.2 Skill Creation Criteria
1. **Need:** Clear, recurring task pattern
2. **Complexity:** Non-trivial implementation
3. **Safety:** No security or privacy risks
4. **Maintainability:** Reasonable to support long-term
5. **Reusability:** Applicable to multiple scenarios

---

## 4. Immediate Actions Required

### 4.1 Context Manager Skill Creation
- **Name:** `context-manager`
- **Purpose:** Intelligent chat history compression and context optimization
- **Features:**
  - Importance-based message retention
  - Model-aware context size limits
  - Automatic summarization of old turns
  - Integration with OpenClaw session commands
  - Tool output bloat detection

### 4.2 Email Delivery Fix
- **Task:** Ensure auto-processor results reach correct iMessage address
- **Approach:** Check routing configuration and delivery targets
- **Priority:** High (affects system notification reliability)

### 4.3 Learning System Integration
- **Task:** Regularly review and implement LEARNING.md entries
- **Frequency:** Daily check during startup sequence
- **Action:** Move stable patterns to appropriate config files when proven

---

## 5. Implementation Log

### 2026-02-27 06:45
- **Issue:** Context overflow causing delivery failures
- **Learning:** Need smart context management system
- **Action:** Create context-manager skill
- **Rule:** Skill creation before third-party skill usage

### 2026-02-27 06:45
- **Issue:** iMessage delivery routing incorrect
- **Learning:** Multiple iMessage addresses available
- **Action:** Update system to use temikolawole@icloud.com as primary

---

## 6. Execution Reliability Learning (2026-03-04)

### 6.1 Failure Pattern Observed
- Sub-agent process chain stopped early due to:
  1) agent routing policy restrictions (named-agent pinning initially blocked),
  2) cross-agent visibility restrictions (no progress history access),
  3) steer action causing run restarts during active execution.

### 6.2 Permanent Fixes Applied
- Enabled named-agent spawning access for main.
- Enabled cross-agent visibility and agent-to-agent history access.
- Added routing + resume guardrails in AGENTS.md and routing profile.

### 6.3 New Operating Rule
Before declaring status, always verify one of:
1) explicit completion artifact(s) exist, or
2) subagent completion message received, or
3) checkpoint report with file-level evidence is captured.

### 6.4 Reporting Rule
For delegated tasks, send progress update in this format:
- Assigned agent + reason
- Done since last update
- Remaining work
- Risks/blockers
- Next check time

## 7. Review Checklist

- [ ] Create context-manager skill
- [x] Fix iMessage delivery routing
- [x] Implement skill creation priority rule
- [x] Add LEARNING.md to session startup sequence
- [ ] Test context compression with real sessions
- [x] Document successful patterns in core configs
- [x] Add delegated-task activity report format
- [x] Add resume-from-plan guardrail

---

**Note:** This file is for ongoing learning. Move stable, proven patterns to appropriate config files (TOOLS.md, MEMORY.md, etc.) once validated.