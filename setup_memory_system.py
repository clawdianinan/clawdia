#!/usr/bin/env python3
"""
Lightweight Memory System Setup for OpenClaw
Uses ChromaDB for vector storage with local embeddings
"""

import os
import sys
import json
import hashlib
from pathlib import Path
import chromadb
from chromadb.config import Settings
import sentence_transformers

class OpenClawMemorySystem:
    def __init__(self, workspace_path="~/.openclaw/workspace"):
        self.workspace = Path(workspace_path).expanduser()
        self.memory_dir = self.workspace / "memory"
        self.memory_file = self.workspace / "MEMORY.md"
        
        # ChromaDB setup
        self.chroma_dir = self.workspace / ".chroma"
        self.chroma_dir.mkdir(exist_ok=True)
        
        # Initialize ChromaDB
        self.client = chromadb.PersistentClient(
            path=str(self.chroma_dir),
            settings=Settings(anonymized_telemetry=False)
        )
        
        # Create/load collection
        self.collection = self.client.get_or_create_collection(
            name="openclaw_memory",
            metadata={"description": "OpenClaw memory vector store"}
        )
        
        # Load embedding model (lightweight)
        print("Loading embedding model...")
        self.embedding_model = sentence_transformers.SentenceTransformer(
            'all-MiniLM-L6-v2',  # Small, fast model (384 dimensions)
            device='cpu'
        )
        
        print(f"Memory system initialized:")
        print(f"  Workspace: {self.workspace}")
        print(f"  Memory files: {len(list(self.memory_dir.glob('*.md')))}")
        print(f"  ChromaDB: {self.chroma_dir}")
        print(f"  Collection size: {self.collection.count()} vectors")
    
    def get_file_hash(self, filepath):
        """Generate hash for file content"""
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        return hashlib.md5(content.encode()).hexdigest()
    
    def chunk_text(self, text, chunk_size=500, overlap=50):
        """Split text into overlapping chunks"""
        words = text.split()
        chunks = []
        
        for i in range(0, len(words), chunk_size - overlap):
            chunk = ' '.join(words[i:i + chunk_size])
            chunks.append(chunk)
            
            if i + chunk_size >= len(words):
                break
        
        return chunks
    
    def index_memory_file(self, filepath, source_name):
        """Index a memory file into ChromaDB"""
        print(f"Indexing: {source_name}")
        
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Skip if empty
        if not content.strip():
            print(f"  Skipping empty file")
            return 0
        
        # Generate file hash for deduplication
        file_hash = self.get_file_hash(filepath)
        
        # Check if already indexed
        existing = self.collection.get(
            where={"source": source_name, "file_hash": file_hash},
            include=["metadatas"]
        )
        
        if existing['ids']:
            print(f"  Already indexed ({len(existing['ids'])} chunks)")
            return 0
        
        # Split into chunks
        chunks = self.chunk_text(content)
        print(f"  Split into {len(chunks)} chunks")
        
        if not chunks:
            return 0
        
        # Generate embeddings
        embeddings = self.embedding_model.encode(chunks).tolist()
        
        # Prepare data for ChromaDB
        ids = []
        metadatas = []
        
        for i, (chunk, embedding) in enumerate(zip(chunks, embeddings)):
            chunk_id = f"{source_name}_{file_hash}_{i}"
            ids.append(chunk_id)
            
            metadata = {
                "source": source_name,
                "file_hash": file_hash,
                "chunk_index": i,
                "total_chunks": len(chunks),
                "filepath": str(filepath),
                "timestamp": os.path.getmtime(filepath)
            }
            metadatas.append(metadata)
        
        # Add to collection
        self.collection.add(
            embeddings=embeddings,
            documents=chunks,
            metadatas=metadatas,
            ids=ids
        )
        
        print(f"  Added {len(chunks)} chunks to vector store")
        return len(chunks)
    
    def index_all_memory(self):
        """Index all memory files"""
        print("\n=== Indexing Memory Files ===")
        
        total_chunks = 0
        
        # Index MEMORY.md
        if self.memory_file.exists():
            total_chunks += self.index_memory_file(
                self.memory_file, "MEMORY.md"
            )
        
        # Index daily memory files
        if self.memory_dir.exists():
            memory_files = sorted(self.memory_dir.glob("*.md"))
            for mem_file in memory_files:
                source_name = f"memory/{mem_file.name}"
                total_chunks += self.index_memory_file(
                    mem_file, source_name
                )
        
        print(f"\nTotal chunks indexed: {total_chunks}")
        return total_chunks
    
    def search_memory(self, query, n_results=5):
        """Search memory with semantic search"""
        print(f"\nSearching for: '{query}'")
        
        # Generate query embedding
        query_embedding = self.embedding_model.encode([query]).tolist()[0]
        
        # Search ChromaDB
        results = self.collection.query(
            query_embeddings=[query_embedding],
            n_results=n_results,
            include=["documents", "metadatas", "distances"]
        )
        
        if not results['ids'][0]:
            print("No results found")
            return []
        
        # Format results
        formatted_results = []
        for i, (doc, metadata, distance) in enumerate(zip(
            results['documents'][0],
            results['metadatas'][0],
            results['distances'][0]
        )):
            result = {
                "rank": i + 1,
                "score": 1 - distance,  # Convert distance to similarity score
                "text": doc,
                "source": metadata["source"],
                "filepath": metadata["filepath"],
                "chunk": f"{metadata['chunk_index'] + 1}/{metadata['total_chunks']}"
            }
            formatted_results.append(result)
        
        return formatted_results
    
    def print_search_results(self, results):
        """Print formatted search results"""
        if not results:
            print("No results found")
            return
        
        print(f"\nFound {len(results)} results:")
        for result in results:
            print(f"\n[{result['rank']}] Score: {result['score']:.3f}")
            print(f"Source: {result['source']} (chunk {result['chunk']})")
            print(f"Text: {result['text'][:200]}...")
    
    def get_stats(self):
        """Get system statistics"""
        stats = {
            "collection_size": self.collection.count(),
            "memory_files": len(list(self.memory_dir.glob("*.md"))),
            "memory_file_exists": self.memory_file.exists(),
            "chroma_path": str(self.chroma_dir),
            "embedding_model": "all-MiniLM-L6-v2 (384d)"
        }
        return stats
    
    def export_config(self):
        """Export configuration for OpenClaw integration"""
        config = {
            "memory_system": {
                "type": "chromadb",
                "path": str(self.chroma_dir),
                "collection": "openclaw_memory",
                "embedding_model": "all-MiniLM-L6-v2",
                "dimensions": 384
            },
            "integration": {
                "search_endpoint": "python3 -m openclaw_memory.search",
                "index_endpoint": "python3 -m openclaw_memory.index"
            }
        }
        
        config_path = self.workspace / "memory_config.json"
        with open(config_path, 'w') as f:
            json.dump(config, f, indent=2)
        
        print(f"Configuration exported to: {config_path}")
        return config_path

def main():
    """Main function"""
    print("=== OpenClaw Memory System Setup ===\n")
    
    # Initialize system
    memory_system = OpenClawMemorySystem()
    
    # Get stats
    stats = memory_system.get_stats()
    print("\nCurrent Stats:")
    for key, value in stats.items():
        print(f"  {key}: {value}")
    
    # Ask user what to do
    print("\nOptions:")
    print("  1. Index all memory files")
    print("  2. Search memory")
    print("  3. Export configuration")
    print("  4. Run all setup steps")
    print("  0. Exit")
    
    choice = input("\nSelect option (0-4): ").strip()
    
    if choice == "1":
        memory_system.index_all_memory()
    
    elif choice == "2":
        query = input("Enter search query: ").strip()
        if query:
            results = memory_system.search_memory(query)
            memory_system.print_search_results(results)
    
    elif choice == "3":
        config_path = memory_system.export_config()
        print(f"\nConfiguration saved. To use in OpenClaw:")
        print(f"1. Add memory_config.json to your workspace")
        print(f"2. Create a skill that uses this memory system")
    
    elif choice == "4":
        print("\nRunning full setup...")
        memory_system.index_all_memory()
        config_path = memory_system.export_config()
        
        # Test search
        test_query = "local models"
        print(f"\nTesting search with: '{test_query}'")
        results = memory_system.search_memory(test_query)
        memory_system.print_search_results(results)
        
        print("\n✅ Setup complete!")
        print(f"Memory system ready at: {memory_system.chroma_dir}")
    
    else:
        print("Exiting...")

if __name__ == "__main__":
    # Install required packages first
    print("Checking dependencies...")
    
    try:
        import chromadb
        import sentence_transformers
    except ImportError:
        print("Installing required packages...")
        os.system("pip3 install chromadb sentence-transformers")
        
        # Try imports again
        import chromadb
        import sentence_transformers
    
    main()