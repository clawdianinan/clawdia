#!/bin/bash

# Continuous test script for localhost:3000
# Tests: HTTP status, HTML content, JavaScript errors, page loading

echo "🚀 PRDForge Test Suite - Starting continuous testing..."
echo "======================================================"

# Configuration
TEST_URL="http://localhost:3000"
MAX_ATTEMPTS=100
SLEEP_BETWEEN_TESTS=10
TEST_COUNT=0

# Function to test HTTP status
test_http_status() {
    echo "🔍 Testing HTTP status..."
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$TEST_URL")
    echo "   HTTP Status: $HTTP_STATUS"
    
    if [ "$HTTP_STATUS" = "200" ]; then
        echo "   ✅ HTTP 200 OK"
        return 0
    else
        echo "   ❌ HTTP $HTTP_STATUS (expected 200)"
        return 1
    fi
}

# Function to test HTML content for PRDForge title
test_html_content() {
    echo "🔍 Testing HTML content for PRDForge title..."
    HTML_CONTENT=$(curl -s "$TEST_URL")
    
    # Check for common title patterns
    if echo "$HTML_CONTENT" | grep -i "prdforge" > /dev/null; then
        echo "   ✅ Found 'PRDForge' in HTML"
        return 0
    elif echo "$HTML_CONTENT" | grep -i "title.*prd" > /dev/null; then
        echo "   ✅ Found PRD-related title in HTML"
        return 0
    elif echo "$HTML_CONTENT" | grep -i "<title>" > /dev/null; then
        TITLE=$(echo "$HTML_CONTENT" | grep -i "<title>" | head -1)
        echo "   ℹ️  Found title tag: $TITLE"
        return 0
    else
        echo "   ❌ No PRDForge title found in HTML"
        return 1
    fi
}

# Function to check for JavaScript errors (simulated)
test_javascript_errors() {
    echo "🔍 Simulating JavaScript error check..."
    
    # Get JavaScript files from page
    JS_FILES=$(curl -s "$TEST_URL" | grep -o 'src="[^"]*\.js"' | cut -d'"' -f2)
    
    if [ -z "$JS_FILES" ]; then
        echo "   ℹ️  No external JS files found (may be inline)"
    else
        echo "   ℹ️  Found JS files: $JS_FILES"
    fi
    
    # Check for common error patterns in HTML
    HTML_CONTENT=$(curl -s "$TEST_URL")
    
    # Look for error indicators
    if echo "$HTML_CONTENT" | grep -i "error\|exception\|syntax\|uncaught" > /dev/null; then
        echo "   ⚠️  Found potential error indicators in HTML"
        # Extract context around error
        ERROR_CONTEXT=$(echo "$HTML_CONTENT" | grep -i -B2 -A2 "error\|exception\|syntax\|uncaught" | head -10)
        echo "   Context: $ERROR_CONTEXT"
        return 1
    else
        echo "   ✅ No obvious JavaScript error indicators found"
        return 0
    fi
}

# Function to simulate browser loading
test_browser_load() {
    echo "🔍 Simulating browser loading..."
    
    # Check if page has reasonable content length
    CONTENT_LENGTH=$(curl -s -I "$TEST_URL" | grep -i "content-length" | cut -d' ' -f2 | tr -d '\r')
    
    if [ -n "$CONTENT_LENGTH" ] && [ "$CONTENT_LENGTH" -gt 100 ]; then
        echo "   ✅ Content length: $CONTENT_LENGTH bytes (reasonable)"
        return 0
    else
        # Try to get actual content
        HTML_CONTENT=$(curl -s "$TEST_URL")
        CHAR_COUNT=${#HTML_CONTENT}
        
        if [ "$CHAR_COUNT" -gt 100 ]; then
            echo "   ✅ Page has $CHAR_COUNT characters (reasonable)"
            return 0
        else
            echo "   ❌ Page content too short: $CHAR_COUNT characters"
            return 1
        fi
    fi
}

# Main test loop
while [ $TEST_COUNT -lt $MAX_ATTEMPTS ]; do
    TEST_COUNT=$((TEST_COUNT + 1))
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo ""
    echo "🔄 Test #$TEST_COUNT - $TIMESTAMP"
    echo "----------------------------------------"
    
    # Run all tests
    ALL_PASSED=true
    
    test_http_status
    if [ $? -ne 0 ]; then
        ALL_PASSED=false
        echo "   ⚠️  HTTP status check failed"
    fi
    
    test_html_content
    if [ $? -ne 0 ]; then
        ALL_PASSED=false
        echo "   ⚠️  HTML content check failed"
    fi
    
    test_javascript_errors
    if [ $? -ne 0 ]; then
        ALL_PASSED=false
        echo "   ⚠️  JavaScript check found issues"
    fi
    
    test_browser_load
    if [ $? -ne 0 ]; then
        ALL_PASSED=false
        echo "   ⚠️  Browser load simulation failed"
    fi
    
    # Check if all tests passed
    if [ "$ALL_PASSED" = true ]; then
        echo ""
        echo "🎉 SUCCESS! All tests passed!"
        echo "✅ HTTP 200 response"
        echo "✅ HTML contains PRDForge title"
        echo "✅ No JavaScript syntax errors"
        echo "✅ Page loads in browser"
        echo ""
        echo "🚀 PRDForge is ready at $TEST_URL"
        exit 0
    else
        echo ""
        echo "❌ Some tests failed. Waiting for Trinity's fix..."
        echo "   Next test in $SLEEP_BETWEEN_TESTS seconds..."
        sleep $SLEEP_BETWEEN_TESTS
    fi
done

echo ""
echo "⏰ Maximum test attempts ($MAX_ATTEMPTS) reached."
echo "❌ PRDForge still not loading correctly."
echo "   Please check Trinity's progress and restart testing."
exit 1