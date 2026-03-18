tell application "Mail"
	-- Get all messages in inbox
	set inboxMessages to messages of inbox
	
	-- Find the message with Maiduguri in subject
	repeat with msg in inboxMessages
		if subject of msg contains "MAIDGURI" then
			set msgSubject to subject of msg
			set msgID to id of msg
			set msgDate to date received of msg
			
			-- Get attachments
			set attachmentNames to {}
			set attachmentPaths to {}
			
			repeat with att in every attachment of msg
				set attName to name of att
				set end of attachmentNames to attName
				
				-- Save attachment
				set downloadsPath to (path to downloads folder as text)
				set savePath to downloadsPath & attName
				save att in file savePath
				set end of attachmentPaths to POSIX path of savePath
			end repeat
			
			return {msgSubject, msgID, msgDate, attachmentNames, attachmentPaths}
		end if
	end repeat
	
	return "No message found"
end tell