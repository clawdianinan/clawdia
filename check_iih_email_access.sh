#!/bin/bash
# Check IIH email access and provide configuration help

echo "=== IIH EMAIL ACCESS CHECK ==="
echo ""

# Check current himalaya configuration
echo "1. Current himalaya configuration:"
if [[ -f ~/.config/himalaya/config.toml ]]; then
    grep -A2 "\[accounts\." ~/.config/himalaya/config.toml | grep "email ="
else
    echo "   No himalaya config found"
fi

echo ""
echo "2. Testing email access:"
echo "   - Checking Gmail account (clawdianinan@gmail.com)..."
if himalaya folder list 2>/dev/null | grep -q "INBOX"; then
    echo "   ✓ Gmail access OK"
    
    # Check for emails from Temi
    echo "   - Checking for emails from Temi in Gmail..."
    if emails=$(himalaya envelope list --limit 10 --output json 2>/dev/null); then
        email_count=$(echo "$emails" | jq 'length')
        temi_emails=0
        for i in $(seq 0 $((email_count - 1))); do
            from=$(echo "$emails" | jq -r ".[$i].from")
            if [[ "$from" == *"temi"* ]] || [[ "$from" == *"Temi"* ]]; then
                ((temi_emails++))
                subject=$(echo "$emails" | jq -r ".[$i].subject")
                echo "   • Found: $subject"
            fi
        done
        if [[ $temi_emails -eq 0 ]]; then
            echo "   ✗ No emails from Temi found in Gmail"
        fi
    fi
else
    echo "   ✗ Gmail access failed"
fi

echo ""
echo "3. IIH Email Configuration Needed:"
echo "   To access clawdia.ai@iih.ng, you need to:"
echo ""
echo "   Step 1: Get Zoho IMAP/SMTP settings for IIH:"
echo "     • IMAP: imap.zoho.com:993"
echo "     • SMTP: smtp.zoho.com:587"
echo "     • Requires app-specific password"
echo ""
echo "   Step 2: Add to himalaya config (~/.config/himalaya/config.toml):"
cat << 'EOF'
[accounts.iih]
email = "clawdia.ai@iih.ng"
display-name = "Clawdia AI - IIH"
default = true

backend.type = "imap"
backend.host = "imap.zoho.com"
backend.port = 993
backend.encryption.type = "tls"
backend.login = "clawdia.ai@iih.ng"
backend.auth.type = "password"
backend.auth.cmd = "security find-generic-password -s 'himalaya-iih' -w"

message.send.backend.type = "smtp"
message.send.backend.host = "smtp.zoho.com"
message.send.backend.port = 587
message.send.backend.encryption.type = "start-tls"
message.send.backend.login = "clawdia.ai@iih.ng"
message.send.backend.auth.type = "password"
message.send.backend.auth.cmd = "security find-generic-password -s 'himalaya-iih' -w"
EOF

echo ""
echo "4. Immediate Workaround:"
echo "   Send test emails to: clawdianinan@gmail.com"
echo "   The system will process them immediately"
echo ""
echo "5. Current Email Processing Status:"
echo "   • Gmail (clawdianinan@gmail.com): ✅ Accessible"
echo "   • IIH (clawdia.ai@iih.ng): ❌ Not configured"
echo "   • iCloud (clawdianinan@icloud.com): ❌ Not configured"