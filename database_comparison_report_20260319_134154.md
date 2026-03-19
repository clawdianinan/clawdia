# PRDForge Database Migration Verification Report
Generated: Thu Mar 19 13:41:54 WAT 2026

## Phase 1: Database Connection Test

Testing OLD database connection...
✅ OLD database connection successful
Testing NEW database connection...
✅ NEW database connection successful

## Phase 2: Table Structure Comparison

### Tables in OLD database:
```
 accounts
 activity_log
 applications
 authorities
 authority_staff
 computation_audit_logs
 email_logs
 email_templates
 helper_lists
 iih_about_static_content
 iih_activity_logs
 iih_admin_users
 iih_contact_info
 iih_contact_settings
 iih_core_values
 iih_data_requests
 iih_events
 iih_facilities
 iih_facility_gallery
 iih_gallery_images
 iih_impact_stories
 iih_inquiries
 iih_partner_types
 iih_partners
 iih_password_resets
 iih_privacy_policies
 iih_program_gallery
 iih_program_types
 iih_programs
 iih_team_members
 iih_timeline_events
 iih_user_consents
 jobs
 jurisdictions
 notifications
 orbit_activity_feed
 orbit_admin_settings
 orbit_audit_logs
 orbit_backups
 orbit_badges
 orbit_blocked_ips
 orbit_comments
 orbit_email_queue
 orbit_friendships
 orbit_levels
 orbit_messages
 orbit_notifications
 orbit_oauth_exchange_codes
 orbit_oauth_state_tokens
 orbit_points_ledger
 orbit_post_likes
 orbit_post_replies
 orbit_posts
 orbit_rate_limits
 orbit_reactions
 orbit_stream_chat
 orbit_stream_memberships
 orbit_stream_moderators
 orbit_streams
 orbit_submissions
 orbit_tasks
 orbit_user_badges
 orbit_user_notification_preferences
 orbit_users
 orbit_weekly_leaderboard
 org_app_enablements
 org_invitations
 org_memberships
 organizations
 otp_challenges
 permissions
 prdforge_activity_logs
 prdforge_admin_config
 prdforge_ai_models
 prdforge_api_keys
 prdforge_architecture_diagrams
 prdforge_billing_history
 prdforge_chat_history
 prdforge_credit_topups
 prdforge_docs
 prdforge_export_unlocks
 prdforge_feature_nodes
 prdforge_guardrails
 prdforge_idea_intake
 prdforge_modules
 prdforge_prd_sections
 prdforge_profiles
 prdforge_projects
 prdforge_section_comments
 prdforge_subscriptions
 prdforge_tasks
 prdforge_templates
 prdforge_usage
 prdforge_user_api_keys
 prdforge_user_roles
 prdforge_versions
 role_permissions
 roles
 sessions
 settings
 settings_backup
 tax_authority_rules
 user_roles
 users
 verifications
```

### Tables in NEW database:
```
 failed_login_attempts
 ip_lockouts
 prdforge_activity_logs
 prdforge_admin_config
 prdforge_ai_models
 prdforge_api_keys
 prdforge_architecture_diagrams
 prdforge_audit_logs
 prdforge_billing_history
 prdforge_blocked_ips
 prdforge_chat_history
 prdforge_credit_topups
 prdforge_data_retention_policies
 prdforge_docs
 prdforge_export_unlocks
 prdforge_feature_nodes
 prdforge_guardrails
 prdforge_idea_intake
 prdforge_mfa_config
 prdforge_modules
 prdforge_prd_sections
 prdforge_profiles
 prdforge_project_docs
 prdforge_projects
 prdforge_rate_limits
 prdforge_rate_limits_legacy
 prdforge_section_comments
 prdforge_security_audit_logs
 prdforge_security_events
 prdforge_subscriptions
 prdforge_tasks
 prdforge_templates
 prdforge_usage
 prdforge_user_api_keys
 prdforge_user_roles
 prdforge_versions
```

### Table Comparison Results:
❌ Tables missing in NEW database:
```
 accounts
 activity_log
 applications
 authorities
 authority_staff
 computation_audit_logs
 email_logs
 email_templates
 helper_lists
 iih_about_static_content
 iih_activity_logs
 iih_admin_users
 iih_contact_info
 iih_contact_settings
 iih_core_values
 iih_data_requests
 iih_events
 iih_facilities
 iih_facility_gallery
 iih_gallery_images
 iih_impact_stories
 iih_inquiries
 iih_partner_types
 iih_partners
 iih_password_resets
 iih_privacy_policies
 iih_program_gallery
 iih_program_types
 iih_programs
 iih_team_members
 iih_timeline_events
 iih_user_consents
 jobs
 jurisdictions
 notifications
 orbit_activity_feed
 orbit_admin_settings
 orbit_audit_logs
 orbit_backups
 orbit_badges
 orbit_blocked_ips
 orbit_comments
 orbit_email_queue
 orbit_friendships
 orbit_levels
 orbit_messages
 orbit_notifications
 orbit_oauth_exchange_codes
 orbit_oauth_state_tokens
 orbit_points_ledger
 orbit_post_likes
 orbit_post_replies
 orbit_posts
 orbit_rate_limits
 orbit_reactions
 orbit_stream_chat
 orbit_stream_memberships
 orbit_stream_moderators
 orbit_streams
 orbit_submissions
 orbit_tasks
 orbit_user_badges
 orbit_user_notification_preferences
 orbit_users
 orbit_weekly_leaderboard
 org_app_enablements
 org_invitations
 org_memberships
 organizations
 otp_challenges
 permissions
 role_permissions
 roles
 sessions
 settings
 settings_backup
 tax_authority_rules
 user_roles
 users
 verifications
```
⚠️  Extra tables in NEW database (not in OLD):
```
 failed_login_attempts
 ip_lockouts
 prdforge_audit_logs
 prdforge_blocked_ips
 prdforge_data_retention_policies
 prdforge_mfa_config
 prdforge_project_docs
 prdforge_rate_limits
 prdforge_rate_limits_legacy
 prdforge_security_audit_logs
 prdforge_security_events
```

## Phase 3: User Data Verification

### auth.users table comparison:
OLD database users: 10
NEW database users: 7
❌ User count mismatch!
Difference: 3

### User email list comparison:
OLD user emails:  drsamhappiness@gmail.com, jobs@iih.ng, kolapoimam1@gmail.com, okeymaureen1996@gmail.com, sinachi@iih.ng, temikolawole@gmail.com, temikolawole@outlook.com, testbykay@gmail.com, test@iih.ng, test.prdforge.2026@mailinator.com,
NEW user emails:  drsamhappiness@gmail.com, kolapoimam1@gmail.com, okeymaureen1996@gmail.com, temikolawole@gmail.com, temikolawole@outlook.com, test.prdforge.2026@mailinator.com, testbykay@gmail.com,

## Phase 4: PRDForge Tables Data Counts

### Table: prdforge_activity_logs
OLD count: 4173
NEW count: 4173
✅ Count matches

### Table: prdforge_admin_config
OLD count: 12
NEW count: 12
✅ Count matches

### Table: prdforge_ai_models
OLD count: 18
NEW count: 18
✅ Count matches

### Table: prdforge_api_keys
OLD count: 0
NEW count: 0
✅ Count matches

### Table: prdforge_architecture_diagrams
OLD count: 24
NEW count: 24
✅ Count matches

### Table: prdforge_billing_history
OLD count: 0
NEW count: 0
✅ Count matches

### Table: prdforge_chat_history
OLD count: 10
NEW count: 10
✅ Count matches

### Table: prdforge_credit_topups
OLD count: 0
NEW count: 0
✅ Count matches

### Table: prdforge_docs
OLD count: 4
NEW count: 4
✅ Count matches

### Table: prdforge_export_unlocks
OLD count: 0
NEW count: 0
✅ Count matches

### Table: prdforge_feature_nodes
OLD count: 82
NEW count: 82
✅ Count matches

### Table: prdforge_guardrails
OLD count: 80
NEW count: 80
✅ Count matches

### Table: prdforge_idea_intake
OLD count: 8
NEW count: 8
✅ Count matches

### Table: prdforge_modules
OLD count: 62
NEW count: 62
✅ Count matches

### Table: prdforge_prd_sections
OLD count: 155
NEW count: 155
✅ Count matches

### Table: prdforge_profiles
OLD count: 7
NEW count: 7
✅ Count matches

### Table: prdforge_projects
OLD count: 8
NEW count: 8
✅ Count matches

### Table: prdforge_section_comments
OLD count: 0
NEW count: 0
✅ Count matches

### Table: prdforge_subscriptions
OLD count: 1
NEW count: 1
✅ Count matches

### Table: prdforge_tasks
OLD count: 314
NEW count: 314
✅ Count matches

### Table: prdforge_templates
