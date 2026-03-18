// OpenClaw agent for processing Temi's emails
// This agent checks for emails from Temi and processes instructions automatically
// Emails from other sources are referred to Temi for next action

const { execSync } = require('child_process');
const fs = require('fs');

// Configuration - USER emails (Temi Kolawole)
const TEMI_EMAILS = [
    'temi@iih.ng',
    'temi.kolawole@iih.ng',
    'temikolawole@icloud.com',
    'temikolawole@gmail.com'
];

// Maximum emails to process per run
const MAX_EMAILS = 10;

// Log function
function log(message) {
    const timestamp = new Date().toISOString();
    console.log(`[${timestamp}] ${message}`);
}

// Check if email is from Temi
function isFromTemi(from) {
    return TEMI_EMAILS.some(email => from.includes(email));
}

// Get recent emails using himalaya
function getRecentEmails() {
    try {
        const result = execSync(`himalaya envelope list --limit ${MAX_EMAILS} --output json`, {
            encoding: 'utf-8',
            stdio: ['pipe', 'pipe', 'pipe']
        });
        
        return JSON.parse(result);
    } catch (error) {
        log(`Error fetching emails: ${error.message}`);
        return [];
    }
}

// Get email body
function getEmailBody(emailId) {
    try {
        const result = execSync(`himalaya read ${emailId} --output json`, {
            encoding: 'utf-8',
            stdio: ['pipe', 'pipe', 'pipe']
        });
        
        const emailData = JSON.parse(result);
        return emailData.body?.text || emailData.body?.html || '';
    } catch (error) {
        log(`Error reading email ${emailId}: ${error.message}`);
        return '';
    }
}

// Process instruction from Temi's email
async function processTemiInstruction(emailId, subject, from, body) {
    log(`Processing instruction from Temi: ${subject}`);
    
    // Extract the instruction from the email body
    // Look for clear instructions, commands, or task descriptions
    const instruction = extractInstruction(body, subject);
    
    if (!instruction) {
        return {
            success: false,
            message: 'No clear instruction found in email'
        };
    }
    
    // Here we would process the instruction
    // For now, we'll just log it and create a response
    const response = `📧 Email instruction processed:

**From:** ${from}
**Subject:** ${subject}
**Instruction:** ${instruction}

I've received your instruction and will process it accordingly.`;

    // Mark email as read
    try {
        execSync(`himalaya flag ${emailId} --read`, { stdio: 'pipe' });
    } catch (error) {
        // Ignore errors on marking as read
    }
    
    return {
        success: true,
        message: response,
        instruction: instruction
    };
}

// Extract instruction from email body
function extractInstruction(body, subject) {
    // Simple extraction logic - can be enhanced
    const lines = body.split('\n').map(line => line.trim()).filter(line => line);
    
    // Look for common instruction patterns
    const instructionPatterns = [
        /please\s+(.+)/i,
        /can you\s+(.+)/i,
        /i need you to\s+(.+)/i,
        /task:\s*(.+)/i,
        /instruction:\s*(.+)/i,
        /action required:\s*(.+)/i
    ];
    
    for (const line of lines) {
        for (const pattern of instructionPatterns) {
            const match = line.match(pattern);
            if (match) {
                return match[1];
            }
        }
    }
    
    // If no pattern matched, use first few lines as instruction
    if (lines.length > 0) {
        return lines[0].substring(0, 200);
    }
    
    return null;
}

// Refer non-Temi email to Temi
function referToTemi(emailId, subject, from) {
    log(`Referring email to Temi: ${subject} from ${from}`);
    
    const message = `📧 Email requires your attention:

**From:** ${from}
**Subject:** ${subject}

This email is from an external source and requires your review.`;

    // Here we could send a notification via Telegram/WhatsApp
    // For now, we'll just return the message
    
    return {
        referred: true,
        message: message
    };
}

// Main agent function
async function main() {
    log('Starting Temi email processor');
    
    const emails = getRecentEmails();
    log(`Found ${emails.length} emails to process`);
    
    const results = {
        temiEmailsProcessed: 0,
        otherEmailsReferred: 0,
        errors: 0,
        details: []
    };
    
    for (const email of emails) {
        try {
            const { id, subject, from, flags } = email;
            const isRead = flags?.includes('Seen') || false;
            
            // Skip already read emails if desired
            // if (isRead) continue;
            
            if (isFromTemi(from)) {
                log(`Processing email from Temi: ${subject}`);
                
                const body = getEmailBody(id);
                if (!body) {
                    log(`Warning: Could not read body of email ${id}`);
                    results.errors++;
                    continue;
                }
                
                const result = await processTemiInstruction(id, subject, from, body);
                results.temiEmailsProcessed++;
                results.details.push({
                    type: 'temi',
                    subject,
                    success: result.success,
                    message: result.message
                });
                
                // Output the result
                if (result.success) {
                    console.log(result.message);
                }
            } else {
                log(`Referring email from ${from}: ${subject}`);
                
                const result = referToTemi(id, subject, from);
                results.otherEmailsReferred++;
                results.details.push({
                    type: 'other',
                    subject,
                    from,
                    message: result.message
                });
                
                // Output referral message
                console.log(result.message);
            }
        } catch (error) {
            log(`Error processing email: ${error.message}`);
            results.errors++;
        }
    }
    
    log(`Processing complete: ${results.temiEmailsProcessed} Temi emails processed, ${results.otherEmailsReferred} other emails referred, ${results.errors} errors`);
    
    return results;
}

// Export for OpenClaw
module.exports = {
    main,
    isFromTemi,
    extractInstruction
};

// Run if called directly
if (require.main === module) {
    main().catch(error => {
        console.error('Fatal error:', error);
        process.exit(1);
    });
}