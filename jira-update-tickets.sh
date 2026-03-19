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
