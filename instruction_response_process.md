# Instruction Response Process & Email-to-iMessage Workflow
**Date:** March 2, 2026  
**Purpose:** Define clear process for handling instructions received via email with iMessage follow-up

## 1. Core Principle

**All emails from Temi to Clawdia must be treated with highest speed and priority.** When an instruction is received via email, an iMessage must be sent to confirm receipt and outline next actions.

## 2. Process Flow

### Phase 1: Email Receipt & Immediate Acknowledgment
```
[Email Received from Temi]
    ↓
[Within 5 minutes]
    ↓
[Send iMessage Acknowledgment]
    ↓
[Parse Instruction & Create Action Plan]
```

### Phase 2: Instruction Processing
```
[Analyze Email Content]
    ↓
[Identify: Task Type, Priority, Dependencies]
    ↓
[Create Execution Plan]
    ↓
[Outline Next Actions in iMessage]
```

### Phase 3: Execution & Updates
```
[Execute Plan]
    ↓
[Regular iMessage Status Updates]
    ↓
[Completion Notification]
    ↓
[Request Next Instructions]
```

## 3. iMessage Response Templates

### Template A: Immediate Acknowledgment
```
✅ Received: [Brief description of task]
📋 Next: [Outline of planned actions]
⏱️ ETA: [Estimated completion time]
❓ Questions: [Any clarifications needed?]
```

### Template B: Status Update
```
📊 Status Update: [Task Name]
✅ Completed: [What's done]
🔄 In Progress: [Current work]
⏭️ Next: [Next steps]
🕐 ETA: [Updated completion estimate]
```

### Template C: Completion Notification
```
🎯 Task Complete: [Task Name]
📁 Outputs: [Files/documents created]
📋 Summary: [Key results]
🤔 Next Actions: [Suggestions for follow-up]
```

## 4. Email Instruction Types & Response Protocols

### Type 1: Analysis/Review Requests
- **Examples:** Document review, legal analysis, strategy assessment
- **Response:** Acknowledge + outline analysis framework + request timeline
- **Output:** Analysis document with recommendations

### Type 2: Execution Tasks
- **Examples:** Send email, create document, research topic
- **Response:** Acknowledge + confirm understanding + execution plan
- **Output:** Completed task with confirmation

### Type 3: Information Requests
- **Examples:** Status update, data lookup, research question
- **Response:** Acknowledge + information gathering plan
- **Output:** Concise information response

### Type 4: Complex/Multi-step Projects
- **Examples:** System design, negotiation preparation, strategic planning
- **Response:** Acknowledge + project breakdown + phased approach
- **Output:** Project plan with milestones

## 5. Email Processing Rules

### Rule 1: Speed Priority
- **Target:** Respond via iMessage within 5 minutes of email receipt
- **Exception:** Quiet hours (23:00-08:00) - respond next morning unless marked urgent

### Rule 2: Clarity & Confirmation
- Always confirm understanding of instruction
- Ask clarifying questions immediately if unclear
- Never assume - verify requirements

### Rule 3: Progress Visibility
- Provide regular status updates via iMessage
- Flag blockers immediately
- Adjust timelines proactively

### Rule 4: Completion Standards
- Deliver outputs in requested format
- Include executive summary for complex outputs
- Request feedback on completion

## 6. Document Management for Email Tasks

### File Naming Convention
```
[TaskType]_[Description]_v[Version]_[YYYYMMDD].[ext]
```
**Examples:**
- `Analysis_IHS_Logo_Proposal_v1.2_20260302.docx`
- `Email_Draft_Response_IHS_v1.0_20260302.txt`
- `Research_Market_Analysis_v1.1_20260302.pdf`

### Version Control
- **v1.0:** Initial draft
- **v1.1:** Minor revisions
- **v2.0:** Major revisions/restructuring
- **FINAL:** Approved version

### Folder Structure
```
workspace/
├── email_tasks/
│   ├── 2026-03-02_IHS_Logo_Proposal/
│   │   ├── analysis/
│   │   ├── drafts/
│   │   ├── outputs/
│   │   └── references/
│   └── [Date]_[Task_Name]/
```

## 7. Email-to-iMessage Integration Tools

### Current Capabilities:
1. **Email Access:** fruitmail CLI for Apple Mail search
2. **iMessage Access:** imsg CLI available
3. **Automation:** Python scripts for workflow automation

### Needed Enhancements:
1. **Email Monitoring:** Script to watch for new emails from Temi
2. **Auto-Response:** Template-based iMessage responses
3. **Task Tracking:** Database for email-initiated tasks
4. **Status Dashboard:** Visual tracking of active tasks

## 8. Implementation Steps

### Phase 1: Manual Process (Immediate)
1. Monitor email manually for Temi instructions
2. Send iMessage using templates above
3. Track tasks in simple text file

### Phase 2: Semi-Automated (This Week)
1. Create email monitoring script
2. Build iMessage response templates
3. Implement basic task tracking

### Phase 3: Automated (Next 2 Weeks)
1. Full email-to-iMessage workflow automation
2. Task status dashboard
3. Integration with calendar/deadlines

## 9. Quality Metrics

### Response Time:
- **Excellent:** <5 minutes
- **Good:** 5-15 minutes  
- **Needs Improvement:** >15 minutes

### Completion Quality:
- **Excellent:** Exceeds requirements, proactive improvements
- **Good:** Meets all requirements
- **Needs Improvement:** Missing requirements or quality issues

### Communication:
- **Excellent:** Regular updates, clear status, proactive questions
- **Good:** Adequate updates, clear communication
- **Needs Improvement:** Infrequent updates, unclear status

## 10. Example Workflow: IHS Logo Proposal

**Email Received:** "Review IHS logo proposal and provide analysis"
```
[02:39] Email received
[02:41] iMessage sent: "✅ Received IHS logo proposal review request"
[02:45] iMessage: "📋 Next: 1) Download attachment 2) Review KWSG agreement 3) Legal analysis 4) Draft response"
[02:50] iMessage: "⏱️ ETA: Complete analysis by 03:15"
[03:05] iMessage: "📊 Status: Analysis complete, drafting email with findings"
[03:10] iMessage: "🎯 Task Complete: Analysis sent to your email. Key finding: DO NOT SIGN current agreement"
```

## 11. Next Actions

1. **Immediate:** Apply this process to current IHS logo proposal task
2. **Today:** Create email monitoring script foundation
3. **This Week:** Implement task tracking system
4. **Ongoing:** Refine templates and response times

**Status:** Process defined, ready for implementation starting with current IHS task.