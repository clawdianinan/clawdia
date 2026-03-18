# Jira ↔ Slack Integration Guide

## Overview
This document outlines the integration between Jira and Slack for the PRDForge project, enabling real-time notifications, status updates, and approval workflows between the two platforms.

## Integration Architecture

### Components:
1. **Jira Cloud Instance**: PRDForge project (DEV-* tickets)
2. **Slack Workspace**: IIH project workspace
3. **Integration Method**: Jira Cloud for Slack app
4. **Notification Channels**: Project-specific Slack channels

## Setup Process

### Step 1: Install Jira Cloud for Slack App
1. In Slack, go to **Apps** → **Browse Apps**
2. Search for "Jira Cloud"
3. Click **Add to Slack**
4. Authorize the integration
5. Select workspace for installation

### Step 2: Connect Jira Instance
1. In Slack, type `/jira connect`
2. Follow authentication flow to Jira
3. Select Jira Cloud instance (atlassian.net)
4. Grant necessary permissions:
   - Read issues
   - Create issues
   - Update issues
   - Manage webhooks

### Step 3: Configure Project Mapping
1. Map Jira project **PRDForge** to Slack
2. Set up notification channels for each project component

## Notification Configuration

### Channel Mapping Table

| Jira Component | Slack Channel | Notification Type |
|----------------|---------------|-------------------|
| Project-wide | `#prdforge-launch` | Major milestones, project updates |
| Development | `#development` | DEV tickets, technical updates |
| Design | `#design` | Design-related tickets |
| Documentation | `#documentation` | Documentation tickets |
| Compliance | `#compliance` | Compliance-related tickets |
| Operations | `#operations` | Operational tickets |
| Testing | `#testing` | Test-related tickets, QA updates |
| Security | `#security` | Security-related tickets |

### Notification Types

#### 1. Ticket Created
- **Trigger**: New Jira ticket created
- **Slack Message**: 
  ```
  🆕 Ticket Created: [DEV-XXX] Ticket Title
  Project: PRDForge | Type: Bug/Feature/Task
  Assignee: @agent | Reporter: @agent
  Priority: High/Medium/Low
  Link: [View in Jira](jira-link)
  ```
- **Channels**: Relevant channel based on ticket component

#### 2. Status Changed
- **Trigger**: Ticket status updated (To Do → In Progress → Done)
- **Slack Message**:
  ```
  🔄 Status Update: [DEV-XXX] Ticket Title
  From: Previous Status → To: New Status
  Updated by: @agent
  Link: [View in Jira](jira-link)
  ```
- **Channels**: Relevant channel + `#prdforge-launch` for Done status

#### 3. Assignee Changed
- **Trigger**: Ticket assignee updated
- **Slack Message**:
  ```
  👤 Assignment: [DEV-XXX] Ticket Title
  Assigned to: @new-agent (from @previous-agent)
  Updated by: @agent
  Link: [View in Jira](jira-link)
  ```
- **Channels**: Relevant channel

#### 4. Comment Added
- **Trigger**: New comment on ticket
- **Slack Message**:
  ```
  💬 Comment: [DEV-XXX] Ticket Title
  By: @agent
  Preview: First 100 characters of comment...
  Link: [View in Jira](jira-link)
  ```
- **Channels**: Relevant channel (optional, can be disabled for high-volume)

#### 5. Approval Needed
- **Trigger**: Ticket marked "Ready for Approval"
- **Slack Message**:
  ```
  ⚠️ Approval Needed: [DEV-XXX] Ticket Title
  Requester: @agent
  Description: Brief summary of work completed
  Link: [View in Jira](jira-link)
  @temikolawole Please review and approve
  ```
- **Channels**: `#prdforge-launch` (with @temikolawole mention)

#### 6. Ticket Completed
- **Trigger**: Ticket moved to "Done" status
- **Slack Message**:
  ```
  ✅ Ticket Completed: [DEV-XXX] Ticket Title
  Completed by: @agent
  Time to completion: X days
  Link: [View in Jira](jira-link)
  🎉 Great work team!
  ```
- **Channels**: Relevant channel + `#prdforge-launch`

## Approval Workflow Integration

### Standard Approval Process:
1. **Agent completes work** → Updates Jira ticket
2. **Clawdia reviews** → Marks ticket "Ready for Approval"
3. **Slack notification** → Sent to `#prdforge-launch` with @temikolawole mention
4. **Temi reviews** → Approves in Jira (`temikolawole@gmail.com`)
5. **Confirmation notification** → Sent to `#prdforge-launch`

### Jira Configuration:
1. Create "Ready for Approval" status in workflow
2. Set up transition from "Review" to "Ready for Approval"
3. Configure webhook for status change to "Ready for Approval"
4. Set up automation for approval notification

### Slack Configuration:
1. Set up custom notification for "Ready for Approval" status
2. Configure @temikolawole mention in approval messages
3. Set up confirmation message template for approvals

## Advanced Configuration

### Custom Webhooks (if needed):
```bash
# Example webhook configuration
JIRA_WEBHOOK_URL="https://your-domain.atlassian.net/rest/webhooks/1.0/webhook"
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/..."

# Events to capture:
- issue.created
- issue.updated
- issue.deleted
- comment.created
- workflow.transition
```

### Filter Rules:
1. **Priority filtering**: Only High/Medium priority to `#prdforge-launch`
2. **Volume control**: Limit comments to relevant channels only
3. **Time filtering**: No notifications outside 8 AM - 6 PM WAT
4. **Agent filtering**: Don't notify assignee of their own updates

### Message Formatting:
- Use emojis for visual scanning
- Include essential metadata
- Provide direct Jira links
- Tag relevant agents
- Keep messages concise

## Testing Procedure

### Test Cases:
1. **Ticket creation**: Verify notification appears in correct channel
2. **Status change**: Verify update message format
3. **Assignee change**: Verify @mention works correctly
4. **Approval workflow**: Verify @temikolawole mention and message
5. **Completion notification**: Verify celebration message appears

### Test Data:
- Create test ticket DEV-999
- Simulate all status transitions
- Test with different agents
- Verify all notification types

## Monitoring and Maintenance

### Daily Checks:
- Verify notifications are being sent
- Check for failed webhooks
- Monitor integration health

### Weekly Tasks:
- Review notification volume
- Adjust filters if needed
- Update channel mappings if project structure changes

### Monthly Audit:
- Review all webhook configurations
- Check integration permissions
- Verify agent @mentions are working
- Test approval workflow end-to-end

## Troubleshooting

### Common Issues:

#### 1. Notifications not appearing
- **Check**: Integration connection status
- **Verify**: Channel permissions in Slack
- **Test**: Manual webhook trigger

#### 2. Incorrect channel mapping
- **Check**: Jira component → Slack channel mapping
- **Verify**: Project configuration in Jira
- **Update**: Channel mappings in integration settings

#### 3. @mentions not working
- **Check**: Agent Slack usernames match Jira display names
- **Verify**: Email mapping between systems
- **Test**: Manual @mention in Slack

#### 4. Approval workflow broken
- **Check**: "Ready for Approval" status exists
- **Verify**: Webhook for status transition
- **Test**: Manual status change trigger

### Escalation Path:
1. Check integration status pages (Jira + Slack)
2. Review webhook logs
3. Test with simplified configuration
4. Contact support if persistent issues

## Security Considerations

### Access Control:
- Limit integration to necessary permissions only
- Regular review of integration access
- Immediate revocation if security concern

### Data Protection:
- No sensitive data in notifications
- Use ticket numbers, not confidential details
- Secure webhook endpoints

### Compliance:
- Log all integration activities
- Maintain audit trail of notifications
- Regular compliance review of integration

## Performance Optimization

### Notification Volume:
- Implement intelligent filtering
- Batch non-urgent notifications
- Use threads for related updates

### Response Time:
- Monitor webhook response times
- Optimize message formatting
- Use async processing where possible

### Resource Usage:
- Monitor API rate limits
- Implement retry logic with exponential backoff
- Cache frequently accessed data

---

**Last Updated**: 2026-03-18  
**Version**: 1.0  
**Author**: Shuri (Operations Analysis Specialist)  
**Status**: Active  
**Jira Ticket**: DEV-26 (Slack Project Integration)