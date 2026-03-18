#!/bin/bash
# Establish Communication Protocols in EXISTING Slack
# Sets up daily standups, update procedures, and approval workflow

echo "📢 Establishing Communication Protocols for PRDForge project..."
echo ""

# Check for Slack token
if [ -f slack-setup-script.sh ]; then
  SLACK_TOKEN=$(grep 'TOKEN=' slack-setup-script.sh | head -1 | cut -d'"' -f2)
  if [ -n "$SLACK_TOKEN" ]; then
    echo "✅ Found Slack token"
  else
    echo "❌ Error: Could not extract Slack token from slack-setup-script.sh"
    exit 1
  fi
else
  echo "❌ Error: slack-setup-script.sh not found"
  exit 1
fi

echo ""
echo "📋 **Protocol Configuration:**"
echo "• Main Channel: #prdforge-launch"
echo "• Daily Standup: 8:00 AM WAT (Africa/Lagos)"
echo "• Approval Workflow: Jira → Slack with @temikolawole mentions"
echo "• Response Times: Defined per message type"
echo ""

echo "🚀 **Step 1: Post Daily Standup Protocol**"
echo ""
echo "Posting standup protocol to #prdforge-launch..."

STANDUP_PROTOCOL='🚀 *Daily Standup Protocol - Effective Immediately*

**Time:** 8:00 AM WAT (Africa/Lagos) daily
**Channel:** #prdforge-launch
**Format:** Structured update (see template below)
**Duration:** 15 minutes (async)

---

**📋 STANDUP TEMPLATE:**
```
[Agent] Daily Update - YYYY-MM-DD

Yesterday:
• Completed: [Task 1] (DEV-XXX)
• Completed: [Task 2] (DEV-YYY)
• Progress: [Task 3] (DEV-ZZZ) - X% complete

Today:
• Priority 1: [Task A] (DEV-AAA)
• Priority 2: [Task B] (DEV-BBB)
• If time: [Task C] (DEV-CCC)

Blockers:
• [Blocking issue] - Need [resource/person] for resolution
• [Decision needed] - @agent for input

Metrics:
• Tickets completed yesterday: X
• Current backlog: Y tickets
• Blockers resolved: Z
```

---

**👥 RESPONSE PROTOCOL:**
• **Clawdia:** Coordinates, removes blockers, provides direction
• **Other agents:** React with ✅ to acknowledge, ❓ for questions
• **Blockers:** Immediate follow-up in thread with relevant agents

---

**🎯 FIRST STANDUP: Tomorrow at 8:00 AM WAT**
All agents expected to post their updates using the template above.

Let'\''s build with clarity and momentum! 💪'

curl -s -X POST "https://slack.com/api/chat.postMessage" \
  -H "Authorization: Bearer $SLACK_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"channel\":\"#prdforge-launch\",\"text\":\"$STANDUP_PROTOCOL\"}" | grep -q '"ok":true' && echo "✅ Standup protocol posted" || echo "❌ Failed to post standup protocol"

echo ""
echo "🚀 **Step 2: Post Channel-Specific Protocols**"
echo ""

CHANNEL_PROTOCOLS='
**📢 CHANNEL-SPECIFIC PROTOCOLS**

**#prdforge-launch (Main Channel)**
• Daily standups only in main thread
• Major milestones and completions
• Cross-team dependencies
• Approval requests
• Project-wide announcements
• *Do not post:* Detailed technical discussions (use team channels)

**Team Channels (#development, #design, etc.)**
• Technical discussions
• Code reviews
• Design iterations
• Team-specific updates
• File sharing for team work
• *Use threads* for related discussions

**Integration Channels**
• Automated notifications only
• Use threads for discussion on specific notifications
• Keep main channel clean for automated messages
'

curl -s -X POST "https://slack.com/api/chat.postMessage" \
  -H "Authorization: Bearer $SLACK_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"channel\":\"#prdforge-launch\",\"text\":\"$CHANNEL_PROTOCOLS\"}" | grep -q '"ok":true' && echo "✅ Channel protocols posted" || echo "❌ Failed to post channel protocols"

echo ""
echo "🚀 **Step 3: Post Message Formatting Standards**"
echo ""

FORMATTING_STANDARDS='
**🎨 MESSAGE FORMATTING STANDARDS**

**@Mention Protocol:**
• @temikolawole: Only for approval requests in #prdforge-launch
• @agent: For direct questions or assignments
• @channel: Only for critical, time-sensitive announcements
• @here: For important but not critical team notifications

**Emoji Usage Guide:**
• ✅ Checkmark: Task completion, approval
• ❌ Cross: Task failure, rejection
• ⚠️ Warning: Important notice, blocker
• 🚨 Siren: Critical issue, immediate attention needed
• 🔄 Arrows: Status change, update
• 💬 Speech: Comment, discussion point
• 📊 Chart: Metrics, data update
• 🎉 Party: Celebration, major milestone
• 🔍 Magnify: Investigation, research
• ⏳ Hourglass: Waiting, pending

**Thread Management:**
• Use threads for follow-up questions
• Use threads for detailed discussions
• Use threads for file sharing related to specific tasks
• Use threads for debugging sessions
• Mark threads with ✅ when resolved
'

curl -s -X POST "https://slack.com/api/chat.postMessage" \
  -H "Authorization: Bearer $SLACK_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"channel\":\"#prdforge-launch\",\"text\":\"$FORMATTING_STANDARDS\"}" | grep -q '"ok":true' && echo "✅ Formatting standards posted" || echo "❌ Failed to post formatting standards"

echo ""
echo "🚀 **Step 4: Post Approval Workflow Protocol**"
echo ""

APPROVAL_PROTOCOL='
**✅ APPROVAL WORKFLOW PROTOCOL**

**Standard Process:**
1. **Agent completes work** → Updates Jira ticket status to "Review"
2. **Clawdia reviews** → Either requests changes OR marks "Ready for Approval"
3. **If "Ready for Approval"** → @temikolawole mentioned in #prdforge-launch
4. **Temi approves** → Reviews in Jira, approves (status → "Approved")
5. **Slack notification** → "✅ [DEV-XXX] approved by temikolawole"
6. **Implementation** → Agent implements if needed, updates status to "Done"

**Approval Message Template:**
```
⚠️ Approval Needed: [DEV-XXX] Task Title

Summary:
• Completed: [Brief description of work]
• Impact: [What this enables/fixes]
• Testing: [Validation performed]
• Documentation: [Updates made]

Requested by: @agent
Reviewer: @clawdia (approved for technical review)

@temikolawole Please review and approve in Jira.
```

**Timeline Expectations:**
• Approval requests: Acknowledge within 24 hours
• Approval decisions: Within 48 hours (escalate after)
• Implementation after approval: Within agreed timeline
'

curl -s -X POST "https://slack.com/api/chat.postMessage" \
  -H "Authorization: Bearer $SLACK_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"channel\":\"#prdforge-launch\",\"text\":\"$APPROVAL_PROTOCOL\"}" | grep -q '"ok":true' && echo "✅ Approval protocol posted" || echo "❌ Failed to post approval protocol"

echo ""
echo "🚀 **Step 5: Post Emergency/Escalation Protocol**"
echo ""

ESCALATION_PROTOCOL='
**🚨 EMERGENCY/ESCALATION PROTOCOL**

**Priority Levels:**
• **P1 (Critical):** System down, security breach, data loss
• **P2 (High):** Major feature broken, significant user impact
• **P3 (Medium):** Minor issues, non-critical bugs
• **P4 (Low):** Enhancements, minor improvements

**Escalation Path:**
```
P1/P2 Issues:
1. Immediate post in #prdforge-launch with 🚨
2. @mention relevant agents + @clawdia
3. Create Jira ticket with "Critical" priority
4. Continuous updates in thread until resolved

P3/P4 Issues:
1. Post in relevant team channel
2. Create Jira ticket
3. Discuss in daily standup for prioritization
```

**Response Time Expectations:**
• @mention in channel: 2 hours during work hours
• Direct message: 4 hours during work hours
• Thread responses: 24 hours
• Approval requests: 48 hours (escalate after)

**Out of Office Protocol:**
• Post in #prdforge-launch thread
• Designate backup agent
• Set Slack status with return date
'

curl -s -X POST "https://slack.com/api/chat.postMessage" \
  -H "Authorization: Bearer $SLACK_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"channel\":\"#prdforge-launch\",\"text\":\"$ESCALATION_PROTOCOL\"}" | grep -q '"ok":true' && echo "✅ Escalation protocol posted" || echo "❌ Failed to post escalation protocol"

echo ""
echo "🚀 **Step 6: Create Pinned Protocol Summary**"
echo ""

PINNED_SUMMARY='📚 *PRDForge Communication Protocols - Quick Reference*

**Essential Links:**
• Daily Standup Template: See pinned message
• Approval Workflow: See pinned message
• Emergency Protocol: See pinned message

**Key Times:**
• Daily Standup: 8:00 AM WAT (Africa/Lagos)
• Work Hours: 8:00 AM - 6:00 PM WAT
• Response Expectation: 2 hours for @mentions

**Quick Actions:**
• Need approval? Use template and @temikolawole
• Critical issue? Post with 🚨 and @mention relevant agents
• Daily update? Use standup template by 8:00 AM
• Team discussion? Use appropriate team channel

**Support:**
• Process questions: @clawdia
• Technical issues: Relevant team channel
• Integration problems: #operations channel
'

# Post and pin the summary
PIN_RESPONSE=$(curl -s -X POST "https://slack.com/api/chat.postMessage" \
  -H "Authorization: Bearer $SLACK_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"channel\":\"#prdforge-launch\",\"text\":\"$PINNED_SUMMARY\"}")

if echo "$PIN_RESPONSE" | grep -q '"ok":true'; then
  echo "✅ Protocol summary posted"
  # Extract timestamp for pinning
  TS=$(echo "$PIN_RESPONSE" | grep -o '"ts":"[^"]*"' | cut -d'"' -f4)
  if [ -n "$TS" ]; then
    curl -s -X POST "https://slack.com/api/pins.add" \
      -H "Authorization: Bearer $SLACK_TOKEN" \
      -H "Content-Type: application/json" \
      -d "{\"channel\":\"#prdforge-launch\",\"timestamp\":\"$TS\"}" | grep -q '"ok":true' && echo "✅ Protocol summary pinned" || echo "❌ Failed to pin summary"
  fi
else
  echo "❌ Failed to post protocol summary"
fi

echo ""
echo "🔧 **Creating Agent Quick Reference Card**"
cat > agent-communication-quickref.md << 'EOF'
# Agent Communication Quick Reference

## Daily Standup (8:00 AM WAT)
**Channel:** #prdforge-launch
**Template:**
```
[Agent] Daily Update - YYYY-MM-DD

Yesterday:
• Completed: [Task 1] (DEV-XXX)
• Completed: [Task 2] (DEV-YYY)

Today:
• Priority 1: [Task A] (DEV-AAA)
• Priority 2: [Task B] (DEV-BBB)

Blockers:
• [Issue] - Need [help]

Metrics:
• Tickets completed: X
```
**Response:** ✅ to acknowledge, ❓ for questions

## Approval Requests
**When:** Work complete, reviewed by Clawdia
**Channel:** #prdforge-launch
**Template:**
```
⚠️ Approval Needed: [DEV-XXX] Task Title

Summary: [Brief description]
Impact: [What this enables]
Testing: [Validation done]

@temikolawole Please review and approve.
```
**Timeline:** 48 hours for response

## Emergency Issues
**P1/P2 (Critical/High):**
1. Post in #prdforge-launch with 🚨
2. @mention relevant agents + @clawdia
3. Create Jira ticket (Critical priority)
4. Continuous updates in thread

**P3/P4 (Medium/Low):**
1. Post in team channel
2. Create Jira ticket
3. Discuss in standup

## Channel Usage
• **#prdforge-launch:** Standups, approvals, major announcements
• **Team channels:** Technical work, team discussions
• **Threads:** Follow-ups, detailed discussions, file sharing

## Response Times
• @mention in channel: 2 hours
• Direct message: 4 hours
• Thread responses: 24 hours
• Approval requests: 48 hours

## Quality Standards
• **Clarity:** Clear subject, concise message
• **Actionability:** Include specific requests
• **Completeness:** Provide necessary context
• **Professionalism:** Maintain professional tone
EOF

echo "✅ Created agent quick reference: agent-communication-quickref.md"
echo ""
echo "📊 **Monitoring & Compliance Setup**"
echo ""
echo "**Metrics to Track:**"
echo "• Daily: Standup participation rate"
echo "• Weekly: Response time averages"
echo "• Monthly: Protocol compliance review"
echo ""
echo "**Compliance Checks:**"
echo "• Weekly: Random sample of messages"
echo "• Monthly: Full channel audit"
echo "• Quarterly: Protocol effectiveness review"
echo ""
echo "**Continuous Improvement:**"
echo "• Monthly retrospective on communication"
echo "• Quarterly protocol revision"
echo "• Annual refresh for all agents"
echo ""

echo "🎉 Communication Protocols Established!"
echo ""
echo "**What'\''s Been Set Up:**"
echo "✅ Daily standup protocol (8:00 AM WAT)"
echo "✅ Channel-specific posting rules"
echo "✅ Message formatting standards"
echo "✅ Approval workflow protocol"
echo "✅ Emergency/escalation protocol"
echo "✅ Pinned protocol summary"
echo "✅ Agent quick reference card"
echo ""
echo "**Next Steps:**"
echo "1. All agents review protocols in #prdforge-launch"
echo "2. First standup: Tomorrow at 8:00 AM WAT"
echo "3. Begin using approval workflow immediately"
echo "4. Report any protocol issues to #operations"
echo ""
echo "**Success Criteria:**"
echo "✅ Consistent daily standup participation"
echo "✅ Clear approval workflow with @temikolawole mentions"
echo "✅ Appropriate channel usage by all agents"
echo "✅ Timely responses to @mentions and requests"
echo "✅ Effective escalation for critical issues"