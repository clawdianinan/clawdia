# PRDForge Logic Test Template
**Purpose:** Test BUSINESS LOGIC correctness (not just code syntax)

## 🎯 **What is Logic Testing?**

### **Code vs Logic Testing:**
```
CODE TESTING (HOW it works)          LOGIC TESTING (WHAT it should do)
─────────────────────────────────── ─────────────────────────────────
• Does it compile?                  • Does it solve the right problem?
• Are types correct?                • Are business rules enforced?
• Are there syntax errors?          • Does user journey make sense?
• Are APIs properly defined?        • Are edge cases handled?
• Is performance acceptable?        • Is state consistent?
```

### **Logic Testing Focus Areas:**
1. **Business Rules** - Pricing, credits, limits, permissions
2. **State Consistency** - Payment → Subscription → Credits flow
3. **Edge Cases** - Boundaries, empty inputs, maximum limits
4. **Race Conditions** - Concurrent operations
5. **Timezone Logic** - Global date/time handling
6. **User Journeys** - Complete workflows from start to finish

## 📋 **Logic Test Case Template**

### **Template: Business Rule Test**
```markdown
## Test: [Business Rule Name]
**ID:** LT-[NUM]-[PRIORITY]
**Category:** Business Logic

**Business Rule:**
[State the business rule in plain language]

**Implementation Check:**
- [ ] Code implements rule correctly
- [ ] Database enforces rule (constraints, triggers)
- [ ] UI reflects rule (validation, messaging)
- [ ] API enforces rule (validation, errors)

**Test Scenarios:**
1. **Normal Case:** Standard operation
   - Input: [Standard input]
   - Expected: [Rule applied correctly]
   - Actual: [ ] Pass / [ ] Fail

2. **Edge Case:** Boundary condition
   - Input: [Boundary input]
   - Expected: [Rule handles boundary]
   - Actual: [ ] Pass / [ ] Fail

3. **Violation Case:** Attempt to break rule
   - Input: [Invalid input]
   - Expected: [Rule prevents violation]
   - Actual: [ ] Pass / [ ] Fail

**Files to Check:**
- [File 1] - Implementation
- [File 2] - Database schema
- [File 3] - UI validation
- [File 4] - API validation

**Automation Potential:** [High/Medium/Low]
**Test Data Required:** [Specific test data]
```

### **Template: State Consistency Test**
```markdown
## Test: [State Transition]
**ID:** ST-[NUM]-[PRIORITY]
**Category:** State Logic

**State Flow:**
[Describe the state transition: A → B → C]

**Consistency Requirements:**
1. [Requirement 1]
2. [Requirement 2]
3. [Requirement 3]

**Test Sequence:**
```
Step 1: [Initial state setup]
Step 2: [Trigger transition]
Step 3: [Verify intermediate state]
Step 4: [Verify final state]
Step 5: [Verify side effects]
```

**Failure Scenarios:**
- [ ] Network interruption during transition
- [ ] Concurrent modifications
- [ ] Invalid input during transition
- [ ] System crash during transition

**Recovery Requirements:**
- [ ] State can be reconstructed
- [ ] No data corruption
- [ ] User can continue from last good state
- [ ] Audit trail exists

**Files Involved:**
- [State management files]
- [Database transaction files]
- [Recovery/rollback files]
```

## 🧪 **Critical Logic Tests for PRDForge**

### **1. Pricing Logic Test ($9/$19 Plans)**
**Business Rule:** Pro plan costs $19/month ($190/year), Starter costs $9/month ($90/year)

**Test Scenarios:**
- [ ] UI displays correct pricing
- [ ] Checkout charges correct amount
- [ ] Invoices show correct pricing
- [ ] Yearly discount calculates correctly (17%)
- [ ] Plan comparison shows correct features

### **2. Credit System Logic Test**
**Business Rule:** Credits deduct immediately, reset monthly, paywall on exhaustion

**Test Scenarios:**
- [ ] Credit deduction happens BEFORE action
- [ ] Monthly reset on 1st of month (timezone-aware)
- [ ] Paywall shows when credits exhausted
- [ ] Top-up credits apply immediately
- [ ] Tier limits enforced correctly

### **3. Payment → Subscription → Credits Flow**
**State Flow:** Payment → Validation → Subscription Activation → Credit Allocation

**Consistency Checks:**
- [ ] Payment success = Subscription active
- [ ] Subscription active = Credits allocated
- [ ] Failed payment = Grace period active
- [ ] Grace period expired = Subscription suspended
- [ ] Subscription suspended = No new credits

### **4. Export Data Transformation Logic**
**Business Rule:** Export produces usable output without [object] tags

**Test Scenarios:**
- [ ] Objects properly stringified
- [ ] Arrays of objects handled correctly
- [ ] Null/undefined values have fallbacks
- [ ] Special characters encoded properly
- [ ] Large content exports completely

### **5. Race Condition Prevention**
**Business Rule:** Concurrent operations don't corrupt state

**Test Scenarios:**
- [ ] Invoice numbers never duplicate
- [ ] Credit deduction atomic (no double-spend)
- [ ] Project creation counters accurate
- [ ] Subscription status updates atomic

## 🔧 **Logic Test Execution**

### **Manual Logic Testing:**
1. **Think like a user:** What would a user expect?
2. **Think like an attacker:** How could this be abused?
3. **Think like a business owner:** What are the business rules?
4. **Think like a developer:** What could go wrong technically?

### **Automated Logic Testing:**
1. **Property-based testing:** Generate random inputs, verify properties hold
2. **State machine testing:** Model system as state machine, test transitions
3. **Contract testing:** Verify APIs obey business rules
4. **Mutation testing:** Introduce faults, verify detection

### **Tools for Logic Testing:**
- **Property-based:** Fast-check, JSVerify
- **State machine:** XState, Model-based testing
- **Contract:** Pact, OpenAPI validation
- **Mutation:** Stryker, PITest

## 📊 **Logic Test Metrics**

### **What to Measure:**
- **Rule Coverage:** % of business rules tested
- **State Coverage:** % of state transitions tested
- **Edge Case Coverage:** % of edge cases tested
- **Logic Bug Rate:** Bugs found in production logic
- **Test Maintenance:** Time to update logic tests

### **Success Criteria:**
- ✅ 100% of business rules tested
- ✅ 100% of critical state transitions tested
- ✅ > 90% of edge cases tested
- ✅ < 1 logic bug per month in production
- ✅ Logic tests updated with feature changes

## 🚀 **Immediate Logic Tests Needed**

### **P0 - Critical (This Week):**
1. **Pricing Logic:** Verify $9/$19 implementation everywhere
2. **Credit Logic:** Test deduction, reset, paywalls
3. **Export Logic:** Fix [object] bug, test all formats
4. **Payment Logic:** Test end-to-end flow

### **P1 - High (Next Week):**
1. **State Consistency:** Payment → Subscription → Credits
2. **Race Conditions:** Invoice numbers, credit deduction
3. **Timezone Logic:** Monthly resets globally
4. **Boundary Logic:** Max limits, empty inputs

### **P2 - Medium (Following Weeks):**
1. **Concurrent Usage:** Multiple users, same resources
2. **Error Recovery:** Network failures, crashes
3. **Data Migration:** Schema changes, data transforms
4. **Integration Logic:** Third-party API interactions

## 📝 **How to Document Logic Tests**

### **For Each Business Rule:**
1. **Rule Statement:** Clear, unambiguous statement
2. **Rationale:** Why this rule exists (business reason)
3. **Implementation:** Where and how it's implemented
4. **Test Cases:** Specific scenarios to verify
5. **Exceptions:** When the rule doesn't apply
6. **Related Rules:** Other rules that interact

### **For Each State Transition:**
1. **From State:** Starting state
2. **To State:** Ending state
3. **Trigger:** What causes the transition
4. **Preconditions:** Required conditions
5. **Postconditions:** Guaranteed outcomes
6. **Side Effects:** Other changes that occur
7. **Error Cases:** What happens on failure

## 🏁 **Logic Testing Success**

### **Logic Testing is Successful When:**
1. **Business rules are crystal clear** and documented
2. **Every rule has test coverage** proving it works
3. **Edge cases are identified** and handled
4. **State consistency is guaranteed** across all operations
5. **The system behaves predictably** under all conditions
6. **Business owners can verify** the system does what they expect

### **Remember:**
**Code can be perfect but logic can be wrong.** 
A function can compile without errors but implement the wrong business rule.
Always test both the **implementation** AND the **intent**.

---

**This template ensures we test WHAT the system should do, not just HOW it does it.**

**Document Version:** 1.0.0  
**Last Updated:** March 25, 2026, 23:35 WAT  
**Maintained By:** Morpheus (QA Lead) via Clawdia