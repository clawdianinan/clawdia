#!/bin/bash
echo "🔗 Testing Jira API..."
source /Users/clawdia/.openclaw/workspace/.jira.env 2>/dev/null || { echo "❌ Config file missing"; exit 1; }
curl -s -u "$JIRA_USER_EMAIL:$JIRA_API_TOKEN" \
  -H "Accept: application/json" \
  "$JIRA_BASE_URL/rest/api/3/myself" | grep -q "displayName" && echo "✅ Connected!" || echo "❌ Failed"
