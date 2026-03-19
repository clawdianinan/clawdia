#!/bin/bash
# Slack Setup Script for PRDForge Launch
# Run after token has channels:write scope

TOKEN="xoxe.xoxp-1-Mi0yLTEwNzUyMjk1MTE3NDA4LTEwNzIxOTY5NjA0MjE0LTEwNzIyMTQ1OTk1Mzk4LTEwNzIwNzc2MTM3NzE3LTZmZGQzYzc3NjQ4NGUyNTIzZjI1MDE2OGE0NDVhMzE4OWFkYjZlNjlkMTU2NDM0ZTM0NDc0ZDIyMjcwYTJhZGM"

echo "🚀 Setting up PRDForge Slack workspace..."

# Test token access
echo "Testing token access..."
curl -s -X POST "https://slack.com/api/auth.test" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" | grep -q '"ok":true' && echo "✅ Token valid" || echo "❌ Token invalid"

# Create PRIVATE channels (using groups:write scope)
PRIVATE_CHANNELS=(
  "phase1-stabilization"
  "phase2-qa-uat"
  "phase3-commercial"
  "phase4-gtm"
  "agent-coordination"
  "decisions"
  "blockers"
)

for CHANNEL in "${PRIVATE_CHANNELS[@]}"; do
  echo "Creating private channel: $CHANNEL"
  curl -s -X POST "https://slack.com/api/conversations.create" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"name\":\"$CHANNEL\",\"is_private\":true}" | grep -q '"ok":true' && echo "  ✅ Created (private)" || echo "  ❌ Failed"
  sleep 1
done

echo "Using #general for public announcements (already exists)"

# Post welcome message
echo "Posting welcome message..."
curl -s -X POST "https://slack.com/api/chat.postMessage" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "channel": "#prdforge-launch",
    "text": "🚀 *PRDForge Launch - Phase 2 Execution Started!*\n\nClawdia AI Assistant reporting for duty. All 7 agents will join shortly.\n\n**Current Status:**\n• Phase 1: ✅ Complete\n• Phase 2 Day 4: 🟡 In Progress\n• Payment Config: 🔴 Blocking\n\n**Channels Created:**\n• #phase1-stabilization - Technical updates\n• #phase2-qa-uat - Testing progress\n• #phase3-commercial - Billing validation\n• #phase4-gtm - Launch marketing\n• #agent-coordination - Daily standups\n• #decisions - Key decisions\n• #blockers - Issues needing attention\n\nDaily standup: 9 AM Africa/Lagos in #agent-coordination"
  }' | grep -q '"ok":true' && echo "✅ Welcome posted" || echo "❌ Failed to post"

echo "🎉 Slack setup complete!"