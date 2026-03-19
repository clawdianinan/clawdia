# QA-003 Mock Payment Service Addendum
## For Testing Without Real Payment API Keys

**Created:** 2026-03-18  
**Status:** ACTIVE - Use for QA-003 testing while real API keys are being obtained  
**Integration:** Works with existing QA-003 test plan

---

## 🎯 **Purpose**

This addendum enables QA-003 billing validation testing to proceed immediately using a mock payment service, bypassing the need for real payment API keys during initial testing.

## 🔧 **Mock Payment Service Configuration**

### **Environment Setup:**
```bash
# Set payment mode to mock
PAYMENT_MODE=mock

# Mock service endpoint
MOCK_PAYMENT_URL=http://localhost:3001/api/mock-payments

# Webhook configuration
MOCK_WEBHOOK_URL=http://localhost:3001/api/webhooks/mock
```

### **How It Works:**
1. **Intercepts** payment requests to real providers
2. **Simulates** provider responses based on test card numbers
3. **Generates** mock webhook events
4. **Creates** test invoices and receipts
5. **Tracks** subscription states

## 🧪 **Test Scenarios with Mock Service**

### **1. Basic Payment Flow Tests**
| Test Card | Expected Result | Mock Response |
|-----------|----------------|---------------|
| `4242 4242 4242 4242` | ✅ Payment Success | `{"status": "succeeded", "id": "mock_pm_123"}` |
| `4000 0000 0000 0002` | ❌ Payment Decline | `{"status": "failed", "error": "card_declined"}` |
| `4000 0025 0000 3155` | ⚠️ 3D Secure Required | `{"status": "requires_action", "next_action": "3d_secure"}` |

### **2. Subscription Lifecycle Tests**
- **Subscribe:** Free → Starter ($12/month)
- **Upgrade:** Starter → Pro ($24/month)
- **Downgrade:** Pro → Starter
- **Cancel:** Subscription cancellation
- **Reactivate:** Cancelled → Active

### **3. Webhook Simulation Tests**
- **Payment Success:** `payment_intent.succeeded`
- **Payment Failure:** `payment_intent.payment_failed`
- **Subscription Created:** `customer.subscription.created`
- **Subscription Updated:** `customer.subscription.updated`
- **Subscription Cancelled:** `customer.subscription.deleted`

### **4. Error Scenario Tests**
- **Network Timeout:** 30-second delay simulation
- **Server Error:** HTTP 500 response
- **Validation Error:** Invalid payment data
- **Rate Limit:** Too many requests
- **Maintenance:** Service unavailable

## 📋 **Test Execution with Mock Service**

### **Step 1: Enable Mock Mode**
```bash
# In PRDForge application
export PAYMENT_MODE=mock
npm run dev
```

### **Step 2: Execute QA-003 Tests**
Use the existing QA-003 test plan with these modifications:
1. **Test Cards:** Use mock test card numbers above
2. **Verification:** Check mock payment logs at `/api/mock-payments/logs`
3. **Webhooks:** Monitor mock webhook delivery at `/api/webhooks/mock/logs`

### **Step 3: Validate Results**
- **Payment Status:** Verify in mock payment dashboard
- **Invoice Generation:** Check mock invoice creation
- **Webhook Delivery:** Confirm mock webhook processing
- **Subscription State:** Validate in mock subscription manager

## 🔄 **Transition to Real Payments**

### **When Real API Keys Are Available:**
1. **Switch Mode:** `PAYMENT_MODE=real`
2. **Update Credentials:** Replace mock credentials with real ones
3. **Re-run Critical Tests:** Verify real payment integration
4. **Compare Results:** Mock vs Real payment behavior

### **Testing Coverage:**
- **Mock Testing:** 100% of QA-003 test scenarios
- **Real Testing:** Critical path validation only
- **Risk:** Minimal - mock service mimics real behavior

## 🎪 **Success Criteria with Mock Service**

### **Must Pass:**
- [ ] All 6 basic payment scenarios
- [ ] Subscription lifecycle transitions
- [ ] Webhook delivery and processing
- [ ] Error handling and recovery
- [ ] Invoice and receipt generation

### **Nice to Have:**
- [ ] Performance benchmarks
- [ ] Concurrent user testing
- [ ] Edge case coverage
- [ ] International payment simulation

## 📊 **Reporting with Mock Service**

### **Test Results Format:**
```json
{
  "test_scenario": "Basic Payment Success",
  "payment_mode": "mock",
  "test_card": "4242 4242 4242 4242",
  "expected_result": "succeeded",
  "actual_result": "succeeded",
  "mock_response_id": "mock_pm_123",
  "webhook_delivered": true,
  "invoice_generated": true,
  "timestamp": "2026-03-18T14:30:00Z"
}
```

### **Metrics to Track:**
- **Mock Payment Success Rate:** Target 100%
- **Webhook Delivery Time:** < 5 seconds
- **Invoice Generation Time:** < 3 seconds
- **Error Recovery Success:** 100%

## 🚀 **Getting Started**

### **Immediate Actions:**
1. **Wait for Trinity** to complete mock payment service implementation (2-3 hours)
2. **Enable Mock Mode** in environment configuration
3. **Begin QA-003 Testing** using this addendum
4. **Document Results** in QA-003 test execution log

### **Expected Timeline:**
- **Mock Service Ready:** 2-3 hours from now
- **QA-003 Testing:** 4-6 hours (can begin immediately after)
- **Phase 2 Completion:** Today if testing completes

## ⚠️ **Limitations & Considerations**

### **Mock Service Limitations:**
- Does not validate real payment provider APIs
- May not catch provider-specific edge cases
- No real money movement validation
- Limited fraud detection simulation

### **Risk Mitigation:**
1. **Post-Mock Validation:** Critical tests with real payments before launch
2. **Provider Documentation:** Review each provider's test requirements
3. **Monitoring:** Enhanced monitoring during real payment transition
4. **Rollback Plan:** Ability to revert to mock if real integration fails

## 🔗 **Integration with Existing QA-003 Plan**

This addendum **extends** the existing QA-003 test plan. All test cases, documentation, and reporting from the main plan apply. The only difference is the payment mode (mock vs real).

**Use this addendum for initial testing, then transition to real payments when API keys are available.**

---
**Version:** 1.0  
**Created:** 2026-03-18  
**Owner:** Clawdia (Orchestrator)  
**Integration:** QA-003 Billing Validation Test Plan  
**Status:** ✅ Ready for use when mock payment service is implemented