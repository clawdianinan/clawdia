#!/usr/bin/env python3
"""
List Convex projects using the Management API.

Requires CONVEX_API_TOKEN environment variable.
Optionally set CONVEX_TEAM_ID; if not provided, fetches team ID via token details.
"""

import os
import sys
import json
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

def list_projects(token, team_id):
    """List projects for a team."""
    url = f"{API_BASE}/teams/{team_id}/list_projects"
    headers = {"Authorization": f"Bearer {token}"}
    try:
        resp = requests.get(url, headers=headers, timeout=10)
        resp.raise_for_status()
        return resp.json()
    except requests.exceptions.RequestException as e:
        print(f"Error listing projects: {e}", file=sys.stderr)
        return None

def main():
    token = os.environ.get("CONVEX_API_TOKEN")
    if not token:
        print("Error: CONVEX_API_TOKEN environment variable not set.", file=sys.stderr)
        print("Obtain a team access token from Convex dashboard.", file=sys.stderr)
        sys.exit(1)

    team_id = os.environ.get("CONVEX_TEAM_ID")
    if not team_id:
        print("Team ID not provided, fetching from token details...")
        team_id = get_team_id(token)
        if not team_id:
            print("Failed to get team ID. Please set CONVEX_TEAM_ID manually.", file=sys.stderr)
            sys.exit(1)
        print(f"Using team ID: {team_id}")

    projects = list_projects(token, team_id)
    if projects is None:
        sys.exit(1)

    print(json.dumps(projects, indent=2))

if __name__ == "__main__":
    main()