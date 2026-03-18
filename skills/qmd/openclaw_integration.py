#!/usr/bin/env python3
"""
OpenClaw integration for QMD
Provides memory search functionality for OpenClaw agents
"""

import os
import sys
import json
from typing import List, Dict, Any

# Add QMD to path
qmd_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, qmd_dir)

from qmd import QMD

class QMDMemorySearch:
    """QMD integration for OpenClaw memory search"""
    
    def __init__(self, config_path: str = None):
        self.qmd = QMD(config_path)
    
    def search_memory(self, query: str, limit: int = 10) -> List[Dict[str, Any]]:
        """Search memory files using QMD"""
        results = self.qmd.search(query, limit=limit)
        
        # Convert datetime objects to strings for JSON serialization
        for result in results:
            for key, value in result.items():
                if hasattr(value, 'isoformat'):  # Check if it's a datetime
                    result[key] = value.isoformat()
        
        return results
    
    def search_workspace(self, query: str, limit: int = 10) -> List[Dict[str, Any]]:
        """Search entire workspace using QMD"""
        return self.qmd.search(query, limit=limit)
    
    def get_relevant_context(self, task: str, limit: int = 5) -> str:
        """Get relevant context from memory for a task"""
        results = self.search_memory(task, limit=limit)
        
        if not results:
            return "No relevant memory found."
        
        context_parts = []
        for i, result in enumerate(results, 1):
            context_parts.append(f"{i}. {result['title']}")
            context_parts.append(f"   Path: {result['path']}")
            if result.get('snippet'):
                context_parts.append(f"   Snippet: {result['snippet']}")
            context_parts.append("")
        
        return "\n".join(context_parts)
    
    def index_workspace(self) -> bool:
        """Index the entire workspace"""
        return self.qmd.index()

# CLI interface for OpenClaw
def main():
    """CLI for OpenClaw integration"""
    import argparse
    
    parser = argparse.ArgumentParser(description="QMD OpenClaw Integration")
    subparsers = parser.add_subparsers(dest="command", help="Command to execute")
    
    # Search memory command
    search_parser = subparsers.add_parser("search", help="Search memory")
    search_parser.add_argument("query", help="Search query")
    search_parser.add_argument("--limit", "-l", type=int, default=10, help="Maximum results")
    
    # Get context command
    context_parser = subparsers.add_parser("context", help="Get context for task")
    context_parser.add_argument("task", help="Task description")
    context_parser.add_argument("--limit", "-l", type=int, default=5, help="Maximum results")
    
    # Index command
    index_parser = subparsers.add_parser("index", help="Index workspace")
    
    # Test command
    test_parser = subparsers.add_parser("test", help="Test integration")
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
    
    # Initialize QMD
    try:
        qmd_integration = QMDMemorySearch()
    except Exception as e:
        print(f"Failed to initialize QMD: {e}", file=sys.stderr)
        sys.exit(1)
    
    # Execute command
    if args.command == "search":
        results = qmd_integration.search_memory(args.query, args.limit)
        
        if not results:
            print("No results found")
            sys.exit(0)
        
        # Output in JSON for programmatic use
        output = {
            "query": args.query,
            "count": len(results),
            "results": results
        }
        print(json.dumps(output, indent=2))
    
    elif args.command == "context":
        context = qmd_integration.get_relevant_context(args.task, args.limit)
        print(context)
    
    elif args.command == "index":
        print("Indexing workspace...")
        success = qmd_integration.index_workspace()
        if success:
            print("Indexing completed successfully")
            sys.exit(0)
        else:
            print("Indexing failed", file=sys.stderr)
            sys.exit(1)
    
    elif args.command == "test":
        print("Testing QMD OpenClaw integration...")
        
        # Test search
        test_queries = ["memory", "IHS", "decision", "financial"]
        
        for query in test_queries:
            print(f"\nTesting query: '{query}'")
            results = qmd_integration.search_memory(query, limit=2)
            if results:
                print(f"  Found {len(results)} results")
                for result in results:
                    print(f"  - {result['title']} (score: {result['score']:.2f})")
            else:
                print(f"  No results")
        
        print("\n✅ Integration test completed")

if __name__ == "__main__":
    main()