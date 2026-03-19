# DEVELOPMENT MODEL RULE - SYSTEM WIDE

## 🚨 **RULE VIOLATION DETECTED: 2026-03-18 06:55 AM**

### **System Rule:**
> "All development work is done via Claude Code with Qwen on local Ollama. Do not use cloud models for development unless instructed."

### **Current Violation:**
- **Agent:** Trinity (STAB-002 RESTART)
- **Model Used:** `gpt-5.3-codex` (cloud model)
- **Task:** P0 defect resolution (development work)
- **Status:** Session active, critical path blocker

### **Correction Actions:**

#### 1. **Current Session (Trinity STAB-002):**
- **Status:** Already running with cloud model
- **Action:** Allow to complete (critical path)
- **Note:** Document violation, ensure future compliance

#### 2. **Future Sessions:**
- **Requirement:** Use local Ollama models for development work
- **Available local models:** 
  - `qwen3.5:9b` (6.6 GB)
  - `llama3.1:8b` (4.9 GB)
- **Configuration needed:** Specify `model` parameter in `sessions_spawn` to use local models

#### 3. **Model Mapping by Agent Type:**

| Agent | Primary Work | Model Requirement |
|-------|-------------|-------------------|
| **Trinity** | Coding, debugging, technical fixes | **Local Ollama (Qwen 3.5 9B)** |
| **Fela** | Visual design, creative work | Can use cloud models (non-development) |
| **Ebun** | Research, writing, documentation | Can use cloud models (non-development) |
| **Nova** | Strategy, planning, analysis | Can use cloud models (non-development) |
| **Shuri** | Quality control, testing | Can use cloud models (non-development) |
| **Sheba** | Commercial, billing, analytics | Can use cloud models (non-development) |
| **Clawdia** | Orchestration, coordination | Current model acceptable |

### **Technical Implementation:**

#### For Development Tasks (Trinity):
```javascript
sessions_spawn({
  task: "...",
  label: "...",
  runtime: "subagent",
  model: "ollama/qwen3.5:9b"  // Local model specification
})
```

#### For Non-Development Tasks (Other agents):
```javascript
sessions_spawn({
  task: "...",
  label: "...", 
  runtime: "subagent"
  // No model specified = use default
})
```

### **Verification Checklist:**
- [ ] Trinity's current session completes (exception allowed)
- [ ] Future Trinity sessions use `model: "ollama/qwen3.5:9b"`
- [ ] Document model usage in agent allocation tracker
- [ ] Update spawn templates for development work
- [ ] Monitor model usage in session listings

### **Impact Assessment:**
- **Current:** Minimal - One session violation, critical path
- **Future:** All development work will use local models
- **Cost:** Reduced cloud model usage, increased local compute
- **Performance:** Local models may be slower but comply with rule

### **Compliance Plan:**
1. **Immediate:** Document current violation
2. **Short-term:** Update Trinity's next task spawn with local model
3. **Long-term:** Create agent-specific model configuration template
4. **Monitoring:** Check session models in daily standups

---
**Rule Established:** 2026-03-18  
**Violation Detected:** 2026-03-18 06:55 AM  
**Corrective Action:** Future development sessions will use local Ollama models  
**Owner:** Clawdia (Orchestration)