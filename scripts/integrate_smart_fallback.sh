#!/bin/bash
# Smart Fallback Integration Script for OpenClaw
# This script hooks into OpenClaw to implement intelligent model fallback logic

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SCRIPT="$SCRIPT_DIR/smart_model_fallback.py"
CACHE_FILE="$HOME/.openclaw/model_fallback_cache.json"
OPENCLAW_CONFIG="$HOME/.openclaw/openclaw.json"
BACKUP_CONFIG="$HOME/.openclaw/openclaw.json.backup.$(date +%Y%m%d_%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        log_error "Python3 is required but not installed"
        return 1
    fi
    
    # Check OpenClaw
    if ! command -v openclaw &> /dev/null; then
        log_warning "OpenClaw CLI not found in PATH (may be normal if installed differently)"
    fi
    
    # Check Python script
    if [ ! -f "$PYTHON_SCRIPT" ]; then
        log_error "Python script not found: $PYTHON_SCRIPT"
        return 1
    fi
    
    log_success "Prerequisites check passed"
    return 0
}

backup_config() {
    log_info "Backing up OpenClaw configuration..."
    cp "$OPENCLAW_CONFIG" "$BACKUP_CONFIG"
    log_success "Configuration backed up to: $BACKUP_CONFIG"
}

get_current_status() {
    log_info "Getting current rate limit status..."
    python3 "$PYTHON_SCRIPT" status
}

record_model_failure() {
    local model="$1"
    local error="$2"
    local retry_after="$3"
    
    log_info "Recording model failure for: $model"
    log_info "Error: $error"
    
    if [ -n "$retry_after" ]; then
        log_info "Custom retry time: $retry_after"
        python3 "$PYTHON_SCRIPT" record "$model" "$error" --retry-after "$retry_after"
    else
        python3 "$PYTHON_SCRIPT" record "$model" "$error"
    fi
}

clear_model_rate_limit() {
    local model="$1"
    
    log_info "Clearing rate limit for: $model"
    python3 "$PYTHON_SCRIPT" clear "$model"
}

get_best_model() {
    log_info "Getting best available model..."
    best_model=$(python3 "$PYTHON_SCRIPT" best)
    echo "$best_model"
}

update_openclaw_config() {
    log_info "Updating OpenClaw configuration with smart fallbacks..."
    
    # Get best available model
    best_model=$(get_best_model)
    
    if [ -z "$best_model" ]; then
        log_error "Could not determine best model"
        return 1
    fi
    
    log_info "Best available model: $best_model"
    
    # Get all available models
    available_models=$(python3 "$PYTHON_SCRIPT" list | grep -E "^[0-9]+\. " | cut -d' ' -f2-)
    
    # Create fallback list (excluding the primary)
    fallbacks=()
    first=true
    while IFS= read -r model; do
        if [ "$first" = true ]; then
            first=false
            continue
        fi
        fallbacks+=("$model")
    done <<< "$available_models"
    
    # Backup config first
    backup_config
    
    # Update configuration using jq if available, otherwise use Python
    if command -v jq &> /dev/null; then
        # Using jq
        jq --arg primary "$best_model" --argjson fallbacks "$(printf '%s\n' "${fallbacks[@]}" | jq -R . | jq -s .)" \
           '.agents.defaults.model.primary = $primary | .agents.defaults.model.fallbacks = $fallbacks' \
           "$OPENCLAW_CONFIG" > "$OPENCLAW_CONFIG.tmp" && mv "$OPENCLAW_CONFIG.tmp" "$OPENCLAW_CONFIG"
    else
        # Using Python
        python3 -c "
import json
import sys

with open('$OPENCLAW_CONFIG', 'r') as f:
    config = json.load(f)

# Update model configuration
if 'agents' in config and 'defaults' in config['agents']:
    config['agents']['defaults']['model']['primary'] = '$best_model'
    config['agents']['defaults']['model']['fallbacks'] = $(python3 -c "import json; print(json.dumps(list('${fallbacks[@]}'.split())))")

with open('$OPENCLAW_CONFIG', 'w') as f:
    json.dump(config, f, indent=2)
"
    fi
    
    log_success "OpenClaw configuration updated"
    log_info "Primary model: $best_model"
    log_info "Fallbacks: ${fallbacks[*]}"
}

restart_openclaw_gateway() {
    log_info "Restarting OpenClaw gateway..."
    
    if openclaw gateway restart 2>/dev/null; then
        log_success "OpenClaw gateway restarted successfully"
    else
        log_warning "OpenClaw gateway restart may have failed or gateway not running"
        log_info "You may need to manually restart: openclaw gateway restart"
    fi
}

setup_monitoring_hook() {
    log_info "Setting up monitoring hook..."
    
    # Create a simple monitoring script that watches OpenClaw logs
    MONITOR_SCRIPT="$SCRIPT_DIR/monitor_openclaw_errors.sh"
    
    cat > "$MONITOR_SCRIPT" << 'EOF'
#!/bin/bash
# Monitor OpenClaw for model errors and record them automatically

LOG_FILE="$HOME/.openclaw/logs/openclaw.log"
CACHE_FILE="$HOME/.openclaw/model_fallback_cache.json"
PYTHON_SCRIPT="$(dirname "$0")/smart_model_fallback.py"

if [ ! -f "$LOG_FILE" ]; then
    echo "Log file not found: $LOG_FILE"
    exit 1
fi

# Patterns to look for
PATTERNS=(
    "gpt-5.3-codex.*insufficient permissions"
    "gpt-5.3-codex.*rate limit"
    "gpt-5.3-codex.*usage limit"
    "HTTP 401.*model.request"
    "404.*not a chat model"
)

tail -F "$LOG_FILE" | while read line; do
    for pattern in "${PATTERNS[@]}"; do
        if echo "$line" | grep -q -i "$pattern"; then
            echo "[$(date)] Detected model error: $pattern"
            echo "Line: $line"
            
            # Extract model name from error
            if echo "$line" | grep -q "gpt-5.3-codex"; then
                model="openai-codex/gpt-5.3-codex"
                python3 "$PYTHON_SCRIPT" record "$model" "$line"
            fi
        fi
    done
done
EOF
    
    chmod +x "$MONITOR_SCRIPT"
    log_success "Monitoring script created: $MONITOR_SCRIPT"
    log_info "To start monitoring: $MONITOR_SCRIPT"
}

show_usage() {
    echo "Smart Fallback Integration for OpenClaw"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  status        - Show current rate limit status"
    echo "  record        - Record a model failure (interactive)"
    echo "  clear         - Clear rate limit for a model (interactive)"
    echo "  update        - Update OpenClaw config with best available model"
    echo "  monitor       - Set up error monitoring hook"
    echo "  full-setup    - Run full setup (update + monitor)"
    echo "  help          - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 status"
    echo "  $0 update"
    echo "  $0 full-setup"
}

case "${1:-help}" in
    status)
        check_prerequisites
        get_current_status
        ;;
    
    record)
        check_prerequisites
        echo "Enter model ID (e.g., openai-codex/gpt-5.3-codex):"
        read -r model
        echo "Enter error message:"
        read -r error
        echo "Enter custom retry time (ISO format, e.g., 2026-03-21T23:33:00) or press Enter for default 24 hours:"
        read -r retry_after
        record_model_failure "$model" "$error" "$retry_after"
        ;;
    
    clear)
        check_prerequisites
        echo "Enter model ID to clear (e.g., openai-codex/gpt-5.3-codex):"
        read -r model
        clear_model_rate_limit "$model"
        ;;
    
    update)
        check_prerequisites
        update_openclaw_config
        restart_openclaw_gateway
        ;;
    
    monitor)
        check_prerequisites
        setup_monitoring_hook
        ;;
    
    full-setup)
        check_prerequisites
        update_openclaw_config
        restart_openclaw_gateway
        setup_monitoring_hook
        ;;
    
    help|*)
        show_usage
        ;;
esac