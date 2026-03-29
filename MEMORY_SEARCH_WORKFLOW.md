# Memory Search Workflow (QMD Fallback)
## For use when OpenAI embedding quota is exhausted

## Quick Reference

### When you need to search memory:
1. **First try:** Use `memory_search` tool (may fail with quota error)
2. **If fails:** Use QMD fallback commands below
3. **For complex queries:** Combine QMD search with manual file reading

## QMD Search Commands

### Basic Search
```bash
# Search memory files
/Users/clawdia/.openclaw/workspace/scripts/qmd-memory-search.sh search "query" 10

# Python API (returns JSON)
python3 /Users/clawdia/.openclaw/workspace/scripts/qmd_fallback_memory.py search "query" 10
```

### Get Specific File
```bash
# Read MEMORY.md lines 1-50
/Users/clawdia/.openclaw/workspace/scripts/qmd-memory-search.sh get /Users/clawdia/.openclaw/workspace/MEMORY.md 1 50

# Read specific memory file
/Users/clawdia/.openclaw/workspace/scripts/qmd-memory-search.sh get /Users/clawdia/.openclaw/workspace/memory/2026-03-*.md 1 30
```

### Maintenance
```bash
# Index memory files (run weekly)
/Users/clawdia/.openclaw/workspace/scripts/qmd-memory-search.sh index

# Test QMD
/Users/clawdia/.openclaw/workspace/scripts/qmd-memory-search.sh test
```

## Common Search Patterns

### 1. Find Recent Decisions
```bash
qmd-memory-search.sh search "decision approval financial" 5
qmd-memory-search.sh search "IHS logo proposal" 3
```

### 2. Find Email Rules
```bash
qmd-memory-search.sh search "IHS Towers email priority" 5
qmd-memory-search.sh search "email formatting HTML" 3
```

### 3. Find Operational Rules
```bash
qmd-memory-search.sh search "DOCX formatting markdown" 3
qmd-memory-search.sh search "signature block IIH" 3
```

### 4. Find Project Context
```bash
qmd-memory-search.sh search "PRDForge project" 5
qmd-memory-search.sh search "STREAMS billing" 3
```

## Integration with Assistant Workflow

### Before answering questions about:
- **Past decisions** → Search memory first
- **Operational rules** → Check MEMORY.md
- **Email protocols** → Search for email rules
- **Financial approvals** → Check recent payment docs

### Example workflow:
```
User: "What's the status of the Learn2 Earn payment?"
Assistant: [Internal]
1. Run: qmd-memory-search.sh search "Learn2 Earn payment" 5
2. Found: Learn2Earn-Payment-Approval.md (score: 27.699)
3. Read: qmd-memory-search.sh get /path/to/Learn2Earn-Payment-Approval.md 1 20
4. Answer based on found content
```

## Manual Fallback (If QMD Fails)

### Read MEMORY.md directly:
```bash
# Use read tool on MEMORY.md
read /Users/clawdia/.openclaw/workspace/MEMORY.md

# Search with grep
grep -i "search term" /Users/clawdia/.openclaw/workspace/MEMORY.md | head -10
```

### Check recent memory files:
```bash
# List recent memory files
ls -la /Users/clawdia/.openclaw/workspace/memory/*.md | tail -5

# Read most recent
read /Users/clawdia/.openclaw/workspace/memory/$(ls -t /Users/clawdia/.openclaw/workspace/memory/*.md | head -1)
```

## Quality Assurance

### Before relying on QMD results:
1. **Check score** - Higher than 20 is usually relevant
2. **Verify path** - Ensure it's a memory file (MEMORY.md or memory/*.md)
3. **Read snippet** - Confirm relevance
4. **Get full context** - Use `get` command to read more lines

### Red flags:
- Score < 15 → Likely irrelevant
- Non-memory file paths → May not be authoritative
- Old timestamps → May be outdated

## Performance Tips

### For better results:
1. **Use specific keywords** - "IHS Towers" not "email"
2. **Combine searches** - Search multiple related terms
3. **Check multiple files** - Don't rely on single result
4. **Verify with manual read** - When in doubt, read the file

### Example:
```
❌ Poor: "email rules"
✅ Better: "IHS Towers email priority escalation"
✅ Best: "HEARTBEAT.md IHS Towers email"
```

## Status Monitoring

### Check QMD health:
```bash
# Test search
qmd-memory-search.sh search "test" 1

# Check index size
du -sh /Users/clawdia/.openclaw/workspace/skills/qmd/index/

# View logs
tail -20 /Users/clawdia/.openclaw/workspace/skills/qmd/qmd.log
```

### If QMD fails:
1. **Reindex:** `qmd-memory-search.sh index`
2. **Check dependencies:** `pip list | grep -E "(whoosh|frontmatter)"`
3. **Manual workaround:** Use `read` tool on MEMORY.md

## Summary

**Primary path:** Use QMD for memory searches when OpenAI embeddings fail
**Fallback path:** Manual file reading with `read` tool
**Emergency path:** Direct grep/search of MEMORY.md

**Remember:** QMD is keyword-based, not semantic. Use specific terms for best results.

---
**Last Updated:** 2026-03-26  
**Next Review:** When OpenAI quota is restored or local embeddings configured