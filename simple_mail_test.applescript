-- Simple Mail.app test script
-- Run this in Script Editor to test permissions

tell application "Mail"
	-- Get account names to verify access
	set accountNames to {}
	repeat with anAccount in every account
		set end of accountNames to name of anAccount
	end repeat
	
	-- Return account names
	return accountNames
end tell