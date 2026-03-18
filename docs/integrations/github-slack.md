# GitHub ↔ Slack Integration Guide

## Overview
This document outlines the integration between GitHub repositories and Slack for the PRDForge project, enabling real-time notifications for pull requests, builds, tests, and deployments.

## Integration Architecture

### Components:
1. **GitHub Organization/Repository**: PRDForge codebase
2. **Slack Workspace**: IIH project workspace
3. **Integration Method**: GitHub app for Slack
4. **Notification Channels**: Project-specific Slack channels

## Setup Process

### Step 1: Install GitHub App for Slack
1. In Slack, go to **Apps** → **Browse Apps**
2. Search for "GitHub"
3. Click **Add to Slack**
4. Authorize the integration
5. Select workspace for installation

### Step 2: Connect GitHub Account
1. In Slack, type `/github signin`
2. Follow authentication flow to GitHub
3. Authorize Slack app access to:
   - Read repository contents
   - Read pull requests
   - Read workflow runs
   - Manage webhooks

### Step 3: Configure Repository Subscriptions
1. Subscribe to PRDForge repositories:
   ```bash
   /github subscribe owner/repo
   ```
2. Configure notification channels for each repository

## Notification Configuration

### Channel Mapping Table

| GitHub Activity | Slack Channel | Notification Type |
|-----------------|---------------|-------------------|
| Pull Requests | `#development` | PR opened, reviewed, merged |
| Build Status | `#development` | CI/CD pipeline results |
| Test Results | `#testing` | Test pass/fail notifications |
| Deployments | `#prdforge-launch` | Production deployments |
| Issues | `#development` | Bug reports, feature requests |
| Releases | `#prdforge-launch` | Version releases |
| Security Alerts | `#security` | Vulnerability notifications |

### Notification Types

#### 1. Pull Request Opened
- **Trigger**: New PR created
- **Slack Message**:
  ```
  🔀 PR Opened: [#XXX] PR Title
  Repository: owner/repo
  Author: @agent | Branch: feature/branch-name
  Link: [View PR](github-link)
  ```
- **Channels**: `#development`

#### 2. Pull Request Review Requested
- **Trigger**: Review requested on PR
- **Slack Message**:
  ```
  👀 Review Requested: [#XXX] PR Title
  Requested from: @reviewer
  Changes: X files changed, +Y -Z
  Link: [View PR](github-link)
  ```
- **Channels**: `#development` (with @mention for reviewer)

#### 3. Pull Request Merged
- **Trigger**: PR merged to main branch
- **Slack Message**:
  ```
  ✅ PR Merged: [#XXX] PR Title
  Merged by: @agent | Into: main
  Changes: X files changed, +Y -Z
  Changelog: [View changes](github-link)
  ```
- **Channels**: `#development` + `#prdforge-launch` for significant changes

#### 4. Build Status Updates
- **Trigger**: CI/CD pipeline status change
- **Slack Message**:
  ```
  🏗️ Build Status: [#XXX] PR Title
  Status: ✅ Success / ❌ Failed / ⚠️ Pending
  Pipeline: GitHub Actions / CircleCI
  Duration: X minutes
  Link: [View details](github-link)
  ```
- **Channels**: `#development`

#### 5. Test Results
- **Trigger**: Test suite completion
- **Slack Message**:
  ```
  🧪 Test Results: [#XXX] PR Title
  Status: ✅ All tests passed / ❌ Tests failed
  Coverage: X% (ΔY%)
  Failures: Z test failures (if any)
  Link: [View details](github-link)
  ```
- **Channels**: `#testing`

#### 6. Deployment Notifications
- **Trigger**: Deployment to environment
- **Slack Message**:
  ```
  🚀 Deployment: vX.Y.Z to Environment
  Environment: Staging/Production
  Deployed by: @agent
  Changes: #XXX, #YYY, #ZZZ
  Link: [View deployment](github-link)
  ```
- **Channels**: `#prdforge-launch`

#### 7. Security Alerts
- **Trigger**: Security vulnerability detected
- **Slack Message**:
  ```
  🚨 Security Alert: Vulnerability in dependency
  Package: package-name@version
  Severity: Critical/High/Medium
  Advisory: [View advisory](github-link)
  Action Required: Update to version X.Y.Z
  ```
- **Channels**: `#security` (with @cypher mention)

## GitHub Actions Integration

### Workflow Configuration:
```yaml
# .github/workflows/notify-slack.yml
name: Notify Slack
on:
  push:
    branches: [main]
  pull_request:
    types: [opened, closed]

jobs:
  notify:
    runs-on: ubuntu-latest
    steps:
      - name: Notify Slack
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          fields: repo,message,commit,author,action,eventName,ref,workflow
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

### Secrets Configuration:
1. Create Slack webhook URL
2. Add to GitHub repository secrets:
   - `SLACK_WEBHOOK_URL`
   - `SLACK_CHANNEL`
   - `SLACK_USERNAME` (optional)

## Advanced Configuration

### Custom Webhooks:
```bash
# GitHub webhook configuration
WEBHOOK_URL="https://hooks.slack.com/services/..."
EVENTS=["push", "pull_request", "issues", "deployment"]

# Payload customization
- Include commit messages
- Include changed files
- Include test results
- Include deployment environment
```

### Filter Rules:
1. **Branch filtering**: Only notify for main/develop branches
2. **PR size filtering**: Only notify for PRs with >10 files changed
3. **Time filtering**: No notifications outside 8 AM - 6 PM WAT
4. **Author filtering**: Don't notify author of their own PRs

### Message Formatting:
- Use consistent emoji scheme
- Include essential metadata
- Provide direct GitHub links
- Tag relevant agents
- Keep messages actionable

## Testing Procedure

### Test Cases:
1. **PR creation**: Verify notification appears in `#development`
2. **Build status**: Verify CI/CD notifications work
3. **Test results**: Verify test notifications to `#testing`
4. **Deployment**: Verify deployment notifications to `#prdforge-launch`
5. **Security alerts**: Verify alerts to `#security` with @cypher

### Test Data:
- Create test PR #999
- Trigger test workflow
- Simulate test failures
- Test deployment workflow
- Trigger security scan

## Monitoring and Maintenance

### Daily Checks:
- Verify GitHub app connection
- Check for failed webhooks
- Monitor notification volume

### Weekly Tasks:
- Review notification effectiveness
- Adjust filters if needed
- Update repository subscriptions

### Monthly Audit:
- Review all webhook configurations
- Check integration permissions
- Verify @mentions are working
- Test security alert workflow

## Code Review Integration

### Review Workflow:
1. **PR opened** → Notification to `#development`
2. **Review requested** → @mention specific reviewers
3. **Review comments** → Thread in PR notification
4. **PR approved** → Status update in thread
5. **PR merged** → Final notification with changelog

### Automation:
- Auto-request reviews based on changed files
- Auto-assign based on CODEOWNERS
- Auto-merge when criteria met (tests pass, approvals)

## Deployment Pipeline Integration

### Stages:
1. **Build** → Notification to `#development`
2. **Test** → Results to `#testing`
3. **Staging deployment** → Notification to `#development`
4. **Production deployment** → Notification to `#prdforge-launch`

### Rollback Notifications:
- Automatic rollback triggers
- Immediate notification to `#prdforge-launch`
- @mention operations team

## Troubleshooting

### Common Issues:

#### 1. Notifications not appearing
- **Check**: GitHub app installation status
- **Verify**: Repository subscriptions
- **Test**: Manual webhook trigger

#### 2. Incorrect channel mapping
- **Check**: Repository → channel mapping
- **Verify**: GitHub app configuration
- **Update**: Channel subscriptions

#### 3. @mentions not working
- **Check**: GitHub username → Slack username mapping
- **Verify**: Email addresses match between systems
- **Test**: Manual @mention in Slack

#### 4. Webhook failures
- **Check**: Webhook delivery logs
- **Verify**: Payload format
- **Test**: Simple test payload

### Escalation Path:
1. Check GitHub status page
2. Check Slack status page
3. Review webhook delivery logs
4. Test with curl command
5. Contact support if persistent issues

## Security Considerations

### Access Control:
- Limit GitHub app to necessary permissions
- Regular review of app access
- Immediate revocation if security concern

### Data Protection:
- No secrets in notifications
- Use repository names, not internal details
- Secure webhook endpoints

### Compliance:
- Log all integration activities
- Maintain audit trail of deployments
- Regular security review of integration

## Performance Optimization

### Notification Volume:
- Implement intelligent filtering
- Batch related notifications
- Use threads for PR discussions

### Response Time:
- Monitor webhook response times
- Optimize payload size
- Use async processing

### Resource Usage:
- Monitor API rate limits
- Implement retry logic
- Cache repository data

## Changelog Generation

### Automated Changelogs:
- PR merge triggers changelog update
- Categorize by feature/bug/security
- Include in deployment notifications
- Post to `#prdforge-launch` on release

### Format:
```
## v1.2.3 (2026-03-18)

### 🚀 Features
- [#123] Add user authentication
- [#124] Implement payment processing

### 🐛 Bug Fixes
- [#125] Fix login redirect issue
- [#126] Resolve payment validation bug

### 🔒 Security
- [#127] Update vulnerable dependency
```

---

**Last Updated**: 2026-03-18  
**Version**: 1.0  
**Author**: Shuri (Operations Analysis Specialist)  
**Status**: Active  
**Jira Ticket**: DEV-26 (Slack Project Integration)