#!/bin/bash

# Quick verification script for payment provider credentials
# Usage: ./verify-payment-credentials.sh

set -e

echo "🔍 Verifying payment provider credentials"
echo "=========================================="

# Load environment variables from .env.test
ENV_FILE="/Users/clawdia/apps/prdforge/.env.test"
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Error: $ENV_FILE not found"
    exit 1
fi

# Export variables from .env.test
export $(grep -v '^#' "$ENV_FILE" | xargs)

echo "✅ Loaded environment variables from $ENV_FILE"
echo ""

# Function to test credential
test_credential() {
    local name=$1
    local value=$2
    local test_type=$3
    
    echo "Testing $name..."
    if [ -z "$value" ]; then
        echo "  ❌ EMPTY - No value set"
        return 1
    fi
    
    case $test_type in
        "stripe")
            if [[ "$value" == *"LoremIpsum"* ]]; then
                echo "  ❌ PLACEHOLDER - Contains 'LoremIpsum'"
                return 1
            elif [[ "$value" == sk_test_* ]]; then
                echo "  ✅ VALID - Stripe test key pattern"
                return 0
            else
                echo "  ⚠️  UNUSUAL - Doesn't match expected pattern"
                return 2
            fi
            ;;
        "paypal")
            if [[ "$value" == *"LoremIpsum"* ]]; then
                echo "  ❌ PLACEHOLDER - Contains 'LoremIpsum'"
                return 1
            elif [[ "$value" == A* ]] && [ ${#value} -gt 50 ]; then
                echo "  ✅ VALID - PayPal sandbox client ID pattern"
                return 0
            else
                echo "  ⚠️  UNUSUAL - Doesn't match expected pattern"
                return 2
            fi
            ;;
        "paystack")
            if [[ "$value" == *"LoremIpsum"* ]]; then
                echo "  ❌ PLACEHOLDER - Contains 'LoremIpsum'"
                return 1
            elif [[ "$value" == pk_test_* ]] || [[ "$value" == sk_test_* ]]; then
                echo "  ✅ VALID - Paystack test key pattern"
                return 0
            else
                echo "  ⚠️  UNUSUAL - Doesn't match expected pattern"
                return 2
            fi
            ;;
        "nowpayments")
            if [[ "$value" == *"LoremIpsum"* ]]; then
                echo "  ❌ PLACEHOLDER - Contains 'LoremIpsum'"
                return 1
            elif [ ${#value} -gt 20 ]; then
                echo "  ✅ VALID - NowPayments API key pattern (length OK)"
                return 0
            else
                echo "  ⚠️  UNUSUAL - Too short for API key"
                return 2
            fi
            ;;
        *)
            echo "  ⚠️  UNKNOWN - No validation pattern"
            return 2
            ;;
    esac
}

# Test all credentials
echo "📋 Credential Validation Results:"
echo "--------------------------------"

FAILURES=0
WARNINGS=0

test_credential "STRIPE_PUBLIC_KEY" "$STRIPE_PUBLIC_KEY" "stripe"
[ $? -eq 1 ] && ((FAILURES++)) || [ $? -eq 2 ] && ((WARNINGS++))

test_credential "STRIPE_SECRET_KEY" "$STRIPE_SECRET_KEY" "stripe"
[ $? -eq 1 ] && ((FAILURES++)) || [ $? -eq 2 ] && ((WARNINGS++))

test_credential "STRIPE_WEBHOOK_SECRET" "$STRIPE_WEBHOOK_SECRET" "nowpayments"
[ $? -eq 1 ] && ((FAILURES++)) || [ $? -eq 2 ] && ((WARNINGS++))

test_credential "PAYPAL_CLIENT_ID" "$PAYPAL_CLIENT_ID" "paypal"
[ $? -eq 1 ] && ((FAILURES++)) || [ $? -eq 2 ] && ((WARNINGS++))

test_credential "PAYPAL_CLIENT_SECRET" "$PAYPAL_CLIENT_SECRET" "nowpayments"
[ $? -eq 1 ] && ((FAILURES++)) || [ $? -eq 2 ] && ((WARNINGS++))

test_credential "PAYSTACK_PUBLIC_KEY" "$PAYSTACK_PUBLIC_KEY" "paystack"
[ $? -eq 1 ] && ((FAILURES++)) || [ $? -eq 2 ] && ((WARNINGS++))

test_credential "PAYSTACK_SECRET_KEY" "$PAYSTACK_SECRET_KEY" "paystack"
[ $? -eq 1 ] && ((FAILURES++)) || [ $? -eq 2 ] && ((WARNINGS++))

test_credential "NOWPAYMENTS_API_KEY" "$NOWPAYMENTS_API_KEY" "nowpayments"
[ $? -eq 1 ] && ((FAILURES++)) || [ $? -eq 2 ] && ((WARNINGS++))

test_credential "NOWPAYMENTS_IPN_SECRET" "$NOWPAYMENTS_IPN_SECRET" "nowpayments"
[ $? -eq 1 ] && ((FAILURES++)) || [ $? -eq 2 ] && ((WARNINGS++))

echo ""
echo "📊 Summary:"
echo "--------------------------------"
echo "Total credentials: 9"
echo "✅ Valid patterns: $((9 - FAILURES - WARNINGS))"
echo "⚠️  Warnings: $WARNINGS"
echo "❌ Failures: $FAILURES"

if [ $FAILURES -gt 0 ]; then
    echo ""
    echo "🚨 CRITICAL: $FAILURES credentials are placeholders or empty!"
    echo "   QA-003 billing validation tests will fail."
    echo "   Run ./update-payment-credentials.sh to fix."
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo ""
    echo "⚠️  WARNING: $WARNINGS credentials have unusual patterns"
    echo "   Consider verifying these credentials manually."
    exit 0
else
    echo ""
    echo "✅ All credentials appear to be valid test keys!"
    echo "   Proceed with QA-003 billing validation testing."
    exit 0
fi