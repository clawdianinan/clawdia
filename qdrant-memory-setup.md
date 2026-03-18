# Qdrant Memory System Setup for OpenClaw

## **Current Status**
- **OpenClaw Memory:** Using OpenAI embeddings via `memory_search`/`memory_get`
- **Vector Database:** None configured (Qdrant not installed)
- **Download in Progress:** DeepSeek Coder 6.7B (9% complete)

## **Qdrant Options**

### **Option 1: Local Qdrant Server (Recommended)**
**Pros:**
- Full control
- No external dependencies
- Works offline
- Better privacy

**Cons:**
- Requires installation
- Uses RAM/disk space

### **Option 2: Cloud Qdrant (Qdrant Cloud)**
**Pros:**
- No installation
- Managed service
- Scalable

**Cons:**
- Requires API key
- Monthly cost
- External dependency

### **Option 3: Alternative Vector DBs**
1. **ChromaDB** - Python-based, simpler
2. **LanceDB** - Arrow-based, fast
3. **Weaviate** - Feature-rich but heavier

## **Setup Plan: Local Qdrant**

### **Step 1: Install Qdrant**
```bash
# Download Qdrant binary
curl -L https://github.com/qdrant/qdrant/releases/download/v1.9.0/qdrant-x86_64-apple-darwin.tar.gz -o qdrant.tar.gz
tar -xzf qdrant.tar.gz
sudo mv qdrant /usr/local/bin/
```

### **Step 2: Create Configuration**
```bash
# Create config directory
mkdir -p ~/.qdrant/config

# Create config file
cat > ~/.qdrant/config/config.yaml << EOF
log_level: INFO
storage:
  storage_path: ~/.qdrant/storage
service:
  http_port: 6333
  grpc_port: 6334
EOF
```

### **Step 3: Create System Service**
```bash
# Create launchd service
cat > ~/Library/LaunchAgents/com.user.qdrant.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.qdrant</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/qdrant</string>
        <string>--config-path</string>
        <string>$HOME/.qdrant/config/config.yaml</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$HOME/.qdrant/qdrant.log</string>
    <key>StandardErrorPath</key>
    <string>$HOME/.qdrant/qdrant.error.log</string>
</dict>
</plist>
EOF

# Load service
launchctl load ~/Library/LaunchAgents/com.user.qdrant.plist
```

### **Step 4: Test Qdrant**
```bash
# Check if running
curl http://localhost:6333

# Create test collection
curl -X PUT http://localhost:6333/collections/test \
  -H 'Content-Type: application/json' \
  -d '{
    "vectors": {
      "size": 384,
      "distance": "Cosine"
    }
  }'
```

### **Step 5: Integrate with OpenClaw**

**Option A: Custom Memory Hook**
Create a hook that:
1. Indexes memory files to Qdrant
2. Provides semantic search via Qdrant
3. Falls back to OpenAI embeddings

**Option B: Replace `memory_search`**
Modify OpenClaw to use Qdrant instead of OpenAI embeddings

## **Memory Architecture**

### **Collection Structure**
```
Collection: openclaw_memory
- id: UUID
- text: Memory content
- embedding: Vector (384/768/1536 dim)
- metadata:
  - source: "MEMORY.md" | "memory/YYYY-MM-DD.md"
  - line_start: 10
  - line_end: 20
  - created_at: timestamp
  - updated_at: timestamp
```

### **Embedding Models**
1. **Local:** `all-MiniLM-L6-v2` (384 dim, fast)
2. **Local:** `gte-small` (384 dim, better quality)
3. **Cloud:** OpenAI `text-embedding-3-small` (1536 dim)

### **Query Flow**
```
User Query → Embedding Model → Qdrant Search → Results → Memory Get
```

## **Implementation Priority**

### **Phase 1: Basic Setup** (Now)
1. Install Qdrant
2. Test local server
3. Create basic collections

### **Phase 2: Integration** (After DeepSeek download)
1. Create embedding pipeline
2. Index existing memory files
3. Test semantic search

### **Phase 3: Production** (Later)
1. Automated indexing
2. Real-time updates
3. Performance optimization

## **Resource Requirements**

### **Memory Usage**
- **Qdrant:** ~100MB base + vector storage
- **Embedding Model:** ~100-500MB
- **Total:** ~200-600MB

### **Disk Space**
- **Qdrant storage:** ~1GB for 10k vectors
- **Models:** ~500MB
- **Total:** ~1.5GB

## **Alternative: Lite Setup**

If Qdrant is too heavy, consider:

### **LiteVector (SQLite + vectors)**
```bash
pip install litevector
```

### **ChromaDB Lite**
```bash
pip install chromadb
```

## **Next Steps**

1. **Wait for DeepSeek download** (currently 9%)
2. **Install Qdrant** (10 minutes)
3. **Test basic functionality**
4. **Create integration script**

**Estimated Time:** 30-60 minutes

## **Decision Needed**

Should I proceed with:
1. **Full Qdrant setup** (recommended)
2. **Lite alternative** (ChromaDB/LiteVector)
3. **Wait for DeepSeek first**

**Recommendation:** Start with Qdrant setup while DeepSeek downloads.