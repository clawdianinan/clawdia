"""
Document indexer for QMD
Handles scanning, parsing, and indexing of documents
"""

import os
import logging
import hashlib
from pathlib import Path
from typing import Dict, List, Any, Optional, Tuple
from datetime import datetime

from whoosh import index
from whoosh.fields import Schema, TEXT, ID, DATETIME, STORED
from whoosh.analysis import StemmingAnalyzer
import frontmatter
import hashlib

class QMDIndexer:
    """Indexes documents for search"""
    
    def __init__(self, config: Dict[str, Any]):
        self.config = config
        self.index_path = config["index_path"]
        self.schema = self.create_schema()
        self.setup_index()
        
        # Initialize vector search if enabled
        if config.get("vector_weight", 0) > 0:
            try:
                from vector_search_simple import SimpleVectorSearch
                self.vector_indexer = SimpleVectorSearch(config)
                logging.info("Vector indexer initialized")
            except Exception as e:
                logging.warning(f"Failed to initialize vector indexer: {e}")
                self.vector_indexer = None
        else:
            self.vector_indexer = None
    
    def create_schema(self) -> Schema:
        """Create Whoosh schema for documents"""
        analyzer = StemmingAnalyzer()
        
        return Schema(
            path=ID(stored=True, unique=True),
            title=TEXT(stored=True, analyzer=analyzer),
            content=TEXT(stored=True, analyzer=analyzer),
            filename=TEXT(stored=True, analyzer=analyzer),
            extension=STORED,
            directory=STORED,
            file_size=STORED,
            modified=DATETIME(stored=True),
            indexed=DATETIME(stored=True),
            checksum=STORED
        )
    
    def setup_index(self):
        """Create or open the index"""
        os.makedirs(self.index_path, exist_ok=True)
        
        if not index.exists_in(self.index_path):
            logging.info(f"Creating new index at {self.index_path}")
            self.ix = index.create_in(self.index_path, self.schema)
        else:
            logging.info(f"Opening existing index at {self.index_path}")
            self.ix = index.open_dir(self.index_path)
    
    def calculate_checksum(self, filepath: str) -> str:
        """Calculate MD5 checksum of file"""
        hash_md5 = hashlib.md5()
        with open(filepath, "rb") as f:
            for chunk in iter(lambda: f.read(4096), b""):
                hash_md5.update(chunk)
        return hash_md5.hexdigest()
    
    def should_index_file(self, filepath: str) -> bool:
        """Check if file should be indexed"""
        # Check extension
        ext = Path(filepath).suffix.lower()
        if ext not in self.config["extensions"]:
            return False
        
        # Check exclude patterns
        for pattern in self.config["exclude_patterns"]:
            if pattern in filepath:
                return False
        
        # Check file size
        max_size = self.config.get("max_file_size_mb", 10) * 1024 * 1024
        file_size = os.path.getsize(filepath)
        if file_size > max_size:
            logging.debug(f"Skipping large file: {filepath} ({file_size} bytes)")
            return False
        
        return True
    
    def parse_document(self, filepath: str) -> Optional[Dict[str, Any]]:
        """Parse document and extract metadata"""
        try:
            path = Path(filepath)
            
            # Read file
            with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            
            # Parse frontmatter if present
            metadata = {}
            try:
                post = frontmatter.loads(content)
                content = post.content
                metadata = post.metadata
            except:
                pass  # No frontmatter or parsing error
            
            # Extract title
            title = metadata.get('title', '')
            if not title:
                # Try to extract from first heading
                lines = content.split('\n')
                for line in lines[:10]:  # Check first 10 lines
                    line = line.strip()
                    if line.startswith('# '):
                        title = line[2:].strip()
                        break
            
            if not title:
                title = path.stem
            
            # Get file stats
            stat = path.stat()
            modified = datetime.fromtimestamp(stat.st_mtime)
            
            # Calculate checksum
            checksum = self.calculate_checksum(filepath)
            
            return {
                "path": str(filepath),
                "title": title,
                "content": content,
                "filename": path.name,
                "extension": path.suffix,
                "directory": str(path.parent),
                "file_size": stat.st_size,
                "modified": modified,
                "indexed": datetime.now(),
                "checksum": checksum
            }
            
        except Exception as e:
            logging.error(f"Failed to parse {filepath}: {e}")
            return None
    
    def index_file(self, filepath: str, writer=None) -> Tuple[bool, str]:
        """Index a single file"""
        close_writer = False
        if writer is None:
            writer = self.ix.writer()
            close_writer = True
        
        try:
            # Parse document
            doc = self.parse_document(filepath)
            if not doc:
                return False, "Failed to parse"
            
            # Check if already indexed and unchanged
            with self.ix.searcher() as searcher:
                results = list(searcher.documents(path=doc["path"]))
                if results:
                    existing = results[0]
                    if existing.get("checksum") == doc["checksum"]:
                        logging.debug(f"Skipping unchanged file: {filepath}")
                        return True, "Unchanged"
            
            # Add or update document in Whoosh (BM25)
            writer.update_document(
                path=doc["path"],
                title=doc["title"],
                content=doc["content"],
                filename=doc["filename"],
                extension=doc["extension"],
                directory=doc["directory"],
                file_size=doc["file_size"],
                modified=doc["modified"],
                indexed=doc["indexed"],
                checksum=doc["checksum"]
            )
            
            # Index in vector database if enabled
            if self.vector_indexer:
                # Generate document ID from path hash
                doc_id = hashlib.md5(doc["path"].encode()).hexdigest()
                
                # Index in ChromaDB
                vector_success = self.vector_indexer.index_document(
                    doc_id=doc_id,
                    text=doc["content"],
                    metadata=doc
                )
                
                if vector_success:
                    logging.debug(f"Indexed in vector DB: {filepath}")
                else:
                    logging.warning(f"Failed to index in vector DB: {filepath}")
            
            if close_writer:
                writer.commit()
            
            return True, "Indexed"
            
        except Exception as e:
            logging.error(f"Failed to index {filepath}: {e}")
            if close_writer:
                writer.cancel()
            return False, str(e)
    
    def index_directory(self, directory: str, verbose: bool = False) -> Dict[str, int]:
        """Index all documents in a directory recursively"""
        stats = {
            "total": 0,
            "indexed": 0,
            "skipped": 0,
            "errors": 0
        }
        
        logging.info(f"Indexing directory: {directory}")
        
        # Get all files
        all_files = []
        for ext in self.config["extensions"]:
            all_files.extend(Path(directory).rglob(f"*{ext}"))
        
        stats["total"] = len(all_files)
        
        if stats["total"] == 0:
            logging.warning(f"No files found with extensions {self.config['extensions']}")
            return stats
        
        # Open writer for batch operations
        writer = self.ix.writer()
        
        try:
            for filepath in all_files:
                filepath_str = str(filepath)
                
                # Check if should index
                if not self.should_index_file(filepath_str):
                    stats["skipped"] += 1
                    if verbose:
                        logging.debug(f"Skipped: {filepath_str}")
                    continue
                
                # Index file
                success, message = self.index_file(filepath_str, writer)
                
                if success:
                    if message == "Indexed":
                        stats["indexed"] += 1
                        if verbose:
                            logging.info(f"Indexed: {filepath_str}")
                    else:  # Unchanged
                        stats["skipped"] += 1
                        if verbose:
                            logging.debug(f"Unchanged: {filepath_str}")
                else:
                    stats["errors"] += 1
                    logging.warning(f"Failed: {filepath_str} - {message}")
                
                # Progress reporting
                processed = stats["indexed"] + stats["skipped"] + stats["errors"]
                if processed % 100 == 0:
                    logging.info(f"Progress: {processed}/{stats['total']} files")
            
            # Commit all changes
            writer.commit()
            logging.info(f"Committed {stats['indexed']} documents to index")
            
        except Exception as e:
            writer.cancel()
            logging.error(f"Batch indexing failed: {e}")
            stats["errors"] += stats["total"] - (stats["indexed"] + stats["skipped"])
        
        return stats
    
    def clear_index(self):
        """Clear the entire index"""
        try:
            writer = self.ix.writer()
            writer.commit(mergetype=index.CLEAR)  # Clear all documents
            logging.info("Index cleared")
        except Exception as e:
            logging.error(f"Failed to clear index: {e}")
            raise
    
    def get_index_stats(self) -> Dict[str, Any]:
        """Get index statistics"""
        try:
            with self.ix.searcher() as searcher:
                doc_count = searcher.doc_count()
                
                # Get field statistics
                fields = list(self.schema.names())
                
                return {
                    "document_count": doc_count,
                    "fields": fields,
                    "index_path": self.index_path,
                    "schema": {name: str(type_) for name, type_ in self.schema.items()}
                }
        except Exception as e:
            logging.error(f"Failed to get index stats: {e}")
            return {"error": str(e)}