#!/bin/bash

echo "🚀 Creating Jira Tickets - Simple Version"
echo "========================================"

source ~/.zshrc 2>/dev/null

JIRA_URL="https://clawdianinan.atlassian.net"
EMAIL="clawdianinan@gmail.com"
TOKEN="$ATLASSIAN_API_TOKEN"
PROJECT_KEY="DEV"

if [ -z "$TOKEN" ]; then
    echo "❌ Token not set"
    exit 1
fi

echo "✅ API connected"
echo ""

# Create tickets one by one
echo "1. Creating DEV-27: Accessibility Info Buttons..."
PAYLOAD1='{
  "fields": {
    "project": {"key": "DEV"},
    "summary": "Accessibility Info Buttons",
    "description": {
      "type": "doc",
      "version": 1,
      "content": [{
        "type": "paragraph",
        "content": [{"type": "text", "text": "Implement accessibility info buttons with hover tooltips and documentation linking."}]
      }]
    },
    "issuetype": {"name": "Task"}
  }
}'

RESPONSE1=$(curl -s -u "$EMAIL:$TOKEN" -X POST -H "Content-Type: application/json" --data "$PAYLOAD1" "$JIRA_URL/rest/api/3/issue")
echo "$RESPONSE1" | grep -q '"key"' && echo "✅ Created" || echo "❌ Failed"

echo ""
echo "2. Creating DEV-28: Motion Design System..."
PAYLOAD2='{
  "fields": {
    "project": {"key": "DEV"},
    "summary": "Motion Design System",
    "description": {
      "type": "doc",
      "version": 1,
      "content": [{
        "type": "paragraph",
        "content": [{"type": "text", "text": "Implement Productive Delight motion design system with page transitions, form feedback, loading states."}]
      }]
    },
    "issuetype": {"name": "Task"}
  }
}'

RESPONSE2=$(curl -s -u "$EMAIL:$TOKEN" -X POST -H "Content-Type: application/json" --data "$PAYLOAD2" "$JIRA_URL/rest/api/3/issue")
echo "$RESPONSE2" | grep -q '"key"' && echo "✅ Created" || echo "❌ Failed"

echo ""
echo "3. Creating DEV-29: Documentation Expansion..."
PAYLOAD3='{
  "fields": {
    "project": {"key": "DEV"},
    "summary": "Documentation Expansion",
    "description": {
      "type": "doc",
      "version": 1,
      "content": [{
        "type": "paragraph",
        "content": [{"type": "text", "text": "Create comprehensive documentation suite including Getting Started, PRD Tutorial, API Reference, Integrations, Troubleshooting, Contributing Guide."}]
      }]
    },
    "issuetype": {"name": "Task"}
  }
}'

RESPONSE3=$(curl -s -u "$EMAIL:$TOKEN" -X POST -H "Content-Type: application/json" --data "$PAYLOAD3" "$JIRA_URL/rest/api/3/issue")
echo "$RESPONSE3" | grep -q '"key"' && echo "✅ Created" || echo "❌ Failed"

echo ""
echo "Checking what was created..."
curl -s -u "$EMAIL:$TOKEN" "$JIRA_URL/rest/api/3/search?jql=project=DEV&maxResults=10" | grep -o '"key":"[^"]*"' | cut -d'"' -f4