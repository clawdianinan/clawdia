# Slack Scope Upgrade Solution

## Problem
The current Slack app tokens lack necessary scopes:
- ❌ `admin.users:write` (to invite users)
- ❌ `conversations:write` (to create channels)
- ❌ `conversations:read` (to list channels)
- ❌ `users:read` (to list users)

## Current Tokens (from image extraction)
- **Bot Token:** `xoxb-10752295117408-10724380225666-jDMryiNyIBV1mjGbVpgJIjPI`
- **User Token:** `xoxp-10752295117408-10721969604214-10720956806053-2d89834682ea00843afbce63f78d73a1`
- **Scopes:** Only `chat:write` (can post messages)

## Solution: Update App Scopes

### Step 1: Log into Slack App Dashboard
1. Go to: https://api.slack.com/apps/AOAM6NOGFOD
2. Log in with workspace admin credentials
   - Workspace: `clawdiasagents.slack.com`
   - Admin credentials needed (not in image)

### Step 2: Update OAuth & Permissions Scopes
In the app dashboard, add these scopes:

#### Bot Token Scopes:
```
admin.users:write
channels:manage
channels:read
groups:write
groups:read
im:write
im:read
mpim:write
mpim:read
users:read
users:read.email
```

#### User Token Scopes:
```
admin.users:write
channels:manage
channels:read
groups:write
groups:read
```

### Step 3: Reinstall App
1. Go to "OAuth & Permissions"
2. Click "Reinstall App"
3. Authorize with admin account
4. Get new tokens

### Step 4: Update Environment Variables
Update `.env` files with new tokens.

## Automated Solution Script

Once scopes are updated, this script will work:

```bash
#!/bin/bash
# slack-automation.sh

# Load credentials from .env
source /Users/clawdia/apps/prdforge/.env

# Invite missing agents
invite_agent() {
    local email=$1
    local name=$2
    curl -X POST -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
        -H "Content-type: application/json" \
        -d "{\"channel_ids\":\"C0AM41CFBV1\",\"email\":\"$email\",\"real_name\":\"$name\",\"resend\":true}" \
        "https://slack.com/api/admin.users.invite"
}

# Create channels
create_channel() {
    local name=$1
    curl -X POST -H "Authorization: Bearer $SLACK_BOT_TOKEN" \
        -H "Content-type: application/json" \
        -d "{\"name\":\"$name\",\"is_private\":false}" \
        "https://slack.com/api/conversations.create"
}

# Invite agents
invite_agent "clawdianinan+ruth@gmail.com" "Ruth (GDPR Compliance)"
invite_agent "clawdianinan+ngozi@gmail.com" "Ngozi (Payment Compliance)"
invite_agent "clawdianinan+cypher@gmail.com" "Cypher (Security)"
invite_agent "clawdianinan+morpheus@gmail.com" "Morpheus (QA/Testing)"

# Create channels
create_channel "development"
create_channel "design"
create_channel "documentation"
create_channel "compliance"
create_channel "operations"
create_channel "testing"
create_channel "security"
```

## Alternative: Manual Completion

If updating scopes isn't possible right now, here are manual steps:

### Manual Step 1: Invite Agents
1. Log into `clawdiasagents.slack.com` as admin
2. Go to "Invite people to Clawdia's Agents"
3. Invite these emails:
   - `clawdianinan+ruth@gmail.com`
   - `clawdianinan+ngozi@gmail.com`
   - `clawdianinan+cypher@gmail.com`
   - `clawdianinan+morpheus@gmail.com`

### Manual Step 2: Create Channels
1. In Slack, click "+" next to "Channels"
2. Create these public channels:
   - `#development`
   - `#design`
   - `#documentation`
   - `#compliance`
   - `#operations`
   - `#testing`
   - `#security`

### Manual Step 3: Add Agents to Channels
Add each agent to appropriate channels based on their specialty.

## What I've Already Done

✅ **Extracted credentials from image**
✅ **Saved to environment variables**
✅ **Tested API access** (limited to posting messages)
✅ **Analyzed scope limitations**
✅ **Created comprehensive solution**

## Next Action Required

**You need to:** Update Slack app scopes OR manually invite agents/create channels.

Once that's done, I can complete the automation.

## Security Note

Credentials were extracted from an image. Consider:
1. Rotating tokens after scope update
2. Reviewing app permissions
3. Monitoring app usage