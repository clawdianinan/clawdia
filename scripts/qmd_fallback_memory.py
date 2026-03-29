#!/usr/bin/env python3
"""
QMD Fallback Memory Search for OpenClaw
Provides memory search functionality when OpenAI embeddings quota is exhausted
"""

import json
import os
import sys
import subprocess
from pathlib import Path

QMD_DIR = Path("/Users/clawdia/.openclaw/workspace/skills/qmd")
MEMORY_DIR = Path("/Users/clawdia/.openclaw/workspace/memory")
MEMORY_FILE = Path("/Users/clawdia/.openclaw/workspace/MEMORY.md")

def search_memory(query, max_results=10, min_score=0.0):
    """Search memory using QMD"""
    try:
        # Run QMD search
        cmd = [
            "python3", str(QMD_DIR / "qmd.py"),
            "search", query,
            "--limit", str(max_results)
        ]
        
        result = subprocess.run(
            cmd,
            cwd=str(QMD_DIR),
            capture_output=True,
            text=True,
            timeout=30
        )
        
        if result.returncode != 0:
            return {
                "error": f"QMD search failed: {result.stderr}",
                "results": []
            }
        
        # Parse QMD output
        lines = result.stdout.strip().split('\n')
        results = []
        current_result = {}
        
        for line in lines:
            if line.startswith(('---', '===')):  # Separator
                if current_result:
                    results.append(current_result)
                    current_result = {}
            elif '. ' in line and 'Path:' in line:  # Result line
                parts = line.split('. ', 1)
                if len(parts) == 2:
                    current_result['rank'] = int(parts[0])
            elif 'Path:' in line:
                current_result['path'] = line.split('Path:', 1)[1].strip()
            elif 'Score:' in line:
                score_text = line.split('Score:', 1)[1].strip()
                try:
                    current_result['score'] = float(score_text)
                except:
                    current_result['score'] = 0.0
            elif 'Snippet:' in line:
                current_result['snippet'] = line.split('Snippet:', 1)[1].strip()
        
        if current_result:
            results.append(current_result)
        
        # Filter by min_score
        filtered_results = [r for r in results if r.get('score', 0) >= min_score]
        
        return {
            "results": filtered_results[:max_results],
            "source": "qmd",
            "query": query
        }
        
    except Exception as e:
        return {
            "error": str(e),
            "results": []
        }

def get_memory_content(path, from_line=1, lines=50):
    """Get specific memory file content"""
    try:
        filepath = Path(path)
        if not filepath.exists():
            return {"error": f"File not found: {path}"}
        
        with open(filepath, 'r', encoding='utf-8') as f:
            content_lines = f.readlines()
        
        start = max(0, from_line - 1)
        end = min(len(content_lines), start + lines)
        
        snippet = ''.join(content_lines[start:end])
        
        return {
            "path": path,
            "from": from_line,
            "lines": lines,
            "content": snippet,
            "total_lines": len(content_lines)
        }
        
    except Exception as e:
        return {"error": str(e)}

def main():
    """Main CLI interface"""
    if len(sys.argv) < 2:
        print("Usage: python3 qmd_fallback_memory.py <command> [args]")
        print("Commands: search, get")
        sys.exit(1)
    
    command = sys.argv[1]
    
    if command == "search":
        if len(sys.argv) < 3:
            print("Error: Query required for search")
            sys.exit(1)
        
        query = sys.argv[2]
        max_results = int(sys.argv[3]) if len(sys.argv) > 3 else 10
        min_score = float(sys.argv[4]) if len(sys.argv) > 4 else 0.0
        
        result = search_memory(query, max_results, min_score)
        print(json.dumps(result, indent=2))
        
    elif command == "get":
        if len(sys.argv) < 3:
            print("Error: Path required for get")
            sys.exit(1)
        
        path = sys.argv[2]
        from_line = int(sys.argv[3]) if len(sys.argv) > 3 else 1
        lines = int(sys.argv[4]) if len(sys.argv) > 4 else 50
        
        result = get_memory_content(path, from_line, lines)
        print(json.dumps(result, indent=2))
        
    elif command == "test":
        # Test search
        test_query = "IHS Towers email"
        print(f"Testing search for: {test_query}")
        result = search_memory(test_query, 3)
        print(json.dumps(result, indent=2))
        
        # Test get
        print("\nTesting get from MEMORY.md:")
        result = get_memory_content(str(MEMORY_FILE), 1, 5)
        print(json.dumps(result, indent=2))
        
    else:
        print(f"Unknown command: {command}")
        sys.exit(1)

if __name__ == "__main__":
    main()