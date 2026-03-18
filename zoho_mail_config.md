# Zoho Mail Configuration (from Himalaya)

## Account 1: temi.kolawole@iih.ng
- **IMAP:** imap.zoho.com:993 (TLS)
- **SMTP:** smtp.zoho.com:587 (STARTTLS)
- **Auth:** security find-generic-password -s 'himalaya-zoho' -a 'temi.kolawole@iih.ng' -w | tr -d '\n'

## Account 2: clawdia.ai@iih.ng  
- **IMAP:** imap.zoho.com:993 (TLS)
- **SMTP:** smtp.zoho.com:587 (STARTTLS)
- **Auth:** security find-generic-password -s 'himalaya-iih-clawdia' -a 'clawdia.ai@iih.ng' -w | tr -d '\n'

## Other Accounts in Himalaya:
- **clawdianinan@gmail.com** (Gmail)
- **clawdianinan@icloud.com** (iCloud)

## Skills Now Available:
1. **zoho-mail** (v1.0.4) - Zoho Mail integration
2. **apple-mail-search-safe** (v5.0.4) - Safe Apple Mail search

## Next Steps:
- Test zoho-mail skill with the configured accounts
- Use apple-mail-search-safe for Mail app access
- Consider creating a unified email skill using these settings