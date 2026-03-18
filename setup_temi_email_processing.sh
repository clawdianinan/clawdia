#!/bin/bash
# Setup script for Temi's email processing automation

set -e

echo "========================================="
echo "Setting up Temi Email Processing for OpenClaw"
echo "========================================="

# Configuration
WORKSPACE_DIR="/Users/clawdia/.openclaw/workspace"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
PLIST_FILE="com.openclaw.mailwatcher.plist"

echo "1. Making scripts executable..."
chmod +x "$WORKSPACE_DIR/process_temi_emails.sh"
chmod +x "$WORKSPACE_DIR/mail_notification_handler.sh"
chmod +x "$WORKSPACE_DIR/setup_temi_email_processing.sh"

echo "2. Testing OpenClaw connectivity..."
if ! command -v openclaw >/dev/null 2>&1; then
    echo "Error: OpenClaw CLI not found in PATH"
    exit 1
fi

echo "3. Testing himalaya email client..."
if ! command -v himalaya >/dev/null 2>&1; then
    echo "Warning: himalaya not found. Email processing will use Apple Mail SQLite."
    echo "Install himalaya with: brew install himalaya"
fi

echo "4. Checking existing cron jobs..."
openclaw cron list

echo "5. Setting up launchd agent for Mail notifications..."
if [[ -f "$WORKSPACE_DIR/$PLIST_FILE" ]]; then
    # Stop existing agent if running
    if launchctl list | grep -q "com.openclaw.mailwatcher"; then
        echo "Stopping existing mailwatcher agent..."
        launchctl unload "$LAUNCH_AGENTS_DIR/$PLIST_FILE" 2>/dev/null || true
    fi
    
    # Copy plist to LaunchAgents
    cp "$WORKSPACE_DIR/$PLIST_FILE" "$LAUNCH_AGENTS_DIR/"
    
    # Load and start the agent
    launchctl load "$LAUNCH_AGENTS_DIR/$PLIST_FILE"
    launchctl start com.openclaw.mailwatcher
    
    echo "Launchd agent installed and started"
else
    echo "Warning: Plist file not found at $WORKSPACE_DIR/$PLIST_FILE"
fi

echo "6. Documentation updated:"
echo "  - EMAIL_PROCESSING_SETUP.md (updated with correct email addresses)"
echo "  - EMAIL_ADDRESS_MAPPING.md (created with clear USER vs Clawdia distinction)"

echo "7. Summary:"
echo "========================================="
echo "✅ Setup complete!"
echo ""
echo "What was configured:"
echo "1. OpenClaw cron job: 'Temi Email Processor' (every 10 minutes)"
echo "2. Mail notification handler script"
echo "3. Launchd agent for periodic checks (every 5 minutes)"
echo "4. Documentation: EMAIL_PROCESSING_SETUP.md"
echo ""
echo "To test immediately:"
echo "  openclaw cron run --id d18a4267-9138-4d4f-8de4-0d6f013cac51"
echo ""
echo "To monitor:"
echo "  tail -f /tmp/mail_notification_handler.log"
echo "  openclaw cron list"
echo "========================================="