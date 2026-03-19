# Integration Guides

PRDForge integrates seamlessly with your existing workflow tools. This guide covers setup and configuration for all supported integrations.

## GitHub/GitLab Integration Setup

### GitHub Integration

#### Prerequisites
1. GitHub account with repository access
2. PRDForge Pro or Enterprise plan
3. GitHub Personal Access Token with appropriate permissions

#### Setup Steps

##### 1. Generate GitHub Personal Access Token
1. Go to GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Set token name: "PRDForge Integration"
4. Select scopes:
   - `repo` (Full control of private repositories)
   - `workflow` (Update GitHub Action workflows)
5. Click "Generate token"
6. **Copy the token immediately** (you won't see it again)

##### 2. Configure PRDForge Integration
1. In PRDForge, go to Settings → Integrations → GitHub
2. Click "Connect GitHub"
3. Enter your Personal Access Token
4. Select default repository
5. Configure sync options:
   - **Auto-sync PRDs**: Push PRD updates to repository
   - **Create issues**: Convert PRD requirements to GitHub issues
   - **Link commits**: Connect PRD sections to commit messages
   - **PR templates**: Generate pull request templates from PRDs

##### 3. Repository Structure
PRDForge creates this structure in your repository:
```
.github/
  └── prdforge/
      ├── prds/          # PRD markdown files
      ├── templates/     # PRD templates
      └── workflows/     # GitHub Actions workflows
docs/
  └── prds/             # Public PRD documentation
```

##### 4. GitHub Actions Workflow
PRDForge automatically creates a GitHub Actions workflow:
```yaml
name: PRDForge Sync
on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  sync-prds:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Sync PRDs from PRDForge
        uses: prdforge/github-action@v1
        with:
          api-key: ${{ secrets.PRDFORGE_API_KEY }}
          project-id: ${{ github.event.repository.id }}
          
      - name: Create PR from PRD updates
        uses: peter-evans/create-pull-request@v4
        with:
          commit-message: "docs: Update PRDs from PRDForge"
          title: "PRD Updates"
          body: "Automated PRD updates from PRDForge"
```

##### 5. Webhook Configuration
For real-time updates, set up a webhook:
1. Go to repository Settings → Webhooks
2. Add webhook URL: `https://api.prdforge.com/v1/webhooks/github`
3. Content type: `application/json`
4. Events: `push`, `pull_request`, `issues`

#### Usage Examples

##### Create PRD from Issue
```javascript
// GitHub Action to create PRD from new issue
name: Create PRD from Issue
on:
  issues:
    types: [opened]

jobs:
  create-prd:
    runs-on: ubuntu-latest
    steps:
      - name: Create PRD
        run: |
          curl -X POST https://api.prdforge.com/v1/projects \
            -H "Authorization: Bearer ${{ secrets.PRDFORGE_API_KEY }}" \
            -H "Content-Type: application/json" \
            -d '{
              "name": "${{ github.event.issue.title }}",
              "description": "${{ github.event.issue.body }}",
              "metadata": {
                "github_issue": "${{ github.event.issue.number }}",
                "github_repo": "${{ github.repository }}"
              }
            }'
```

##### Sync PRD to Wiki
```yaml
# Sync PRD to GitHub Wiki
- name: Update Wiki
  run: |
    git clone https://github.com/${{ github.repository }}.wiki.git
    cp prds/*.md wiki/
    cd wiki
    git add .
    git commit -m "Update PRDs"
    git push
```

### GitLab Integration

#### Prerequisites
1. GitLab account with project access
2. PRDForge Pro or Enterprise plan
3. GitLab Personal Access Token

#### Setup Steps

##### 1. Generate GitLab Access Token
1. Go to GitLab → Preferences → Access Tokens
2. Set token name: "PRDForge Integration"
3. Select scopes:
   - `api` (Full API access)
   - `read_repository`
   - `write_repository`
4. Click "Create personal access token"
5. Copy the token

##### 2. Configure PRDForge Integration
1. In PRDForge, go to Settings → Integrations → GitLab
2. Click "Connect GitLab"
3. Enter your GitLab instance URL (default: https://gitlab.com)
4. Enter your Personal Access Token
5. Select project
6. Configure sync options (similar to GitHub)

##### 3. GitLab CI/CD Pipeline
PRDForge can add a CI/CD pipeline:
```yaml
# .gitlab-ci.yml
stages:
  - sync
  - deploy

sync_prds:
  stage: sync
  script:
    - curl -X POST https://api.prdforge.com/v1/sync/gitlab \
        -H "Authorization: Bearer $PRDFORGE_API_KEY" \
        -H "Content-Type: application/json" \
        -d '{"project_id": "$CI_PROJECT_ID"}'
  only:
    - main

deploy_docs:
  stage: deploy
  script:
    - mkdir -p public/docs
    - cp prds/*.md public/docs/
    - echo "PRDs deployed"
  artifacts:
    paths:
      - public/docs
```

## Jira/Notion Connectivity

### Jira Integration

#### Prerequisites
1. Jira Cloud or Server instance
2. Admin access to create apps
3. PRDForge Pro or Enterprise plan

#### Setup Steps

##### 1. Create Jira API Token
1. Go to [id.atlassian.com/manage/api-tokens](https://id.atlassian.com/manage/api-tokens)
2. Click "Create API token"
3. Set label: "PRDForge Integration"
4. Copy the token

##### 2. Get Jira Site URL
- Cloud: `https://your-domain.atlassian.net`
- Server: `https://your-jira-server.com`

##### 3. Configure PRDForge Integration
1. In PRDForge, go to Settings → Integrations → Jira
2. Enter:
   - Jira Site URL
   - Email (Jira account email)
   - API Token
3. Test connection
4. Configure mapping:
   - PRD sections → Jira epics
   - Requirements → Jira stories
   - Tasks → Jira subtasks

##### 4. Field Mapping
Map PRDForge fields to Jira fields:
- **PRD Section** → Jira Epic
- **Requirement** → Jira Story
- **Acceptance Criteria** → Jira Description
- **Priority** → Jira Priority
- **Estimate** → Jira Story Points

##### 5. Automation Rules
Set up automation in PRDForge:
```json
{
  "rules": [
    {
      "trigger": "prd_section_completed",
      "action": "create_jira_epic",
      "mapping": {
        "title": "{section_title}",
        "description": "{section_content}",
        "labels": ["prd", "automated"]
      }
    },
    {
      "trigger": "requirement_defined",
      "action": "create_jira_story",
      "mapping": {
        "summary": "{requirement_title}",
        "description": "{acceptance_criteria}",
        "parent": "{epic_key}"
      }
    }
  ]
}
```

##### 6. Jira Webhook
For bidirectional sync, set up Jira webhook:
1. Jira Administration → System → Webhooks
2. Add webhook:
   - URL: `https://api.prdforge.com/v1/webhooks/jira`
   - Events: Issue created, updated, deleted
3. PRDForge will sync status changes back to PRDs

#### Usage Examples

##### Create Jira Issues from PRD
```javascript
// Create Jira issues from PRD requirements
const createJiraIssues = async (prdId) => {
  const prd = await prdforge.projects.get(prdId);
  
  for (const section of prd.content.sections) {
    if (section.type === 'requirements') {
      for (const req of section.content.requirements) {
        await jira.createIssue({
          fields: {
            project: { key: 'PRD' },
            summary: req.title,
            description: req.description,
            issuetype: { name: 'Story' },
            customfield_10001: req.estimate // Story points
          }
        });
      }
    }
  }
};
```

##### Sync Jira Status to PRD
```javascript
// Webhook handler for Jira updates
app.post('/webhooks/jira', async (req, res) => {
  const { webhookEvent, issue } = req.body;
  
  if (webhookEvent === 'jira:issue_updated') {
    await prdforge.projects.updateStatus({
      project_id: issue.fields.customfield_20000, // PRD ID custom field
      requirement_id: issue.key,
      status: issue.fields.status.name
    });
  }
  
  res.status(200).send('OK');
});
```

### Notion Integration

#### Prerequisites
1. Notion account with workspace access
2. Notion integration created
3. PRDForge Pro or Enterprise plan

#### Setup Steps

##### 1. Create Notion Integration
1. Go to [notion.so/my-integrations](https://www.notion.so/my-integrations)
2. Click "New integration"
3. Set name: "PRDForge Integration"
4. Select workspace
5. Copy the "Internal Integration Token"

##### 2. Share Database with Integration
1. Create or open a Notion database for PRDs
2. Click "Share" → "Invite"
3. Search for your integration name
4. Grant "Can edit" permissions

##### 3. Get Database ID
1. Open database in Notion
2. Copy the URL: `https://www.notion.so/workspace/{database_id}?v={view_id}`
3. Extract the database ID (32-character hex)

##### 4. Configure PRDForge Integration
1. In PRDForge, go to Settings → Integrations → Notion
2. Enter:
   - Integration Token
   - Database ID
3. Test connection
4. Configure field mapping

##### 5. Database Schema
PRDForge expects this database structure:
| Property | Type | Description |
|----------|------|-------------|
| Name | Title | PRD name |
| Status | Select | Draft, In Progress, Complete |
| Description | Text | PRD description |
| Sections | Number | Number of sections |
| Word Count | Number | Total words |
| Last Updated | Date | Last modification |
| PRDForge ID | Text | Internal PRD ID |
| Export URL | URL | Link to exported PRD |

##### 6. Two-way Sync Configuration
```json
{
  "sync_direction": "bidirectional",
  "sync_interval": "15m",
  "conflict_resolution": "prdforge_wins",
  "properties": {
    "name": "Name",
    "status": "Status",
    "description": "Description",
    "sections": "Sections",
    "word_count": "Word Count"
  }
}
```

#### Usage Examples

##### Create Notion Page from PRD
```javascript
// Create Notion page from PRD
const createNotionPage = async (prd) => {
  const response = await notion.pages.create({
    parent: { database_id: process.env.NOTION_DATABASE_ID },
    properties: {
      Name: {
        title: [
          {
            text: {
              content: prd.name
            }
          }
        ]
      },
      Status: {
        select: {
          name: prd.status
        }
      },
      Description: {
        rich_text: [
          {
            text: {
              content: prd.description
            }
          }
        ]
      },
      'PRDForge ID': {
        rich_text: [
          {
            text: {
              content: prd.id
            }
          }
        ]
      }
    },
    children: prd.content.sections.map(section => ({
      object: 'block',
      type: 'heading_2',
      heading_2: {
        rich_text: [{
          type: 'text',
          text: { content: section.title }
        }]
      }
    }))
  });
  
  return response;
};
```

##### Sync Notion Updates to PRDForge
```javascript
// Notion webhook handler
app.post('/webhooks/notion', async (req, res) => {
  const { type, data } = req.body;
  
  if (type === 'page.updated') {
    const page = await notion.pages.retrieve({ page_id: data.id });
    const prdId = page.properties['PRDForge ID'].rich_text[0].text.content;
    
    await prdforge.projects.update(prdId, {
      name: page.properties.Name.title[0].text.content,
      status: page.properties.Status.select.name
    });
  }
  
  res.status(200).send('OK');
});
```

## Custom Template Creation

### Template Structure
PRDForge templates use JSON format:
```json
{
  "name": "Business PRD Template",
  "description": "Template for business product requirements",
  "category": "business",
  "version": "1.0.0",
  "sections": [
    {
      "id": "executive_summary",
      "title": "Executive Summary",
      "type": "text",
      "required": true,
      "prompt": "Provide a high-level overview of the product...",
      "ai_enabled": true,
      "default_content": ""
    },
    {
      "id": "problem_statement",
      "title": "Problem Statement",
      "type": "text",
      "required": true,
      "prompt": "Describe the problem this product solves...",
      "ai_enabled": true,
      "fields": [
        {
          "name": "target_audience",
          "label": "Target Audience",
          "type": "text",
          "required": true
        },
        {
          "name": "pain_points",
          "label": "Key Pain Points",
          "type": "list",
          "required": true
        }
      ]
    }
  ],
  "metadata": {
    "estimated_time": "2 hours",
    "word_count_target": 2000,
    "sections_count": 8
  }
}
```

### Creating Custom Templates

#### 1. Using Template Builder
1. Go to Templates → Create New Template
2. Use visual builder to add sections
3. Configure section properties
4. Set AI prompts and defaults
5. Save as template

#### 2. Import JSON Template
```javascript
// Import template via API
const template = await prdforge.templates.create({
  name: "My Custom Template",
  description: "Template for internal use",
  category: "custom",
  sections: [...],
  metadata: {...}
});
```

#### 3. Template Variables
Use variables in prompts and content:
```json
{
  "prompt": "Create a product description for {product_name} targeting {target_audience}..."
}
```

Available variables:
- `{product_name}`
- `{company_name}`
- `{target_audience}`
- `{industry}`
- `{current_date}`

#### 4. Template Validation
```javascript
// Validate template structure
const validateTemplate = (template) => {
  const requiredFields = ['name', 'description', 'sections'];
  const errors = [];
  
  for (const field of requiredFields) {
    if (!template[field]) {
      errors.push(`Missing required field: ${field}`);
    }
  }
  
  if (template.sections && template.sections.length === 0) {
    errors.push('Template must have at least one section');
  }
  
  return errors;
};
```

### Sharing Templates

#### 1. Team Templates
```javascript
// Share template with team
await prdforge.templates.share({
  template_id: "temp_123456789",
  team_id: "team_987654321",
  permission: "edit" // or "view"
});
```

#### 2. Public Templates
```javascript
// Publish template to community
await prdforge.templates.publish({
  template_id: "temp_123456789",
  category: "business",
  tags: ["saas", "startup", "b2b"]
});
```

#### 3. Template Versioning
Templates support versioning:
```javascript
// Create new version
await prdforge.templates.createVersion({
  template_id: "temp_123456789",
  version: "2.0.0",
  changes: "Added new compliance section"
});

// Rollback to previous version
await prdforge.templates.rollback({
  template_id: "temp_123456789",
  version: "1.5.0"
});
```

## Team Workspace Configuration

### Creating Team Workspace

#### 1. Set Up Team
```javascript
// Create new team
const team = await prdforge.teams.create({
  name: "Acme Corp Product Team",
  description: "Product development team",
  plan: "enterprise",
  member_limit: 50
});
```

#### 2. Invite Members
```javascript
// Invite team members
await prdforge.teams.inviteMembers({
  team_id: team.id,
  members: [
    {
      email: "product@acme.com",
      role: "admin",
      permissions: ["create", "edit", "delete", "share"]
    },
    {
      email: "developer@acme.com",
      role: "editor",
      permissions: ["create", "edit"]
    },
    {
      email: "viewer@acme.com",
      role: "viewer",
      permissions: ["view"]
    }
  ]
});
```

#### 3. Configure Workspace Settings
```javascript
// Configure workspace
await prdforge.teams.configureWorkspace({
  team_id: team.id,
  settings: {
    default_template: "temp_business",
    approval_workflow: true,
    export_restrictions: {
      allowed_formats: ["pdf", "docx"],
      require_approval: true
    },
    credit_pool: {
      shared: true,
      monthly_allocation: 1000,
      member_limits: {
        admin: 500,
        editor: 200,
        viewer: 50
      }
    }
  }
});
```

### Team Collaboration Features

#### 1. Real-time Collaboration
```javascript
// Join collaborative editing session
const session = await prdforge.collaboration.join({
  project_id: "proj_123456789",
  user_id: "user_987654321",
  permissions: "edit"
});

// Receive real-time updates
session.on('update', (update) => {
  console.log('Collaborator update:', update);
});

// Send changes
session.sendUpdate({
  type: 'content_change',
  section: 'features',
  content: 'Updated feature list...'
});
```

#### 2. Comments and Feedback
```javascript
// Add comment to PRD
await prdforge.comments.create({
  project_id: "proj_123456789",
  section: "executive_summary",
  content: "This needs more market context",
  mentioned_users: ["user_123", "user_456"]
});

// Resolve comment
await prdforge.comments.resolve({
  comment_id: "comment_123456789",
  resolution: "Added market analysis section"
});
```

#### 3. Approval Workflows
```javascript
// Request approval
await prdforge.approvals.request({
  project_id: "proj_123456789",
  approvers: ["user_admin", "user_product_lead"],
  message: "Please review final PRD before development",
  deadline: "2026-03-25T18:00:00Z"
});

// Approve/Reject
await prdforge.approvals.respond({
  approval_id: "app_123456789",
  decision: "approved", // or "rejected"
  feedback: "Looks good, proceed to development"
});
```

### Advanced Team Features

#### 1. Custom Roles and Permissions
```javascript
// Create custom role
await prdforge.teams.createRole({
  team_id: team.id,
  name: "Technical Writer",
  permissions: {
    projects: ["create", "edit", "export"],
    templates: ["view"],
    team: ["view_members"],
    billing: ["view"]
  },
  restrictions: {
    max_projects: 10,
    export_formats: ["md", "pdf"],
    credit_limit: 100
  }
});
```

#### 2. Audit Logs
```javascript
// Get team audit logs
const logs = await prdforge.teams.getAuditLogs({
  team_id: team.id,
  start_date: "2026-03-01",
  end_date: "2026-03-18",
  actions: ["project.create", "project.export", "user.invite"]
});

// Export audit trail
const auditReport = await prdforge.teams.exportAuditTrail({
  team_id: team.id,
  format: "csv",
  include_user_details: true
});
```

#### 3. Single Sign-On (SSO)
```javascript
// Configure SAML SSO
await prdforge.teams.configureSSO({
  team_id: team.id,
  provider: "saml",
  config: {
    entry_point: "https://idp.acme.com/saml2",
    issuer: "prdforge",
    certificate: "-----BEGIN CERTIFICATE-----\n...",
    attributes: {
      email: "email",
      name: "displayName",
      groups: "department"
    }
  }
});

// Configure OAuth
await prdforge.teams.configureSSO({
  team_id: team.id,
  provider: "oauth",
  config: {
    client_id: "your-client-id",
    client_secret: "your-client-secret",
    authorization_url: "https://oauth.acme.com/authorize",
    token_url: "https://oauth.acme.com/token",
    userinfo_url: "https://oauth.acme.com/userinfo"
  }
});
```

## Integration Best Practices

### 1. Security Considerations
- **API Keys**: Store securely, rotate regularly
- **Webhooks**: Verify signatures, use HTTPS
- **Permissions**: Principle of least privilege
- **Audit**: Log all integration activities

### 2. Error Handling
```javascript
// Robust error handling for integrations
async function syncWithIntegration(prdId, integrationConfig) {
  try {
    const prd = await prdforge.projects.get(prdId);
    const result = await integration.sync(prd, integrationConfig);
    
    await prdforge.audit.log({
      action: "integration_sync",
      project_id: prdId,
      integration: integrationConfig.type,
      status: "success",
      details: result
    });
    
    return result;
  } catch (error) {
    await prdforge.audit.log({
      action: "integration_sync",
      project_id: prdId,
      integration: integrationConfig.type,
      status: "error",
      error: error.message
    });
    
    // Retry logic
    if (error.retryable) {
      await retryWithBackoff(() => syncWithIntegration(prdId, integrationConfig));
    }
    
    throw error;
  }
}
```

### 3. Performance Optimization
- **Batch operations**: Sync multiple items at once
- **Delta updates**: Only sync changed content
- **Async processing**: Use webhooks for long operations
- **Caching**: Cache integration responses when appropriate

### 4. Monitoring and Alerts
```javascript
// Monitor integration health
const monitorIntegration = async (integrationId) => {
  const health = await prdforge.integrations.checkHealth(integrationId);
  
  if (health.status !== 'healthy') {
    await prdforge.alerts.create({
      type: 'integration_health',
      severity: health.severity,
      message: `Integration ${integrationId} is ${health.status}`,
      details: health.details
    });
  }
  
  return health;
};

// Schedule regular health checks
setInterval(() => {
  monitorIntegration('github_integration');
  monitorIntegration('jira_integration');
}, 5 * 60 * 1000); // Every 5 minutes
```

## Troubleshooting Common Issues

### GitHub/GitLab Integration Issues
1. **Permission denied**: Check token scopes
2. **Webhook failures**: Verify endpoint URL and secret
3. **Sync conflicts**: Configure conflict resolution strategy
4. **Rate limiting**: Implement exponential backoff

### Jira/Notion Connectivity Problems
1. **Authentication failed**: Verify API tokens
2. **Field mapping errors**: Check field names and types
3. **Webhook delivery failures**: Test webhook endpoints
4. **Sync performance**: Optimize batch sizes

### Custom Template Issues
1. **Validation errors**: Check JSON schema
2. **AI generation failures**: Review prompt formatting
3. **Variable substitution**: Ensure variables are defined
4. **Version conflicts**: Clear template cache

### Team Workspace Problems
1. **Invitation failures**: Check email addresses
2. **Permission conflicts**: Review role definitions
3. **Credit allocation**: Verify pool settings
4. **SSO configuration**: Test authentication flow

## Getting Help

### Support Channels
- **Documentation**: [docs.prdforge.com/integrations](https://docs.prdforge.com/integrations)
- **Email**: integrations@prdforge.com
- **Community**: [GitHub Discussions](https://github.com/prdforge/discussions)
- **Live Chat**: Available in app for Pro/Enterprise plans

### Integration Status
- **Status Page**: [status.prdforge.com](https://status.prdforge.com)
- **Incident History**: Public incident reports
- **Scheduled Maintenance**: 24-hour notice for planned downtime

### API Reference
- **Full API Docs**: [api.prdforge.com](https://api.prdforge.com)
- **SDK Documentation**: Language-specific guides
- **Webhook Reference**: Event types and payloads

---

**Note**: Integrations are continuously improved. Check [docs.prdforge.com/integrations](https://docs.prdforge.com/integrations) for the latest updates and new integration offerings.

Last Updated: March 2026  
Integration Version: 3.2.0
