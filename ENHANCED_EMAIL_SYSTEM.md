# Enhanced Email Processing System

## Overview
Enhanced email processing system with IIH-specific intelligence, address book integration, and monthly report context awareness.

## Key Enhancements

### 1. IIH Email Segregation
- **Rule:** Keep IIH matters strictly with IIH emails (@iih.ng domain)
- **Implementation:** Automatic detection and routing of IIH-related emails
- **External IIH emails:** Prompt to use IIH email addresses for responses

### 2. IIH Address Book Integration
- **File:** `iih_address_book.json`
- **Staff Recognition:** Can identify staff by name without exact email addresses
- **Departments:** Programs, Finance, Administration, HR, Facility, IT/Marketing, MD Office
- **Name Resolution:** "Adebola" → adebola.oladipo@iih.ng, "Finance" → khadijat.bello@iih.ng, etc.

### 3. Monthly Report Context
- **Reference:** `MONTHLY_REPORT_PROCESS.md`
- **Automatic Detection:** Identifies monthly report-related emails
- **Action Recognition:** "send reminder", "check status", "compile report", etc.
- **Departmental Tracking:** Knows which departments submit which reports

### 4. Smart Email Classification

#### Category 1: Temi's Instructions (USER Emails)
- **Emails:** temi@iih.ng, temi.kolawole@iih.ng, temikolawole@icloud.com, temikolawole@gmail.com
- **Action:** Process instructions automatically
- **Sub-classification:**
  - IIH-related: Process with IIH context
  - Personal: Process as personal tasks
  - Monthly report: Specialized processing

#### Category 2: IIH Internal Emails
- **Domain:** @iih.ng
- **Action:** Route appropriately, handle departmental communications
- **Monthly reports:** Track submissions, send acknowledgments

#### Category 3: External IIH-related Emails
- **Detection:** Content analysis for IIH keywords
- **Action:** Handle with IIH email addresses only
- **Rule:** Never mix personal and IIH email identities

#### Category 4: External Non-IIH Emails
- **Action:** Refer to Temi for review
- **Rule:** Do not process automatically

## System Components

### 1. Enhanced Processor Script
- **File:** `enhanced_email_processor.sh`
- **Features:**
  - IIH address book loading and name resolution
  - Email content classification
  - Monthly report instruction processing
  - Smart routing logic

### 2. IIH Address Book
- **File:** `iih_address_book.json`
- **Contents:** Staff names, emails, departments, titles
- **Usage:** Resolve "Adebola" to adebola.oladipo@iih.ng

### 3. OpenClaw Cron Job
- **ID:** `d18a4267-9138-4d4f-8de4-0d6f013cac51`
- **Name:** Temi Email Processor
- **Schedule:** Every 10 minutes
- **Enhanced Logic:** Includes all IIH-specific rules

### 4. Supporting Scripts
- `process_temi_emails.sh` - Basic email processing
- `temi_email_processor.js` - Node.js agent
- `mail_notification_handler.sh` - Notification triggers

## How It Works

### Step 1: Email Retrieval
- Every 10 minutes, fetch recent emails via himalaya
- Maximum 20 emails per run to avoid overload

### Step 2: Classification
1. **Sender Analysis:**
   - Temi? → Process instructions
   - IIH staff? → Internal routing
   - External? → Content analysis

2. **Content Analysis:**
   - IIH keywords detection
   - Monthly report pattern matching
   - Department references

### Step 3: Processing
1. **Temi's Instructions:**
   - Extract actionable items
   - Apply IIH context if relevant
   - Execute or schedule tasks

2. **IIH Internal:**
   - Route to appropriate department/person
   - Track monthly report submissions
   - Maintain IIH email protocol

3. **External IIH:**
   - Flag for IIH email response
   - Do not use personal emails
   - Maintain professional boundaries

4. **External Non-IIH:**
   - Create review task for Temi
   - Do not process automatically

### Step 4: Notification & Logging
- Log all actions to `/tmp/enhanced_email_processor.log`
- Send summaries via OpenClaw webchat
- Maintain audit trail

## Monthly Report Special Handling

### Detection Patterns
- Keywords: "monthly report", "departmental report", "submission", "reminder"
- Department references: "Programs report", "Finance submission"
- Timeline references: "deadline", "3rd working day"

### Automated Actions
1. **Reminder Sending:** Based on monthly report timeline
2. **Status Tracking:** Monitor departmental submissions
3. **Compilation:** Trigger report assembly when all parts received
4. **Financial Processing:** Special handling for financial sections

### Integration with MONTHLY_REPORT_PROCESS.md
- Understands departmental responsibilities
- Knows submission deadlines and reminders
- Follows standardized email templates
- Maintains proper cc: temi@iih.ng

## Testing the System

### Test 1: Basic Classification
```bash
./enhanced_email_processor.sh
```

### Test 2: Address Book Resolution
```bash
# Test name resolution
grep -A5 "resolve_iih_staff" enhanced_email_processor.sh
```

### Test 3: Monthly Report Detection
```bash
# Create test email content
TEST_SUBJECT="Monthly Report Submission - Programs Department"
TEST_BODY="Please find attached the Programs report for February 2026."
# Test detection logic
```

### Test 4: Cron Job Test
```bash
openclaw cron run d18a4267-9138-4d4f-8de4-0d6f013cac51
```

## Monitoring

### Log Files
- `/tmp/enhanced_email_processor.log` - Main processing log
- `/tmp/clawdia_email_processor.log` - Legacy log
- `/tmp/mail_notification_handler.log` - Notification triggers

### OpenClaw Monitoring
```bash
# Check cron job status
openclaw cron list

# View recent runs
openclaw cron runs --id d18a4267-9138-4d4f-8de4-0d6f013cac51

# Check for errors
openclaw cron runs --id d18a4267-9138-4d4f-8de4-0d6f013cac51 --limit 5 | jq '.entries[] | select(.status == "error")'
```

## Maintenance

### Updating IIH Staff
1. Edit `iih_address_book.json`
2. Add new staff members with name, emails, department
3. Test name resolution: `./enhanced_email_processor.sh`

### Adding New Email Rules
1. Update classification logic in `enhanced_email_processor.sh`
2. Add new keyword patterns
3. Test with sample emails

### Modifying Monthly Report Process
1. Update `MONTHLY_REPORT_PROCESS.md`
2. Sync changes to email detection patterns
3. Test reminder templates and timing

## Troubleshooting

### Common Issues

1. **himalaya not found:**
   ```bash
   brew install himalaya
   ```

2. **jq not installed:**
   ```bash
   brew install jq
   ```

3. **Cron job errors:**
   ```bash
   # Check OpenClaw gateway
   openclaw gateway status
   
   # Check channel configuration
   openclaw channels list
   ```

4. **Email access issues:**
   - Verify himalaya configuration: `~/.config/himalaya/config.toml`
   - Check IMAP/SMTP credentials
   - Test manually: `himalaya envelope list`

### Debug Mode
```bash
# Enable verbose logging
export DEBUG=1
./enhanced_email_processor.sh

# Check specific function
bash -x enhanced_email_processor.sh 2>&1 | grep -A10 "process_email"
```

## Security Considerations

### Email Segregation
- Never mix personal and IIH email identities
- External IIH matters → Use IIH emails only
- Personal matters → Use appropriate personal email

### Data Privacy
- IIH staff information stored locally only
- Email content processed but not stored long-term
- Logs contain minimal identifying information

### Access Control
- Scripts run with user permissions only
- No elevated privileges required
- OpenClaw cron jobs run in isolated sessions

## Future Enhancements

### Planned Features
1. **Natural Language Processing:** Better instruction extraction
2. **Calendar Integration:** Schedule meetings from email instructions
3. **Task Creation:** Convert email instructions to todo items
4. **Template Responses:** Smart reply suggestions
5. **Attachment Processing:** Extract and act on attached documents

### Integration Points
1. **Todo System:** Convert email tasks to `todo.db` entries
2. **Calendar:** Schedule meetings from email content
3. **Document Management:** Process attached reports and documents
4. **Notification System:** Smart alerts based on email priority

## Conclusion

The enhanced email system now:
- ✅ Processes your emails automatically
- ✅ Keeps IIH matters with IIH emails
- ✅ Recognizes IIH staff by name
- ✅ Understands monthly report context
- ✅ Routes emails intelligently
- ✅ Maintains proper email segregation

Ready for your test email! The system will be on the lookout and process it according to the enhanced rules.