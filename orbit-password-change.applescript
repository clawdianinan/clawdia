-- ORBIT Password Change Automation
-- This script automates changing the password for ORBIT platform

-- Configuration
set orbitUrl to "https://orbit2.iih.ng/login"
set currentEmail to "clawdia.ai@iih.ng"
set currentPassword to "N49eYXkwV6A9W$k"
set newPassword to "m!r@c#dFW3fezydV4PM"

-- Log function
on logMessage(message)
	do shell script "echo '\n" & message & "'"
end logMessage

-- Wait for page to load
on waitForPageLoad(tab)
	set loadComplete to false
	repeat 30 times
		try
			tell application "Safari"
				set pageState to do JavaScript "document.readyState" in tab
				if pageState is "complete" then
					set loadComplete to true
					exit repeat
				end if
			end tell
		end try
		delay 1
	end repeat
	return loadComplete
end waitForPageLoad

-- Find element by placeholder, name, or id
on findElement(selector, value)
	tell application "Safari"
		try
			-- Try by placeholder
			set element to do JavaScript "document.querySelector('[placeholder=\"" & value & "\"]')" in current tab of window 1
			if element is not missing value then return element
		end try
		
		try
			-- Try by name
			set element to do JavaScript "document.querySelector('[name=\"" & value & "\"]')" in current tab of window 1
			if element is not missing value then return element
		end try
		
		try
			-- Try by id
			set element to do JavaScript "document.getElementById('" & value & "')" in current tab of window 1
			if element is not missing value then return element
		end try
		
		return missing value
	end tell
end findElement

-- Main script
logMessage("Starting ORBIT password change automation...")
logMessage("URL: " & orbitUrl)
logMessage("Email: " & currentEmail)

try
	-- Open Safari and navigate to ORBIT
	tell application "Safari"
		activate
		make new document with properties {URL:orbitUrl}
		delay 2
		
		set currentWindow to window 1
		set currentTab to current tab of currentWindow
		
		-- Wait for page to load
		logMessage("Waiting for page to load...")
		my waitForPageLoad(currentTab)
		
		-- Look for login form
		delay 3
		
		-- Try to find email field
		logMessage("Looking for login form...")
		set emailField to my findElement("placeholder", "Email")
		if emailField is missing value then
			set emailField to my findElement("name", "email")
		end if
		
		if emailField is missing value then
			-- Try to find by inspecting the page
			set pageSource to do JavaScript "document.body.innerHTML" in currentTab
			if pageSource contains "Sign In" or pageSource contains "Login" then
				logMessage("Found login page, attempting to fill form...")
				
				-- Try to find email input using more generic selectors
				do JavaScript "
					// Try to find email input
					var emailInput = document.querySelector('input[type=\"email\"]');
					if (!emailInput) emailInput = document.querySelector('input[type=\"text\"][name*=\"email\"]');
					if (!emailInput) emailInput = document.querySelector('input[name*=\"email\"]');
					if (!emailInput) emailInput = document.querySelector('input[placeholder*=\"email\" i]');
					
					var passwordInput = document.querySelector('input[type=\"password\"]');
					var submitButton = document.querySelector('button[type=\"submit\"]') || document.querySelector('button:contains(\"Sign In\")') || document.querySelector('button:contains(\"Login\")');
					
					if (emailInput && passwordInput) {
						emailInput.value = '" & currentEmail & "';
						passwordInput.value = '" & currentPassword & "';
						if (submitButton) submitButton.click();
						'Form filled and submitted';
					} else {
						'Could not find form elements';
					}
				" in currentTab
				
				delay 3
				
				-- Check if login was successful
				set currentUrl to URL of currentTab
				if currentUrl does not contain "login" then
					logMessage("Login successful! Current URL: " & currentUrl)
					
					-- Now look for profile/settings menu to change password
					delay 2
					
					-- Try to find user menu or profile settings
					do JavaScript "
						// Look for user avatar, profile menu, or settings
						var userMenu = document.querySelector('[aria-label*=\"user\" i], [aria-label*=\"profile\" i], [aria-label*=\"account\" i]');
						var avatar = document.querySelector('img[alt*=\"user\" i], img[alt*=\"profile\" i]');
						var settingsLink = document.querySelector('a[href*=\"settings\" i], a[href*=\"profile\" i], a[href*=\"account\" i]');
						
						if (userMenu) userMenu.click();
						else if (avatar && avatar.closest('button')) avatar.closest('button').click();
						else if (settingsLink) settingsLink.click();
						else {
							// Try to find by text content
							var elements = document.querySelectorAll('button, a');
							for (var i = 0; i < elements.length; i++) {
								var text = elements[i].textContent.toLowerCase();
								if (text.includes('profile') || text.includes('settings') || text.includes('account')) {
									elements[i].click();
									break;
								}
							}
						}
					" in currentTab
					
					delay 2
					
					-- Look for password change section
					do JavaScript "
						// Look for password change fields
						var passwordSection = document.querySelector('*:contains(\"Change Password\")');
						var currentPassField = document.querySelector('input[type=\"password\"][placeholder*=\"current\" i]');
						var newPassField = document.querySelector('input[type=\"password\"][placeholder*=\"new\" i]');
						var confirmPassField = document.querySelector('input[type=\"password\"][placeholder*=\"confirm\" i]');
						
						if (currentPassField && newPassField) {
							currentPassField.value = '" & currentPassword & "';
							newPassField.value = '" & newPassword & "';
							if (confirmPassField) confirmPassField.value = '" & newPassword & "';
							
							// Find and click save button
							var saveButton = document.querySelector('button:contains(\"Save\")') || 
											document.querySelector('button:contains(\"Update\")') || 
											document.querySelector('button:contains(\"Change Password\")');
							if (saveButton) saveButton.click();
							'Password change form filled';
						} else {
							'Could not find password change form. Current page HTML: ' + document.body.innerHTML.substring(0, 1000);
						}
					" in currentTab
					
					delay 3
					
					-- Check for success message
					set pageContent to do JavaScript "document.body.textContent" in currentTab
					if pageContent contains "success" or pageContent contains "updated" or pageContent contains "changed" then
						logMessage("Password change appears successful!")
						logMessage("New password: " & newPassword)
					else
						logMessage("Password change may not have completed. Please check manually.")
						logMessage("Page content snippet: " & (text 1 thru 500 of pageContent))
					end if
					
				else
					logMessage("Login may have failed. Still on login page.")
					set pageContent to do JavaScript "document.body.innerHTML" in currentTab
					logMessage("Page HTML snippet: " & (text 1 thru 1000 of pageContent))
				end if
				
			else
				logMessage("Could not identify login page structure")
			end if
		else
			logMessage("Found email field directly")
		end if
		
	end tell
	
	logMessage("Automation completed. Please verify password change manually.")
	
on error errMsg
	logMessage("Error: " & errMsg)
	logMessage("Please change password manually at: " & orbitUrl)
end try

-- Keep Safari open for manual verification
logMessage("\nInstructions for manual verification:")
logMessage("1. Go to: " & orbitUrl)
logMessage("2. Login with: " & currentEmail & " / " & currentPassword)
logMessage("3. Navigate to profile/settings")
logMessage("4. Change password to: " & newPassword)
logMessage("5. Update MCP server configuration with new password")