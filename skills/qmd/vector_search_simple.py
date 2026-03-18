"""
Simple vector search engine for QMD using sentence-transformers only
No ChromaDB dependency - uses local storage
"""

import os
import json
import logging
import pickle
import hashlib
from typing import List, Dict, Any, Optional, Tuple
from datetime import datetime
from pathlib import Path

import numpy as np
from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity

class SimpleVectorSearch:
    """Simple vector search using sentence-transformers and local storage"""
    
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.embedding_model = None
        self.embeddings_file = os.path.join(
            os.path.dirname(config["index_path"]),
            "vector_embeddings.pkl"
        )
        self.metadata_file = os.path.join(
            os.path.dirname(config["index_path"]),
            "vector_metadata.json"
        )
        self.embeddings = {}  # doc_id -> embedding vector
        self.metadata = {}    # doc_id -> metadata
        self.load_embedding_model()
        self.load_embeddings()
    
    def load_embedding_model(self):
        """Load sentence transformer model for embeddings"""
        try:
            # Use a lightweight model for local use
            model_name = "all-MiniLM-L6-v2"  # 384 dimensions, fast
            logging.info(f"Loading embedding model: {model_name}")
            
            self.embedding_model = SentenceTransformer(model_name)
            logging.info(f"Embedding model loaded: {model_name}")
            
        except Exception as e:
            logging.error(f"Failed to load embedding model: {e}")
            self.embedding_model = None
    
    def generate_embedding(self, text: str) -> Optional[np.ndarray]:
        """Generate embedding vector for text"""
        if not self.embedding_model or not text:
            return None
        
        try:
            # Clean and truncate text if too long
            if len(text) > 10000:
                text = text[:10000]
            
            # Generate embedding
            embedding = self.embedding_model.encode(text)
            return embedding
            
        except Exception as e:
            logging.error(f"Failed to generate embedding: {e}")
            return None
    
    def generate_doc_id(self, path: str) -> str:
        """Generate unique document ID from path"""
        return hashlib.md5(path.encode()).hexdigest()
    
    def load_embeddings(self):
        """Load embeddings from disk"""
        try:
            if os.path.exists(self.embeddings_file):
                with open(self.embeddings_file, 'rb') as f:
                    self.embeddings = pickle.load(f)
                logging.info(f"Loaded {len(self.embeddings)} embeddings from {self.embeddings_file}")
            else:
                logging.info("No embeddings file found, starting fresh")
                self.embeddings = {}
            
            if os.path.exists(self.metadata_file):
                with open(self.metadata_file, 'r') as f:
                    self.metadata = json.load(f)
                logging.info(f"Loaded metadata for {len(self.metadata)} documents")
            else:
                self.metadata = {}
                
        except Exception as e:
            logging.error(f"Failed to load embeddings: {e}")
            self.embeddings = {}
            self.metadata = {}
    
    def save_embeddings(self):
        """Save embeddings to disk"""
        try:
            # Ensure directory exists
            os.makedirs(os.path.dirname(self.embeddings_file), exist_ok=True)
            
            # Save embeddings
            with open(self.embeddings_file, 'wb') as f:
                pickle.dump(self.embeddings, f)
            
            # Save metadata
            with open(self.metadata_file, 'w') as f:
                json.dump(self.metadata, f, indent=2, default=str)
            
            logging.info(f"Saved {len(self.embeddings)} embeddings to {self.embeddings_file}")
            
        except Exception as e:
            logging.error(f"Failed to save embeddings: {e}")
    
    def index_document(self, doc_id: str, text: str, metadata: Dict[str, Any]) -> bool:
        """Index a document with vector embeddings"""
        if not self.embedding_model:
            logging.warning("Embedding model not available")
            return False
        
        try:
            # Generate embedding
            embedding = self.generate_embedding(text)
            if embedding is None:
                return False
            
            # Store embedding
            self.embeddings[doc_id] = embedding
            
            # Store metadata
            self.metadata[doc_id] = {
                "path": metadata.get("path", ""),
                "title": metadata.get("title", ""),
                "filename": metadata.get("filename", ""),
                "extension": metadata.get("extension", ""),
                "file_size": metadata.get("file_size", 0),
                "modified": metadata.get("modified", "").isoformat() if hasattr(metadata.get("modified", ""), 'isoformat') else str(metadata.get("modified", "")),
                "indexed": datetime.now().isoformat(),
                "text_preview": text[:500]  # Store first 500 chars for snippets
            }
            
            # Save to disk
            self.save_embeddings()
            
            logging.debug(f"Indexed document with vector: {doc_id}")
            return True
            
        except Exception as e:
            logging.error(f"Failed to index document {doc_id}: {e}")
            return False
    
    def search(self, query: str, limit: int = 10) -> List[Dict[str, Any]]:
        """Search documents using vector similarity"""
        if not self.embedding_model or not self.embeddings:
            logging.warning("Vector search not available or no embeddings")
            return []
        
        try:
            # Generate query embedding
            query_embedding = self.generate_embedding(query)
            if query_embedding is None:
                return []
            
            # Prepare embeddings matrix
            doc_ids = list(self.embeddings.keys())
            if not doc_ids:
                return []
            
            embeddings_matrix = np.array([self.embeddings[doc_id] for doc_id in doc_ids])
            
            # Calculate cosine similarities
            query_embedding_2d = query_embedding.reshape(1, -1)
            similarities = cosine_similarity(query_embedding_2d, embeddings_matrix)[0]
            
            # Get top results
            top_indices = np.argsort(similarities)[::-1][:limit]
            
            # Prepare results
            results = []
            for idx in top_indices:
                doc_id = doc_ids[idx]
                similarity = similarities[idx]
                meta = self.metadata.get(doc_id, {})
                
                results.append({
                    "id": doc_id,
                    "path": meta.get("path", ""),
                    "title": meta.get("title", "Untitled"),
                    "score": float(similarity),  # Convert numpy float to Python float
                    "snippet": meta.get("text_preview", "")[:200] + "..." if len(meta.get("text_preview", "")) > 200 else meta.get("text_preview", ""),
                    "metadata": meta
                })
            
            logging.info(f"Vector search found {len(results)} results for: '{query}'")
            return results
            
        except Exception as e:
            logging.error(f"Vector search failed: {e}")
            return []
    
    def delete_document(self, doc_id: str) -> bool:
        """Delete a document from vector index"""
        try:
            if doc_id in self.embeddings:
                del self.embeddings[doc_id]
            
            if doc_id in self.metadata:
                del self.metadata[doc_id]
            
            self.save_embeddings()
            logging.debug(f"Deleted document from vector index: {doc_id}")
            return True
            
        except Exception as e:
            logging.error(f"Failed to delete document {doc_id}: {e}")
            return False
    
    def clear_index(self) -> bool:
        """Clear all vector embeddings"""
        try:
            self.embeddings = {}
            self.metadata = {}
            self.save_embeddings()
            logging.info("Cleared all vector embeddings")
            return True
        except Exception as e:
            logging.error(f"Failed to clear vector index: {e}")
            return False
    
    def get_stats(self) -> Dict[str, Any]:
        """Get vector index statistics"""
        stats = {
            "document_count": len(self.embeddings),
            "embedding_dimensions": self.embedding_model.get_sentence_embedding_dimension() if self.embedding_model else "Unknown",
            "embeddings_file": self.embeddings_file,
            "metadata_file": self.metadata_file,
            "total_size_bytes": sum(sys.getsizeof(e) for e in self.embeddings.values()) if self.embeddings else 0
        }
        return stats
    
    def test_search(self) -> Dict[str, Any]:
        """Test vector search functionality"""
        test_queries = [
            "artificial intelligence",
            "financial report",
            "memory system",
            "project decision"
        ]
        
        results = {}
        
        for query in test_queries:
            try:
                search_results = self.search(query, limit=2)
                results[query] = {
                    "success": True,
                    "count": len(search_results),
                    "results": [
                        {
                            "title": r.get("title", ""),
                            "score": r.get("score", 0)
                        }
                        for r in search_results[:2]
                    ]
                }
            except Exception as e:
                results[query] = {
                    "success": False,
                    "error": str(e),
                    "count": 0
                }
        
        return results