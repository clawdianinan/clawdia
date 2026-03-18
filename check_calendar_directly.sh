#!/bin/bash
# Direct macOS Calendar check

echo "=== DIRECT CALENDAR CHECK ==="
echo "Checking macOS Calendar for events TODAY ($(date '+%Y-%m-%d'))"
echo ""

# Method 1: AppleScript with more debugging
echo "Method 1: AppleScript query"
cat > /tmp/check_calendar.applescript << 'EOF'
tell application "Calendar"
    set todayStart to current date
    set time of todayStart to 0
    set todayEnd to todayStart + (1 * days)
    
    set allCalendars to name of every calendar
    set eventCount to 0
    
    log "Available calendars: " & allCalendars
    
    repeat with cal in calendars
        set calName to name of cal
        log "Checking calendar: " & calName
        
        try
            set theseEvents to (every event of cal whose start date ≥ todayStart and end date ≤ todayEnd)
            set eventCount to eventCount + (count of theseEvents)
            
            repeat with ev in theseEvents
                set startTime to start date of ev
                set summaryText to summary of ev
                log "FOUND: " & (time string of startTime) & " - " & summaryText & " (Calendar: " & calName & ")"
            end repeat
        on error errMsg
            log "Error checking calendar " & calName & ": " & errMsg
        end try
    end repeat
    
    if eventCount = 0 then
        return "No events found in any calendar"
    else
        return "Found " & eventCount & " events total"
    end if
end tell
EOF

osascript -e "$(cat /tmp/check_calendar.applescript)" 2>&1

echo ""
echo "=== Method 2: Calendar database check ==="

# Check if Calendar SQLite database exists
CALENDAR_DB="$HOME/Library/Calendars/Calendar Cache"
if [[ -f "$CALENDAR_DB" ]]; then
    echo "Calendar database found: $CALENDAR_DB"
    # This is more complex - would need proper SQL queries
    echo "Calendar database requires specialized SQL queries"
else
    echo "Calendar database not found at standard location"
fi

echo ""
echo "=== Method 3: Simple today events ==="

# Simple AppleScript to list all events today
osascript << 'EOF'
tell application "Calendar"
    set output to "Today's events:\n"
    set hasEvents to false
    
    repeat with cal in calendars
        set calName to name of cal
        try
            set todayEvents to (every event of cal where start date ≥ (current date) and start date < (current date) + 1 * days)
            if (count of todayEvents) > 0 then
                set hasEvents to true
                set output to output & "Calendar: " & calName & "\n"
                repeat with ev in todayEvents
                    set startTime to start date of ev
                    set endTime to end date of ev
                    set summaryText to summary of ev
                    set output to output & "  • " & (time string of startTime) & " - " & summaryText & "\n"
                end repeat
                set output to output & "\n"
            end if
        on error
            -- Skip calendars with errors
        end try
    end repeat
    
    if not hasEvents then
        set output to "No events found in any calendar for today"
    end if
    
    return output
end tell
EOF