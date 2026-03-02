#!/bin/bash

# Script to check temi (IIH) calendar events
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
    local apple_script='tell application "Calendar"
    -- Find the "temi" calendar
    set targetCalendar to null
    repeat with cal in calendars
        if name of cal is "temi" then
            set targetCalendar to cal
            exit repeat
        end if
    end repeat
    
    if targetCalendar is null then
        return "ERROR: Calendar named \"temi\" not found"
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
    
    -- Check for events in current week (next 7 days)
    set weekEvents to events of targetCalendar whose start date is greater than or equal to todayStart and start date is less than (todayStart + 7 * days)
    
    -- Build output
    set output to "CALENDAR:" & name of targetCalendar & "
"
    set output to output & "CHECK_TIME:" & (now as string) & "
"
    set output to output & "TODAY_COUNT:" & (count of todayEvents) & "
"
    set output to output & "NEXT48_COUNT:" & (count of next48Events) & "
"
    set output to output & "WEEK_COUNT:" & (count of weekEvents) & "
"
    
    -- Today'"'"'s events
    if (count of todayEvents) > 0 then
        set output to output & "TODAY_EVENTS:
"
        repeat with ev in todayEvents
            set output to output & "  • " & summary of ev & " (" & (time string of (start date of ev)) & ")"
            try
                if location of ev is not "" then
                    set output to output & " [" & location of ev & "]"
                end if
            on error
                -- No location
            end try
            set output to output & "
"
        end repeat
    end if
    
    -- Next 48 hours events
    if (count of next48Events) > 0 then
        set output to output & "NEXT48_EVENTS:
"
        repeat with ev in next48Events
            set output to output & "  • " & summary of ev & " (" & (start date of ev as string) & ")"
            try
                if location of ev is not "" then
                    set output to output & " [" & location of ev & "]"
                end if
            on error
                -- No location
            end try
            set output to output & "
"
        end repeat
    end if
    
    -- Current week events
    if (count of weekEvents) > 0 then
        set output to output & "WEEK_EVENTS:
"
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
                set output to output & "
" & dayString & ":
"
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
            set output to output & "
"
        end repeat
    end if
    
    return output
end tell'
    
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
    
    local in_today_events=false
    local in_next48_events=false
    local in_week_events=false
    
    while IFS= read -r line; do
        case "$line" in
            CALENDAR:*)
                calendar_name="${line#CALENDAR:}"
                log "INFO" "Calendar: $calendar_name"
                ;;
            CHECK_TIME:*)
                check_time="${line#CHECK_TIME:}"
                log "INFO" "Check time: $check_time"
                ;;
            TODAY_COUNT:*)
                today_count="${line#TODAY_COUNT:}"
                ;;
            NEXT48_COUNT:*)
                next48_count="${line#NEXT48_COUNT:}"
                ;;
            WEEK_COUNT:*)
                week_count="${line#WEEK_COUNT:}"
                ;;
            TODAY_EVENTS:*)
                in_today_events=true
                in_next48_events=false
                in_week_events=false
                log "INFO" "Today's events ($today_count):"
                ;;
            NEXT48_EVENTS:*)
                in_today_events=false
                in_next48_events=true
                in_week_events=false
                log "INFO" "Events in next 48 hours ($next48_count):"
                ;;
            WEEK_EVENTS:*)
                in_today_events=false
                in_next48_events=false
                in_week_events=true
                log "INFO" "Current week events ($week_count):"
                ;;
            *)
                if [[ "$line" == "  • "* ]]; then
                    if [ "$in_today_events" = true ]; then
                        log "INFO" "$line"
                    elif [ "$in_next48_events" = true ]; then
                        log "WARN" "URGENT: $line"
                    elif [ "$in_week_events" = true ]; then
                        if [[ "$line" == *":" ]]; then
                            log "INFO" "$line"
                        else
                            log "INFO" "$line"
                        fi
                    fi
                elif [[ -n "$line" ]]; then
                    if [ "$in_week_events" = true ]; then
                        log "INFO" "$line"
                    fi
                fi
                ;;
        esac
    done <<< "$data"
    
    # Log summary
    log "INFO" "=== Calendar Check Summary ==="
    log "INFO" "Today's events: $today_count"
    log "INFO" "Next 48 hours: $next48_count"
    log "INFO" "Current week: $week_count"
    
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