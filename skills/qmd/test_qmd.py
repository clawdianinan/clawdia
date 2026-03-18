#!/usr/bin/env python3
"""
Test script for QMD
"""

import os
import sys
import subprocess

def test_installation():
    """Test if dependencies are installed"""
    print("Testing QMD installation...")
    
    # Check Python version
    python_version = sys.version_info
    print(f"Python version: {python_version.major}.{python_version.minor}.{python_version.micro}")
    
    # Try to import dependencies
    try:
        import whoosh
        print(f"✓ Whoosh version: {whoosh.__version__}")
    except ImportError:
        print("✗ Whoosh not installed")
        return False
    
    try:
        import frontmatter
        print(f"✓ python-frontmatter installed")
    except ImportError:
        print("✗ python-frontmatter not installed")
        return False
    
    return True

def test_cli():
    """Test CLI commands"""
    print("\nTesting CLI commands...")
    
    # Make script executable
    qmd_path = os.path.join(os.path.dirname(__file__), "qmd.py")
    os.chmod(qmd_path, 0o755)
    
    # Test help
    print("Testing '--help'...")
    result = subprocess.run([sys.executable, qmd_path, "--help"], 
                          capture_output=True, text=True)
    if result.returncode == 0:
        print("✓ Help command works")
    else:
        print(f"✗ Help command failed: {result.stderr}")
        return False
    
    # Test list command (should work even with empty index)
    print("\nTesting 'list' command...")
    result = subprocess.run([sys.executable, qmd_path, "list"], 
                          capture_output=True, text=True)
    if result.returncode == 0:
        print("✓ List command works")
        if "No documents indexed" in result.stdout:
            print("  (Index is empty - this is expected)")
    else:
        print(f"✗ List command failed: {result.stderr}")
    
    return True

def create_test_documents():
    """Create test documents for indexing"""
    test_dir = os.path.join(os.path.dirname(__file__), "test_docs")
    os.makedirs(test_dir, exist_ok=True)
    
    test_files = {
        "test1.md": """---
title: Test Document One
tags: [test, example]
---

# Test Document One

This is a test document for QMD. It contains some sample text about artificial intelligence and machine learning.

## Section One

AI systems are becoming increasingly sophisticated. They can now understand natural language, recognize images, and make predictions.

## Section Two

Machine learning algorithms require large datasets for training. The quality of the data affects the performance of the model.
""",
        
        "test2.md": """# Financial Report Q1 2026

## Executive Summary

Revenue increased by 15% compared to Q4 2025. Expenses were well controlled, resulting in a net profit margin of 22%.

## Key Decisions

1. Approved new hiring for engineering team
2. Launched new product line
3. Expanded to European markets

## Next Steps

- Complete Q2 planning
- Review marketing strategy
- Update financial projections
""",
        
        "memory_test.md": """# Memory Test Document

This document tests memory-related searches.

## Important Decisions

- Decision to implement QMD for document search
- Decision to use BM25 for initial version
- Decision to add vector search later

## Keywords

memory, search, indexing, documents, QMD
"""
    }
    
    for filename, content in test_files.items():
        filepath = os.path.join(test_dir, filename)
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Created test file: {filepath}")
    
    return test_dir

def test_indexing():
    """Test document indexing"""
    print("\nTesting document indexing...")
    
    # Create test documents
    test_dir = create_test_documents()
    
    # Run index command
    qmd_path = os.path.join(os.path.dirname(__file__), "qmd.py")
    result = subprocess.run([sys.executable, qmd_path, "index", "--path", test_dir, "--verbose"], 
                          capture_output=True, text=True)
    
    if result.returncode == 0:
        print("✓ Indexing successful")
        print(f"Output: {result.stdout[:500]}...")
    else:
        print(f"✗ Indexing failed: {result.stderr}")
        return False
    
    return True

def test_search():
    """Test search functionality"""
    print("\nTesting search functionality...")
    
    qmd_path = os.path.join(os.path.dirname(__file__), "qmd.py")
    
    test_queries = [
        ("artificial intelligence", "Should find test1.md"),
        ("financial report", "Should find test2.md"),
        ("memory", "Should find memory_test.md"),
        ("decision", "Should find multiple documents")
    ]
    
    all_passed = True
    
    for query, description in test_queries:
        print(f"\nTesting query: '{query}'")
        print(f"  {description}")
        
        result = subprocess.run([sys.executable, qmd_path, "search", query], 
                              capture_output=True, text=True)
        
        if result.returncode == 0:
            if "No results found" in result.stdout:
                print(f"  ✗ No results found (might be expected for empty index)")
                all_passed = False
            else:
                print(f"  ✓ Search successful")
                # Show first result
                lines = result.stdout.split('\n')
                for line in lines[:5]:
                    if line.strip():
                        print(f"    {line}")
        else:
            print(f"  ✗ Search failed: {result.stderr}")
            all_passed = False
    
    return all_passed

def test_memory_integration():
    """Test OpenClaw memory integration"""
    print("\nTesting OpenClaw memory integration...")
    
    qmd_path = os.path.join(os.path.dirname(__file__), "qmd.py")
    
    # Test memory indexing
    print("Testing memory indexing...")
    result = subprocess.run([sys.executable, qmd_path, "index-memory"], 
                          capture_output=True, text=True)
    
    if result.returncode == 0:
        print("✓ Memory indexing command works")
    else:
        print(f"✗ Memory indexing failed: {result.stderr}")
    
    # Test memory test command
    print("\nTesting memory test command...")
    result = subprocess.run([sys.executable, qmd_path, "test-memory"], 
                          capture_output=True, text=True)
    
    if result.returncode == 0:
        print("✓ Memory test command works")
    else:
        print(f"✗ Memory test failed: {result.stderr}")
    
    return True

def main():
    """Run all tests"""
    print("=" * 60)
    print("QMD Test Suite")
    print("=" * 60)
    
    tests = [
        ("Installation", test_installation),
        ("CLI", test_cli),
        ("Indexing", test_indexing),
        ("Search", test_search),
        ("Memory Integration", test_memory_integration)
    ]
    
    results = []
    
    for test_name, test_func in tests:
        print(f"\n{'='*40}")
        print(f"Test: {test_name}")
        print(f"{'='*40}")
        
        try:
            success = test_func()
            results.append((test_name, success))
            status = "PASS" if success else "FAIL"
            print(f"\n{test_name}: {status}")
        except Exception as e:
            print(f"\n{test_name}: ERROR - {e}")
            results.append((test_name, False))
    
    # Summary
    print(f"\n{'='*60}")
    print("Test Summary")
    print(f"{'='*60}")
    
    passed = sum(1 for _, success in results if success)
    total = len(results)
    
    for test_name, success in results:
        status = "✓ PASS" if success else "✗ FAIL"
        print(f"{status} - {test_name}")
    
    print(f"\nTotal: {passed}/{total} tests passed")
    
    if passed == total:
        print("\n🎉 All tests passed! QMD is ready to use.")
        print("\nNext steps:")
        print("1. Install dependencies: pip install -r requirements.txt")
        print("2. Index your workspace: python qmd.py index")
        print("3. Search documents: python qmd.py search 'your query'")
    else:
        print(f"\n⚠️  {total - passed} test(s) failed. Check logs above.")
    
    return passed == total

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)