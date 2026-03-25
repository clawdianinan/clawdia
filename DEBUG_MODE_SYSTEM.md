# 🐛 DEBUG MODE SYSTEM - Agent Error Visibility

## 🎯 Purpose
Toggleable debug mode that provides enhanced error visibility for agents during troubleshooting and development.

## 🔧 How It Works

### **Debug Mode States:**
- **OFF:** Normal production error handling (user-friendly messages)
- **ON:** Enhanced error details (stack traces, environment info, debugging data)
- **VERBOSE:** Maximum debugging (request/response logs, timing, full context)

### **Activation Methods:**
1. **Environment Variable:** `DEBUG_MODE=true`
2. **URL Parameter:** `?debug=true`
3. **Local Storage:** `localStorage.setItem('debugMode', 'true')`
4. **Admin Panel:** Toggle in application settings

## 🚀 Implementation for PRDForge

### **1. Edge Function Debug Enhancement:**

**Current Edge Function (`prdforge-api`):**
```javascript
// BEFORE (normal):
if (error) {
  return new Response(JSON.stringify({ error: 'Something went wrong' }), {
    status: 500,
    headers: { 'Content-Type': 'application/json' }
  });
}

// AFTER (with debug mode):
if (error) {
  const response = { error: 'Something went wrong' };
  
  // Add debug info if debug mode is enabled
  if (req.headers.get('x-debug-mode') === 'true' || 
      process.env.DEBUG_MODE === 'true') {
    response.debug = {
      message: error.message,
      stack: error.stack,
      timestamp: new Date().toISOString(),
      function: 'prdforge-api',
      environment: process.env.NODE_ENV,
      requestId: req.headers.get('x-request-id')
    };
  }
  
  return new Response(JSON.stringify(response), {
    status: 500,
    headers: { 'Content-Type': 'application/json' }
  });
}
```

### **2. Frontend Debug Toggle:**

**Create `DebugToggle` component:**
```jsx
// components/DebugToggle.jsx
import { useState, useEffect } from 'react';

export function DebugToggle() {
  const [debugMode, setDebugMode] = useState(
    localStorage.getItem('debugMode') === 'true' || 
    new URLSearchParams(window.location.search).has('debug')
  );

  useEffect(() => {
    // Add debug header to all fetch requests
    const originalFetch = window.fetch;
    window.fetch = function(...args) {
      if (debugMode) {
        const [url, options = {}] = args;
        options.headers = {
          ...options.headers,
          'x-debug-mode': 'true',
          'x-debug-timestamp': Date.now()
        };
        return originalFetch(url, options);
      }
      return originalFetch(...args);
    };

    return () => {
      window.fetch = originalFetch;
    };
  }, [debugMode]);

  const toggleDebug = () => {
    const newValue = !debugMode;
    setDebugMode(newValue);
    localStorage.setItem('debugMode', newValue.toString());
    
    // Reload to apply debug headers
    if (newValue) {
      window.location.search = '?debug=true';
    } else {
      window.location.search = '';
    }
  };

  return (
    <div className="debug-toggle">
      <button onClick={toggleDebug}>
        {debugMode ? '🐛 Debug ON' : '🚀 Debug OFF'}
      </button>
      {debugMode && (
        <div className="debug-info">
          Debug mode active - Enhanced error details enabled
        </div>
      )}
    </div>
  );
}
```

### **3. Enhanced Error Display:**

**ErrorDisplay component with debug:**
```jsx
// components/ErrorDisplay.jsx
export function ErrorDisplay({ error, debugData }) {
  const isDebugMode = localStorage.getItem('debugMode') === 'true';
  
  return (
    <div className="error-display">
      <h3>⚠️ Something went wrong</h3>
      <p>{error.message || 'An unexpected error occurred'}</p>
      
      {isDebugMode && debugData && (
        <div className="debug-details">
          <h4>🐛 Debug Details:</h4>
          <pre>{JSON.stringify(debugData, null, 2)}</pre>
          
          <details>
            <summary>Technical Details</summary>
            <ul>
              <li><strong>Timestamp:</strong> {debugData.timestamp}</li>
              <li><strong>Function:</strong> {debugData.function}</li>
              <li><strong>Environment:</strong> {debugData.environment}</li>
              <li><strong>Request ID:</strong> {debugData.requestId}</li>
            </ul>
          </details>
          
          {debugData.stack && (
            <details>
              <summary>Stack Trace</summary>
              <pre>{debugData.stack}</pre>
            </details>
          )}
        </div>
      )}
      
      {isDebugMode && (
        <div className="debug-actions">
          <button onClick={() => navigator.clipboard.writeText(JSON.stringify(debugData, null, 2))}>
            Copy Debug Info
          </button>
          <button onClick={() => console.log('Debug Data:', debugData)}>
            Log to Console
          </button>
        </div>
      )}
    </div>
  );
}
```

## 🔧 Agent Debug Tools

### **1. Debug Mode Activation Script:**
```bash
#!/bin/bash
# scripts/activate-debug.sh

# Activate debug mode for PRDForge
echo "Activating debug mode..."

# Method 1: Environment variable (for Edge Functions)
export DEBUG_MODE=true

# Method 2: Update Supabase environment
supabase secrets set DEBUG_MODE=true

# Method 3: Update Netlify environment
netlify env:set DEBUG_MODE true

echo "✅ Debug mode activated"
echo "Access site with: https://prdforge-dev.netlify.app?debug=true"
```

### **2. Debug Information Collector:**
```bash
#!/bin/bash
# scripts/collect-debug-info.sh

# Collect comprehensive debug information
echo "=== PRDFORGE DEBUG INFORMATION COLLECTOR ==="
echo "Timestamp: $(date)"
echo ""

# 1. Edge Function Status
echo "1. Edge Function Status:"
supabase functions list
echo ""

# 2. Environment Variables
echo "2. Environment Variables:"
supabase secrets list
echo ""

# 3. Database Connections
echo "3. Database Connection Test:"
PGPASSWORD="cVHV8VFB61QVd8nv" psql -h "db.eflrqvxmqrtbytkxyrze.supabase.co" -p 5432 -U "postgres" -d "postgres" -c "SELECT version();" 2>&1
echo ""

# 4. Network Connectivity
echo "4. Network Connectivity:"
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" "https://prdforge-dev.netlify.app"
echo ""

# 5. OAuth Endpoints
echo "5. OAuth Endpoint Status:"
curl -s -o /dev/null -w "GitHub OAuth: %{http_code}\n" "https://prdforge-dev.netlify.app/auth/github"
curl -s -o /dev/null -w "Google OAuth: %{http_code}\n" "https://prdforge-dev.netlify.app/auth/google"
echo ""

echo "✅ Debug information collected"
```

## 🎯 Agent Workflow with Debug Mode

### **When Agents Encounter Errors:**

1. **Activate Debug Mode:**
   ```bash
   ./scripts/activate-debug.sh
   ```

2. **Reproduce Error with Debug Headers:**
   ```bash
   curl -H "x-debug-mode: true" https://prdforge-dev.netlify.app/api/edge-function
   ```

3. **Collect Debug Information:**
   ```bash
   ./scripts/collect-debug-info.sh > debug_report_$(date +%Y%m%d_%H%M%S).md
   ```

4. **Analyze Enhanced Error Details:**
   - Stack traces
   - Environment variables
   - Request/response logs
   - Database connection status

5. **Fix Issue & Deactivate Debug:**
   ```bash
   supabase secrets unset DEBUG_MODE
   ```

## 📋 Debug Mode Rules

### **When to Enable:**
- Agent troubleshooting sessions
- Production issue investigation
- Development and testing
- Performance optimization

### **When to Disable:**
- Normal user operations
- Production deployment
- Security-sensitive operations
- Performance-critical paths

### **Security Considerations:**
- Debug mode exposes internal details
- Use only in controlled environments
- Never expose debug mode in production to end users
- Rotate debug access tokens regularly

## 🚀 Implementation Priority

### **Phase 1 (Immediate):**
1. Add debug headers to Edge Functions
2. Create basic debug toggle component
3. Implement enhanced error display

### **Phase 2 (Short-term):**
1. Agent debug scripts
2. Debug information collector
3. Debug mode persistence

### **Phase 3 (Long-term):**
1. Admin debug dashboard
2. Automated debug reporting
3. Performance profiling integration

## 📊 Success Metrics

### **Debug Mode Effectiveness:**
- Reduced troubleshooting time
- Improved error resolution rate
- Better agent productivity
- Enhanced system reliability

### **Agent Experience:**
- Clear error details
- Actionable debug information
- Easy mode toggling
- Comprehensive diagnostics

---

**Status:** 🚀 READY FOR IMPLEMENTATION
**Priority:** HIGH - Critical for agent troubleshooting
**Security:** MEDIUM - Requires controlled access
**Impact:** SIGNIFICANT - Dramatically improves agent debugging capability