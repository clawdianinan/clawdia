-- AppleScript to invite Slack agents via browser automation
-- This script automates inviting 4 missing agents to Slack

tell application "Safari"
	-- Open Slack workspace
	activate
	open location "https://clawdiasagents.slack.com"
	delay 3
	
	-- Check if we're logged in (look for workspace name)
	try
		set pageText to text of document 1
		if pageText contains "Clawdia's Agents" then
			display notification "Already logged into Slack" with title "Slack Automation"
		else
			-- Need to log in
			display dialog "Please log into Slack in the browser, then click OK to continue automation." buttons {"OK"} default button 1
		end if
	end try
	
	delay 2
	
	-- Navigate to invite page
	-- Method 1: Try to click workspace menu
	tell document 1
		do JavaScript "document.querySelector('[data-qa=\"workspace_switcher\"]').click();" in document 1
	end tell
	delay 1
	
	-- Search for "invite people"
	tell application "System Events"
		keystroke "k" using {command down}
		delay 0.5
		keystroke "invite people"
		delay 0.5
		key code 36 -- return key
	end tell
	delay 2
	
	-- Fill in email addresses
	tell application "System Events"
		-- First email
		keystroke "clawdianinan+ruth@gmail.com"
		delay 0.5
		key code 36 -- return
		delay 0.5
		
		-- Second email
		keystroke "clawdianinan+ngozi@gmail.com"
		delay 0.5
		key code 36 -- return
		delay 0.5
		
		-- Third email
		keystroke "clawdianinan+cypher@gmail.com"
		delay 0.5
		key code 36 -- return
		delay 0.5
		
		-- Fourth email
		keystroke "clawdianinan+morpheus@gmail.com"
		delay 0.5
		key code 36 -- return
		delay 0.5
	end tell
	
	delay 1
	
	-- Try to click send button
	tell document 1
		try
			do JavaScript "document.querySelector('button[data-qa=\"invite_button\"]').click();" in document 1
		on error
			-- Alternative: Press Enter
			tell application "System Events"
				key code 36 -- return
			end tell
		end try
	end tell
	
	delay 2
	
	-- Create channels
	display notification "Starting channel creation..." with title "Slack Automation"
	
	-- Function to create channel
	set channelNames to {"development", "design", "documentation", "compliance", "operations", "testing", "security"}
	
	repeat with channelName in channelNames
		-- Open create channel dialog
		tell application "System Events"
			keystroke "k" using {command down}
			delay 0.5
			keystroke "create a channel"
			delay 0.5
			key code 36 -- return
		end tell
		
		delay 1
		
		-- Enter channel name
		tell application "System Events"
			keystroke channelName
			delay 0.5
			key code 36 -- return
		end tell
		
		delay 1
		
		-- Click create button
		tell document 1
			try
				do JavaScript "document.querySelector('button[data-qa=\"create_channel_button\"]').click();" in document 1
			on error
				tell application "System Events"
					key code 36 -- return
				end tell
			end try
		end tell
		
		delay 1
	end repeat
	
	display notification "Slack automation complete!" with title "Success" sound name "Glass"
	
end tell

-- Fallback instructions
display dialog "Automation attempted. If it didn't work completely, please:" & return & return & "1. Manually invite these 4 emails:" & return & "   • clawdianinan+ruth@gmail.com" & return & "   • clawdianinan+ngozi@gmail.com" & return & "   • clawdianinan+cypher@gmail.com" & return & "   • clawdianinan+morpheus@gmail.com" & return & return & "2. Create these 7 channels:" & return & "   • #development, #design, #documentation" & return & "   • #compliance, #operations, #testing, #security" buttons {"OK"} default button 1