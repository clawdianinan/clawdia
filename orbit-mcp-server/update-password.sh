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
