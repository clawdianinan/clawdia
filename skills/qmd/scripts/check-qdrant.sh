#!/bin/bash
# Check Qdrant service status and restart if needed

set -e

# Configuration
QDRAINT_BINARY="/usr/local/bin/qdrant"
if [ ! -f "$QDRAINT_BINARY" ]; then
    QDRAINT_BINARY="$HOME/.local/bin/qdrant"
fi
if [ ! -f "$QDRAINT_BINARY" ]; then
    QDRAINT_BINARY="$HOME/bin/qdrant"
fi
QDRAINT_CONFIG="$HOME/.qdrant/config/config.yaml"
QDRAINT_LOG="$HOME/.qdrant/qdrant.log"
QDRAINT_ERROR_LOG="$HOME/.qdrant/qdrant.error.log"
QDRAINT_PORT=6333

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

check_qdrant_installed() {
    if [ ! -f "$QDRAINT_BINARY" ]; then
        error "Qdrant binary not found at $QDRAINT_BINARY"
        return 1
    fi
    
    if [ ! -x "$QDRAINT_BINARY" ]; then
        error "Qdrant binary is not executable"
        return 1
    fi
    
    log "Qdrant binary found: $QDRAINT_BINARY"
    return 0
}

check_qdrant_running() {
    # Check if process is running
    if pgrep -f "qdrant" > /dev/null; then
        log "Qdrant process is running"
        return 0
    else
        warning "Qdrant process is not running"
        return 1
    fi
}

check_qdrant_port() {
    # Check if port is listening
    if nc -z localhost $QDRAINT_PORT 2>/dev/null; then
        log "Qdrant is listening on port $QDRAINT_PORT"
        return 0
    else
        warning "Qdrant is not listening on port $QDRAINT_PORT"
        return 1
    fi
}

check_qdrant_health() {
    # Check HTTP health endpoint
    if curl -s http://localhost:$QDRAINT_PORT/health > /dev/null 2>&1; then
        log "Qdrant health check passed"
        return 0
    else
        warning "Qdrant health check failed"
        return 1
    fi
}

start_qdrant() {
    log "Starting Qdrant service..."
    
    # Create directories if they don't exist
    mkdir -p "$(dirname "$QDRAINT_CONFIG")"
    mkdir -p "$(dirname "$QDRAINT_LOG")"
    
    # Create default config if it doesn't exist
    if [ ! -f "$QDRAINT_CONFIG" ]; then
        cat > "$QDRAINT_CONFIG" << EOF
log_level: INFO
storage:
  storage_path: $HOME/.qdrant/storage
service:
  http_port: 6333
  grpc_port: 6334
EOF
        log "Created default Qdrant config at $QDRAINT_CONFIG"
    fi
    
    # Start Qdrant in background
    nohup "$QDRAINT_BINARY" --config-path "$QDRAINT_CONFIG" > "$QDRAINT_LOG" 2> "$QDRAINT_ERROR_LOG" &
    
    local pid=$!
    log "Started Qdrant with PID $pid"
    
    # Wait for startup
    local max_wait=30
    local wait_interval=2
    local waited=0
    
    while [ $waited -lt $max_wait ]; do
        if check_qdrant_port; then
            success "Qdrant started successfully"
            return 0
        fi
        sleep $wait_interval
        waited=$((waited + wait_interval))
    done
    
    error "Qdrant failed to start within $max_wait seconds"
    return 1
}

install_qdrant() {
    log "Installing Qdrant..."
    
    # Check if tar.gz exists
    local qdrant_tar="$HOME/.qdrant/qdrant.tar.gz"
    if [ ! -f "$qdrant_tar" ]; then
        error "Qdrant tar.gz not found at $qdrant_tar"
        error "Please download it first:"
        error "curl -L https://github.com/qdrant/qdrant/releases/download/v1.9.0/qdrant-x86_64-apple-darwin.tar.gz -o $qdrant_tar"
        return 1
    fi
    
    # Extract Qdrant
    log "Extracting Qdrant from $qdrant_tar"
    tar -xzf "$qdrant_tar" -C /tmp/
    
    # Install to /usr/local/bin
    if [ -f "/tmp/qdrant" ]; then
        sudo mv /tmp/qdrant /usr/local/bin/
        sudo chmod +x /usr/local/bin/qdrant
        success "Qdrant installed to /usr/local/bin/qdrant"
        return 0
    else
        error "Failed to extract qdrant binary"
        return 1
    fi
}

create_launchd_service() {
    log "Creating launchd service for Qdrant..."
    
    local plist_path="$HOME/Library/LaunchAgents/com.user.qdrant.plist"
    
    cat > "$plist_path" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.qdrant</string>
    <key>ProgramArguments</key>
    <array>
        <string>$QDRAINT_BINARY</string>
        <string>--config-path</string>
        <string>$QDRAINT_CONFIG</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$QDRAINT_LOG</string>
    <key>StandardErrorPath</key>
    <string>$QDRAINT_ERROR_LOG</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    </dict>
</dict>
</plist>
EOF
    
    log "Created launchd plist at $plist_path"
    
    # Load the service
    launchctl load "$plist_path" 2>/dev/null || true
    log "Loaded launchd service"
}

main() {
    log "=== Qdrant Service Check ==="
    
    # Check if Qdrant is installed
    if ! check_qdrant_installed; then
        warning "Qdrant is not installed. Attempting to install..."
        if install_qdrant; then
            success "Qdrant installed successfully"
        else
            error "Failed to install Qdrant"
            exit 1
        fi
    fi
    
    # Check if Qdrant is running
    local needs_restart=false
    
    if ! check_qdrant_running; then
        warning "Qdrant is not running"
        needs_restart=true
    elif ! check_qdrant_port; then
        warning "Qdrant port not listening"
        needs_restart=true
    elif ! check_qdrant_health; then
        warning "Qdrant health check failed"
        needs_restart=true
    fi
    
    # Restart if needed
    if [ "$needs_restart" = true ]; then
        log "Restarting Qdrant..."
        
        # Kill existing process
        pkill -f "qdrant" 2>/dev/null || true
        sleep 2
        
        # Start Qdrant
        if start_qdrant; then
            success "Qdrant restarted successfully"
            
            # Create launchd service for auto-start
            create_launchd_service
            
        else
            error "Failed to restart Qdrant"
            exit 1
        fi
    else
        success "Qdrant is running and healthy"
    fi
    
    # Test Qdrant functionality
    log "Testing Qdrant functionality..."
    
    # Create test collection
    if curl -s -X PUT http://localhost:$QDRAINT_PORT/collections/test \
        -H 'Content-Type: application/json' \
        -d '{"vectors": {"size": 384, "distance": "Cosine"}}' > /dev/null 2>&1; then
        log "Test collection created successfully"
        
        # Delete test collection
        curl -s -X DELETE http://localhost:$QDRAINT_PORT/collections/test > /dev/null 2>&1
        log "Test collection cleaned up"
    else
        warning "Failed to create test collection (may already exist)"
    fi
    
    log "=== Qdrant Check Complete ==="
    exit 0
}

# Handle script arguments
case "${1:-}" in
    install)
        install_qdrant
        ;;
    start)
        start_qdrant
        ;;
    stop)
        pkill -f "qdrant" 2>/dev/null && success "Qdrant stopped" || error "Failed to stop Qdrant"
        ;;
    status)
        echo "=== Qdrant Status ==="
        check_qdrant_installed && echo "✓ Installed" || echo "✗ Not installed"
        check_qdrant_running && echo "✓ Running" || echo "✗ Not running"
        check_qdrant_port && echo "✓ Port listening" || echo "✗ Port not listening"
        check_qdrant_health && echo "✓ Healthy" || echo "✗ Unhealthy"
        ;;
    *)
        main
        ;;
esac