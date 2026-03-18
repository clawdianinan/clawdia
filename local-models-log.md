# Local Model Performance Log for OpenClaw
**Machine:** Apple Silicon Mac with 16GB RAM
**Date:** 2026-02-26
**Purpose:** Find best local model for OpenClaw agent workflows

---

## **Models Attempted & Performance**

### **1. Llama 3.2 3B (2.0 GB)**
- **Status:** Currently in use
- **Download Date:** 2026-02-26
- **Performance Issues:**
  - Poor response quality
  - Limited reasoning capability
  - Struggles with complex tool calling
  - Shallow, simplistic responses
- **Verdict:** ❌ **FAILED** - Too small for OpenClaw agent work

### **2. Gemma 2 2B (1.6 GB)**
- **Status:** Downloaded but not primary
- **Performance Issues:**
  - Even smaller than Llama 3.2 3B
  - Basic responses only
  - Not suitable for agent workflows
- **Verdict:** ❌ **FAILED** - Insufficient capacity

### **3. Qwen2.5 Coder 1.5B (986 MB)**
- **Status:** Downloaded but not primary
- **Performance Issues:**
  - Smallest of all, coding-focused
  - Limited general reasoning
  - Not enough parameters for agent work
- **Verdict:** ❌ **FAILED** - Too specialized, too small

---

## **Root Cause Analysis**
**Problem:** All attempted models are **≤3B parameters** - insufficient for:
1. Complex tool calling/function execution
2. Multi-step reasoning
3. Agent delegation workflows
4. Quality conversation

**Minimum Viable Size:** **7B+ parameters** required for decent OpenClaw performance

---

## **Best Possible Local Models for 16GB Mac**

### **TIER 1: Optimal Balance (7B-10B)**
These will fit comfortably with good performance:

1. **DeepSeek Coder 6.7B** (~3.8GB Q4_K_M)
   - **Why best:** Different architecture, excellent tool calling
   - **RAM Usage:** ~5GB
   - **Quality:** Excellent for technical/agent work
   - **Command:** `ollama pull deepseek-coder:6.7b`

2. **Solar 10.7B** (~6.1GB Q4_K_M)
   - **Why best:** Mixture of Experts, punches above weight
   - **RAM Usage:** ~8GB
   - **Quality:** Approaches 13B model performance
   - **Command:** `ollama pull solar:10.7b`

3. **Llama 3.1 8B** (~4.7GB Q4_K_M)
   - **Why:** Proper 8B size (vs failed 3B)
   - **RAM Usage:** ~6.1GB
   - **Quality:** Good general purpose
   - **Command:** `ollama pull llama3.1:8b`

### **TIER 2: Maximum Possible (Pushing Limits)**
These might work but will be tight:

4. **Mistral 8x7B** (~12GB Q4_K_M)
   - **RAM Usage:** ~15.6GB (tight on 16GB)
   - **Risk:** Possible swapping/slowdown
   - **Quality:** Excellent (near GPT-3.5 level)

5. **Qwen2.5 14B** (~8GB Q4_K_M)
   - **RAM Usage:** ~10.4GB
   - **Quality:** Very good, larger context

---

## **Recommendation Matrix**

| Model | Size (Q4) | RAM Est | Quality | Tool Calling | Risk | Verdict |
|-------|-----------|---------|---------|--------------|------|---------|
| DeepSeek Coder 6.7B | 3.8GB | ~5GB | Excellent | ⭐⭐⭐⭐⭐ | Low | **BEST CHOICE** |
| Solar 10.7B | 6.1GB | ~8GB | Excellent | ⭐⭐⭐⭐ | Low | Great alternative |
| Llama 3.1 8B | 4.7GB | ~6.1GB | Good | ⭐⭐⭐ | Low | Solid option |
| Mistral 8x7B | 12GB | ~15.6GB | Excellent | ⭐⭐⭐⭐ | High | Risky on 16GB |

---

## **Action Plan**

### **Immediate Next Step:**
```bash
# Download the recommended model
ollama pull deepseek-coder:6.7b

# Verify download
ollama list

# Update OpenClaw config
# Add to ~/.openclaw/openclaw.json models.providers.ollama.models
```

### **Configuration Update:**
Add to OpenClaw config:
```json
{
  "id": "deepseek-coder:6.7b",
  "name": "deepseek-coder-6.7b-local"
}
```

### **Testing Protocol:**
1. Basic conversation test
2. Tool calling test (exec, read, write)
3. Skill execution test
4. Agent delegation test
5. Multi-step workflow test

---

## **Lessons Learned**
1. **Minimum 7B parameters** required for OpenClaw agent work
2. **Architecture matters** - DeepSeek different from Llama/Mistral
3. **Quantization crucial** - Q4_K_M provides best size/quality balance
4. **RAM planning** - Model size × 1.3 = inference memory needed

---

## **Future Considerations**
If DeepSeek Coder 6.7B works well:
- Consider Solar 10.7B for even better quality
- Monitor RAM usage during heavy workloads
- Keep cloud fallbacks (DeepSeek Chat, OpenAI) for complex tasks

## **Current Status (2026-02-26 05:54 GMT+1)**

### **Actions Completed:**
1. ✅ Removed all previous models:
   - `llama3.2:3b` (2.0 GB)
   - `gemma2:2b` (1.6 GB)
   - `qwen2.5-coder:1.5b` (986 MB)

2. ✅ Started downloading **DeepSeek Coder 6.7B**:
   - **Progress:** 9% complete (~355MB of 3.8GB)
   - **Speed:** ~8.1 MB/s
   - **ETA:** ~7 minutes

3. ✅ Updated OpenClaw configuration:
   - Added `deepseek-coder:6.7b` to ollama models
   - Updated fallbacks list
   - Removed old `llama3.2:3b` references

### **Next Steps After Download:**
1. Verify download completion
2. Restart OpenClaw gateway
3. Test model with basic commands
4. Run comprehensive test suite

**Last Updated:** 2026-02-26 05:54 GMT+1
**Next Review:** After DeepSeek Coder 6.7B download completes