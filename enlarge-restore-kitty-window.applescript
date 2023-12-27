tell application "System Events"
	set frontApp to first application process whose frontmost is true
	set frontWindow to first window of frontApp
	set {windowWidth, windowHeight} to size of frontWindow
end tell

if windowWidth is equal to 1792 # MacBook Pro 16" 2019
	tell application "System Events" to tell process "kitty" to set size of first window to {728, 1120}
else if windowWidth is equal to 1728 # MacBook Pro 16" 2023
	tell application "System Events" to tell process "kitty" to set size of first window to {702, 1085}
else if windowWidth is equal to 2305 then # Apple Studio Display
	tell application "System Events" to tell process "kitty" to set size of first window to {935, 1340}
else if windowWidth is equal to 728 # MacBook Pro 16" 2019
	tell application "System Events" to tell process "kitty" to set size of first window to {1792, 1120}
else if windowWidth is equal to 702 # MacBook Pro 16" 2023
	tell application "System Events" to tell process "kitty" to set size of first window to {1728, 1085}	
else if windowWidth is equal to 935 # Apple Studio Display
	tell application "System Events" to tell process "kitty" to set size of first window to {2305, 1340}
end if



