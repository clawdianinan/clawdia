# Troubleshooting & FAQ

This guide helps you resolve common issues with PRDForge. If you don't find your issue here, please contact our support team.

## Common Issues and Solutions

### Account & Login Issues

#### 1. "Invalid email or password"
**Solution:**
1. Check caps lock is off
2. Try "Forgot password" to reset
3. Clear browser cache and cookies
4. Try incognito/private browsing mode

**If still not working:**
- Check if you're using the correct email (personal vs. work)
- Verify account exists at [app.prdforge.com](https://app.prdforge.com)
- Contact support with your email address

#### 2. "Account not verified"
**Solution:**
1. Check spam/junk folder for verification email
2. Request new verification email from login page
3. Use different email provider if possible
4. Whitelist `@prdforge.com` in your email filters

#### 3. Two-Factor Authentication (2FA) Issues
**Solution:**
1. Use backup codes (saved during 2FA setup)
2. Try authenticator app time sync:
   - Google Authenticator: Settings → Time correction
   - Authy: Settings → Accounts → Time correction
3. Contact support with account details for 2FA reset

### PRD Creation & Editing Issues

#### 1. "AI generation failed"
**Common causes and solutions:**

| Error Message | Cause | Solution |
|--------------|-------|----------|
| "Insufficient credits" | Not enough credits for generation | Purchase credits or upgrade plan |
| "Model unavailable" | AI service temporarily down | Try again in 5-10 minutes |
| "Content too long" | Input exceeds model limits | Break into smaller sections |
| "Invalid prompt" | Prompt contains unsupported content | Simplify or rephrase prompt |
| "Rate limit exceeded" | Too many requests | Wait 1 minute and retry |

**Troubleshooting steps:**
1. Check credit balance in Settings → Credits
2. Try different AI model (Standard vs. Premium)
3. Reduce prompt length
4. Clear section and start fresh
5. Check [status.prdforge.com](https://status.prdforge.com) for outages

#### 2. "Save failed" or "Changes not saved"
**Solution:**
1. Check internet connection
2. Look for auto-save indicator (green dot)
3. Try manual save (Ctrl/Cmd + S)
4. Export current version as backup
5. Refresh page (changes may auto-recover)

**Prevention:**
- Enable auto-save in Settings → Editor
- Export regularly as backup
- Use offline mode for critical work

#### 3. "Template not loading"
**Solution:**
1. Clear browser cache (Ctrl/Cmd + Shift + R)
2. Try different browser
3. Check template availability in Template Library
4. Create new project with different template

### Export & Download Issues

#### 1. "Export failed" or "Export stuck"
**Solution:**

| Export Format | Common Issues | Solutions |
|--------------|---------------|-----------|
| PDF | Large documents, complex formatting | Reduce document size, simplify formatting |
| Word (.docx) | Font issues, template conflicts | Use standard fonts, try different template |
| Markdown | Special character encoding | Check for invalid characters |
| JSON | Data structure issues | Validate JSON structure |
| Google Sheets | Permission issues, quota limits | Check Google account permissions |

**General troubleshooting:**
1. Wait 5-10 minutes (large exports take time)
2. Check export status in Exports page
3. Try different export format
4. Reduce document size (remove images, split sections)
5. Clear browser cache and retry

#### 2. "Download failed" or "File corrupted"
**Solution:**
1. Check internet connection stability
2. Try different browser
3. Disable browser extensions temporarily
4. Use direct download link from Exports page
5. Contact support with export ID for re-generation

#### 3. "Formatting issues in exported file"
**Solution:**
- **PDF**: Check PDF viewer compatibility, try Adobe Reader
- **Word**: Use latest Word version, check compatibility mode
- **Markdown**: Use markdown viewer like Typora or VS Code
- **Google Sheets**: Check sharing permissions, try different account

### Performance Optimization Tips

#### 1. Slow loading or laggy interface
**Quick fixes:**
1. Clear browser cache and cookies
2. Disable browser extensions
3. Use Chrome or Firefox (best performance)
4. Close unused tabs/applications

**Advanced optimization:**
1. Enable hardware acceleration in browser
2. Increase browser memory allocation
3. Use PRDForge desktop app (available for Pro users)
4. Contact IT for network optimization

#### 2. Large document performance issues
**Optimization strategies:**
1. Split large PRDs into multiple projects
2. Use collapsible sections for long content
3. Disable real-time preview for very large documents
4. Export and work offline when possible

#### 3. Browser-specific issues
**Chrome:**
- Clear cache: Ctrl+Shift+Delete
- Disable extensions: chrome://extensions
- Reset settings: chrome://settings/reset

**Firefox:**
- Clear cache: Ctrl+Shift+Delete
- Safe mode: Help → Restart with Add-ons Disabled
- Refresh Firefox: about:support → Refresh Firefox

**Safari:**
- Clear cache: Safari → Preferences → Privacy → Manage Website Data
- Disable extensions: Safari → Preferences → Extensions
- Reset: Safari → Clear History and Website Data

### Billing and Account Questions

#### 1. "Payment failed" or "Card declined"
**Common causes:**
- Insufficient funds
- Card expired
- International transaction blocked
- Billing address mismatch

**Solution:**
1. Check card details and expiration date
2. Contact bank to authorize international transactions
3. Try different payment method (PayPal, Paystack)
4. Update billing information in Settings → Billing

#### 2. "Unexpected charges" or "Billing confusion"
**Understanding PRDForge billing:**
- **Free plan**: $0, 10 credits/month, export costs $5/project
- **Starter**: $9/month, includes exports, 100 credits/month
- **Pro**: $29/month, unlimited projects, 500 credits/month
- **Credits**: Used for AI generations ($5 = 25 credits)

**Check:**
1. Current plan in Settings → Billing
2. Credit usage in Settings → Credits
3. Export history in Exports page
4. Invoice details in Billing → Invoices

#### 3. "How to cancel or downgrade"
**Process:**
1. Go to Settings → Billing
2. Click "Change Plan" or "Cancel Subscription"
3. Follow prompts (subscription continues until end of billing period)
4. Receive confirmation email

**Important notes:**
- No refunds for partial months
- Credits don't roll over after cancellation
- Data retained for 30 days after cancellation
- Can re-activate within 30 days

#### 4. "Tax/VAT invoices needed"
**Solution:**
1. Go to Settings → Billing → Invoices
2. Download any invoice as PDF
3. For custom invoices, contact billing@prdforge.com
4. Include company VAT number in billing profile

### Team & Collaboration Issues

#### 1. "Can't invite team members"
**Check:**
1. Current plan supports teams (Starter+: up to 5, Pro+: up to 25)
2. Email address is correct
3. User doesn't already have PRDForge account with that email
4. Team member limit not reached

**Solution:**
1. Upgrade plan for more team members
2. Remove inactive members first
3. Use different email address
4. Contact support for team management help

#### 2. "Permission issues" or "Can't access project"
**Common scenarios:**
- **Viewer** trying to edit: Request edit permission from admin
- **Editor** trying to delete: Only admins can delete
- **Project not visible**: Check project sharing settings

**Resolution:**
1. Contact project owner or team admin
2. Check your role in Team → Members
3. Verify project is shared with your team
4. Request access via project share link

#### 3. "Real-time collaboration not working"
**Troubleshooting:**
1. Check internet connection (WebSocket required)
2. Refresh page to re-establish connection
3. Check if collaborator is online (green dot)
4. Try different browser
5. Disable VPN or proxy temporarily

### Integration Problems

#### 1. "GitHub/GitLab sync failed"
**Check:**
1. API token is valid and has correct permissions
2. Repository exists and is accessible
3. Webhook is configured correctly
4. Rate limits not exceeded

**Solution:**
1. Regenerate API token with correct scopes
2. Check repository URL and permissions
3. Test webhook delivery in integration settings
4. Implement exponential backoff for API calls

#### 2. "Jira/Notion connection issues"
**Common problems:**
- Invalid API credentials
- Insufficient permissions
- Field mapping conflicts
- Webhook delivery failures

**Troubleshooting:**
1. Test connection in integration settings
2. Verify API keys/tokens are current
3. Check field names match exactly
4. Test webhook endpoint separately

#### 3. "Custom integration not working"
**Debug steps:**
1. Check API key is valid and not expired
2. Verify endpoint URLs are correct
3. Test with simple API call first
4. Check rate limits and quotas
5. Review error logs in integration settings

### Mobile App Issues

#### 1. "App won't install" or "Installation failed"
**Solution:**
- **iOS**: Check iOS version (requires 14.0+), storage space
- **Android**: Check Android version (8.0+), enable unknown sources if sideloading
- **Both**: Restart device, check internet connection

#### 2. "App crashes" or "Freezes"
**Quick fixes:**
1. Force close and restart app
2. Clear app cache (Settings → Apps → PRDForge → Storage → Clear Cache)
3. Update to latest version
4. Reinstall app (backup data first)

#### 3. "Sync issues between web and mobile"
**Solution:**
1. Check both are logged into same account
2. Pull to refresh on mobile
3. Check internet connection on both devices
4. Force sync from web app (Settings → Sync Now)

## Frequently Asked Questions (FAQ)

### General Questions

#### Q: Is there a free trial?
**A:** Yes! Free plan includes 10 credits/month. No credit card required.

#### Q: Can I use PRDForge offline?
**A:** Limited offline mode available in desktop app for Pro users. Web app requires internet connection.

#### Q: Is my data secure?
**A:** Yes. We use encryption at rest and in transit, regular security audits, and comply with GDPR/CCPA.

#### Q: Can I export all my data?
**A:** Yes. Go to Settings → Account → Export Data to download all your PRDs and data.

### Pricing & Plans

#### Q: What's the difference between plans?
**A:** 
- **Free**: 10 credits/month, export costs extra
- **Starter** ($9): 100 credits/month, exports included
- **Pro** ($29): 500 credits/month, unlimited projects
- **Enterprise**: Custom pricing, advanced features

#### Q: Do credits roll over?
**A:** No, credits reset monthly. Unused credits don't carry over.

#### Q: Can I pay annually?
**A:** Yes! Annual plans save 17% (Starter: $90/year, Pro: $290/year).

#### Q: Are there educational discounts?
**A:** Yes. Contact sales@prdforge.com with proof of educational status.

### Features & Usage

#### Q: How many PRDs can I create?
**A:** Free: 3 active projects, Starter: 15, Pro: unlimited.

#### Q: What AI models are available?
**A:** Standard (GPT-4), Premium (Claude 3), Advanced (specialized models).

#### Q: Can I use my own templates?
**A:** Yes! Create and save custom templates in all paid plans.

#### Q: Is there version history?
**A:** Yes. All plans include version history and restore.

### Technical Questions

#### Q: What browsers are supported?
**A:** Chrome 90+, Firefox 88+, Safari 14+, Edge 90+.

#### Q: Is there an API?
**A:** Yes! REST API available for all paid plans. WebSocket API for real-time features.

#### Q: Can I self-host PRDForge?
**A:** Enterprise plan includes self-hosting option. Contact sales.

#### Q: What's the maximum file size?
**A:** 50MB per project, 10MB per image upload.

### Account Management

#### Q: Can I change my email?
**A:** Yes. Settings → Account → Email. Requires verification.

#### Q: How do I delete my account?
**A:** Settings → Account → Delete Account. Data deleted after 30 days.

#### Q: Can I transfer projects to another account?
**A:** Yes. Contact support with both account emails.

#### Q: What happens when I cancel?
**A:** Access continues until billing period ends. Data retained 30 days.

## Performance Optimization Tips

### For Slow Performance

1. **Browser Optimization**
   - Use latest Chrome or Firefox
   - Disable unnecessary extensions
   - Clear cache regularly
   - Enable hardware acceleration

2. **Document Optimization**
   - Split large PRDs (>50 pages)
   - Use collapsible sections
   - Compress images before upload
   - Avoid complex tables with many cells

3. **Network Optimization**
   - Use wired connection if possible
   - Close bandwidth-heavy applications
   - Disable VPN for testing
   - Check router/modem performance

### For AI Generation Speed

1. **Prompt Optimization**
   - Be specific but concise
   - Use clear formatting
   - Provide examples when possible
   - Break complex requests into steps

2. **Model Selection**
   - Standard models: Fastest, good for most tasks
   - Premium models: Slower, better for complex tasks
   - Advanced models: Slowest, specialized use cases

3. **Batch Processing**
   - Generate multiple sections at once
   - Use templates for consistency
   - Queue generations during off-peak hours

## Contact Support Information

### When to Contact Support

**Immediate assistance needed:**
- Security incident or data breach
- Payment charged but no access
- Account hacked or compromised
- Critical bug preventing all work

**Within 24 hours:**
- Export failures
- Billing issues
- Account access problems
- Major feature not working

**Within 3 business days:**
- Feature requests
- Minor bugs
- General questions
- Integration help

### How to Contact Support

#### 1. In-App Support (Fastest)
1. Click Help (?) in bottom right
2. Select "Contact Support"
3. Describe issue with details
4. Attach screenshots if helpful

#### 2. Email Support
- **General**: support@prdforge.com
- **Billing**: billing@prdforge.com
- **Enterprise**: enterprise@prdforge.com
- **Security**: security@prdforge.com

**Include in email:**
- Account email
- Description of issue
- Steps to reproduce
- Screenshots/error messages
- Browser/OS information

#### 3. Community Support
- **GitHub Discussions**: [github.com/prdforge/discussions](https://github.com/prdforge/discussions)
- **Stack Overflow**: Tag `prdforge`
- **Discord**: [discord.gg/prdforge](https://discord.gg/prdforge)

#### 4. Phone Support (Enterprise Only)
- **US**: +1 (555) 123-PRDF
- **UK**: +44 20 7123 4567
- **EU**: +49 30 12345678

Available 9 AM - 5 PM local time, Monday-Friday.

### What Support Can Help With

**Yes, we can help:**
- Account access and security
- Billing and subscription issues
- Bug reports and technical issues
- Feature explanations and how-tos
- Integration setup and troubleshooting

**No, we cannot help:**
- Writing your PRD content
- Making business decisions
- Legal or compliance advice
- Third-party tool support

### Before Contacting Support

**Please try:**
1. Restarting browser/application
2. Clearing cache and cookies
3. Checking [status.prdforge.com](https://status.prdforge.com)
4. Searching this troubleshooting guide
5. Asking in community forums

**Have ready:**
1. Your account email
2. Error messages (screenshot)
3. Steps to reproduce
4. Browser/OS information

## Service Status and Updates

### Check Service Status
- **Status Page**: [status.prdforge.com](https://status.prdforge.com)
- **Twitter Updates**: [@prdforgestatus](https://twitter.com/prdforgestatus)
- **Email Alerts**: Subscribe on status page

### Maintenance Schedule
- **Regular maintenance**: Sundays 2-4 AM UTC
- **Emergency maintenance**: 24-hour notice when possible
- **Updates**: Deployed gradually, minimal disruption

### SLA (Service Level Agreement)
- **Free**: 99% uptime
- **Starter**: 99.5% uptime
- **Pro**: 99.9% uptime
- **Enterprise**: 99.95% uptime with credits

---

**Remember**: Most issues can be resolved quickly with the steps above. If you're still having trouble, our support team is here to help!

Last Updated: March 2026  
Support Version: 4.1.0