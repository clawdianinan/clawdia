#!/usr/bin/env python3
"""
QMD - Queryable Memory Database
Local document search and indexing for OpenClaw
"""

import os
import sys
import json
import argparse
import logging
from pathlib import Path
from typing import List, Dict, Any, Optional

# Add current directory to path for imports
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from indexer import QMDIndexer
from bm25_search import BM25Search

# Default configuration
DEFAULT_CONFIG = {
    "index_path": str(Path.home() / ".openclaw" / "workspace" / "skills" / "qmd" / "index"),
    "documents_path": str(Path.home() / ".openclaw" / "workspace"),
    "extensions": [".md", ".txt"],
    "exclude_patterns": ["node_modules", ".git", ".venv", "__pycache__"],
    "max_file_size_mb": 10,
    "max_results": 20,
    "bm25_weight": 1.0,
    "vector_weight": 0.0,  # Not implemented yet
    "log_level": "INFO"
}

class QMD:
    """Main QMD application class"""
    
    def __init__(self, config_path: Optional[str] = None):
        self.config = self.load_config(config_path)
        self.setup_logging()
        self.indexer = QMDIndexer(self.config)
        self.searcher = BM25Search(self.config)
        
        # Initialize vector search lazily only when enabled
        # (avoids importing heavy embedding stack during BM25-only runs)
        if self.config.get("vector_weight", 0) > 0:
            try:
                from vector_search_simple import SimpleVectorSearch as VectorSearch
                self.vector_searcher = VectorSearch(self.config)
                logging.info("Vector search initialized")
            except Exception as e:
                logging.warning(f"Failed to initialize vector search: {e}")
                self.vector_searcher = None
        else:
            self.vector_searcher = None
        
    def load_config(self, config_path: Optional[str] = None) -> Dict[str, Any]:
        """Load configuration from file or use defaults"""
        if config_path is None:
            config_path = os.path.join(
                os.path.dirname(os.path.abspath(__file__)),
                "config.json"
            )
        
        config = DEFAULT_CONFIG.copy()
        
        if os.path.exists(config_path):
            try:
                with open(config_path, 'r') as f:
                    file_config = json.load(f)
                config.update(file_config)
                logging.info(f"Loaded configuration from {config_path}")
            except Exception as e:
                logging.warning(f"Failed to load config from {config_path}: {e}")
        
        # Ensure directories exist
        os.makedirs(config["index_path"], exist_ok=True)
        
        return config
    
    def setup_logging(self):
        """Setup logging configuration"""
        log_level = getattr(logging, self.config["log_level"].upper())
        log_file = os.path.join(os.path.dirname(self.config["index_path"]), "qmd.log")
        
        logging.basicConfig(
            level=log_level,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(log_file),
                logging.StreamHandler(sys.stdout)
            ]
        )
    
    def index(self, path: Optional[str] = None, verbose: bool = False) -> bool:
        """Index documents from specified path or default"""
        target_path = path or self.config["documents_path"]
        
        if not os.path.exists(target_path):
            logging.error(f"Path does not exist: {target_path}")
            return False
        
        logging.info(f"Indexing documents from: {target_path}")
        
        try:
            stats = self.indexer.index_directory(target_path, verbose=verbose)
            
            if stats["total"] == 0:
                logging.warning("No documents were indexed")
                return False
            
            logging.info(f"Indexing complete: {stats['indexed']} indexed, "
                        f"{stats['skipped']} skipped, {stats['errors']} errors")
            return True
            
        except Exception as e:
            logging.error(f"Indexing failed: {e}")
            return False
    
    def search(self, query: str, limit: int = None, field: List[str] = None, 
               debug: bool = False, mode: str = "hybrid") -> List[Dict[str, Any]]:
        """Search indexed documents using BM25, vector, or hybrid search"""
        if not query or not query.strip():
            logging.error("Empty query")
            return []
        
        limit = limit or self.config["max_results"]
        
        logging.info(f"Searching for: '{query}' (limit: {limit}, mode: {mode})")
        
        try:
            # BM25 search (always available)
            bm25_results = self.searcher.search(query, limit=limit, fields=field, debug=debug)
            
            # Vector search (if enabled)
            vector_results = []
            if self.vector_searcher and mode in ["vector", "hybrid"]:
                vector_results = self.vector_searcher.search(query, limit=limit)
            
            # Combine results based on mode
            if mode == "bm25":
                results = bm25_results
                logging.info(f"BM25 search found {len(results)} results")
                
            elif mode == "vector":
                results = vector_results
                logging.info(f"Vector search found {len(results)} results")
                
            else:  # hybrid
                bm25_weight = self.config.get("bm25_weight", 0.5)
                vector_weight = self.config.get("vector_weight", 0.5)
                
                results = self.vector_searcher.hybrid_search(
                    bm25_results, vector_results, bm25_weight, vector_weight
                ) if self.vector_searcher else bm25_results
                
                logging.info(f"Hybrid search found {len(results)} results "
                           f"(BM25: {len(bm25_results)}, Vector: {len(vector_results)})")
            
            if not results:
                logging.info("No results found")
                return []
            
            return results[:limit]
            
        except Exception as e:
            logging.error(f"Search failed: {e}")
            return []
    
    def list_documents(self) -> List[Dict[str, Any]]:
        """List all indexed documents"""
        try:
            documents = self.searcher.list_documents()
            logging.info(f"Found {len(documents)} indexed documents")
            return documents
        except Exception as e:
            logging.error(f"Failed to list documents: {e}")
            return []
    
    def clear_index(self) -> bool:
        """Clear the entire index"""
        try:
            self.indexer.clear_index()
            logging.info("Index cleared successfully")
            return True
        except Exception as e:
            logging.error(f"Failed to clear index: {e}")
            return False
    
    def test_memory(self) -> bool:
        """Test integration with OpenClaw memory system"""
        logging.info("Testing OpenClaw memory integration...")
        
        # Test indexing memory files
        memory_path = os.path.join(self.config["documents_path"], "memory")
        if os.path.exists(memory_path):
            logging.info(f"Found memory directory: {memory_path}")
            
            # Count memory files
            memory_files = []
            for ext in self.config["extensions"]:
                memory_files.extend(Path(memory_path).rglob(f"*{ext}"))
            
            logging.info(f"Found {len(memory_files)} memory files")
            
            # Test search on memory
            test_queries = [
                "memory",
                "decision",
                "IHS",
                "IIH"
            ]
            
            for query in test_queries:
                results = self.search(query, limit=3)
                if results:
                    logging.info(f"Query '{query}': Found {len(results)} results")
                else:
                    logging.info(f"Query '{query}': No results")
            
            return True
        else:
            logging.warning("Memory directory not found")
            return False
    
    def index_memory(self) -> bool:
        """Specifically index OpenClaw memory files"""
        memory_path = os.path.join(self.config["documents_path"], "memory")
        
        if not os.path.exists(memory_path):
            logging.error(f"Memory directory not found: {memory_path}")
            return False
        
        logging.info(f"Indexing memory files from: {memory_path}")
        return self.index(memory_path)

def main():
    """Main CLI entry point"""
    parser = argparse.ArgumentParser(description="QMD - Queryable Memory Database")
    subparsers = parser.add_subparsers(dest="command", help="Command to execute")
    
    # Index command
    index_parser = subparsers.add_parser("index", help="Index documents")
    index_parser.add_argument("--path", help="Path to index (default: workspace)")
    index_parser.add_argument("--verbose", "-v", action="store_true", help="Verbose output")
    
    # Search command
    search_parser = subparsers.add_parser("search", help="Search indexed documents")
    search_parser.add_argument("query", help="Search query")
    search_parser.add_argument("--limit", "-l", type=int, help="Maximum results")
    search_parser.add_argument("--field", "-f", action="append", help="Field to search")
    search_parser.add_argument("--debug", "-d", action="store_true", help="Debug mode")
    search_parser.add_argument("--mode", "-m", choices=["bm25", "vector", "hybrid"], 
                              default="hybrid", help="Search mode (default: hybrid)")
    
    # List command
    list_parser = subparsers.add_parser("list", help="List indexed documents")
    
    # Clear command
    clear_parser = subparsers.add_parser("clear", help="Clear index")
    
    # Test command
    test_parser = subparsers.add_parser("test-memory", help="Test memory integration")
    
    # Index memory command
    memory_parser = subparsers.add_parser("index-memory", help="Index memory files")
    
    # Global arguments
    parser.add_argument("--config", "-c", help="Configuration file path")
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
    
    # Initialize QMD
    try:
        qmd = QMD(args.config)
    except Exception as e:
        logging.error(f"Failed to initialize QMD: {e}")
        sys.exit(1)
    
    # Execute command
    if args.command == "index":
        success = qmd.index(args.path, args.verbose)
        sys.exit(0 if success else 1)
    
    elif args.command == "search":
        results = qmd.search(args.query, args.limit, args.field, args.debug, args.mode)
        
        if not results:
            print("No results found")
            sys.exit(1)
        
        # Print results
        for i, result in enumerate(results, 1):
            print(f"\n{i}. {result.get('title', 'Untitled')}")
            print(f"   Path: {result.get('path', 'Unknown')}")
            print(f"   Score: {result.get('score', 0):.3f}")
            
            # Show snippet if available
            snippet = result.get('snippet', '')
            if snippet:
                print(f"   Snippet: {snippet[:200]}...")
            
            print("-" * 80)
        
        sys.exit(0)
    
    elif args.command == "list":
        documents = qmd.list_documents()
        
        if not documents:
            print("No documents indexed")
            sys.exit(1)
        
        for i, doc in enumerate(documents, 1):
            print(f"{i}. {doc.get('title', 'Untitled')} - {doc.get('path', 'Unknown')}")
        
        sys.exit(0)
    
    elif args.command == "clear":
        confirm = input("Are you sure you want to clear the index? (y/N): ")
        if confirm.lower() == 'y':
            success = qmd.clear_index()
            sys.exit(0 if success else 1)
        else:
            print("Cancelled")
            sys.exit(0)
    
    elif args.command == "test-memory":
        success = qmd.test_memory()
        sys.exit(0 if success else 1)
    
    elif args.command == "index-memory":
        success = qmd.index_memory()
        sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()