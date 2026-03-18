-- Mail Notification Watcher for OpenClaw
-- This AppleScript monitors Mail app for new emails and triggers OpenClaw processing

property notificationHandlerScript : "/Users/clawdia/.openclaw/workspace/mail_notification_handler.sh"

on run
    -- Check if Mail is running
    tell application "System Events"
        if not (exists process "Mail") then
            display notification "Mail is not running" with title "OpenClaw Mail Watcher"
            return
        end if
    end tell
    
    -- Display status
    display notification "Mail notification watcher is active" with title "OpenClaw Mail Watcher"
    
    -- We can't directly monitor notifications in AppleScript easily
    -- Instead, we'll set up a periodic check or use a different approach
    -- For now, just log that we're running
    do shell script "echo '[$(date)] Mail watcher started' >> /tmp/mail_watcher.log"
    
    return "Mail notification watcher initialized"
end run

-- Function to check for new emails and trigger processing
on checkForNewMail()
    try
        tell application "Mail"
            -- Get unread count
            set unreadCount to count of (messages of inbox whose read status is false)
            
            if unreadCount > 0 then
                -- Get most recent unread email
                set recentMessages to (messages of inbox whose read status is false)
                set newestMessage to first item of recentMessages
                
                -- Check if it's from Temi
                set senderAddress to sender of newestMessage
                set isFromTemi to false
                
                -- Check against known Temi email addresses (USER emails)
                set temiEmails to {"temi@iih.ng", "temi.kolawole@iih.ng", "temikolawole@icloud.com", "temikolawole@gmail.com"}
                repeat with temiEmail in temiEmails
                    if senderAddress contains temiEmail then
                        set isFromTemi to true
                        exit repeat
                    end if
                end repeat
                
                -- Trigger OpenClaw processing
                do shell script notificationHandlerScript & " \"New mail from " & senderAddress & "\""
                
                return "New email detected from " & senderAddress & " (Temi: " & isFromTemi & ")"
            else
                return "No new unread emails"
            end if
        end tell
    on error errMsg
        return "Error checking mail: " & errMsg
    end try
end checkForNewMail

-- Function to manually trigger email check
on triggerEmailCheck()
    return checkForNewMail()
end triggerEmailCheck