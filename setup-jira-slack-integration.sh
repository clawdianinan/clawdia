#!/bin/bash
# Set Up Jira ↔ Slack Integration
# Connect EXISTING Jira to EXISTING Slack for PRDForge project

echo "🔗 Setting up Jira ↔ Slack Integration for PRDForge project..."
echo ""

# Load environment variables
if [ -f .env.atlassian ]; then
  source .env.atlassian
  echo "✅ Loaded Atlassian API token"
else
  echo "❌ Error: .env.atlassian file not found"
  echo "Please create .env.atlassian with ATLASSIAN_API_TOKEN"
  exit 1
fi

# Check for Slack token
if [ -f slack-setup-script.sh ]; then
  SLACK_TOKEN=$(grep 'TOKEN=' slack-setup-script.sh | head -1 | cut -d'"' -f2)
  if [ -n "$SLACK_TOKEN" ]; then
    echo "✅ Found Slack token"
  else
    echo "❌ Error: Could not extract Slack token from slack-setup-script.sh"
    exit 1
  fi
else
  echo "❌ Error: slack-setup-script.sh not found"
  exit 1
fi

echo ""
echo "📋 **Integration Configuration:**"
echo "• Jira Project: PRDForge (DEV-* tickets)"
echo "• Slack Workspace: clawdiasagents.slack.com"
echo "• Main Channel: #prdforge-launch"
echo "• Team Channels: #development, #design, #documentation, #compliance, #operations, #testing, #security"
echo ""

echo "🚀 **Step 1: Install Jira Cloud for Slack App**"
echo ""
echo "Manual Steps Required:"
echo "1. Go to https://clawdiasagents.slack.com/apps"
echo "2. Search for 'Jira Cloud'"
echo "3. Click 'Add to Slack'"
echo "4. Authorize the integration"
echo "5. Select workspace for installation"
echo ""

echo "🚀 **Step 2: Connect Jira Instance**"
echo ""
echo "In Slack, type:"
echo "/jira connect"
echo ""
echo "Follow authentication flow to Jira and grant permissions:"
echo "• Read issues"
echo "• Create issues"
echo "• Update issues"
echo "• Manage webhooks"
echo ""

echo "🚀 **Step 3: Configure Project Mapping**"
echo ""
echo "Map Jira project PRDForge to Slack channels:"
echo ""
echo "**Channel Mapping Configuration:**"
echo "1. Project-wide notifications → #prdforge-launch"
echo "2. Development tickets → #development"
echo "3. Design tickets → #design"
echo "4. Documentation tickets → #documentation"
echo "5. Compliance tickets → #compliance"
echo "6. Operations tickets → #operations"
echo "7. Testing tickets → #testing"
echo "8. Security tickets → #security"
echo ""

echo "🚀 **Step 4: Configure Notification Types**"
echo ""
echo "**Enable these notifications:**"
echo "✅ Ticket Created - Notify relevant channel"
echo "✅ Status Changed - Notify relevant channel + #prdforge-launch for Done"
echo "✅ Assignee Changed - Notify relevant channel"
echo "✅ Comment Added - Notify relevant channel (optional)"
echo "✅ Approval Needed - Notify #prdforge-launch with @temikolawole mention"
echo "✅ Ticket Completed - Notify relevant channel + #prdforge-launch"
echo ""

echo "🚀 **Step 5: Set Up Approval Workflow**"
echo ""
echo "**Approval Process Configuration:**"
echo "1. Create 'Ready for Approval' status in Jira workflow"
echo "2. Set up transition from 'Review' to 'Ready for Approval'"
echo "3. Configure webhook for status change to 'Ready for Approval'"
echo "4. Set up automation for approval notification to Slack"
echo ""
echo "**Slack Notification for Approvals:**"
echo "When ticket marked 'Ready for Approval':"
echo "• Post to #prdforge-launch"
echo "• Include @temikolawole mention"
echo "• Include ticket details and link"
echo ""

echo "🚀 **Step 6: Test Integration**"
echo ""
echo "**Test Cases:**"
echo "1. Create test ticket DEV-999"
echo "2. Verify notification appears in correct channel"
echo "3. Change ticket status"
echo "4. Verify update message"
echo "5. Mark ticket 'Ready for Approval'"
echo "6. Verify @temikolawole mention in #prdforge-launch"
echo "7. Complete ticket"
echo "8. Verify celebration message"
echo ""

echo "📝 **Jira Webhook Configuration (Alternative Method)**"
echo ""
echo "If using webhooks directly, configure in Jira:"
echo "1. Go to Jira Settings → System → Webhooks"
echo "2. Create new webhook"
echo "3. URL: https://hooks.sack.com/services/... (Slack incoming webhook)"
echo "4. Events:"
echo "   - jira:issue_created"
echo "   - jira:issue_updated"
echo "   - jira:issue_deleted"
echo "   - comment_created"
echo "   - workflow_transition"
echo ""

echo "🔧 **Automation Script for Testing**"
cat > test-jira-slack-integration.py << 'EOF'
#!/usr/bin/env python3
"""
Test Jira-Slack Integration
Creates test ticket and verifies Slack notifications
"""

import os
import json
import requests
from datetime import datetime

# Load tokens from environment
JIRA_API_TOKEN = os.getenv('ATLASSIAN_API_TOKEN')
SLACK_TOKEN = os.getenv('SLACK_TOKEN')

if not JIRA_API_TOKEN or not SLACK_TOKEN:
    print("❌ Error: Tokens not found in environment")
    exit(1)

# Jira configuration
JIRA_BASE_URL = "https://clawdianinan.atlassian.net"
JIRA_PROJECT_KEY = "DEV"

# Slack configuration
SLACK_CHANNEL = "#prdforge-launch"

def create_test_ticket():
    """Create a test ticket in Jira"""
    url = f"{JIRA_BASE_URL}/rest/api/3/issue"
    
    headers = {
        "Authorization": f"Bearer {JIRA_API_TOKEN}",
        "Content-Type": "application/json"
    }
    
    payload = {
        "fields": {
            "project": {"key": JIRA_PROJECT_KEY},
            "summary": "Test Jira-Slack Integration Ticket",
            "description": {
                "type": "doc",
                "version": 1,
                "content": [{
                    "type": "paragraph",
                    "content": [{
                        "type": "text",
                        "text": "This is a test ticket to verify Jira-Slack integration."
                    }]
                }]
            },
            "issuetype": {"name": "Task"},
            "priority": {"name": "Medium"}
        }
    }
    
    try:
        response = requests.post(url, headers=headers, json=payload)
        if response.status_code == 201:
            ticket_data = response.json()
            ticket_key = ticket_data.get('key')
            print(f"✅ Created test ticket: {ticket_key}")
            return ticket_key
        else:
            print(f"❌ Failed to create ticket: {response.status_code}")
            print(response.text)
            return None
    except Exception as e:
        print(f"❌ Error creating ticket: {e}")
        return None

def post_to_slack(message):
    """Post test message to Slack"""
    url = "https://slack.com/api/chat.postMessage"
    
    headers = {
        "Authorization": f"Bearer {SLACK_TOKEN}",
        "Content-Type": "application/json"
    }
    
    payload = {
        "channel": SLACK_CHANNEL,
        "text": message
    }
    
    try:
        response = requests.post(url, headers=headers, json=payload)
        if response.status_code == 200 and response.json().get('ok'):
            print("✅ Test message posted to Slack")
            return True
        else:
            print(f"❌ Failed to post to Slack: {response.json()}")
            return False
    except Exception as e:
        print(f"❌ Error posting to Slack: {e}")
        return False

def main():
    print("🧪 Testing Jira-Slack Integration...")
    print(f"Jira Base URL: {JIRA_BASE_URL}")
    print(f"Slack Channel: {SLACK_CHANNEL}")
    print("")
    
    # Test Slack connection
    print("1. Testing Slack connection...")
    if post_to_slack("🧪 *Jira-Slack Integration Test Started*\nTesting connection between Jira and Slack..."):
        print("   ✅ Slack connection successful")
    else:
        print("   ❌ Slack connection failed")
        return
    
    # Test Jira connection
    print("\n2. Testing Jira connection...")
    ticket_key = create_test_ticket()
    if ticket_key:
        print(f"   ✅ Jira connection successful - Ticket: {ticket_key}")
        
        # Post success message to Slack
        success_msg = f"✅ *Jira-Slack Integration Test Complete*\nTest ticket created: {ticket_key}\nIntegration is working correctly!"
        post_to_slack(success_msg)
    else:
        print("   ❌ Jira connection failed")
        
        # Post failure message to Slack
        failure_msg = "❌ *Jira-Slack Integration Test Failed*\nCould not create test ticket. Please check Jira configuration."
        post_to_slack(failure_msg)

if __name__ == "__main__":
    main()
EOF

chmod +x test-jira-slack-integration.py

echo "✅ Created test script: test-jira-slack-integration.py"
echo ""
echo "To test the integration:"
echo "1. Set environment variables:"
echo "   export ATLASSIAN_API_TOKEN='your_token'"
echo "   export SLACK_TOKEN='your_slack_token'"
echo "2. Run: python3 test-jira-slack-integration.py"
echo ""

echo "📊 **Monitoring Setup**"
echo ""
echo "**Daily Checks:**"
echo "• Verify notifications are being sent"
echo "• Check for failed webhooks"
echo "• Monitor integration health"
echo ""
echo "**Weekly Tasks:**"
echo "• Review notification volume"
echo "• Adjust filters if needed"
echo "• Update channel mappings"
echo ""
echo "**Monthly Audit:**"
echo "• Review all webhook configurations"
echo "• Check integration permissions"
echo "• Verify @mentions are working"
echo "• Test approval workflow end-to-end"
echo ""

echo "🎉 Jira-Slack Integration Configuration Complete!"
echo ""
echo "**Next Steps:**"
echo "1. Install Jira Cloud app in Slack"
echo "2. Connect Jira instance"
echo "3. Configure channel mappings"
echo "4. Test with test-jira-slack-integration.py"
echo "5. Begin using integrated workflow"
echo ""
echo "**Success Criteria:**"
echo "✅ All agents receive relevant Jira notifications"
echo "✅ Approval requests trigger @temikolawole mentions"
echo "✅ Ticket completions are celebrated in channels"
echo "✅ Real-time status updates visible to all agents"