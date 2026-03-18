# Qwen 3.5 9B + Claude Code Hybrid Workflow

## When to Use Which Model

### **Use Claude Code (Cloud, Paid)**
- Complex software projects
- Production code with Superpowers workflow
- Code review and architecture design
- When you need advanced reasoning
- Team collaboration features

### **Use Qwen 3.5 9B (Local, Free)**
- Privacy-sensitive code (API keys, credentials)
- Offline development
- Simple scripts and utilities
- Learning/experimentation
- High-volume code generation (no API costs)

## Quick Commands

### **Start Claude Code**
```bash
cd /path/to/project
claude
# Authenticates via browser, then you're in
```

### **Start Qwen 3.5 9B**
```bash
# Direct Ollama
ollama run qwen3.5:9b

# Via OpenClaw session
sessions_spawn model="ollama/qwen3.5:9b" task="Your coding task"
```

### **Use Superpowers (Claude Code only)**
1. Start Claude Code
2. Ask: "Help me plan this feature"
3. Superpowers skills auto-trigger

## Model Comparison

| Feature | Claude Code | Qwen 3.5 9B |
|---------|-------------|-------------|
| **Model** | Claude 3.5 Sonnet/Opus | Qwen 3.5 9B |
| **Location** | Cloud | Local |
| **Cost** | Paid (Anthropic) | Free |
| **Speed** | Fast (cloud) | Slower (local) |
| **Context** | 200K tokens | 32K tokens |
| **Coding** | Advanced | Good |
| **Security** | Cloud privacy | Local privacy |
| **Superpowers** | ✅ Yes | ❌ No |

## Integration Points

1. **Claude Code for planning** → Qwen for implementation
2. **Qwen for local prototyping** → Claude Code for refinement
3. **Both available via OpenClaw** orchestration

## Authentication Status
- **Claude Code**: Needs browser authentication (run `claude`)
- **Qwen 3.5 9B**: Ready now (no auth needed)
- **Superpowers**: Installed for Claude Code