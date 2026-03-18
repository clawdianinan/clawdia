# Jira Agent Accounts Configuration

## Overview
This document outlines the Jira user accounts for all active agents in the PRDForge system. Each agent has a dedicated Jira account with virtual email addresses following the format `agent-name@prdforge.ai`.

## Agent User Accounts

### Development Team
| Agent | Jira Username | Email Address | Display Name | Role |
|-------|---------------|---------------|--------------|------|
| Trinity | `trinity-dev` | `trinity@prdforge.ai` | Trinity (Development) | Developer |
| Morpheus | `morpheus-qa` | `morpheus@prdforge.ai` | Morpheus (QA) | Quality Assurance |
| Cypher | `cypher-security` | `cypher@prdforge.ai` | Cypher (Security) | Security Engineer |

### Design Team
| Agent | Jira Username | Email Address | Display Name | Role |
|-------|---------------|---------------|--------------|------|
| Fela | `fela-design` | `fela@prdforge.ai` | Fela (Design) | UI/UX Designer |
| Seun | `seun-video` | `seun@prdforge.ai` | Seun (Video) | Video/Motion Designer |
| Femi | `femi-brand` | `femi@prdforge.ai` | Femi (Brand) | Brand Designer |

### Documentation Team
| Agent | Jira Username | Email Address | Display Name | Role |
|-------|---------------|---------------|--------------|------|
| Ebun | `ebun-docs` | `ebun@prdforge.ai` | Ebun (Documentation) | Technical Writer |
| Ade | `ade-intel` | `ade@prdforge.ai` | Ade (Intelligence) | Market Researcher |

### Compliance Team
| Agent | Jira Username | Email Address | Display Name | Role |
|-------|---------------|---------------|--------------|------|
| Ruth | `ruth-gdpr` | `ruth@prdforge.ai` | Ruth (Compliance) | Legal/Compliance |
| Ngozi | `ngozi-payments` | `ngozi@prdforge.ai` | Ngozi (Payments) | Financial Compliance |

### Operations Team
| Agent | Jira Username | Email Address | Display Name | Role |
|-------|---------------|---------------|--------------|------|
| Shuri | `shuri-ops` | `shuri@prdforge.ai` | Shuri (Operations) | Operations Analyst |
| Nova | `nova-strategy` | `nova@prdforge.ai` | Nova (Strategy) | Strategic Planner |
| Chimamanda | `chimamanda-comms` | `chimamanda@prdforge.ai` | Chimamanda (Comms) | Communications |

### Orchestration
| Agent | Jira Username | Email Address | Display Name | Role |
|-------|---------------|---------------|--------------|------|
| Clawdia | `clawdia-orchestrator` | `clawdia@prdforge.ai` | Clawdia (Orchestrator) | System Orchestrator |

## Account Creation Instructions

### 1. Manual Creation (Jira Admin Console)
1. Log in to Jira as administrator
2. Navigate to **User Management**
3. Click **Create User** for each agent
4. Use the following settings:
   - **Email:** `agent-name@prdforge.ai`
   - **Username:** As specified in table
   - **Full Name:** Display Name from table
   - **Password:** Generate secure password (store in password manager)
   - **Send Notification Email:** Disabled (virtual accounts)

### 2. Bulk Import (CSV)
Create a CSV file with the following columns:
```
username,email_address,display_name,password,active
trinity-dev,trinity@prdforge.ai,Trinity (Development),[password],true
morpheus-qa,morpheus@prdforge.ai,Morpheus (QA),[password],true
...
```

### 3. API Automation
```bash
# Example using Jira REST API
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Basic $(echo -n admin:password | base64)" \
  -d '{
    "name": "trinity-dev",
    "password": "secure-password-123",
    "emailAddress": "trinity@prdforge.ai",
    "displayName": "Trinity (Development)",
    "notification": false
  }' \
  https://your-jira-instance/rest/api/2/user
```

## Avatar Configuration

### Default Avatars
Each agent should have a distinctive avatar:
- **Development Team:** Code/terminal themed avatars
- **Design Team:** Design/creative themed avatars  
- **Documentation Team:** Book/document themed avatars
- **Compliance Team:** Shield/lock themed avatars
- **Operations Team:** Gear/analytics themed avatars
- **Orchestration:** Panther/coordination themed avatar

### Avatar Upload
1. Prepare 48x48 pixel PNG images for each agent
2. Use Jira Admin → User Management → Edit User → Upload Avatar
3. Or use REST API: `/rest/api/2/user/avatar`

## Account Status Monitoring

### Active Status
All agent accounts should be marked as **Active** with:
- ✅ Email verified (skip for virtual accounts)
- ✅ Account enabled
- ✅ Password set (never expires)
- ✅ Multi-factor authentication disabled (for automation)

### Access Logs
Monitor login attempts and API usage:
- **Expected:** API-based access only
- **Alert:** Manual login attempts (should not occur)
- **Review:** Monthly access audit

## Security Considerations

### Password Management
- Store passwords in secure password manager (1Password/Bitwarden)
- Never hardcode passwords in scripts
- Rotate passwords quarterly
- Use API tokens for automation where possible

### API Token Configuration
For each agent account:
1. Generate personal access token
2. Scope: Read/Write permissions as needed
3. Store securely in environment variables
4. Rotate tokens every 90 days

### Access Control
- Limit agent accounts to specific projects/boards
- No administrative privileges
- Regular permission audits (monthly)

## Maintenance Schedule

### Weekly
- Check account status (active/inactive)
- Review failed login attempts
- Verify API token validity

### Monthly
- Audit permission assignments
- Review access logs
- Update avatars if needed

### Quarterly
- Password rotation
- API token regeneration
- Permission review and cleanup

## Troubleshooting

### Common Issues
1. **Account locked:** Reset password via admin console
2. **API token expired:** Generate new token
3. **Permission denied:** Check project/board access
4. **Email bounce:** Virtual email - ignore for agent accounts

### Support Contacts
- **Jira Admin:** System Administrator
- **Automation Support:** Shuri (Operations)
- **Security Review:** Cypher (Security)

---

**Last Updated:** 2026-03-18  
**Version:** 1.0  
**Owner:** Shuri (Operations Analysis)