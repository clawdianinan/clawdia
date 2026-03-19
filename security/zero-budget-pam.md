# Zero-Budget Privileged Access Management (PAM)

## Executive Summary
This document provides a comprehensive, zero-budget framework for implementing basic Privileged Access Management. The approach focuses on inventory management, free 2FA implementation, manual access logging, and defined review processes without requiring commercial PAM solutions.

## 1. Admin Account Inventory

### 1.1 Inventory Template

Create `security/admin-inventory.csv`:

```csv
System,Username,Role,Access Level,2FA Enabled,Last Password Change,Last Access Review,Owner,Status
Web Server,root,Superuser,Full,No,2026-01-15,2026-02-01,System Admin,Active
Database,admin,DBA,Full,Yes,2026-02-20,2026-02-20,DB Team,Active
CRM,crm_admin,Admin,Moderate,Yes,2026-03-01,2026-03-01,Sales Team,Active
GitHub,temi_dev,Developer,Read/Write,Yes,2026-02-28,2026-02-28,Dev Team,Active
```

### 1.2 Discovery Commands

**Linux/Unix Systems:**
```bash
# List all users with UID 0 (root equivalent)
getent passwd | awk -F: '$3 == 0 {print $1}'

# Check sudoers
sudo cat /etc/sudoers
sudo cat /etc/sudoers.d/*

# Check recent sudo usage
sudo journalctl _COMM=sudo | tail -50

# Check SSH authorized keys
find /home -name "authorized_keys" -type f 2>/dev/null
```

**Database Systems:**

**MySQL/MariaDB:**
```sql
-- List all users with privileges
SELECT user, host FROM mysql.user;
-- Show grants for each user
SHOW GRANTS FOR 'username'@'host';
```

**PostgreSQL:**
```sql
-- List all users
SELECT usename FROM pg_user;
-- Show role memberships
SELECT * FROM pg_roles;
```

**Web Applications:**
- Check admin panels for user lists
- Review configuration files for admin credentials
- Check source code for hardcoded admin accounts

### 1.3 Manual Inventory Spreadsheet

Create `security/admin-inventory.xlsx` or use Google Sheets with these columns:

| System | Account Type | Username | Purpose | Access Level | Owner | Created | Last Used | 2FA | Status | Notes |
|--------|-------------|----------|---------|-------------|-------|---------|-----------|-----|--------|-------|

## 2. Free 2FA Implementation

### 2.1 Google Authenticator for Linux SSH

**Step 1: Install Google Authenticator PAM module**
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install libpam-google-authenticator

# CentOS/RHEL
sudo yum install google-authenticator

# macOS (Homebrew)
brew install google-authenticator
```

**Step 2: Configure for a user**
```bash
# Run as the user who needs 2FA
google-authenticator

# Answer prompts:
# - Do you want authentication tokens to be time-based? y
# - Do you want me to update your "/home/user/.google_authenticator" file? y
# - Do you want to disallow multiple uses of the same authentication token? y
# - Do you want to enable rate-limiting? y
```

**Step 3: Configure SSH to use 2FA**
```bash
# Edit SSH PAM configuration
sudo nano /etc/pam.d/sshd

# Add at the top:
auth required pam_google_authenticator.so

# Edit SSH daemon configuration
sudo nano /etc/ssh/sshd_config

# Ensure these lines are present:
ChallengeResponseAuthentication yes
UsePAM yes

# Restart SSH
sudo systemctl restart sshd
```

### 2.2 2FA for Web Applications

**Option A: Free TOTP Libraries**

**PHP:**
```php
// Install via Composer: composer require robthree/twofactorauth
require_once 'vendor/autoload.php';
use RobThree\Auth\TwoFactorAuth;

$tfa = new TwoFactorAuth('Your App Name');
$secret = $tfa->createSecret();

// Generate QR code for Google Authenticator
$qrCodeUrl = $tfa->getQRCodeImageAsDataUri('user@example.com', $secret);

// Verify code
$isValid = $tfa->verifyCode($secret, $_POST['2fa_code']);
```

**Node.js:**
```javascript
// Install: npm install speakeasy qrcode
const speakeasy = require('speakeasy');
const QRCode = require('qrcode');

// Generate secret
const secret = speakeasy.generateSecret({
  name: "Your App Name",
  issuer: "Your Company"
});

// Generate QR code
QRCode.toDataURL(secret.otpauth_url, (err, data_url) => {
  console.log('QR Code URL:', data_url);
});

// Verify token
const verified = speakeasy.totp.verify({
  secret: secret.base32,
  encoding: 'base32',
  token: userProvidedToken
});
```

**Python:**
```python
# Install: pip install pyotp qrcode[pil]
import pyotp
import qrcode

# Generate secret
secret = pyotp.random_base32()
totp = pyotp.TOTP(secret)

# Generate QR code
qr = qrcode.make(totp.provisioning_uri("user@example.com", issuer_name="Your App"))
qr.save("2fa_qr.png")

# Verify code
is_valid = totp.verify(input_code)
```

**Option B: FreeAuth (Open Source 2FA Solution)**
- GitHub: https://github.com/freeauth/freeauth
- Self-hosted 2FA server
- Supports TOTP, backup codes, and recovery options

### 2.3 Emergency Access Procedures

**Create `security/2fa-emergency-access.md`:**
```markdown
# 2FA Emergency Access Procedures

## Recovery Methods
1. **Backup Codes**: Each user receives 10 one-time backup codes
2. **Recovery Email**: Secondary email for 2FA reset
3. **Manual Override**: Admin can disable 2FA temporarily (requires approval)

## Lost Device Procedure
1. User reports lost device to admin@example.com
2. Admin verifies identity via security questions
3. Admin generates new 2FA secret
4. User sets up new device
5. All backup codes are invalidated

## Emergency Bypass (Last Resort)
Contact: security@example.com
Requires: Two admin approvals
Timeout: 24 hours maximum
```

## 3. Manual Access Logging System

### 3.1 Access Log Spreadsheet Template

Create `security/access-logs/YYYY-MM.csv`:

```csv
Timestamp,User,System,Action,Resource,IP Address,Status,Notes
2026-03-18 10:30:00,admin,Web Server,Login,SSH,192.168.1.100,Success,
2026-03-18 11:15:00,john,Database,SELECT,users_table,192.168.1.101,Success,Regular query
2026-03-18 14:45:00,root,Web Server,DELETE,log_file,192.168.1.100,Success,System maintenance
2026-03-18 16:20:00,unknown,Web Server,Login Attempt,SSH,203.0.113.5,Failed,Brute force attempt
```

### 3.2 Simple Bash Script for Logging

**`security/scripts/log-access.sh`:**
```bash
#!/bin/bash

LOG_FILE="/var/log/custom-access.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
USER=$(whoami)
ACTION="$1"
RESOURCE="$2"
IP=$(echo $SSH_CONNECTION | awk '{print $1}')
STATUS="$3"

echo "$TIMESTAMP,$USER,$ACTION,$RESOURCE,$IP,$STATUS" >> "$LOG_FILE"
```

**Usage:**
```bash
# Log successful login
./log-access.sh "Login" "SSH" "Success"

# Log file access
./log-access.sh "Read" "/etc/passwd" "Success"

# Log failed attempt
./log-access.sh "Login Attempt" "SSH" "Failed"
```

### 3.3 Web Application Access Logging

**PHP Example:**
```php
<?php
function log_admin_access($user_id, $action, $resource, $status) {
    $log_file = '/var/log/web-admin-access.log';
    $timestamp = date('Y-m-d H:i:s');
    $ip = $_SERVER['REMOTE_ADDR'];
    $user_agent = $_SERVER['HTTP_USER_AGENT'];
    
    $log_entry = "$timestamp | User: $user_id | Action: $action | " .
                 "Resource: $resource | IP: $ip | Status: $status | " .
                 "UA: $user_agent\n";
    
    file_put_contents($log_file, $log_entry, FILE_APPEND);
}

// Usage in admin pages
session_start();
if (isset($_SESSION['admin_id'])) {
    log_admin_access(
        $_SESSION['admin_id'],
        'VIEW_ADMIN_PANEL',
        'dashboard.php',
        'SUCCESS'
    );
}
?>
```

**Node.js/Express Example:**
```javascript
// accessLogger.js
const fs = require('fs');
const path = require('path');

const logAccess = (req, action, resource, status) => {
  const timestamp = new Date().toISOString();
  const user = req.user ? req.user.id : 'anonymous';
  const ip = req.ip;
  const userAgent = req.get('User-Agent');
  
  const logEntry = `${timestamp} | User: ${user} | Action: ${action} | ` +
                   `Resource: ${resource} | IP: ${ip} | Status: ${status} | ` +
                   `UA: ${userAgent}\n`;
  
  const logFile = path.join(__dirname, '../logs/admin-access.log');
  fs.appendFileSync(logFile, logEntry);
};

// Middleware
const adminAccessLogger = (req, res, next) => {
  const originalSend = res.send;
  
  res.send = function(body) {
    const action = req.method;
    const resource = req.originalUrl;
    const status = res.statusCode;
    
    logAccess(req, action, resource, status);
    
    originalSend.call(this, body);
  };
  
  next();
};

// Usage
app.use('/admin', adminAccessLogger);
```

## 4. Access Review Process

### 4.1 Monthly Access Review Checklist

**Create `security/access-review-checklist.md`:**
```markdown
# Monthly Access Review Checklist

## Review Date: [YYYY-MM-DD]
## Reviewer: [Name]

### 1. Admin Account Review
- [ ] Verify all admin accounts are still needed
- [ ] Check for inactive accounts (no login in 90 days)
- [ ] Confirm account owners are still with organization
- [ ] Review and update access levels

### 2. 2FA Status Check
- [ ] Verify 2FA is enabled for all admin accounts
- [ ] Check for users with multiple 2FA devices
- [ ] Review backup code usage
- [ ] Test 2FA recovery process

### 3. Access Log Analysis
- [ ] Review failed login attempts
- [ ] Check for unusual access patterns
- [ ] Verify all privileged actions are authorized
- [ ] Follow up on any suspicious activity

### 4. Permission Audit
- [ ] Review sudoers file changes
- [ ] Check database user privileges
- [ ] Verify file system permissions
- [ ] Review API key usage

### 5. Emergency Access Review
- [ ] Test emergency bypass procedures
- [ ] Verify contact information is current
- [ ] Review and update documentation
- [ ] Conduct tabletop exercise

## Findings:
1. [List any issues found]
2. [Action items]
3. [Follow-up dates]

## Sign-off:
Reviewer: __________________ Date: _______________
Security Lead: _______________ Date: _______________
```

### 4.2 Automated Review Script

**`security/scripts/monthly-access-review.sh`:**
```bash
#!/bin/bash

# Monthly Access Review Script
REVIEW_DATE=$(date '+%Y-%m-%d')
REPORT_FILE="/security/reports/access-review-$REVIEW_DATE.md"

echo "# Access Review Report - $REVIEW_DATE" > "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 1. Check for inactive admin accounts
echo "## 1. Inactive Admin Accounts" >> "$REPORT_FILE"
lastlog -b 90 | grep -v "Never logged in" | awk '{print $1}' > /tmp/active_users
cut -d: -f1 /etc/passwd | grep -v -f /tmp/active_users | while read user; do
    if groups "$user" | grep -q "sudo\|admin\|wheel"; then
        echo "- $user (inactive for 90+ days)" >> "$REPORT_FILE"
    fi
done

# 2. Check sudo usage
echo "" >> "$REPORT_FILE"
echo "## 2. Sudo Usage (Last 30 Days)" >> "$REPORT_FILE"
sudo journalctl --since="30 days ago" _COMM=sudo | \
    awk '/sudo:/ {print $8 " " $9 " " $10}' | \
    sort | uniq -c | sort -rn | head -20 >> "$REPORT_FILE"

# 3. Check SSH login attempts
echo "" >> "$REPORT_FILE"
echo "## 3. Failed SSH Attempts" >> "$REPORT_FILE"
sudo grep "Failed password" /var/log/auth.log | \
    awk '{print $11}' | sort | uniq -c | sort -rn | head -10 >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "## 4. Recommendations" >> "$REPORT_FILE"
echo "1. Review inactive admin accounts for removal" >> "$REPORT_FILE"
echo "2. Investigate unusual sudo patterns" >> "$REPORT_FILE"
echo "3. Block IPs with excessive failed attempts" >> "$REPORT_FILE"

echo "Report generated: $REPORT_FILE"
```

### 4.3 Access Review Meeting Template

**Create `security/templates/access-review-meeting.md`:**
```markdown
# Access Review Meeting - [Date]

## Attendees
- [List names]

## Agenda
1. Review of last month's action items
2. Current access review findings
3. Risk assessment updates
4. Policy changes discussion
5. Action items for next month

## Discussion Notes

### 1. Previous Action Items
[Status updates]

### 2. Current Findings
[From automated report]

### 3. Risk Assessment
- High-risk items:
- Medium-risk items:
- Low-risk items:

### 4. Policy Changes
[Proposed changes]

### 5. Action Items
| Item | Owner | Due Date | Status |
|------|-------|----------|--------|
|      |       |          |        |

## Next Meeting
Date: [Next month same date]
Pre-work: [Assignments]

## Notes
[Additional notes]
```

## 5. Emergency Response Procedures

### 5.1 Account Compromise Response

**Create `security/emergency-response.md`:**
```markdown
# Account Compromise Emergency Response

## Step 1: Immediate Containment
1. **Isolate the account**: Disable login immediately
2. **Change passwords**: Reset all related credentials
3. **Revoke sessions**: Terminate all active sessions
4. **Enable logging**: Increase logging for related systems

## Step 2: Investigation
1. **Review access logs**: Last 72 hours minimum
2. **Check for data exfiltration**: Database queries, file downloads
3. **Identify entry point**: How was the account compromised?
4. **Document timeline**: Create incident timeline

## Step 3: Remediation
1. **Implement additional controls**: 2FA, IP restrictions
2. **Update security policies**: Address root cause
3. **Notify affected parties**: If personal data was accessed
4. **Legal considerations**: Consult if necessary

## Step 4: Recovery
1. **Restore from backup**: If data was modified
2. **Monitor for recurrence**: Enhanced monitoring for 30 days
3. **Conduct post-mortem**: Document lessons learned
4. **Update training**: Prevent future occurrences

## Contact List
- Primary Security Contact: [Name, Phone, Email]
- Backup Contact: [Name, Phone, Email]
- Legal Contact: [Name, Phone, Email]
- Management Contact: [Name, Phone, Email]
```

## 6. Success Metrics

Track monthly:
1. **Admin accounts with 2FA**: Target 100%
2. **Inactive accounts removed**: Target 0
3. **Access reviews completed**: Target 100% on schedule
4. **Security incidents**: Target 0
5. **Policy compliance**: Target 100%

## 7. Continuous Improvement

### Quarterly Improvements:
1. **Q1**: Implement basic 2FA for all admin accounts
2. **Q2**: Establish regular access review process
3. **Q3**: Implement logging and monitoring
4. **Q4**: Conduct security awareness training

### Annual Audit:
1. Review all PAM processes
2. Test emergency procedures
3. Update documentation
4. Train new team members

---

**Last Updated**: 2026-03-18  
**Review Schedule**: Monthly  
**Responsible Team**: IT & Security  
**Next Review Date**: 2026-04-18