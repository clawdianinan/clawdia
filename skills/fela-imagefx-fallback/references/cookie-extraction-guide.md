# ImageFX Cookie Extraction Guide

## Prerequisites
- Google account: `clawdianinan@gmail.com`
- Logged into Chrome with this account
- ImageFX available in your region (or use VPN)

## Method 1: Cookie Editor Extension (Recommended)

### Step 1: Install Extension
1. Open Chrome
2. Go to: https://chrome.google.com/webstore/detail/cookie-editor/hlkenndednhfkekhgcdicdfddnkalmdm
3. Click "Add to Chrome"

### Step 2: Get Cookie
1. Navigate to: https://labs.google/fx/tools/image-fx
2. Ensure you're logged in as `clawdianinan@gmail.com`
3. Click the Cookie Editor extension icon
4. Click "Export" button
5. Select "Header String" format
6. Copy the entire cookie string

### Step 3: Set Environment Variable
```bash
# Terminal (macOS/Linux)
export GOOGLE_COOKIE="paste_cookie_here"

# Make permanent (add to ~/.zshrc or ~/.bashrc)
echo 'export GOOGLE_COOKIE="paste_cookie_here"' >> ~/.zshrc
source ~/.zshrc
```

## Method 2: Browser Developer Tools

### Step 1: Open DevTools
1. Navigate to: https://labs.google/fx/tools/image-fx
2. Press F12 or Ctrl+Shift+I (Cmd+Option+I on Mac)
3. Go to "Network" tab

### Step 2: Capture Request
1. Press Ctrl+R (Cmd+R) to refresh page
2. Look for request named "image-fx" or similar
3. Click on the request

### Step 3: Extract Cookie
1. In the request details, go to "Headers" section
2. Find "Request Headers" → "Cookie"
3. Copy the entire cookie value
4. Set as environment variable (see Method 1 Step 3)

## Method 3: JavaScript Console

### Step 1: Get Cookie via Console
1. Navigate to: https://labs.google/fx/tools/image-fx
2. Open DevTools (F12)
3. Go to "Console" tab
4. Paste and run:
```javascript
console.log(document.cookie);
```

### Step 2: Format for API
```bash
# Combine all cookies into header format
export GOOGLE_COOKIE="$(echo 'paste_cookies_here' | tr ';' '; ')"
```

## Cookie Format Requirements

### Valid Cookie Example
```
__Secure-1PSID=abc123...; __Secure-1PSIDTS=def456...; __Secure-1PSIDCC=ghi789...; NID=123...; OTZ=456...; SID=789...; HSID=abc...; SSID=def...; APISID=ghi...; SAPISID=jkl...; ...etc
```

### Required Cookies (Minimum)
- `__Secure-1PSID` (Primary session ID)
- `__Secure-1PSIDTS` (Timestamp)
- `__Secure-1PSIDCC` (Cross-domain)
- `SID`, `HSID`, `SSID` (Google session IDs)

## Testing Cookie Validity

### Quick Test
```bash
# Test with simple prompt
imagefx generate --prompt "test image" --cookie "$GOOGLE_COOKIE"

# Expected output: Image saved to current directory
```

### Error Diagnosis
- **"Authentication failed"**: Cookie expired or incomplete
- **"Invalid cookie format"**: Missing required cookies
- **"Region not supported"**: Need VPN for initial cookie acquisition
- **"Rate limited"**: Too many requests, wait and retry

## Cookie Refresh Schedule

### Expiration Times
- **Short-lived**: 1-7 days (typical)
- **Long-lived**: Up to 30 days (with activity)
- **Detection**: Failed authentication after successful previous use

### Refresh Procedure
1. **Weekly check**: Test cookie every Monday
2. **Automated refresh**: Script to detect and refresh
3. **Backup cookies**: Store multiple valid cookies

## Regional Restrictions Workaround

### If ImageFX Not Available
1. **Install VPN** (Windscribe, ProtonVPN, etc.)
2. **Connect to US/UK/Canada** server
3. **Get cookie** while on VPN
4. **Disconnect VPN** (cookie works globally)

### VPN Services
- **Free**: Windscribe (10GB/month), ProtonVPN (free tier)
- **Paid**: ExpressVPN, NordVPN, Surfshark
- **Important**: Only need VPN for initial cookie acquisition

## Security Considerations

### Cookie Protection
- **Never commit** cookies to git
- **Environment variables only**
- **Restrict file permissions**: `chmod 600 ~/.cookie_file`
- **Regular rotation**: Change cookies periodically

### Account Security
- **Dedicated account**: `clawdianinan@gmail.com` for ImageFX only
- **Monitor activity**: Check Google Account → Security
- **Revoke access**: If cookie compromised, revoke in Google Account

## Automation Script

### Cookie Refresh Script
```bash
#!/bin/bash
# refresh_cookie.sh

# Check cookie validity
if ! imagefx generate --prompt "test" --cookie "$GOOGLE_COOKIE" --dir /tmp 2>/dev/null; then
    echo "Cookie expired, manual refresh required"
    echo "Please:"
    echo "1. Navigate to https://labs.google/fx/tools/image-fx"
    echo "2. Use Cookie Editor to export new cookie"
    echo "3. Update GOOGLE_COOKIE environment variable"
    exit 1
else
    echo "Cookie valid"
fi
```

### Scheduled Check (cron)
```bash
# Add to crontab (crontab -e)
0 9 * * 1 /path/to/refresh_cookie.sh  # Every Monday at 9 AM
```

## Troubleshooting Common Issues

### Issue: "Cookie expired"
**Solution**: 
1. Clear browser cookies for labs.google
2. Re-login to `clawdianinan@gmail.com`
3. Extract fresh cookie

### Issue: "Invalid model"
**Solution**:
```bash
# List available models
imagefx --help | grep -A5 "model"
```

### Issue: "Network error"
**Solution**:
1. Check internet connection
2. Retry with delay: `sleep 5 && command`
3. Verify labs.google is accessible

### Issue: "Too many requests"
**Solution**:
1. Implement rate limiting: 1 request per 10 seconds
2. Use batch processing with delays
3. Monitor usage patterns

## Best Practices

### 1. Cookie Storage
- **Primary**: Environment variable `GOOGLE_COOKIE`
- **Backup**: Encrypted file with restricted permissions
- **Rotation**: Multiple cookies for high-volume usage

### 2. Error Handling
- **Graceful fallback**: Switch to Nano Banana if ImageFX fails
- **Retry logic**: Exponential backoff for transient errors
- **Monitoring**: Log all authentication failures

### 3. Performance
- **Batch processing**: Group character generations
- **Parallel limits**: Max 2 concurrent requests
- **Cache results**: Reuse successful generations

### 4. Maintenance
- **Weekly validation**: Test cookie every Monday
- **Version updates**: Check npm package for updates
- **Documentation**: Keep this guide updated

## Support & Updates

### Package Updates
```bash
# Check for updates
npm outdated -g @rohitaryal/imagefx-api

# Update package
npm update -g @rohitaryal/imagefx-api
```

### GitHub Repository
- **Source**: https://github.com/rohitaryal/imageFX-api
- **Issues**: Report bugs and feature requests
- **Contributions**: Pull requests welcome

### Community
- **Discord**: OpenClaw community for support
- **Stack Overflow**: Tag with `imagefx-api`
- **Documentation**: Read package README for latest features

---

*Last updated: 2026-03-16 | For AOZ character generation fallback system*