#!/usr/bin/env python3
"""
Local Email Sender - Send emails using SMTP without API keys
"""

import smtplib
import json
import os
import sys
import argparse
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.application import MIMEApplication
from email.utils import formatdate
from pathlib import Path

def get_password_from_keychain(account_name):
    """Get password from macOS keychain"""
    try:
        import subprocess
        # Try to get password from keychain
        cmd = ['security', 'find-generic-password', '-s', f'email-{account_name}', '-w']
        result = subprocess.run(cmd, capture_output=True, text=True)
        if result.returncode == 0:
            return result.stdout.strip()
    except:
        pass
    
    # Try environment variable
    env_var = f"EMAIL_PASSWORD_{account_name.upper()}"
    return os.getenv(env_var, "")

def load_config():
    """Load email configuration"""
    config_path = os.path.expanduser("~/.openclaw/email_config.json")
    if os.path.exists(config_path):
        with open(config_path, 'r') as f:
            return json.load(f)
    return {}

def send_email(args):
    """Send an email using SMTP"""
    config = load_config()
    
    if args.account not in config:
        print(f"Error: Account '{args.account}' not found in config")
        print(f"Available accounts: {list(config.keys())}")
        return False
    
    account_config = config[args.account]
    
    # Get password
    password = get_password_from_keychain(args.account)
    if not password:
        print(f"Error: No password found for account '{args.account}'")
        print("Set password in keychain: security add-generic-password -s 'email-{account}' -a '{username}' -w 'PASSWORD'")
        print(f"Or set environment variable: EMAIL_PASSWORD_{args.account.upper()}")
        return False
    
    # Create message
    msg = MIMEMultipart()
    msg['From'] = account_config.get('from_address', account_config['username'])
    msg['To'] = args.to
    msg['Date'] = formatdate(localtime=True)
    msg['Subject'] = args.subject
    
    if args.cc:
        msg['Cc'] = args.cc
    
    # Add body
    msg.attach(MIMEText(args.body, 'plain'))
    
    # Add attachment if specified
    if args.attachment and os.path.exists(args.attachment):
        with open(args.attachment, 'rb') as f:
            part = MIMEApplication(f.read(), Name=os.path.basename(args.attachment))
        part['Content-Disposition'] = f'attachment; filename="{os.path.basename(args.attachment)}"'
        msg.attach(part)
    
    try:
        # Connect to SMTP server
        if account_config.get('use_tls', True):
            server = smtplib.SMTP(account_config['smtp_server'], account_config['smtp_port'])
            server.starttls()
        else:
            server = smtplib.SMTP(account_config['smtp_server'], account_config['smtp_port'])
        
        # Login
        server.login(account_config['username'], password)
        
        # Send email
        recipients = [args.to]
        if args.cc:
            recipients.append(args.cc)
        
        server.send_message(msg)
        server.quit()
        
        print(f"Email sent successfully to {args.to}")
        if args.cc:
            print(f"CC: {args.cc}")
        return True
        
    except Exception as e:
        print(f"Error sending email: {e}")
        return False

def main():
    parser = argparse.ArgumentParser(description='Send emails using local SMTP')
    parser.add_argument('--to', required=True, help='Recipient email address')
    parser.add_argument('--subject', required=True, help='Email subject')
    parser.add_argument('--body', required=True, help='Email body text')
    parser.add_argument('--account', required=True, help='Email account to use (from config)')
    parser.add_argument('--cc', help='CC email address')
    parser.add_argument('--attachment', help='Path to attachment file')
    
    args = parser.parse_args()
    
    # Check if config exists
    config_path = os.path.expanduser("~/.openclaw/email_config.json")
    if not os.path.exists(config_path):
        print("Configuration file not found. Creating template...")
        create_template_config(config_path)
        print(f"Please edit {config_path} with your SMTP settings")
        return
    
    success = send_email(args)
    sys.exit(0 if success else 1)

def create_template_config(config_path):
    """Create a template configuration file"""
    template = {
        "zoho_iih": {
            "smtp_server": "smtp.zoho.com",
            "smtp_port": 587,
            "username": "clawdia.ai@iih.ng",
            "from_address": "clawdia.ai@iih.ng",
            "use_tls": True
        },
        "gmail": {
            "smtp_server": "smtp.gmail.com",
            "smtp_port": 587,
            "username": "clawdianinan@gmail.com",
            "from_address": "clawdianinan@gmail.com",
            "use_tls": True
        }
    }
    
    os.makedirs(os.path.dirname(config_path), exist_ok=True)
    with open(config_path, 'w') as f:
        json.dump(template, f, indent=2)

if __name__ == '__main__':
    main()