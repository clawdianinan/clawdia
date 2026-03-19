# Slack Environment Variables Setup Guide

## What to Extract from the Image

From the Slack configuration image you sent, extract these values:

### 1. **Workspace Information**
- [ ] **Slack Workspace URL**: `clawdiasagents.slack.com` (likely)
- [ ] **Team ID**: `T0AN48P3FC0` (from earlier)

### 2. **Admin Credentials** (for web interface access)
- [ ] **Admin Email**: `[from image]`
- [ ] **Admin Password**: `[from image]` ⚠️ **DO NOT SAVE IN .ENV**

### 3. **API Tokens** (for programmatic access)
- [ ] **Bot Token (xoxb-)**: `[from image]`
- [ ] **User Token (xoxp-)**: `[from image]`
- [ ] **Signing Secret**: `[from image]`
- [ ] **Client Secret**: `[from image]`
- [ ] **Client ID**: `[from image]`
- [ ] **Verification Token**: `[from image]`

### 4. **App Information**
- [ ] **App ID**: `[from image]`
- [ ] **App Name**: `[from image]`

## How to Save Securely

### Option A: Run the Script (Recommended)
```bash
chmod +x /Users/clawdia/.openclaw/workspace/save-slack-env.sh
cd /Users/clawdia/.openclaw/workspace
./save-slack-env.sh
```

### Option B: Manual Update
Edit `/Users/clawdia/apps/prdforge/.env` and add:

```bash
# Slack Configuration
SLACK_WORKSPACE=clawdiasagents.slack.com
SLACK_BOT_TOKEN=xoxb-...
SLACK_USER_TOKEN=xoxp-...
SLACK_SIGNING_SECRET=...
SLACK_CLIENT_SECRET=...
SLACK_CLIENT_ID=...
```

## Security Best Practices

### ✅ **DO Save in .env:**
- API Tokens (xoxb, xoxp)
- Signing Secret
- Client Secret
- Client ID

### ❌ **DO NOT Save in .env:**
- Admin passwords
- Personal access tokens (unless specifically for automation)
- Any credentials that grant admin/web interface access

### 🔒 **Additional Security Steps:**
1. **Rotate tokens** if they were exposed in the image
2. **Enable 2FA** on admin account
3. **Restrict token scopes** to minimum required
4. **Use .env.local** for development, not committed to git
5. **Use environment variables** in production (not hardcoded)

## What This Enables

With these environment variables set, we can:

### 1. **Automate Slack Operations**
- Invite agents programmatically
- Create channels automatically
- Post updates to channels
- Manage user permissions

### 2. **Integrate with PRDForge**
- Slack notifications for PRD generation
- Error alerts to Slack channels
- Team collaboration workflows

### 3. **Complete Our Setup**
- Add missing agents (Ruth, Ngozi, Cypher, Morpheus)
- Create team channels (#development, #design, etc.)
- Establish communication protocols

## Next Steps After Saving

Once environment variables are saved:

1. **Test Slack API access**
2. **Invite missing agents** programmatically
3. **Create missing channels**
4. **Update Slack integration documentation**
5. **Complete the Slack setup task**

## Verification

After saving, verify by running:
```bash
cd /Users/clawdia/apps/prdforge
grep -i slack .env
```

You should see the Slack variables in the output.