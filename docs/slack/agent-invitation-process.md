# Agent Invitation Process for Slack Workspace

## Overview
This document outlines the process for inviting the remaining 4 agents to the `clawdiasagents.slack.com` workspace.

## Current Status
- **Workspace**: `clawdiasagents.slack.com`
- **Existing Agents**: 6 (Trinity, Fela, Shuri, Ebun, Nova, Sheba)
- **Missing Agents**: 4 (Ruth, Ngozi, Cypher, Morpheus)
- **Admin Account**: `clawdianinan@gmail.com` (Primary owner)

## Missing Agents Details

| Agent | Role | Email | Required Channels |
|-------|------|-------|-------------------|
| Ruth | GDPR Compliance | `clawdianinan+ruth@gmail.com` | `#compliance`, `#prdforge-launch` |
| Ngozi | Payment Compliance | `clawdianinan+ngozi@gmail.com` | `#compliance`, `#prdforge-launch` |
| Cypher | Security Specialist | `clawdianinan+cypher@gmail.com` | `#security`, `#development`, `#prdforge-launch` |
| Morpheus | QA/Testing Specialist | `clawdianinan+morpheus@gmail.com` | `#testing`, `#development`, `#prdforge-launch` |

## Invitation Methods

### Method 1: Manual Invitation (Recommended)
1. **Log in** to `https://clawdiasagents.slack.com` as admin (`clawdianinan@gmail.com`)
2. Click **"Invite people to Clawdia's Agents"** in the sidebar
3. Enter all 4 emails:
   - `clawdianinan+ruth@gmail.com`
   - `clawdianinan+ngozi@gmail.com`
   - `clawdianinan+cypher@gmail.com`
   - `clawdianinan+morpheus@gmail.com`
4. Click **"Send Invitations"**
5. Check `clawdianinan@gmail.com` inbox for invitation emails
6. Accept invitations for each agent

### Method 2: API Invitation (Requires Admin Token)
If you have a token with `admin.users:write` scope:
```bash
TOKEN="xoxp-YOUR-ADMIN-TOKEN-HERE"
curl -X POST "https://slack.com/api/admin.users.invite" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "channel_ids": "C0AN48P3FC1",
    "email": "clawdianinan+ruth@gmail.com",
    "real_name": "Ruth (GDPR Compliance)",
    "resend": true
  }'
```

### Method 3: Browser Automation
Use automation tools like Selenium or Playwright to:
1. Log in to Slack web interface
2. Navigate to invitation page
3. Enter emails and send invitations

## Channel Creation
The following channels need to be created (if they don't exist):
1. `#development` - For Trinity, Morpheus, Cypher
2. `#design` - For Fela
3. `#documentation` - For Ebun
4. `#compliance` - For Ruth, Ngozi
5. `#operations` - For Shuri, Nova
6. `#testing` - For Morpheus
7. `#security` - For Cypher

## Acceptance Process
1. **Check Email**: All agent emails forward to `clawdianinan@gmail.com`
2. **Open Invitations**: Look for emails from `slack.com` or `clawdiasagents.slack.com`
3. **Accept Invitations**: Click "Join Now" in each email
4. **Set Up Profiles**: Complete Slack signup for each agent

## Verification Steps
1. Verify all 10 agents appear in Slack member list
2. Confirm each agent is added to appropriate channels
3. Test communication in `#prdforge-launch` channel
4. Document completion in project records

## Troubleshooting
- **Invitation not received**: Check spam folder, resend invitation
- **Cannot accept invitation**: Ensure using correct email address
- **Channel creation failed**: Verify token has `conversations.create` scope
- **Agent not showing in workspace**: Wait 5-10 minutes, refresh page

## Success Criteria
- ✅ All 10 agents invited to Slack
- ✅ All invitations accepted
- ✅ Agents added to appropriate channels
- ✅ Slack workspace fully populated with project team

## Files Created
- `docs/slack/agent-invitation-process.md` - This document
- `docs/slack/agent-channel-assignments.md` - Channel membership guide
- `slack-invitation-completion-report.md` - Results summary

## Jira Reference
- **Ticket**: DEV-26 (Slack Integration)
- **Status**: In Progress
- **Assignee**: Shuri (Operations Analysis)