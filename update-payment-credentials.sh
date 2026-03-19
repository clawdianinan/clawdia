#!/bin/bash

# Script to update payment provider credentials in PRDForge environment files
# Usage: ./update-payment-credentials.sh

set -e

ENV_FILE="/Users/clawdia/apps/prdforge/.env"
ENV_TEST_FILE="/Users/clawdia/apps/prdforge/.env.test"

echo "🔄 Updating payment provider credentials for PRDForge QA-003 testing"
echo "================================================================"

# Check if files exist
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Error: $ENV_FILE not found"
    exit 1
fi

if [ ! -f "$ENV_TEST_FILE" ]; then
    echo "❌ Error: $ENV_TEST_FILE not found"
    exit 1
fi

# Backup original files
BACKUP_DIR="/tmp/prdforge-env-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp "$ENV_FILE" "$BACKUP_DIR/.env.backup"
cp "$ENV_TEST_FILE" "$BACKUP_DIR/.env.test.backup"
echo "✅ Backups created in: $BACKUP_DIR"

# Function to prompt for credential
prompt_credential() {
    local name=$1
    local description=$2
    local current_value=$3
    
    echo ""
    echo "🔧 $name"
    echo "   Description: $description"
    echo "   Current value: $current_value"
    read -p "   Enter new value (or press Enter to keep current): " new_value
    
    if [ -n "$new_value" ]; then
        echo "$new_value"
    else
        echo "$current_value"
    fi
}

echo ""
echo "📝 Enter payment provider credentials (test/sandbox keys only)"
echo "================================================================"

# Collect credentials
STRIPE_PUBLIC_KEY=$(prompt_credential "Stripe Public Key" "pk_test_..." "pk_test_51QaAbCLoremIpsumDolorSitAmetConsectetur")
STRIPE_SECRET_KEY=$(prompt_credential "Stripe Secret Key" "sk_test_..." "sk_test_51QaAbCLoremIpsumDolorSitAmetConsecteturAdipiscing")
STRIPE_WEBHOOK_SECRET=$(prompt_credential "Stripe Webhook Secret" "whsec_..." "whsec_LoremIpsumDolorSitAmetConsecteturAdipiscingElit")
PAYPAL_CLIENT_ID=$(prompt_credential "PayPal Client ID" "Starts with A..." "AVr-s5kGXqnsht9K4k30Iahz1hHjQtYxlsNhxWVSAiDaZOgWopkMG1AM64UvDx3s1Bnog30P0gqyVM6v")
PAYPAL_CLIENT_SECRET=$(prompt_credential "PayPal Client Secret" "Long string..." "EN3dcrJt-LNpWEt1LbDxsO8O5m5UNJoALZht5w3HA0JXA_j5VY9TJv7HVPtsz6Tj3uV-joudQBT6rT5p")
PAYSTACK_PUBLIC_KEY=$(prompt_credential "Paystack Public Key" "pk_test_..." "pk_test_loremipsumdolorsitametconsecteturadipiscingelit")
PAYSTACK_SECRET_KEY=$(prompt_credential "Paystack Secret Key" "sk_test_..." "sk_test_loremipsumdolorsitametconsecteturadipiscingelit")
NOWPAYMENTS_API_KEY=$(prompt_credential "NowPayments API Key" "Generated key..." "np_test_loremipsumdolorsitametconsecteturadipiscingelit")
NOWPAYMENTS_IPN_SECRET=$(prompt_credential "NowPayments IPN Secret" "IPN secret..." "np_ipn_test_loremipsumdolorsitametconsecteturadipiscing")

echo ""
echo "📋 Summary of changes:"
echo "================================================================"
echo "Stripe Public Key: ${STRIPE_PUBLIC_KEY:0:20}..."
echo "Stripe Secret Key: ${STRIPE_SECRET_KEY:0:20}..."
echo "PayPal Client ID: ${PAYPAL_CLIENT_ID:0:20}..."
echo "Paystack Public Key: ${PAYSTACK_PUBLIC_KEY:0:20}..."
echo "NowPayments API Key: ${NOWPAYMENTS_API_KEY:0:20}..."

read -p "✅ Apply these changes? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "❌ Update cancelled. Original files preserved."
    exit 0
fi

# Update .env file
echo ""
echo "🔄 Updating $ENV_FILE..."
sed -i '' "s|STRIPE_PUBLIC_KEY=.*|STRIPE_PUBLIC_KEY=\"$STRIPE_PUBLIC_KEY\"|" "$ENV_FILE"
sed -i '' "s|STRIPE_SECRET_KEY=.*|STRIPE_SECRET_KEY=\"$STRIPE_SECRET_KEY\"|" "$ENV_FILE"
sed -i '' "s|STRIPE_WEBHOOK_SECRET=.*|STRIPE_WEBHOOK_SECRET=\"$STRIPE_WEBHOOK_SECRET\"|" "$ENV_FILE"
sed -i '' "s|PAYPAL_CLIENT_ID=.*|PAYPAL_CLIENT_ID=\"$PAYPAL_CLIENT_ID\"|" "$ENV_FILE"
sed -i '' "s|PAYPAL_CLIENT_SECRET=.*|PAYPAL_CLIENT_SECRET=\"$PAYPAL_CLIENT_SECRET\"|" "$ENV_FILE"
sed -i '' "s|PAYSTACK_PUBLIC_KEY=.*|PAYSTACK_PUBLIC_KEY=\"$PAYSTACK_PUBLIC_KEY\"|" "$ENV_FILE"
sed -i '' "s|PAYSTACK_SECRET_KEY=.*|PAYSTACK_SECRET_KEY=\"$PAYSTACK_SECRET_KEY\"|" "$ENV_FILE"
sed -i '' "s|NOWPAYMENTS_API_KEY=.*|NOWPAYMENTS_API_KEY=\"$NOWPAYMENTS_API_KEY\"|" "$ENV_FILE"
sed -i '' "s|NOWPAYMENTS_IPN_SECRET=.*|NOWPAYMENTS_IPN_SECRET=\"$NOWPAYMENTS_IPN_SECRET\"|" "$ENV_FILE"

# Remove placeholder warnings from .env (keep them clean for actual credentials)
sed -i '' '/# ⚠️ PLACEHOLDER VALUES - REAL TEST API KEYS REQUIRED FOR QA-003 BILLING VALIDATION/d' "$ENV_FILE"
sed -i '' '/# See: \/Users\/clawdia\/.openclaw\/workspace\/payment-api-keys-guide.md for setup instructions/d' "$ENV_FILE"

# Update .env.test file
echo "🔄 Updating $ENV_TEST_FILE..."
sed -i '' "s|PAYPAL_CLIENT_ID=.*|PAYPAL_CLIENT_ID=$PAYPAL_CLIENT_ID|" "$ENV_TEST_FILE"
sed -i '' "s|PAYPAL_CLIENT_SECRET=.*|PAYPAL_CLIENT_SECRET=$PAYPAL_CLIENT_SECRET|" "$ENV_TEST_FILE"
sed -i '' "s|STRIPE_PUBLIC_KEY=.*|STRIPE_PUBLIC_KEY=$STRIPE_PUBLIC_KEY|" "$ENV_TEST_FILE"
sed -i '' "s|STRIPE_SECRET_KEY=.*|STRIPE_SECRET_KEY=$STRIPE_SECRET_KEY|" "$ENV_TEST_FILE"
sed -i '' "s|STRIPE_WEBHOOK_SECRET=.*|STRIPE_WEBHOOK_SECRET=$STRIPE_WEBHOOK_SECRET|" "$ENV_TEST_FILE"
sed -i '' "s|PAYSTACK_PUBLIC_KEY=.*|PAYSTACK_PUBLIC_KEY=$PAYSTACK_PUBLIC_KEY|" "$ENV_TEST_FILE"
sed -i '' "s|PAYSTACK_SECRET_KEY=.*|PAYSTACK_SECRET_KEY=$PAYSTACK_SECRET_KEY|" "$ENV_TEST_FILE"
sed -i '' "s|NOWPAYMENTS_API_KEY=.*|NOWPAYMENTS_API_KEY=$NOWPAYMENTS_API_KEY|" "$ENV_TEST_FILE"
sed -i '' "s|NOWPAYMENTS_IPN_SECRET=.*|NOWPAYMENTS_IPN_SECRET=$NOWPAYMENTS_IPN_SECRET|" "$ENV_TEST_FILE"

# Remove placeholder warnings from .env.test
sed -i '' '/# ⚠️ PLACEHOLDER VALUES - REAL TEST API KEYS REQUIRED FOR QA-003 BILLING VALIDATION/d' "$ENV_TEST_FILE"

echo ""
echo "✅ Update complete!"
echo ""
echo "📋 Next steps:"
echo "1. Run verification tests to confirm credentials work:"
echo "   cd /Users/clawdia/apps/prdforge"
echo "   node scripts/safety-controls.js run"
echo ""
echo "2. Proceed with QA-003 billing validation testing"
echo ""
echo "3. If credentials don't work, restore from backup:"
echo "   cp $BACKUP_DIR/.env.backup $ENV_FILE"
echo "   cp $BACKUP_DIR/.env.test.backup $ENV_TEST_FILE"
echo ""
echo "🔒 Remember: These are TEST credentials. Never commit to version control!"