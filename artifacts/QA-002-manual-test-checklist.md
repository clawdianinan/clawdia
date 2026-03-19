# QA-002: Manual Testing Checklist
## Auth-State Failure Scenarios Testing

### Test Preparation
- [ ] PRDForge application running on http://localhost:8080
- [ ] Browser with developer tools open
- [ ] Network tab ready for throttling
- [ ] Console tab open for error monitoring
- [ ] Test user accounts created
- [ ] Clear browser cookies and cache before each test

---

## 1. SESSION EXPIRY TESTS

### 1.1 Token Expiration During Active Session
**Objective:** Verify system handles expired tokens gracefully

**Test Steps:**
1. [ ] Login with valid credentials
2. [ ] Access a protected page/dashboard
3. [ ] Manually expire the session token (methods below)
4. [ ] Try to access another protected resource
5. [ ] Verify system response

**Token Expiration Methods:**
- [ ] Browser: Edit localStorage/sessionStorage to modify token expiry
- [ ] Browser: Delete token from storage
- [ ] Server: If accessible, modify token expiry in database
- [ ] Wait: Let token naturally expire (if short expiry configured)

**Expected Results:**
- [ ] User is redirected to login page
- [ ] Clear error message: "Session expired, please login again"
- [ ] No sensitive data exposed in error messages
- [ ] Session data properly cleared from client storage
- [ ] User can login again successfully

**Actual Results:**
- [ ] 
- [ ] 
- [ ] 

**Screenshots Required:**
- [ ] Error message displayed
- [ ] Network response for expired token
- [ ] Console errors (if any)

---

### 1.2 Refresh Token Failure
**Objective:** Verify system handles invalid refresh tokens

**Test Steps:**
1. [ ] Login to obtain refresh token
2. [ ] Corrupt/delete refresh token from storage
3. [ ] Trigger token refresh (methods below)
4. [ ] Observe system behavior

**Refresh Trigger Methods:**
- [ ] Wait for access token to expire
- [ ] Manually call refresh endpoint
- [ ] Perform action requiring fresh token

**Expected Results:**
- [ ] System detects invalid refresh token
- [ ] User is logged out gracefully
- [ ] Clear error message displayed
- [ ] No infinite retry loops
- [ ] User can login with fresh credentials

**Actual Results:**
- [ ] 
- [ ] 
- [ ] 

**Screenshots Required:**
- [ ] Refresh token error response
- [ ] User notification
- [ ] Network tab showing failed refresh

---

### 1.3 Concurrent Session Limits
**Objective:** Verify system handles multiple simultaneous sessions

**Test Steps:**
1. [ ] Login in Browser Tab 1
2. [ ] Login with same credentials in Browser Tab 2 (same browser)
3. [ ] Login with same credentials in different Browser/Device
4. [ ] Perform actions in all sessions
5. [ ] Observe session conflicts

**Expected Results:**
- [ ] System allows or limits concurrent sessions per policy
- [ ] Session conflicts handled gracefully
- [ ] Clear notification if session terminated elsewhere
- [ ] No data corruption between sessions
- [ ] Last session wins OR first session maintained (per policy)

**Actual Results:**
- [ ] 
- [ ] 
- [ ] 

**Screenshots Required:**
- [ ] Multiple active sessions
- [ ] Conflict notification (if any)
- [ ] Session termination message

---

## 2. NETWORK FAILURE TESTS

### 2.1 API Timeout During Auth Flow
**Objective:** Verify system handles API timeouts

**Test Steps:**
1. [ ] Open browser developer tools → Network tab
2. [ ] Set throttling to "Slow 3G" or "Offline"
3. [ ] Attempt login
4. [ ] Observe timeout behavior
5. [ ] Restore network and retry

**Expected Results:**
- [ ] Request times out after reasonable period (30-60s)
- [ ] User sees timeout notification
- [ ] UI shows loading state during attempt
- [ ] User can retry after timeout
- [ ] No UI freezing or hanging

**Actual Results:**
- [ ] 
- [ ] 
- [ ] 

**Screenshots Required:**
- [ ] Timeout error message
- [ ] Network tab showing timed out request
- [ ] Loading state UI

---

### 2.2 Network Disconnect During Login
**Objective:** Verify system handles mid-login network loss

**Test Steps:**
1. [ ] Start login process
2. [ ] Midway through (during API call), go offline
3. [ ] Observe system behavior
4. [ ] Go back online
5. [ ] Check if login completes or fails

**Expected Results:**
- [ ] Login fails gracefully with network error
- [ ] User informed of network issue
- [ ] Form data preserved (username at least)
- [ ] User can retry after reconnection
- [ ] No partial login state

**Actual Results:**
- [ ] 
- [ ] 
- [ ] 

**Screenshots Required:**
- [ ] Network error message
- [ ] Form state after disconnect
- [ ] Retry option availability

---

### 2.3 Partial Response Scenarios
**Objective:** Verify system handles incomplete API responses

**Test Steps:**
1. [ ] Use browser extension to modify API responses
2. [ ] Login and intercept response
3. [ ] Return partial/incomplete response (missing fields)
4. [ ] Observe error handling

**Expected Results:**
- [ ] System validates response completeness
- [ ] Incomplete responses rejected gracefully
- [ ] Clear error message about invalid response
- [ ] User can retry
- [ ] No crashes or undefined behavior

**Actual Results:**
- [ ] 
- [ ] 
- [ ] 

**Screenshots Required:**
- [ ] Modified response in network tab
- [ ] Error message for incomplete response
- [ ] Console validation errors

---

## 3. ERROR STATE RECOVERY TESTS

### 3.1 Invalid Token Handling
**Objective:** Verify security measures for invalid tokens

**Test Steps:**
1. [ ] Create malformed tokens (methods below)
2. [ ] Attempt to access protected resources
3. [ ] Observe system response

**Invalid Token Types:**
- [ ] Malformed JSON
- [ ] Wrong signature
- [ ] Expired timestamp
- [ ] Missing required claims
- [ ] Tampered payload

**Expected Results:**
- [ ] All invalid tokens rejected
- [ ] 401 Unauthorized response
- [ ] Clear security error in logs (not user-facing)
- [ ] User redirected to login
- [ ] Rate limiting for repeated invalid tokens

**Actual Results:**
- [ ] 
- [ ] 
- [ ] 

**Screenshots Required:**
- [ ] Network 401 response
- [ ] Security headers in response
- [ ] Console warnings (if any)

---

### 3.2 Server Error Responses (500, 503)
**Objective:** Verify system handles server failures

**Test Steps:**
1. [ ] Intercept auth API calls
2. [ ] Return 500 Internal Server Error
3. [ ] Return 503 Service Unavailable
4. [ ] Observe user experience

**Expected Results:**
- [ ] User sees generic error message
- [ ] No server details exposed to user
- [ ] Option to retry or contact support
- [ ] Error properly logged server-side
- [ ] Graceful degradation of features

**Actual Results:**
- [ ] 
- [ ] 
- [ ] 

**Screenshots Required:**
- [ ] User-facing error message
- [ ] Network tab with error response
- [ ] Retry mechanism UI

---

### 3.3 Rate Limiting Scenarios
**Objective:** Verify rate limiting prevents abuse

**Test Steps:**
1. [ ] Attempt rapid consecutive logins (10+ in 1 minute)
2. [ ] Use wrong credentials repeatedly
3. [ ] Test from different IPs (if possible)
4. [ ] Observe rate limiting behavior

**Expected Results:**
- [ ] Rate limiting activates after threshold
- [ ] Clear "too many attempts" message
- [ ] Cooldown period enforced
- [ ] Legitimate users not blocked indefinitely
- [ ] Different limits for auth vs other endpoints

**Actual Results:**
- [ ] 
- [ ] 
- [ ] 

**Screenshots Required:**
- [ ] Rate limit error message
- [ ] Network 429 responses
- [ ] Retry-after headers

---

## 4. EDGE CASE TESTS

### 4.1 Browser Refresh During Auth
**Objective:** Verify state recovery after refresh

**Test Steps:**
1. [ ] Start login process
2. [ ] Refresh browser mid-process
3. [ ] Check if process resumes or restarts
4. [ ] Test with password reset flow
5. [ ] Test with registration flow

**Expected Results:**
- [ ] Form state preserved where safe
- [ ] Sensitive data (password) not preserved
- [ ] User can continue or restart flow
- [ ] No broken state or errors
- [ ] Clear indication of where user is in flow

**Actual Results:**
- [ ] 
- [ ] 
- [ ] 

**Screenshots Required:**
- [ ] Form state after refresh
- [ ] Progress indicators
- [ ] Error states (if any)

---

### 4.2 Tab Duplication with Shared Session
**Objective:** Verify session consistency across tabs

**Test Steps:**
1. [ ] Login in Tab 1
2. [ ] Duplicate tab (right-click → duplicate)
3. [ ] Perform action in Tab 1 (logout, change settings)
4. [ ] Check Tab 2 state
5. [ ] Perform action in Tab 2

**Expected Results:**
- [ ] Sessions synchronized or handled per policy
- [ ] Clear notification if session invalidated
- [ ] No race conditions or data conflicts
- [ ] Graceful handling of expired sessions in other tabs

**Actual Results:**
- [ ] 
- [ ] 
- [ ] 

**Screenshots Required:**
- [ ] Multiple tabs with same session
- [ ] Synchronization notifications
- [ ] Conflict resolution UI

---

### 4.3 Cross-Origin Authentication Issues
**Objective:** Verify CORS/CSRF protection

**Test Steps:**
1. [ ] Check CORS headers on auth endpoints
2. [ ] Verify CSRF tokens in requests
3. [ ] Test from different origin (if possible)
4. [ ] Check security headers (HSTS, CSP)

**Expected Results:**
- [ ] Proper CORS headers present
- [ ] CSRF protection implemented
- [ ] Security headers configured
- [ ] No mixed content warnings
- [ ] Secure cookies (HttpOnly, Secure flags)

**Actual Results:**
- [ ] 
- [ ] 
- [ ] 

**Screenshots Required:**
- [ ] Response headers for auth endpoints
- [ ] Security headers
- [ ] Console warnings about CORS/security

---

## TEST COMPLETION CHECKLIST

### Documentation Complete:
- [ ] All test steps executed
- [ ] All expected/actual results documented
- [ ] All required screenshots captured
- [ ] Issues logged with severity ratings
- [ ] Workarounds documented

### Issues Categorized:
- [ ] P1: Critical - Blocks release
- [ ] P2: High - Must fix before release
- [ ] P3: Medium - Should fix, workaround exists
- [ ] P4: Low - Nice to have, cosmetic

### Test Report Generated:
- [ ] Executive summary
- [ ] Detailed findings
- [ ] Risk assessment
- [ ] Recommendations
- [ ] Next steps

---

**Tester:** Shuri (QA Agent)
**Test Date:** 2026-03-18
**Application Version:** PRDForge v1.0 (release-candidate-v1.0 branch)
**Test Environment:** http://localhost:8080

**Notes:** 
- Execute tests in order of priority (Session Expiry → Network Failure → Error Recovery → Edge Cases)
- Document all failures with exact steps to reproduce
- Capture network traffic for failed tests
- Note browser/device details for each test