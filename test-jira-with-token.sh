#!/bin/bash

echo "🔗 Testing Jira API with available token sources..."
echo "=================================================="

# Try different token sources
TOKEN=""

# 1. Check environment variable
if [ -n "$ATLASSIAN_API_TOKEN" ]; then
    echo "✅ Found token in environment variable: ATLASSIAN_API_TOKEN"
    TOKEN="$ATLASSIAN_API_TOKEN"
elif [ -n "$JIRA_API_TOKEN" ]; then
    echo "✅ Found token in environment variable: JIRA_API_TOKEN"
    TOKEN="$JIRA_API_TOKEN"
fi

# 2. Check config file
CONFIG_FILE="/Users/clawdia/.openclaw/workspace/.jira.env"
if [ -z "$TOKEN" ] && [ -f "$CONFIG_FILE" ]; then
    echo "📁 Checking config file: $CONFIG_FILE"
    source "$CONFIG_FILE" 2>/dev/null
    if [ -n "$JIRA_API_TOKEN" ] && [ "$JIRA_API_TOKEN" != "your-api-token-here" ]; then
        echo "✅ Found token in config file"
        TOKEN="$JIRA_API_TOKEN"
    fi
fi

# 3. Check if we have credentials from earlier scripts
if [ -z "$TOKEN" ]; then
    echo "🔍 No token found in standard locations"
    echo ""
    echo "📝 To set up the token:"
    echo ""
    echo "METHOD 1: Set environment variable"
    echo "   export ATLASSIAN_API_TOKEN='your-token-here'"
    echo "   Then run this script again"
    echo ""
    echo "METHOD 2: Create config file"
    echo "   cp .jira.env.example .jira.env"
    echo "   nano .jira.env"
    echo "   # Replace 'your-api-token-here' with actual token"
    echo "   Then run this script again"
    echo ""
    echo "METHOD 3: Direct test with provided token"
    echo "   ./test-jira-direct.sh ATATT3xFfGF0...your-token"
    exit 1
fi

# We have a token, let's test it
echo ""
echo "🎯 Testing Jira API with token..."
echo "Token preview: ${TOKEN:0:12}..."

JIRA_URL="https://clawdianinan.atlassian.net"
EMAIL="clawdianinan@gmail.com"

echo "Testing connection to: $JIRA_URL"
echo "Using email: $EMAIL"

RESPONSE=$(curl -s -u "$EMAIL:$TOKEN" \
  -H "Accept: application/json" \
  "$JIRA_URL/rest/api/3/myself")

if echo "$RESPONSE" | grep -q "displayName"; then
    echo "✅ SUCCESS! Jira API connection working!"
    
    # Parse user info
    DISPLAY_NAME=$(echo "$RESPONSE" | grep -o '"displayName":"[^"]*"' | cut -d'"' -f4)
    ACCOUNT_ID=$(echo "$RESPONSE" | grep -o '"accountId":"[^"]*"' | cut -d'"' -f4)
    
    echo ""
    echo "👤 Connected as: $DISPLAY_NAME"
    echo "🆔 Account ID: $ACCOUNT_ID"
    echo ""
    
    # Test project access
    echo "📊 Testing project access..."
    PROJECT_RESPONSE=$(curl -s -u "$EMAIL:$TOKEN" \
        -H "Accept: application/json" \
        "$JIRA_URL/rest/api/3/project/DEV")
    
    if echo "$PROJECT_RESPONSE" | grep -q "key"; then
        PROJECT_NAME=$(echo "$PROJECT_RESPONSE" | grep -o '"name":"[^"]*"' | cut -d'"' -f4)
        echo "✅ Project access successful: $PROJECT_NAME"
    else
        echo "⚠️  Could not access DEV project (might not exist)"
    fi
    
    echo ""
    echo "🚀 Ready to update tickets! Run:"
    echo "   ./update-jira-tickets-complete.sh"
    
else
    echo "❌ API connection failed"
    echo "Response: ${RESPONSE:0:200}"
    echo ""
    echo "🔧 Possible issues:"
    echo "1. Token expired or invalid"
    echo "2. Email address incorrect"
    echo "3. Token doesn't have API permissions"
    echo "4. Network/connectivity issue"
fi