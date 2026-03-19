#!/bin/bash

# Script to save Slack details to environment variables
# Run this script and enter the values from the image

echo "🔧 Saving Slack Details to Environment Variables"
echo "================================================"
echo ""
echo "Please enter the values from the Slack configuration image:"
echo ""

# Read values (they won't be displayed for security)
read -sp "Slack Workspace URL (e.g., clawdiasagents.slack.com): " SLACK_WORKSPACE
echo ""
read -sp "Slack Admin Email: " SLACK_ADMIN_EMAIL
echo ""
read -sp "Slack Admin Password: " SLACK_ADMIN_PASSWORD
echo ""
read -sp "Slack Bot Token (xoxb-...): " SLACK_BOT_TOKEN
echo ""
read -sp "Slack User Token (xoxp-...): " SLACK_USER_TOKEN
echo ""
read -sp "Slack Signing Secret: " SLACK_SIGNING_SECRET
echo ""
read -sp "Slack Client Secret: " SLACK_CLIENT_SECRET
echo ""

# Create or update .env file
ENV_FILE="/Users/clawdia/apps/prdforge/.env"

echo ""
echo "📝 Updating $ENV_FILE with Slack configuration..."
echo ""

# Check if .env exists
if [ ! -f "$ENV_FILE" ]; then
    echo "Creating new .env file..."
    touch "$ENV_FILE"
fi

# Backup existing .env
cp "$ENV_FILE" "$ENV_FILE.backup.$(date +%Y%m%d_%H%M%S)"

# Add or update Slack variables
echo "# Slack Configuration" >> "$ENV_FILE"
echo "SLACK_WORKSPACE=$SLACK_WORKSPACE" >> "$ENV_FILE"
echo "SLACK_ADMIN_EMAIL=$SLACK_ADMIN_EMAIL" >> "$ENV_FILE"
# Note: Password is not saved in .env for security - use password manager
echo "SLACK_BOT_TOKEN=$SLACK_BOT_TOKEN" >> "$ENV_FILE"
echo "SLACK_USER_TOKEN=$SLACK_USER_TOKEN" >> "$ENV_FILE"
echo "SLACK_SIGNING_SECRET=$SLACK_SIGNING_SECRET" >> "$ENV_FILE"
echo "SLACK_CLIENT_SECRET=$SLACK_CLIENT_SECRET" >> "$ENV_FILE"
echo "" >> "$ENV_FILE"

# Also update .env.production
PROD_ENV_FILE="/Users/clawdia/apps/prdforge/.env.production"
if [ -f "$PROD_ENV_FILE" ]; then
    echo "📝 Updating $PROD_ENV_FILE with Slack configuration..."
    cp "$PROD_ENV_FILE" "$PROD_ENV_FILE.backup.$(date +%Y%m%d_%H%M%S)"
    echo "# Slack Configuration" >> "$PROD_ENV_FILE"
    echo "SLACK_WORKSPACE=$SLACK_WORKSPACE" >> "$PROD_ENV_FILE"
    echo "SLACK_BOT_TOKEN=$SLACK_BOT_TOKEN" >> "$PROD_ENV_FILE"
    echo "SLACK_SIGNING_SECRET=$SLACK_SIGNING_SECRET" >> "$PROD_ENV_FILE"
    echo "" >> "$PROD_ENV_FILE"
fi

echo "✅ Slack environment variables saved!"
echo ""
echo "📋 Summary of what was saved:"
echo "   - SLACK_WORKSPACE: [saved]"
echo "   - SLACK_ADMIN_EMAIL: [saved]"
echo "   - SLACK_ADMIN_PASSWORD: [NOT saved - use password manager]"
echo "   - SLACK_BOT_TOKEN: [saved]"
echo "   - SLACK_USER_TOKEN: [saved]"
echo "   - SLACK_SIGNING_SECRET: [saved]"
echo "   - SLACK_CLIENT_SECRET: [saved]"
echo ""
echo "⚠️  Security Notes:"
echo "   1. Admin password was NOT saved to .env (use password manager)"
echo "   2. Original .env files backed up with timestamp"
echo "   3. Consider rotating tokens if they were exposed"
echo ""
echo "To use these variables in your app, access them via process.env in Node.js"
echo "or import.meta.env in Vite/React applications."