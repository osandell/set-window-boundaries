-- OBS! The coordinate system differs depending on context. When we are querying
-- NSScreen the y axis starts from the bottom, while when setting the window
-- position it starts from the top.

use framework "Foundation"
use framework "AppKit"
use scripting additions

on getScreenSizes()
	set output to {}
	repeat with curScreen in current application's NSScreen's screens()
		set theFrame to curScreen's frame()
		set _size to item 2 of theFrame
		copy _size to the end of the output
	end repeat
	return output
end getScreenSizes

on getWorkAreaSizes()
	set output to {}
	repeat with curScreen in current application's NSScreen's screens()
		# We use visibleFrame() instead of frame() in order to account for the dock and menu bar
		set theFrame to curScreen's visibleFrame()
		set _size to item 2 of theFrame
		copy _size to the end of the output
	end repeat
	return output
end getWorkAreaSizes

on getDockHeight()
	set primaryScreen to item 1 of current application's NSScreen's screens()
	set theFrame to primaryScreen's visibleFrame()
	return item 2 of item 1 of theFrame
end getDockHeight

on getScreensCount()
	set screensCount to count of current application's NSScreen's screens()
	return screensCount
end getScreensCount

on setWindowBoundaries(appName, targetScreen, shouldHaveSpaceAround, xRatio, yRatio, xOffsetRatio, yOffsetRatio)
	set SPACE_AROUND_X_RATIO to 0.90
	set SPACE_AROUND_Y_RATIO to 0.93

	set screenSizes to getScreenSizes()
	set workAreaSizes to getWorkAreaSizes()
	set screensCount to getScreensCount()
	
	set primaryScreenHeight to item 2 of item 1 of screenSizes
	set primaryWorkAreaWidth to item 1 of item 1 of workAreaSizes
	set primaryWorkAreaHeight to item 2 of item 1 of workAreaSizes

	set dockHeight to getDockHeight()
	set menuBarHeight to primaryScreenHeight - (primaryWorkAreaHeight + dockHeight)

	if screensCount is 2 then
		set secondaryScreenHeight to item 2 of item 2 of screenSizes
		set secondaryWorkAreaWidth to item 1 of item 2 of workAreaSizes

		-- For some reason we don't get the correct work area height for the
		-- secondary screen. We need to manually subtract the menu bar height.
		set secondaryWorkAreaHeight to item 2 of item 2 of workAreaSizes - menuBarHeight 
	end if

	if (appName is "frontmost")
		try
			tell application (path to frontmost application as text)
				activate
				set windowBounds to bounds of window 1
				set currentXPosition to item 1 of windowBounds
			end tell
		on error
			tell application "System Events" to tell first application process whose frontmost is true
				tell window 1
					set winPosition to position
					set currentXPosition to item 1 of winPosition
				end tell
			end tell
		end try
	else 
		try
			tell application appName
				activate
				set windowBounds to bounds of window 1
				set currentXPosition to item 1 of windowBounds
			end tell
		on error
			tell application "System Events" to tell process appName
				tell window 1
					set winPosition to position
					set currentXPosition to item 1 of winPosition
				end tell
			end tell
		end try
	end if

	if currentXPosition > primaryWorkAreaWidth then
		set currentScreen to "secondary"
	else
		set currentScreen to "primary"
	end if
	
	if (currentScreen is "secondary" and targetScreen is "current") or (targetScreen is "secondary" and screensCount is 2) then
		if (shouldHaveSpaceAround is "true") then
			set appWidth to secondaryWorkAreaWidth * xRatio * SPACE_AROUND_X_RATIO
			set appHeight to secondaryWorkAreaHeight * yRatio * SPACE_AROUND_Y_RATIO
		else
			set appWidth to secondaryWorkAreaWidth * xRatio
			set appHeight to secondaryWorkAreaHeight * yRatio
		end if
		
		set xOffset to primaryWorkAreaWidth + secondaryWorkAreaWidth * xOffsetRatio
		
		set yOffset to secondaryWorkAreaHeight * yOffsetRatio
		
		set xPos to (secondaryWorkAreaWidth - appWidth) / 2 + xOffset
		set yPos to (secondaryWorkAreaHeight - appHeight) / 2 + menuBarHeight + yOffset
	else
	if (shouldHaveSpaceAround is "true" or (shouldHaveSpaceAround is "auto" and screensCount is 2)) then
			set appWidth to primaryWorkAreaWidth * xRatio * SPACE_AROUND_X_RATIO
			set appHeight to primaryWorkAreaHeight * yRatio * SPACE_AROUND_Y_RATIO
			set xOffset to primaryWorkAreaWidth * SPACE_AROUND_X_RATIO * xOffsetRatio
			set yOffset to primaryWorkAreaHeight * SPACE_AROUND_Y_RATIO * yOffsetRatio
		else
			set appWidth to primaryWorkAreaWidth * xRatio
			set appHeight to primaryWorkAreaHeight * yRatio
			set xOffset to primaryWorkAreaWidth * xOffsetRatio
			set yOffset to primaryWorkAreaHeight * yOffsetRatio
		end if
		
		set xPos to (primaryWorkAreaWidth - appWidth) / 2 + xOffset
		set yPos to (primaryWorkAreaHeight - appHeight) / 2 + menuBarHeight + yOffset
	end if

	if (appName is "frontmost")
		try
			tell application (path to frontmost application as text)
				activate
				if ((count of windows) = 0) then
					make new window with properties {bounds:{1920, 22, 960, 622}}
				else
					set bounds of window 1 to {xPos, yPos, xPos + appWidth, yPos + appHeight}
				end if
			end tell
		on error
			tell application "System Events" to tell first application process whose frontmost is true
				tell window 1
					set size to {appWidth, appHeight}
					set position to {xPos, yPos}
				
					# Set the size one more time in case we go from a small to big screen because in that case the 
					# size will be auto corrected after the first call. 
					set size to {appWidth, appHeight}
				end tell
			end tell
		end try
	else
		try
			tell application appName
				activate
				if ((count of windows) = 0) then
					make new window with properties {bounds:{1920, 22, 960, 622}}
				else
					set bounds of window 1 to {xPos, yPos, xPos + appWidth, yPos + appHeight}
				end if
			end tell
		on error
			tell application "System Events" to tell process appName
				tell window 1
					set size to {appWidth, appHeight}
					set position to {xPos, yPos}
				
					# Set the size one more time in case we go from a small to big screen because in that case the 
					# size will be auto corrected after the first call. 
					set size to {appWidth, appHeight}
				end tell
			end tell
		end try
	end if
	return
end setWindowBoundaries

on setWindowBoundariesMaximized(appName, targetScreen, shouldHaveSpaceAround)
	setWindowBoundaries(appName, targetScreen, shouldHaveSpaceAround, 1, 1, 0, 0)
end setWindowBoundariesMaximized

on setWindowBoundariesLeftHalf(appName, targetScreen, shouldHaveSpaceAround)
	setWindowBoundaries(appName, targetScreen, shouldHaveSpaceAround, 0.5, 1, -0.25, 0)
end setWindowBoundariesLeftHalf

on setWindowBoundariesRightHalf(appName, targetScreen, shouldHaveSpaceAround)
	setWindowBoundaries(appName, targetScreen, shouldHaveSpaceAround, 0.5, 1, 0.25, 0)
end setWindowBoundariesRightHalf

on replace_chars(this_text, search_string, replacement_string)
 set AppleScript's text item delimiters to the search_string
 set the item_list to every text item of this_text
 set AppleScript's text item delimiters to the replacement_string
 set this_text to the item_list as string
 set AppleScript's text item delimiters to ""
 return this_text
end replace_chars

on run argv
	set appName to item 1 of argv -- Process Name | "frontmost"
	set targetScreen to item 2 of argv 	-- "primary" | "secondary" | "current"
	set type to item 3 of argv
	set shouldHaveSpaceAround to item 4 of argv -- "true" | "false" | "auto"
	
	if type is "maximized" then
		setWindowBoundariesMaximized(appName, targetScreen, shouldHaveSpaceAround)
	else if type is "left-half" then
		setWindowBoundariesLeftHalf(appName, targetScreen, shouldHaveSpaceAround)
	else if type is "right-half" then
		setWindowBoundariesRightHalf(appName, targetScreen, shouldHaveSpaceAround)
	else if type is "custom" then

		# We need to replace "." with "," because locales that use "," as a decimal
		# separator will not work otherwise. On the other hand the English locale can
		# handle either one.
		set xRatio to replace_chars(item 5 of argv, ".", ",") as number 
		set yRatio to replace_chars(item 6 of argv, ".", ",") as number 
		set	xOffsetRatio to replace_chars(item 7 of argv, ".", ",") as number 
		set	yOffsetRatio to replace_chars(item 8 of argv, ".", ",") as number

		setWindowBoundaries(appName, targetScreen, shouldHaveSpaceAround, xRatio, yRatio, xOffsetRatio, yOffsetRatio)
	end if
end run
