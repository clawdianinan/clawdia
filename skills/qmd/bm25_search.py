"""
BM25 search engine for QMD
Provides keyword search using Whoosh
"""

import os
import logging
from typing import List, Dict, Any, Optional
from datetime import datetime

from whoosh import index
from whoosh.qparser import MultifieldParser, OrGroup

class BM25Search:
    """BM25 keyword search engine"""
    
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.index_path = config["index_path"]
        self.setup_searcher()
    
    def setup_searcher(self):
        """Open the index for searching"""
        if not index.exists_in(self.index_path):
            raise FileNotFoundError(f"Index not found at {self.index_path}")
        
        self.ix = index.open_dir(self.index_path)
        logging.info(f"Opened index with {self.ix.doc_count()} documents")
    
    def search(self, query: str, limit: int = 20, fields: List[str] = None, debug: bool = False) -> List[Dict[str, Any]]:
        """Search indexed documents"""
        if not query or not query.strip():
            return []
        
        limit = min(limit, self.config.get("max_results", 100))
        
        # Default fields to search
        if not fields:
            fields = ["title", "content", "filename"]
        
        # Create parser
        parser = MultifieldParser(fields, schema=self.ix.schema, group=OrGroup)
        parsed_query = parser.parse(query)
        
        if debug:
            logging.debug(f"Parsed query: {parsed_query}")
            logging.debug(f"Searching fields: {fields}")
        
        results = []
        
        with self.ix.searcher() as searcher:
            # Execute search
            search_results = searcher.search(parsed_query, limit=limit)
            
            if debug:
                logging.debug(f"Found {len(search_results)} results")
            
            # Process results
            for hit in search_results:
                # Get highlighted snippets (simplified version)
                title = hit.get("title", "")
                content = hit.get("content", "")
                
                # Simple snippet extraction - get first 200 chars of content
                snippet = ""
                if content:
                    # Try to find query terms in content
                    content_lower = content.lower()
                    query_terms = query.lower().split()
                    
                    # Find first occurrence of any query term
                    for term in query_terms:
                        if len(term) > 3:  # Skip short terms
                            pos = content_lower.find(term)
                            if pos != -1:
                                start = max(0, pos - 50)
                                end = min(len(content), pos + len(term) + 100)
                                snippet = content[start:end]
                                if len(snippet) > 200:
                                    snippet = snippet[:197] + "..."
                                break
                    
                    # If no query terms found, use beginning of content
                    if not snippet:
                        snippet = content[:200]
                        if len(content) > 200:
                            snippet = snippet[:197] + "..."
                
                # Prepare result
                result = {
                    "path": hit.get("path", ""),
                    "title": hit.get("title", "Untitled"),
                    "score": hit.score,
                    "snippet": snippet,
                    "filename": hit.get("filename", ""),
                    "directory": hit.get("directory", ""),
                    "file_size": hit.get("file_size", 0),
                    "modified": hit.get("modified"),
                    "indexed": hit.get("indexed"),
                    "fields": {field: hit.get(field, "") for field in fields}
                }
                
                results.append(result)
        
        return results
    
    def list_documents(self) -> List[Dict[str, Any]]:
        """List all indexed documents"""
        documents = []
        
        with self.ix.searcher() as searcher:
            # Get all documents
            for fields in searcher.all_stored_fields():
                doc = {
                    "path": fields.get("path", ""),
                    "title": fields.get("title", "Untitled"),
                    "filename": fields.get("filename", ""),
                    "directory": fields.get("directory", ""),
                    "file_size": fields.get("file_size", 0),
                    "modified": fields.get("modified"),
                    "indexed": fields.get("indexed")
                }
                documents.append(doc)
        
        # Sort by modified date (newest first)
        documents.sort(key=lambda x: x.get("modified") or datetime.min, reverse=True)
        
        return documents
    
    def get_document(self, path: str) -> Optional[Dict[str, Any]]:
        """Get a specific document by path"""
        with self.ix.searcher() as searcher:
            results = list(searcher.documents(path=path))
            
            if not results:
                return None
            
            doc = results[0]
            return {
                "path": doc.get("path", ""),
                "title": doc.get("title", "Untitled"),
                "content": doc.get("content", ""),
                "filename": doc.get("filename", ""),
                "directory": doc.get("directory", ""),
                "file_size": doc.get("file_size", 0),
                "modified": doc.get("modified"),
                "indexed": doc.get("indexed"),
                "checksum": doc.get("checksum", "")
            }
    
    def search_similar(self, path: str, limit: int = 10) -> List[Dict[str, Any]]:
        """Find documents similar to a given document"""
        # Get the target document
        target_doc = self.get_document(path)
        if not target_doc:
            return []
        
        # Extract key terms from the document
        content = target_doc.get("content", "")
        title = target_doc.get("title", "")
        
        # Simple approach: use title and first 100 chars as query
        query_terms = []
        
        # Add title words
        if title:
            query_terms.extend(title.split()[:5])
        
        # Add content words (first 200 chars)
        if content:
            first_words = content[:200].split()
            query_terms.extend(first_words[:10])
        
        # Remove duplicates and common words
        common_words = {"the", "a", "an", "and", "or", "but", "in", "on", "at", "to", "for", "of", "with", "by"}
        query_terms = [word.lower() for word in query_terms if word.lower() not in common_words]
        
        # Create query
        query = " ".join(set(query_terms[:10]))  # Use top 10 unique terms
        
        if not query:
            return []
        
        # Search for similar documents (excluding the original)
        results = self.search(query, limit=limit + 1)
        
        # Filter out the original document
        similar_results = [r for r in results if r["path"] != path]
        
        return similar_results[:limit]
    
    def get_index_stats(self) -> Dict[str, Any]:
        """Get search engine statistics"""
        with self.ix.searcher() as searcher:
            return {
                "document_count": searcher.doc_count(),
                "index_path": self.index_path,
                "fields": list(self.ix.schema.names()),
                "is_readonly": searcher.is_closed
            }
    
    def test_search(self, test_queries: List[str] = None) -> Dict[str, Any]:
        """Test search functionality with sample queries"""
        if test_queries is None:
            test_queries = [
                "memory",
                "decision",
                "project",
                "financial",
                "email"
            ]
        
        results = {}
        
        for query in test_queries:
            try:
                search_results = self.search(query, limit=3)
                results[query] = {
                    "success": True,
                    "count": len(search_results),
                    "results": [
                        {
                            "title": r.get("title", ""),
                            "path": r.get("path", ""),
                            "score": r.get("score", 0)
                        }
                        for r in search_results[:2]  # First 2 results
                    ]
                }
            except Exception as e:
                results[query] = {
                    "success": False,
                    "error": str(e),
                    "count": 0
                }
        
        return results