-- Read email from Mail.app
tell application "Mail"
	-- Try to find the organogram email
	set targetSubject to "New IIH Organogram"
	set foundMessages to {}
	
	repeat with theAccount in every account
		repeat with theMailbox in every mailbox of theAccount
			try
				set theseMessages to (every message of theMailbox whose subject contains targetSubject)
				if (count of theseMessages) > 0 then
					set foundMessages to foundMessages & theseMessages
				end if
			on error
				-- Skip mailboxes with errors
			end try
		end repeat
	end repeat
	
	if (count of foundMessages) > 0 then
		-- Get the most recent one
		set theMessage to item 1 of foundMessages
		set messageContent to content of theMessage
		set messageSender to sender of theMessage
		set messageDate to date received of theMessage
		
		return "EMAIL FOUND:
Subject: " & targetSubject & "
From: " & messageSender & "
Date: " & messageDate & "

CONTENT:
" & messageContent
	else
		return "Email not found in Mail.app"
	end if
end tell