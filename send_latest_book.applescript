tell application "Mail"
    set newMessage to make new outgoing message with properties {subject:"Thrive Where You Are - LATEST Manuscript (v2 DOCX)", content:"Here is the LATEST version of the \"Thrive Where You Are\" manuscript in DOCX format.

File: Thrive_Where_You_Are_FORMATTED_v2.docx
Size: 169 KB
Created: March 16, 18:08 (newer than previous version)
Pages: Estimated 208 pages
Words: 51,633+

This is the most recent formatted version, publication-ready with professional Word formatting.

Best,
Clawdia"}
    
    tell newMessage
        make new to recipient at end of to recipients with properties {address:"temikolawole@gmail.com"}
        try
            make new attachment with properties {file name:"/Users/clawdia/My Drive/Clawdia Documents/Projects/ThriveWhereYouAre/Thrive_Where_You_Are_FORMATTED_v2.docx"} at after the last paragraph of content
        on error
            set content of newMessage to content of newMessage & "

[Attachment path: /Users/clawdia/My Drive/Clawdia Documents/Projects/ThriveWhereYouAre/Thrive_Where_You_Are_FORMATTED_v2.docx]"
        end try
    end tell
    
    activate
    set visible of newMessage to true
end tell