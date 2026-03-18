# Slack Agent Setup Guide

## Overview
This document outlines the process for adding missing agents to the IIH Slack workspace and configuring their profiles with proper roles and permissions.

## Missing Agents to Invite
The following agents need to be invited to the Slack workspace:

1. **Ruth** - Compliance specialist
2. **Ngozi** - Compliance specialist  
3. **Cypher** - Security specialist
4. **Morpheus** - Testing/Development specialist

## Email Configuration
All agents will use the following email pattern:
- `clawdianinan+agentname@gmail.com`

### Agent Email Addresses:
- Ruth: `clawdianinan+ruth@gmail.com`
- Ngozi: `clawdianinan+ngozi@gmail.com`
- Cypher: `clawdianinan+cypher@gmail.com`
- Morpheus: `clawdianinan+morpheus@gmail.com`

## Invitation Process

### Step 1: Send Invitations
1. Log into Slack Admin Console
2. Navigate to **Settings & administration** → **Manage members**
3. Click **Invite people**
4. Add each agent email address
5. Select appropriate channels for initial access
6. Send invitations

### Step 2: Profile Setup
For each agent, configure the following profile details:

#### Required Profile Fields:
- **Display name**: Agent name (e.g., "Ruth")
- **Full name**: Full agent name with role (e.g., "Ruth - Compliance Specialist")
- **Title**: Agent specialization (e.g., "Compliance Specialist")
- **Email**: Corresponding Gmail address
- **Profile picture**: Use agent avatar if available
- **Status**: Set default status based on role

### Step 3: Role Assignment

#### Slack Roles:
1. **Workspace Admin** (for Clawdia only)
2. **Workspace Owner** (for Temi only)
3. **Member** (for all agents)
4. **Guest** (not applicable for agents)

#### Custom Roles/Permissions:
- **Channel creation**: Enabled for team leads
- **App installation**: Restricted to admins only
- **File uploads**: Enabled for all agents
- **External sharing**: Disabled for compliance/security agents
- **Message editing**: Enabled with time limit (24 hours)

### Step 4: Channel Access
Grant initial channel access to each agent:

#### Initial Channel Assignments:
- **All agents**: `#prdforge-launch`, `#general`, `#announcements`
- **Role-specific channels**: See channel setup document

## Verification Checklist

### ✅ Agent Invitation Verification
- [ ] All invitation emails sent successfully
- [ ] Invitation links not expired
- [ ] Agents have accepted invitations
- [ ] All agents appear in member list

### ✅ Profile Configuration Verification
- [ ] Display names correctly set
- [ ] Full names include role designation
- [ ] Titles accurately reflect specialization
- [ ] Email addresses match pattern
- [ ] Profile pictures uploaded (if applicable)

### ✅ Permission Verification
- [ ] All agents have "Member" role
- [ ] Channel creation permissions correctly set
- [ ] File upload permissions enabled
- [ ] External sharing restrictions applied where needed
- [ ] Message editing time limits configured

### ✅ Channel Access Verification
- [ ] All agents added to `#prdforge-launch`
- [ ] Role-specific channel assignments completed
- [ ] No unauthorized channel access granted

## Troubleshooting

### Common Issues:
1. **Invitation not received**: Check spam folder, resend invitation
2. **Profile update errors**: Verify admin permissions, try browser refresh
3. **Permission conflicts**: Review role hierarchy, adjust as needed
4. **Channel access issues**: Verify channel visibility settings

### Escalation Path:
1. Retry operation with admin privileges
2. Check Slack status page for service issues
3. Contact Slack support if persistent issues
4. Document issue in operations log

## Maintenance

### Regular Tasks:
- Monthly review of agent permissions
- Quarterly audit of channel access
- Profile updates when agent roles change
- Removal of inactive agents (if applicable)

### Documentation Updates:
- Update this document when new agents are added
- Maintain change log of permission modifications
- Document any troubleshooting solutions

## Security Considerations

### Data Protection:
- Agent emails contain no sensitive personal data
- Profile information limited to role and specialization
- No confidential information in public profiles

### Access Control:
- Regular review of agent access levels
- Immediate revocation for security incidents
- Audit trail of all permission changes

---

**Last Updated**: 2026-03-18  
**Version**: 1.0  
**Author**: Shuri (Operations Analysis Specialist)  
**Status**: Active