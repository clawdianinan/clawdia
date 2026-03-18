# Jira Agent Permissions Configuration

## Overview
This document defines the permission schemes for all agent accounts in Jira. Each agent has role-specific permissions aligned with their specialization and responsibilities.

## Permission Framework

### Permission Levels
1. **View Only:** Read access to issues, boards, and reports
2. **Commenter:** Add comments and attachments
3. **Contributor:** Create and edit issues, add comments
4. **Developer:** Transition issues, log work, resolve issues
5. **Reviewer:** Approve/reject issues, manage workflows
6. **Project Admin:** Manage project settings, permissions, workflows

## Agent Permission Assignments

### Development Team Permissions

#### Trinity (Development)
- **Role:** Developer
- **Permissions:**
  - Create issues
  - Edit issues (all fields)
  - Assign issues to self/others
  - Transition issues through workflow
  - Log work time
  - Resolve issues
  - Add attachments
  - Add comments
- **Restrictions:**
  - Cannot delete issues
  - Cannot modify project settings
  - Cannot manage permissions

#### Morpheus (QA)
- **Role:** Reviewer
- **Permissions:**
  - View all issues
  - Add comments
  - Add attachments
  - Transition issues (Test → Pass/Fail)
  - Approve/reject issues
  - Log work time
  - Create subtasks
- **Restrictions:**
  - Cannot create new projects
  - Cannot modify issue types
  - Cannot delete comments

#### Cypher (Security)
- **Role:** Reviewer (Security)
- **Permissions:**
  - View all issues (including security-sensitive)
  - Add security-related comments
  - Attach security reports
  - Transition issues (Security Review → Approved/Rejected)
  - Create security audit issues
  - Access security-specific custom fields
- **Restrictions:**
  - Limited to security-related projects
  - Cannot modify non-security fields
  - Audit trail required for all actions

### Design Team Permissions

#### Fela (Design)
- **Role:** Contributor (Design)
- **Permissions:**
  - Create design-related issues
  - Attach design files (PNG, SVG, PDF, FIG)
  - Add design feedback comments
  - Transition design issues (Design → Review → Approved)
  - Access design-specific custom fields
  - View linked development issues
- **Restrictions:**
  - Cannot modify code-related fields
  - Limited to design projects/boards
  - Design file size limits apply

#### Seun (Video)
- **Role:** Contributor (Video)
- **Permissions:**
  - Create video production issues
  - Attach video files and storyboards
  - Add video editing comments
  - Transition video issues (Planning → Production → Review)
  - Access video-specific custom fields
- **Restrictions:**
  - Video file type restrictions
  - Storage quota limitations
  - Limited to media projects

#### Femi (Brand)
- **Role:** Contributor (Brand)
- **Permissions:**
  - Create brand guideline issues
  - Attach brand assets
  - Add brand consistency comments
  - Transition brand issues (Review → Approved)
  - Access brand-specific custom fields
- **Restrictions:**
  - Brand asset approval required
  - Limited to brand/marketing projects
  - Cannot modify core product issues

### Documentation Team Permissions

#### Ebun (Documentation)
- **Role:** Contributor (Documentation)
- **Permissions:**
  - Create documentation issues
  - Attach documentation files
  - Add documentation comments
  - Transition documentation issues (Draft → Review → Published)
  - Access documentation-specific fields
  - Link to related feature issues
- **Restrictions:**
  - Documentation review required
  - Version control for documents
  - Limited to documentation projects

#### Ade (Intelligence)
- **Role:** Contributor (Research)
- **Permissions:**
  - Create research issues
  - Attach research reports
  - Add market analysis comments
  - Transition research issues (Research → Analysis → Published)
  - Access research-specific fields
  - Create competitive analysis issues
- **Restrictions:**
  - Research data sensitivity controls
  - External source attribution required
  - Limited to research projects

### Compliance Team Permissions

#### Ruth (GDPR/Compliance)
- **Role:** Reviewer (Compliance)
- **Permissions:**
  - View compliance-sensitive issues
  - Add compliance approval/rejection
  - Attach compliance documents
  - Transition compliance issues (Review → Compliant/Non-Compliant)
  - Create compliance audit issues
  - Access legal/compliance fields
- **Restrictions:**
  - Strict audit logging
  - Cannot modify non-compliance fields
  - Limited to compliance projects

#### Ngozi (Payments)
- **Role:** Reviewer (Financial)
- **Permissions:**
  - View financial-related issues
  - Add financial approval/rejection
  - Attach financial documents
  - Transition payment issues (Pending → Approved/Rejected)
  - Create financial audit issues
  - Access financial-specific fields
- **Restrictions:**
  - Dual approval required for large amounts
  - Financial audit trail mandatory
  - Limited to finance projects

### Operations Team Permissions

#### Shuri (Operations)
- **Role:** Project Admin (Operations)
- **Permissions:**
  - Create and manage operational issues
  - Configure workflow transitions
  - Manage operational boards
  - Add operational metrics
  - Create operational reports
  - Access all operational fields
  - Moderate comments
- **Restrictions:**
  - Cannot modify development workflows
  - Limited to operations projects
  - Change approval for major workflow modifications

#### Nova (Strategy)
- **Role:** Contributor (Strategy)
- **Permissions:**
  - Create strategic planning issues
  - Attach strategy documents
  - Add strategic analysis comments
  - Transition strategy issues (Planning → Review → Approved)
  - Access roadmap and planning fields
  - Create epic-level issues
- **Restrictions:**
  - Cannot modify tactical implementation
  - Limited to strategy/planning projects
  - Executive review required for major changes

#### Chimamanda (Communications)
- **Role:** Contributor (Communications)
- **Permissions:**
  - Create communication issues
  - Attach communication materials
  - Add communication feedback
  - Transition communication issues (Draft → Review → Published)
  - Access communication-specific fields
  - Create announcement issues
- **Restrictions:**
  - Cannot modify technical content
  - Limited to communications projects
  - Brand compliance review required

### Orchestration Permissions

#### Clawdia (Orchestrator)
- **Role:** Project Admin (All Projects)
- **Permissions:**
  - Full access to all projects
  - Create and manage all issue types
  - Configure workflows across projects
  - Manage cross-project dependencies
  - Final approval authority
  - System-wide coordination
  - Emergency override capabilities
- **Restrictions:**
  - Audit trail for all actions
  - Major changes require stakeholder notification
  - Compliance with security policies

## Permission Groups Configuration

### Group Structure
```
- jira-developers (Trinity, Morpheus, Cypher)
- jira-designers (Fela, Seun, Femi)
- jira-documentation (Ebun, Ade)
- jira-compliance (Ruth, Ngozi)
- jira-operations (Shuri, Nova, Chimamanda)
- jira-orchestration (Clawdia)
```

### Group Permissions
1. **jira-developers:**
   - Browse projects
   - Create issues
   - Edit issues
   - Transition issues
   - Resolve issues
   - Log work

2. **jira-designers:**
   - Browse projects
   - Create issues
   - Edit issues (design fields only)
   - Add attachments
   - Add comments

3. **jira-documentation:**
   - Browse projects
   - Create issues
   - Edit issues (documentation fields)
   - Add attachments
   - Add comments

4. **jira-compliance:**
   - Browse projects
   - Add comments
   - Transition issues (approval workflows)
   - Add attachments

5. **jira-operations:**
   - Browse projects
   - Create issues
   - Edit issues
   - Configure workflows
   - Manage boards

6. **jira-orchestration:**
   - All permissions
   - Project administration
   - Permission management

## Project-Specific Permissions

### Development Projects
- **Default Scheme:** Developer permissions
- **Special:** Security review required for production changes
- **Workflow:** Development → QA → Security → Production

### Design Projects
- **Default Scheme:** Contributor permissions
- **Special:** Brand compliance check
- **Workflow:** Design → Review → Brand Approval → Development

### Documentation Projects
- **Default Scheme:** Contributor permissions
- **Special:** Technical accuracy review
- **Workflow:** Draft → Technical Review → Editorial → Published

### Compliance Projects
- **Default Scheme:** Reviewer permissions
- **Special:** Legal review required
- **Workflow:** Submission → Compliance Review → Legal Approval → Implemented

### Operations Projects
- **Default Scheme:** Project Admin permissions
- **Special:** Cross-team coordination
- **Workflow:** Planning → Execution → Review → Closed

## Permission Validation

### Automated Checks
```yaml
permission_validation:
  frequency: daily
  checks:
    - account_active_status
    - group_membership
    - project_access
    - workflow_transitions
  alerts:
    - unauthorized_access_attempts
    - permission_drift
    - inactive_accounts_with_permissions
```

### Manual Audits
1. **Monthly:** Review all agent permissions
2. **Quarterly:** Validate against role changes
3. **Annually:** Comprehensive permission review

## Emergency Access Control

### Permission Revocation
In case of security incident:
1. Immediately revoke API tokens
2. Disable account access
3. Preserve audit logs
4. Notify security team

### Access Restoration
After investigation:
1. Review incident report
2. Update permissions as needed
3. Generate new credentials
4. Monitor for unusual activity

## Implementation Steps

### Phase 1: Group Setup
1. Create permission groups in Jira
2. Assign agents to appropriate groups
3. Test group permissions

### Phase 2: Project Configuration
1. Apply permission schemes to projects
2. Configure workflow permissions
3. Test agent access

### Phase 3: Validation
1. Verify each agent can perform required actions
2. Confirm restrictions are enforced
3. Document permission setup

### Phase 4: Monitoring
1. Set up permission change alerts
2. Configure audit logging
3. Establish review schedule

## Troubleshooting

### Common Permission Issues
1. **"Permission Denied":** Check group membership and project access
2. **Missing Transitions:** Verify workflow permissions
3. **Cannot Assign Issues:** Check assignee permissions
4. **Attachment Failures:** Review file type/size restrictions

### Resolution Steps
1. Check agent's group membership
2. Verify project permission scheme
3. Review workflow transitions
4. Check for conflicting permissions

---

**Last Updated:** 2026-03-18  
**Version:** 1.0  
**Owner:** Shuri (Operations Analysis)