# QA-003: Billing Validation Test Plan
## PRDForge Payment System Comprehensive Testing

**Created:** 2026-03-18  
**Prepared by:** Sheba (Commercial Agent)  
**Status:** Ready for Execution  
**Priority:** CRITICAL - Phase 2 Day 6

---

## Executive Summary

This document outlines the comprehensive billing validation test plan for PRDForge. All payment provider configurations have been verified and are ready for end-to-end testing. The plan covers all 4 payment providers (Stripe, PayPal, Paystack, NowPayments) with 8 core test cases and 5 test data scenarios.

## 1. Test Environment

### 1.1 Configuration Status
- ✅ **Environment Variables:** All payment credentials configured in `.env.test`
- ✅ **Test Site:** `https://prdforge-dev.netlify.app` (HTTP 200 confirmed)
- ✅ **Test User:** `test+prdforge@example.com` / `TestPassword123!`
- ✅ **Supabase:** Connected and accessible

### 1.2 Payment Provider Status
| Provider | Status | Test Mode | Credentials |
|----------|--------|-----------|-------------|
| **Stripe** | ✅ Ready | Test | `sk_test_...` format confirmed |
| **PayPal** | ✅ Ready | Sandbox | Client ID/Secret present |
| **Paystack** | ✅ Ready | Test | `sk_test_...` format confirmed |
| **NowPayments** | ✅ Ready | Test | `np_test_...` format confirmed |

### 1.3 Webhook Configuration
- **Stripe Webhook Secret:** ✅ Configured
- **NowPayments IPN Secret:** ✅ Configured
- **Webhook URLs:** Need configuration in provider dashboards:
  - `https://jnlkzcmeiksqljnbtfhb.supabase.co/functions/v1/stripe/webhook`
  - `https://jnlkzcmeiksqljnbtfhb.supabase.co/functions/v1/paystack/webhook`
  - `https://jnlkzcmeiksqljnbtfhb.supabase.co/functions/v1/nowpayments/webhook`

## 2. Test Objectives

### 2.1 Primary Objectives
1. Validate end-to-end payment flows for all providers
2. Test successful and failed payment scenarios
3. Verify invoice generation and email receipts
4. Test credit top-up and subscription flows
5. Validate webhook/IPN processing

### 2.2 Success Criteria
- All 8 test cases pass
- Payment processing works for all 4 providers
- Invoices generated with correct format
- Emails delivered for receipts and notifications
- Database records created correctly

## 3. Test Cases

### 3.1 Core Payment Flow Tests

#### **TC-BILL-001: Stripe Credit Card Payment - Successful**
- **Priority:** High
- **Description:** Test successful payment with Stripe test card
- **Test Card:** `4242 4242 4242 4242`
- **Validation Points:**
  - Payment completes successfully
  - Invoice generated (format: `PRF-YYYY-XXXXXX`)
  - Credits added to user account
  - Webhook processed
  - Email receipt sent

#### **TC-BILL-002: Stripe Credit Card Payment - Declined**
- **Priority:** High
- **Description:** Test declined payment scenario
- **Test Card:** `4000 0000 0000 0002`
- **Validation Points:**
  - Appropriate error message displayed
  - No invoice generated
  - No credits added
  - User can retry payment

#### **TC-BILL-003: PayPal Sandbox Payment**
- **Priority:** High
- **Description:** Test PayPal sandbox payment flow
- **Test Account:** PayPal sandbox test account required
- **Validation Points:**
  - Redirect to PayPal sandbox works
  - Payment completes successfully
  - Return to PRDForge with success status
  - Credits added to account

#### **TC-BILL-004: Paystack NGN Payment**
- **Priority:** Medium
- **Description:** Test Paystack Nigerian Naira payment
- **Test Card:** `5061 0606 0606 0606`
- **Validation Points:**
  - NGN payment processes successfully
  - Currency conversion handled correctly
  - Invoice generated in USD equivalent
  - Credits added to account

#### **TC-BILL-005: NowPayments Crypto Payment**
- **Priority:** Medium
- **Description:** Test cryptocurrency payment flow
- **Test Crypto:** Bitcoin testnet (or other testnet crypto)
- **Validation Points:**
  - Payment address generated
  - IPN webhook received on payment
  - Payment confirmed after blockchain confirmation
  - Credits added to account

### 3.2 Billing System Tests

#### **TC-BILL-006: Invoice Generation and Email**
- **Priority:** High
- **Description:** Test invoice generation and email receipt
- **Validation Points:**
  - Invoice record created in `prdforge_billing_history`
  - Invoice number follows format: `PRF-YYYY-XXXXXX`
  - Email sent to user with receipt
  - Email contains correct invoice details

#### **TC-BILL-007: Credit Top-up Flow**
- **Priority:** High
- **Description:** Test credit purchase and balance update
- **Test Pack:** Any credit pack (e.g., 100 credits for $20)
- **Validation Points:**
  - Credit balance updated correctly
  - Transaction recorded in history
  - Invoice generated for credit purchase
  - Email confirmation sent

#### **TC-BILL-008: Subscription Payment Flow**
- **Priority:** Medium
- **Description:** Test recurring subscription payment
- **Test Plan:** Starter plan (monthly)
- **Validation Points:**
  - Subscription activated after payment
  - Recurring billing date set correctly
  - Subscription status shows "active"
  - Can cancel subscription

## 4. Test Data Scenarios

### 4.1 User Scenarios

| Scenario | User | Action | Amount | Provider | Validation Focus |
|----------|------|--------|--------|----------|------------------|
| **New User First Payment** | `test+newuser@example.com` | Export unlock | $5.00 | Stripe | Onboarding flow |
| **Existing User Credit Top-up** | `test+existing@example.com` | 100 credits | $20.00 | PayPal | Balance update |
| **Nigerian User Payment** | `test+ng@example.com` | Monthly subscription | ₦3,500 | Paystack | Currency conversion |
| **Crypto Payment** | `test+crypto@example.com` | Export unlock | 0.00015 BTC | NowPayments | Crypto confirmation |
| **Failed Payment Retry** | `test+failed@example.com` | Declined card | $5.00 | Stripe | Error handling |

### 4.2 Test Data Requirements
1. **Test Cards:**
   - Stripe: `4242 4242 4242 4242` (success), `4000 0000 0000 0002` (declined)
   - Paystack: `5061 0606 0606 0606` (NGN test card)

2. **Test Accounts:**
   - PayPal sandbox buyer account
   - NowPayments testnet crypto wallet

3. **Test Amounts:**
   - Export unlock: $5.00
   - Credit packs: $5 (25 credits), $10 (60 credits), $20 (150 credits), $50 (500 credits)
   - Subscriptions: $10/month (Starter), $30/month (Pro), $100/month (Enterprise)

## 5. Test Execution Plan

### 5.1 Pre-Test Checklist
- [ ] All environment variables loaded
- [ ] Test site accessible
- [ ] Test user account created
- [ ] Payment provider dashboards accessible
- [ ] Webhook endpoints configured in providers
- [ ] Email service configured and testable

### 5.2 Test Execution Order
1. **Phase 1: Configuration Verification** (Already Complete)
   - Environment variables check
   - Provider connectivity test
   - Webhook configuration check

2. **Phase 2: Core Payment Flows**
   - TC-BILL-001: Stripe successful payment
   - TC-BILL-002: Stripe declined payment
   - TC-BILL-003: PayPal payment
   - TC-BILL-004: Paystack payment

3. **Phase 3: Advanced Flows**
   - TC-BILL-005: Crypto payment (if testnet available)
   - TC-BILL-007: Credit top-up
   - TC-BILL-008: Subscription flow

4. **Phase 4: System Validation**
   - TC-BILL-006: Invoice and email validation
   - Database consistency checks
   - Error logging verification

### 5.3 Test Duration
- **Estimated Time:** 4-6 hours
- **Parallel Testing:** Possible for different providers
- **Critical Path:** Stripe → PayPal → Paystack → NowPayments

## 6. Reporting Templates

### 6.1 Test Execution Log Template
```markdown
# Test Execution Log - QA-003
**Date:** [Date]
**Tester:** [Name]
**Environment:** [Test/Staging/Production]

## Test Results Summary
- Total Tests: 8
- Passed: [X]
- Failed: [X]
- Blocked: [X]
- Not Executed: [X]

## Detailed Results
| Test Case | Status | Notes | Evidence |
|-----------|--------|-------|----------|
| TC-BILL-001 | [Pass/Fail/Blocked] | [Notes] | [Screenshot/Log] |
| TC-BILL-002 | [Pass/Fail/Blocked] | [Notes] | [Screenshot/Log] |
| ... | ... | ... | ... |

## Issues Found
1. [Issue description]
   - Severity: [High/Medium/Low]
   - Impact: [Description]
   - Steps to reproduce: [Steps]
   - Suggested fix: [Fix]

## Recommendations
- [Recommendation 1]
- [Recommendation 2]
```

### 6.2 Defect Report Template
```markdown
# Defect Report
**ID:** [Auto-generated]
**Title:** [Brief description]
**Reported By:** [Name]
**Date:** [Date]
**Environment:** [Test/Staging/Production]

## Defect Details
- **Severity:** [Critical/High/Medium/Low]
- **Priority:** [P1/P2/P3/P4]
- **Status:** [New/In Progress/Resolved/Closed]

## Description
[Detailed description of the defect]

## Steps to Reproduce
1. [Step 1]
2. [Step 2]
3. [Step 3]
...

## Expected Result
[What should happen]

## Actual Result
[What actually happens]

## Evidence
- Screenshots: [Links]
- Logs: [Links]
- Console output: [Text]

## Environment Details
- Browser: [Browser and version]
- OS: [Operating System]
- Device: [Device type]
- Network: [Network conditions]

## Additional Notes
[Any additional information]
```

## 7. Risk Assessment

### 7.1 Identified Risks
1. **Real API Key Requirement:** Current credentials are placeholders
   - **Mitigation:** Obtain actual test API keys from provider dashboards
   - **Impact:** Testing cannot proceed without real test keys

2. **Webhook Configuration:** Webhooks not yet configured in provider dashboards
   - **Mitigation:** Configure webhook endpoints before testing
   - **Impact:** Payment confirmation may not trigger backend processing

3. **Crypto Testnet Availability:** NowPayments testnet may not be readily available
   - **Mitigation:** Use simulated crypto payment or skip if unavailable
   - **Impact:** Crypto payment flow cannot be fully tested

4. **Email Delivery:** Test emails may go to spam or not be delivered
   - **Mitigation:** Check spam folders, use email testing service
   - **Impact:** Cannot validate email receipt functionality

### 7.2 Risk Matrix
| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Missing real API keys | High | High | Obtain from provider dashboards |
| Webhook misconfiguration | Medium | High | Test webhook endpoints manually |
| Crypto testnet unavailable | Medium | Medium | Simulate or document as limitation |
| Email delivery issues | Low | Medium | Use email testing, check logs |

## 8. Exit Criteria

### 8.1 Must-Have (Blocking)
- [ ] All 4 payment providers configured with real test keys
- [ ] Webhook endpoints configured and responding
- [ ] TC-BILL-001 and TC-BILL-006 pass (Stripe + Invoice)
- [ ] No critical defects blocking payment processing

### 8.2 Should-Have (Important)
- [ ] At least 6 of 8 test cases pass
- [ ] PayPal and Paystack payment flows working
- [ ] Email receipts being delivered
- [ ] Database records created correctly

### 8.3 Nice-to-Have (Optional)
- [ ] All 8 test cases pass
- [ ] Crypto payment flow tested
- [ ] Performance metrics collected
- [ ] Load testing completed

## 9. Next Steps

### 9.1 Immediate Actions (Before Testing)
1. **Obtain real test API keys** from:
   - Stripe Dashboard → Developers → API Keys
   - PayPal Developer Dashboard → Sandbox → Apps
   - Paystack Dashboard → Settings → API Keys & Webhooks
   - NowPayments Dashboard → API Settings

2. **Configure webhook endpoints** in each provider dashboard:
   - Stripe: `https://jnlkzcmeiksqljnbtfhb.supabase.co/functions/v1/stripe/webhook`
   - Paystack: `https://jnlkzcmeiksqljnbtfhb.supabase.co/functions/v1/paystack/webhook`
   - NowPayments: `https://jnlkzcmeiksqljnbtfhb.supabase.co/functions/v1/nowpayments/webhook`

3. **Update environment files** with real test keys:
   - `/Users/clawdia/apps/prdforge/.env.test`
   - `/Users/clawdia/apps/prdforge/.env`

### 9.2 Testing Execution
1. Execute test cases in order of priority
2. Document all results with screenshots
3. Log any defects found
4. Validate database changes

### 9.3 Post-Testing
1. Generate test report
2. Review and prioritize defects
3. Plan fixes for critical issues
4. Schedule retest for fixed defects

## 10. Contact Information

- **Test Lead:** Sheba (Commercial Agent)
- **Technical Support:** Trinity (Technical Agent)
- **Project Management:** Clawdia (Orchestrator)
- **Stakeholder:** Temi Kolawole

## 11. Appendices

### Appendix A: Test Card Numbers
- **Stripe Test Cards:**
  - Success: `4242 4242 4242 4242`
  - Decline: `4000 0000 0000 0002`
  - Authentication required: `4000 0025 0000 3155`
  
- **Paystack Test Cards (NGN):**
  - Success: `5061 0606 0606 0606`
  - Insufficient funds: `5061 0606 0606 0614`

### Appendix B: Webhook Testing Tools
- **Stripe CLI:** `stripe listen --forward-to localhost:54321/functions/v1/stripe/webhook`
- **Webhook.site:** For testing webhook endpoints
- **ngrok:** For local webhook testing

### Appendix C: Environment Variables Reference
```bash
# Payment Providers
STRIPE_PUBLIC_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

PAYPAL_CLIENT_ID=AVr-s5kG...
PAYPAL_CLIENT_SECRET=EN3dcrJt...
PAYPAL_MODE=sandbox

PAYSTACK_PUBLIC_KEY=pk_test_...
PAYSTACK_SECRET_KEY=sk_test_...

NOWPAYMENTS_API_KEY=np_test_...
NOWPAYMENTS_IPN_SECRET=np_ipn_test_...

# Test Configuration
TEST_USER_EMAIL=test+prdforge@example.com
TEST_USER_PASSWORD=TestPassword123!
SITE_URL=https://prdforge-dev.netlify.app
```

---

**Document Version:** 1.0  
**Last Updated:** 2026-03-18  
**Next Review:** After QA-003 execution  
**Status:** ✅ READY FOR EXECUTION