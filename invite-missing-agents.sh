#!/bin/bash
# Invite Missing Agents to Existing Slack Workspace
# Adds: Ruth, Ngozi, Cypher, Morpheus to clawdiasagents.slack.com

TOKEN="xoxe.xoxp-1-Mi0yLTEwNzUyMjk1MTE3NDA4LTEwNzIxOTY5NjA0MjE0LTEwNzIyMTQ1OTk1Mzk4LTEwNzIwNzc2MTM3NzE3LTZmZGQzYzc3NjQ4NGUyNTIzZjI1MDE2OGE0NDVhMzE4OWFkYjZlNjlkMTU2NDM0ZTM0NDc0ZDIyMjcwYTJhZGM"

MISSING_AGENTS=(
  "clawdianinan+ruth@gmail.com"
  "clawdianinan+ngozi@gmail.com"
  "clawdianinan+cypher@gmail.com"
  "clawdianinan+morpheus@gmail.com"
)

echo "📧 Inviting 4 missing agents to EXISTING Slack workspace: clawdiasagents.slack.com"
echo "Existing agents already in workspace: Trinity, Fela, Shuri, Ebun, Nova, Sheba"
echo ""

for EMAIL in "${MISSING_AGENTS[@]}"; do
  AGENT_NAME=$(echo "$EMAIL" | cut -d'+' -f2 | cut -d'@' -f1)
  echo "Inviting missing agent: $EMAIL ($AGENT_NAME)"
  
  # Note: Slack API for inviting users typically requires admin permissions
  # This is a placeholder - actual implementation may vary
  echo "  ⚠️  Requires admin invite via Slack UI or different API endpoint"
  echo "  Please invite manually or ensure proper admin scopes"
done

echo ""
echo "📋 **Manual Invitation Steps for Missing Agents:**"
echo "1. Go to https://clawdiasagents.slack.com"
echo "2. Click 'Invite people to Clawdia'\'s Agents'"
echo "3. Add these 4 emails:"
for EMAIL in "${MISSING_AGENTS[@]}"; do
  AGENT_NAME=$(echo "$EMAIL" | cut -d'+' -f2 | cut -d'@' -f1)
  echo "   • $EMAIL (Agent: $AGENT_NAME)"
done
echo "4. Send invitations"
echo ""
echo "📝 **Agent Roles & Channel Assignments:**"
echo "• Ruth: Compliance specialist → #compliance channel"
echo "• Ngozi: Compliance specialist → #compliance channel"
echo "• Cypher: Security specialist → #security, #development channels"
echo "• Morpheus: Testing/Development specialist → #testing, #development channels"
echo ""
echo "✅ Once invited, add agents to their respective channels."