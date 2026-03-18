# Temi Email Processing Setup

## Overview
This system automatically processes emails from Temi Kolawole and refers other emails to him for review.

## Components

### 1. OpenClaw Cron Job
- **Name:** Temi Email Processor
- **Schedule:** Every 10 minutes
- **Function:** Checks for new emails, processes Temi's instructions, refers other emails
- **USER Email addresses monitored (Temi Kolawole):**
  - temi@iih.ng
  - temi.kolawole@iih.ng
  - temikolawole@icloud.com
  - temikolawole@gmail.com
- **Clawdia Email addresses (NOT monitored for processing):**
  - clawdianinan@icloud.com
  - clawdianinan@gmail.com
  - clawdia.ai@iih.ng

### 2. Mail Notification Handler
- **Script:** `mail_notification_handler.sh`
- **Function:** Triggers email processing when Mail app receives notifications
- **Logs:** `/tmp/mail_notification_handler.log`

### 3. Launchd Agent
- **Name:** com.openclaw.mailwatcher
- **Schedule:** Every 5 minutes
- **Function:** Runs the mail notification handler periodically

### 4. Processing Scripts
- `process_temi_emails.sh` - Main email processing logic
- `temi_email_processor.js` - Node.js agent for OpenClaw integration

## How It Works

1. **Regular Checks:** Every 10 minutes, OpenClaw checks for new emails
2. **Real-time Triggers:** Mail app notifications can trigger immediate processing
3. **Email Classification:**
   - **From Temi:** Instructions are processed automatically
   - **From Others:** Emails are referred to Temi for review
4. **Processing:** Instructions in Temi's emails are extracted and executed

## Testing

1. Test the cron job:
   ```bash
   openclaw cron run --id d18a4267-9138-4d4f-8de4-0d6f013cac51
   ```

2. Test the mail handler:
   ```bash
   ./mail_notification_handler.sh
   ```

3. Check logs:
   ```bash
   tail -f /tmp/mail_notification_handler.log
   ```

## Maintenance

- Update Temi's email addresses in `process_temi_emails.sh` if needed
- Monitor cron job status: `openclaw cron list`
- Check agent logs: `openclaw cron runs --id d18a4267-9138-4d4f-8de4-0d6f013cac51`

## Troubleshooting

1. **Cron job errors:** Check OpenClaw gateway is running
2. **Email access issues:** Verify himalaya configuration or Mail app permissions
3. **Notification issues:** Check launchd agent status: `launchctl list | grep openclaw`
