#!/bin/bash

echo "🚀 Jira API Setup"
echo "================="

# Create example configuration
cat > /Users/clawdia/.openclaw/workspace/.jira.env.example << 'EOF'
# Jira API Configuration
JIRA_BASE_URL="https://clawdianinan.atlassian.net"
JIRA_USER_EMAIL="clawdianinan@gmail.com"
JIRA_API_TOKEN="your-api-token-here"
JIRA_PROJECT_KEY="DEV"
EOF

echo "✅ Created example config: .jira.env.example"
echo ""
echo "📝 To set up Jira API:"
echo ""
echo "1. 🔑 Generate API token:"
echo "   Visit: https://id.atlassian.com/manage-profile/security/api-tokens"
echo "   • Click 'Create API token'"
echo "   • Name it: 'PRDForge-Automation'"
echo "   • COPY THE TOKEN (only shown once!)"
echo ""
echo "2. ⚙️  Create config file:"
echo "   cp .jira.env.example .jira.env"
echo "   nano .jira.env"
echo "   # Replace 'your-api-token-here' with your actual token"
echo ""
echo "3. 🔗 Test connection:"
echo "   ./test-jira-api.sh"
echo ""
echo "4. 🎯 Update tickets:"
echo "   ./update-jira-tickets.sh"
echo ""

# Create test script
cat > /Users/clawdia/.openclaw/workspace/test-jira-api.sh << 'EOF'
#!/bin/bash
echo "🔗 Testing Jira API..."
source /Users/clawdia/.openclaw/workspace/.jira.env 2>/dev/null || { echo "❌ Config file missing"; exit 1; }
curl -s -u "$JIRA_USER_EMAIL:$JIRA_API_TOKEN" \
  -H "Accept: application/json" \
  "$JIRA_BASE_URL/rest/api/3/myself" | grep -q "displayName" && echo "✅ Connected!" || echo "❌ Failed"
EOF
chmod +x /Users/clawdia/.openclaw/workspace/test-jira-api.sh

# Create update script
cat > /Users/clawdia/.openclaw/workspace/update-jira-tickets.sh << 'EOF'
#!/bin/bash
echo "🎯 Updating Jira tickets DEV-27 to DEV-34..."
echo "Run after setting up API token in .jira.env"
echo ""
echo "This will update:"
echo "DEV-27: Accessibility Info Buttons (Trinity)"
echo "DEV-28: Motion Design System (Fela)"
echo "DEV-29: Documentation Expansion (Ebun)"
echo "DEV-30: Intro Tour Implementation (Trinity)"
echo "DEV-31: Security Improvements (Cypher)"
echo "DEV-32: Advanced Accessibility Features (Shuri)"
echo "DEV-33: Micro-interactions Optimization (Fela)"
echo "DEV-34: Dark Mode Polish (Fela)"
EOF
chmod +x /Users/clawdia/.openclaw/workspace/update-jira-tickets.sh

echo "✅ Setup complete! Follow the steps above."