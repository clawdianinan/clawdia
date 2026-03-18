#!/usr/bin/env python3
"""
Integration example for Email Auto-Processor with attachment access
"""

import sys
import os
import json
from pathlib import Path
from datetime import datetime

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent))

from mail_attachments import MailAttachments

class EnhancedEmailProcessor:
    """
    Enhanced email processor that can access attachments
    """
    
    def __init__(self):
        self.ma = MailAttachments()
        self.attachments_dir = Path.home() / "Documents" / "EmailAttachments"
        self.attachments_dir.mkdir(parents=True, exist_ok=True)
    
    def process_email_with_attachments(self, email_info):
        """
        Process an email that has attachments
        
        Args:
            email_info: Email information from fruitmail search
        
        Returns:
            dict: Processing results
        """
        email_id = email_info.get('id')
        subject = email_info.get('subject', 'No subject')
        sender = email_info.get('sender_address', '')
        
        print(f"Processing email {email_id}: {subject}")
        
        # Get attachments
        attachments = self.ma.get_attachments_via_applescript(email_id)
        
        if not attachments:
            return {
                'email_id': email_id,
                'status': 'no_attachments',
                'message': 'No attachments found'
            }
        
        # Create organized directory
        email_dir = self.attachments_dir / f"email_{email_id}_{datetime.now().strftime('%Y%m%d')}"
        email_dir.mkdir(exist_ok=True)
        
        # Download all attachments
        downloaded = []
        for attachment in attachments:
            att_name = attachment.get('name', 'unknown')
            file_path = self.ma.download_attachment(email_id, att_name, email_dir)
            if file_path:
                downloaded.append({
                    'name': att_name,
                    'path': file_path,
                    'size': os.path.getsize(file_path) if os.path.exists(file_path) else 0
                })
        
        # Process based on file types
        processing_results = self._process_downloaded_files(downloaded, email_info)
        
        return {
            'email_id': email_id,
            'subject': subject,
            'sender': sender,
            'attachments_found': len(attachments),
            'downloaded': len(downloaded),
            'downloaded_files': downloaded,
            'processing_results': processing_results,
            'download_dir': str(email_dir),
            'timestamp': datetime.now().isoformat()
        }
    
    def _process_downloaded_files(self, downloaded_files, email_info):
        """
        Process downloaded files based on type
        
        Args:
            downloaded_files: List of downloaded file info
            email_info: Original email info
        
        Returns:
            dict: Processing results by file type
        """
        results = {
            'pdf': [],
            'documents': [],
            'images': [],
            'spreadsheets': [],
            'other': []
        }
        
        for file_info in downloaded_files:
            file_path = file_info['path']
            file_ext = os.path.splitext(file_path)[1].lower()
            
            file_result = {
                'path': file_path,
                'name': file_info['name'],
                'extension': file_ext,
                'size': file_info['size']
            }
            
            # Categorize and process
            if file_ext == '.pdf':
                file_result['action'] = 'process_pdf'
                file_result['summary'] = self._extract_pdf_summary(file_path)
                results['pdf'].append(file_result)
                
            elif file_ext in ['.doc', '.docx', '.txt', '.rtf']:
                file_result['action'] = 'process_document'
                results['documents'].append(file_result)
                
            elif file_ext in ['.xls', '.xlsx', '.csv']:
                file_result['action'] = 'process_spreadsheet'
                results['spreadsheets'].append(file_result)
                
            elif file_ext in ['.jpg', '.jpeg', '.png', '.gif']:
                file_result['action'] = 'process_image'
                results['images'].append(file_result)
                
            else:
                file_result['action'] = 'archive'
                results['other'].append(file_result)
        
        return results
    
    def _extract_pdf_summary(self, pdf_path):
        """Extract basic info from PDF (placeholder for actual PDF processing)"""
        try:
            # This would use a PDF processing library like PyPDF2
            # For now, return basic info
            return {
                'pages': 'unknown',
                'size_kb': os.path.getsize(pdf_path) / 1024,
                'filename': os.path.basename(pdf_path)
            }
        except:
            return {'error': 'Could not process PDF'}
    
    def find_emails_needing_processing(self, criteria):
        """
        Find emails that need attachment processing
        
        Args:
            criteria: dict with search criteria
        
        Returns:
            list: Emails matching criteria
        """
        return self.ma.search_emails(**criteria)
    
    def process_batch(self, search_criteria, output_report=None):
        """
        Process a batch of emails matching criteria
        
        Args:
            search_criteria: Search criteria for emails
            output_report: Path to save processing report
        
        Returns:
            dict: Batch processing results
        """
        print(f"Batch processing with criteria: {search_criteria}")
        
        emails = self.find_emails_needing_processing(search_criteria)
        
        if not emails:
            print("No emails found matching criteria")
            return {'total': 0, 'processed': 0, 'results': []}
        
        print(f"Found {len(emails)} emails to process")
        
        results = []
        for i, email in enumerate(emails, 1):
            print(f"\n[{i}/{len(emails)}] Processing email: {email.get('subject', 'No subject')}")
            
            try:
                result = self.process_email_with_attachments(email)
                results.append(result)
                print(f"  ✓ Processed {result.get('downloaded', 0)} attachments")
            except Exception as e:
                print(f"  ✗ Error processing email: {e}")
                results.append({
                    'email_id': email.get('id'),
                    'status': 'error',
                    'error': str(e)
                })
        
        # Generate report
        report = {
            'timestamp': datetime.now().isoformat(),
            'criteria': search_criteria,
            'total_emails': len(emails),
            'successful': len([r for r in results if r.get('status') != 'error']),
            'failed': len([r for r in results if r.get('status') == 'error']),
            'total_attachments': sum([r.get('downloaded', 0) for r in results if isinstance(r.get('downloaded'), int)]),
            'results': results
        }
        
        if output_report:
            with open(output_report, 'w') as f:
                json.dump(report, f, indent=2)
            print(f"\nReport saved to: {output_report}")
        
        return report


# Example usage for your specific needs
def process_iih_emails():
    """Example: Process IIH-related emails with attachments"""
    processor = EnhancedEmailProcessor()
    
    # Criteria for IIH emails
    criteria = {
        'sender': '@iih.ng',
        'has_attachment': True,
        'days': 30,
        'limit': 50
    }
    
    report = processor.process_batch(
        criteria,
        output_report=Path.home() / "Documents" / "IIH" / "email_processing_report.json"
    )
    
    return report


def process_specific_email_ids(email_ids):
    """Process specific email IDs (like from your auto-processor)"""
    processor = EnhancedEmailProcessor()
    
    # Since fruitmail doesn't have a "get by ID" command, we search broadly
    # and filter by ID
    all_recent = processor.ma.search_emails(days=7, limit=100)
    
    results = []
    for email in all_recent:
        if email.get('id') in email_ids:
            result = processor.process_email_with_attachments(email)
            results.append(result)
    
    return results


# Integration with your existing auto-processor
def enhance_auto_processor():
    """
    Example of how to enhance your existing email auto-processor
    
    Your current flow:
    1. fruitmail search → find emails
    2. Process email bodies
    3. Create todos/responses
    
    Enhanced flow:
    1. fruitmail search → find emails WITH attachments
    2. Download attachments using this skill
    3. Process attachments based on type
    4. Include attachment content in responses
    5. Save attachments to organized folders
    """
    
    processor = EnhancedEmailProcessor()
    
    # Example: Process the emails you mentioned
    target_emails = [
        # Email 166: "Report on Facility conditions"
        # Email 247: "IIH FINANCIAL REPORT" 
        # Email 242: "FACILITY MANAGEMENT REPORT"
        # Email 297: "New Roles for Hiring"
    ]
    
    # You would get these IDs from your fruitmail search
    # For example:
    # fruitmail search --subject "Report on Facility conditions" --json
    
    print("To integrate with your auto-processor:")
    print("1. In your cron job, after finding emails with fruitmail...")
    print("2. For emails with attachments, call process_specific_email_ids()")
    print("3. Use the downloaded attachments in your processing")
    print("4. Save results to appropriate locations")
    
    return processor


if __name__ == "__main__":
    print("Enhanced Email Processor with Attachment Access")
    print("=" * 50)
    
    # Test the processor
    processor = EnhancedEmailProcessor()
    
    # Example: Find recent emails with attachments
    print("\n1. Finding recent emails with attachments...")
    emails = processor.find_emails_needing_processing({
        'days': 3,
        'has_attachment': True,
        'limit': 3
    })
    
    if emails:
        print(f"Found {len(emails)} emails")
        
        # Process first email as example
        print(f"\n2. Processing first email as example...")
        result = processor.process_email_with_attachments(emails[0])
        
        print(f"   Email: {result.get('subject')}")
        print(f"   Attachments downloaded: {result.get('downloaded')}")
        print(f"   Saved to: {result.get('download_dir')}")
        
        # Show what was downloaded
        if result.get('downloaded_files'):
            print(f"\n   Downloaded files:")
            for file_info in result['downloaded_files']:
                print(f"     • {file_info['name']} ({file_info['size']} bytes)")
    
    print("\n" + "=" * 50)
    print("\nTo use in your workflows:")
    print("""
# Basic usage
from email_processor_integration import EnhancedEmailProcessor

processor = EnhancedEmailProcessor()

# Find emails needing processing
emails = processor.find_emails_needing_processing({
    'sender': '@iih.ng',
    'has_attachment': True,
    'days': 30
})

# Process each email
for email in emails:
    result = processor.process_email_with_attachments(email)
    # Do something with result...
    
# Or process specific email IDs
results = process_specific_email_ids([166, 247, 242, 297])
    """)