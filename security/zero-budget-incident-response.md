# Zero-Budget Incident Response Plan

## Overview
This document outlines a basic incident response plan using free tools and manual processes. The plan is designed for organizations with limited budgets but need to establish formal incident response capabilities.

## 1. Incident Response Team (IRT) Structure

### Core Team Roles (Can be filled by existing staff)
| Role | Responsibilities | Required Skills |
|------|-----------------|-----------------|
| **Incident Commander** | Overall coordination, decision making | Leadership, communication |
| **Technical Lead** | Technical investigation, containment | System administration, networking |
| **Communications Lead** | Internal/external communications | Writing, stakeholder management |
| **Documentation Lead** | Evidence collection, reporting | Attention to detail, organization |

### On-Call Rotation
- **Primary:** [Name/Team]
- **Secondary:** [Name/Team]
- **Escalation:** [Name/Team]

## 2. Incident Classification

### Severity Levels
| Level | Impact | Response Time | Example |
|-------|--------|---------------|---------|
| **SEV-1** | Critical business impact | Immediate | Data breach, ransomware attack |
| **SEV-2** | Major impact | 1 hour | Service outage, unauthorized access |
| **SEV-3** | Minor impact | 4 hours | Performance degradation, suspicious activity |
| **SEV-4** | Informational | Next business day | Security scan findings, policy violations |

### Incident Categories
1. **Malware Infection**
2. **Unauthorized Access**
3. **Data Breach/Loss**
4. **Denial of Service**
5. **Phishing/Social Engineering**
6. **Physical Security Breach**
7. **Compliance Violation**

## 3. Incident Response Process

### Phase 1: Preparation
**Tools Required:**
- Communication channels (Telegram/Slack/Email)
- Documentation templates (Google Docs/Sheets)
- Evidence collection tools (screenshots, logs)

**Preparation Checklist:**
- [ ] Define IR team members and contact information
- [ ] Establish communication channels
- [ ] Create documentation templates
- [ ] Conduct tabletop exercises quarterly
- [ ] Maintain updated asset inventory

### Phase 2: Detection & Analysis

#### Detection Sources
1. **System Logs:** Review Wazuh, ELK Stack alerts
2. **User Reports:** Establish reporting channel (email/chat)
3. **External Reports:** Monitor security mailing lists
4. **Automated Scans:** Regular vulnerability scans

#### Initial Analysis Steps
```bash
# 1. Check system logs
sudo tail -f /var/log/syslog
sudo journalctl -f

# 2. Check network connections
sudo netstat -tulpn
sudo ss -tulpn

# 3. Check running processes
ps aux | grep -i suspicious
top -b -n 1

# 4. Check file modifications
find / -type f -mtime -1 2>/dev/null | head -20
```

#### Evidence Collection Template
```markdown
# Incident Evidence Log
**Incident ID:** [Auto-generated]
**Date/Time:** [YYYY-MM-DD HH:MM]
**Reporter:** [Name/Contact]
**Initial Description:** [Brief summary]

## Evidence Collected
1. **Log Files:** [List files with paths]
2. **Screenshots:** [List with timestamps]
3. **Network Captures:** [File locations]
4. **System State:** [Commands/output]
5. **User Accounts:** [Affected accounts]

## Timeline
| Time | Event | Source |
|------|-------|--------|
| | | |
```

### Phase 3: Containment, Eradication & Recovery

#### Short-term Containment
1. **Isolate affected systems:**
   ```bash
   # Block network access
   sudo iptables -A INPUT -s [IP] -j DROP
   
   # Disable user accounts
   sudo usermod -L [username]
   sudo passwd -l [username]
   ```

2. **Preserve evidence:**
   ```bash
   # Create forensic copies
   sudo dd if=/dev/sda of=/evidence/disk.img bs=4M
   
   # Capture memory
   sudo cat /proc/[pid]/maps > /evidence/memory_maps.txt
   ```

3. **Change credentials:**
   ```bash
   # Reset passwords
   sudo passwd [username]
   
   # Rotate SSH keys
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_new
   ```

#### Eradication Steps
1. **Remove malware:**
   ```bash
   # Scan with ClamAV (free)
   sudo apt-get install clamav
   sudo freshclam
   sudo clamscan -r --remove /
   
   # Use rkhunter
   sudo apt-get install rkhunter
   sudo rkhunter --check --sk
   ```

2. **Patch vulnerabilities:**
   ```bash
   # Update system
   sudo apt-get update && sudo apt-get upgrade -y
   
   # Check for known vulnerabilities
   sudo apt-get install debsecan
   debsecan --only-fixed
   ```

#### Recovery Procedures
1. **System restoration:**
   ```bash
   # From backups
   sudo tar -xzvf /backups/system-backup.tar.gz -C /
   
   # Rebuild from known good state
   sudo apt-get install --reinstall [package]
   ```

2. **Service validation:**
   ```bash
   # Test critical services
   curl -I https://your-domain.com
   nc -zv localhost 22
   systemctl status [service]
   ```

### Phase 4: Post-Incident Activity

#### Lessons Learned Template
```markdown
# Post-Incident Review
**Incident ID:** [Reference]
**Date:** [YYYY-MM-DD]
**Duration:** [Hours/Days]

## What Went Well
1. [Positive aspect 1]
2. [Positive aspect 2]

## What Could Be Improved
1. [Improvement area 1]
2. [Improvement area 2]

## Action Items
| Item | Owner | Due Date | Status |
|------|-------|----------|--------|
| | | | |
```

#### Improvement Implementation
1. **Update procedures:** Incorporate lessons learned
2. **Enhance monitoring:** Add detection for similar incidents
3. **Training:** Conduct team training on new procedures
4. **Tool improvement:** Enhance existing tools or add new ones

## 4. Communication Plan

### Internal Communication
**Primary Channel:** Telegram/Slack
**Backup Channel:** Email
**Escalation Path:** Phone call

### External Communication
**Template for Customers:**
```
Subject: Service Update [Date]

Dear [Customer],

We are writing to inform you about [brief description of incident].
Our team has [actions taken] and services have been restored.

We apologize for any inconvenience and are taking steps to prevent recurrence.

Sincerely,
[Your Organization]
```

**Template for Regulators (if required):**
```
Subject: Security Incident Notification

To: [Regulatory Body]

This notification concerns a security incident that occurred on [date].
The incident involved [brief description]. We have taken [actions] and are
implementing [preventive measures].

Please contact [contact person] for more information.

Respectfully,
[Your Organization]
```

## 5. Free Communication Tools

### Telegram for Incident Coordination
1. Create private group for IR team
2. Use bots for alerts:
   ```python
   # alert-bot.py
   import telegram
   bot = telegram.Bot(token='YOUR_TOKEN')
   bot.send_message(chat_id='GROUP_ID', text='INCIDENT ALERT')
   ```

### Slack Free Tier
- Create #incident-response channel
- Use webhooks for automated alerts
- Integrate with monitoring tools

### Google Workspace (Free for non-profits)
- Google Docs for collaborative documentation
- Google Sheets for tracking
- Google Meet for video conferences

## 6. Documentation Templates

### Incident Report Template (Google Docs)
```
INCIDENT REPORT
===============

1. EXECUTIVE SUMMARY
   • Incident ID: 
   • Date/Time: 
   • Severity: 
   • Impact: 

2. DETAILED TIMELINE
   Time | Action | Responsible
   -----|--------|------------
   
3. ROOT CAUSE ANALYSIS
   
4. ACTIONS TAKEN
   
5. LESSONS LEARNED
   
6. PREVENTIVE MEASURES
```

### Evidence Tracking Sheet (Google Sheets)
| Timestamp | Evidence Type | Location | Hash (MD5/SHA256) | Collected By |
|-----------|--------------|----------|-------------------|--------------|
| | | | | |

## 7. Training & Exercises

### Quarterly Tabletop Exercises
**Scenario Examples:**
1. Ransomware attack on file server
2. Data breach involving customer information
3. DDoS attack on web application
4. Insider threat investigation

**Exercise Structure:**
1. **Introduction** (15 mins): Present scenario
2. **Response** (45 mins): Team works through scenario
3. **Discussion** (30 mins): Review actions taken
4. **Documentation** (15 mins): Record lessons learned

### Free Training Resources
1. **SANS Incident Response Posters:** https://www.sans.org/posters/
2. **NIST Computer Security Incident Handling Guide:** https://csrc.nist.gov/publications/detail/sp/800-61/rev-2/final
3. **CISA Incident Response Resources:** https://www.cisa.gov/incident-response

## 8. Legal & Compliance Considerations

### Data Protection
- Document what data was affected
- Determine notification requirements
- Consult legal counsel if unsure

### Evidence Handling
1. **Chain of custody:** Document who handled evidence
2. **Integrity:** Use cryptographic hashes
3. **Storage:** Secure storage with access controls

### Reporting Requirements
- Check industry-specific regulations
- Determine notification timelines
- Prepare required documentation

## 9. Tool Integration

### Automated Alerting Workflow
```
Monitoring Tool → Webhook → Telegram/Slack → IR Team
                    ↓
              Documentation System
                    ↓
              Evidence Collection
```

### Sample Integration Script
```python
#!/usr/bin/env python3
# incident-webhook.py

from flask import Flask, request
import requests
import json

app = Flask(__name__)

@app.route('/webhook/incident', methods=['POST'])
def handle_incident():
    data = request.json
    
    # Send to Telegram
    telegram_url = f"https://api.telegram.org/bot{TOKEN}/sendMessage"
    telegram_data = {
        "chat_id": CHAT_ID,
        "text": f"INCIDENT: {data['alert']}",
        "parse_mode": "Markdown"
    }
    requests.post(telegram_url, json=telegram_data)
    
    # Log to file
    with open('/var/log/incidents.log', 'a') as f:
        f.write(json.dumps(data) + '\n')
    
    return "OK", 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

## 10. Continuous Improvement

### Metrics to Track
1. **MTTD (Mean Time to Detect):** Time from incident start to detection
2. **MTTR (Mean Time to Respond):** Time from detection to response
3. **MTTC (Mean Time to Contain):** Time from response to containment
4. **Incident Volume:** Number of incidents by category
5. **False Positive Rate:** Percentage of alerts that aren't incidents

### Regular Reviews
1. **Monthly:** Review incident metrics
2. **Quarterly:** Update procedures based on lessons learned
3. **Annually:** Full review of incident response program

## Conclusion

This zero-budget incident response plan provides a foundation for handling security incidents without financial investment. The key to success is regular practice, continuous improvement, and clear communication.

**Immediate Actions:**
1. Assign IR team roles
2. Set up communication channels
3. Create documentation templates
4. Schedule first tabletop exercise
5. Integrate monitoring tools with alerting

**Remember:** The goal is not perfection but preparedness. Start simple and improve over time based on actual incidents and exercises.