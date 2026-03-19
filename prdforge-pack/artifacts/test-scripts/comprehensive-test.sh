#!/bin/bash

echo "PRDForge Comprehensive Compatibility Test"
echo "========================================="
echo "Test Date: $(date)"
echo "Application URL: http://localhost:8080"
echo ""

# Test 1: Basic HTTP connectivity
echo "1. Testing basic HTTP connectivity..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080)
if [ "$HTTP_STATUS" = "200" ]; then
    echo "   ✅ HTTP 200 OK"
else
    echo "   ❌ HTTP $HTTP_STATUS"
    exit 1
fi

# Test 2: Check page title
echo "2. Checking page title..."
PAGE_TITLE=$(curl -s http://localhost:8080 | grep -o "<title>[^<]*</title>" | sed 's/<title>//;s/<\/title>//')
EXPECTED_TITLE="PRDForge — AI-Powered PRD Design Platform"
if [[ "$PAGE_TITLE" == "$EXPECTED_TITLE" ]]; then
    echo "   ✅ Title matches: '$PAGE_TITLE'"
else
    echo "   ❌ Title mismatch: Got '$PAGE_TITLE', Expected '$EXPECTED_TITLE'"
fi

# Test 3: Check for required meta tags
echo "3. Checking for required meta tags..."
META_VIEWPORT=$(curl -s http://localhost:8080 | grep -i "viewport" | head -1)
if [[ -n "$META_VIEWPORT" ]]; then
    echo "   ✅ Viewport meta tag found"
else
    echo "   ❌ No viewport meta tag found"
fi

# Test 4: Check for JavaScript files
echo "4. Checking for JavaScript files..."
JS_FILES=$(curl -s http://localhost:8080 | grep -o 'src="[^"]*\.js[^"]*"' | wc -l)
if [ "$JS_FILES" -gt 0 ]; then
    echo "   ✅ $JS_FILES JavaScript file(s) found"
else
    echo "   ❌ No JavaScript files found"
fi

# Test 5: Check for CSS files
echo "5. Checking for CSS files..."
CSS_FILES=$(curl -s http://localhost:8080 | grep -o 'href="[^"]*\.css[^"]*"' | wc -l)
if [ "$CSS_FILES" -gt 0 ]; then
    echo "   ✅ $CSS_FILES CSS file(s) found"
else
    echo "   ❌ No CSS files found"
fi

# Test 6: Check for React markers
echo "6. Checking for React application..."
REACT_MARKER=$(curl -s http://localhost:8080 | grep -i "react\|root" | head -1)
if [[ -n "$REACT_MARKER" ]]; then
    echo "   ✅ React application markers found"
else
    echo "   ⚠️  No obvious React markers found"
fi

# Test 7: Check API endpoints (if any)
echo "7. Checking API endpoints..."
# Try common API endpoints
API_ENDPOINTS=("/api/health" "/api/status" "/health" "/status")
for endpoint in "${API_ENDPOINTS[@]}"; do
    API_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080$endpoint" 2>/dev/null || echo "000")
    if [ "$API_STATUS" = "200" ] || [ "$API_STATUS" = "404" ]; then
        echo "   ✅ Endpoint $endpoint responded with HTTP $API_STATUS"
    else
        echo "   ⚠️  Endpoint $endpoint not accessible (HTTP $API_STATUS)"
    fi
done

# Test 8: Check for common error patterns in HTML
echo "8. Checking for error patterns in HTML..."
ERROR_PATTERNS=("error" "exception" "failed" "cannot" "uncaught")
HTML_CONTENT=$(curl -s http://localhost:8080 | tr '[:upper:]' '[:lower:]')
for pattern in "${ERROR_PATTERNS[@]}"; do
    COUNT=$(echo "$HTML_CONTENT" | grep -o "$pattern" | wc -l)
    if [ "$COUNT" -gt 0 ]; then
        echo "   ⚠️  Found '$pattern' $COUNT time(s) in HTML"
    fi
done

echo ""
echo "Test Summary:"
echo "============="
echo "All basic checks completed."
echo ""
echo "Next steps for manual testing:"
echo "1. Open http://localhost:8080 in Chrome"
echo "2. Check browser console for JavaScript errors"
echo "3. Test authentication flows"
echo "4. Test PRD creation and editing"
echo "5. Test responsive design at different screen sizes"
echo "6. Repeat in Firefox, Safari, and Edge"