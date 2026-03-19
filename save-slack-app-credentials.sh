#!/bin/bash

# Script to save "Clawdia's Assistant" Slack app credentials
# Run this script and enter values from the Slack app configuration image

echo "🔧 Saving 'Clawdia's Assistant' Slack App Credentials"
echo "======================================================"
echo ""
echo "Extracting credentials for Slack app: 'Clawdia's Assistant'"
echo ""

# Read values (they won't be displayed for security)
echo "From the Slack app configuration image, enter these values:"
echo ""

# Basic Information
read -p "App ID: " SLACK_APP_ID
read -p "Client ID: " SLACK_CLIENT_ID
read -p "Client Secret: " SLACK_CLIENT_SECRET
read -p "Signing Secret: " SLACK_SIGNING_SECRET
read -p "Verification Token: " SLACK_VERIFICATION_TOKEN

# OAuth Tokens
echo ""
echo "OAuth Tokens (from OAuth & Permissions section):"
read -sp "Bot User OAuth Token (xoxb-...): " SLACK_BOT_TOKEN
echo ""
read -sp "User OAuth Token (xoxp-...): " SLACK_USER_TOKEN
echo ""

# Workspace Information
echo ""
echo "Workspace Information:"
read -p "Slack Workspace URL (e.g., clawdiasagents.slack.com): " SLACK_WORKSPACE
read -p "Team ID (if shown): " SLACK_TEAM_ID

# Create or update .env file
ENV_FILE="/Users/clawdia/apps/prdforge/.env"

echo ""
echo "📝 Updating $ENV_FILE with Slack app configuration..."
echo ""

# Check if .env exists
if [ ! -f "$ENV_FILE" ]; then
    echo "Creating new .env file..."
    touch "$ENV_FILE"
fi

# Backup existing .env
BACKUP_FILE="$ENV_FILE.backup.$(date +%Y%m%d_%H%M%S)"
cp "$ENV_FILE" "$BACKUP_FILE"
echo "Backup created: $BACKUP_FILE"

# Add or update Slack variables
echo "" >> "$ENV_FILE"
echo "# Slack App: Clawdia's Assistant" >> "$ENV_FILE"
echo "SLACK_APP_NAME=\"Clawdia's Assistant\"" >> "$ENV_FILE"
echo "SLACK_APP_ID=$SLACK_APP_ID" >> "$ENV_FILE"
echo "SLACK_CLIENT_ID=$SLACK_CLIENT_ID" >> "$ENV_FILE"
echo "SLACK_CLIENT_SECRET=$SLACK_CLIENT_SECRET" >> "$ENV_FILE"
echo "SLACK_SIGNING_SECRET=$SLACK_SIGNING_SECRET" >> "$ENV_FILE"
echo "SLACK_VERIFICATION_TOKEN=$SLACK_VERIFICATION_TOKEN" >> "$ENV_FILE"
echo "SLACK_BOT_TOKEN=$SLACK_BOT_TOKEN" >> "$ENV_FILE"
echo "SLACK_USER_TOKEN=$SLACK_USER_TOKEN" >> "$ENV_FILE"
echo "SLACK_WORKSPACE=$SLACK_WORKSPACE" >> "$ENV_FILE"
echo "SLACK_TEAM_ID=$SLACK_TEAM_ID" >> "$ENV_FILE"
echo "" >> "$ENV_FILE"

# Also update .env.production
PROD_ENV_FILE="/Users/clawdia/apps/prdforge/.env.production"
if [ -f "$PROD_ENV_FILE" ]; then
    echo "📝 Updating $PROD_ENV_FILE with Slack configuration..."
    cp "$PROD_ENV_FILE" "$PROD_ENV_FILE.backup.$(date +%Y%m%d_%H%M%S)"
    echo "" >> "$PROD_ENV_FILE"
    echo "# Slack App: Clawdia's Assistant" >> "$PROD_ENV_FILE"
    echo "SLACK_APP_NAME=\"Clawdia's Assistant\"" >> "$PROD_ENV_FILE"
    echo "SLACK_APP_ID=$SLACK_APP_ID" >> "$PROD_ENV_FILE"
    echo "SLACK_CLIENT_ID=$SLACK_CLIENT_ID" >> "$PROD_ENV_FILE"
    echo "SLACK_CLIENT_SECRET=$SLACK_CLIENT_SECRET" >> "$PROD_ENV_FILE"
    echo "SLACK_SIGNING_SECRET=$SLACK_SIGNING_SECRET" >> "$PROD_ENV_FILE"
    echo "SLACK_VERIFICATION_TOKEN=$SLACK_VERIFICATION_TOKEN" >> "$PROD_ENV_FILE"
    echo "SLACK_BOT_TOKEN=$SLACK_BOT_TOKEN" >> "$PROD_ENV_FILE"
    echo "SLACK_WORKSPACE=$SLACK_WORKSPACE" >> "$PROD_ENV_FILE"
    echo "SLACK_TEAM_ID=$SLACK_TEAM_ID" >> "$PROD_ENV_FILE"
    echo "" >> "$PROD_ENV_FILE"
fi

echo "✅ 'Clawdia's Assistant' Slack app credentials saved!"
echo ""
echo "📋 Summary of what was saved:"
echo "   - SLACK_APP_NAME: Clawdia's Assistant"
echo "   - SLACK_APP_ID: [saved]"
echo "   - SLACK_CLIENT_ID: [saved]"
echo "   - SLACK_CLIENT_SECRET: [saved]"
echo "   - SLACK_SIGNING_SECRET: [saved]"
echo "   - SLACK_VERIFICATION_TOKEN: [saved]"
echo "   - SLACK_BOT_TOKEN: [saved]"
echo "   - SLACK_USER_TOKEN: [saved]"
echo "   - SLACK_WORKSPACE: [saved]"
echo "   - SLACK_TEAM_ID: [saved]"
echo ""
echo "🔒 Security Recommendations:"
echo "   1. Consider rotating tokens if they were exposed in the image"
echo "   2. Review app scopes in Slack API dashboard"
echo "   3. Verify app permissions are minimal required"
echo "   4. Monitor app usage in Slack audit logs"
echo ""
echo "🚀 Next Steps:"
echo "   1. Test Slack API access with saved tokens"
echo "   2. Complete Slack agent invitations"
echo "   3. Create missing Slack channels"
echo "   4. Integrate Slack with Jira/GitHub"
echo ""
echo "To test Slack API access:"
echo "  curl -H \"Authorization: Bearer $SLACK_BOT_TOKEN\" \\"
echo "    \"https://slack.com/api/auth.test\""