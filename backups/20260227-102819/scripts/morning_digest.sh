#!/bin/bash
# Morning Digest Script
# Generates and sends morning digest with calendar, emails, todos, and reminders

set -e

WORKSPACE="/Users/clawdia/.openclaw/workspace"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M %Z')
DATE_FILE=$(date '+%Y-%m-%d')
DIGEST_FILE="$WORKSPACE/morning_digest_$DATE_FILE.txt"

echo "🌅 Generating Morning Digest for $TIMESTAMP..."

# Create digest header
cat > "$DIGEST_FILE" << EOF
🌅 MORNING DIGEST — $TIMESTAMP

EOF

# Calendar section
echo "📅 CALENDAR" >> "$DIGEST_FILE"
if which gog >/dev/null 2>&1 && gog auth list 2>/dev/null | grep -q "token"; then
    echo "• Checking Google Calendar..." >> "$DIGEST_FILE"
    gog calendar events --today --account default 2>/dev/null | head -10 >> "$DIGEST_FILE" || echo "• No calendar events found or error accessing" >> "$DIGEST_FILE"
else
    echo "• Google Calendar access not configured (gog requires setup)" >> "$DIGEST_FILE"
fi
echo "" >> "$DIGEST_FILE"

# Email section
echo "📧 EMAIL SUMMARY" >> "$DIGEST_FILE"
if [ -f "$WORKSPACE/scripts/check-emails.sh" ]; then
    echo "• Running email check..." >> "$DIGEST_FILE"
    "$WORKSPACE/scripts/check-emails.sh" --summary 2>&1 | grep -E "(PRIORITY|ALERT|IHS Towers)" | head -20 >> "$DIGEST_FILE" || echo "• Error checking emails" >> "$DIGEST_FILE"
else
    echo "• Email check script not found" >> "$DIGEST_FILE"
fi
echo "" >> "$DIGEST_FILE"

# Todo section
echo "✅ TODO LIST" >> "$DIGEST_FILE"
if [ -f "$WORKSPACE/scripts/todo.sh" ]; then
    echo "• Current todos:" >> "$DIGEST_FILE"
    bash "$WORKSPACE/scripts/todo.sh" list 2>/dev/null >> "$DIGEST_FILE" || echo "• Error accessing todo list" >> "$DIGEST_FILE"
else
    echo "• Todo script not found" >> "$DIGEST_FILE"
fi
echo "" >> "$DIGEST_FILE"

# Reminders section
echo "⏰ REMINDERS" >> "$DIGEST_FILE"
if which remindctl >/dev/null 2>&1; then
    echo "• Today's reminders:" >> "$DIGEST_FILE"
    remindctl today 2>/dev/null | head -10 >> "$DIGEST_FILE" || echo "• No reminders for today" >> "$DIGEST_FILE"
    echo "" >> "$DIGEST_FILE"
    echo "• Overdue reminders:" >> "$DIGEST_FILE"
    remindctl overdue 2>/dev/null | head -10 >> "$DIGEST_FILE" || echo "• No overdue reminders" >> "$DIGEST_FILE"
else
    echo "• remindctl not installed" >> "$DIGEST_FILE"
fi
echo "" >> "$DIGEST_FILE"

# Action items
echo "🚨 ACTION ITEMS" >> "$DIGEST_FILE"
echo "1. Review priority emails" >> "$DIGEST_FILE"
echo "2. Address overdue reminders" >> "$DIGEST_FILE"
echo "3. Check calendar for today's events" >> "$DIGEST_FILE"
echo "4. Update todo list as needed" >> "$DIGEST_FILE"
echo "" >> "$DIGEST_FILE"

# Footer
echo "📱 Delivery: iMessage" >> "$DIGEST_FILE"
echo "⏰ Generated: $TIMESTAMP" >> "$DIGEST_FILE"

echo "✅ Digest saved to: $DIGEST_FILE"
echo "📤 Sending via iMessage..."

# Send via iMessage (simplified - in production would use proper targeting)
if [ -f "$DIGEST_FILE" ]; then
    # This is a simplified version - actual sending would use OpenClaw's message tool
    echo "📱 iMessage delivery would be triggered here"
    echo "⚠️ Note: Actual iMessage delivery requires OpenClaw message tool integration"
fi

echo "🎉 Morning digest completed!"