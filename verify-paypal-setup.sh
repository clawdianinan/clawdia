#!/bin/bash

# PayPal Setup Verification Script
# Use after credential rotation to verify everything is configured correctly

set -e

echo "🔍 PayPal Setup Verification"
echo "============================"
echo ""

# Check environment files
echo "1. Checking environment files..."
ENV_TEST_FILE="/Users/clawdia/apps/prdforge/.env.test"
ENV_FILE="/Users/clawdia/apps/prdforge/.env"

if [ ! -f "$ENV_TEST_FILE" ]; then
    echo "❌ ERROR: $ENV_TEST_FILE not found"
    exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
    echo "❌ ERROR: $ENV_FILE not found"
    exit 1
fi

echo "✅ Environment files exist"

# Check PayPal configuration in .env.test
echo ""
echo "2. Checking PayPal configuration in .env.test..."

PAYPAL_MODE=$(grep PAYPAL_MODE "$ENV_TEST_FILE" | cut -d= -f2)
PAYPAL_CLIENT_ID=$(grep PAYPAL_CLIENT_ID "$ENV_TEST_FILE" | cut -d= -f2)
PAYPAL_CLIENT_SECRET=$(grep PAYPAL_CLIENT_SECRET "$ENV_TEST_FILE" | cut -d= -f2)

if [ -z "$PAYPAL_MODE" ]; then
    echo "❌ ERROR: PAYPAL_MODE not found in .env.test"
    exit 1
fi

if [ -z "$PAYPAL_CLIENT_ID" ]; then
    echo "❌ ERROR: PAYPAL_CLIENT_ID not found in .env.test"
    exit 1
fi

if [ -z "$PAYPAL_CLIENT_SECRET" ]; then
    echo "❌ ERROR: PAYPAL_CLIENT_SECRET not found in .env.test"
    exit 1
fi

echo "✅ PayPal configuration found in .env.test"
echo "   Mode: $PAYPAL_MODE"
echo "   Client ID: ${PAYPAL_CLIENT_ID:0:20}..."
echo "   Client Secret: ${PAYPAL_CLIENT_SECRET:0:20}..."

# Verify mode is sandbox
if [ "$PAYPAL_MODE" != "sandbox" ]; then
    echo "⚠️  WARNING: PAYPAL_MODE is '$PAYPAL_MODE', should be 'sandbox' for testing"
    read -p "Continue anyway? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo "✅ Mode is 'sandbox' (correct for testing)"
fi

# Check for placeholder/lorem ipsum values
echo ""
echo "3. Checking for placeholder values..."

if echo "$PAYPAL_CLIENT_ID" | grep -qi "lorem"; then
    echo "❌ ERROR: PayPal Client ID contains 'lorem' (placeholder value)"
    exit 1
fi

if echo "$PAYPAL_CLIENT_SECRET" | grep -qi "lorem"; then
    echo "❌ ERROR: PayPal Client Secret contains 'lorem' (placeholder value)"
    exit 1
fi

if [ "$PAYPAL_CLIENT_ID" = "AVr-s5kGXqnsht9K4k30Iahz1hHjQtYxlsNhxWVSAiDaZOgWopkMG1AM64UvDx3s1Bnog30P0gqyVM6v" ]; then
    echo "⚠️  WARNING: Using the OLD production Client ID"
    echo "   These credentials should have been revoked!"
    read -p "Continue anyway? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "✅ No placeholder values detected"

# Test credentials with Node script
echo ""
echo "4. Testing PayPal credentials..."
cd /Users/clawdia/.openclaw/workspace

if [ ! -f "test-paypal-credentials.js" ]; then
    echo "❌ ERROR: test-paypal-credentials.js not found"
    exit 1
fi

echo "   Running credential test..."
node test-paypal-credentials.js

if [ $? -eq 0 ]; then
    echo "✅ PayPal credentials are VALID and working!"
else
    echo "❌ PayPal credentials test FAILED"
    echo ""
    echo "💡 Troubleshooting steps:"
    echo "   1. Check if credentials are correct"
    echo "   2. Verify PayPal account is active"
    echo "   3. Check network connectivity"
    echo "   4. Ensure credentials are for sandbox, not production"
    exit 1
fi

# Check Supabase function
echo ""
echo "5. Checking PayPal Supabase function..."

PAYPAL_FUNCTION="/Users/clawdia/apps/prdforge/supabase/functions/paypal/index.ts"
if [ ! -f "$PAYPAL_FUNCTION" ]; then
    echo "❌ ERROR: PayPal function not found at $PAYPAL_FUNCTION"
    exit 1
fi

echo "✅ PayPal function exists"
echo "   Location: $PAYPAL_FUNCTION"

# Check function size
FUNCTION_SIZE=$(wc -l < "$PAYPAL_FUNCTION")
echo "   Lines of code: $FUNCTION_SIZE"

# Check for critical functions
echo ""
echo "6. Checking for required functions in code..."

REQUIRED_FUNCTIONS=("create-order" "capture-order" "create-subscription" "webhook")
MISSING_FUNCTIONS=0

for func in "${REQUIRED_FUNCTIONS[@]}"; do
    if grep -q "action === \"$func\"" "$PAYPAL_FUNCTION"; then
        echo "✅ Function '$func' found"
    else
        echo "❌ Function '$func' NOT found"
        MISSING_FUNCTIONS=$((MISSING_FUNCTIONS + 1))
    fi
done

if [ $MISSING_FUNCTIONS -gt 0 ]; then
    echo "⚠️  WARNING: $MISSING_FUNCTIONS required functions missing"
else
    echo "✅ All required functions found"
fi

# Summary
echo ""
echo "📊 VERIFICATION SUMMARY"
echo "======================"
echo ""
echo "✅ Environment files: OK"
echo "✅ PayPal configuration: OK"
echo "✅ Credentials test: PASSED"
echo "✅ Supabase function: EXISTS"
echo ""
echo "🎉 PayPal setup verification COMPLETE!"
echo ""
echo "Next steps:"
echo "1. Set up webhooks in PayPal Developer Dashboard"
echo "2. Create sandbox test accounts"
echo "3. Run comprehensive payment tests"
echo ""
echo "To run full PayPal tests:"
echo "  cd /Users/clawdia/.openclaw/workspace"
echo "  node paypal-extensive-test.js"
echo ""
echo "Script completed successfully!"