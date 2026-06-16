#!/usr/bin/env python3
"""
Create a Convex project using the Management API.

Requires CONVEX_API_TOKEN environment variable.
Optionally set CONVEX_TEAM_ID; if not provided, fetches team ID via token details.
"""

import os
import sys
import json
import argparse
import requests

API_BASE = "https://api.convex.dev/v1"

def get_team_id(token):
    """Get team ID from token details endpoint."""
    url = f"{API_BASE}/token_details"
    headers = {"Authorization": f"Bearer {token}"}
    try:
        resp = requests.get(url, headers=headers, timeout=10)
        resp.raise_for_status()
        data = resp.json()
        return data.get("team_id")
    except requests.exceptions.RequestException as e:
        print(f"Error fetching team ID: {e}", file=sys.stderr)
        if resp.status_code == 401:
            print("Token invalid or expired.", file=sys.stderr)
        return None

def create_project(token, team_id, project_name, provision_dev=False, provision_prod=False):
    """Create a new project."""
    url = f"{API_BASE}/teams/{team_id}/create_project"
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    payload = {
        "name": project_name,
    }
    if provision_dev:
        payload["provisionDev"] = True
    if provision_prod:
        payload["provisionProd"] = True

    try:
        resp = requests.post(url, headers=headers, json=payload, timeout=30)
        resp.raise_for_status()
        return resp.json()
    except requests.exceptions.RequestException as e:
        print(f"Error creating project: {e}", file=sys.stderr)
        if resp.status_code == 400:
            print(f"Response: {resp.text}", file=sys.stderr)
        return None

def main():
    parser = argparse.ArgumentParser(description="Create a Convex project.")
    parser.add_argument("--name", required=True, help="Project name")
    parser.add_argument("--team-id", help="Team ID (default: infer from token)")
    parser.add_argument("--provision-dev", action="store_true", help="Provision a dev deployment")
    parser.add_argument("--provision-prod", action="store_true", help="Provision a prod deployment")
    args = parser.parse_args()

    token = os.environ.get("CONVEX_API_TOKEN")
    if not token:
        print("Error: CONVEX_API_TOKEN environment variable not set.", file=sys.stderr)
        print("Obtain a team access token from Convex dashboard.", file=sys.stderr)
        sys.exit(1)

    team_id = args.team_id or os.environ.get("CONVEX_TEAM_ID")
    if not team_id:
        print("Team ID not provided, fetching from token details...")
        team_id = get_team_id(token)
        if not team_id:
            print("Failed to get team ID. Please set --team-id or CONVEX_TEAM_ID.", file=sys.stderr)
            sys.exit(1)
        print(f"Using team ID: {team_id}")

    result = create_project(token, team_id, args.name, args.provision_dev, args.provision_prod)
    if result is None:
        sys.exit(1)

    print(json.dumps(result, indent=2))

if __name__ == "__main__":
    main()