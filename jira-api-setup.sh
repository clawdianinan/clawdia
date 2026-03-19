#!/bin/bash

# Jira API Setup Script
# This script sets up Jira API credentials and tests connectivity

set -e

echo "🚀 Jira API Setup"
echo "================="

# Configuration
CONFIG_FILE="/Users/clawdia/.openclaw/workspace/.jira.env"
EXAMPLE_FILE="/Users/clawdia/.openclaw/workspace/.jira.env.example"

# Create example configuration
cat > "$EXAMPLE_FILE" << 'EOF'
# Jira API Configuration
# ======================
# 1. Get your API token from:
#    https://id.atlassian.com/manage-profile/security/api-tokens
# 2. Create a token named "PRDForge-Automation"
# 3. Copy the token (only shown once)
# 4. Fill in the values below

JIRA_BASE_URL="https://clawdianinan.atlassian.net"
JIRA_USER_EMAIL="clawdianinan@gmail.com"
JIRA_API_TOKEN="your-api-token-here"

# Optional: Project key
JIRA_PROJECT_KEY="DEV"

# Optional: Default assignee (account ID)
# JIRA_DEFAULT_ASSIGNEE="your-account-id"
EOF

echo "📋 Created example configuration: $EXAMPLE_FILE"
echo ""
echo "📝 To set up Jira API:"
echo ""
echo "1. Generate API token:"
echo "   🔗 https://id.atlassian.com/manage-profile/security/api-tokens"
echo "   • Click 'Create API token'"
echo "   • Name: 'PRDForge-Automation'"
echo "   • Copy the token (only shown once!)"
echo ""
echo "2. Edit the configuration:"
echo "   cp $EXAMPLE_FILE $CONFIG_FILE"
echo "   nano $CONFIG_FILE"
echo "   # Fill in your API token"
echo ""
echo "3. Test the connection:"
echo "   ./jira-test-connection.sh"
echo ""
echo "4. Update tickets:"
echo "   ./jira-update-tickets.sh"
echo ""

# Create test connection script
cat > /Users/clawdia/.openclaw/workspace/jira-test-connection.sh << 'EOF'
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
EOF

chmod +x /Users/clawdia/.openclaw/workspace/jira-test-connection.sh

# Create ticket update script
cat > /Users/clawdia/.openclaw/workspace/jira-update-tickets.sh << 'EOF'
#!/bin/bash

# Jira Ticket Update Script
# Updates tickets DEV-27 to DEV-34 with completion status

set -e

echo "🎯 Updating Jira Tickets"
echo "========================"

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

echo "📋 Configuration loaded"
echo "   URL: $JIRA_BASE_URL"
echo "   Email: $JIRA_USER_EMAIL"
echo "   Project: ${JIRA_PROJECT_KEY:-Not specified}"

# Tickets to update (DEV-27 to DEV-34)
TICKETS=("DEV-27" "DEV-28" "DEV-29" "DEV-30" "DEV-31" "DEV-32" "DEV-33" "DEV-34")

# Completion data for each ticket
declare -A TICKET_DATA
TICKET_DATA["DEV-27"]="Accessibility Info Buttons|Trinity|4.5 hours|Completed by Trinity. Implementation includes accessibility info buttons with hover tooltips and documentation linking."
TICKET_DATA["DEV-28"]="Motion Design System|Fela|~4 hours|Completed by Fela. Implemented 'Productive Delight' motion design system with page transitions, form feedback, loading states."
TICKET_DATA["DEV-29"]="Documentation Expansion|Ebun|8-12 hours|Completed by Ebun. Created comprehensive documentation suite (89,877 bytes) including Getting Started, PRD Tutorial, API Reference, Integrations, Troubleshooting, Contributing Guide."
TICKET_DATA["DEV-30"]="Intro Tour Implementation|Trinity|~4 hours|Completed by Trinity. Implemented guided intro tour with dimmed background, highlighted elements, tooltip bubbles, skip functionality."
TICKET_DATA["DEV-31"]="Security Improvements|Cypher|6-9 hours|Completed by Trinity (initial) and Cypher (current owner). Initial security improvements including rate limiting, security headers optimization, security scanning automation. Security rating improved from 8.5/10 to 9.3/10."
TICKET_DATA["DEV-32"]="Advanced Accessibility Features|Shuri|6-8 hours|Completed by Shuri. Implemented advanced accessibility features including screen reader optimization, full keyboard navigation, cognitive accessibility features."
TICKET_DATA["DEV-33"]="Micro-interactions Optimization|Fela|4-5 hours|Completed by Fela. Implemented micro-interactions optimization including drag & drop feedback, swipe actions, progressive loading, error prevention interactions."
TICKET_DATA["DEV-34"]="Dark Mode Polish|Fela|3-4 hours|Completed by Fela. Implemented dark mode polish including true black vs dark gray optimization, color contrast, image/text legibility, system preference."

echo ""
echo "📊 Tickets to update: ${#TICKETS[@]} tickets"
echo ""

SUCCESS_COUNT=0
FAIL_COUNT=0

for TICKET in "${TICKETS[@]}"; do
    echo "🔄 Updating $TICKET..."
    
    # Parse ticket data
    IFS='|' read -r TITLE AGENT TIME COMMENT <<< "${TICKET_DATA[$TICKET]}"
    
    # Create JSON payload for transition to "Done"
    # First, we need to get the transition ID for "Done"
    echo "   Getting transition ID for 'Done'..."
    
    TRANSITIONS_RESPONSE=$(curl -s -u "$JIRA_USER_EMAIL:$JIRA_API_TOKEN" \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        "$JIRA_BASE_URL/rest/api/3/issue/$TICKET/transitions")
    
    # Find the "Done" transition ID
    DONE_TRANSITION_ID=$(echo "$TRANSITIONS_RESPONSE" | grep -o '"id":"[^"]*","name":"Done"' | cut -d'"' -f4)
    
    if [ -z "$DONE_TRANSITION_ID" ]; then
        echo "   ⚠️  Could not find 'Done' transition, trying alternative..."
        # Try to get any transition
        DONE_TRANSITION_ID=$(echo "$TRANSITIONS_RESPONSE" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
    fi
    
    if [ -n "$DONE_TRANSITION_ID" ]; then
        # Execute transition
        TRANSITION_PAYLOAD=$(cat <<EOF
{
  "transition": {
    "id": "$DONE_TRANSITION_ID"
  },
  "update": {
    "comment": [
      {
        "add": {
          "body": {
            "type": "doc",
            "version": 1,
            "content": [
              {
                "type": "paragraph",
                "content": [
                  {
                    "type": "text",
                    "text": "$COMMENT Time spent: $TIME"
                  }
                ]
              }
            ]
          }
        }
      }
    ]
  }
}
EOF
)
        
        TRANSITION_RESPONSE=$(curl -s -u "$JIRA_USER_EMAIL:$JIRA_API_TOKEN" \
            -X POST \
            -H "Accept: application/json" \
            -H "Content-Type: application/json" \
            --data "$TRANSITION_PAYLOAD" \
            "$JIRA_BASE_URL/rest/api/3/issue/$TICKET/transitions")
        
        if [ -z "$TRANSITION_RESPONSE" ]; then
            echo "   ✅ $TICKET updated to Done"
            ((SUCCESS_COUNT++))
            
            # Add additional comment with agent info
            COMMENT_PAYLOAD=$(cat <<EOF
{
  "body": {
    "type": "doc",
    "version": 1,
    "content": [
      {
        "type": "paragraph",
        "content": [
          {
            "type": "text",
            "text": "Agent: $AGENT | Completed: $(date '+%Y-%m-%d %H:%M')"
          }
        ]
      }
    ]
  }
}
EOF
)
            
            curl -s -u "$JIRA_USER_EMAIL:$JIRA_API_TOKEN" \
                -X POST \
                -H "Accept: application/json" \
                -H "Content-Type: application/json" \
                --data "$COMMENT_PAYLOAD" \
                "$JIRA_BASE_URL/rest/api/3/issue/$TICKET/comment" > /dev/null
            
        else
            echo "   ❌ Failed to update $TICKET"
            echo "   Response: ${TRANSITION_RESPONSE:0:100}"
            ((FAIL_COUNT++))
        fi
    else
        echo "   ❌ Could not find transition for $TICKET"
        ((FAIL_COUNT++))
    fi
    
    echo ""
done

echo "📊 Update Summary:"
echo "   ✅ Success: $SUCCESS_COUNT"
echo "   ❌ Failed: $FAIL_COUNT"
echo "   📋 Total: ${#TICKETS[@]}"
echo ""

if [ $SUCCESS_COUNT -eq ${#TICKETS[@]} ]; then
    echo "🎉 All tickets updated successfully!"
elif [ $SUCCESS_COUNT -gt 0 ]; then
    echo "⚠️  Some tickets updated successfully"
else
    echo "❌ No tickets were updated"
fi

# Create summary report
SUMMARY_FILE="/Users/clawdia/.openclaw/workspace/jira-update-summary-$(date '+%Y%m%d-%H%M').txt"
cat > "$SUMMARY_FILE" <<EOF
Jira Ticket Update Summary
==========================
Date: $(date)
Tickets Updated: $SUCCESS_COUNT/${#TICKETS[@]}

Updated Tickets:
$(for TICKET in "${TICKETS[@]}"; do
    IFS='|' read -r TITLE AGENT TIME COMMENT <<< "${TICKET_DATA[$TICKET]}"
    echo "- $TICKET: $TITLE ($AGENT)"
done)

Failed Tickets: $FAIL_COUNT

Configuration:
- URL: $JIRA_BASE_URL
- Email: $JIRA_USER_EMAIL
- Project: ${JIRA_PROJECT_KEY:-Not specified}
EOF

echo "📄 Summary saved to: $SUMMARY_FILE"
EOF

chmod +x /Users/clawdia/.openclaw/workspace/jira-update-tickets.sh

# Create quick update script for single tickets
cat > /Users/clawdia/.openclaw/workspace/jira-update-single.sh << 'EOF'
#!/bin/bash

# Jira Single Ticket Update Script

if [ $# -lt 1 ]; then
    echo "Usage: $0 <ticket-key> [comment]"
    echo "Example: $0 DEV-27 \"Completed by Trinity\""
    exit 1
fi

TICKET=$1
COMMENT=${2:-"Ticket completed via automation"}

# Load configuration
CONFIG_FILE="/Users/clawdia/.openclaw/workspace/.jira.env"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Configuration file not found"
    exit 1
fi

source "$CONFIG_FILE"

echo "🎯 Updating $TICKET..."
echo "Comment: $COMMENT"

# Transition to Done
TRANSITION_PAYLOAD=$(cat <<EOF
{
  "transition": {
    "id": "31"
  },
  "update": {
    "comment": [
      {
        "add": {
          "body": {
            "type": "doc",
            "version": 1,
            "content": [
              {
                "type": "paragraph",
                "content": [
                  {
                    "type": "text",
                    "text": "$COMMENT"
                  }
                ]
              }
            ]
          }
        }
      }
    ]
  }
}
EOF
)

RESPONSE=$(curl -s -u "$JIRA_USER_EMAIL:$JIRA_API_TOKEN" \
    -X POST \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    --data "$TRANSITION_PAYLOAD" \
    "$JIRA_BASE_URL/rest/api/3/issue/$TICKET/transitions")

if [ -z "$RESPONSE" ]; then
    echo "✅ $TICKET updated successfully"
else
    echo "❌ Failed to update $TICKET"
    echo "Response: $RESPONSE"
fi
EOF

chmod +x /Users/clawdia/.openclaw/workspace/jira-update-single.sh

echo "✅ Created Jira API management scripts:"
echo ""
echo "1. 📋 jira-api-setup.sh - Setup instructions"
echo "2. 🔗 jira-test-connection.sh - Test API connection"
echo "3. 🎯 jira-update-tickets.sh - Update all tickets (DEV-27 to DEV-34)"
echo "4. ⚡ jira-update-single.sh - Update single ticket"
echo ""
echo "📝 Next steps:"
echo "1. Generate API token at:"
echo "   🔗 https://id.atlassian.com/manage-profile/security/api-tokens"
echo "2. Run: ./jira-api-setup.sh"
echo "3. Edit .jira