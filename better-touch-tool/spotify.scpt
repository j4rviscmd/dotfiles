set appPath to (POSIX path of (path to home folder)) & "Applications/Chrome Apps.localized/Spotify.app"
set appName to "Spotify"

tell application "System Events"
    if (count (every process whose name is appName)) > 0 then
        tell application appName to activate
    else
        do shell script "open " & quoted form of appPath
    end if
end tell