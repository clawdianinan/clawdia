#!/bin/bash
# AOZ Character Generation with Nano Banana + ImageFX Fallback

set -e

# Configuration
PROMPT="$1"
OUTPUT_FILE="$2"
NANO_BANANA_DIR="/opt/homebrew/lib/node_modules/openclaw/skills/nano-banana-pro"
LOG_FILE="/tmp/aoz_character_generation.log"

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Check prerequisites
check_prerequisites() {
    # Check Nano Banana
    if [ ! -d "$NANO_BANANA_DIR" ]; then
        log "ERROR: Nano Banana directory not found: $NANO_BANANA_DIR"
        return 1
    fi
    
    # Check ImageFX
    if ! command -v imagefx &> /dev/null; then
        log "WARNING: imagefx command not found. Install with: npm install -g @rohitaryal/imagefx-api"
        return 1
    fi
    
    # Check cookie
    if [ -z "$GOOGLE_COOKIE" ]; then
        log "WARNING: GOOGLE_COOKIE environment variable not set"
        log "ImageFX fallback will not work without cookie"
        return 1
    fi
    
    return 0
}

# Generate with Nano Banana
generate_nano_banana() {
    local prompt="$1"
    local output="$2"
    
    log "Attempting Nano Banana generation..."
    log "Prompt: $prompt"
    log "Output: $output"
    
    cd "$NANO_BANANA_DIR"
    
    # Run generation
    uv run scripts/generate_image.py \
        --prompt "$prompt" \
        --filename "$output" \
        --resolution 2K \
        --aspect-ratio "1:1" 2>&1 | tee -a "$LOG_FILE"
    
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        log "SUCCESS: Nano Banana generation completed"
        return 0
    else
        log "ERROR: Nano Banana generation failed with code $exit_code"
        return $exit_code
    fi
}

# Generate with ImageFX fallback
generate_imagefx() {
    local prompt="$1"
    local output="$2"
    local output_dir=$(dirname "$output")
    local output_name=$(basename "$output" .png)
    
    log "Falling back to ImageFX generation..."
    log "Prompt: $prompt"
    log "Output directory: $output_dir"
    
    # Create output directory if it doesn't exist
    mkdir -p "$output_dir"
    
    # Generate with ImageFX
    imagefx generate \
        --prompt "$prompt" \
        --model IMAGEN_4 \
        --size SQUARE \
        --dir "$output_dir" \
        --cookie "$GOOGLE_COOKIE" 2>&1 | tee -a "$LOG_FILE"
    
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        # ImageFX saves with generated name, find and rename
        local generated_file=$(find "$output_dir" -name "*.png" -newer "$LOG_FILE" | head -1)
        if [ -n "$generated_file" ]; then
            mv "$generated_file" "$output"
            log "SUCCESS: ImageFX generation completed and renamed to $output"
            return 0
        else
            log "ERROR: ImageFX generated file not found"
            return 1
        fi
    else
        log "ERROR: ImageFX generation failed with code $exit_code"
        return $exit_code
    fi
}

# Main generation logic
generate_character() {
    local prompt="$1"
    local output="$2"
    
    log "=== Starting character generation ==="
    log "Timestamp: $(date)"
    
    # Check prerequisites
    if ! check_prerequisites; then
        log "WARNING: Some prerequisites missing, continuing anyway..."
    fi
    
    # Try Nano Banana first
    if generate_nano_banana "$prompt" "$output"; then
        log "Character generated successfully with Nano Banana"
        return 0
    fi
    
    # Check if error is quota-related
    if grep -q "429 RESOURCE_EXHAUSTED" "$LOG_FILE" || \
       grep -q "quota exceeded" "$LOG_FILE" || \
       grep -q "API key not valid" "$LOG_FILE"; then
        log "Detected quota/authentication error, attempting ImageFX fallback..."
        
        # Wait a moment before fallback
        sleep 2
        
        if generate_imagefx "$prompt" "$output"; then
            log "Character generated successfully with ImageFX fallback"
            return 0
        else
            log "ERROR: Both Nano Banana and ImageFX failed"
            return 1
        fi
    else
        log "ERROR: Nano Banana failed with non-quota error, not attempting fallback"
        return 1
    fi
}

# Batch generation function
generate_batch() {
    local prompt_file="$1"
    local output_dir="$2"
    
    if [ ! -f "$prompt_file" ]; then
        log "ERROR: Prompt file not found: $prompt_file"
        return 1
    fi
    
    mkdir -p "$output_dir"
    
    local index=1
    while IFS= read -r prompt || [ -n "$prompt" ]; do
        # Skip empty lines and comments
        if [[ -z "$prompt" || "$prompt" =~ ^# ]]; then
            continue
        fi
        
        local output_file="${output_dir}/character_${index}.png"
        log "Generating character $index: $prompt"
        
        if ! generate_character "$prompt" "$output_file"; then
            log "WARNING: Failed to generate character $index"
        fi
        
        # Rate limiting between generations
        sleep 5
        
        ((index++))
    done < "$prompt_file"
    
    log "Batch generation completed: $((index-1)) characters attempted"
}

# Usage information
usage() {
    cat << EOF
AOZ Character Generation with Fallback

Usage:
  $0 "prompt text" output.png           # Single character
  $0 --batch prompts.txt output_dir/    # Batch generation

Options:
  --batch    Batch mode with prompt file
  --help     Show this help

Examples:
  # Single character
  $0 "anthropomorphic ape with intelligent eyes" character.png
  
  # Batch generation
  $0 --batch character_prompts.txt aoz_characters/

Prompt file format (for batch):
  # Character descriptions, one per line
  annunaki ape with advanced technology
  elder village ape with traditional markings
  young diaspora ape in urban environment

Environment variables:
  GOOGLE_COOKIE    Required for ImageFX fallback
  GEMINI_API_KEY   Required for Nano Banana (optional, uses existing)

Logs: $LOG_FILE
EOF
}

# Main script
main() {
    # Parse arguments
    if [ $# -eq 0 ]; then
        usage
        exit 1
    fi
    
    case "$1" in
        --help|-h)
            usage
            exit 0
            ;;
        --batch)
            if [ $# -lt 3 ]; then
                log "ERROR: Batch mode requires prompt file and output directory"
                usage
                exit 1
            fi
            generate_batch "$2" "$3"
            ;;
        *)
            if [ $# -lt 2 ]; then
                log "ERROR: Single mode requires prompt and output file"
                usage
                exit 1
            fi
            generate_character "$1" "$2"
            ;;
    esac
}

# Run main function
main "$@"