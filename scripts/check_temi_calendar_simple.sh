#!/bin/bash

# Simple script to check temi calendar events
# To be added to cron for regular checks

set -e

SCRIPT_NAME="check_temi_calendar.sh"
LOG_FILE="/Users/clawdia/.openclaw/workspace/logs/calendar-check.log"
WORKSPACE="/Users/clawdia/.openclaw/workspace"

# Create log directory if it doesn't exist
mkdir -p "$(dirname "$LOG_FILE")"

# Logging function
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# Main check function
check_temi_calendar() {
    log "INFO" "Starting temi calendar check..."
    
    # Use AppleScript to check temi calendar
    local apple_script=$(cat <<'END_APPLESCRIPT'
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
        return "ERROR: Calendar named 'temi' not found"
    end if
    
    -- Get current date and time
    set now to current date
    set todayStart to current date
    set time of todayStart to 0
    
    -- Check for events today
    set todayEvents to events of targetCalendar whose start date is greater than or equal to todayStart and start date is less than (todayStart + 1 * days)
    
    -- Check for events in next 48 hours
    set fortyEightHoursLater to now + (2 * days)
    set next48Events to events of targetCalendar whose start date is greater than or equal to now and start date is less than fortyEightHoursLater
    
    -- Check for events in next 7 days
    set weekEvents to events of targetCalendar whose start date is greater than or equal to todayStart and start date is less than (todayStart + 7 * days)
    
    -- Build simple output
    set output to "CALENDAR_NAME:" & name of targetCalendar & "
"
    set output to output & "CHECK_TIME:" & (now as string) & "
"
    set output to output & "TODAY_EVENTS_COUNT:" & (count of todayEvents) & "
"
    set output to output & "NEXT48_EVENTS_COUNT:" & (count of next48Events) & "
"
    set output to output & "WEEK_EVENTS_COUNT:" & (count of weekEvents) & "
"
    
    -- Today's events
    if (count of todayEvents) > 0 then
        set output to output & "TODAY_EVENTS_START
"
        repeat with ev in todayEvents
            set output to output & "EVENT:" & summary of ev & "|" & (start date of ev as string) & "|"
            try
                set output to output & (end date of ev as string)
            on error
                set output to output & "all day"
            end try
            set output to output & "|"
            try
                if location of ev is not "" then
                    set output to output & location of ev
                end if
            on error
                -- No location
            end try
            set output to output & "
"
        end repeat
        set output to output & "TODAY_EVENTS_END
"
    end if
    
    -- Next 48 hours events
    if (count of next48Events) > 0 then
        set output to output & "NEXT48_EVENTS_START
"
        repeat with ev in next48Events
            set output to output & "EVENT:" & summary of ev & "|" & (start date of ev as string) & "|"
            try
                set output to output & (end date of ev as string)
            on error
                set output to output & "all day"
            end try
            set output to output & "|"
            try
                if location of ev is not "" then
                    set output to output & location of ev
                end if
            on error
                -- No location
            end try
            set output to output & "
"
        end repeat
        set output to output & "NEXT48_EVENTS_END
"
    end if
    
    -- Week events overview
    if (count of weekEvents) > 0 then
        set output to output & "WEEK_EVENTS_START
"
        -- Sort by date
        set sortedEvents to {}
        repeat with ev in weekEvents
            set end of sortedEvents to ev
        end repeat
        
        repeat with ev in sortedEvents
            set evDate to start date of ev
            set output to output & "WEEK_EVENT:" & (date string of evDate) & "|"
            try
                if (time of evDate) is not 0 then
                    set output to output & (time string of evDate) & "|"
                else
                    set output to output & "all day|"
                end if
            on error
                set output to output & "|"
            end try
            set output to output & summary of ev & "
"
        end repeat
        set output to output & "WEEK_EVENTS_END
"
    end if
    
    return output
end tell
END_APPLESCRIPT
)
    
    local output
    output=$(osascript -e "$apple_script")
    echo "$output"
}

# Parse and process the calendar data
process_calendar_data() {
    local data="$1"
    
    local calendar_name=""
    local check_time=""
    local today_count=0
    local next48_count=0
    local week_count=0
    
    while IFS= read -r line; do
        case "$line" in
            CALENDAR_NAME:*)
                calendar_name="${line#CALENDAR_NAME:}"
                ;;
            CHECK_TIME:*)
                check_time="${line#CHECK_TIME:}"
                ;;
            TODAY_EVENTS_COUNT:*)
                today_count="${line#TODAY_EVENTS_COUNT:}"
                ;;
            NEXT48_EVENTS_COUNT:*)
                next48_count="${line#NEXT48_EVENTS_COUNT:}"
                ;;
            WEEK_EVENTS_COUNT:*)
                week_count="${line#WEEK_EVENTS_COUNT:}"
                ;;
            TODAY_EVENTS_START)
                log "INFO" "Today's events:"
                ;;
            EVENT:*)
                local event_data="${line#EVENT:}"
                local summary="${event_data%%|*}"
                local remaining="${event_data#*|}"
                local start_time="${remaining%%|*}"
                remaining="${remaining#*|}"
                local end_time="${remaining%%|*}"
                local location="${remaining#*|}"
                
                log "INFO" "  • $summary"
                log "INFO" "    Start: $start_time"
                log "INFO" "    End: $end_time"
                if [ -n "$location" ]; then
                    log "INFO" "    Location: $location"
                fi
                ;;
            NEXT48_EVENTS_START)
                log "INFO" "Events in next 48 hours:"
                ;;
            WEEK_EVENTS_START)
                log "INFO" "Events this week:"
                ;;
            WEEK_EVENT:*)
                local event_data="${line#WEEK_EVENT:}"
                local date="${event_data%%|*}"
                local remaining="${event_data#*|}"
                local time="${remaining%%|*}"
                local summary="${remaining#*|}"
                
                log "INFO" "  • $date $time: $summary"
                ;;
        esac
    done <<< "$data"
    
    # Log summary
    log "INFO" "Calendar check summary:"
    log "INFO" "  • Calendar: $calendar_name"
    log "INFO" "  • Check time: $check_time"
    log "INFO" "  • Today's events: $today_count"
    log "INFO" "  • Next 48 hours: $next48_count"
    log "INFO" "  • This week: $week_count"
    
    # HEARTBEAT check
    if [ "$next48_count" -eq 0 ]; then
        log "INFO" "HEARTBEAT_OK: No urgent calendar events in next 48 hours"
    else
        log "WARN" "HEARTBEAT_ALERT: $next48_count event(s) in next 48 hours require attention"
    fi
}

# Main execution
main() {
    log "INFO" "=== $SCRIPT_NAME started ==="
    
    # Check temi calendar
    local calendar_data
    calendar_data=$(check_temi_calendar)
    
    if echo "$calendar_data" | grep -q "ERROR:"; then
        log "ERROR" "Failed to check temi calendar: $calendar_data"
        exit 1
    fi
    
    # Process the data
    process_calendar_data "$calendar_data"
    
    log "INFO" "=== $SCRIPT_NAME completed ==="
}

# Run main function
main "$@"