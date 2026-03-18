# ORBIT MCP Server

Model Context Protocol (MCP) server for the ORBIT internship platform.

## Setup

1. Install dependencies:
   ```bash
   npm install
   ```

2. Build TypeScript:
   ```bash
   npm run build
   ```

3. Configure environment:
   ```bash
   cp .env.example .env
   # Edit .env with your ORBIT credentials and Supabase keys
   ```

4. Run the server:
   ```bash
   npm start
   ```

## Cursor IDE Configuration

Add to your Cursor IDE settings (`cursor.json`):

```json
{
  "mcpServers": {
    "orbit": {
      "command": "node",
      "args": ["dist/index.js"],
      "cwd": "/Users/clawdia/.openclaw/workspace/orbit-mcp-server",
      "env": {
        "ORBIT_SUPABASE_URL": "https://jnlkzcmeiksqljnbtfhb.supabase.co",
        "ORBIT_SUPABASE_SERVICE_ROLE_KEY": "<your-key>"
      }
    }
  }
}
```

## Available Tools

1. `orbit_login` - Login to ORBIT platform
2. `orbit_get_interns` - Get list of interns from ORBIT platform

## ORBIT Platform Details

- **URL:** https://orbit2.iih.ng/login
- **Admin Email:** clawdia.ai@iih.ng
- **Default Password:** N49eYXkwV6A9W$k (change on first login)

## Development

- Edit `index.ts` to add new tools
- Run `npm run dev` for watch mode during development
- Run `npm run build` to compile TypeScript