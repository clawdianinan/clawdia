#!/usr/bin/env python3
"""
Mail Attachments - Access email attachments from CLI and Apple Mail.app
"""

import os
import sys
import json
import subprocess
import argparse
from pathlib import Path
from datetime import datetime, timedelta
import tempfile
import shutil

class MailAttachments:
    """Main class for email attachment management"""
    
    def __init__(self, debug=False):
        self.debug = debug
        self.fruitmail_path = self._find_fruitmail()
        self.ensure_mail_app_running()
        
    def _find_fruitmail(self):
        """Find fruitmail CLI executable"""
        paths = [
            "/opt/homebrew/bin/fruitmail",
            "/usr/local/bin/fruitmail",
            "/usr/bin/fruitmail",
            subprocess.run(["which", "fruitmail"], capture_output=True, text=True).stdout.strip()
        ]
        
        for path in paths:
            if path and os.path.exists(path):
                if self.debug:
                    print(f"Found fruitmail at: {path}")
                return path
        
        raise FileNotFoundError(
            "fruitmail CLI not found. Install with: npm install -g apple-mail-search-cli"
        )
    
    def ensure_mail_app_running(self):
        """Ensure Mail.app is running"""
        try:
            # Check if Mail.app is running
            result = subprocess.run(
                ["osascript", "-e", 'tell application "System Events" to (name of processes) contains "Mail"'],
                capture_output=True,
                text=True
            )
            
            if "true" not in result.stdout.lower():
                if self.debug:
                    print("Mail.app not running, starting it...")
                subprocess.run(["open", "-a", "Mail"])
                
                # Wait a moment for Mail to start
                import time
                time.sleep(3)
        except Exception as e:
            if self.debug:
                print(f"Warning checking Mail.app: {e}")
    
    def run_fruitmail(self, args, json_output=True):
        """Run fruitmail command and return results"""
        cmd = [self.fruitmail_path] + args
        if json_output:
            cmd.append("--json")
        
        if self.debug:
            print(f"Running: {' '.join(cmd)}")
        
        try:
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            if result.returncode != 0:
                print(f"fruitmail error: {result.stderr}")
                return None
            
            if json_output:
                try:
                    return json.loads(result.stdout)
                except json.JSONDecodeError:
                    # Try to parse as lines
                    lines = result.stdout.strip().split('\n')
                    return [{"raw": line} for line in lines if line]
            else:
                return result.stdout
                
        except Exception as e:
            print(f"Error running fruitmail: {e}")
            return None
    
    def search_emails(self, **kwargs):
        """
        Search emails with various filters
        
        Args:
            subject: Search by subject
            sender: Search by sender email
            days: Days lookback
            unread: Only unread emails
            has_attachment: Only emails with attachments
            attachment_type: Filter by attachment extension
            limit: Max results
        """
        args = ["search"]
        
        if kwargs.get('subject'):
            args.extend(["--subject", kwargs['subject']])
        if kwargs.get('sender'):
            args.extend(["--sender", kwargs['sender']])
        if kwargs.get('days'):
            args.extend(["--days", str(kwargs['days'])])
        if kwargs.get('unread'):
            args.append("--unread")
        if kwargs.get('has_attachment'):
            args.append("--has-attachment")
        if kwargs.get('attachment_type'):
            args.extend(["--attachment-type", kwargs['attachment_type']])
        if kwargs.get('limit'):
            args.extend(["-n", str(kwargs['limit'])])
        
        return self.run_fruitmail(args)
    
    def get_email_body(self, email_id):
        """Get email body content"""
        result = self.run_fruitmail(["body", str(email_id)], json_output=False)
        return result
    
    def get_attachments_via_applescript(self, email_id):
        """
        Get attachment information via AppleScript
        
        Returns list of attachments with name, size, and id
        """
        applescript = f'''
tell application "Mail"
    set targetMessage to missing value
    
    -- Search through all accounts and mailboxes
    repeat with anAccount in every account
        repeat with aMailbox in every mailbox of anAccount
            repeat with aMessage in every message of aMailbox
                if id of aMessage is {email_id} then
                    set targetMessage to aMessage
                    exit repeat
                end if
            end repeat
            if targetMessage is not missing value then exit repeat
        end repeat
        if targetMessage is not missing value then exit repeat
    end repeat
    
    if targetMessage is missing value then
        return ""
    end if
    
    -- Get attachments and format as simple text
    set attachmentText to ""
    set attCount to 0
    repeat with anAttachment in every attachment of targetMessage
        set attCount to attCount + 1
        set attName to name of anAttachment
        set attId to id of anAttachment as text
        set attachmentText to attachmentText & "Attachment " & attCount & ": " & attName & " (ID: " & attId & ")" & "
"
    end repeat
    
    if attCount = 0 then
        return "No attachments"
    else
        return attachmentText
    end if
end tell
        '''
        
        try:
            result = subprocess.run(
                ["osascript", "-e", applescript],
                capture_output=True,
                text=True
            )
            
            if result.returncode != 0:
                print(f"AppleScript error: {result.stderr}")
                return []
            
            # Parse AppleScript list output
            # Format: {{name:"file.pdf", id:"123"}, {name:"doc.docx", id:"124"}}
            output = result.stdout.strip()
            if not output or output == "{}":
                return []
            
            # Simple parsing - for more robust parsing, we'd need a better approach
            attachments = []
            lines = output.strip('{}').split('}, {')
            for line in lines:
                line = line.strip('{}')
                parts = line.split(', ')
                att = {}
                for part in parts:
                    if ':' in part:
                        key, value = part.split(':', 1)
                        att[key.strip()] = value.strip().strip('"')
                if att:
                    attachments.append(att)
            
            return attachments
            
        except Exception as e:
            print(f"Error getting attachments via AppleScript: {e}")
            return []
    
    def download_attachment(self, email_id, attachment_name, output_dir=None):
        """
        Download an attachment via AppleScript
        
        Args:
            email_id: Email message ID
            attachment_name: Name of attachment to download
            output_dir: Directory to save to (default: Downloads)
        
        Returns path to downloaded file
        """
        if output_dir is None:
            output_dir = str(Path.home() / "Downloads")
        
        output_dir = Path(output_dir)
        output_dir.mkdir(parents=True, exist_ok=True)
        
        output_path = output_dir / attachment_name
        
        # Clean filename for AppleScript
        safe_name = attachment_name.replace('"', '\\"')
        
        applescript = f'''
tell application "Mail"
    set targetMessage to missing value
    
    -- Search through all accounts and mailboxes
    repeat with anAccount in every account
        repeat with aMailbox in every mailbox of anAccount
            repeat with aMessage in every message of aMailbox
                if id of aMessage is {email_id} then
                    set targetMessage to aMessage
                    exit repeat
                end if
            end repeat
            if targetMessage is not missing value then exit repeat
        end repeat
        if targetMessage is not missing value then exit repeat
    end repeat
    
    if targetMessage is missing value then
        return "Message not found: {email_id}"
    end if
    
    -- Find and save the attachment
    repeat with anAttachment in every attachment of targetMessage
        if name of anAttachment is "{safe_name}" then
            set savePath to POSIX file "{output_path}"
            save anAttachment in savePath
            return "Saved: {safe_name}"
        end if
    end repeat
    
    return "Attachment not found: {safe_name}"
end tell
        '''
        
        try:
            result = subprocess.run(
                ["osascript", "-e", applescript],
                capture_output=True,
                text=True
            )
            
            if result.returncode != 0:
                print(f"Download error: {result.stderr}")
                return None
            
            if os.path.exists(output_path):
                if self.debug:
                    print(f"Downloaded: {output_path}")
                return str(output_path)
            else:
                print(f"Download failed: {result.stdout}")
                return None
                
        except Exception as e:
            print(f"Error downloading attachment: {e}")
            return None
    
    def download_all_attachments(self, email_id, output_dir=None):
        """Download all attachments from an email"""
        attachments = self.get_attachments_via_applescript(email_id)
        
        if not attachments:
            print(f"No attachments found for email {email_id}")
            return []
        
        downloaded = []
        for att in attachments:
            path = self.download_attachment(email_id, att['name'], output_dir)
            if path:
                downloaded.append(path)
        
        return downloaded
    
    def open_email_in_mail(self, email_id):
        """Open email in Mail.app"""
        result = self.run_fruitmail(["open", str(email_id)], json_output=False)
        return result
    
    def get_email_info(self, email_id):
        """Get comprehensive email information"""
        # First get basic info from fruitmail
        emails = self.search_emails(limit=1)
        if not emails:
            return None
        
        # Find the specific email
        target_email = None
        for email in emails:
            if str(email.get('id')) == str(email_id):
                target_email = email
                break
        
        if not target_email:
            return None
        
        # Get body
        body = self.get_email_body(email_id)
        
        # Get attachments
        attachments = self.get_attachments_via_applescript(email_id)
        
        return {
            **target_email,
            'body_preview': body[:500] + "..." if body and len(body) > 500 else body,
            'attachments': attachments,
            'attachment_count': len(attachments)
        }
    
    def batch_process(self, search_kwargs, output_dir=None, callback=None):
        """
        Batch process emails matching search criteria
        
        Args:
            search_kwargs: Search criteria
            output_dir: Directory for downloads
            callback: Function to call for each email (email_info, downloaded_paths)
        """
        emails = self.search_emails(**search_kwargs)
        
        if not emails:
            print("No emails found matching criteria")
            return []
        
        results = []
        for email in emails:
            email_id = email.get('id')
            if not email_id:
                continue
            
            print(f"Processing email {email_id}: {email.get('subject', 'No subject')}")
            
            # Get attachments
            attachments = self.get_attachments_via_applescript(email_id)
            
            # Download attachments
            downloaded = []
            for att in attachments:
                path = self.download_attachment(email_id, att['name'], output_dir)
                if path:
                    downloaded.append(path)
            
            # Call callback if provided
            if callback:
                callback_result = callback({
                    'email': email,
                    'attachments': attachments,
                    'downloaded': downloaded
                })
                results.append(callback_result)
            else:
                results.append({
                    'email_id': email_id,
                    'subject': email.get('subject'),
                    'attachments_found': len(attachments),
                    'downloaded': downloaded
                })
        
        return results


def main():
    """Command-line interface"""
    parser = argparse.ArgumentParser(description="Mail Attachments Manager")
    parser.add_argument("--debug", action="store_true", help="Enable debug output")
    
    subparsers = parser.add_subparsers(dest="command", help="Command to execute")
    
    # Search command
    search_parser = subparsers.add_parser("search", help="Search emails")
    search_parser.add_argument("--subject", help="Search by subject")
    search_parser.add_argument("--sender", help="Search by sender")
    search_parser.add_argument("--days", type=int, default=30, help="Days lookback")
    search_parser.add_argument("--unread", action="store_true", help="Only unread")
    search_parser.add_argument("--has-attachment", action="store_true", help="Only with attachments")
    search_parser.add_argument("--attachment-type", help="Attachment type filter")
    search_parser.add_argument("--limit", type=int, default=20, help="Max results")
    
    # List attachments command
    list_parser = subparsers.add_parser("list-attachments", help="List attachments in email")
    list_parser.add_argument("email_id", type=int, help="Email ID")
    
    # Download command
    download_parser = subparsers.add_parser("download", help="Download attachments")
    download_parser.add_argument("email_id", type=int, help="Email ID")
    download_parser.add_argument("--output", "-o", default="~/Downloads", help="Output directory")
    download_parser.add_argument("--all", action="store_true", help="Download all attachments")
    download_parser.add_argument("--name", help="Specific attachment name")
    
    # Info command
    info_parser = subparsers.add_parser("info", help="Get email info")
    info_parser.add_argument("email_id", type=int, help="Email ID")
    
    # Open command
    open_parser = subparsers.add_parser("open", help="Open email in Mail.app")
    open_parser.add_argument("email_id", type=int, help="Email ID")
    
    # Batch command
    batch_parser = subparsers.add_parser("batch", help="Batch process")
    batch_parser.add_argument("--output", "-o", default="~/Downloads", help="Output directory")
    batch_parser.add_argument("--days", type=int, default=7, help="Days lookback")
    batch_parser.add_argument("--sender", help="Filter by sender")
    batch_parser.add_argument("--subject", help="Filter by subject")
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        return
    
    ma = MailAttachments(debug=args.debug)
    
    if args.command == "search":
        results = ma.search_emails(
            subject=args.subject,
            sender=args.sender,
            days=args.days,
            unread=args.unread,
            has_attachment=args.has_attachment,
            attachment_type=args.attachment_type,
            limit=args.limit
        )
        
        if results:
            print(f"Found {len(results)} emails:")
            for email in results:
                print(f"  ID: {email.get('id')}")
                print(f"    Subject: {email.get('subject', 'No subject')}")
                print(f"    From: {email.get('sender_name', '')} <{email.get('sender_address', '')}>")
                print(f"    Date: {email.get('date_received', '')}")
                if email.get('has_attachment'):
                    print(f"    Has attachments: Yes")
                print()
    
    elif args.command == "list-attachments":
        attachments = ma.get_attachments_via_applescript(args.email_id)
        
        if attachments:
            print(f"Attachments in email {args.email_id}:")
            for i, att in enumerate(attachments, 1):
                print(f"  {i}. {att.get('name', 'Unknown')} (ID: {att.get('id', 'N/A')})")
        else:
            print(f"No attachments found in email {args.email_id}")
    
    elif args.command == "download":
        output_dir = os.path.expanduser(args.output)
        
        if args.all:
            downloaded = ma.download_all_attachments(args.email_id, output_dir)
            if downloaded:
                print(f"Downloaded {len(downloaded)} attachments:")
                for path in downloaded:
                    print(f"  ✓ {os.path.basename(path)}")
            else:
                print("No attachments downloaded")
        
        elif args.name:
            path = ma.download_attachment(args.email_id, args.name, output_dir)
            if path:
                print(f"Downloaded: {path}")
            else:
                print(f"Failed to download attachment: {args.name}")
        
        else:
            # List and ask which to download
            attachments = ma.get_attachments_via_applescript(args.email_id)
            if attachments:
                print("Available attachments:")
                for i, att in enumerate(attachments, 1):
                    print(f"  {i}. {att.get('name', 'Unknown')}")
                
                try:
                    choice = input("\nEnter number to download (or 'all'): ").strip()
                    if choice.lower() == 'all':
                        downloaded = ma.download_all_attachments(args.email_id, output_dir)
                        if downloaded:
                            print(f"Downloaded {len(downloaded)} attachments")
                    else:
                        idx = int(choice) - 1
                        if 0 <= idx < len(attachments):
                            att_name = attachments[idx]['name']
                            path = ma.download_attachment(args.email_id, att_name, output_dir)
                            if path:
                                print(f"Downloaded: {path}")
                        else:
                            print("Invalid choice")
                except (ValueError, KeyboardInterrupt):
                    print("Cancelled")
            else:
                print("No attachments found")
    
    elif args.command == "info":
        info = ma.get_email_info(args.email_id)
        if info:
            print(f"Email ID: {args.email_id}")
            print(f"Subject: {info.get('subject', 'No subject')}")
            print(f"From: {info.get('sender_name', '')} <{info.get('sender_address', '')}>")
            print(f"Date: {info.get('date_received', '')}")
            print(f"Attachments: {info.get('attachment_count', 0)}")
            
            if info.get('attachments'):
                print("Attachment list:")
                for att in info['attachments']:
                    print(f"  • {att.get('name', 'Unknown')}")
            
            if info.get('body_preview'):
                print(f"\nBody preview:\n{info['body_preview']}")
        else:
            print(f"Email {args.email_id} not found")
    
    elif args.command == "open":
        result = ma.open_email_in_mail(args.email_id)
        print(f"Opened email {args.email_id} in Mail.app")
    
    elif args.command == "batch":
        output_dir = os.path.expanduser(args.output)
        
        search_kwargs = {
            'days': args.days,
            'has_attachment': True
        }
        
        if args.sender:
            search_kwargs['sender'] = args.sender
        if args.subject:
            search_kwargs['subject'] = args.subject
        
        def process_callback(result):
            email = result['email']
            downloaded = result['downloaded']
            
            print(f"  Processed: {email.get('subject', 'No subject')}")
            print(f"    Downloaded {len(downloaded)} files")
            return result
        
        print(f"Batch processing emails from last {args.days} days...")
        results = ma.batch_process(
            search_kwargs=search_kwargs,
            output_dir=output_dir,
            callback=process_callback
        )