#!/usr/bin/env python3
"""
Local memory search for OpenClaw
Use this when the OpenAI embedding quota is exhausted
"""

import json
import re
import math
from collections import defaultdict
import sys

class LocalMemorySearch:
    def __init__(self, index_path="~/.openclaw/workspace/.memory_index.json"):
        import os
        self.index_path = os.path.expanduser(index_path)
        self.documents = {}
        self.term_freq = defaultdict(dict)
        self.doc_freq = defaultdict(int)
        self.total_docs = 0
        
        self.load_index()
    
    def load_index(self):
        """Load the memory index"""
        try:
            with open(self.index_path, 'r') as f:
                data = json.load(f)
                self.documents = data.get('documents', {})
                self.term_freq = defaultdict(dict, data.get('term_freq', {}))
                self.doc_freq = defaultdict(int, data.get('doc_freq', {}))
                self.total_docs = data.get('total_docs', 0)
            print(f"Loaded index with {self.total_docs} documents", file=sys.stderr)
            return True
        except Exception as e:
            print(f"Error loading index: {e}", file=sys.stderr)
            return False
    
    def tokenize(self, text):
        """Simple tokenization"""
        words = re.findall(r'\b\w+\b', text.lower())
        return words
    
    def tf_idf(self, term, doc_id):
        """Calculate TF-IDF score"""
        if doc_id not in self.term_freq.get(term, {}):
            return 0
        
        # Term frequency
        tf = self.term_freq[term][doc_id]
        
        # Inverse document frequency
        idf = math.log((self.total_docs + 1) / (self.doc_freq.get(term, 0) + 1)) + 1
        
        return tf * idf
    
    def search(self, query, limit=10):
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
            # Extract a better snippet around query terms
            content = doc['content']
            snippet = content[:200] + '...' if len(content) > 200 else content
            
            results.append({
                'score': score,
                'path': doc['path'],
                'snippet': snippet,
                'lines': f"1-{min(50, len(content.splitlines()))}",
                'doc_id': doc_id
            })
        
        return results
    
    def print_results(self, results, query):
        """Print search results in OpenClaw format"""
        if not results:
            print(f"No results found for: {query}")
            return
        
        print(f"Found {len(results)} results for: {query}")
        for i, result in enumerate(results, 1):
            print(f"\n[{i}] Score: {result['score']:.3f}")
            print(f"File: {result['path']}")
            print(f"Snippet: {result['snippet']}")
            print(f"Source: {result['path']}#{result['lines']}")

def main():
    """Main function"""
    if len(sys.argv) < 2:
        print("Usage: python3 local_memory_search.py <query> [limit]")
        print("Example: python3 local_memory_search.py 'IHS Towers' 5")
        sys.exit(1)
    
    query = sys.argv[1]
    limit = int(sys.argv[2]) if len(sys.argv) > 2 else 10
    
    searcher = LocalMemorySearch()
    results = searcher.search(query, limit=limit)
    searcher.print_results(results, query)

if __name__ == "__main__":
    main()