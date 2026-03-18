#!/bin/bash
# Check ALL email accounts for emails from Temi

echo "=== CHECKING ALL ACCOUNTS FOR EMAILS FROM TEMI ==="
echo ""

# Get list of accounts
accounts=$(himalaya account list 2>/dev/null | tail -n +3 | awk '{print $1}' | tr -d '|')

if [[ -z "$accounts" ]]; then
    echo "No accounts found in himalaya"
    exit 1
fi

echo "Found accounts: $accounts"
echo ""

total_emails_from_temi=0

for account in $accounts; do
    echo "🔍 Checking account: $account"
    
    # Try to get emails from this account
    # Note: himalaya doesn't have a direct --account flag in envelope command
    # We need to set default account or use config
    
    # For now, let's check if this account is accessible
    if himalaya --account "$account" folder list 2>/dev/null | grep -q "INBOX"; then
        echo "  ✓ Account accessible"
        
        # Check recent emails (this is tricky without proper account switching)
        # For now, just note that account exists
        echo "  • Account exists but need to check emails"
    else
        echo "  ✗ Account not accessible"
    fi
    echo ""
done

echo "=== IMMEDIATE FIX REQUIRED ==="
echo ""
echo "PROBLEM: himalaya CLI doesn't support easy account switching in envelope commands"
echo ""
echo "SOLUTION 1: Configure clawdia.ai@iih.ng as default account"
echo "  Edit ~/.config/himalaya/config.toml and set:"
echo "  [accounts.iih_clawdia]"
echo "  default = true"
echo ""
echo "SOLUTION 2: Send test email to accessible account"
echo "  Send to: clawdianinan@gmail.com (currently accessible)"
echo ""
echo "SOLUTION 3: Update all scripts to use specific account"
echo "  Need to modify: morning_digest.sh, regular_update.sh, etc."
echo ""
echo "RECOMMENDATION:"
echo "  1. Send test email to clawdianinan@gmail.com for now"
echo "  2. I'll update scripts to check iih_clawdia account specifically"
echo "  3. Configure proper account switching in himalaya"