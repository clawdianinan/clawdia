# Fix Memory Search - OpenAI Embedding Quota Exhausted

## Problem
OpenClaw's `memory_search` tool is failing with error:
```
openai embeddings failed: 429 {
    "error": {
        "message": "You exceeded your current quota, please check your plan and billing details.",
        "type": "insufficient_quota",
        "code": "insufficient_quota"
    }
}
```

## Solution
Use local QMD-based memory search instead of OpenAI embeddings.

## Immediate Workaround

### 1. Use QMD Search Script
```bash
# Search memory
/Users/clawdia/.openclaw/workspace/scripts/qmd-memory-search.sh search "your query" 10

# Example: Search for IHS Towers
/Users/clawdia/.openclaw/workspace/scripts/qmd-memory-search.sh search "IHS Towers" 5
```

### 2. Use Python QMD Script (JSON output)
```bash
python3 /Users/clawdia/.openclaw/workspace/scripts/qmd_fallback_memory.py search "your query" 10
```

### 3. Use New Local Memory Search (TF-IDF based)
```bash
python3 /Users/clawdia/.openclaw/workspace/local_memory_search.py "your query" 10
```

## Long-Term Fix Options

### Option 1: Configure Local Embeddings (If Supported)
Check if OpenClaw supports local embedding providers:
```bash
openclaw config set embedding.provider local
openclaw config set embedding.model local-model
```

### Option 2: Disable Embeddings (If Possible)
```bash
openclaw config set agents.defaults.disableEmbeddings true
```

### Option 3: Switch to Different Embedding Provider
If OpenClaw supports other providers (Cohere, Hugging Face, etc.):
```bash
openclaw config set embedding.provider cohere
openclaw config set embedding.apiKey YOUR_COHERE_KEY
```

## Current Status
- **QMD System:** Working ✅ (tested with "IHS Towers" search)
- **Local TF-IDF Index:** Working ✅ (235 documents indexed)
- **OpenAI Embeddings:** Exhausted quota ❌

## Recommended Actions

### Short-term (Now):
1. Use QMD scripts for memory searches
2. Document this workaround in AGENTS.md
3. Create alias/helper function for easier access

### Medium-term (Next few days):
1. Check OpenClaw documentation for local embedding configuration
2. Explore alternative embedding providers
3. Consider setting up local embedding model (SentenceTransformers)

### Long-term (When needed):
1. Top up OpenAI quota if needed
2. Implement proper local embedding pipeline
3. Update OpenClaw configuration to use local embeddings

## Testing the Fix

### Test 1: Basic Search
```bash
/Users/clawdia/.openclaw/workspace/scripts/qmd-memory-search.sh search "memory system" 3
```

### Test 2: Complex Query
```bash
/Users/clawdia/.openclaw/workspace/scripts/qmd-memory-search.sh search "IHS Towers email priority escalation" 5
```

### Test 3: Recent Tasks
```bash
/Users/clawdia/.openclaw/workspace/scripts/qmd-memory-search.sh search "todo task completed" 5
```

## Integration with Assistant Workflow

When you need to search memory:

1. **Instead of:** `memory_search(query="your query")`
2. **Use:** `exec(command="/Users/clawdia/.openclaw/workspace/scripts/qmd-memory-search.sh search 'your query' 10")`
3. **Parse results** from the output

## Example Implementation

```python
# Pseudo-code for memory search wrapper
def memory_search_fallback(query, limit=10):
    cmd = f"/Users/clawdia/.openclaw/workspace/scripts/qmd-memory-search.sh search '{query}' {limit}"
    result = exec(cmd)
    # Parse and return results in similar format to memory_search
    return parse_qmd_output(result)
```

## Monitoring

Check if OpenAI quota is restored:
```bash
# Try memory_search tool occasionally
# When it works, quota is restored
```

## Backup Plan

If QMD fails:
1. Use `grep` on MEMORY.md and memory/*.md files
2. Use `read` tool to manually check files
3. Use the local TF-IDF index directly

## Files Created/Updated

1. `/Users/clawdia/.openclaw/workspace/index_memory.py` - Local TF-IDF indexer
2. `/Users/clawdia/.openclaw/workspace/local_memory_search.py` - Local search tool
3. `/Users/clawdia/.openclaw/workspace/fix_memory_search.md` - This document

## Next Steps

1. **Immediate:** Use QMD for all memory searches
2. **Today:** Update AGENTS.md with memory search workaround
3. **This week:** Research OpenClaw embedding configuration options
4. **When possible:** Restore OpenAI quota or configure local embeddings

---
**Status:** Memory search functionality restored via QMD fallback
**Date:** 2026-03-31
**Next Review:** When OpenAI quota is restored or embedding configuration changed