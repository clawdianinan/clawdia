# Incident Update Email Template

**Template Name:** Incident Status Update
**Purpose:** Provide updates to customers during an incident
**Trigger:** Scheduled updates during active incident
**Timing:** Hourly for SEV-1, every 2 hours for SEV-2, daily for SEV-3

## HTML Version

```html
<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background-color: #fff3cd; padding: 20px; text-align: center; border-left: 4px solid #ffc107; }
        .severity-badge { display: inline-block; padding: 4px 12px; border-radius: 12px; font-size: 12px; font-weight: bold; }
        .severity-critical { background-color: #f8d7da; color: #721c24; }
        .severity-high { background-color: #fff3cd; color: #856404; }
        .severity-medium { background-color: #d1ecf1; color: #0c5460; }
        .severity-low { background-color: #d4edda; color: #155724; }
        .content { padding: 20px; }
        .status-timeline { margin: 20px 0; padding: 15px; background-color: #f8f9fa; border-radius: 4px; }
        .timeline-item { margin-bottom: 10px; padding-bottom: 10px; border-bottom: 1px solid #dee2e6; }
        .timeline-time { font-weight: bold; color: #6c757d; }
        .footer { margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee; font-size: 12px; color: #666; }
        .button { display: inline-block; padding: 8px 16px; background-color: #6c757d; color: white; text-decoration: none; border-radius: 4px; font-size: 14px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h2>Incident Update: [Incident Title]</h2>
            <span class="severity-badge severity-[critical/high/medium/low]">[SEV-1/2/3/4]</span>
            <p>Update #[Update Number] | [Current Date/Time]</p>
        </div>
        
        <div class="content">
            <h3>Current Status</h3>
            <p><strong>Status:</strong> [Investigating/Identified/Monitoring/Resolved]</p>
            <p><strong>Impact:</strong> [Description of impact on services/users]</p>
            <p><strong>Next Update:</strong> [Date/Time of next scheduled update]</p>
            
            <h3>Latest Update</h3>
            <p>[Detailed description of latest developments, investigation progress, or resolution steps]</p>
            
            <div class="status-timeline">
                <h4>Incident Timeline</h4>
                
                <div class="timeline-item">
                    <span class="timeline-time">[Time]</span> - [Event description]
                </div>
                <div class="timeline-item">
                    <span class="timeline-time">[Time]</span> - [Event description]
                </div>
                <div class="timeline-item">
                    <span class="timeline-time">[Time]</span> - [Event description]
                </div>
                <!-- Add more timeline items as needed -->
            </div>
            
            <h3>Affected Services</h3>
            <ul>
                <li>[Service 1] - [Status]</li>
                <li>[Service 2] - [Status]</li>
                <li>[Service 3] - [Status]</li>
            </ul>
            
            <h3>Workarounds (if available)</h3>
            <p>[Description of any workarounds customers can use]</p>
            
            <div style="text-align: center; margin: 30px 0;">
                <a href="[Status Page Link]" class="button">View Real-time Status</a>
                <a href="[Support Link]" class="button" style="margin-left: 10px;">Contact Support</a>
            </div>
            
            <p><strong>Note:</strong> This is an automated update. You will receive further updates as the situation develops.</p>
            
            <p>We apologize for any inconvenience caused and appreciate your patience.</p>
            
            <p>Best regards,<br>
            The [Company Name] Operations Team</p>
        </div>
        
        <div class="footer">
            <p><strong>Incident Reference:</strong> INC-[Year][Month][Day]-[Number]</p>
            <p><strong>Status Page:</strong> <a href="[Status Page Link]">[Status Page URL]</a></p>
            <p><strong>Support:</strong> <a href="[Support Link]">[Support URL]</a> | Email: support@[company].com</p>
            <p>You're receiving this email because you are an affected customer. <a href="[Unsubscribe Link]">Update notification preferences</a></p>
        </div>
    </div>
</body>
</html>
```

## Plain Text Version

```
INCIDENT UPDATE: [Incident Title]

Severity: [SEV-1/2/3/4]
Update #[Update Number] | [Current Date/Time]

CURRENT STATUS
Status: [Investigating/Identified/Monitoring/Resolved]
Impact: [Description of impact on services/users]
Next Update: [Date/Time of next scheduled update]

LATEST UPDATE
[Detailed description of latest developments, investigation progress, or resolution steps]

INCIDENT TIMELINE
[Time] - [Event description]
[Time] - [Event description]
[Time] - [Event description]

AFFECTED SERVICES
- [Service 1] - [Status]
- [Service 2] - [Status]
- [Service 3] - [Status]

WORKAROUNDS (IF AVAILABLE)
[Description of any workarounds customers can use]

LINKS
Real-time Status: [Status Page Link]
Contact Support: [Support Link]

Note: This is an automated update. You will receive further updates as the situation develops.

We apologize for any inconvenience caused and appreciate your patience.

Best regards,
The [Company Name] Operations Team

---
Incident Reference: INC-[Year][Month][Day]-[Number]
Status Page: [Status Page URL]
Support: [Support URL] | Email: support@[company].com
Update notification preferences: [Unsubscribe Link]
```

## Variables to Replace

- `[Incident Title]` - Brief descriptive title of the incident
- `[critical/high/medium/low]` - Severity level for CSS class
- `[SEV-1/2/3/4]` - Severity level for display
- `[Update Number]` - Sequential update number (1, 2, 3, etc.)
- `[Current Date/Time]` - Current date and time in customer's timezone
- `[Investigating/Identified/Monitoring/Resolved]` - Current incident status
- `[Description of impact]` - Clear description of how customers are affected
- `[Date/Time of next update]` - When next update will be sent
- `[Detailed description]` - Technical details of progress
- `[Time]` - Timeline event timestamps
- `[Event description]` - Timeline event descriptions
- `[Service X]` - Names of affected services
- `[Status]` - Status of each service (Operational/Degraded/Outage)
- `[Description of workarounds]` - Any available workarounds
- `[Status Page Link]` - URL to status page
- `[Support Link]` - URL to support portal
- `[Company Name]` - Your company name
- `[Year][Month][Day]-[Number]` - Incident reference number
- `[Status Page URL]` - Full status page URL
- `[Support URL]` - Full support URL
- `[company]` - Your company domain
- `[Unsubscribe Link]` - Preferences management URL

## Severity Level Guidelines

### SEV-1 (Critical)
- **Header Color:** Red (#f8d7da)
- **Badge:** "SEV-1 - Critical"
- **Update Frequency:** Hourly
- **Tone:** Urgent, apologetic, transparent

### SEV-2 (High)
- **Header Color:** Orange (#fff3cd)
- **Badge:** "SEV-2 - High"
- **Update Frequency:** Every 2 hours
- **Tone:** Concerned, informative, proactive

### SEV-3 (Medium)
- **Header Color:** Blue (#d1ecf1)
- **Badge:** "SEV-3 - Medium"
- **Update Frequency:** Daily
- **Tone:** Informative, reassuring, detailed

### SEV-4 (Low)
- **Header Color:** Green (#d4edda)
- **Badge:** "SEV-4 - Low"
- **Update Frequency:** As needed
- **Tone:** Informative, routine, minimal

## Communication Protocol

### Initial Notification (0-15 minutes):
- Subject: `[SEV-X] Incident: [Brief Description]`
- Content: Acknowledgment, initial impact assessment, next steps

### Ongoing Updates (Scheduled):
- Subject: `Update #[Number]: [SEV-X] Incident: [Brief Description]`
- Content: Progress, current status, next update time

### Resolution Notification:
- Subject: `Resolved: [SEV-X] Incident: [Brief Description]`
- Content: Resolution details, root cause summary, preventive measures

### Post-Incident Report (24-48 hours after resolution):
- Subject: `Post-Incident Report: [Incident Title]`
- Content: Comprehensive analysis, lessons learned, improvement actions

## Quality Checklist

- [ ] Severity level is correctly identified and displayed
- [ ] Impact description is clear and accurate
- [ ] Timeline includes all key events
- [ ] Affected services list is complete and accurate
- [ ] Workarounds are clearly explained (if available)
- [ ] Next update time is specified
- [ ] All links are working
- [ ] Tone matches severity level
- [ ] No technical jargon that customers won't understand
- [ ] Contact information is correct
- [ ] Incident reference number is included

## Testing Protocol

1. **Template Testing:** Test with different severity levels
2. **Link Testing:** Verify all links work correctly
3. **Mobile Testing:** Ensure readability on mobile devices
4. **Email Client Testing:** Test in major email clients
5. **Content Review:** Technical and non-technical team review

## Performance Metrics to Track

- **Open Rate:** Target > 60% (high due to importance)
- **Click-Through Rate:** Target > 30% (to status page)
- **Customer Satisfaction:** Post-incident survey scores
- **Response Time:** Time from incident detection to first notification
- **Update Frequency:** Adherence to scheduled update times

---

**Template Version:** 1.0
**Last Updated:** 2026-03-18
**Owner:** Operations/Support Team
**Approval Required:** ☐ Yes (for initial notification) ☐ No (for scheduled updates)