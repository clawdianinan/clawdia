#!/bin/bash
# Evening Wrap-up Script
# Generates and sends evening wrap-up with accomplishments, remaining emails, and tomorrow preview

set -e

WORKSPACE="/Users/clawdia/.openclaw/workspace"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M %Z')
DATE_FILE=$(date '+%Y-%m-%d')
WRAPUP_FILE="$WORKSPACE/evening_wrapup_$DATE_FILE.txt"

echo "🌙 Generating Evening Wrap-up for $TIMESTAMP..."

# Create wrap-up header
cat > "$WRAPUP_FILE" << EOF
🌙 EVENING WRAP-UP — $TIMESTAMP

EOF

# Today's accomplishments section
echo "✅ TODAY'S ACCOMPLISHMENTS" >> "$WRAPUP_FILE"
echo "• Checking today's memory log..." >> "$WRAPUP_FILE"

# Read today's memory file for accomplishments
TODAY_MEMORY="$WORKSPACE/memory/$(date '+%Y-%m-%d').md"
if [ -f "$TODAY_MEMORY" ]; then
    # Extract key accomplishments from memory file
    grep -E "^(## |### |• |- |\* )" "$TODAY_MEMORY" | head -15 >> "$WRAPUP_FILE" || echo "• No detailed accomplishments recorded" >> "$WRAPUP_FILE"
else
    echo "• No memory file for today" >> "$WRAPUP_FILE"
fi
echo "" >> "$WRAPUP_FILE"

# Remaining emails section
echo "📧 REMAINING EMAILS TO ADDRESS" >> "$WRAPUP_FILE"
if [ -f "$WORKSPACE/scripts/consolidated-email-processor.sh" ]; then
    echo "• Checking for unread/urgent emails..." >> "$WRAPUP_FILE"
    # Run email check in summary mode
    EMAIL_CONTEXT_MODE="${EMAIL_CONTEXT_MODE:-iih}" "$WORKSPACE/scripts/consolidated-email-processor.sh" --summary 2>&1 | grep -E "(UNREAD|URGENT|PRIORITY|IHS Towers)" | head -10 >> "$WRAPUP_FILE" || echo "• No urgent emails pending" >> "$WRAPUP_FILE"
else
    echo "• Consolidated email processor not found" >> "$WRAPUP_FILE"
fi
echo "" >> "$WRAPUP_FILE"

# Tomorrow preview section
echo "📅 TOMORROW PREVIEW" >> "$WRAPUP_FILE"

# Check calendar for tomorrow
TOMORROW_DATE=$(date -v+1d '+%Y-%m-%d')
if which gog >/dev/null 2>&1 && gog auth list 2>/dev/null | grep -q "token"; then
    echo "• Calendar events for tomorrow ($TOMORROW_DATE):" >> "$WRAPUP_FILE"
    gog calendar events --date "$TOMORROW_DATE" --account default 2>/dev/null | head -8 >> "$WRAPUP_FILE" || echo "• No calendar events scheduled" >> "$WRAPUP_FILE"
else
    echo "• Google Calendar access not configured" >> "$WRAPUP_FILE"
fi
echo "" >> "$WRAPUP_FILE"

# Todo status
echo "✅ TODO STATUS" >> "$WRAPUP_FILE"
if [ -f "$WORKSPACE/scripts/todo.sh" ]; then
    echo "• Pending todos:" >> "$WRAPUP_FILE"
    bash "$WORKSPACE/scripts/todo.sh" list --status pending 2>/dev/null | head -8 >> "$WRAPUP_FILE" || echo "• No pending todos" >> "$WRAPUP_FILE"
else
    echo "• Todo script not found" >> "$WRAPUP_FILE"
fi
echo "" >> "$WRAPUP_FILE"

# Reminders for tomorrow
echo "⏰ TOMORROW'S REMINDERS" >> "$WRAPUP_FILE"
if which remindctl >/dev/null 2>&1; then
    echo "• Reminders for tomorrow:" >> "$WRAPUP_FILE"
    remindctl list --date "$TOMORROW_DATE" 2>/dev/null | head -8 >> "$WRAPUP_FILE" || echo "• No reminders for tomorrow" >> "$WRAPUP_FILE"
else
    echo "• remindctl not installed" >> "$WRAPUP_FILE"
fi
echo "" >> "$WRAPUP_FILE"

# Action items for tomorrow
echo "🚨 TOMORROW'S PRIORITIES" >> "$WRAPUP_FILE"
echo "1. Address any remaining urgent emails" >> "$WRAPUP_FILE"
echo "2. Review calendar events for the day" >> "$WRAPUP_FILE"
echo "3. Work on pending todo items" >> "$WRAPUP_FILE"
echo "4. Check for new reminders" >> "$WRAPUP_FILE"
echo "" >> "$WRAPUP_FILE"

# Footer
echo "📱 Delivery: iMessage" >> "$WRAPUP_FILE"
echo "⏰ Generated: $TIMESTAMP" >> "$WRAPUP_FILE"
echo "🌙 Good night!" >> "$WRAPUP_FILE"

echo "✅ Wrap-up saved to: $WRAPUP_FILE"
echo "📤 Sending via iMessage..."

# Display the wrap-up content
echo ""
echo "=== EVENING WRAP-UP CONTENT ==="
cat "$WRAPUP_FILE"
echo "=== END WRAP-UP ==="

echo "🎉 Evening wrap-up generated successfully!"