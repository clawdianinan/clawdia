#!/usr/bin/env python3
"""
Simple markdown to DOCX converter for Thrive Where You Are book chapters.
"""

import re
import sys
from pathlib import Path
from docx import Document
from docx.shared import Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH

def convert_markdown_to_docx(md_path, docx_path):
    """Convert markdown file to DOCX with basic formatting."""
    
    # Read markdown file
    with open(md_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Create document
    doc = Document()
    
    # Set default font
    style = doc.styles['Normal']
    font = style.font
    font.name = 'Calibri'
    font.size = Pt(11)
    
    # Process content line by line
    lines = content.split('\n')
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        
        # Skip empty lines
        if not line:
            i += 1
            continue
        
        # Check for headings
        if line.startswith('# '):
            # Main title
            p = doc.add_paragraph(line[2:], style='Title')
            p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        elif line.startswith('## '):
            # Chapter title
            p = doc.add_paragraph(line[3:], style='Heading 1')
        elif line.startswith('### '):
            # Section heading
            p = doc.add_paragraph(line[4:], style='Heading 2')
        elif line.startswith('#### '):
            # Subsection heading
            p = doc.add_paragraph(line[5:], style='Heading 3')
        elif line.startswith('**') and line.endswith('**'):
            # Bold text (remove markers and add as bold run)
            p = doc.add_paragraph()
            run = p.add_run(line[2:-2])
            run.bold = True
        elif line.startswith('*') and line.endswith('*') and not line.startswith('**'):
            # Italic text
            p = doc.add_paragraph()
            run = p.add_run(line[1:-1])
            run.italic = True
        elif line.startswith('- ') or line.startswith('* '):
            # List item
            p = doc.add_paragraph(line[2:], style='List Bullet')
        elif re.match(r'^\d+\. ', line):
            # Numbered list
            p = doc.add_paragraph(line, style='List Number')
        elif line.startswith('> '):
            # Blockquote
            p = doc.add_paragraph(line[2:], style='Intense Quote')
        elif line.startswith('```'):
            # Code block - skip until end of code block
            p = doc.add_paragraph('Code block:', style='Heading 4')
            i += 1
            while i < len(lines) and not lines[i].strip().startswith('```'):
                code_line = lines[i].rstrip()
                if code_line:
                    p = doc.add_paragraph(code_line, style='Normal')
                i += 1
        else:
            # Regular paragraph
            # Clean up any remaining markdown formatting
            clean_line = re.sub(r'\*\*(.*?)\*\*', r'\1', line)  # Remove bold
            clean_line = re.sub(r'\*(.*?)\*', r'\1', clean_line)  # Remove italic
            clean_line = re.sub(r'`(.*?)`', r'\1', clean_line)  # Remove inline code
            clean_line = re.sub(r'\[(.*?)\]\(.*?\)', r'\1', clean_line)  # Remove links
            
            p = doc.add_paragraph(clean_line, style='Normal')
        
        i += 1
    
    # Save document
    doc.save(docx_path)
    print(f"Converted {md_path} to {docx_path}")
    return True

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print("Usage: python convert_md_to_docx.py <input.md> <output.docx>")
        sys.exit(1)
    
    md_path = Path(sys.argv[1])
    docx_path = Path(sys.argv[2])
    
    if not md_path.exists():
        print(f"Error: Input file {md_path} not found")
        sys.exit(1)
    
    convert_markdown_to_docx(md_path, docx_path)