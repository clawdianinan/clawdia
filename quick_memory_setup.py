#!/usr/bin/env python3
"""
Quick Memory System Setup for OpenClaw
Simple text-based search without complex dependencies
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
    """Main function"""
    print("=== OpenClaw Quick Memory System ===\n")
    
    # Initialize indexer
    indexer = QuickMemoryIndex()
    
    # Try to load existing index
    indexer.load_index()
    
    # Interactive menu
    while True:
        print("\nOptions:")
        print("  1. Index all memory files")
        print("  2. Search memory")
        print("  3. Show statistics")
        print("  4. Test with sample queries")
        print("  0. Exit")
        
        try:
            choice = input("\nSelect option (0-4): ").strip()
            
            if choice == "1":
                print("\nIndexing...")
                count = indexer.index_all()
                if count > 0:
                    print(f"\n✓ Successfully indexed {count} files")
                else:
                    print("No new files to index")
            
            elif choice == "2":
                query = input("Enter search query: ").strip()
                if query:
                    results = indexer.search(query)
                    indexer.print_results(results)
                else:
                    print("Please enter a query")
            
            elif choice == "3":
                print(f"\nStatistics:")
                print(f"  Documents: {indexer.total_docs}")
                print(f"  Unique terms: {len(indexer.term_freq)}")
                print(f"  Index file: {indexer.index_file}")
                print(f"  Memory files: {len(list(indexer.memory_dir.glob('*.md')))}")
            
            elif choice == "4":
                print("\nTesting with sample queries...")
                test_queries = [
                    "local models",
                    "OpenClaw",
                    "memory system",
                    "DeepSeek",
                    "vector database"
                ]
                
                for query in test_queries:
                    print(f"\nQuery: '{query}'")
                    results = indexer.search(query, limit=3)
                    if results:
                        for i, result in enumerate(results, 1):
                            print(f"  {i}. {result['path']} (score: {result['score']:.3f})")
                    else:
                        print("  No results")
            
            elif choice == "0":
                print("\nExiting...")
                break
            
            else:
                print("Invalid choice")
        
        except KeyboardInterrupt:
            print("\n\nExiting...")
            break
        except Exception as e:
            print(f"Error: {e}")

if __name__ == "__main__":
    main()