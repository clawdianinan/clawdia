#!/bin/bash
# Simple Memory System Setup for OpenClaw
# Uses basic text search with TF-IDF instead of vector DB

set -e

echo "=== OpenClaw Simple Memory System Setup ==="
echo ""

WORKSPACE="$HOME/.openclaw/workspace"
MEMORY_DIR="$WORKSPACE/memory"
MEMORY_FILE="$WORKSPACE/MEMORY.md"
INDEX_DIR="$WORKSPACE/.memory_index"

echo "Workspace: $WORKSPACE"
echo "Memory files found: $(find "$MEMORY_DIR" -name "*.md" 2>/dev/null | wc -l)"
echo ""

# Create index directory
mkdir -p "$INDEX_DIR"

# Create Python script for indexing
cat > "$INDEX_DIR/index_memory.py" << 'EOF'
#!/usr/bin/env python3
"""
Simple memory indexer using TF-IDF
"""

import os
import json
import re
from pathlib import Path
from collections import defaultdict
import math

class SimpleMemoryIndex:
    def __init__(self, workspace_path):
        self.workspace = Path(workspace_path)
        self.memory_dir = self.workspace / "memory"
        self.memory_file = self.workspace / "MEMORY.md"
        self.index_dir = self.workspace / ".memory_index"
        
        self.index_file = self.index_dir / "memory_index.json"
        self.documents = {}
        self.term_freq = defaultdict(dict)
        self.doc_freq = defaultdict(int)
        self.total_docs = 0
        
    def load_index(self):
        """Load existing index"""
        if self.index_file.exists():
            with open(self.index_file, 'r') as f:
                data = json.load(f)
                self.documents = data.get('documents', {})
                self.term_freq = defaultdict(dict, data.get('term_freq', {}))
                self.doc_freq = defaultdict(int, data.get('doc_freq', {}))
                self.total_docs = data.get('total_docs', 0)
            print(f"Loaded index with {self.total_docs} documents")
            return True
        return False
    
    def save_index(self):
        """Save index to file"""
        data = {
            'documents': self.documents,
            'term_freq': dict(self.term_freq),
            'doc_freq': dict(self.doc_freq),
            'total_docs': self.total_docs
        }
        with open(self.index_file, 'w') as f:
            json.dump(data, f, indent=2)
        print(f"Saved index with {self.total_docs} documents")
    
    def tokenize(self, text):
        """Simple tokenization"""
        # Convert to lowercase and split
        words = re.findall(r'\b\w+\b', text.lower())
        return words
    
    def index_file(self, filepath, doc_id):
        """Index a single file"""
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Skip if empty
            if not content.strip():
                return False
            
            # Store document
            self.documents[doc_id] = {
                'path': str(filepath),
                'content': content[:500],  # Store snippet
                'length': len(content)
            }
            
            # Tokenize and count terms
            tokens = self.tokenize(content)
            token_counts = defaultdict(int)
            
            for token in tokens:
                token_counts[token] += 1
            
            # Update term frequencies
            for token, count in token_counts.items():
                self.term_freq[token][doc_id] = count
                if doc_id not in self.term_freq[token]:
                    self.doc_freq[token] += 1
            
            self.total_docs += 1
            return True
            
        except Exception as e:
            print(f"Error indexing {filepath}: {e}")
            return False
    
    def index_all(self):
        """Index all memory files"""
        print("Indexing memory files...")
        
        # Index MEMORY.md
        if self.memory_file.exists():
            doc_id = f"memory_md_{os.path.getmtime(self.memory_file)}"
            if self.index_file(self.memory_file, doc_id):
                print(f"  ✓ MEMORY.md")
        
        # Index daily memory files
        if self.memory_dir.exists():
            for mem_file in sorted(self.memory_dir.glob("*.md")):
                doc_id = f"memory_{mem_file.name}_{os.path.getmtime(mem_file)}"
                if self.index_file(mem_file, doc_id):
                    print(f"  ✓ {mem_file.name}")
        
        print(f"Total documents indexed: {self.total_docs}")
        self.save_index()
    
    def tf_idf(self, term, doc_id):
        """Calculate TF-IDF score"""
        if doc_id not in self.term_freq.get(term, {}):
            return 0
        
        # Term frequency
        tf = self.term_freq[term][doc_id]
        
        # Inverse document frequency
        idf = math.log((self.total_docs + 1) / (self.doc_freq.get(term, 0) + 1)) + 1
        
        return tf * idf
    
    def search(self, query, limit=5):
        """Search memory with TF-IDF"""
        query_tokens = self.tokenize(query)
        
        if not query_tokens:
            return []
        
        scores = defaultdict(float)
        
        # Calculate scores for each document
        for doc_id in self.documents:
            score = 0
            for token in query_tokens:
                score += self.tf_idf(token, doc_id)
            if score > 0:
                scores[doc_id] = score
        
        # Sort by score
        sorted_docs = sorted(scores.items(), key=lambda x: x[1], reverse=True)
        
        # Format results
        results = []
        for doc_id, score in sorted_docs[:limit]:
            doc = self.documents[doc_id]
            results.append({
                'score': score,
                'path': doc['path'],
                'snippet': doc['content'][:200] + '...',
                'doc_id': doc_id
            })
        
        return results
    
    def print_results(self, results):
        """Print search results"""
        if not results:
            print("No results found")
            return
        
        print(f"\nFound {len(results)} results:")
        for i, result in enumerate(results, 1):
            print(f"\n[{i}] Score: {result['score']:.3f}")
            print(f"File: {result['path']}")
            print(f"Snippet: {result['snippet']}")

def main():
    import sys
    
    workspace = os.path.expanduser("~/.openclaw/workspace")
    indexer = SimpleMemoryIndex(workspace)
    
    # Try to load existing index
    indexer.load_index()
    
    if len(sys.argv) > 1:
        command = sys.argv[1]
        
        if command == "index":
            indexer.index_all()
        
        elif command == "search" and len(sys.argv) > 2:
            query = " ".join(sys.argv[2:])
            results = indexer.search(query)
            indexer.print_results(results)
        
        elif command == "stats":
            print(f"Documents: {indexer.total_docs}")
            print(f"Unique terms: {len(indexer.term_freq)}")
            print(f"Index file: {indexer.index_file}")
        
        else:
            print("Commands: index, search <query>, stats")
    else:
        # Interactive mode
        print("Simple Memory Indexer")
        print("Commands: index, search <query>, stats, quit")
        
        while True:
            try:
                cmd = input("\n> ").strip()
                
                if cmd == "index":
                    indexer.index_all()
                
                elif cmd.startswith("search "):
                    query = cmd[7:]
                    results = indexer.search(query)
                    indexer.print_results(results)
                
                elif cmd == "stats":
                    print(f"Documents: {indexer.total_docs}")
                    print(f"Unique terms: {len(indexer.term_freq)}")
                
                elif cmd in ["quit", "exit", "q"]:
                    break
                
                else:
                    print("Unknown command")
            
            except KeyboardInterrupt:
                print("\nExiting...")
                break
            except Exception as e:
                print(f"Error: {e}")

if __name__ == "__main__":
    main()
EOF

# Make Python script executable
chmod +x "$INDEX_DIR/index_memory.py"

# Create wrapper script
cat > "$WORKSPACE/memory_search" << 'EOF'
#!/bin/bash
# Memory search wrapper

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SCRIPT="$SCRIPT_DIR/.memory_index/index_memory.py"

if [ ! -f "$PYTHON_SCRIPT" ]; then
    echo "Error: Memory indexer not found"
    echo "Run: ./simple_memory_setup.sh init"
    exit 1
fi

python3 "$PYTHON_SCRIPT" "$@"
EOF

chmod +x "$WORKSPACE/memory_search"

# Create initialization script
cat > "$WORKSPACE/init_memory_system.sh" << 'EOF'
#!/bin/bash
# Initialize memory system

echo "Initializing OpenClaw Memory System..."
echo ""

# Create index
cd "$HOME/.openclaw/workspace"
python3 .memory_index/index_memory.py index

echo ""
echo "Memory system initialized!"
echo ""
echo "Usage:"
echo "  ./memory_search index          # Re-index all memory"
echo "  ./memory_search search <query> # Search memory"
echo "  ./memory_search stats          # Show statistics"
echo ""
EOF

chmod +x "$WORKSPACE/init_memory_system.sh"

echo "Setup complete!"
echo ""
echo "Files created:"
echo "  - $INDEX_DIR/index_memory.py    (Indexer script)"
echo "  - $WORKSPACE/memory_search      (Search wrapper)"
echo "  - $WORKSPACE/init_memory_system.sh (Initialization script)"
echo ""
echo "To initialize memory system:"
echo "  cd $WORKSPACE && ./init_memory_system.sh"
echo ""
echo "To search memory:"
echo "  ./memory_search search 'local models'"
echo ""

# Check if we should initialize now
read -p "Initialize memory system now? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cd "$WORKSPACE"
    ./init_memory_system.sh
fi