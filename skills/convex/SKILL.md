---
name: convex
description: Manage and deploy Convex projects via CLI and API. Use when you need to work with Convex (backend-as-a-service) for project management (list, create, configure), deployment, development, environment variables, data operations, logs, and running functions. Includes wrappers for Convex CLI commands (`npx convex ...`) and optional Management API integration for advanced project management. Handles authentication via Convex login.
---

# Convex Skill

## Overview

This skill provides comprehensive access to Convex backend-as-a-service operations through the Convex CLI and Management API. It enables project management, deployment, development workflows, environment variable management, data operations, and log viewing.

## Authentication

Convex uses device-based authentication. Before using most commands, ensure you are logged in:

```bash
npx convex login
```

This will open a browser for authentication. The CLI stores credentials in `~/.convex/`.

To check if you're logged in, run any command that requires auth (e.g., `npx convex dev`). If not logged in, you'll be prompted.

For Management API access (project listing, creation), you'll need a team access token. Obtain it from the Convex dashboard under Team Settings > Access Tokens. Set it as environment variable `CONVEX_API_TOKEN`.

## Project Management

### List Projects

To list all projects in your team, use the Management API with a team access token:

```bash
export CONVEX_API_TOKEN=your_token_here
python3 scripts/list_projects.py
```

The script `scripts/list_projects.py` uses the Convex Management API to fetch projects. Requires `CONVEX_API_TOKEN` and `CONVEX_TEAM_ID` (optional). If team ID is not provided, the script will attempt to infer it from the token.

### Create a Project

There are two ways to create a Convex project:

1. **Via CLI (interactive)**: Run `npx convex dev` in a directory without a Convex project configured. It will guide you through creating a new project.

2. **Via Management API**: Use `scripts/create_project.py` with appropriate parameters (team ID, project name). Requires a team access token.

### Configure Project

Project configuration is stored in `convex.json` and environment variables (`CONVEX_DEPLOYMENT`, `CONVEX_DEPLOY_KEY`). Use `npx convex env` to manage environment variables for your deployment.

## Deployment

### Deploy to Production

```bash
npx convex deploy
```

Deploys your Convex functions to the production deployment of the current project. Ensure `CONVEX_DEPLOYMENT` or `CONVEX_DEPLOY_KEY` environment variable is set.

### Deploy to Preview

Set `CONVEX_DEPLOY_KEY` to a preview deploy key, then run `npx convex deploy`. Use `--preview-create` to name the preview deployment.

### Deploy with Custom Command

```bash
npx convex deploy --cmd "npm run build"
```

## Development

### Start Dev Server

```bash
npx convex dev
```

Watches your Convex functions and pushes changes to the development deployment. Use `--tail-logs` to control log output.

### Run a Function

```bash
npx convex run <functionName> [args]
```

Run a query, mutation, or action on your deployment. Arguments are JSON.

### Open Dashboard

```bash
npx convex dashboard
```

Opens the Convex dashboard in your browser.

### Generate Types

```bash
npx convex codegen
```

Updates generated TypeScript definitions in `convex/_generated`.

## Environment Variables

Manage deployment environment variables:

```bash
npx convex env list
npx convex env get <name>
npx convex env set <name> <value>
npx convex env remove <name>
```

Use `--prod` to manage production deployment variables.

## Data Operations

### List Tables and View Data

```bash
npx convex data
npx convex data <table>
```

### Import Data

```bash
npx convex import --table <tableName> <path>
```

### Export Data

```bash
npx convex export --path <directory>
```

## Logs

### Tail Deployment Logs

```bash
npx convex logs
```

Use `--prod` for production logs.

## Management API Scripts

The skill includes Python scripts for Management API operations. Ensure you have `requests` installed (`pip install requests`).

### List Projects Script

`scripts/list_projects.py` – Lists all projects in the team.

### Create Project Script

`scripts/create_project.py` – Creates a new project (requires team ID and project name).

### Common Setup

Set environment variables:

```bash
export CONVEX_API_TOKEN=your_team_access_token
export CONVEX_TEAM_ID=your_team_id  # optional, can be inferred
```

Run scripts with `--help` for usage.

## Examples

### Quick Start

1. Login to Convex: `npx convex login`
2. Create a new project: `mkdir myapp && cd myapp && npx convex dev`
3. Deploy: `npx convex deploy`
4. Set an environment variable: `npx convex env set API_KEY secret`
5. Run a function: `npx convex run myfunction '{"param": "value"}'`

### Listing Projects via API

```bash
export CONVEX_API_TOKEN=$(cat ~/.convex/token)  # if you have a token file
python3 scripts/list_projects.py
```

### Creating a Project via API

```bash
python3 scripts/create_project.py --team-id 123 --name "My New Project"
```

## References

- [Convex CLI Documentation](https://docs.convex.dev/cli)
- [Management API Reference](https://docs.convex.dev/management-api)
- [Convex Dashboard](https://dashboard.convex.dev)

## Troubleshooting

- **Not logged in**: Run `npx convex login`.
- **No project configured**: Ensure `CONVEX_DEPLOYMENT` is set or run `npx convex dev` to create a project.
- **Permission denied**: Check that your token has appropriate team/project permissions.
- **Script dependencies**: Install required Python packages: `pip install requests`.

---