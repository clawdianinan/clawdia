# Zero-Budget Risk Assessment Framework

## Executive Summary
This document provides a comprehensive, zero-budget risk assessment framework for identifying, evaluating, and mitigating security risks. The methodology focuses on free tools, manual processes, and continuous improvement without requiring commercial risk management solutions.

## 1. Risk Assessment Methodology

### 1.1 Risk Matrix Template

**Create `security/risk-matrix.csv`:**
```csv
Risk ID,Category,Description,Impact,Likelihood,Risk Score,Mitigation,Owner,Status,Due Date
RISK-001,Data,SQL injection vulnerability,High,High,16,Parameterized queries,Dev Team,In Progress,2026-03-25
RISK-002,Access,Admin accounts without 2FA,High,Medium,12,Implement Google Auth,IT Team,Open,2026-04-01
RISK-003,Infrastructure,Outdated server software,Medium,High,12,Update packages,System Admin,Open,2026-03-30
RISK-004,Compliance,No access review process,Medium,Medium,9,Monthly reviews,Security Lead,Planned,2026-04-15
```

### 1.2 Risk Scoring System

**Impact Levels:**
- **Low (1)**: Minor inconvenience, no data loss
- **Medium (2)**: Moderate disruption, limited data exposure
- **High (3)**: Significant disruption, sensitive data exposure
- **Critical (4)**: System outage, major data breach

**Likelihood Levels:**
- **Rare (1)**: Once per year or less
- **Unlikely (2)**: Once every 6 months
- **Possible (3)**: Once per month
- **Likely (4)**: Once per week
- **Almost Certain (5)**: Daily or more

**Risk Score = Impact × Likelihood**
- **1-4**: Low risk (Green)
- **5-9**: Medium risk (Yellow)
- **10-16**: High risk (Orange)
- **17-20**: Critical risk (Red)

## 2. Critical Assets Inventory

### 2.1 Asset Classification Template

**Create `security/critical-assets.csv`:**
```csv
Asset ID,Asset Name,Type,Criticality,Owner,Location,Backup Frequency,Recovery Time Objective (RTO),Data Classification
AST-001,User Database,Database,Critical,DB Team,Primary Server,Daily,4 hours,Confidential
AST-002,Web Application,Application,High,Dev Team,Cloud,Weekly,8 hours,Internal
AST-003,Source Code,Data,High,Dev Team,GitHub,Daily,24 hours,Internal
AST-004,Admin SSH Access,Access,Critical,System Admin,All Servers,N/A,1 hour,N/A
AST-005,Customer Data,Data,Critical,Sales Team,Database,Daily,4 hours,Confidential
```

### 2.2 Asset Discovery Commands

**System Inventory:**
```bash
#!/bin/bash
# system-inventory.sh
echo "=== System Inventory Report ==="
echo "Generated: $(date)"
echo ""

# Hardware
echo "## Hardware Information"
echo "Hostname: $(hostname)"
echo "Kernel: $(uname -r)"
echo "CPU: $(lscpu | grep "Model name" | cut -d: -f2 | xargs)"
echo "Memory: $(free -h | grep Mem | awk '{print $2}')"
echo "Disk: $(df -h / | tail -1 | awk '{print $2}')"

# Network
echo ""
echo "## Network Information"
echo "IP Addresses:"
ip addr show | grep "inet " | awk '{print $2}'

# Services
echo ""
echo "## Running Services"
systemctl list-units --type=service --state=running | head -20

# Open Ports
echo ""
echo "## Open Ports"
ss -tuln | grep LISTEN
```

**Web Application Assets:**
```bash
#!/bin/bash
# web-assets-discovery.sh
echo "=== Web Application Assets ==="

# Find web root directories
find /var/www /srv /home -name "index.php" -o -name "index.html" 2>/dev/null | head -10

# Check for configuration files
find /etc -name "*.conf" -type f | xargs grep -l "password\|secret\|key" 2>/dev/null | head -10

# Database connections
find /var/www /home -type f \( -name "*.php" -o -name "*.js" -o -name "*.py" \) \
  -exec grep -l "mysql_connect\|pg_connect\|new PDO" {} \; 2>/dev/null | head -10
```

## 3. Top 5 Risks Identification

### 3.1 Risk Identification Workshop Template

**Create `security/risk-identification-worksheet.md`:**
```markdown
# Risk Identification Workshop

## Date: [YYYY-MM-DD]
## Participants: [List names]

### Brainstorming Questions:
1. What could cause our systems to stop working?
2. What data would cause the most damage if exposed?
3. How could someone gain unauthorized access?
4. What dependencies do we have that could fail?
5. What compliance requirements do we need to meet?

### Identified Risks:

#### 1. [Risk Name]
- **Description**: 
- **Impact**: 
- **Likelihood**: 
- **Affected Assets**: 
- **Current Controls**: 
- **Gap Analysis**: 

#### 2. [Risk Name]
- **Description**: 
- **Impact**: 
- **Likelihood**: 
- **Affected Assets**: 
- **Current Controls**: 
- **Gap Analysis**: 

[Continue for all identified risks]

### Prioritization:
1. [Highest priority risk]
2. [Second priority]
3. [Third priority]
4. [Fourth priority]
5. [Fifth priority]

### Next Steps:
- [ ] Document risks in risk register
- [ ] Assign owners
- [ ] Develop mitigation plans
- [ ] Schedule follow-up review
```

### 3.2 Top 5 Risks Template

**Create `security/top-5-risks.md`:**
```markdown
# Top 5 Security Risks

## Last Updated: 2026-03-18
## Next Review: 2026-04-18

### 1. SQL Injection Vulnerabilities
**Risk Score**: 16 (Critical)
**Description**: Legacy code uses string concatenation for SQL queries, making applications vulnerable to injection attacks.
**Affected Systems**: Web applications, admin interfaces
**Impact**: Complete database compromise, data theft, data corruption
**Likelihood**: High (Attackers actively scan for SQLi)
**Mitigation Plan**:
- [ ] Implement parameterized queries
- [ ] Add input validation middleware
- [ ] Conduct SQLMap testing
- [ ] Train developers on secure coding
**Owner**: Development Team
**Due Date**: 2026-03-25
**Status**: In Progress

### 2. Lack of Multi-Factor Authentication
**Risk Score**: 12 (High)
**Description**: Admin accounts accessible with only username/password, no 2FA.
**Affected Systems**: SSH access, web admin panels, cloud accounts
**Impact**: Account takeover, privilege escalation
**Likelihood**: Medium (Credential stuffing common)
**Mitigation Plan**:
- [ ] Implement Google Authenticator for SSH
- [ ] Add TOTP to web applications
- [ ] Enforce 2FA for all admin accounts
- [ ] Create emergency access procedures
**Owner**: IT Team
**Due Date**: 2026-04-01
**Status**: Open

### 3. Outdated Software Components
**Risk Score**: 12 (High)
**Description**: Servers running outdated operating systems and software with known vulnerabilities.
**Affected Systems**: Web servers, database servers, development environments
**Impact**: Exploitation of known vulnerabilities, system compromise
**Likelihood**: High (Automated scanners target outdated software)
**Mitigation Plan**:
- [ ] Create patch management schedule
- [ ] Implement automated security updates
- [ ] Regular vulnerability scanning
- [ ] Maintain software inventory
**Owner**: System Administration
**Due Date**: 2026-03-30
**Status**: Open

### 4. Insufficient Access Controls
**Risk Score**: 9 (Medium)
**Description**: No regular access reviews, excessive privileges, shared admin accounts.
**Affected Systems**: All systems with user accounts
**Impact**: Privilege misuse, insider threats, compliance violations
**Likelihood**: Medium (Common in growing organizations)
**Mitigation Plan**:
- [ ] Implement principle of least privilege
- [ ] Monthly access reviews
- [ ] Separate admin accounts per person
- [ ] Log all privileged actions
**Owner**: Security Lead
**Due Date**: 2026-04-15
**Status**: Planned

### 5. Lack of Security Monitoring
**Risk Score**: 8 (Medium)
**Description**: No centralized logging, alerting, or incident detection capabilities.
**Affected Systems**: All systems
**Impact**: Delayed breach detection, extended attacker dwell time
**Likelihood**: Medium (Attacks may go unnoticed)
**Mitigation Plan**:
- [ ] Implement centralized logging
- [ ] Create alert rules for suspicious activity
- [ ] Daily log review process
- [ ] Incident response procedures
**Owner**: Security Team
**Due Date**: 2026-04-30
**Status**: Planned
```

## 4. Mitigation Plans

### 4.1 Risk Mitigation Template

**Create `security/risk-mitigation-plans/` directory with individual plans:**

**Example: `RISK-001-mitigation.md`**
```markdown
# Risk Mitigation Plan: RISK-001

## Risk: SQL Injection Vulnerabilities
**Risk Score**: 16 (Critical)
**Target Risk Score**: 4 (Low)

## Mitigation Strategy
### Phase 1: Immediate Protection (Week 1)
- [ ] Implement input validation middleware
- [ ] Add WAF rules to block SQL injection patterns
- [ ] Enable detailed logging of SQL errors

### Phase 2: Code Remediation (Month 1)
- [ ] Inventory all SQL queries in codebase
- [ ] Prioritize high-risk queries (user input, admin functions)
- [ ] Convert to parameterized queries
- [ ] Code review for security

### Phase 3: Testing & Validation (Month 2)
- [ ] Conduct SQLMap testing
- [ ] Penetration testing
- [ ] Developer training on secure coding

### Phase 4: Ongoing Maintenance (Continuous)
- [ ] Add SQL injection checks to CI/CD pipeline
- [ ] Regular code reviews
- [ ] Annual security training

## Resources Required
- Development time: 40 hours
- Testing tools: SQLMap (free), OWASP ZAP (free)
- Training: OWASP SQL Injection Prevention Cheat Sheet

## Success Metrics
- Zero SQL injection vulnerabilities in new code
- All legacy high-risk queries remediated
- Negative SQLMap test results
- Developer training completion: 100%

## Timeline
| Phase | Start Date | End Date | Status |
|-------|------------|----------|--------|
| Phase 1 | 2026-03-18 | 2026-03-25 | In Progress |
| Phase 2 | 2026-03-25 | 2026-04-22 | Planned |
| Phase 3 | 2026-04-22 | 2026-05-20 | Planned |
| Phase 4 | 2026-05-20 | Ongoing | Planned |

## Owner: Development Team
## Approval: [Signature/Date]
```

### 4.2 Free Mitigation Tools

**Vulnerability Scanners:**
1. **OpenVAS** - Open source vulnerability scanner
   ```bash
   # Installation
   sudo apt install openvas
   sudo gvm-setup
   sudo gvm-start
   # Access at https://localhost:9392
   ```

2. **OWASP ZAP** - Web application security scanner
   ```bash
   # Download from https://www.zaproxy.org/download/
   # Run with Java
   java -jar zap-2.14.0.jar
   ```

3. **Nikto** - Web server scanner
   ```bash
   # Installation
   sudo apt install nikto
   # Basic scan
   nikto -h https://example.com
   ```

4. **Nmap** - Network discovery and security auditing
   ```bash
   # Installation
   sudo apt install nmap
   # Vulnerability scan
   nmap -sV --script vuln target.com
   ```

**Log Analysis Tools:**
1. **GoAccess** - Real-time web log analyzer
   ```bash
   sudo apt install goaccess
   goaccess /var/log/apache2/access.log --log-format=COMBINED
   ```

2. **Lynis** - Security auditing tool
   ```bash
   sudo apt install lynis
   sudo lynis audit system
   ```

## 5. Monthly Review Process

### 5.1 Monthly Risk Review Checklist

**Create `security/monthly-risk-review.md`:**
```markdown
# Monthly Risk Review Checklist

## Review Date: [YYYY-MM-DD]
## Reviewer: [Name]

### 1. Risk Register Update
- [ ] Review all open risks
- [ ] Update risk scores based on changes
- [ ] Add new risks identified
- [ ] Close mitigated risks

### 2. Mitigation Progress
- [ ] Review status of all mitigation plans
- [ ] Update completion percentages
- [ ] Identify blockers or delays
- [ ] Adjust timelines if needed

### 3. New Risk Identification
- [ ] Review system changes from last month
- [ ] Check for new vulnerabilities in software
- [ ] Review security news relevant to our stack
- [ ] Brainstorm new potential risks

### 4. Metrics Review
- [ ] Number of open risks (target: decreasing)
- [ ] Average risk score (target: decreasing)
- [ ] Mitigation completion rate (target: >80%)
- [ ] Time to mitigate high risks (target: <30 days)

### 5. Compliance Check
- [ ] Review any new compliance requirements
- [ ] Check alignment with security policies
- [ ] Document any gaps
- [ ] Plan remediation for gaps

## Findings:
1. [Key findings from review]
2. [Trends identified]
3. [Areas needing attention]

## Action Items:
| Item | Owner | Due Date | Priority |
|------|-------|----------|----------|
|      |       |          |          |

## Next Review Date: [Next month same date]

## Sign-off:
Reviewer: __________________ Date: _______________
Security Lead: _______________ Date: _______________
Management: __________________ Date: _______________
```

### 5.2 Automated Risk Reporting Script

**`security/scripts/monthly-risk-report.sh`:**
```bash
#!/bin/bash

# Monthly Risk Report Generator
REPORT_DATE=$(date '+%Y-%m-%d')
REPORT_FILE="/security/reports/risk-report-$REPORT_DATE.md"

echo "# Monthly Risk Assessment Report" > "$REPORT_FILE"
echo "**Date**: $REPORT_DATE" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Summary Statistics
echo "## Executive Summary" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Count risks by severity
echo "### Risk Distribution" >> "$REPORT_FILE"
echo "- Critical Risks: $(grep -c "Critical" security/risk-matrix.csv)" >> "$REPORT_FILE"
echo "- High Risks: $(grep -c "High" security/risk-matrix.csv)" >> "$REPORT_FILE"
echo "- Medium Risks: $(grep -c "Medium" security/risk-matrix.csv)" >> "$REPORT_FILE"
echo "- Low Risks: $(grep -c "Low" security/risk-matrix.csv)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Top risks
echo "### Top 5 Risks Needing Attention" >> "$REPORT_FILE"
tail -n +2 security/risk-matrix.csv | sort -t, -k6 -nr | head -5 | while IFS=, read -r id category desc impact likelihood score mitigation owner status due; do
    echo "1. **$desc** (Score: $score)" >> "$REPORT_FILE"
    echo "   - Owner: $owner" >> "$REPORT_FILE"
    echo "   - Due: $due" >> "$REPORT_FILE"
    echo "   - Status: $status" >> "$REPORT_FILE"
done
echo "" >> "$REPORT_FILE"

# Mitigation progress
echo "### Mitigation Progress" >> "$REPORT_FILE"
total_risks=$(tail -n +2 security/risk-matrix.csv | wc -l)
mitigated_risks=$(grep -c "Closed\|Completed" security/risk-matrix.csv)
progress=$((mitigated_risks * 100 / total_risks))
echo "- Total Risks: $total_risks" >> "$REPORT_FILE"
echo "- Mitigated: $mitigated_risks" >> "$REPORT_FILE"
echo "- Progress: $progress%" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Recommendations
echo "## Recommendations" >> "$REPORT_FILE"
echo "1. Focus on critical risks first" >> "$REPORT_FILE"
echo "2. Review overdue mitigation items" >> "$REPORT_FILE"
echo "3. Update risk scores based on recent changes" >> "$REPORT_FILE"
echo "4. Schedule risk identification workshop" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "Report generated: $REPORT_FILE"
```

## 6. Risk Communication

### 6.1 Stakeholder Reporting Template

**Create `security/templates/stakeholder-report.md`:**
```markdown
# Security Risk Status Report

## Period: [Month Year]
## Prepared For: [Stakeholder Group]
## Date: [YYYY-MM-DD]

### 1. Executive Summary
[Brief overview of current risk posture]

### 2. Key Metrics
- Overall Risk Score: [Number]
- Open Risks: [Number]
- Risks Mitigated This Period: [Number]
- Average Time to Mitigate: [Days]

### 3. Critical Risks
[Table of top 3-5 critical risks]

### 4. Progress Highlights
- [Key achievements]
- [Successful mitigations]
- [Process improvements]

### 5. Challenges & Blockers
- [Resource constraints]
- [Technical challenges]
- [Dependencies]

### 6. Next Quarter Focus
- [Priority areas]
- [Key initiatives]
- [Resource requirements]

### 7. Recommendations for Leadership
- [Strategic decisions needed]
- [Budget considerations]
- [Policy changes required]

## Appendix
- Detailed risk register
- Mitigation plans
- Supporting data

---

**Prepared by**: Security Team  
**Next Report**: [Next month]  
**Contact**: security@example.com
```

### 6.2 Risk Awareness Training

**Free Training Resources:**
1. **OWASP Top 10** - https://owasp.org/www-project-top-ten/
2. **SANS Security Awareness** - Free posters and materials
3. **CISA Cybersecurity Resources** - https://www.cisa.gov/cybersecurity
4. **Google Security Training** - https://landing.google.com/security-training/

**Monthly Security Newsletter Template:**
```markdown
# Security Awareness Newsletter - [Month Year]

## This Month's Focus: [Topic, e.g., "Password Security"]

### Quick Tips
1. [Tip 1]
2. [Tip 2]
3. [Tip 3]

### Real-World Example
[Brief case study of relevant security incident]

### Free Tools & Resources
- [Tool 1 with link]
- [Tool 2 with link]
- [Resource 1 with link]

### Quiz Question
[Simple security question with answer next month]

### Upcoming
- Next month's focus: [Topic]
- Security training: [Date if scheduled]

---

**Stay secure!**  
The Security Team
```

## 7. Continuous Improvement Framework

### 7.1 Quarterly Improvement Cycle

**Q1: Foundation**
- Establish risk assessment process
- Create asset inventory
- Identify top 5 risks

**Q2: Mitigation**
- Implement critical risk mitigations
- Establish monitoring
- Conduct first penetration test

**Q3: Maturation**
- Refine processes
- Expand coverage
- Implement automation

**Q4: Optimization**
- Review and improve
- Benchmark against standards
- Plan for next year

### 7.2 Success Metrics Dashboard

**Create `security/metrics-dashboard.md`:**
```markdown
# Security Risk Metrics Dashboard

## Last Updated: [Date]

### Key Performance Indicators (KPIs)
1. **Risk Reduction Rate**: Target: 20% quarterly reduction
2. **Mitigation Completion**: Target: 90% on-time completion
3. **Mean Time to Mitigate**: Target: <30 days for high risks
4. **Risk Identification Rate**: Target: <5 new critical risks/month
5. **Stakeholder Satisfaction**: Target: >4/5 rating

### Current Status
| Metric | Current | Target | Status | Trend |
|--------|---------|--------|--------|-------|
| Open Critical Risks | 3 | 0 | 🔴 | ↘️ |
| Mitigation Completion | 65% | 90% | 🟡 | ↗️ |
| MTTR High Risks | 45 days | 30 days | 🟡 | ↘️ |
| New Risks/Month | 2 | <5 | 🟢 | → |
| Training Completion | 80% | 100% | 🟡 | ↗️ |

### Quarterly Goals
**Q1 2026**: Establish baseline metrics
**Q2 2026**: Achieve 50% risk reduction
**Q3 2026**: Implement automated reporting
**Q4 2026**: Achieve industry benchmark compliance
```

## 8. Integration with Other Processes

### 8.1 Change Management Integration
- Risk assessment for all system changes
- Security review before production deployment
- Post-implementation risk validation

### 8.2 Incident Response Integration
- Risk-based incident prioritization
- Lessons learned feed into risk assessment
- Continuous improvement based on incidents

### 8.3 Compliance Integration
- Map risks to compliance requirements
- Use risk assessment for audit evidence
- Demonstrate risk-based decision making

## 9. Free Risk Assessment Tools

### 9.1 Spreadsheet Templates
- **NIST Risk Assessment Template**: Available from NIST website
- **ISO 27005 Risk Assessment**: Free templates online
- **FAIR Risk Assessment**: Open FAIR standard templates

### 9.2 Open Source Tools
1. **OWASP Threat Dragon** - Threat modeling tool
2. **Microsoft Threat Modeling Tool** - Free for download
3. **PyTM** - Pythonic threat modeling
4. **Mozilla Risk Assessment** - Open source framework

### 9.3 Community Resources
- **OWASP Risk Assessment Methodology**
- **SANS Risk Management Posters**
- **CIS Critical Security Controls**
- **NIST Cybersecurity Framework**

## 10. Getting Started Checklist

### Week 1: Foundation
- [ ] Read this document
- [ ] Create security directory structure
- [ ] Identify key stakeholders
- [ ] Schedule risk identification workshop

### Week 2: Assessment
- [ ] Conduct asset inventory
- [ ] Identify top 5 risks
- [ ] Create risk register
- [ ] Assign risk owners

### Week 3: Planning
- [ ] Develop mitigation plans
- [ ] Set up monthly review process
- [ ] Create reporting templates
- [ ] Schedule first monthly review

### Week 4: Implementation
- [ ] Begin mitigating top risk
- [ ] Set up basic monitoring
- [ ] Conduct first training session
- [ ] Send first status report

## Conclusion

This zero-budget risk assessment framework provides everything needed to establish a basic but effective risk management program. The key to success is consistency—regular reviews, continuous improvement, and stakeholder engagement.

Remember: **Perfect is the enemy of good.** Start small, demonstrate value, and gradually expand your risk management capabilities.

---

**Framework Version**: 1.0  
**Last Updated**: 2026-03-18  
**Next Framework Review**: 2026-06-18  
**Maintainer**: Security Team  
**License**: CC BY-SA 4.0 (Free to use and modify with attribution)