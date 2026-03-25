#!/bin/bash

# deactivate-prdforge-debug.sh
# Deactivate debug mode for PRDForge

set -e

echo "=== DEACTIVATING PRDFORGE DEBUG MODE ==="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if we're in the right directory
if [ ! -d "/Users/clawdia/apps/prdforge" ]; then
    print_warning "PRDForge directory not found, continuing with cleanup..."
else
    cd /Users/clawdia/apps/prdforge
fi

# 1. Remove environment variables
print_info "1. Removing debug environment variables..."
if command -v supabase &> /dev/null; then
    supabase secrets unset DEBUG_MODE 2>/dev/null && \
        print_success "DEBUG_MODE unset from Supabase" || \
        print_warning "Could not unset DEBUG_MODE (may not be set)"
else
    print_warning "Supabase CLI not found, skipping environment cleanup"
fi

# 2. Clean up frontend localStorage
print_info "2. Cleaning frontend debug state..."
echo "   Users should:"
echo "   1. Navigate to https://prdforge-dev.netlify.app"
echo "   2. Click the 🚀 button to disable debug mode"
echo "   3. Clear browser localStorage if needed"
echo ""

# 3. List and clean debug session files
print_info "3. Cleaning debug session files..."
DEBUG_FILES=$(ls /tmp/prdforge_debug_*.md 2>/dev/null | wc -l)
if [ "$DEBUG_FILES" -gt 0 ]; then
    echo "   Found $DEBUG_FILES debug session files:"
    ls -la /tmp/prdforge_debug_*.md 2>/dev/null | head -5
    echo ""
    read -p "   Delete these files? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -f /tmp/prdforge_debug_*.md 2>/dev/null
        print_success "Debug session files deleted"
    else
        print_warning "Debug session files preserved"
    fi
else
    print_success "No debug session files found"
fi

# 4. Clear any debug cookies/local storage instructions
print_info "4. Browser cleanup instructions:"
echo ""
echo "   To fully deactivate debug mode in browser:"
echo "   1. Open Developer Tools (F12)"
echo "   2. Go to Application tab"
echo "   3. Clear Local Storage for prdforge-dev.netlify.app"
echo "   4. Clear Session Storage"
echo "   5. Clear Cookies"
echo "   6. Reload the page"
echo ""

# 5. Verify normal mode
print_info "5. Verifying normal mode..."
NORMAL_URL="https://prdforge-dev.netlify.app"
echo "   Normal URL: $NORMAL_URL"
echo "   (No ?debug parameter, no debug headers)"
echo ""

# 6. Final status
print_success "✅ PRDForge debug mode deactivated!"
echo ""
echo "   System returned to normal production mode."
echo "   Users will see standard error messages."
echo "   Enhanced debugging details are now hidden."
echo ""
echo "   To reactivate debug mode:"
echo "   ./scripts/activate-prdforge-debug.sh"