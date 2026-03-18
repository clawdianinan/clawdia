#!/bin/bash

# ORBIT Password Change - Manual Instructions
# This script opens the browser and provides instructions for changing the ORBIT password

echo "================================================"
echo "ORBIT PASSWORD CHANGE INSTRUCTIONS"
echo "================================================"
echo ""
echo "STEP 1: Open ORBIT Login Page"
echo "URL: https://orbit2.iih.ng/login"
echo ""
echo "STEP 2: Login with Current Credentials"
echo "Email: clawdia.ai@iih.ng"
echo "Current Password: N49eYXkwV6A9W\$k"
echo ""
echo "STEP 3: Navigate to Profile/Settings"
echo "After login, look for:"
echo "  - User avatar/profile picture"
echo "  - 'Settings' or 'Account' menu"
echo "  - 'Profile' or 'Security' section"
echo ""
echo "STEP 4: Change Password"
echo "Look for 'Change Password' option"
echo "Current Password: N49eYXkwV6A9W\$k"
echo "New Password: m!r@c#dFW3fezydV4PM"
echo "Confirm New Password: m!r@c#dFW3fezydV4PM"
echo ""
echo "STEP 5: Save Changes"
echo "Click 'Save', 'Update', or 'Change Password' button"
echo ""
echo "STEP 6: Test New Password"
echo "Log out and log back in with new password"
echo ""
echo "STEP 7: Update MCP Server Configuration"
echo "Update the .env file in orbit-mcp-server with new password"
echo ""
echo "================================================"
echo "Opening browser to ORBIT login page..."
echo "================================================"

# Open browser (macOS)
open "https://orbit2.iih.ng/login"

# Also create a configuration update script
cat > /Users/clawdia/.openclaw/workspace/orbit-mcp-server/update-password.sh << 'EOF'
#!/bin/bash
# Script to update ORBIT password in MCP server configuration

NEW_PASSWORD="m!r@c#dFW3fezydV4PM"

echo "Updating ORBIT MCP server configuration with new password..."
echo ""

# Create or update .env file
cat > .env << ENV_CONFIG
# ORBIT Supabase Configuration
ORBIT_SUPABASE_URL=https://jnlkzcmeiksqljnbtfhb.supabase.co
ORBIT_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpubGt6Y21laWtzcWxqbmJ0ZmhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUwODg3MTUsImV4cCI6MjA2MDY2NDcxNX0.oHvsn37LuRdlkn3bGsgvOu2GK2PCCDku5hKtLAIbWo0

# ORBIT API Configuration
ORBIT_API_BASE_URL=https://orbit2.iih.ng/api
ORBIT_ADMIN_EMAIL=clawdia.ai@iih.ng
ORBIT_ADMIN_PASSWORD=${NEW_PASSWORD}

# Note: Service role key needed for full MCP functionality
ORBIT_SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here
ENV_CONFIG

echo ".env file updated with new password"
echo ""
echo "To test the new password, run:"
echo "cd /Users/clawdia/.openclaw/workspace/orbit-mcp-server"
echo "node test-orbit-api.js"
echo ""
echo "Remember to update any other systems using the old password!"
EOF

chmod +x /Users/clawdia/.openclaw/workspace/orbit-mcp-server/update-password.sh

echo ""
echo "Browser opened. Please follow the instructions above."
echo ""
echo "After changing password, run this command to update MCP server:"
echo "cd /Users/clawdia/.openclaw/workspace/orbit-mcp-server && ./update-password.sh"
echo ""
echo "================================================"