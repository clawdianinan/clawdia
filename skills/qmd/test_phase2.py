#!/usr/bin/env python3
"""
Test Phase 2: Vector Search Integration
"""

import os
import sys
import json
import logging
from pathlib import Path

# Add current directory to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from qmd import QMD
from vector_search_simple import SimpleVectorSearch as VectorSearch

def test_vector_search_initialization():
    """Test if vector search initializes correctly"""
    print("=== Testing Vector Search Initialization ===")
    
    try:
        # Load config
        config_path = os.path.join(os.path.dirname(__file__), "config.json")
        with open(config_path, 'r') as f:
            config = json.load(f)
        
        # Initialize vector search
        vector_search = VectorSearch(config)
        
        # Test embedding generation
        test_text = "This is a test document about artificial intelligence."
        embedding = vector_search.generate_embedding(test_text)
        
        if embedding:
            print(f"✓ Vector search initialized successfully")
            print(f"✓ Embedding generated: {len(embedding)} dimensions")
            return True
        else:
            print("✗ Failed to generate embedding")
            return False
            
    except Exception as e:
        print(f"✗ Vector search initialization failed: {e}")
        return False

def test_hybrid_search():
    """Test hybrid search functionality"""
    print("\n=== Testing Hybrid Search ===")
    
    try:
        # Initialize QMD with hybrid search
        qmd = QMD()
        
        # Test search with different modes
        test_query = "artificial intelligence"
        
        print(f"Testing query: '{test_query}'")
        
        # BM25 search
        bm25_results = qmd.search(test_query, mode="bm25", limit=3)
        print(f"  BM25 results: {len(bm25_results)}")
        
        # Vector search
        vector_results = qmd.search(test_query, mode="vector", limit=3)
        print(f"  Vector results: {len(vector_results)}")
        
        # Hybrid search
        hybrid_results = qmd.search(test_query, mode="hybrid", limit=3)
        print(f"  Hybrid results: {len(hybrid_results)}")
        
        if hybrid_results:
            print("✓ Hybrid search working")
            
            # Show first result details
            first_result = hybrid_results[0]
            print(f"  Top result: {first_result.get('title', 'Untitled')}")
            print(f"    Score: {first_result.get('score', 0):.3f}")
            if 'hybrid_score' in first_result:
                print(f"    Hybrid score: {first_result.get('hybrid_score', 0):.3f}")
                print(f"    BM25 score: {first_result.get('bm25_score', 0):.3f}")
                print(f"    Vector score: {first_result.get('vector_score', 0):.3f}")
            
            return True
        else:
            print("✗ No hybrid results found")
            return False
            
    except Exception as e:
        print(f"✗ Hybrid search test failed: {e}")
        return False

def test_semantic_search():
    """Test semantic understanding with vector search"""
    print("\n=== Testing Semantic Search ===")
    
    try:
        qmd = QMD()
        
        # Test queries that should find similar concepts
        test_cases = [
            ("machine learning", "artificial intelligence"),
            ("financial report", "quarterly earnings"),
            ("memory system", "recall mechanism"),
            ("project decision", "strategic choice")
        ]
        
        all_passed = True
        
        for query, expected_concept in test_cases:
            print(f"\nQuery: '{query}' (should relate to '{expected_concept}')")
            
            results = qmd.search(query, mode="vector", limit=2)
            
            if results:
                print(f"  Found {len(results)} results")
                for i, result in enumerate(results, 1):
                    print(f"  {i}. {result.get('title', 'Untitled')} "
                          f"(score: {result.get('score', 0):.3f})")
            else:
                print(f"  No results found")
                all_passed = False
        
        return all_passed
        
    except Exception as e:
        print(f"✗ Semantic search test failed: {e}")
        return False

def test_indexing_with_vectors():
    """Test that indexing works with vector storage"""
    print("\n=== Testing Vector-Enabled Indexing ===")
    
    try:
        # Create a test document
        test_dir = os.path.join(os.path.dirname(__file__), "test_docs_phase2")
        os.makedirs(test_dir, exist_ok=True)
        
        test_file = os.path.join(test_dir, "test_semantic.md")
        test_content = """# Semantic Test Document

This document tests semantic search capabilities. It discusses advanced topics in artificial intelligence, machine learning, and neural networks.

## Key Concepts

1. **Deep Learning** - Multi-layer neural networks
2. **Natural Language Processing** - Understanding human language
3. **Computer Vision** - Image recognition and analysis
4. **Reinforcement Learning** - Learning through rewards

## Applications

- Autonomous vehicles
- Medical diagnosis
- Financial forecasting
- Content recommendation
"""
        
        with open(test_file, 'w') as f:
            f.write(test_content)
        
        print(f"Created test document: {test_file}")
        
        # Index with QMD
        qmd = QMD()
        success = qmd.index(test_dir)
        
        if success:
            print("✓ Indexing successful")
            
            # Search for semantic concepts
            semantic_queries = [
                "neural networks",
                "language understanding", 
                "image analysis",
                "learning through rewards"
            ]
            
            print("\nTesting semantic queries:")
            for query in semantic_queries:
                results = qmd.search(query, mode="vector", limit=1)
                if results:
                    print(f"  '{query}': Found '{results[0].get('title', 'Untitled')}'")
                else:
                    print(f"  '{query}': No results")
            
            return True
        else:
            print("✗ Indexing failed")
            return False
            
    except Exception as e:
        print(f"✗ Vector indexing test failed: {e}")
        return False

def test_chromadb_stats():
    """Test ChromaDB statistics and management"""
    print("\n=== Testing ChromaDB Management ===")
    
    try:
        from vector_search_simple import SimpleVectorSearch as VectorSearch
        
        # Load config
        config_path = os.path.join(os.path.dirname(__file__), "config.json")
        with open(config_path, 'r') as f:
            config = json.load(f)
        
        vector_search = VectorSearch(config)
        
        # Get collection stats
        stats = vector_search.get_collection_stats()
        
        print("ChromaDB Collection Statistics:")
        for key, value in stats.items():
            print(f"  {key}: {value}")
        
        # Test vector search
        test_results = vector_search.test_vector_search()
        
        print("\nVector Search Test Results:")
        for query, result in test_results.items():
            if result["success"]:
                print(f"  '{query}': {result['count']} results")
            else:
                print(f"  '{query}': Failed - {result.get('error', 'Unknown error')}")
        
        return True
        
    except Exception as e:
        print(f"✗ ChromaDB test failed: {e}")
        return False

def main():
    """Run all Phase 2 tests"""
    print("=" * 60)
    print("QMD Phase 2: Vector Search Integration Tests")
    print("=" * 60)
    
    tests = [
        ("Vector Search Initialization", test_vector_search_initialization),
        ("Hybrid Search", test_hybrid_search),
        ("Semantic Search", test_semantic_search),
        ("Vector-Enabled Indexing", test_indexing_with_vectors),
        ("ChromaDB Management", test_chromadb_stats)
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
    print("Phase 2 Test Summary")
    print(f"{'='*60}")
    
    passed = sum(1 for _, success in results if success)
    total = len(results)
    
    for test_name, success in results:
        status = "✓ PASS" if success else "✗ FAIL"
        print(f"{status} - {test_name}")
    
    print(f"\nTotal: {passed}/{total} tests passed")
    
    if passed == total:
        print("\n🎉 Phase 2 tests passed! Vector search is ready.")
        print("\nNext steps:")
        print("1. Re-index workspace: python qmd.py index")
        print("2. Test hybrid search: python qmd.py search 'query' --mode hybrid")
        print("3. Compare modes: python qmd.py search 'AI' --mode bm25 vs --mode vector")
    else:
        print(f"\n⚠️  {total - passed} test(s) failed. Check logs above.")
    
    return passed == total

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)