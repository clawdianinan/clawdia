"""
Vector search engine for QMD using ChromaDB
Provides semantic search using embeddings
"""

import os
import logging
import hashlib
from typing import List, Dict, Any, Optional
from datetime import datetime

import chromadb
from chromadb.config import Settings
from sentence_transformers import SentenceTransformer

class VectorSearch:
    """Vector semantic search engine using ChromaDB"""
    
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.embedding_model = None
        self.chroma_client = None
        self.collection = None
        self.setup_chromadb()
    
    def setup_chromadb(self):
        """Initialize ChromaDB client and collection"""
        try:
            # ChromaDB settings
            chroma_settings = Settings(
                chroma_db_impl="duckdb+parquet",
                persist_directory=os.path.join(
                    os.path.dirname(self.config["index_path"]),
                    "chroma_db"
                ),
                anonymized_telemetry=False
            )
            
            # Create client
            self.chroma_client = chromadb.Client(chroma_settings)
            logging.info(f"ChromaDB client initialized at {chroma_settings.persist_directory}")
            
            # Get or create collection
            collection_name = "qmd_documents"
            try:
                self.collection = self.chroma_client.get_collection(collection_name)
                logging.info(f"Loaded existing ChromaDB collection: {collection_name}")
            except:
                self.collection = self.chroma_client.create_collection(
                    name=collection_name,
                    metadata={"description": "QMD document embeddings"}
                )
                logging.info(f"Created new ChromaDB collection: {collection_name}")
            
            # Load embedding model
            self.load_embedding_model()
            
        except Exception as e:
            logging.error(f"Failed to setup ChromaDB: {e}")
            raise
    
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
            # Fallback to a simpler model or disable vector search
            self.embedding_model = None
    
    def generate_embedding(self, text: str) -> Optional[List[float]]:
        """Generate embedding vector for text"""
        if not self.embedding_model or not text:
            return None
        
        try:
            # Clean and truncate text if too long
            if len(text) > 10000:
                text = text[:10000]
            
            # Generate embedding
            embedding = self.embedding_model.encode(text).tolist()
            return embedding
            
        except Exception as e:
            logging.error(f"Failed to generate embedding: {e}")
            return None
    
    def index_document(self, doc_id: str, text: str, metadata: Dict[str, Any]) -> bool:
        """Index a document in ChromaDB"""
        if not self.collection or not self.embedding_model:
            logging.warning("ChromaDB or embedding model not available")
            return False
        
        try:
            # Generate embedding
            embedding = self.generate_embedding(text)
            if not embedding:
                return False
            
            # Prepare metadata
            chroma_metadata = {
                "source": metadata.get("path", ""),
                "title": metadata.get("title", ""),
                "filename": metadata.get("filename", ""),
                "extension": metadata.get("extension", ""),
                "file_size": str(metadata.get("file_size", 0)),
                "modified": metadata.get("modified", "").isoformat() if hasattr(metadata.get("modified", ""), 'isoformat') else str(metadata.get("modified", "")),
                "indexed": datetime.now().isoformat()
            }
            
            # Add to collection
            self.collection.add(
                ids=[doc_id],
                embeddings=[embedding],
                metadatas=[chroma_metadata],
                documents=[text[:10000]]  # Store first 10k chars
            )
            
            logging.debug(f"Indexed document in ChromaDB: {doc_id}")
            return True
            
        except Exception as e:
            logging.error(f"Failed to index document {doc_id} in ChromaDB: {e}")
            return False
    
    def search(self, query: str, limit: int = 10) -> List[Dict[str, Any]]:
        """Search documents using vector similarity"""
        if not self.collection or not self.embedding_model:
            logging.warning("Vector search not available")
            return []
        
        try:
            # Generate query embedding
            query_embedding = self.generate_embedding(query)
            if not query_embedding:
                return []
            
            # Search in ChromaDB
            results = self.collection.query(
                query_embeddings=[query_embedding],
                n_results=min(limit, 20),
                include=["metadatas", "documents", "distances"]
            )
            
            # Process results
            vector_results = []
            
            if results and results["ids"]:
                for i in range(len(results["ids"][0])):
                    doc_id = results["ids"][0][i]
                    metadata = results["metadatas"][0][i] if results["metadatas"] else {}
                    document = results["documents"][0][i] if results["documents"] else ""
                    distance = results["distances"][0][i] if results["distances"] else 0
                    
                    # Convert distance to similarity score (0-1, higher is better)
                    similarity = 1.0 / (1.0 + distance) if distance > 0 else 1.0
                    
                    vector_results.append({
                        "id": doc_id,
                        "path": metadata.get("source", ""),
                        "title": metadata.get("title", "Untitled"),
                        "score": similarity,
                        "distance": distance,
                        "snippet": document[:200] + "..." if len(document) > 200 else document,
                        "metadata": metadata
                    })
            
            logging.info(f"Vector search found {len(vector_results)} results for: '{query}'")
            return vector_results
            
        except Exception as e:
            logging.error(f"Vector search failed: {e}")
            return []
    
    def hybrid_search(self, bm25_results: List[Dict[str, Any]], vector_results: List[Dict[str, Any]], 
                     bm25_weight: float = 0.5, vector_weight: float = 0.5) -> List[Dict[str, Any]]:
        """Combine BM25 and vector search results"""
        
        if not bm25_results and not vector_results:
            return []
        
        # Normalize scores
        def normalize_scores(results, score_key="score"):
            if not results:
                return []
            
            scores = [r.get(score_key, 0) for r in results]
            if not scores:
                return results
            
            min_score = min(scores)
            max_score = max(scores)
            
            if max_score == min_score:
                # All scores are equal
                for r in results:
                    r["normalized_score"] = 0.5
            else:
                # Normalize to 0-1 range
                for r in results:
                    raw_score = r.get(score_key, 0)
                    r["normalized_score"] = (raw_score - min_score) / (max_score - min_score)
            
            return results
        
        # Normalize both result sets
        bm25_results = normalize_scores(bm25_results, "score")
        vector_results = normalize_scores(vector_results, "score")
        
        # Create combined results dictionary
        combined = {}
        
        # Add BM25 results
        for result in bm25_results:
            doc_id = result.get("path", "")  # Use path as ID
            if doc_id:
                combined[doc_id] = {
                    "bm25_score": result.get("normalized_score", 0),
                    "vector_score": 0,
                    "result": result
                }
        
        # Add or update with vector results
        for result in vector_results:
            doc_id = result.get("path", "")
            if doc_id in combined:
                combined[doc_id]["vector_score"] = result.get("normalized_score", 0)
            else:
                combined[doc_id] = {
                    "bm25_score": 0,
                    "vector_score": result.get("normalized_score", 0),
                    "result": result
                }
        
        # Calculate hybrid scores
        hybrid_results = []
        for doc_id, scores in combined.items():
            hybrid_score = (
                scores["bm25_score"] * bm25_weight +
                scores["vector_score"] * vector_weight
            )
            
            result = scores["result"].copy()
            result["hybrid_score"] = hybrid_score
            result["bm25_score"] = scores["bm25_score"]
            result["vector_score"] = scores["vector_score"]
            
            hybrid_results.append(result)
        
        # Sort by hybrid score
        hybrid_results.sort(key=lambda x: x.get("hybrid_score", 0), reverse=True)
        
        logging.info(f"Hybrid search combined {len(bm25_results)} BM25 + {len(vector_results)} vector = {len(hybrid_results)} results")
        return hybrid_results
    
    def delete_document(self, doc_id: str) -> bool:
        """Delete a document from ChromaDB"""
        if not self.collection:
            return False
        
        try:
            self.collection.delete(ids=[doc_id])
            logging.debug(f"Deleted document from ChromaDB: {doc_id}")
            return True
        except Exception as e:
            logging.error(f"Failed to delete document {doc_id}: {e}")
            return False
    
    def clear_collection(self) -> bool:
        """Clear all documents from ChromaDB"""
        if not self.collection:
            return False
        
        try:
            # Get all IDs and delete
            results = self.collection.get()
            if results and results["ids"]:
                self.collection.delete(ids=results["ids"])
                logging.info(f"Cleared {len(results['ids'])} documents from ChromaDB")
            else:
                logging.info("ChromaDB collection already empty")
            return True
        except Exception as e:
            logging.error(f"Failed to clear ChromaDB collection: {e}")
            return False
    
    def get_collection_stats(self) -> Dict[str, Any]:
        """Get ChromaDB collection statistics"""
        if not self.collection:
            return {"error": "Collection not initialized"}
        
        try:
            results = self.collection.get()
            
            stats = {
                "document_count": len(results["ids"]) if results["ids"] else 0,
                "collection_name": self.collection.name,
                "embedding_dimensions": self.embedding_model.get_sentence_embedding_dimension() if self.embedding_model else "Unknown",
                "persist_directory": self.chroma_client._settings.persist_directory if self.chroma_client else "Unknown"
            }
            
            return stats
        except Exception as e:
            logging.error(f"Failed to get collection stats: {e}")
            return {"error": str(e)}
    
    def test_vector_search(self) -> Dict[str, Any]:
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
                            "score": r.get("score", 0),
                            "distance": r.get("distance", 0)
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