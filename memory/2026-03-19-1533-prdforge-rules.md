# PRDFORGE PROJECT RULES ESTABLISHED - 2026-03-19 15:33

## 🚨 CRITICAL RULES CREATED

### **Background:**
After extensive PRDForge debugging session (blank page, OAuth redirect, database migration), established strict rules to prevent future issues and ensure consistent workflow.

### **Rules Established:**
1. **Development Model Separation:**
   - OpenClaw: No Ollama models configured
   - Claude Code: Uses `ollama launch claude --model qwen3.5:9b` for coding work
   - Agents invoke Qwen at runtime, not configured in OpenClaw
   - **CORRECTION (2026-03-19 15:42):** `claude --model qwen3.5:9b` does NOT work, use `ollama launch claude --model qwen3.5:9b`

2. **Tool Integration Mandatory:**
   - Jira tickets BEFORE work
   - GitHub commits DURING work  
   - Slack notifications AFTER work
   - Named agent delegation (Trinity, Morpheus, Cypher)

3. **Cost Control:**
   - Zero-cost development via local Qwen3.5:9b
   - Minimal OpenClaw API usage for orchestration only

### **Files Created:**
1. `/Users/clawdia/.openclaw/workspace/PRDFORGE_PROJECT_RULES.md` - Complete rules
2. `/Users/clawdia/.openclaw/workspace/README_RULES_FIRST.md` - Prominent warning
3. **Updated:** `AGENTS.md` with mandatory rule reference

### **Current PRDForge Status:**
- ✅ Production: https://prdforge-dev.netlify.app working
- ✅ OAuth: Supabase config updated (redirects to production)
- ✅ Database: 635+ rows migrated
- ✅ Edge Functions: 22+ deployed
- ✅ UI: Overlapping buttons removed
- ✅ React: Upgrade in progress

### **Enforcement:**
- Rules are MANDATORY for all agents
- Violation = immediate task stop and reassignment
- All agents must read rules before PRDForge work

### **Key Configuration:**
- OpenClaw: `openai-codex/gpt-5.3-codex` (no Ollama)
- Claude Code: `ollama launch claude --model qwen3.5:9b` (corrected command)
- Jira: `ATLASSIAN_API_TOKEN` configured
- Slack: Bot token configured
- GitHub: Repository access

**Status:** Rules active and enforced from 2026-03-19 15:33
EOF && echo "✅ Memory entry created"