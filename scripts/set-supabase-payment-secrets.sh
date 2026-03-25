#!/bin/bash

# Script to set payment credentials as Supabase secrets
# Run this after deploying Edge Functions

set -e

echo "=== SETTING SUPABASE PAYMENT SECRETS ==="
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

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if supabase CLI is available
if ! command -v supabase &> /dev/null; then
    print_error "Supabase CLI not found. Please install it first."
    exit 1
fi

# Check if we're in the PRDForge directory
if [ ! -f "/Users/clawdia/apps/prdforge/.env" ]; then
    print_error "Not in PRDForge directory or .env not found"
    exit 1
fi

cd /Users/clawdia/apps/prdforge

# Read credentials from backup file (created during CYPHER audit)
BACKUP_FILE=$(ls -t /Users/clawdia/apps/prdforge/.env.backup.cypher-audit-* 2>/dev/null | head -1)

if [ -z "$BACKUP_FILE" ]; then
    print_warning "No CYPHER audit backup file found. Using current .env if available."
    BACKUP_FILE="/Users/clawdia/apps/prdforge/.env"
fi

print_info "Reading credentials from: $BACKUP_FILE"

# Extract payment credentials
PAYPAL_CLIENT_ID=$(grep "^PAYPAL_CLIENT_ID=" "$BACKUP_FILE" | cut -d= -f2-)
PAYPAL_CLIENT_SECRET=$(grep "^PAYPAL_CLIENT_SECRET=" "$BACKUP_FILE" | cut -d= -f2-)
PAYPAL_MODE=$(grep "^PAYPAL_MODE=" "$BACKUP_FILE" | cut -d= -f2-)
STRIPE_SECRET_KEY=$(grep "^STRIPE_SECRET_KEY=" "$BACKUP_FILE" | cut -d= -f2-)
STRIPE_WEBHOOK_SECRET=$(grep "^STRIPE_WEBHOOK_SECRET=" "$BACKUP_FILE" | cut -d= -f2-)
PAYSTACK_SECRET_KEY=$(grep "^PAYSTACK_SECRET_KEY=" "$BACKUP_FILE" | cut -d= -f2-)
NOWPAYMENTS_API_KEY=$(grep "^NOWPAYMENTS_API_KEY=" "$BACKUP_FILE" | cut -d= -f2-)
NOWPAYMENTS_IPN_SECRET=$(grep "^NOWPAYMENTS_IPN_SECRET=" "$BACKUP_FILE" | cut -d= -f2-)
PAYMENT_MODE=$(grep "^PAYMENT_MODE=" "$BACKUP_FILE" | cut -d= -f2-)

# Check if credentials are placeholder/test values
check_if_placeholder() {
    local value="$1"
    if [[ "$value" == *"LoremIpsum"* ]] || [[ "$value" == *"loremipsum"* ]] || [[ "$value" == *"test_"* ]] || [[ "$value" == *"mock"* ]]; then
        return 0  # Is placeholder
    else
        return 1  # Is real credential
    fi
}

print_info "Setting Supabase secrets..."

# Set each secret if not empty and not placeholder
if [ -n "$PAYPAL_CLIENT_ID" ] && ! check_if_placeholder "$PAYPAL_CLIENT_ID"; then
    supabase secrets set PAYPAL_CLIENT_ID="$PAYPAL_CLIENT_ID" && \
        print_success "PAYPAL_CLIENT_ID set" || \
        print_warning "Failed to set PAYPAL_CLIENT_ID"
else
    print_warning "PAYPAL_CLIENT_ID is empty or placeholder, skipping"
fi

if [ -n "$PAYPAL_CLIENT_SECRET" ] && ! check_if_placeholder "$PAYPAL_CLIENT_SECRET"; then
    supabase secrets set PAYPAL_CLIENT_SECRET="$PAYPAL_CLIENT_SECRET" && \
        print_success "PAYPAL_CLIENT_SECRET set" || \
        print_warning "Failed to set PAYPAL_CLIENT_SECRET"
else
    print_warning "PAYPAL_CLIENT_SECRET is empty or placeholder, skipping"
fi

if [ -n "$PAYPAL_MODE" ]; then
    supabase secrets set PAYPAL_MODE="$PAYPAL_MODE" && \
        print_success "PAYPAL_MODE set to $PAYPAL_MODE" || \
        print_warning "Failed to set PAYPAL_MODE"
fi

if [ -n "$STRIPE_SECRET_KEY" ] && ! check_if_placeholder "$STRIPE_SECRET_KEY"; then
    supabase secrets set STRIPE_SECRET_KEY="$STRIPE_SECRET_KEY" && \
        print_success "STRIPE_SECRET_KEY set" || \
        print_warning "Failed to set STRIPE_SECRET_KEY"
else
    print_warning "STRIPE_SECRET_KEY is empty or placeholder, skipping"
fi

if [ -n "$STRIPE_WEBHOOK_SECRET" ] && ! check_if_placeholder "$STRIPE_WEBHOOK_SECRET"; then
    supabase secrets set STRIPE_WEBHOOK_SECRET="$STRIPE_WEBHOOK_SECRET" && \
        print_success "STRIPE_WEBHOOK_SECRET set" || \
        print_warning "Failed to set STRIPE_WEBHOOK_SECRET"
else
    print_warning "STRIPE_WEBHOOK_SECRET is empty or placeholder, skipping"
fi

if [ -n "$PAYSTACK_SECRET_KEY" ] && ! check_if_placeholder "$PAYSTACK_SECRET_KEY"; then
    supabase secrets set PAYSTACK_SECRET_KEY="$PAYSTACK_SECRET_KEY" && \
        print_success "PAYSTACK_SECRET_KEY set" || \
        print_warning "Failed to set PAYSTACK_SECRET_KEY"
else
    print_warning "PAYSTACK_SECRET_KEY is empty or placeholder, skipping"
fi

if [ -n "$NOWPAYMENTS_API_KEY" ] && ! check_if_placeholder "$NOWPAYMENTS_API_KEY"; then
    supabase secrets set NOWPAYMENTS_API_KEY="$NOWPAYMENTS_API_KEY" && \
        print_success "NOWPAYMENTS_API_KEY set" || \
        print_warning "Failed to set NOWPAYMENTS_API_KEY"
else
    print_warning "NOWPAYMENTS_API_KEY is empty or placeholder, skipping"
fi

if [ -n "$NOWPAYMENTS_IPN_SECRET" ] && ! check_if_placeholder "$NOWPAYMENTS_IPN_SECRET"; then
    supabase secrets set NOWPAYMENTS_IPN_SECRET="$NOWPAYMENTS_IPN_SECRET" && \
        print_success "NOWPAYMENTS_IPN_SECRET set" || \
        print_warning "Failed to set NOWPAYMENTS_IPN_SECRET"
else
    print_warning "NOWPAYMENTS_IPN_SECRET is empty or placeholder, skipping"
fi

if [ -n "$PAYMENT_MODE" ]; then
    supabase secrets set PAYMENT_MODE="$PAYMENT_MODE" && \
        print_success "PAYMENT_MODE set to $PAYMENT_MODE" || \
        print_warning "Failed to set PAYMENT_MODE"
fi

echo ""
print_info "Summary of secrets set:"
supabase secrets list 2>/dev/null | grep -E "(PAYPAL|STRIPE|PAYSTACK|NOWPAYMENTS|PAYMENT_MODE)" || \
    print_warning "Could not list secrets (may need Docker running)"

echo ""
print_success "Payment credentials moved to Supabase secrets!"
echo ""
echo "Next steps:"
echo "1. Deploy Edge Functions: supabase functions deploy"
echo "2. Test payment functionality"
echo "3. Verify .env file no longer contains payment credentials"
echo "4. Update Jira ticket DEV-31 with completion status"