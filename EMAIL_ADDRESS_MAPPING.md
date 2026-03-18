# Email Address Mapping

## Clear Distinction Between USER and OpenClaw/Clawdia Emails

### USER Emails (Temi Kolawole)
These are YOUR personal and professional email addresses. Emails from these addresses should be processed automatically by Clawdia.

1. **temi@iih.ng** - Primary IIH professional email
2. **temi.kolawole@iih.ng** - Alternate IIH email  
3. **temikolawole@icloud.com** - Personal iCloud email
4. **temikolawole@gmail.com** - Personal Gmail email

**Purpose:** All emails from these addresses contain instructions for Clawdia to process automatically.

### OpenClaw/Clawdia Emails (Assistant Accounts)
These are Clawdia's email addresses for different purposes. Emails from these addresses should NOT be processed by the automatic email system.

1. **clawdianinan@icloud.com**
   - Primary communication channel
   - Direct/private correspondence
   - Personal scheduling and day-to-day interaction

2. **clawdianinan@gmail.com**
   - Account registrations and SaaS logins
   - Third-party integrations and automation auth
   - Public-compatibility workflows (especially Google-linked services)
   - Check when instructed: "I sent you an email"

3. **clawdia.ai@iih.ng**
   - Official IIH identity for internal IIH communication
   - Strictly for IIH-related matters
   - Primary check for IIH-related emails
   - Always check when matter relates to IIH

## Email Processing Rules

### Automatic Processing (USER Emails)
- ✅ Emails from `temi@iih.ng` - Process instructions automatically
- ✅ Emails from `temi.kolawole@iih.ng` - Process instructions automatically  
- ✅ Emails from `temikolawole@icloud.com` - Process instructions automatically
- ✅ Emails from `temikolawole@gmail.com` - Process instructions automatically

### Refer to Temi (Other Sources)
- ⚠️ Emails from ANY other source - Refer to Temi for next action
- ⚠️ Emails from Clawdia addresses - Should not trigger processing (system emails)

### Special Cases
- **IHS Towers emails** (`@ihstowers.com`) - Highest priority, always escalate immediately
- **External business emails** - Refer to Temi for review and response
- **IIH internal emails** - Process based on content and urgency

## System Configuration

### OpenClaw Cron Job
- **Job ID:** `d18a4267-9138-4d4f-8de4-0d6f013cac51`
- **Name:** Temi Email Processor
- **Schedule:** Every 10 minutes
- **Function:** Checks for emails from USER addresses, processes instructions, refers others

### Processing Scripts
- `process_temi_emails.sh` - Shell script with USER email list
- `temi_email_processor.js` - Node.js agent with USER email logic
- `mail_notification_handler.sh` - Trigger script for Mail app notifications

### Launchd Agent
- **Name:** `com.openclaw.mailwatcher`
- **Schedule:** Every 5 minutes
- **Function:** Periodic email check and notification handling

## Testing Email Processing

1. **Send test email** from one of your USER addresses with a simple instruction
2. **Check cron job status:**
   ```bash
   openclaw cron list
   openclaw cron runs --id d18a4267-9138-4d4f-8de4-0d6f013cac51
   ```
3. **Monitor logs:**
   ```bash
   tail -f /tmp/mail_notification_handler.log
   tail -f /tmp/com.openclaw.mailwatcher.log
   ```

## Updates Required

If you add new email addresses:

1. Update `USER.md` with new email address
2. Update `process_temi_emails.sh` TEMI_EMAILS array
3. Update `temi_email_processor.js` TEMI_EMAILS array  
4. Update `MailNotificationWatcher.scpt` temiEmails list
5. Update OpenClaw cron job message with new address

## Last Updated
2026-02-27 04:47 GMT+1