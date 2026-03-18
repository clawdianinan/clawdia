"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const index_js_1 = require("@modelcontextprotocol/sdk/server/index.js");
const stdio_js_1 = require("@modelcontextprotocol/sdk/server/stdio.js");
const types_js_1 = require("@modelcontextprotocol/sdk/types.js");
// ORBIT API Configuration
const ORBIT_SUPABASE_URL = process.env.ORBIT_SUPABASE_URL || 'https://jnlkzcmeiksqljnbtfhb.supabase.co';
const ORBIT_SUPABASE_ANON_KEY = process.env.ORBIT_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpubGt6Y21laWtzcWxqbmJ0ZmhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUwODg3MTUsImV4cCI6MjA2MDY2NDcxNX0.oHvsn37LuRdlkn3bGsgvOu2GK2PCCDku5hKtLAIbWo0';
// Create MCP server
const server = new index_js_1.Server({
    name: 'orbit-mcp-server',
    version: '1.0.0',
}, {
    capabilities: {
        tools: {},
    },
});
// Helper function to make ORBIT API calls
async function makeOrbitApiCall(endpoint, method = 'POST', body, useAuthHeader = false) {
    const headers = {
        'apikey': ORBIT_SUPABASE_ANON_KEY,
        'Content-Type': 'application/json',
        'Prefer': 'return=representation'
    };
    // Note: ORBIT RPC functions typically don't use Authorization header
    // They pass token as p_token parameter in the body
    const response = await fetch(`${ORBIT_SUPABASE_URL}/rest/v1/rpc/${endpoint}`, {
        method,
        headers,
        body: body ? JSON.stringify(body) : undefined
    });
    if (!response.ok) {
        const errorText = await response.text();
        throw new Error(`API call failed: ${response.status} ${response.statusText} - ${errorText}`);
    }
    return response.json();
}
// List available tools
server.setRequestHandler(types_js_1.ListToolsRequestSchema, async () => {
    return {
        tools: [
            {
                name: 'orbit_login',
                description: 'Login to ORBIT platform',
                inputSchema: {
                    type: 'object',
                    properties: {
                        email: { type: 'string' },
                        password: { type: 'string' }
                    },
                    required: ['email', 'password']
                }
            },
            {
                name: 'orbit_get_activity_feed',
                description: 'Get activity feed from ORBIT platform',
                inputSchema: {
                    type: 'object',
                    properties: {
                        token: { type: 'string' },
                        limit: { type: 'number' },
                        offset: { type: 'number' }
                    },
                    required: ['token']
                }
            },
            {
                name: 'orbit_get_users',
                description: 'Get users from ORBIT platform',
                inputSchema: {
                    type: 'object',
                    properties: {
                        token: { type: 'string' },
                        role: { type: 'string' },
                        limit: { type: 'number' }
                    },
                    required: ['token']
                }
            }
            // Add more tools as needed based on MCP_CONNECTION_GUIDE.md
        ],
    };
});
// Handle tool calls
server.setRequestHandler(types_js_1.CallToolRequestSchema, async (request) => {
    const { name, arguments: args } = request.params;
    try {
        switch (name) {
            case 'orbit_login':
                if (!args?.email || !args?.password) {
                    throw new Error('Email and password are required');
                }
                const loginResult = await makeOrbitApiCall('orbit_login', 'POST', {
                    p_email: args.email,
                    p_password: args.password
                });
                return {
                    content: [
                        {
                            type: 'text',
                            text: JSON.stringify(loginResult, null, 2),
                        },
                    ],
                };
            case 'orbit_get_activity_feed':
                if (!args?.token) {
                    throw new Error('Token is required');
                }
                const feedResult = await makeOrbitApiCall('orbit_get_activity_feed', 'POST', {
                    p_token: args.token,
                    p_limit: args.limit || 10,
                    p_offset: args.offset || 0
                });
                return {
                    content: [
                        {
                            type: 'text',
                            text: JSON.stringify(feedResult, null, 2),
                        },
                    ],
                };
            case 'orbit_get_users':
                if (!args?.token) {
                    throw new Error('Token is required');
                }
                // For now, we'll use a placeholder since we don't have the exact RPC function
                // In a real implementation, you would call the actual ORBIT user API
                return {
                    content: [
                        {
                            type: 'text',
                            text: `Getting users with role: ${args.role || 'all'}. This function needs the actual ORBIT user API endpoint.`,
                        },
                    ],
                };
            default:
                throw new Error(`Tool ${name} not found`);
        }
    }
    catch (error) {
        return {
            content: [
                {
                    type: 'text',
                    text: `Error: ${error.message}`,
                },
            ],
        };
    }
});
// Start server with stdio transport
async function main() {
    const transport = new stdio_js_1.StdioServerTransport();
    await server.connect(transport);
    console.error('ORBIT MCP server running on stdio');
}
main().catch((error) => {
    console.error('Server error:', error);
    process.exit(1);
});
