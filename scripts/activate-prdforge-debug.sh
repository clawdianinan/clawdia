#!/bin/bash

# activate-prdforge-debug.sh
# Activate debug mode for PRDForge troubleshooting

set -e

echo "=== ACTIVATING PRDFORGE DEBUG MODE ==="
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

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if we're in the right directory
if [ ! -d "/Users/clawdia/apps/prdforge" ]; then
    print_error "PRDForge directory not found"
    echo "Expected: /Users/clawdia/apps/prdforge"
    exit 1
fi

cd /Users/clawdia/apps/prdforge

# 1. Set environment variables for Edge Functions
print_info "1. Setting Edge Function debug environment..."
if command -v supabase &> /dev/null; then
    supabase secrets set DEBUG_MODE=true 2>/dev/null && \
        print_success "Supabase DEBUG_MODE set to true" || \
        print_warning "Could not set Supabase secret (may need login)"
else
    print_warning "Supabase CLI not found, skipping environment setup"
fi

# 2. Deploy debug-enhanced Edge Function
print_info "2. Deploying debug-enhanced Edge Function..."
if [ -d "supabase/functions/prdforge-api-debug" ]; then
    supabase functions deploy prdforge-api-debug --no-verify-jwt 2>/dev/null && \
        print_success "prdforge-api-debug deployed" || \
        print_warning "Could not deploy function (may already be deployed)"
else
    print_warning "prdforge-api-debug directory not found"
fi

# 3. Create debug URL
print_info "3. Creating debug access URLs..."
DEBUG_URL="https://prdforge-dev.netlify.app?debug=true"
echo "   Frontend Debug URL: $DEBUG_URL"
echo ""

# 4. Test endpoints with debug headers
print_info "4. Testing debug endpoints..."
echo "   Testing health endpoint with debug headers:"
curl -s -H "x-debug-mode: true" \
     -H "x-debug-session: agent_$(date +%s)" \
     "https://eflrqvxmqrtbytkxyrze.supabase.co/functions/v1/prdforge-api-debug/health" | \
     jq -r '.status, .debug.mode // "No debug info"' 2>/dev/null || \
     echo "   Response received (jq not installed)"

# 5. Create agent instructions
print_info "5. Agent Debug Instructions:"
echo ""
echo "   To use debug mode:"
echo "   1. Navigate to: $DEBUG_URL"
echo "   2. Click the 🐛 button in bottom-right corner"
echo "   3. Reproduce the error"
echo "   4. Check browser console for debug logs"
echo ""
echo "   For API debugging:"
echo "   curl -H 'x-debug-mode: true' \\"
echo "        -H 'x-debug-session: agent_test' \\"
echo "        https://eflrqvxmqrtbytkxyrze.supabase.co/functions/v1/prdforge-api-debug/generate"
echo ""

# 6. Create debug session file
SESSION_ID="debug_session_$(date +%Y%m%d_%H%M%S)"
cat > "/tmp/prdforge_debug_${SESSION_ID}.md" << EOF
# PRDForge Debug Session - ${SESSION_ID}

## Activation Details
- **Timestamp:** $(date)
- **Agent:** $(whoami)
- **Session ID:** ${SESSION_ID}

## Environment
- **DEBUG_MODE:** true
- **Frontend URL:** ${DEBUG_URL}
- **API Endpoint:** https://eflrqvxmqrtbytkxyrze.supabase.co/functions/v1/prdforge-api-debug

## Test Commands
\`\`\`bash
# Test health endpoint
curl -H "x-debug-mode: true" \\
     -H "x-debug-session: ${SESSION_ID}" \\
     "https://eflrqvxmqrtbytkxyrze.supabase.co/functions/v1/prdforge-api-debug/health"

# Test generation endpoint
curl -X POST \\
     -H "x-debug-mode: true" \\
     -H "x-debug-session: ${SESSION_ID}" \\
     -H "Content-Type: application/json" \\
     -d '{"prompt": "Test prompt", "projectId": "test", "userId": "test"}' \\
     "https://eflrqvxmqrtbytkxyrze.supabase.co/functions/v1/prdforge-api-debug/generate"
\`\`\`

## Notes
- Debug mode exposes detailed error information
- Use only for troubleshooting
- Disable when done
EOF

print_success "Debug session file created: /tmp/prdforge_debug_${SESSION_ID}.md"

# 7. Final instructions
print_info "6. Next Steps:"
echo ""
echo "   To troubleshoot the 'Edge function returned a non-2xx status code' error:"
echo "   1. Enable debug mode on the frontend"
echo "   2. Attempt to generate from prompt"
echo "   3. Check browser console for detailed error"
echo "   4. Use the debug-enhanced API endpoint"
echo ""
echo "   To deactivate debug mode:"
echo "   ./scripts/deactivate-prdforge-debug.sh"
echo ""

print_success "✅ PRDForge debug mode activated!"
echo "   Session: ${SESSION_ID}"
echo "   URL: ${DEBUG_URL}"
echo "   Duration: Until manually deactivated"