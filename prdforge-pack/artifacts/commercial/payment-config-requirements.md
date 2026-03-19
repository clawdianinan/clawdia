# Payment Configuration Requirements
## For Trinity (Technical Agent)

**Created:** 2026-03-18 07:15 AM (Africa/Lagos)
**Priority:** CRITICAL - Phase 2 Blocking Dependency
**Required By:** Day 5 (2026-03-19) for test environment setup
**Impact:** Billing validation (Day 6) cannot proceed without this

---

## Current Status Analysis

### Environment Files Checked:
1. **`/Users/clawdia/apps/prdforge/.env`** - Main development environment
2. **`/Users/clawdia/apps/prdforge/.env.test`** - Test environment
3. **`/Users/clawdia/apps/prdforge/.env.production`** - Production environment

### Findings:
All payment environment variables are currently **PLACEHOLDERS**:
```
STRIPE_SECRET_KEY="sk_test_placeholder_configure_me"
STRIPE_WEBHOOK_SECRET="whsec_placeholder_configure_me"
PAYPAL_CLIENT_ID="test_client_id_placeholder_configure_me"
PAYPAL_CLIENT_SECRET="test_client_secret_placeholder_configure_me"
PAYSTACK_SECRET_KEY="sk_test_placeholder_configure_me"
NOWPAYMENTS_API_KEY="np_api_key_placeholder_configure_me"
NOWPAYMENTS_IPN_SECRET="np_ipn_secret_placeholder_configure_me"
```

---

## Configuration Requirements

### 1. Stripe Configuration
**Purpose:** Primary payment processor for credit card payments

#### Required Actions:
1. **Create Stripe Test Account:**
   - Go to: https://dashboard.stripe.com/register
   - Use test email: `prdforge-test@iih.ng` (or appropriate test account)
   - Enable test mode

2. **Obtain API Keys:**
   - **Secret Key:** `sk_test_...` (from Developers → API keys)
   - **Publishable Key:** `pk_test_...` (for frontend if needed)
   - **Webhook Secret:** `whsec_...` (from Webhooks → Add endpoint)

3. **Configure Webhook Endpoint:**
   - Endpoint URL: `https://[your-domain]/api/webhooks/stripe`
   - Events to listen for:
     - `payment_intent.succeeded`
     - `payment_intent.payment_failed`
     - `invoice.payment_succeeded`
     - `invoice.payment_failed`
     - `customer.subscription.created`
     - `customer.subscription.updated`
     - `customer.subscription.deleted`

4. **Test Cards to Enable:**
   - Visa: `4242 4242 4242 4242`
   - MasterCard: `5555 5555 5555 4444`
   - Amex: `3782 822463 10005`
   - Decline: `4000 0000 0000 0002`
   - 3D Secure: `4000 0025 0000 3155`

### 2. PayPal Configuration
**Purpose:** Alternative payment method for users preferring PayPal

#### Required Actions:
1. **Create PayPal Sandbox Account:**
   - Go to: https://developer.paypal.com/
   - Create sandbox business account
   - Create sandbox personal account (for testing)

2. **Obtain API Credentials:**
   - **Client ID:** From REST API apps section
   - **Client Secret:** From REST API apps section
   - **Mode:** `sandbox`

3. **Configure Webhooks:**
   - Events to listen for:
     - `PAYMENT.CAPTURE.COMPLETED`
     - `PAYMENT.CAPTURE.DENIED`
     - `BILLING.SUBSCRIPTION.ACTIVATED`
     - `BILLING.SUBSCRIPTION.CANCELLED`

4. **Test Accounts:**
   - **Buyer:** `sb-abcde1234567@personal.example.com`
   - **Seller:** `sb-xyz7890123@business.example.com`
   - **Password:** `test1234` (standard sandbox password)

### 3. Paystack Configuration
**Purpose:** Local Nigerian payments (NGN currency)

#### Required Actions:
1. **Create Paystack Test Account:**
   - Go to: https://dashboard.paystack.com/
   - Use test mode

2. **Obtain API Keys:**
   - **Secret Key:** `sk_test_...`
   - **Public Key:** `pk_test_...`

3. **Configure Webhooks:**
   - Events to listen for:
     - `charge.success`
     - `charge.failed`
     - `subscription.create`
     - `subscription.disable`

4. **Test Cards:**
   - Success: `4084 0840 8408 4081`
   - Decline: `4084 0840 8408 4082`
   - 3D Secure: `5061 0606 0606 0606`

### 4. NowPayments Configuration
**Purpose:** Cryptocurrency payments

#### Required Actions:
1. **Create NowPayments Test Account:**
   - Go to: https://nowpayments.io/
   - Register for sandbox/testing account

2. **Obtain API Keys:**
   - **API Key:** From account settings
   - **IPN Secret:** For instant payment notifications

3. **Configure IPN (Instant Payment Notification):**
   - IPN URL: `https://[your-domain]/api/webhooks/nowpayments`
   - Enable test mode

4. **Test Crypto Addresses:**
   - Use testnet addresses for Bitcoin, Ethereum, etc.
   - Small test amounts (0.001 BTC, 0.01 ETH)

---

## Environment Variable Updates Required

### Update `/Users/clawdia/apps/prdforge/.env` (Development):
```bash
# Stripe Configuration
STRIPE_SECRET_KEY="sk_test_51P... [REAL_TEST_KEY]"
STRIPE_WEBHOOK_SECRET="whsec_... [REAL_WEBHOOK_SECRET]"

# PayPal Configuration  
PAYPAL_CLIENT_ID="AeA... [REAL_SANDBOX_CLIENT_ID]"
PAYPAL_CLIENT_SECRET="EC... [REAL_SANDBOX_CLIENT_SECRET]"
PAYPAL_MODE="sandbox"

# Paystack Configuration
PAYSTACK_SECRET_KEY="sk_test_... [REAL_TEST_KEY]"

# NowPayments Configuration
NOWPAYMENTS_API_KEY="np_api_key_... [REAL_TEST_KEY]"
NOWPAYMENTS_IPN_SECRET="np_ipn_secret_... [REAL_IPN_SECRET]"
```

### Update `/Users/clawdia/apps/prdforge/.env.test` (Test Environment):
```bash
# PayPal Sandbox Configuration
PAYPAL_CLIENT_ID="[REAL_SANDBOX_CLIENT_ID]"
PAYPAL_CLIENT_SECRET="[REAL_SANDBOX_CLIENT_SECRET]"
PAYPAL_MODE="sandbox"

# Add missing payment variables:
STRIPE_SECRET_KEY="[REAL_TEST_KEY]"
STRIPE_WEBHOOK_SECRET="[REAL_WEBHOOK_SECRET]"
PAYSTACK_SECRET_KEY="[REAL_TEST_KEY]"
NOWPAYMENTS_API_KEY="[REAL_TEST_KEY]"
NOWPAYMENTS_IPN_SECRET="[REAL_IPN_SECRET]"
```

### Create `/Users/clawdia/apps/prdforge/.env.local` (Optional - Local Development):
```bash
# Local development overrides
# Use if different from main .env file
```

---

## Verification Steps

### After Configuration:
1. **Test API Connectivity:**
   ```bash
   # Test Stripe connection
   curl https://api.stripe.com/v1/balance \
     -u sk_test_...:
   
   # Test PayPal connection
   curl -v https://api-m.sandbox.paypal.com/v1/oauth2/token \
     -H "Accept: application/json" \
     -H "Accept-Language: en_US" \
     -u "client_id:secret" \
     -d "grant_type=client_credentials"
   ```

2. **Verify Webhook Endpoints:**
   - Stripe: Send test webhook from dashboard
   - PayPal: Send test notification from developer portal
   - Paystack: Use test webhook from dashboard
   - NowPayments: Test IPN from settings

3. **Test Payment Flow:**
   - Attempt test payment with `4242 4242 4242 4242`
   - Verify payment succeeds
   - Check webhook received and processed
   - Confirm invoice generated

---

## Timeline & Dependencies

### Critical Path:
**Day 4 (Today - 2026-03-18):**
- [ ] Trinity: Begin payment provider account creation
- [ ] Trinity: Obtain test API keys
- [ ] Trinity: Configure webhook endpoints

**Day 5 (Tomorrow - 2026-03-19):**
- [ ] Trinity: Complete all payment configurations
- [ ] Trinity: Update environment files with real keys
- [ ] Sheba: Verify connectivity and test basic payment
- [ ] Sheba: Dry run critical test scenarios

**Day 6 (2026-03-20):**
- [ ] Sheba: Execute full billing validation test suite
- [ ] Trinity: Provide technical support during testing

### Success Criteria:
- [ ] All 4 payment providers configured in test mode
- [ ] API keys validated and working
- [ ] Webhook endpoints receiving test events
- [ ] Test payments processing successfully
- [ ] Environment files updated with real (test) keys

---

## Risk Mitigation

### If Configuration Delayed:
1. **Priority Order:**
   - 1. Stripe (primary - covers 80% of use cases)
   - 2. PayPal (important alternative)
   - 3. Paystack (NGN payments)
   - 4. NowPayments (crypto - nice to have)

2. **Fallback Options:**
   - **Option A:** Test with Stripe only initially
   - **Option B:** Use mock payment service for initial tests
   - **Option C:** Extend testing timeline if multi-provider setup takes time

3. **Escalation Path:**
   - **Day 4 EOD:** If no progress, escalate to Clawdia
   - **Day 5 Morning:** If not complete, implement fallback options
   - **Day 5 EOD:** Must have at least Stripe configured for Day 6 testing

---

## Support & Resources

### Documentation Links:
- **Stripe Test Mode:** https://stripe.com/docs/testing
- **PayPal Sandbox:** https://developer.paypal.com/docs/api-basics/sandbox/
- **Paystack Test Mode:** https://paystack.com/docs/payments/test-payments
- **NowPayments Sandbox:** https://documenter.getpostman.com/view/10058163/SWLk4RPL

### Test Data Reference:
- **Stripe Test Cards:** https://stripe.com/docs/testing#cards
- **PayPal Sandbox Accounts:** Automatically created in developer portal
- **Paystack Test Cards:** Provided in dashboard
- **NowPayments Test Crypto:** Use testnet addresses

### Contact for Issues:
- **Clawdia:** Orchestrator for escalation
- **Sheba:** For testing requirements clarification
- **Team Channel:** For collaborative problem-solving

---

## Next Steps

### Immediate (Today - Standup):
1. **Trinity:** Confirm understanding of requirements
2. **Trinity:** Provide estimated completion timeline
3. **Clawdia:** Approve priority order and fallback plan

### Post-standup:
1. **Trinity:** Begin account creation and configuration
2. **Sheba:** Prepare test scripts for verification
3. **Team:** Daily check-in on progress at 9 AM standup

---
**Document Version:** 1.0
**Created:** 2026-03-18 07:15 AM
**Owner:** Sheba (Commercial Agent)
**Status:** ✅ Requirements Defined
**Next Review:** 9 AM Standup (2026-03-18)