#!/bin/bash

# Script to check current week events in temi calendar
# Outputs to terminal (no dialog boxes)

set -e

echo "=== Current Week Events in temi (IIH) Calendar ==="
echo "Check time: $(date)"
echo ""

# Use AppleScript to get current week events
osascript <<'EOF'
tell application "Calendar"
    -- Find the "temi" calendar
    set targetCalendar to null
    repeat with cal in calendars
        if name of cal is "temi" then
            set targetCalendar to cal
            exit repeat
        end if
    end repeat
    
    if targetCalendar is null then
        log "ERROR: Calendar named 'temi' not found"
        return
    end if
    
    -- Get current date
    set todayStart to current date
    set time of todayStart to 0
    
    -- Check for events in current week (next 7 days)
    set weekEvents to events of targetCalendar whose start date is greater than or equal to todayStart and start date is less than (todayStart + 7 * days)
    
    set weekCount to count of weekEvents
    
    if weekCount = 0 then
        log "No events scheduled for the current week in temi calendar"
        return
    end if
    
    -- Build output
    set output to "Current Week Events in temi calendar (" & weekCount & " events):" & return & return
    
    -- Sort by date
    set sortedEvents to {}
    repeat with ev in weekEvents
        set end of sortedEvents to ev
    end repeat
    
    -- Simple sort by date
    repeat with i from 1 to (count of sortedEvents) - 1
        repeat with j from 1 to (count of sortedEvents) - i
            set ev1 to item j of sortedEvents
            set ev2 to item (j + 1) of sortedEvents
            if start date of ev1 > start date of ev2 then
                set item j of sortedEvents to ev2
                set item (j + 1) of sortedEvents to ev1
            end if
        end repeat
    end repeat
    
    set currentDay to ""
    repeat with ev in sortedEvents
        set evDate to start date of ev
        set dayString to (date string of evDate)
        
        if dayString is not currentDay then
            set currentDay to dayString
            set output to output & "📅 " & dayString & ":" & return
        end if
        
        set output to output & "  • " & summary of ev
        try
            if (time of evDate) is not 0 then
                set output to output & " at " & (time string of evDate)
            else
                set output to output & " (all day)"
            end if
        on error
            set output to output & " (time not available)"
        end try
        try
            if location of ev is not "" then
                set output to output & " [" & location of ev & "]"
            end if
        on error
            -- No location
        end try
        set output to output & return
    end repeat
    
    -- Also check for events in next 48 hours
    set now to current date
    set fortyEightHoursLater to now + (2 * days)
    set next48Events to events of targetCalendar whose start date is greater than or equal to now and start date is less than fortyEightHoursLater
    
    set next48Count to count of next48Events
    
    set output to output & return & "=== Next 48 Hours ===" & return
    if next48Count = 0 then
        set output to output & "No events in the next 48 hours" & return
    else
        set output to output & "Events in next 48 hours (" & next48Count & "):" & return
        repeat with ev in next48Events
            set output to output & "⚠️  " & summary of ev & " (" & (start date of ev as string) & ")" & return
        end repeat
    end if
    
    log output
end tell

on log(message)
    do shell script "echo " & quoted form of message
end log
EOF