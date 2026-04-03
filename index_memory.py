#!/usr/bin/env python3
"""
Simple memory indexer for OpenClaw
Run this to create a local memory index
"""

import os
import json
import re
from pathlib import Path
from collections import defaultdict
import math

class QuickMemoryIndex:
    def __init__(self, workspace_path="~/.openclaw/workspace"):
        self.workspace = Path(workspace_path).expanduser()
        self.memory_dir = self.workspace / "memory"
        self.memory_file = self.workspace / "MEMORY.md"
        self.index_file = self.workspace / ".memory_index.json"
        
        self.documents = {}
        self.term_freq = defaultdict(dict)
        self.doc_freq = defaultdict(int)
        self.total_docs = 0
        
    def load_index(self):
        """Load existing index"""
        if self.index_file.exists():
            try:
                with open(self.index_file, 'r') as f:
                    data = json.load(f)
                    self.documents = data.get('documents', {})
                    self.term_freq = defaultdict(dict, data.get('term_freq', {}))
                    self.doc_freq = defaultdict(int, data.get('doc_freq', {}))
                    self.total_docs = data.get('total_docs', 0)
                print(f"✓ Loaded index with {self.total_docs} documents")
                return True
            except Exception as e:
                print(f"Error loading index: {e}")
                return False
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
        print(f"✓ Saved index with {self.total_docs} documents")
    
    def tokenize(self, text):
        """Simple tokenization"""
        words = re.findall(r'\b\w+\b', text.lower())
        return words
    
    def add_document(self, filepath, doc_id):
        """Add a document to the index"""
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
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
        
        indexed_count = 0
        
        # Index MEMORY.md
        if self.memory_file.exists():
            doc_id = f"memory_md_{os.path.getmtime(self.memory_file)}"
            if self.add_document(str(self.memory_file), doc_id):
                print(f"  ✓ MEMORY.md")
                indexed_count += 1
        
        # Index daily memory files
        if self.memory_dir.exists():
            for mem_file in sorted(self.memory_dir.glob("*.md")):
                doc_id = f"memory_{mem_file.name}_{os.path.getmtime(mem_file)}"
                if self.add_document(str(mem_file), doc_id):
                    print(f"  ✓ {mem_file.name}")
                    indexed_count += 1
        
        print(f"Total documents indexed: {indexed_count}")
        if indexed_count > 0:
            self.save_index()
        return indexed_count

def main():
    """Main function - just index files"""
    print("=== OpenClaw Memory Indexer ===\n")
    
    # Initialize indexer
    indexer = QuickMemoryIndex()
    
    # Try to load existing index
    indexer.load_index()
    
    # Index all files
    count = indexer.index_all()
    
    if count > 0:
        print(f"\n✓ Successfully indexed {count} memory files")
        print(f"Index saved to: {indexer.index_file}")
    else:
        print("No memory files found to index")

if __name__ == "__main__":
    main()