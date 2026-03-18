tell application "Mail"
    -- Get the inbox
    set inboxAccount to account "iCloud"
    set inboxMailbox to mailbox "INBOX" of inboxAccount
    
    -- Search for emails from Temi in the last day
    set searchDate to (current date) - (1 * days)
    set temiEmails to (every message of inboxMailbox whose date received is greater than searchDate and sender contains "temi")
    
    repeat with msg in temiEmails
        set msgSubject to subject of msg
        set msgID to id of msg
        set attachmentCount to count of mail attachments of msg
        
        log "Email: " & msgSubject & " (ID: " & msgID & ")"
        log "  Attachments: " & attachmentCount
        
        if attachmentCount > 0 then
            repeat with att in mail attachments of msg
                set attName to name of att
                set attSize to size of att
                log "    - " & attName & " (" & attSize & " bytes)"
            end repeat
        end if
    end repeat
end tell