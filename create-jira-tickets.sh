#!/bin/bash

echo "🚀 CREATING JIRA TICKETS DEV-27 to DEV-34"
echo "=========================================="

source ~/.zshrc 2>/dev/null

JIRA_URL="https://clawdianinan.atlassian.net"
EMAIL="clawdianinan@gmail.com"
TOKEN="$ATLASSIAN_API_TOKEN"
PROJECT_KEY="DEV"

if [ -z "$TOKEN" ]; then
    echo "❌ Token not set"
    exit 1
fi

echo "✅ Token: ${TOKEN:0:12}..."
echo "📧 Email: $EMAIL"
echo "🎯 Project: $PROJECT_KEY"
echo ""

# Ticket data
declare -A TICKETS
TICKETS["DEV-27"]="Accessibility Info Buttons|Implement accessibility info buttons with hover tooltips and documentation linking.|Trinity"
TICKETS["DEV-28"]="Motion Design System|Implement 'Productive Delight' motion design system with page transitions, form feedback, loading states.|Fela"
TICKETS["DEV-29"]="Documentation Expansion|Create comprehensive documentation suite including Getting Started, PRD Tutorial, API Reference, Integrations, Troubleshooting, Contributing Guide.|Ebun"
TICKETS["DEV-30"]="Intro Tour Implementation|Implement guided intro tour with dimmed background, highlighted elements, tooltip bubbles, skip functionality.|Trinity"
TICKETS["DEV-31"]="Security Improvements|Initial security improvements including rate limiting, security headers optimization, security scanning automation. Security rating improved from 8.5/10 to 9.3/10.|Cypher"
TICKETS["DEV-32"]="Advanced Accessibility Features|Implement advanced accessibility features including screen reader optimization, full keyboard navigation, cognitive accessibility features.|Shuri"
TICKETS["DEV-33"]="Micro-interactions Optimization|Implement micro-interactions optimization including drag & drop feedback, swipe actions, progressive loading, error prevention interactions.|Fela"
TICKETS["DEV-34"]="Dark Mode Polish|Implement dark mode polish including true black vs dark gray optimization, color contrast, image/text legibility, system preference.|Fela"

CREATED=0
FAILED=0
LOG_FILE="/Users/clawdia/.openclaw/workspace/jira-create-$(date '+%Y%m%d-%H%M').log"

echo "Creating 8 tickets..." | tee "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

for KEY in "${!TICKETS[@]}"; do
    IFS='|' read -r SUMMARY DESCRIPTION ASSIGNEE <<< "${TICKETS[$KEY]}"
    
    echo "--- Creating $KEY ---" | tee -a "$LOG_FILE"
    echo "Summary: $SUMMARY" | tee -a "$LOG_FILE"
    echo "Assignee: $ASSIGNEE" | tee -a "$LOG_FILE"
    
    # Create JSON payload
    # Note: We need to use accountId for assignee, but we'll create unassigned first
    PAYLOAD=$(cat <<EOF
{
  "fields": {
    "project": {
      "key": "$PROJECT_KEY"
    },
    "summary": "$SUMMARY",
    "description": {
      "type": "doc",
      "version": 1,
      "content": [
        {
          "type": "paragraph",
          "content": [
            {
              "type": "text",
              "text": "$DESCRIPTION"
            }
          ]
        }
      ]
    },
    "issuetype": {
      "name": "Task"
    }
  }
}
EOF
)
    
    echo "Creating ticket..." | tee -a "$LOG_FILE"
    RESPONSE=$(curl -s -w "%{http_code}" -u "$EMAIL:$TOKEN" \
        -X POST \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        --data "$PAYLOAD" \
        "$JIRA_URL/rest/api/3/issue")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -1)
    RESPONSE_BODY=$(echo "$RESPONSE" | sed '$d')
    
    if [ "$HTTP_CODE" = "201" ]; then
        CREATED_KEY=$(echo "$RESPONSE_BODY" | grep -o '"key":"[^"]*"' | cut -d'"' -f4)
        echo "✅ Created: $CREATED_KEY" | tee -a "$LOG_FILE"
        ((CREATED++))
    else
        echo "❌ Failed to create $KEY" | tee -a "$LOG_FILE"
        echo "HTTP Code: $HTTP_CODE" | tee -a "$LOG_FILE"
        echo "Response: $RESPONSE_BODY" | tee -a "$LOG_FILE"
        ((FAILED++))
    fi
    
    echo "" | tee -a "$LOG_FILE"
    sleep 1  # Rate limiting
done

echo "=========================================" | tee -a "$LOG_FILE"
echo "📊 CREATION RESULTS" | tee -a "$LOG_FILE"
echo "   ✅ Created: $CREATED" | tee -a "$LOG_FILE"
echo "   ❌ Failed: $FAILED" | tee -a "$LOG_FILE"
echo "   📋 Total: 8" | tee -a "$LOG_FILE"
echo "=========================================" | tee -a "$LOG_FILE"

if [ $CREATED -eq 8 ]; then
    echo "🎉 ALL TICKETS CREATED SUCCESSFULLY!" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    echo "Next: Run update script to mark them as Done"
    echo "   ./update-jira-tickets-complete.sh" | tee -a "$LOG_FILE"
elif [ $CREATED -gt 0 ]; then
    echo "⚠️  Partial success: $CREATED created, $FAILED failed" | tee -a "$LOG_FILE"
else
    echo "❌ NO TICKETS WERE CREATED" | tee -a "$LOG_FILE"
fi

echo "" | tee -a "$LOG_FILE"
echo "📄 Detailed log: $LOG_FILE" | tee -a "$LOG_FILE"