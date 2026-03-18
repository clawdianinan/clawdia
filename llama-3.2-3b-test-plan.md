# Llama 3.2 3B Instruct - OpenClaw Integration Test Plan

## Current Status
- **✅ Download complete:** 100% (2.0 GB / 2.0 GB)
- **✅ Model verified:** Available in Ollama as `llama3.2:3b`
- **✅ OpenClaw Config:** Updated with model configuration
- **✅ Model ID:** `ollama/llama3.2:3b`
- **✅ Fallback Position:** Added to agents.defaults.model.fallbacks
- **Next step:** Restart OpenClaw gateway and begin Phase 1 testing

## Test Suite

### Phase 1: Basic Functionality (Immediate after download)
1. **Model Verification**
   - Check if model appears in `ollama list`
   - Verify model size and metadata

2. **Simple Conversation Test**
   - Basic greeting response
   - Simple Q&A test

3. **Tool Calling Test**
   - Execute simple `exec` command
   - Read a file using `read` tool
   - Write a test file using `write` tool

### Phase 2: OpenClaw Integration Tests
1. **Configuration Test**
   - Verify OpenClaw can connect to Ollama
   - Test model selection via fallback mechanism

2. **Skill Execution Test**
   - Test basic skill (weather, github, etc.)
   - Verify tool calling works through OpenClaw

3. **Multi-step Task Test**
   - "Read file X, then edit line Y"
   - "Create a test file and list directory contents"

### Phase 3: Advanced Agent Capabilities
1. **Sub-agent Spawning Test**
   - Test spawning a simple sub-agent
   - Verify communication between agents

2. **Complex Tool Chains**
   - Multiple tool calls in sequence
   - Error handling and recovery

3. **Memory System Test**
   - Read/write to memory files
   - Memory search functionality

## Success Criteria

### Must Pass (Critical)
1. ✅ Responds conversationally (not raw JSON)
2. ✅ Handles basic tool calls correctly
3. ✅ Executes simple skills properly
4. ✅ Works with OpenClaw's fallback system

### Should Pass (Important)
1. ✅ Supports multi-step tasks
2. ✅ Handles file operations reliably
3. ✅ Works with memory system
4. ✅ Reasonable response times (<10 seconds)

### Nice to Have
1. ✅ Can spawn sub-agents
2. ✅ Handles complex tool chains
3. ✅ Good instruction following
4. ✅ Stable for daily use

## Test Execution Log

### Pre-Test Setup
- [x] OpenClaw configuration updated
- [x] Model added to fallbacks list
- [ ] Model download completed
- [ ] Gateway restart required

### Test Execution
- [ ] Phase 1: Basic Functionality
- [ ] Phase 2: OpenClaw Integration
- [ ] Phase 3: Advanced Capabilities

## Fallback Plan
If Llama 3.2 3B doesn't meet success criteria:
1. **Try Qwen2.5 7B Instruct** (4.5 GB) - Better instruction following
2. **Try Phi-3 Mini 3.8B** (2.3 GB) - Microsoft's alternative
3. **Try Gemma 2 9B** (5.5 GB) - Best quality but largest

## Notes
- Model size: ~2.0 GB
- Expected RAM usage: ~4-6 GB during inference
- Ollama base URL: `http://127.0.0.1:11434/v1`
- OpenClaw model ID: `ollama/llama3.2:3b`