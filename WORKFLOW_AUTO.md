# WORKFLOW_AUTO.md - Automatic Context Management

## Purpose
Prevent context overflow errors by managing memory and session lifecycle.

## Rules

### 1. Session Health Monitoring
- If conversation exceeds 50+ messages, suggest `/reset`
- If response time slows significantly, auto-suggest model switch
- Daily memory file pruning: keep only last 7 days active

### 2. Memory Management
- Daily: Create memory/YYYY-MM-DD.md if missing
- Weekly: Archive memory files older than 30 days to memory/archive/
- Monthly: Review MEMORY.md for pruning

### 3. Model Selection
- Default: deepseek/deepseek-chat (cost-effective)
- Heavy coding/analysis: Switch to openai-codex/gpt-5.3-codex
- Command: `/model openai-codex/gpt-5.3-codex`

### 4. Overflow Prevention Triggers
- System warning about context size → immediate `/reset` suggestion
- Error "prompt too large" → auto-execute `/reset` sequence
- After reset: Always run full Session Startup sequence

### 5. Startup Sequence (Post-Reset)
1. Read SOUL.md
2. Read USER.md  
3. Read memory/today.md (create if missing)
4. Read memory/yesterday.md (if exists)
5. Read MEMORY.md
6. Read WORKFLOW_AUTO.md (this file)

## Emergency Response
If overflow occurs:
1. User executes `/reset` or `/new`
2. System auto-compacts memory
3. I run startup sequence
4. Resume normal operations

## Status Check
Run `/status` periodically to monitor:
- Context usage
- Model performance
- Memory file sizes

Last updated: 2026-02-27
Created after context overflow incident