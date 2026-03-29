# 🚨 PRDFORGE PROJECT RULES - MANDATORY FOR ALL AGENTS

## 📋 **CRITICAL RULES - READ BEFORE ANY WORK**

### **1. DEVELOPMENT MODEL RULE (STRICT)**
- **OpenClaw Level:** Uses `openai-codex/gpt-5.3-codex` (API models only)
- **Claude Code Level:** **STRICTLY** uses Qwen3.5:9b via Ollama
- **Standardized Skill:** Use `/Users/clawdia/.openclaw/workspace/skills/claude-qwen-dev/` skill
- **Invocation Options:**
  ```bash
  # Option 1: Use standardized skill script
  ./skills/claude-qwen-dev/scripts/launch-claude.sh "coding task"
  
  # Option 2: Direct command (launches interactive Claude Code with Qwen):
  ollama launch claude --model qwen3.5:9b
  
  # Then use Claude Code interactively for coding tasks
  ```
- **Restriction:** Only Claude Code agents invoke Qwen, not OpenClaw directly
- **NO Ollama models configured in OpenClaw** - Agents invoke at runtime
- **Note:** `claude --model qwen3.5:9b` does NOT work - use `ollama launch claude --model qwen3.5:9b`

### **2. TOOL INTEGRATION RULES**
- **Jira:** Tickets created BEFORE work starts (Managed by **SHURI**)
- **GitHub:** Commits during work, PRs for major changes (Managed by **TRINITY**)
- **Slack:** Notifications for deployments and milestones (Managed by **CHIMAMANDA**)
- **Testing:** Production verification (Managed by **MORPHEUS**)
- **Security:** Scanning and hardening (Managed by **CYPHER**)

### **3. PLATFORM MANAGEMENT DELEGATION**
**Each platform has a dedicated agent:**
- **Slack Communications:** CHIMAMANDA - All notifications and updates
- **Jira Operations:** SHURI - Ticket creation, tracking, documentation
- **GitHub Implementation:** TRINITY - Code commits, deployments
- **QA & Testing:** MORPHEUS - Production verification, testing
- **Security:** CYPHER - Security scanning, compliance

**Reference:** `/Users/clawdia/.openclaw/workspace/PLATFORM_MANAGEMENT_AGENTS.md`

### **3. WORKFLOW WITH CLAUDE CODE**
```
1. Jira Ticket Created → 2. Claude Code invoked with Qwen → 
3. GitHub Commit → 4. Test → 5. Deploy → 6. Slack Notification
```

### **4. ECC (EVERYTHING CLAUDE CODE) INTEGRATION RULES (MANDATORY)**
- **ECC Version:** 1.9.0 (installed March 25, 2026)
- **Repository:** https://github.com/affaan-m/everything-claude-code
- **NPM Package:** `ecc-universal@1.9.0` (globally installed)

#### **4.1 ECC Development Workflow (PRDForge-Specific)**
```
1. Planning: /plan "PRDForge feature description"
2. Implementation: Follow ECC TypeScript/React patterns
3. Testing: /tdd for test-driven development (80%+ coverage)
4. Review: /code-review before commits
5. Security: /security-scan before deployment
6. Quality Gate: /quality-gate for final verification
```

#### **4.2 Mandatory ECC Commands for PRDForge**
- **Planning:** `/plan "Improve PRD generation algorithm"`
- **Code Review:** `/code-review --focus="prd-generation/"`
- **Security:** `/security-scan --check="user-data-protection"`
- **Testing:** `/tdd "Add test coverage for PRD template validation"`
- **E2E:** `/e2e "PRD generation user flow"`
- **Build Fixes:** `/build-fix` for build errors

#### **4.3 ECC Agent Integration**
- **Trinity (Implementation):** Uses `/plan`, `/tdd`, `/build-fix`
- **Morpheus (QA):** Uses `/code-review`, `/quality-gate`, `/e2e`
- **Cypher (Security):** Uses `/security-scan`, AgentShield integration
- **All Agents:** Must follow ECC coding standards and patterns

#### **4.4 ECC Quality Gates (Non-Negotiable)**
1. **Type Safety:** All TypeScript errors must be resolved
2. **Test Coverage:** Minimum 80% test coverage for new features
3. **Security Scan:** No critical/high vulnerabilities
4. **Code Review:** All ECC code review checks must pass
5. **Build Verification:** Project must build without errors

#### **4.5 ECC Configuration Status**
```
✅ ECC Universal: 1.9.0 installed globally
✅ Claude Settings: ECC hooks configured
✅ Agents: 28 specialized agents available
✅ Commands: 59 ECC commands operational
✅ Skills: 46 domain skills installed
✅ Rules: Comprehensive coding standards enforced
```

### **5. COST CONTROL RULES**
- ✅ **Zero-cost development:** Claude Code uses local Qwen3.5:9b
- ✅ **Minimal orchestration:** OpenClaw uses minimal API calls
- ✅ **No API for coding:** All coding via local Ollama model

## 🔧 **AGENT TEAM STRUCTURE**

### **Development Family (Matrix Theme):**
- **Trinity:** Core implementation & feature development (uses `claude --model qwen3.5:9b` + ECC `/plan`, `/tdd`, `/build-fix`)
- **Morpheus:** QA/testing & quality assurance (uses `claude --model qwen3.5:9b` + ECC `/code-review`, `/quality-gate`, `/e2e`)
- **Cypher:** Security scanning & system hardening (uses `claude --model qwen3.5:9b` + ECC `/security-scan`, AgentShield)

### **Design Family:**
- **Fela:** Visual & creative design

### **Documentation Family:**
- **Ebun:** Research synthesis, public writing

### **Compliance Family:**
- **Ruth:** Contract management & legal compliance
- **Ngozi:** Financial operations & payment compliance

### **Operations Family:**
- **Shuri:** IIH operations docs, structured analysis
- **Nova:** Venture strategy/planning/product direction

### **Communications & Relations Family:**
- **Chimamanda:** Email management & communications
- **Oprah:** Stakeholder relations & engagement

### **Main Orchestrator:**
- **Clawdia:** Approvals, communication, sensitive decisions, orchestration

## 🎯 **CURRENT CONFIGURATION STATUS**

### **OpenClaw:**
```
✅ Default: openai-codex/gpt-5.3-codex
✅ Fallbacks: deepseek, openrouter models
❌ NO Ollama models configured
❌ NO Qwen references
```

### **Claude Code Agents:**
```
✅ Trinity: Uses claude --model qwen3.5:9b + ECC commands
✅ Morpheus: Uses claude --model qwen3.5:9b + ECC quality gates
✅ Cypher: Uses claude --model qwen3.5:9b + ECC security scanning
✅ ECC Integration: 1.9.0 installed and configured (March 25, 2026)
```

### **Tool Integration:**
```
✅ Jira: API token configured (ATLASSIAN_API_TOKEN)
✅ Slack: Bot token configured (xoxb-...)
✅ GitHub: Repository access configured
```

## 📁 **PROJECT FILES & LOCATIONS**

### **PRDForge Repository:**
- Path: `/Users/clawdia/apps/prdforge`
- GitHub: https://github.com/clawdianinan/prdforge
- Production: https://prdforge-dev.netlify.app

### **Supabase Configuration:**
- URL: https://eflrqvxmqrtbytkxyrze.supabase.co
- Site URL: https://prdforge-dev.netlify.app
- Redirect URLs: `/dashboard` paths configured

### **Database:**
- OLD (read-only): `db.jnlkzcmeiksqljnbtfhb.supabase.co`
- NEW (active): `db.eflrqvxmqrtbytkxyrze.supabase.co`
- Migration: 635+ rows completed

## 🚀 **WORKFLOW EXAMPLES**

### **For Coding Tasks:**
```bash
# CORRECT INVOCATION (launches interactive Claude Code with Qwen):
ollama launch claude --model qwen3.5:9b

# Then use Claude Code with ECC commands:
# - /plan "Fix React component issue in PRDForge"
# - /tdd "Add tests for PRD generation feature"
# - /code-review --focus="src/core/prd-generation/"
# - /security-scan --check="api-security"
# - /build-fix (for build errors)
# - /quality-gate (final verification)

# IMPORTANT: `claude --model qwen3.5:9b` does NOT work
# Use `ollama launch claude --model qwen3.5:9b` instead
```

### **Agent Delegation Pattern:**
```javascript
// When spawning coding agents:
sessions_spawn({
  runtime: "acp",
  agentId: "claude-code", // Uses Qwen via Claude CLI
  task: "Use claude --model qwen3.5:9b for this coding task"
})
```

## ⚠️ **VIOLATION CONSEQUENCES**

**Any agent violating these rules will be:**
1. Immediately stopped
2. Task reassigned
3. Violation logged in memory
4. Configuration reviewed

## 📞 **ESCALATION PATH**

1. **Technical Issues:** Trinity → Morpheus → Cypher
2. **Process Issues:** Shuri → Nova
3. **Compliance Issues:** Ruth → Ngozi
4. **Final Authority:** Clawdia

## 🔄 **UPDATE LOG**

- **2026-03-19:** Rules established after PRDForge debugging session
- **Key Fixes:** Blank page, OAuth redirect, button removal, database migration
- **Configuration:** OpenClaw no Ollama, Claude Code uses Qwen3.5:9b
- **2026-03-25:** ECC (Everything Claude Code) 1.9.0 integrated
- **ECC Integration:** Mandatory ECC workflow, commands, and quality gates added

---

**ALL AGENTS MUST READ AND ACKNOWLEDGE THESE RULES BEFORE STARTING ANY PRDFORGE WORK**

**Status:** ✅ ACTIVE AND ENFORCED