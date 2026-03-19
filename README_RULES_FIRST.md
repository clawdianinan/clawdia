# ⚠️⚠️⚠️ STOP - READ RULES FIRST! ⚠️⚠️⚠️

## **BEFORE DOING ANY PRDFORGE WORK:**

### **1. READ THE RULES FILE:**
**Location:** `/Users/clawdia/.openclaw/workspace/PRDFORGE_PROJECT_RULES.md`

### **2. CRITICAL RULES SUMMARY:**
- **NO Ollama in OpenClaw** - Agents invoke Qwen at runtime
- **Claude Code uses:** `claude --model qwen3.5:9b`
- **Jira tickets BEFORE work**
- **GitHub commits DURING work**
- **Slack notifications AFTER work**

### **3. VIOLATION = IMMEDIATE STOP**

### **4. CHECK CURRENT STATUS:**
- Production: https://prdforge-dev.netlify.app
- GitHub: https://github.com/clawdianinan/prdforge
- Jira: https://clawdianinan.atlassian.net

---

## **QUICK REFERENCE:**

```bash
# CORRECT COMMAND for coding work (launches interactive Claude Code):
ollama launch claude --model qwen3.5:9b

# Then use Claude Code interactively for task description

# Agent delegation:
sessions_spawn({
  runtime: "acp",
  agentId: "claude-code",
  task: "Use ollama launch claude --model qwen3.5:9b for interactive coding"
})

# IMPORTANT: `claude --model qwen3.5:9b` does NOT work
```

---

**IGNORING THESE RULES WILL RESULT IN TASK FAILURE AND REASSIGNMENT**

EOF && echo "✅ Created prominent rules notice" && echo "" && echo "Files created:" && ls -la PRDFORGE_PROJECT_RULES.md README_RULES_FIRST.md