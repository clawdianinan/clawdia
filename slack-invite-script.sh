#!/bin/bash
# Slack Agent Invitation Script
# Invites all 6 agents to Slack workspace

TOKEN="xoxe.xoxp-1-Mi0yLTEwNzUyMjk1MTE3NDA4LTEwNzIxOTY5NjA0MjE0LTEwNzIyMTQ1OTk1Mzk4LTEwNzIwNzc2MTM3NzE3LTZmZGQzYzc3NjQ4NGUyNTIzZjI1MDE2OGE0NDVhMzE4OWFkYjZlNjlkMTU2NDM0ZTM0NDc0ZDIyMjcwYTJhZGM"

AGENTS=(
  "clawdianinan+trinity@gmail.com"
  "clawdianinan+fela@gmail.com"
  "clawdianinan+shuri@gmail.com"
  "clawdianinan+ebun@gmail.com"
  "clawdianinan+nova@gmail.com"
  "clawdianinan+sheba@gmail.com"
)

echo "📧 Inviting 6 agents to Slack workspace..."

for EMAIL in "${AGENTS[@]}"; do
  AGENT_NAME=$(echo "$EMAIL" | cut -d'+' -f2 | cut -d'@' -f1)
  echo "Inviting: $EMAIL ($AGENT_NAME)"
  
  # Note: Slack API for inviting users typically requires admin permissions
  # This is a placeholder - actual implementation may vary
  echo "  ⚠️  Requires admin invite via Slack UI or different API endpoint"
  echo "  Please invite manually or ensure proper admin scopes"
done

echo ""
echo "📋 **Manual Invitation Steps:**"
echo "1. Go to clawdiasagents.slack.com"
echo "2. Click 'Invite people to Clawdia'\'s Agents'"
echo "3. Add these 6 emails:"
for EMAIL in "${AGENTS[@]}"; do
  echo "   • $EMAIL"
done
echo "4. Send invitations"
echo ""
echo "Once invited, agents will appear in workspace and can be added to channels."