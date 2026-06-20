#!/usr/bin/env python3
"""
Enhanced Email Sender - Send HTML emails with attachments
"""

import smtplib
import json
import os
import sys
import argparse
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.application import MIMEApplication
from email.mime.image import MIMEImage
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

def parse_inline_images(inline_images):
    parsed = []
    for item in inline_images or []:
        if "=" not in item:
            print(f"  Warning: Inline image must be CID=PATH, got: {item}")
            continue
        cid, path = item.split("=", 1)
        cid = cid.strip().strip("<>")
        path = path.strip()
        if not cid or not path:
            print(f"  Warning: Invalid inline image spec: {item}")
            continue
        parsed.append((cid, path))
    return parsed

def send_html_email(to, subject, html_body, plain_body, account, cc=None, attachments=None, inline_images=None):
    """Send an HTML email with optional plain text fallback"""
    config = load_config()
    
    if account not in config:
        print(f"Error: Account '{account}' not found in config")
        print(f"Available accounts: {list(config.keys())}")
        return False
    
    account_config = config[account]
    password = get_password_from_keychain(account)
    
    if not password:
        print(f"Error: No password found for account '{account}'")
        print("Set password in keychain: security add-generic-password -s 'email-{account}' -a '{username}' -w 'PASSWORD'")
        print(f"Or set environment variable: EMAIL_PASSWORD_{account.upper()}")
        return False
    
    # Create message. Use mixed -> related -> alternative so inline images
    # stay associated with the HTML body while normal files remain attachments.
    msg = MIMEMultipart('mixed')
    msg['From'] = account_config.get('from_address', account_config['username'])
    msg['To'] = to
    msg['Date'] = formatdate(localtime=True)
    msg['Subject'] = subject
    
    if cc:
        msg['Cc'] = cc
    
    related = MIMEMultipart('related')
    alternative = MIMEMultipart('alternative')
    alternative.attach(MIMEText(plain_body, 'plain'))
    alternative.attach(MIMEText(html_body, 'html'))
    related.attach(alternative)

    for cid, image_path in parse_inline_images(inline_images):
        if not os.path.exists(image_path):
            print(f"  Warning: Inline image not found: {image_path}")
            continue
        with open(image_path, 'rb') as f:
            image = MIMEImage(f.read())
        image.add_header('Content-ID', f'<{cid}>')
        image.add_header('Content-Disposition', 'inline', filename=os.path.basename(image_path))
        related.attach(image)
        print(f"  Inline image: {cid} -> {os.path.basename(image_path)}")

    msg.attach(related)
    
    # Add attachments if specified
    if attachments:
        if isinstance(attachments, str):
            attachments = [attachments]
        
        for attachment_path in attachments:
            if os.path.exists(attachment_path):
                with open(attachment_path, 'rb') as f:
                    filename = os.path.basename(attachment_path)
                    # Determine MIME type
                    if filename.lower().endswith('.pdf'):
                        mime_type = 'application/pdf'
                    elif filename.lower().endswith('.docx'):
                        mime_type = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
                    elif filename.lower().endswith('.png'):
                        mime_type = 'image/png'
                    elif filename.lower().endswith('.jpg') or filename.lower().endswith('.jpeg'):
                        mime_type = 'image/jpeg'
                    else:
                        mime_type = 'application/octet-stream'
                    
                    part = MIMEApplication(f.read(), _subtype=mime_type.split('/')[-1])
                    part.add_header('Content-Disposition', 'attachment', filename=filename)
                    part.add_header('Content-Type', mime_type)
                    msg.attach(part)
                print(f"  Attached: {filename}")
            else:
                print(f"  Warning: Attachment not found: {attachment_path}")
    
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
        recipients = [to]
        if cc:
            recipients.append(cc)
        
        server.send_message(msg)
        server.quit()
        
        print(f"✅ HTML email sent successfully to {to}")
        if cc:
            print(f"   CC: {cc}")
        return True
        
    except Exception as e:
        print(f"❌ Error sending email: {e}")
        return False

def main():
    parser = argparse.ArgumentParser(description='Send HTML emails with attachments')
    parser.add_argument('--to', required=True, help='Recipient email address')
    parser.add_argument('--subject', required=True, help='Email subject')
    parser.add_argument('--html', help='HTML body content (file or text)')
    parser.add_argument('--html-file', help='HTML body file')
    parser.add_argument('--plain', help='Plain text body content (file or text)')
    parser.add_argument('--plain-file', help='Plain text body file')
    parser.add_argument('--signature-html-file', help='HTML signature file to append')
    parser.add_argument('--signature-plain-file', help='Plain text signature file to append')
    parser.add_argument('--account', required=True, help='Email account to use (from config)')
    parser.add_argument('--cc', help='CC email address')
    parser.add_argument('--attachments', nargs='+', help='Paths to attachment files')
    parser.add_argument('--inline-images', nargs='+', help='Inline images as CID=PATH')
    
    args = parser.parse_args()
    
    # Load HTML body
    html_body = ""
    if args.html_file:
        with open(args.html_file, 'r') as f:
            html_body = f.read()
    elif args.html:
        html_body = args.html
    
    # Load plain text body
    plain_body = ""
    if args.plain_file:
        with open(args.plain_file, 'r') as f:
            plain_body = f.read()
    elif args.plain:
        plain_body = args.plain
    elif html_body:
        # Create simple plain text from HTML (basic conversion)
        import re
        plain_body = re.sub(r'<[^>]+>', '', html_body)
        plain_body = re.sub(r'\n\s*\n', '\n\n', plain_body)

    if args.signature_html_file:
        with open(args.signature_html_file, 'r') as f:
            html_body = f"{html_body}\n{f.read()}"

    if args.signature_plain_file:
        with open(args.signature_plain_file, 'r') as f:
            plain_body = f"{plain_body.rstrip()}\n\n{f.read()}"
    
    if not html_body and not plain_body:
        print("Error: No email body provided")
        return False
    
    # Check if config exists
    config_path = os.path.expanduser("~/.openclaw/email_config.json")
    if not os.path.exists(config_path):
        print("Configuration file not found.")
        return False
    
    success = send_html_email(
        to=args.to,
        subject=args.subject,
        html_body=html_body,
        plain_body=plain_body,
        account=args.account,
        cc=args.cc,
        attachments=args.attachments,
        inline_images=args.inline_images
    )
    
    sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()
