#!/bin/bash
# Slack Post Update Script for PRDForge Launch
# Use when Slack integration is configured in OpenClaw

echo "📝 Posting PRDForge launch update to Slack..."

# Check if openclaw is available
if ! command -v openclaw &> /dev/null; then
    echo "❌ OpenClaw CLI not found"
    exit 1
fi

# Check if Slack channel is configured
if ! openclaw channels list 2>/dev/null | grep -q "slack"; then
    echo "⚠️  Slack channel not configured in OpenClaw"
    echo ""
    echo "To configure Slack:"
    echo "1. Create Slack app at https://api.slack.com/apps"
    echo "2. Enable Socket Mode and generate App Token (xapp-...)"
    echo "3. Create Bot Token (xoxb-...)"
    echo "4. Add to OpenClaw config:"
    echo '   {'
    echo '     "channels": {'
    echo '       "slack": {'
    echo '         "enabled": true,'
    echo '         "appToken": "xapp-...",'
    echo '         "botToken": "xoxb-..."'
    echo '       }'
    echo '     }'
    echo '   }'
    echo ""
    echo "Manual posting required for now."
    exit 1
fi

# Post update message
echo "Posting to #prdforge-launch channel..."
openclaw message send --channel slack --target "#prdforge-launch" --message "
🚀 **PRDFORGE LAUNCH UPDATE - 92% COMPLETE**

✅ **COMPLETED (11/12):**
1. Accessibility Info Buttons - Trinity
2. Motion Design System - Fela
3. Documentation Expansion - Ebun
4. Intro Tour Implementation - Trinity
5. Security Improvements - Trinity → Cypher
6. Advanced Accessibility Features - Shuri
7. Micro-interactions Optimization - Fela
8. GDPR Compliance - Ruth
9. Dark Mode Polish - Fela
10. Payment Compliance - Ngozi
11. Jira Agent Integration - Shuri

🔄 **STILL RUNNING:**
1. Continuous Testing - Morpheus (4-5 hours remaining)

📋 **CRITICAL UPDATES:**
• Email format: \`clawdianinan+agentname@gmail.com\`
• Jira final approver: \`temikolawole@gmail.com\`
• Slack integration: All agents now in Slack

🎯 **NEXT:**
• Morpheus completes Continuous Testing
• Skills assignment after tasks complete
• Final approvals via Jira
• Phase 4 (GTM Activation) planning
"

if [ $? -eq 0 ]; then
    echo "✅ Update posted successfully"
else
    echo "❌ Failed to post update"
    echo ""
    echo "Manual posting instructions:"
    echo "1. Log into clawdiasagents.slack.com"
    echo "2. Navigate to #prdforge-launch channel"
    echo "3. Copy and paste the message above"
    echo "4. Post as Clawdia Assistant bot"
fi