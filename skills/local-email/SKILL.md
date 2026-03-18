# Local Email Skill

## Purpose
Send emails using local SMTP servers without API keys or external dependencies.

## Features
- Send emails via local SMTP (Zoho, Gmail, etc.)
- Reply to existing email threads
- CC/BCC support
- Attachment support (basic)
- Uses existing email credentials from system

## Requirements
- Python 3.6+
- SMTP credentials configured in system

## Configuration
Store SMTP settings in `~/.openclaw/email_config.json`:
```json
{
  "zoho_iih": {
    "smtp_server": "smtp.zoho.com",
    "smtp_port": 587,
    "username": "clawdia.ai@iih.ng",
    "use_tls": true
  },
  "gmail": {
    "smtp_server": "smtp.gmail.com", 
    "smtp_port": 587,
    "username": "clawdianinan@gmail.com",
    "use_tls": true
  }
}
```

## Usage Examples
```bash
# Send simple email
python scripts/send_email.py --to "recipient@example.com" --subject "Test" --body "Hello" --account zoho_iih

# Reply to thread
python scripts/send_email.py --to "maureen@iih.ng" --subject "Re: Event Request" --body "Response here" --account zoho_iih --cc "temi@iih.ng"

# With attachment
python scripts/send_email.py --to "someone@example.com" --subject "Document" --body "See attached" --attachment "/path/to/file.pdf" --account gmail
```

## Security
- Never store passwords in config files
- Use system keychain or environment variables
- All credentials managed outside the skill

## Integration
Works with:
- `apple-mail-search-safe` for reading/searching
- System Mail app for complex email management
- Existing email infrastructure