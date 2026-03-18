tell application "Mail"
	set inboxMessages to messages of inbox
	set resultList to {}
	
	repeat with msg in inboxMessages
		if subject of msg contains "MAIDGURI" then
			set msgID to id of msg
			set msgSubject to subject of msg
			set msgDate to date received of msg
			
			-- Try to get attachment count
			try
				set attCount to count of every attachment of msg
			on error
				set attCount to 0
			end try
			
			set end of resultList to {msgID, msgSubject, msgDate, attCount}
		end if
	end repeat
	
	return resultList
end tell