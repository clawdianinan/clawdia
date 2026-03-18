tell application "Mail"
    set newMessage to make new outgoing message with properties {subject:"Thrive Where You Are - Complete Manuscript (DOCX)", content:"Here is the complete manuscript for \"Thrive Where You Are\" in DOCX format.

File: Thrive_Where_You_Are_COMPLETE_MANUSCRIPT_v1_20260316.docx
Size: 172 KB
Pages: Estimated 208 pages
Words: 51,633

This is the publication-ready version formatted according to our DOCX standards (no markdown traces, professional Word formatting).

Please review and let me know your thoughts on the voice alignment and additional layers we discussed.

Best,
Clawdia"}
    
    tell newMessage
        make new to recipient at end of to recipients with properties {address:"temikolawole@gmail.com"}
        try
            make new attachment with properties {file name:"/Users/clawdia/My Drive/Clawdia Documents/Projects/ThriveWhereYouAre/Thrive_Where_You_Are_COMPLETE_MANUSCRIPT_v1_20260316.docx"} at after the last paragraph of content
        on error
            -- If attachment fails, just send without it
            set content of newMessage to content of newMessage & "

[Attachment failed to load - file available at: /Users/clawdia/My Drive/Clawdia Documents/Projects/ThriveWhereYouAre/Thrive_Where_You_Are_COMPLETE_MANUSCRIPT_v1_20260316.docx]"
        end try
    end tell
    
    activate
    open newMessage
end tell