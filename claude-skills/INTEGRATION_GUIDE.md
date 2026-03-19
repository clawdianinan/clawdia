# Claude Code Skills Integration Guide

## Overview
This directory contains skill templates for enhancing Claude Code capabilities when used with OpenClaw.

## Available Skills

### 1. Code Reviewer
- **Purpose:** Comprehensive code review for multiple languages
- **Trigger:** "code review", "review this code", "check code quality"
- **Use with:** Trinity (coding agent), Cypher (security agent)

### 2. React Best Practices
- **Purpose:** Vercel-optimized React/Next.js performance guidelines
- **Trigger:** "react", "nextjs", "performance", "optimization"
- **Use with:** Trinity (React development), Fela (design system)

### 3. Debugging Assistant
- **Purpose:** Systematic debugging methodology
- **Trigger:** "debug", "fix error", "troubleshooting"
- **Use with:** All agents for issue diagnosis

## How to Use

### Manual Usage
When using Claude Code interactively, reference these skills by their triggers:

```
Claude, please use the "code reviewer" skill to review this TypeScript code:
[code here]
```

### OpenClaw Integration
The `claude-code-manager.js` script can be extended to automatically apply relevant skills based on task type.

## Skill Development

### Creating New Skills
1. Add skill template to `scripts/claude-skills-setup.js`
2. Run `node scripts/claude-skills-setup.js`
3. Test skill with Claude Code

### Skill Structure
Each skill should include:
- Clear purpose and scope
- Trigger phrases
- Methodology or checklist
- Expected output format

## Integration with aitmpl.com Skills
When aitmpl.com CLI becomes available, additional skills can be installed:

```bash
# Example installation commands
npx claude-code-templates@latest --skill development/code-reviewer
npx claude-code-templates@latest --skill development/react-best-practices
npx claude-code-templates@latest --skill security/security-audit
```

## Fallback Strategy
If automated Claude Code integration fails, use manual interactive mode:

```bash
# Manual interactive session
ANTHROPIC_API_KEY=ollama ANTHROPIC_BASE_URL=http://localhost:11434/v1 \
  claude --model ollama/qwen3.5:9b

# Then reference skills manually
```

## Next Steps
1. Test each skill with sample tasks
2. Extend claude-code-manager.js to use skills
3. Integrate with specific OpenClaw agents
4. Add more specialized skills as needed
