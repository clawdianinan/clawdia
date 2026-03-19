# Debugging Assistant Skill

## Purpose
Follow systematic debugging methodology to diagnose and fix runtime issues.

## Four-Phase Debugging Methodology

### Phase 1: Root Cause Investigation
1. **Reproduce the issue**
   - Exact steps to trigger
   - Environment details
   - Frequency (always/sometimes)

2. **Gather evidence**
   - Error messages and stack traces
   - Console logs
   - Network requests
   - System logs

3. **Isolate the component**
   - Minimal reproduction
   - Remove unrelated code
   - Test in isolation

### Phase 2: Pattern Analysis
1. **Identify patterns**
   - When does it work vs. fail?
   - Common factors in failures
   - Timing or sequence issues

2. **Check dependencies**
   - Version compatibility
   - Configuration differences
   - Environment variables

3. **Review recent changes**
   - Code changes
   - Dependency updates
   - Configuration changes
   - Deployment changes

### Phase 3: Hypothesis Testing
1. **Formulate hypotheses**
   - Based on evidence
   - Testable predictions
   - Prioritize by likelihood

2. **Test hypotheses**
   - Create controlled tests
   - Modify one variable at a time
   - Document results

3. **Validate findings**
   - Confirm root cause
   - Verify fix addresses issue
   - Test edge cases

### Phase 4: Implementation & Validation
1. **Implement fix**
   - Minimal changes
   - Follow coding standards
   - Add tests

2. **Test thoroughly**
   - Original issue fixed
   - No regression
   - Edge cases handled

3. **Document solution**
   - Root cause analysis
   - Fix description
   - Prevention measures

## Common Debugging Scenarios

### React/Next.js Blank Page
1. Check browser console for errors
2. Verify React hydration
3. Check environment variables
4. Verify build process
5. Check runtime dependencies

### API/Network Issues
1. Check network tab
2. Verify CORS headers
3. Check authentication
4. Verify request/response format
5. Test with curl/postman

### Database Issues
1. Check connection strings
2. Verify schema compatibility
3. Check query performance
4. Verify data migration
5. Check transaction isolation

## Output Format
```
## Debugging Report

### Issue Summary
[Brief description]

### Reproduction Steps
1. [Step 1]
2. [Step 2]

### Evidence Collected
- Error: [Error message]
- Logs: [Relevant logs]
- Network: [Network issues]
- Environment: [Env details]

### Root Cause Analysis
[Detailed analysis]

### Hypothesis Testing Results
1. [Hypothesis 1]: [Result]
2. [Hypothesis 2]: [Result]

### Identified Root Cause
[Root cause]

### Recommended Fix
[Fix description]

### Implementation Steps
1. [Step 1]
2. [Step 2]

### Validation Plan
1. [Test 1]
2. [Test 2]

### Prevention Measures
1. [Measure 1]
2. [Measure 2]
```