#!/bin/bash
# Create Project Channels in EXISTING Slack Workspace
# Creates PRDForge project-specific channels

TOKEN="xoxe.xoxp-1-Mi0yLTEwNzUyMjk1MTE3NDA4LTEwNzIxOTY5NjA0MjE0LTEwNzIyMTQ1OTk1Mzk4LTEwNzIwNzc2MTM3NzE3LTZmZGQzYzc3NjQ4NGUyNTIzZjI1MDE2OGE0NDVhMzE4OWFkYjZlNjlkMTU2NDM0ZTM0NDc0ZDIyMjcwYTJhZGM"

echo "🚀 Creating PRDForge project channels in EXISTING Slack workspace..."

# Test token access
echo "Testing token access..."
curl -s -X POST "https://slack.com/api/auth.test" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" | grep -q '"ok":true' && echo "✅ Token valid" || echo "❌ Token invalid"

# Create PROJECT-SPECIFIC channels
PROJECT_CHANNELS=(
  "prdforge-launch"
  "development"
  "design"
  "documentation"
  "compliance"
  "operations"
  "testing"
  "security"
)

CHANNEL_DESCRIPTIONS=(
  "Main project channel for PRDForge launch - all agents"
  "Development team channel - Trinity, Morpheus, Cypher"
  "Design team channel - Fela"
  "Documentation team channel - Ebun"
  "Compliance team channel - Ruth, Ngozi"
  "Operations team channel - Shuri, Nova"
  "Testing team channel - Morpheus"
  "Security team channel - Cypher"
)

echo ""
echo "📋 Creating ${#PROJECT_CHANNELS[@]} project channels..."

for i in "${!PROJECT_CHANNELS[@]}"; do
  CHANNEL="${PROJECT_CHANNELS[$i]}"
  DESCRIPTION="${CHANNEL_DESCRIPTIONS[$i]}"
  
  echo "Creating channel: #$CHANNEL"
  echo "  Description: $DESCRIPTION"
  
  # Check if channel already exists
  CHANNEL_EXISTS=$(curl -s -X POST "https://slack.com/api/conversations.list" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"types":"public_channel,private_channel"}' | grep -o "\"name\":\"$CHANNEL\"" | wc -l)
  
  if [ "$CHANNEL_EXISTS" -gt 0 ]; then
    echo "  ⚠️  Channel #$CHANNEL already exists - skipping creation"
  else
    # Create as private channel for team-specific work
    if [[ "$CHANNEL" == "prdforge-launch" ]]; then
      # Main channel should be public for all agents
      curl -s -X POST "https://slack.com/api/conversations.create" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"name\":\"$CHANNEL\",\"is_private\":false}" | grep -q '"ok":true' && echo "  ✅ Created (public)" || echo "  ❌ Failed"
    else
      # Team channels should be private
      curl -s -X POST "https://slack.com/api/conversations.create" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"name\":\"$CHANNEL\",\"is_private\":true}" | grep -q '"ok":true' && echo "  ✅ Created (private)" || echo "  ❌ Failed"
    fi
    
    # Update channel description
    sleep 1
    curl -s -X POST "https://slack.com/api/conversations.setPurpose" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d "{\"channel\":\"$CHANNEL\",\"purpose\":\"$DESCRIPTION\"}" | grep -q '"ok":true' && echo "  ✅ Description set" || echo "  ❌ Failed to set description"
  fi
  
  echo ""
  sleep 1
done

echo "📝 **Channel Membership Plan:**"
echo "#prdforge-launch: All agents"
echo "#development: Trinity, Morpheus, Cypher"
echo "#design: Fela"
echo "#documentation: Ebun"
echo "#compliance: Ruth, Ngozi"
echo "#operations: Shuri, Nova"
echo "#testing: Morpheus"
echo "#security: Cypher"
echo ""
echo "✅ Channel creation complete! Add agents to their respective channels."

# Post welcome to main channel
echo ""
echo "Posting welcome message to #prdforge-launch..."
curl -s -X POST "https://slack.com/api/chat.postMessage" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "channel": "#prdforge-launch",
    "text": "🚀 *PRDForge Project Channels Created!*\n\nAll project-specific channels have been created for the PRDForge launch.\n\n**Channel Structure:**\n• #prdforge-launch - Main project channel (all agents)\n• #development - Development team (Trinity, Morpheus, Cypher)\n• #design - Design team (Fela)\n• #documentation - Documentation team (Ebun)\n• #compliance - Compliance team (Ruth, Ngozi)\n• #operations - Operations team (Shuri, Nova)\n• #testing - Testing team (Morpheus)\n• #security - Security team (Cypher)\n\n**Next Steps:**\n1. Missing agents (Ruth, Ngozi, Cypher, Morpheus) will be invited\n2. Agents will be added to their respective channels\n3. Daily standups begin tomorrow at 8:00 AM WAT\n4. Jira/GitHub integrations will be configured\n\nLet'\''s build something amazing! 🎯"
  }' | grep -q '"ok":true' && echo "✅ Welcome posted to #prdforge-launch" || echo "❌ Failed to post welcome"

echo ""
echo "🎉 Project channel setup complete!"