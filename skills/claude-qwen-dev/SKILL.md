# Claude-Qwen Development Skill

## 🎯 Purpose
Standardized, zero-cost software development using Claude Code with Qwen3.5:9b via Ollama. Enforces PRDForge project rules and provides consistent development workflow.

## 📋 When to Use
Use this skill when:
- Developing code for PRDForge or any project
- Need zero-cost local development
- Following PRDForge project rules
- Using Claude Code with Qwen3.5:9b model
- Ensuring consistent development workflow

## 🚫 When NOT to Use
- Do NOT use for OpenClaw orchestration (use API models)
- Do NOT use `claude --model qwen3.5:9b` (doesn't work)
- Do NOT configure Ollama in OpenClaw config

## 🔧 Core Command
```bash
# CORRECT command (tested and working):
ollama launch claude --model qwen3.5:9b

# Then use Claude Code interactively for:
# - Coding tasks
# - Feature implementation
# - Bug fixes
# - Code reviews
```

## 📁 Skill Structure
```
claude-qwen-dev/
├── SKILL.md              # This file
├── scripts/
│   ├── launch-claude.sh  # Standardized launch script
│   ├── validate-setup.sh # Setup validation
│   └── quick-test.sh     # Quick functionality test
├── templates/
│   └── task-template.md  # Standard task template
└── references/
    └── best-practices.md # Development best practices
```

## 🚀 Quick Start

### 1. Launch Claude with Qwen:
```bash
# Use the standardized script:
./scripts/launch-claude.sh "Fix React component issue"

# Or directly:
ollama launch claude --model qwen3.5:9b -- "Your coding task here"
```

### 2. For Interactive Development:
```bash
ollama launch claude --model qwen3.5:9b
# Then interact with Claude Code in the terminal
```

## 📋 Standard Workflow

### Before Development:
1. **Jira Ticket:** SHURI creates ticket (mandatory)
2. **Task Definition:** Clear scope and requirements
3. **Environment:** Verify Ollama and Qwen installed

### During Development:
1. **Launch:** Use this skill's standardized command
2. **Code:** Implement using Claude Code + Qwen
3. **Test:** Local testing and validation
4. **Commit:** GitHub commits with descriptive messages

### After Development:
1. **Deploy:** Netlify deployment (if applicable)
2. **Notify:** CHIMAMANDA sends Slack notification
3. **Update:** SHURI updates Jira ticket
4. **Document:** Update project documentation

## 🔧 Setup Validation

### Check Ollama Installation:
```bash
./scripts/validate-setup.sh
```

### Expected Output:
```
✅ Ollama installed: version x.x.x
✅ Qwen3.5:9b model available
✅ Claude integration available
✅ Ready for zero-cost development
```

## 🎯 Agent Integration

### For TRINITY (Implementation Agent):
```bash
# Standard invocation:
ollama launch claude --model qwen3.5:9b -- "Implement feature X for PRDForge"

# With this skill:
./scripts/launch-claude.sh "Implement feature X"
```

### For MORPHEUS (QA Agent):
```bash
# Testing tasks:
ollama launch claude --model qwen3.5:9b -- "Write test cases for feature Y"
```

### For CYPHER (Security Agent):
```bash
# Security scanning:
ollama launch claude --model qwen3.5:9b -- "Review code for security vulnerabilities"
```

## ⚠️ Common Errors & Solutions

### Error: "claude --model qwen3.5:9b not found"
**Solution:** Use `ollama launch claude --model qwen3.5:9b` instead

### Error: "Input must be provided"
**Solution:** Add task after `--` or use interactively

### Error: "Model not found"
**Solution:** Run `ollama pull qwen3.5:9b`

### Error: "Claude integration not available"
**Solution:** Update Ollama: `ollama update`

## 📊 Performance Tips

### For Best Results:
1. **Clear Prompts:** Be specific about requirements
2. **Context:** Provide relevant code context
3. **Iterative:** Work in small, testable increments
4. **Validation:** Test code immediately after generation

### Memory Management:
- Qwen3.5:9b has 9B parameters
- Suitable for most development tasks
- For very large files, work in sections

## 🔗 Integration with PRDForge Rules

This skill enforces:
- ✅ Zero-cost development (local Qwen)
- ✅ Correct command usage
- ✅ Agent workflow compliance
- ✅ Platform management integration

## 🚨 Compliance Rules

### Mandatory:
1. Always use `ollama launch claude --model qwen3.5:9b`
2. Never configure Ollama in OpenClaw
3. Follow Jira → GitHub → Slack workflow
4. Use agents per their roles

### Prohibited:
1. `claude --model qwen3.5:9b` (doesn't work)
2. API models for development work
3. Skipping Jira tickets
4. Bypassing agent delegation

## 📈 Success Metrics

### Development Quality:
- Code compiles/runs without errors
- Follows project coding standards
- Includes appropriate tests
- Documentation updated

### Process Compliance:
- Jira ticket created before work
- GitHub commits during work
- Slack notifications after work
- Agent roles respected

## 🔄 Updates & Maintenance

### Version History:
- **v1.0** (2026-03-19): Initial skill creation
- **Future:** Add more templates, validation scripts

### To Update:
1. Modify scripts in `scripts/` directory
2. Update this SKILL.md file
3. Test with `./scripts/quick-test.sh`
4. Deploy to all agents

## 📞 Support & Troubleshooting

### Quick Debug:
```bash
./scripts/quick-test.sh
```

### Common Issues:
1. **Ollama not running:** `ollama serve`
2. **Model not pulled:** `ollama pull qwen3.5:9b`
3. **Permission issues:** Check script permissions

### Escalation:
1. Check `references/best-practices.md`
2. Review PRDForge project rules
3. Contact Clawdia for orchestration issues

---

**Status:** ✅ ACTIVE - Enforces PRDForge development rules
**Priority:** HIGH - Mandatory for all development work
**Compliance:** STRICT - Violation stops task immediately