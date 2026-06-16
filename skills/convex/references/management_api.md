# Convex Management API Reference

## Overview

The Convex Management API allows programmatic management of teams, projects, deployments, and access tokens. It is useful for automating project creation, listing deployments, and integrating Convex into CI/CD pipelines.

**Base URL:** `https://api.convex.dev/v1`

## Authentication

Use a Bearer token in the Authorization header.

```bash
curl -H "Authorization: Bearer $CONVEX_API_TOKEN" https://api.convex.dev/v1/token_details
```

Token types:
- **Team Access Token**: Grants access to all resources within a team. Obtain from Convex dashboard under Team Settings > Access Tokens.
- **OAuth Team Token**: For third‑party integrations.
- **Personal Access Token**: For individual user automation.

## Endpoints

### Get Token Details
`GET /token_details`

Returns the team ID for team tokens.

**Response:**
```json
{
  "team_id": 123
}
```

### List Projects
`GET /teams/{team_id}/list_projects`

List all projects for a team.

**Response:**
```json
[
  {
    "id": 456,
    "name": "My Project",
    "slug": "my-project",
    "team_id": 123,
    "created_at": "2026-01-01T00:00:00Z"
  }
]
```

### Create Project
`POST /teams/{team_id}/create_project`

Create a new project on a team.

**Request Body:**
```json
{
  "name": "Project Name",
  "provisionDev": true,
  "provisionProd": false
}
```

**Response:**
```json
{
  "id": 456,
  "name": "Project Name",
  "slug": "project-name",
  "team_id": 123,
  "dev_deployment": "happy-animal-123",
  "prod_deployment": null
}
```

### Get Project by ID
`GET /projects/{project_id}`

### Get Project by Slug
`GET /teams/{team_id_or_slug}/projects/{project_slug}`

### Delete Project
`POST /projects/{project_id}/delete`

Deletes a project and all its deployments.

### List Deployments
`GET /projects/{project_id}/list_deployments`

List deployments for a project.

**Query parameters:**
- `includeLocal` (boolean): Include local deployments created by the caller.
- `isDefault` (boolean): Filter by default deployment status.
- `deploymentType` (string): `dev`, `prod`, `preview`, `custom`.

### Create Deployment
`POST /projects/{project_id}/create_deployment`

Create a new deployment for a project.

**Request Body:**
```json
{
  "type": "dev",
  "class": "s16",
  "region": "us-east-1"
}
```

### Get Deployment
`GET /deployments/{deployment_name}`

### Update Deployment
`PATCH /deployments/{deployment_name}`

### Delete Deployment
`POST /deployments/{deployment_name}/delete`

### Create Deploy Key
`POST /deployments/{deployment_name}/create_deploy_key`

Create a deploy key for a deployment (e.g., `dev:happy-animal-123|ey...`).

### List Deploy Keys
`GET /deployments/{deployment_name}/list_deploy_keys`

### Delete Deploy Key
`POST /deployments/{deployment_name}/delete_deploy_key`

### Create Preview Deploy Key
`POST /projects/{project_id}/create_preview_deploy_key`

### List Preview Deploy Keys
`GET /projects/{project_id}/list_preview_deploy_keys`

### List Team Members
`GET /teams/{team_id}/list_members`

### Create Team Access Token
`POST /teams/{team_id}/create_access_token`

### List Personal Access Tokens
`GET /list_personal_access_tokens`

### Create Personal Access Token
`POST /create_personal_access_token`

### Delete Personal Access Token
`POST /delete_personal_access_token`

## Error Handling

Responses use standard HTTP status codes:

- `200`: Success
- `400`: Bad request (invalid parameters)
- `401`: Unauthorized (invalid or missing token)
- `403`: Forbidden (token lacks permission)
- `404`: Resource not found
- `429`: Rate limit exceeded

Errors include a JSON body with a `message` field.

## Rate Limits

The API is rate‑limited per token. Check `X-RateLimit-*` headers.

## Using with Python

Example script:

```python
import os
import requests

token = os.environ["CONVEX_API_TOKEN"]
team_id = 123

headers = {"Authorization": f"Bearer {token}"}

# List projects
resp = requests.get(f"https://api.convex.dev/v1/teams/{team_id}/list_projects", headers=headers)
projects = resp.json()
```

## Using with cURL

```bash
curl -H "Authorization: Bearer $CONVEX_API_TOKEN" \
  "https://api.convex.dev/v1/teams/123/list_projects"
```

## OpenAPI Specification

Full OpenAPI spec available at:
https://api.convex.dev/v1/openapi.json