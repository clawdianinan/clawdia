# Payment Provider API Keys - Setup Guide
## For QA-003 Billing Validation Testing
**Date:** 2026-03-18  
**Priority:** CRITICAL - Blocks QA-003 testing

## Current Status
All payment provider credentials in `.env` and `.env.test` files are **placeholder values** (contain "LoremIpsum" text). Real test API keys are required for proper billing validation testing.

## Required Accounts & Credentials

### 1. **Stripe Test Account**
**URL:** https://dashboard.stripe.com/register  
**Email to use:** `clawdianinan@gmail.com` (Gmail for compatibility)  
**Credentials needed:**
- **Secret Key:** `sk_test_...` (starts with `sk_test_`)
- **Publishable Key:** `pk_test_...` (starts with `pk_test_`)  
- **Webhook Secret:** `whsec_...` (starts with `whsec_`)

**Steps:**
1. Register for Stripe account using Gmail
2. Go to **Developers → API Keys**
3. Copy **Publishable key** and **Secret key**
4. Go to **Developers → Webhooks**
5. Add endpoint: `https://prdforge-dev.netlify.app/api/webhooks/stripe`
6. Copy **Signing secret** (webhook secret)

### 2. **PayPal Sandbox Account**
**URL:** https://developer.paypal.com/  
**Email to use:** `clawdianinan@gmail.com`  
**Credentials needed:**
- **Client ID:** (starts with `A` for sandbox)
- **Client Secret:** (long string)

**Steps:**
1. Log in to PayPal Developer portal
2. Go to **Dashboard → My Apps & Credentials**
3. Create new REST API app (sandbox)
4. Copy **Client ID** and **Client Secret**
5. Ensure **sandbox mode** is enabled

### 3. **Paystack Test Account**
**URL:** https://dashboard.paystack.com/  
**Email to use:** `clawdianinan@gmail.com`  
**Credentials needed:**
- **Secret Key:** `sk_test_...` (starts with `sk_test_`)
- **Public Key:** `pk_test_...` (starts with `pk_test_`)

**Steps:**
1. Register for Paystack account
2. Go to **Settings → API Keys & Webhooks**
3. Copy **Test Secret Key** and **Test Public Key**
4. Enable **test mode**

### 4. **NowPayments Test Account**
**URL:** https://nowpayments.io/  
**Email to use:** `clawdianinan@gmail.com`  
**Credentials needed:**
- **API Key:** (generated in dashboard)
- **IPN Secret:** (for Instant Payment Notifications)

**Steps:**
1. Register for NowPayments account
2. Go to **Dashboard → API Settings**
3. Generate new API key
4. Copy **API Key**
5. Set up **IPN Secret** in IPN settings

## Environment Files to Update

### File 1: `/Users/clawdia/apps/prdforge/.env`
```env
# Payment Provider Configuration
STRIPE_PUBLIC_KEY="pk_test_REAL_KEY_HERE"
STRIPE_SECRET_KEY="sk_test_REAL_KEY_HERE"
STRIPE_WEBHOOK_SECRET="whsec_REAL_SECRET_HERE"
PAYPAL_CLIENT_ID="REAL_CLIENT_ID_HERE"
PAYPAL_CLIENT_SECRET="REAL_CLIENT_SECRET_HERE"
PAYPAL_MODE="sandbox"
PAYSTACK_PUBLIC_KEY="pk_test_REAL_KEY_HERE"
PAYSTACK_SECRET_KEY="sk_test_REAL_KEY_HERE"
NOWPAYMENTS_API_KEY="REAL_API_KEY_HERE"
NOWPAYMENTS_IPN_SECRET="REAL_IPN_SECRET_HERE"
```

### File 2: `/Users/clawdia/apps/prdforge/.env.test`
```env
# ── PayPal Sandbox Configuration ────────────────────────────────────────────
PAYPAL_CLIENT_ID=REAL_CLIENT_ID_HERE
PAYPAL_CLIENT_SECRET=REAL_CLIENT_SECRET_HERE
PAYPAL_MODE=sandbox

# ── Stripe Test Configuration ──────────────────────────────────────────────
STRIPE_PUBLIC_KEY=pk_test_REAL_KEY_HERE
STRIPE_SECRET_KEY=sk_test_REAL_KEY_HERE
STRIPE_WEBHOOK_SECRET=whsec_REAL_SECRET_HERE

# ── Paystack Test Configuration ────────────────────────────────────────────
PAYSTACK_PUBLIC_KEY=pk_test_REAL_KEY_HERE
PAYSTACK_SECRET_KEY=sk_test_REAL_KEY_HERE

# ── NowPayments Test Configuration ─────────────────────────────────────────
NOWPAYMENTS_API_KEY=REAL_API_KEY_HERE
NOWPAYMENTS_IPN_SECRET=REAL_IPN_SECRET_HERE
```

## Verification Steps

After obtaining credentials, verify each provider:

1. **Stripe:**
   ```bash
   curl https://api.stripe.com/v1/balance \
     -u sk_test_YOUR_REAL_KEY: \
     -H "Stripe-Version: 2023-10-16"
   ```

2. **PayPal:**
   ```bash
   curl -v https://api-m.sandbox.paypal.com/v1/oauth2/token \
     -u "CLIENT_ID:CLIENT_SECRET" \
     -H "Content-Type: application/x-www-form-urlencoded" \
     -d "grant_type=client_credentials"
   ```

3. **Paystack:**
   ```bash
   curl https://api.paystack.co/transaction/initialize \
     -H "Authorization: Bearer sk_test_YOUR_REAL_KEY" \
     -H "Content-Type: application/json" \
     -d '{"email": "test@example.com", "amount": "10000"}'
   ```

4. **NowPayments:**
   ```bash
   curl -X GET "https://api.nowpayments.io/v1/status" \
     -H "x-api-key: YOUR_REAL_API_KEY"
   ```

## Security Notes
- These are **TEST/SANDBOX** credentials only
- Never commit real credentials to version control
- Rotate keys regularly during development
- Use environment variables in production

## Next Steps
1. Create accounts on all four platforms
2. Obtain API keys and secrets
3. Update both `.env` and `.env.test` files
4. Run verification tests
5. Proceed with QA-003 billing validation

## Contact for Assistance
If account creation encounters issues (verification, 2FA, etc.), manual intervention may be required.