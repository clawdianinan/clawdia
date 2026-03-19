#!/bin/bash

# Jira API Test Connection Script

set -e

echo "🔗 Testing Jira API Connection"
echo "=============================="

# Load configuration
CONFIG_FILE="/Users/clawdia/.openclaw/workspace/.jira.env"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Configuration file not found: $CONFIG_FILE"
    echo "📝 Run ./jira-api-setup.sh first"
    exit 1
fi

source "$CONFIG_FILE"

# Validate configuration
if [ -z "$JIRA_BASE_URL" ] || [ -z "$JIRA_USER_EMAIL" ] || [ -z "$JIRA_API_TOKEN" ]; then
    echo "❌ Missing configuration values"
    echo "   Please check $CONFIG_FILE"
    exit 1
fi

echo "📋 Configuration:"
echo "   URL: $JIRA_BASE_URL"
echo "   Email: $JIRA_USER_EMAIL"
echo "   Token: ${JIRA_API_TOKEN:0:8}..."

# Test API connection
echo ""
echo "📡 Testing API connection..."

RESPONSE=$(curl -s -u "$JIRA_USER_EMAIL:$JIRA_API_TOKEN" \
    -H "Accept: application/json" \
    "$JIRA_BASE_URL/rest/api/3/myself")

if echo "$RESPONSE" | grep -q "displayName"; then
    echo "✅ API connection successful!"
    
    # Parse response
    DISPLAY_NAME=$(echo "$RESPONSE" | grep -o '"displayName":"[^"]*"' | cut -d'"' -f4)
    ACCOUNT_ID=$(echo "$RESPONSE" | grep -o '"accountId":"[^"]*"' | cut -d'"' -f4)
    EMAIL_ADDRESS=$(echo "$RESPONSE" | grep -o '"emailAddress":"[^"]*"' | cut -d'"' -f4)
    
    echo ""
    echo "👤 User Information:"
    echo "   Name: $DISPLAY_NAME"
    echo "   Account ID: $ACCOUNT_ID"
    echo "   Email: $EMAIL_ADDRESS"
    
    # Update config with account ID
    if [ -n "$ACCOUNT_ID" ]; then
        if ! grep -q "JIRA_ACCOUNT_ID" "$CONFIG_FILE"; then
            echo "JIRA_ACCOUNT_ID=\"$ACCOUNT_ID\"" >> "$CONFIG_FILE"
            echo "💾 Added account ID to configuration"
        fi
    fi
    
else
    echo "❌ API connection failed"
    echo "Response: ${RESPONSE:0:200}"
    echo ""
    echo "🔧 Troubleshooting:"
    echo "1. Check API token is correct"
    echo "2. Verify email address"
    echo "3. Ensure token has necessary permissions"
    echo "4. Check network connectivity"
    exit 1
fi

# Test project access
if [ -n "$JIRA_PROJECT_KEY" ]; then
    echo ""
    echo "📊 Testing project access: $JIRA_PROJECT_KEY"
    
    PROJECT_RESPONSE=$(curl -s -u "$JIRA_USER_EMAIL:$JIRA_API_TOKEN" \
        -H "Accept: application/json" \
        "$JIRA_BASE_URL/rest/api/3/project/$JIRA_PROJECT_KEY")
    
    if echo "$PROJECT_RESPONSE" | grep -q "key"; then
        PROJECT_NAME=$(echo "$PROJECT_RESPONSE" | grep -o '"name":"[^"]*"' | cut -d'"' -f4)
        echo "✅ Project access successful: $PROJECT_NAME"
    else
        echo "⚠️  Could not access project $JIRA_PROJECT_KEY"
        echo "   (This may be normal if project doesn't exist)"
    fi
fi

echo ""
echo "🎉 Jira API is ready for use!"
echo "Next: Run ./jira-update-tickets.sh to update tickets"
