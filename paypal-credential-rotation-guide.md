# PayPal Credential Rotation Guide
## For PRDForge QA-003 Testing
**Date:** 2026-03-18  
**Priority:** CRITICAL - Immediate Action Required

---

## 🚨 URGENT: PRODUCTION CREDENTIALS EXPOSED

### Current Situation:
- **Production PayPal credentials** are in `.env.test` file
- **Credentials are active** and working in production environment
- **Security risk:** Real financial transactions possible
- **Compliance violation:** PCI-DSS requirements not met

### Immediate Actions Required:

#### Step 1: Revoke Current Production Credentials
**Time:** IMMEDIATELY (Right Now)

1. **Log in to PayPal Developer Dashboard:**
   - URL: https://developer.paypal.com/
   - Use the account that owns the credentials

2. **Navigate to Credentials:**
   - Go to **Dashboard → My Apps & Credentials**
   - Find the app with Client ID: `AVr-s5kGXqnsht9K4k30Iahz1hHjQtYxlsNhxWVSAiDaZOgWopkMG1AM64UvDx3s1Bnog30P0gqyVM6v`

3. **Revoke Credentials:**
   - Click on the app
   - Click **"Remove"** or **"Delete"** button
   - Confirm deletion

4. **Verify Revocation:**
   - Try to use the credentials (they should fail)
   - Check PayPal account for any unauthorized transactions

#### Step 2: Create New Sandbox Credentials
**Time:** After Step 1 (15-30 minutes)

1. **Create Sandbox App:**
   - In PayPal Developer Dashboard
   - Click **"Create App"** button
   - Select **"REST API app"**
   - Choose **"Sandbox"** environment

2. **Configure App:**
   - **App Name:** `PRDForge Sandbox Testing`
   - **Sandbox Business Account:** Select existing or create new
   - Click **"Create App"**

3. **Copy Credentials:**
   - **Client ID:** Copy the new sandbox Client ID
   - **Client Secret:** Click **"Show"** and copy the secret
   - **Note:** Sandbox credentials start differently than production

#### Step 3: Update Environment Files
**Time:** After Step 2 (5 minutes)

1. **Update `.env.test` file:**
   ```bash
   cd /Users/clawdia/apps/prdforge
   nano .env.test
   ```

2. **Replace PayPal section:**
   ```env
   # ── PayPal Sandbox Configuration ────────────────────────────────────────────
   PAYPAL_CLIENT_ID=NEW_SANDBOX_CLIENT_ID_HERE
   PAYPAL_CLIENT_SECRET=NEW_SANDBOX_CLIENT_SECRET_HERE
   PAYPAL_MODE=sandbox
   ```

3. **Update `.env` file (if needed):**
   ```bash
   nano .env
   ```
   ```env
   PAYPAL_CLIENT_ID="NEW_SANDBOX_CLIENT_ID_HERE"
   PAYPAL_CLIENT_SECRET="NEW_SANDBOX_CLIENT_SECRET_HERE"
   PAYPAL_MODE="sandbox"
   ```

#### Step 4: Verify New Credentials
**Time:** After Step 3 (5 minutes)

Run verification test:
```bash
cd /Users/clawdia/.openclaw/workspace
node test-paypal-credentials.js
```

**Expected Result:** ✅ "Sandbox credentials are VALID and working!"

---

## SANDBOX TEST ACCOUNT SETUP

### Required Test Accounts:

#### 1. Sandbox Business Account (Seller)
- **Purpose:** Receives payments in sandbox
- **Setup:** Automatically created with app
- **Email:** `prdforge-sandbox-business@example.com` (example)
- **Password:** Set during creation

#### 2. Sandbox Personal Account (Buyer)
- **Purpose:** Makes test payments
- **Setup:** Manual creation required

**Steps to create:**
1. PayPal Developer Dashboard → **Sandbox → Accounts**
2. Click **"Create Account"**
3. Select **"Personal"** account type
4. Fill in test details:
   - **Email:** `prdforge-test-buyer@example.com`
   - **Password:** `TestPassword123!`
   - **Country:** United States
5. Click **"Create Account"**

#### 3. Test Funding Sources
**Sandbox provides test cards automatically:**

**Credit Cards:**
- **Visa:** `4032034813351885` (generic sandbox card)
- **Mastercard:** `5102421030503021` (generic sandbox card)
- **Amex:** `378282246310005` (generic sandbox card)

**Always Declined Cards:**
- `4716396246980225` (always declined)
- `4007400000000007` (requires 3D Secure)

**Bank Accounts:** (if needed for testing)
- Sandbox provides test bank accounts

---

## WEBHOOK CONFIGURATION

### Required for QA-003 Testing:

#### Webhook URL:
```
https://jnlkzcmeiksqljnbtfhb.supabase.co/functions/v1/paypal/webhook
```

#### Events to Subscribe:
1. **PAYMENT.CAPTURE.COMPLETED** - Successful payment
2. **PAYMENT.CAPTURE.DENIED** - Failed payment
3. **PAYMENT.CAPTURE.REFUNDED** - Refund processed
4. **BILLING.SUBSCRIPTION.ACTIVATED** - Subscription started
5. **BILLING.SUBSCRIPTION.CANCELLED** - Subscription cancelled

#### Setup Steps:
1. PayPal Developer Dashboard → **My Apps & Credentials**
2. Select your sandbox app
3. Click **"Add Webhook"**
4. Enter the webhook URL
5. Select the events listed above
6. Click **"Save"**

#### Verification:
1. PayPal will send a verification webhook
2. PRDForge needs to handle `WEBHOOKS.PAYLOAD.VERIFICATION`
3. Verify webhook signature in code

---

## TESTING CHECKLIST

### Phase 1: Credential Setup ✅
- [ ] Production credentials revoked
- [ ] Sandbox app created
- [ ] Environment files updated
- [ ] Credentials verified working

### Phase 2: Account Setup ✅
- [ ] Business account configured
- [ ] Personal/buyer account created
- [ ] Test funding sources available

### Phase 3: Webhook Setup ✅
- [ ] Webhook URL configured
- [ ] Events subscribed
- [ ] Webhook verification working

### Phase 4: Basic Testing ✅
- [ ] Access token acquisition
- [ ] Order creation
- [ ] Order capture
- [ ] Error scenarios

### Phase 5: Advanced Testing ✅
- [ ] Refund flow
- [ ] Subscription management
- [ ] Credit top-up
- [ ] Webhook event processing

---

## TROUBLESHOOTING

### Common Issues:

#### 1. "Invalid Client" Error
**Cause:** Credentials incorrect or revoked
**Solution:**
- Verify Client ID and Secret are correct
- Check if credentials are for sandbox, not production
- Ensure no extra spaces or characters

#### 2. Webhook Not Delivered
**Cause:** URL incorrect or not accessible
**Solution:**
- Verify webhook URL is correct
- Check Supabase function is deployed
- Test URL accessibility with curl

#### 3. Sandbox Payments Not Working
**Cause:** Test accounts not properly funded
**Solution:**
- Log in to sandbox buyer account
- Add test credit card
- Verify sufficient balance

#### 4. 3D Secure Required
**Cause:** Using test card that requires authentication
**Solution:**
- Use generic sandbox card: `4032034813351885`
- Or handle 3D Secure flow in testing

---

## SECURITY BEST PRACTICES

### For Sandbox Testing:
1. **Never use production credentials** in test environment
2. **Rotate sandbox credentials** periodically
3. **Use separate accounts** for different environments
4. **Monitor sandbox transactions** for anomalies

### For Production:
1. **Use environment variables** (never hardcode)
2. **Implement credential rotation** (every 90 days)
3. **Use PayPal's IPN/Webhook signatures**
4. **Follow PCI-DSS compliance guidelines**

### Code Security:
```typescript
// GOOD: Read from environment
const clientId = Deno.env.get("PAYPAL_CLIENT_ID");

// BAD: Hardcoded credentials
const clientId = "AVr-s5kGXq...";
```

---

## AUTOMATION SCRIPTS

### Credential Verification Script:
```bash
#!/bin/bash
# verify-paypal-credentials.sh

echo "🔍 Verifying PayPal credentials..."
cd /Users/clawdia/apps/prdforge

# Check if credentials are sandbox
if grep -q "PAYPAL_MODE=sandbox" .env.test; then
    echo "✅ Mode: sandbox"
else
    echo "❌ ERROR: Not in sandbox mode!"
    exit 1
fi

# Check credential format
CLIENT_ID=$(grep PAYPAL_CLIENT_ID .env.test | cut -d= -f2)
if [[ $CLIENT_ID == A* ]]; then
    echo "✅ Client ID format looks correct"
else
    echo "⚠️  Warning: Client ID format unexpected"
fi

echo "📋 Verification complete"
```

### Test Execution Script:
```bash
#!/bin/bash
# run-paypal-tests.sh

echo "🚀 Running PayPal tests..."
cd /Users/clawdia/.openclaw/workspace

# Run credential test
echo "1. Testing credentials..."
node test-paypal-credentials.js

if [ $? -eq 0 ]; then
    echo "✅ Credentials valid, running full tests..."
    node paypal-extensive-test.js
else
    echo "❌ Credentials invalid, stopping tests"
    exit 1
fi
```

---

## SUPPORT RESOURCES

### PayPal Developer Documentation:
- [Sandbox Testing Guide](https://developer.paypal.com/docs/api-basics/sandbox/)
- [Webhook Setup](https://developer.paypal.com/docs/api/webhooks/)
- [REST API Reference](https://developer.paypal.com/docs/api/overview/)

### PRDForge Resources:
- Payment integration code: `/supabase/functions/paypal/`
- Test scripts: `/Users/clawdia/.openclaw/workspace/`
- Documentation: `payment-api-keys-guide.md`

### Contact for Help:
- **PayPal Support:** https://www.paypal.com/support
- **Developer Forums:** https://developer.paypal.com/community/
- **PRDForge Team:** Internal communication channels

---

## TIMELINE & ESTIMATES

### Immediate (0-2 hours):
- [ ] Revoke production credentials
- [ ] Create sandbox app
- [ ] Update environment files
- [ ] Basic verification

### Short-term (2-8 hours):
- [ ] Set up test accounts
- [ ] Configure webhooks
- [ ] Run basic payment tests
- [ ] Document findings

### Medium-term (8-24 hours):
- [ ] Complete all test scenarios
- [ ] Fix any issues found
- [ ] Security review
- [ ] Production readiness assessment

---

**Last Updated:** 2026-03-18 14:25 GMT+1  
**Status:** AWAITING CREDENTIAL ROTATION  
**Next Action:** Revoke production credentials IMMEDIATELY