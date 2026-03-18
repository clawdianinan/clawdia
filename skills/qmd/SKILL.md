# QMD Skill - Local Document Search & Indexing

## Overview
QMD (Queryable Memory Database) is a local search and indexing skill for OpenClaw that indexes personal document collections (.md files) for fast retrieval using:
1. **BM25 keyword search** - Traditional text matching
2. **Vector semantic search** - AI-powered similarity (future)
3. **Hybrid LLM-reranked queries** - Combined intelligence (future)

## Purpose
Enables OpenClaw to interact with local files, build searchable knowledge bases, and retrieve content as part of its memory system.

## Installation
```bash
# Install Python dependencies
pip install whoosh python-frontmatter
```

## Commands

### Index Management
```bash
# Create or update index
qmd index [--path /path/to/docs]

# List indexed documents
qmd list

# Clear index
qmd clear
```

### Search
```bash
# BM25 keyword search
qmd search "query terms"

# Search with limit
qmd search "query" --limit 10

# Search specific fields
qmd search "query" --field content --field title
```

### Integration
```bash
# Test integration with OpenClaw memory
qmd test-memory

# Index OpenClaw memory files
qmd index-memory
```

## Configuration
Default configuration file: `~/.openclaw/workspace/skills/qmd/config.json`

```json
{
  "index_path": "~/.openclaw/workspace/skills/qmd/index",
  "documents_path": "~/.openclaw/workspace",
  "extensions": [".md", ".txt"],
  "exclude_patterns": ["node_modules", ".git", ".venv"],
  "bm25_weight": 1.0,
  "vector_weight": 0.0,
  "max_results": 20
}
```

## Integration with OpenClaw Memory

### Automatic Indexing
QMD can automatically index:
- `MEMORY.md` (long-term memory)
- `memory/*.md` (daily logs)
- Workspace `.md` files

### Search Integration
```python
# In OpenClaw skills or agents
from openclaw_integration import QMDMemorySearch

# Initialize
qmd = QMDMemorySearch()

# Search memory
results = qmd.search_memory("project decisions from last week", limit=5)

# Get context for a task
context = qmd.get_relevant_context("Need to review financial decisions", limit=3)
```

### CLI Integration
```bash
# Search memory from command line
python openclaw_integration.py search "IHS Towers" --limit 5

# Get context for a task
python openclaw_integration.py context "financial report preparation"

# Index workspace
python openclaw_integration.py index

# Test integration
python openclaw_integration.py test
```

### OpenClaw Agent Integration
Add to agent scripts:
```bash
#!/bin/bash
# Get context before executing task
CONTEXT=$(python /path/to/qmd/openclaw_integration.py context "$1")
echo "Relevant context:"
echo "$CONTEXT"
```

## Architecture

### Components
1. **Indexer** - Scans and indexes documents
2. **BM25 Engine** - Whoosh-based keyword search
3. **Vector Engine** - Qdrant-based semantic search (future)
4. **Reranker** - LLM-based result optimization (future)
5. **CLI** - Command-line interface

### Data Flow
```
Documents → Indexer → BM25 Index + Vector DB → Query → Hybrid Search → Results
```

## Development Status

### ✅ Phase 1: BM25 Only (Current)
- Basic document indexing
- Keyword search with Whoosh
- CLI interface
- OpenClaw integration

### 🔄 Phase 2: Vector Search (Planned)
- Qdrant installation
- Embedding generation
- Semantic search
- Hybrid BM25+vector scoring

### 📋 Phase 3: LLM Reranking (Future)
- LLM-based result reranking
- Query understanding
- Context-aware results

## Usage Examples

### 1. Index Workspace
```bash
qmd index --path ~/.openclaw/workspace
```

### 2. Search for Decisions
```bash
qmd search "financial decision architecture"
```

### 3. Search Memory Files
```bash
qmd search "IHS Towers email priority" --path ~/.openclaw/workspace/memory
```

### 4. Integration Test
```bash
qmd test-memory
```

## File Structure
```
qmd/
├── SKILL.md (this file)
├── qmd.py (main CLI)
├── indexer.py (document indexing)
├── bm25_search.py (BM25 engine)
├── vector_search.py (future - vector search)
├── reranker.py (future - LLM reranking)
├── config.json (configuration)
└── requirements.txt (dependencies)
```

## Dependencies
- `whoosh>=2.7.4` - BM25 search engine
- `python-frontmatter>=1.0.0` - Markdown frontmatter parsing
- `qdrant-client>=1.9.0` (future) - Vector database
- `sentence-transformers>=2.2.2` (future) - Local embeddings

## Performance
- **Indexing:** ~1000 documents/minute
- **Search:** <100ms for typical queries
- **Memory:** ~50MB for 10k documents
- **Storage:** ~100MB for 10k documents

## Limitations
1. Only indexes `.md` and `.txt` files initially
2. No real-time updates (requires re-indexing)
3. Vector search requires Qdrant installation
4. LLM reranking requires API key or local model

## Future Enhancements
1. Real-time indexing with file watcher
2. PDF/DOCX support
3. Image OCR and indexing
4. Cross-document references
5. Automatic categorization
6. Timeline visualization

## Troubleshooting

### Common Issues
1. **Index corruption** - Run `qmd clear` then re-index
2. **Missing dependencies** - Install with `pip install -r requirements.txt`
3. **Permission errors** - Check write access to index directory
4. **Large files** - Files >10MB are skipped by default

### Debug Mode
```bash
qmd search "query" --debug
qmd index --verbose
```

## Support
- Check `qmd --help` for command reference
- View logs in `~/.openclaw/workspace/skills/qmd/qmd.log`
- Report issues to OpenClaw maintainers

## Version History
- **v0.1.0** (2026-02-27): Initial BM25-only release
- **v0.2.0** (Planned): Add vector search with Qdrant
- **v0.3.0** (Planned): Add LLM reranking
- **v1.0.0** (Planned): Production-ready hybrid search