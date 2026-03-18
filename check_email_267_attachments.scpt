tell application "Mail"
    -- Try to select the email with ID 267 by subject
    set targetSubject to "Program KPIs"
    set foundMessage to missing value
    
    repeat with theAccount in every account
        repeat with theMailbox in every mailbox of theAccount
            repeat with theMessage in every message of theMailbox
                if subject of theMessage contains targetSubject then
                    set foundMessage to theMessage
                    exit repeat
                end if
            end repeat
            if foundMessage is not missing value then exit repeat
        end repeat
        if foundMessage is not missing value then exit repeat
    end repeat
    
    if foundMessage is not missing value then
        set attachmentNames to {}
        repeat with theAttachment in mail attachments of foundMessage
            set end of attachmentNames to name of theAttachment
        end repeat
        return attachmentNames
    else
        return "Message not found"
    end if
end tell