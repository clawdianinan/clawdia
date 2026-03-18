---
name: mail-attachments
description: Access and manage email attachments from both CLI (fruitmail) and Apple Mail.app. Use when you need to: (1) Download email attachments via command line, (2) Save attachments from specific emails to local files, (3) List attachments in emails, (4) Access Mail.app attachments directly via AppleScript, (5) Process attachments in automated workflows. Works with both fruitmail CLI for searching and AppleScript for direct Mail.app access.
---

# Mail Attachments Skill

Comprehensive email attachment management for macOS Mail.app with both CLI and AppleScript access.

## Purpose

Bridge the gap between fruitmail CLI (which can search but not access attachments) and Apple Mail.app (which has full attachment access but needs AppleScript). Provides unified access to download, list, and manage email attachments.

## Installation Requirements

```bash
# 1. Install fruitmail CLI (for searching)
npm install -g apple-mail-search-cli

# 2. Ensure Apple Mail.app is installed and configured
# 3. Grant Terminal/Automation access to Mail.app
#    System Preferences → Security & Privacy → Privacy → Automation
#    Check "Mail" for Terminal/your terminal app
```

## Core Capabilities

### 1. **Attachment Discovery** (fruitmail CLI)
- Search emails with attachments
- Filter by attachment type (PDF, DOCX, etc.)
- Get email metadata with attachment info

### 2. **Attachment Access** (AppleScript)
- Download attachments to local files
- List all attachments in an email
- Get attachment metadata (name, size, type)
- Open attachments directly

### 3. **Unified Workflow**
- Search → Identify → Download → Process
- Batch processing of multiple attachments
- Integration with other skills (document processing, etc.)

## Usage Examples

### Basic Attachment Search
```bash
# Find emails with attachments
mail-attachments search --has-attachment --days 30

# Find PDF attachments from specific sender
mail-attachments search --sender "@ihstowers.com" --attachment-type pdf

# List all attachments in recent unread emails
mail-attachments list-attachments --unread --days 7
```

### Download Attachments
```bash
# Download all attachments from specific email ID
mail-attachments download --email-id 12345 --output ~/Downloads/

# Download only PDF attachments
mail-attachments download --email-id 12345 --type pdf --output ~/Documents/

# Download attachments from multiple emails
mail-attachments batch-download --ids 12345,67890,11223 --output ~/Attachments/
```

### Apple Mail.app Direct Access
```bash
# Open email in Mail.app (for manual inspection)
mail-attachments open --email-id 12345

# Get attachment info without downloading
mail-attachments info --email-id 12345

# Save attachment with original filename
mail-attachments save --email-id 12345 --attachment "Report.pdf" --output ~/Documents/
```

## Integration with Email Processing

### 1. **Email Auto-Processor Enhancement**
```bash
# In your cron job script:
# 1. Search for emails with instructions
# 2. Download attachments
# 3. Process attachments
# 4. Create responses

fruitmail search --subject "Report" --has-attachment --days 1 --json | \
  jq -r '.[].id' | \
  xargs -I {} mail-attachments download --email-id {} --output ./attachments/
```

### 2. **Attachment-Based Workflows**
```bash
# Process all PDF attachments from today
mail-attachments search --has-attachment --attachment-type pdf --days 1 --json | \
  jq -r '.[] | "\(.id) \(.subject)"' | \
  while read id subject; do
    mail-attachments download --email-id $id --output ./pdfs/
    # Process PDF with other skills
    pdf-processor "./pdfs/*.pdf"
  done
```

## AppleScript Implementation

The skill uses AppleScript to interact directly with Mail.app:

```applescript
tell application "Mail"
  set theMessage to message id 12345
  set theAttachments to every attachment of theMessage
  repeat with anAttachment in theAttachments
    set attachmentPath to (POSIX path of (path to downloads folder)) & (name of anAttachment)
    save anAttachment in file attachmentPath
  end repeat
end tell
```

## Python Wrapper

For more complex workflows, a Python wrapper is provided:

```python
from mail_attachments import MailAttachments

ma = MailAttachments()

# Search for emails
emails = ma.search(subject="Report", has_attachment=True, days=30)

# Download attachments
for email in emails:
    attachments = ma.get_attachments(email['id'])
    for attachment in attachments:
        ma.download_attachment(email['id'], attachment['name'], '/path/to/save')
```

## Configuration

### Security Settings
```bash
# Grant automation access (required)
sudo tccutil reset AppleEvents
# Then manually grant access in System Preferences
```

### Default Paths
```yaml
downloads:
  default_path: ~/Downloads/email_attachments/
  organize_by: date  # date, sender, type
  preserve_structure: true
  
search:
  default_days: 30
  max_results: 50
  include_body: false
  
apple_mail:
  timeout: 30  # seconds
  retry_attempts: 3
```

## Common Use Cases

### 1. **Document Processing Pipeline**
```bash
# Find document attachments → Download → Process → Archive
mail-attachments pipeline \
  --sender "@company.com" \
  --type pdf,docx \
  --processor "document-converter" \
  --archive-path ~/Documents/Processed/
```

### 2. **Automated Report Handling**
```bash
# Daily report processing
mail-attachments cron \
  --schedule "0 9 * * *" \
  --search "--subject 'Daily Report' --has-attachment" \
  --action "download --output /reports/ && process-reports"
```

### 3. **Attachment Backup**
```bash
# Backup all attachments from important senders
mail-attachments backup \
  --senders "@ihstowers.com,@iih.ng" \
  --output ~/Backups/EmailAttachments/ \
  --compress
```

## Troubleshooting

### Common Issues

1. **"Mail got an error: Application isn't running"**
   ```bash
   # Ensure Mail.app is running
   open -a Mail
   # Grant automation permissions
   ```

2. **No attachments found**
   ```bash
   # Check if email actually has attachments
   mail-attachments info --email-id 12345
   # Verify fruitmail can see attachments
   fruitmail search --has-attachment --json | jq '.[0]'
   ```

3. **Permission denied**
   ```bash
   # Reset privacy permissions
   tccutil reset AppleEvents com.apple.Terminal
   # Re-grant in System Preferences
   ```

### Debug Mode
```bash
# Enable verbose logging
mail-attachments --debug download --email-id 12345

# Test AppleScript connection
mail-attachments test-connection

# Check fruitmail installation
mail-attachments check-dependencies
```

## Integration with Existing Skills

### With `apple-mail-search` (fruitmail)
- Use fruitmail for fast searching
- Use this skill for attachment access
- Combined workflow: search → identify → download

### With `himalaya` (IMAP/SMTP)
- Himalaya for sending/composing
- This skill for receiving/attachments
- Complete email workflow

### With `document-processing` skills
- Download attachments → Process → Archive
- Chain multiple skills together

## Performance Notes

- **fruitmail**: Fast SQLite search (~50ms for 130k emails)
- **AppleScript**: Slower but full access (2-5 seconds per operation)
- **Recommendation**: Use fruitmail for searching, AppleScript only for needed attachments

## Safety & Privacy

- **Read-only**: Cannot send emails or modify Mail.app
- **Local only**: Works with local Mail.app database
- **User confirmation**: Optional prompts for large downloads
- **Logging**: All operations logged for audit

## Advanced Features

### 1. **Smart Filtering**
```bash
# Download only new attachments (not previously downloaded)
mail-attachments download --email-id 12345 --skip-existing

# Filter by size
mail-attachments search --has-attachment --min-size 1MB --max-size 10MB
```

### 2. **Batch Operations**
```bash
# Process all attachments from last week
mail-attachments batch \
  --search "--days 7 --has-attachment" \
  --action "download --organize-by-date"
```

### 3. **Webhook Integration**
```bash
# Notify when specific attachments arrive
mail-attachments monitor \
  --sender "@important.com" \
  --type pdf \
  --webhook "https://hooks.slack.com/..."
```

## Example: Complete Workflow

```bash
#!/bin/bash
# Process all IIH-related attachments from last month

# 1. Search for emails
EMAIL_IDS=$(mail-attachments search \
  --sender "@iih.ng" \
  --has-attachment \
  --days 30 \
  --json | jq -r '.[].id')

# 2. Download attachments
for ID in $EMAIL_IDS; do
  mail-attachments download \
    --email-id $ID \
    --output ~/Documents/IIH/Attachments/ \
    --organize-by-date
done

# 3. Process based on type
find ~/Documents/IIH/Attachments/ -name "*.pdf" -exec pdf-processor {} \;
find ~/Documents/IIH/Attachments/ -name "*.docx" -exec doc-processor {} \;

# 4. Archive
tar -czf ~/Backups/IIH_Attachments_$(date +%Y%m%d).tar.gz ~/Documents/IIH/Attachments/
```

This skill solves the attachment access problem by combining the speed of fruitmail CLI with the full access of AppleScript, providing a complete solution for email attachment management in OpenClaw workflows.