# Ollama Model Options for System Command Performance

## Current Benchmark: DeepSeek Chat
- **Strengths:** Good at system commands, instructions, reasoning
- **Size:** ~16B parameters (quantized)
- **Performance:** Balanced speed/quality for assistant tasks

## Recommended Ollama Models (Similar Performance)

### Tier 1: Best Matches for System Commands

#### 1. **Qwen2.5-Coder (7B or 14B)**
- **Why:** Excellent for system commands, coding, instructions
- **Size:** 7B (4.1GB) or 14B (8.2GB)
- **Command:** `ollama pull qwen2.5-coder:7b` or `qwen2.5-coder:14b`
- **Strengths:** 
  - Strong instruction following
  - Good at system/terminal commands
  - Coding assistance
  - Logical reasoning

#### 2. **Llama 3.2 (3B or 11B Vision)**
- **Why:** Good balance of speed and capability
- **Size:** 3B (1.8GB) or 11B (6.6GB)
- **Command:** `ollama pull llama3.2` or `llama3.2-vision:11b`
- **Strengths:**
  - Fast inference
  - Good instruction following
  - Balanced performance
  - 3B version very fast for simple tasks

#### 3. **DeepSeek-Coder-V2-Lite (16B)**
- **Why:** Direct match to current DeepSeek style
- **Size:** 16B (9.2GB)
- **Command:** `ollama pull deepseek-coder-v2-lite:16b`
- **Strengths:**
  - Same architecture as current model
  - Excellent coding/system commands
  - Strong reasoning
  - Familiar behavior

### Tier 2: Good Alternatives

#### 4. **Mistral-Nemo (12B)**
- **Why:** Strong general purpose, good instructions
- **Size:** 12B (7.1GB)
- **Command:** `ollama pull mistral-nemo:12b`
- **Strengths:**
  - Good at following complex instructions
  - Strong reasoning
  - Balanced performance

#### 5. **Phi-3.5-Mini (3.8B)**
- **Why:** Surprisingly capable for small size
- **Size:** 3.8B (2.3GB)
- **Command:** `ollama pull phi3.5:mini`
- **Strengths:**
  - Very fast
  - Good instruction following for size
  - Low resource usage

### Tier 3: Specialized Options

#### 6. **CodeQwen1.5 (7B)**
- **Why:** Specialized for code/system commands
- **Size:** 7B (4.1GB)
- **Command:** `ollama pull codeqwen1.5:7b`
- **Strengths:**
  - Excellent at terminal commands
  - Strong coding assistance
  - Good system interaction

#### 7. **Granite-Code (3B or 8B)**
- **Why:** IBM's coding-focused model
- **Size:** 3B (1.8GB) or 8B (4.7GB)
- **Command:** `ollama pull granite-code:3b` or `granite-code:8b`
- **Strengths:**
  - Strong system command understanding
  - Good at automation tasks
  - Enterprise-focused

## Performance Comparison

### For System Commands & Instructions:
1. **Qwen2.5-Coder (14B)** - Best overall match
2. **DeepSeek-Coder-V2-Lite (16B)** - Direct replacement
3. **Llama 3.2 (11B)** - Good balance
4. **Mistral-Nemo (12B)** - Strong general purpose

### For Speed & Efficiency:
1. **Llama 3.2 (3B)** - Fastest, decent quality
2. **Phi-3.5-Mini (3.8B)** - Good quality for size
3. **Qwen2.5-Coder (7B)** - Balanced speed/quality

### For Coding/Automation:
1. **DeepSeek-Coder-V2-Lite (16B)** - Best coding
2. **Qwen2.5-Coder (14B)** - Excellent all-rounder
3. **CodeQwen1.5 (7B)** - Specialized coding

## Installation & Setup

### Step 1: Install Ollama (if not installed)
```bash
# macOS
brew install ollama

# Linux
curl -fsSL https://ollama.com/install.sh | sh
```

### Step 2: Pull Recommended Model
```bash
# Recommended starting point
ollama pull qwen2.5-coder:14b

# Or for faster testing
ollama pull llama3.2:3b
```

### Step 3: Configure OpenClaw

Update `~/.openclaw/openclaw.json`:
```json
"models": {
  "providers": {
    "ollama": {
      "baseUrl": "http://127.0.0.1:11434/v1",
      "apiKey": "ollama",
      "api": "openai-completions",
      "models": [
        {
          "id": "qwen2.5-coder:14b",
          "name": "ollama-qwen-coder"
        }
      ]
    }
  }
},
"agents": {
  "defaults": {
    "model": {
      "primary": "ollama/qwen2.5-coder:14b",
      "fallbacks": [
        "deepseek/deepseek-chat",
        "openrouter/auto"
      ]
    }
  }
}
```

### Step 4: Test Configuration
```bash
# Test Ollama directly
ollama run qwen2.5-coder:14b "List files in current directory with ls -la"

# Test with OpenClaw
openclaw agent --model ollama/qwen2.5-coder:14b --message "Test system command"
```

## Memory & Hardware Requirements

### Minimum (8GB RAM):
- Llama 3.2 (3B) - 1.8GB
- Phi-3.5-Mini (3.8B) - 2.3GB
- Qwen2.5-Coder (7B) - 4.1GB

### Recommended (16GB+ RAM):
- Qwen2.5-Coder (14B) - 8.2GB
- Mistral-Nemo (12B) - 7.1GB
- Llama 3.2 (11B) - 6.6GB

### Optimal (32GB+ RAM):
- DeepSeek-Coder-V2-Lite (16B) - 9.2GB
- Multiple models concurrently

## Testing Strategy

### Phase 1: Quick Test (Day 1)
```bash
# Pull small model
ollama pull llama3.2:3b

# Test basic commands
ollama run llama3.2:3b "How to list files with details?"

# Update OpenClaw config temporarily
```

### Phase 2: Performance Test (Day 2-3)
```bash
# Pull recommended model
ollama pull qwen2.5-coder:14b

# Test system commands
ollama run qwen2.5-coder:14b "Write a bash script to backup files"

# Compare with DeepSeek
```

### Phase 3: Full Integration (Day 4-7)
- Update OpenClaw default model
- Test email processing
- Test cron job execution
- Monitor performance

## Cost-Benefit Analysis

### Current (DeepSeek Cloud):
- **Cost:** ~$0.30-0.50/day (after optimization)
- **Latency:** Network dependent
- **Privacy:** Data leaves local machine
- **Reliability:** API dependent

### Local (Ollama):
- **Cost:** $0 (after hardware)
- **Latency:** Local, faster for simple tasks
- **Privacy:** 100% local
- **Reliability:** No API dependencies
- **Hardware:** Requires RAM/GPU

## Migration Plan

### Week 1: Testing
- Test 2-3 models
- Compare performance
- Identify best fit

### Week 2: Parallel Run
- Run local model alongside DeepSeek
- Compare results
- Adjust configuration

### Week 3: Primary Switch
- Make local model primary
- Keep DeepSeek as fallback
- Monitor for issues

### Week 4: Optimization
- Fine-tune model selection
- Optimize prompts
- Adjust for local strengths

## Troubleshooting

### Common Issues:

1. **Out of Memory:**
   ```bash
   # Reduce context size
   OLLAMA_NUM_CTX=2048 ollama run model
   
   # Use smaller model
   ollama pull llama3.2:3b
   ```

2. **Slow Performance:**
   ```bash
   # Enable GPU acceleration
   OLLAMA_GPU_LAYERS=20 ollama run model
   
   # Use quantization
   ollama pull model:q4_0
   ```

3. **OpenClaw Integration:**
   ```bash
   # Check Ollama is running
   curl http://localhost:11434/api/tags
   
   # Test API endpoint
   curl http://localhost:11434/v1/chat/completions -d '{"model":"qwen2.5-coder:14b","messages":[{"role":"user","content":"test"}]}'
   ```

## Recommended Starting Point

### For Immediate Testing:
```bash
# Pull and test
ollama pull llama3.2:3b
ollama run llama3.2:3b "Write a cron job for daily backup"

# Quick OpenClaw test
openclaw agent --model ollama/llama3.2:3b --message "Process email about organogram update"
```

### For Production Use:
```bash
# Pull recommended model
ollama pull qwen2.5-coder:14b

# Configure as primary
# Update openclaw.json model configuration
```

## Final Recommendation

**Start with:** `qwen2.5-coder:14b`
- Best balance of instruction following and system command capability
- Similar performance profile to DeepSeek
- Good community support
- Regular updates

**Fallback:** `llama3.2:3b` for speed testing
**Alternative:** `deepseek-coder-v2-lite:16b` for direct replacement

## Next Steps

1. **Install Ollama** (if not already)
2. **Pull test model:** `ollama pull llama3.2:3b`
3. **Test basic commands**
4. **Update OpenClaw configuration**
5. **Run parallel test with DeepSeek**
6. **Evaluate and choose primary model**

## Resources
- [Ollama Models Library](https://ollama.com/library)
- [OpenClaw Model Configuration](https://docs.openclaw.ai/configuration/models)
- [Local Model Performance Guide](https://github.com/ollama/ollama/wiki/Performance-Guide)