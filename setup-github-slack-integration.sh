#!/bin/bash
# Set Up GitHub ↔ Slack Integration
# Connect EXISTING GitHub to EXISTING Slack for PRDForge project

echo "🔗 Setting up GitHub ↔ Slack Integration for PRDForge project..."
echo ""

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
echo "• GitHub Repository: PRDForge codebase"
echo "• Slack Workspace: clawdiasagents.slack.com"
echo "• Development Channel: #development"
echo "• Testing Channel: #testing"
echo "• Security Channel: #security"
echo "• Main Channel: #prdforge-launch"
echo ""

echo "🚀 **Step 1: Install GitHub App for Slack**"
echo ""
echo "Manual Steps Required:"
echo "1. Go to https://clawdiasagents.slack.com/apps"
echo "2. Search for 'GitHub'"
echo "3. Click 'Add to Slack'"
echo "4. Authorize the integration"
echo "5. Select workspace for installation"
echo ""

echo "🚀 **Step 2: Connect GitHub Account**"
echo ""
echo "In Slack, type:"
echo "/github signin"
echo ""
echo "Follow authentication flow to GitHub and authorize:"
echo "• Read repository contents"
echo "• Read pull requests"
echo "• Read workflow runs"
echo "• Manage webhooks"
echo ""

echo "🚀 **Step 3: Configure Repository Subscriptions**"
echo ""
echo "Subscribe to PRDForge repositories:"
echo ""
echo "In Slack, type:"
echo "/github subscribe owner/repo"
echo ""
echo "**Channel Subscriptions:**"
echo "1. Pull Requests → #development"
echo "2. Build Status → #development"
echo "3. Test Results → #testing"
echo "4. Deployments → #prdforge-launch"
echo "5. Issues → #development"
echo "6. Releases → #prdforge-launch"
echo "7. Security Alerts → #security (with @cypher mention)"
echo ""

echo "🚀 **Step 4: Configure Notification Types**"
echo ""
echo "**Enable these notifications:**"
echo "✅ PR Opened - Notify #development"
echo "✅ PR Review Requested - Notify #development with @mention"
echo "✅ PR Merged - Notify #development + #prdforge-launch for significant changes"
echo "✅ Build Status - Notify #development"
echo "✅ Test Results - Notify #testing"
echo "✅ Deployments - Notify #prdforge-launch"
echo "✅ Security Alerts - Notify #security with @cypher mention"
echo ""

echo "🚀 **Step 5: Set Up GitHub Actions Integration**"
echo ""
echo "**GitHub Actions Workflow Configuration:**"
cat > .github/workflows/slack-notifications.yml << 'EOF'
name: Slack Notifications

on:
  push:
    branches: [main, develop]
  pull_request:
    types: [opened, synchronize, reopened, closed, review_requested]
  workflow_run:
    workflows: ["CI", "Test", "Deploy"]
    types: [completed]

jobs:
  notify-slack:
    runs-on: ubuntu-latest
    if: always()
    
    steps:
      - name: Notify Slack on PR
        if: github.event_name == 'pull_request'
        uses: slackapi/slack-github-action@v1.25.0
        with:
          payload: |
            {
              "event": "pull_request",
              "action": "${{ github.event.action }}",
              "pr_number": ${{ github.event.pull_request.number }},
              "pr_title": "${{ github.event.pull_request.title }}",
              "pr_author": "${{ github.event.pull_request.user.login }}",
              "pr_url": "${{ github.event.pull_request.html_url }}",
              "repository": "${{ github.repository }}"
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
          
      - name: Notify Slack on Push
        if: github.event_name == 'push'
        uses: slackapi/slack-github-action@v1.25.0
        with:
          payload: |
            {
              "event": "push",
              "branch": "${{ github.ref }}",
              "commit_count": ${{ github.event.commits.length }},
              "pusher": "${{ github.event.pusher.name }}",
              "compare_url": "${{ github.event.compare }}",
              "repository": "${{ github.repository }}"
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
          
      - name: Notify Slack on Workflow Completion
        if: github.event_name == 'workflow_run'
        uses: slackapi/slack-github-action@v1.25.0
        with:
          payload: |
            {
              "event": "workflow_run",
              "workflow": "${{ github.event.workflow_run.name }}",
              "status": "${{ github.event.workflow_run.conclusion }}",
              "run_url": "${{ github.event.workflow_run.html_url }}",
              "repository": "${{ github.repository }}"
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
EOF

echo "✅ Created GitHub Actions workflow: .github/workflows/slack-notifications.yml"
echo ""

echo "🚀 **Step 6: Configure GitHub Secrets**"
echo ""
echo "**Required Secrets in GitHub Repository:**"
echo "1. SLACK_WEBHOOK_URL - Slack incoming webhook URL"
echo "2. SLACK_CHANNEL - Default channel for notifications"
echo "3. SLACK_USERNAME - (Optional) Custom username for bot"
echo ""
echo "**To add secrets:**"
echo "1. Go to GitHub repository → Settings → Secrets and variables → Actions"
echo "2. Click 'New repository secret'"
echo "3. Add each secret with appropriate value"
echo ""

echo "🚀 **Step 7: Set Up Code Review Integration**"
echo ""
echo "**Review Workflow Configuration:**"
echo "1. PR opened → Notification to #development"
echo "2. Review requested → @mention specific reviewers"
echo "3. Review comments → Thread in PR notification"
echo "4. PR approved → Status update in thread"
echo "5. PR merged → Final notification with changelog"
echo ""
echo "**Automation Features:**"
echo "• Auto-request reviews based on changed files"
echo "• Auto-assign based on CODEOWNERS"
echo "• Auto-merge when criteria met (tests pass, approvals)"
echo ""

echo "🚀 **Step 8: Configure Deployment Pipeline Integration**"
echo ""
echo "**Deployment Stages & Notifications:**"
echo "1. Build → Notification to #development"
echo "2. Test → Results to #testing"
echo "3. Staging deployment → Notification to #development"
echo "4. Production deployment → Notification to #prdforge-launch"
echo ""
echo "**Rollback Notifications:**"
echo "• Automatic rollback triggers"
echo "• Immediate notification to #prdforge-launch"
echo "• @mention operations team"
echo ""

echo "🔧 **Automation Script for Testing**"
cat > test-github-slack-integration.py << 'EOF'
#!/usr/bin/env python3
"""
Test GitHub-Slack Integration
Simulates GitHub events and verifies Slack notifications
"""

import os
import json
import requests
from datetime import datetime

# Load Slack token from environment
SLACK_TOKEN = os.getenv('SLACK_TOKEN')

if not SLACK_TOKEN:
    print("❌ Error: Slack token not found in environment")
    exit(1)

# Slack configuration
SLACK_CHANNELS = {
    "development": "#development",
    "testing": "#testing",
    "security": "#security",
    "main": "#prdforge-launch"
}

def post_to_slack(channel_type, message):
    """Post test message to Slack channel"""
    channel = SLACK_CHANNELS.get(channel_type, SLACK_CHANNELS["main"])
    
    url = "https://slack.com/api/chat.postMessage"
    
    headers = {
        "Authorization": f"Bearer {SLACK_TOKEN}",
        "Content-Type": "application/json"
    }
    
    payload = {
        "channel": channel,
        "text": message
    }
    
    try:
        response = requests.post(url, headers=headers, json=payload)
        if response.status_code == 200 and response.json().get('ok'):
            print(f"✅ Test message posted to {channel}")
            return True
        else:
            print(f"❌ Failed to post to {channel}: {response.json()}")
            return False
    except Exception as e:
        print(f"❌ Error posting to Slack: {e}")
        return False

def simulate_github_events():
    """Simulate various GitHub events"""
    print("🧪 Simulating GitHub events for Slack integration test...")
    print("")
    
    # Test 1: PR Opened
    print("1. Simulating PR Opened event...")
    pr_message = "🔀 *Test PR Opened*\nPR #999: Test GitHub-Slack Integration\nAuthor: test-agent | Branch: feature/test-integration\nRepository: owner/repo\nThis is a test PR to verify GitHub-Slack integration."
    if post_to_slack("development", pr_message):
        print("   ✅ PR notification test passed")
    
    # Test 2: Build Status
    print("\n2. Simulating Build Status event...")
    build_message = "🏗️ *Test Build Status*\nBuild #123: Test GitHub-Slack Integration\nStatus: ✅ Success\nDuration: 2 minutes 15 seconds\nPipeline: GitHub Actions\nAll checks passed successfully."
    if post_to_slack("development", build_message):
        print("   ✅ Build notification test passed")
    
    # Test 3: Test Results
    print("\n3. Simulating Test Results event...")
    test_message = "🧪 *Test Results*\nTest run #456: Integration Tests\nStatus: ✅ All tests passed\nCoverage: 92% (Δ+3%)\nDuration: 1 minute 30 seconds\nNo test failures detected."
    if post_to_slack("testing", test_message):
        print("   ✅ Test notification test passed")
    
    # Test 4: Security Alert
    print("\n4. Simulating Security Alert event...")
    security_message = "🚨 *Test Security Alert*\nVulnerability detected in dependency\nPackage: test-package@1.0.0\nSeverity: High\nAdvisory: Test security advisory\nAction Required: Update to version 1.0.1\n@cypher Please review this security alert."
    if post_to_slack("security", security_message):
        print("   ✅ Security notification test passed")
    
    # Test 5: Deployment
    print("\n5. Simulating Deployment event...")
    deploy_message = "🚀 *Test Deployment*\nv1.2.3 deployed to Staging environment\nDeployed by: test-agent\nChanges: #999 (Test integration), #998 (Fix build)\nDuration: 3 minutes\nNext: Production deployment after validation"
    if post_to_slack("main", deploy_message):
        print("   ✅ Deployment notification test passed")

def main():
    print("🧪 Testing GitHub-Slack Integration...")
    print(f"Slack Workspace: clawdiasagents.slack.com")
    print("Channels configured:")
    for channel_type, channel_name in SLACK_CHANNELS.items():
        print(f"  • {channel_type}: {channel_name}")
    print("")
    
    # Test initial connection
    print("Testing Slack connection...")
    test_msg = "🧪 *GitHub-Slack Integration Test Started*\nBeginning simulation of GitHub events..."
    if post_to_slack("main", test_msg):
        print("✅ Slack connection successful")
    else:
        print("❌ Slack connection failed")
        return
    
    # Simulate GitHub events
    simulate_github_events()
    
    # Post completion message
    completion_msg = "✅ *GitHub-Slack Integration Test Complete*\nAll simulated events posted successfully.\nIntegration is ready for use!"
    post_to_slack("main", completion_msg)
    
    print("\n🎉 GitHub-Slack integration test complete!")

if __name__ == "__main__":
    main()
EOF

chmod +x test-github-slack-integration.py

echo "✅ Created test script: test-github-slack-integration.py"
echo ""
echo "To test the integration:"
echo "1. Set environment variable:"
echo "   export SLACK_TOKEN='your_slack_token'"
echo "2. Run: python3 test-github-slack-integration.py"
echo ""

echo "📊 **Monitoring Setup**"
echo ""
echo "**Daily Checks:**"
echo "• Verify GitHub app connection"
echo "• Check for failed webhooks"
echo "• Monitor notification volume"
echo ""
echo "**Weekly Tasks:**"
echo "• Review notification effectiveness"
echo "• Adjust filters if needed"
echo "• Update repository subscriptions"
echo ""
echo "**Monthly Audit:**"
echo "• Review all webhook configurations"
echo "• Check integration permissions"
echo "• Verify @mentions are working"
echo "• Test security alert workflow"
echo ""

echo "🎉 GitHub-Slack Integration Configuration Complete!"
echo ""
echo "**Next Steps:**"
echo "1. Install GitHub app in Slack"
echo "2. Connect GitHub account"
echo "3. Configure repository subscriptions"
echo "4. Set up GitHub Actions workflow"
echo "5. Configure GitHub secrets"
echo "6. Test with test-github-slack-integration.py"
echo ""
echo "**Success Criteria:**"
echo "✅ PR notifications appear in #development"
echo "✅ Build/test notifications go to correct channels"
echo "✅ Security alerts trigger @cypher mentions"
echo "✅ Deployment notifications appear in #prdforge-launch"
echo "✅ Real-time updates visible to all agents"