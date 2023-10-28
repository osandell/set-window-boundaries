tell application "System Events"
	set frontApp to first application process whose frontmost is true
	set frontWindow to first window of frontApp
	set {windowWidth, windowHeight} to size of frontWindow
end tell

tell application "Finder"
	set screenResolution to bounds of window of desktop
	set screenWidth to item 3 of screenResolution
end tell

if windowWidth is equal to screenWidth then
	if screenWidth is equal to 1792 then
		tell application "System Events" to tell process "kitty" to set size of first window to {736, 1120}
	else
		tell application "System Events" to tell process "kitty" to set size of first window to {936, 1420} --fix
	end if
else
	if screenWidth is equal to 1792 then
		tell application "System Events" to tell process "kitty" to set size of first window to {1792, 1120}
	else
		tell application "System Events" to tell process "kitty" to set size of first window to {2000, 1420} --fix
	end if
end if



