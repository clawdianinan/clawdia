# Slack Communication Protocols

## Overview
This document establishes standardized communication protocols for the PRDForge project team within Slack, ensuring efficient, clear, and consistent information flow across all agents.

## Daily Communication Structure

### 1. Daily Standup (8:00 AM WAT)
- **Channel**: `#prdforge-launch`
- **Frequency**: Daily, Monday-Friday
- **Duration**: 15 minutes (async)
- **Format**: Structured update format

#### Standup Format:
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

#### Response Protocol:
- **Clawdia**: Coordinates, removes blockers, provides direction
- **Other agents**: React with ✅ to acknowledge, ❓ for questions
- **Blockers**: Immediate follow-up in thread with relevant agents

### 2. Task Completion Announcements
- **When**: Immediately upon task completion
- **Channel**: Relevant team channel + `#prdforge-launch` for major milestones
- **Format**: 
  ```
  ✅ Task Completed: [DEV-XXX] Task Title
  Completed by: @agent
  Time: X hours/days
  Impact: [Brief description of impact]
  Next: [Next task or dependency]
  ```

### 3. Blocker/Issue Reporting
- **When**: As soon as blocker identified
- **Channel**: Relevant team channel (thread in standup for visibility)
- **Format**:
  ```
  🚨 Blocker: [Brief description]
  Ticket: DEV-XXX (if applicable)
  Impact: [What's blocked]
  Needed: [Specific help/resource]
  Timeline: [Urgency - High/Medium/Low]
  @mention relevant agents for help
  ```

## Channel-Specific Protocols

### `#prdforge-launch` (Main Channel)
- **Purpose**: Cross-team coordination, major announcements
- **Posting Rules**:
  - Daily standups only in main thread
  - Major milestones and completions
  - Cross-team dependencies
  - Approval requests
  - Project-wide announcements
- **Do Not Post**:
  - Detailed technical discussions (use team channels)
  - Long debugging sessions
  - File sharing (use threads or team channels)

### Team Channels (`#development`, `#design`, etc.)
- **Purpose**: Team-specific work coordination
- **Posting Rules**:
  - Technical discussions
  - Code reviews
  - Design iterations
  - Team-specific updates
  - File sharing for team work
- **Thread Usage**: Use threads for related discussions to keep channel clean

### Integration Channels (`jira-*`, `github-*`)
- **Purpose**: Automated notifications only
- **Posting Rules**:
  - No manual posts (integration only)
  - Use threads for discussion on specific notifications
  - Keep main channel clean for automated messages

## Message Formatting Standards

### 1. @Mention Protocol
- **@temikolawole**: Only for approval requests in `#prdforge-launch`
- **@agent**: For direct questions or assignments
- **@channel**: Only for critical, time-sensitive announcements
- **@here**: For important but not critical team notifications

### 2. Emoji Usage Guide
- ✅ **Checkmark**: Task completion, approval
- ❌ **Cross**: Task failure, rejection
- ⚠️ **Warning**: Important notice, blocker
- 🚨 **Siren**: Critical issue, immediate attention needed
- 🔄 **Arrows**: Status change, update
- 💬 **Speech**: Comment, discussion point
- 📊 **Chart**: Metrics, data update
- 🎉 **Party**: Celebration, major milestone
- 🔍 **Magnify**: Investigation, research
- ⏳ **Hourglass**: Waiting, pending

### 3. Thread Management
- **When to use threads**:
  - Follow-up questions on a message
  - Detailed discussion on a topic
  - File sharing related to a specific task
  - Debugging sessions
- **Thread naming**: Use descriptive titles
- **Thread resolution**: Mark with ✅ when resolved

## Approval Workflow Protocol

### Standard Approval Process:
```
Step 1: Agent completes work
  → Updates Jira ticket status to "Review"
  → Posts in relevant channel: "Ready for review: [DEV-XXX]"

Step 2: Clawdia reviews
  → Reviews in Jira/Slack thread
  → Either: Requests changes OR marks "Ready for Approval"
  → If "Ready for Approval": @temikolawole in #prdforge-launch

Step 3: Temi approves
  → Reviews in Jira
  → Approves (changes status to "Approved")
  → Slack notification: "✅ [DEV-XXX] approved by temikolawole"

Step 4: Implementation
  → Agent implements if production change needed
  → Updates status to "Done" when complete
```

### Approval Message Template:
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

## Emergency/Escalation Protocol

### Priority Levels:
- **P1 (Critical)**: System down, security breach, data loss
- **P2 (High)**: Major feature broken, significant user impact
- **P3 (Medium)**: Minor issues, non-critical bugs
- **P4 (Low)**: Enhancements, minor improvements

### Escalation Path:
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

## File Sharing Protocol

### Acceptable File Types:
- **Documents**: .md, .txt, .pdf, .docx
- **Images**: .png, .jpg, .svg (for design review)
- **Code**: Snippets in messages, files in threads
- **Data**: .csv, .json (small files only)

### File Size Limits:
- **Slack upload**: < 1GB per file
- **Preferred**: < 100MB for quick loading
- **Large files**: Use Google Drive with Slack integration

### Organization:
- **Naming**: `YYYY-MM-DD_Description_Agent.ext`
- **Location**: Relevant channel threads
- **Cleanup**: Archive old files monthly

## Meeting Coordination

### Scheduled Meetings:
- **Weekly Planning**: Mondays 9:00 AM (30 min)
- **Retrospective**: Fridays 4:00 PM (30 min)
- **Ad-hoc**: Schedule in thread with poll

### Meeting Protocol:
1. **Announcement**: 24 hours in advance in `#prdforge-launch`
2. **Agenda**: Posted in thread day before
3. **Notes**: Taken by designated notetaker
4. **Action items**: Posted in thread after meeting
5. **Follow-up**: Track action items in Jira

## Response Time Expectations

### Expected Response Times:
- **@mention in channel**: 2 hours during work hours
- **Direct message**: 4 hours during work hours
- **Thread responses**: 24 hours
- **Approval requests**: 48 hours (escalate after)

### Out of Office Protocol:
- **Notification**: Post in `#prdforge-launch` thread
- **Coverage**: Designate backup agent
- **Auto-response**: Set Slack status with return date

## Quality Standards

### Message Quality:
- **Clarity**: Clear subject, concise message
- **Actionability**: Include specific requests or next steps
- **Completeness**: Provide necessary context
- **Professionalism**: Maintain professional tone

### Channel Hygiene:
- **Cleanup**: Archive resolved threads weekly
- **Organization**: Use appropriate channels
- **Noise reduction**: Move detailed discussions to threads

## Training and Onboarding

### New Agent Onboarding:
1. **Day 1**: Add to channels, share this protocol
2. **Day 2**: Shadow standup, observe communication
3. **Day 3**: First standup post with mentor review
4. **Week 1**: Full participation with support

### Protocol Updates:
- **Announcement**: In `#prdforge-launch` with 📢
- **Training**: Quick sync if major changes
- **Documentation**: Update this protocol immediately

## Monitoring and Compliance

### Metrics Tracking:
- **Daily**: Standup participation rate
- **Weekly**: Response time averages
- **Monthly**: Protocol compliance review

### Compliance Checks:
- **Weekly**: Random sample of messages
- **Monthly**: Full channel audit
- **Quarterly**: Protocol effectiveness review

### Continuous Improvement:
- **Feedback**: Monthly retrospective on communication
- **Updates**: Quarterly protocol revision
- **Training**: Annual refresh for all agents

## Troubleshooting Communication Issues

### Common Issues:
1. **Missed messages**: Check notification settings, use @mentions appropriately
2. **Channel overload**: Move to threads, create new channels if needed
3. **Response delays**: Escalate via DM, then @mention in channel
4. **Misunderstandings**: Clarify in thread, schedule quick call if complex

### Resolution Process:
1. **Identify**: Pinpoint communication breakdown
2. **Discuss**: Address in relevant channel thread
3. **Resolve**: Agree on solution, update protocol if needed
4. **Document**: Note resolution for future reference

---

**Last Updated**: 2026-03-18  
**Version**: 1.0  
**Author**: Shuri (Operations Analysis Specialist)  
**Status**: Active  
**Jira Ticket**: DEV-26 (Slack Project Integration)