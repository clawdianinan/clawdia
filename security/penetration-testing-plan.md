# Penetration Testing Plan & Schedule
**Version:** 1.0  
**Date:** March 18, 2026  
**Author:** Cypher (Security Specialist)  
**Status:** Draft for Review

## Executive Summary

This document outlines a comprehensive penetration testing program for the organization, designed to identify and remediate security vulnerabilities before they can be exploited by malicious actors. The plan follows industry best practices and aligns with compliance requirements for 2026.

### Key Objectives
1. **Identify security weaknesses** across all critical systems
2. **Validate security controls** and their effectiveness
3. **Meet compliance requirements** (SOC 2, ISO 27001, PCI-DSS)
4. **Improve incident response** capabilities
5. **Establish continuous security validation** program

## 1. Testing Schedule

### 1.1 Quarterly External Penetration Tests

| Quarter | Focus Area | Testing Window | Vendor Selection Deadline |
|---------|------------|----------------|---------------------------|
| Q2 2026 | Web Applications & APIs | April 15-30, 2026 | March 31, 2026 |
| Q3 2026 | Cloud Infrastructure & Network | July 15-31, 2026 | June 30, 2026 |
| Q4 2026 | Mobile Applications & IoT | October 15-31, 2026 | September 30, 2026 |
| Q1 2027 | AI/ML Systems & Advanced Threats | January 15-31, 2027 | December 31, 2026 |

### 1.2 Monthly Internal Security Assessments

| Month | Assessment Type | Scope | Responsible Team |
|-------|-----------------|-------|------------------|
| Monthly | Vulnerability Scanning | All production systems | Security Operations |
| Bi-Monthly | Red Team Exercises | Critical business functions | Security Team + External Vendor |
| Quarterly | Purple Team Exercises | Integration testing | Security + Development Teams |

### 1.3 Specialized Testing Schedule

| Test Type | Frequency | Scope | Compliance Driver |
|-----------|-----------|-------|-------------------|
| **SOC 2 Compliance Testing** | Annually (before audit) | All in-scope systems | SOC 2 Type II |
| **PCI-DSS Testing** | Quarterly + after changes | Payment systems | PCI-DSS 4.0 |
| **AI/ML Security Testing** | Semi-annually | AI models, training pipelines | NIST AI RMF |
| **Supply Chain Security** | Annually | Third-party dependencies | Executive Order 14028 |

## 2. Testing Scope

### 2.1 In-Scope Systems

#### Critical Applications
- **OpenClaw Gateway** (`gateway.iih.ng`)
- **Clawdia AI Platform** (`clawdia.iih.ng`)
- **IIH Management Portal** (`portal.iih.ng`)
- **API Gateway & Microservices** (`api.iih.ng`)

#### Infrastructure
- **Cloud Infrastructure** (AWS/Azure/GCP)
- **Network Perimeter** (Firewalls, Load Balancers, VPN)
- **Container Orchestration** (Kubernetes clusters)
- **CI/CD Pipeline** (GitHub Actions, Jenkins)

#### Data Systems
- **Databases** (PostgreSQL, MongoDB, Redis)
- **Object Storage** (S3, Azure Blob Storage)
- **Message Queues** (RabbitMQ, Kafka)

### 2.2 Out-of-Scope Systems
- Development environments (unless explicitly requested)
- Third-party SaaS applications (tested via API only)
- Legacy systems scheduled for decommissioning
- Personal devices and BYOD endpoints

### 2.3 Testing Boundaries
- **IP Ranges:** All public IP addresses owned by IIH
- **Domains:** All `*.iih.ng` subdomains
- **Time Windows:** Business hours (9 AM - 5 PM WAT) unless otherwise agreed
- **Rate Limits:** Maximum 10 requests/second per target

## 3. Testing Methodology

### 3.1 Approach Selection

| Test Type | Methodology | Depth | Duration |
|-----------|-------------|-------|----------|
| **Black Box** | External perspective, no prior knowledge | Medium | 2 weeks |
| **Gray Box** | Limited internal knowledge provided | High | 3 weeks |
| **White Box** | Full source code and architecture access | Very High | 4 weeks |
| **Red Team** | Adversary simulation, stealth operations | Extreme | 4-6 weeks |

### 3.2 Testing Phases

#### Phase 1: Planning & Reconnaissance (Week 1)
- Scope finalization and rules of engagement
- Legal agreements and authorization documents
- Passive reconnaissance (OSINT gathering)
- Asset discovery and mapping

#### Phase 2: Vulnerability Assessment (Week 2)
- Automated vulnerability scanning
- Manual configuration review
- Authentication and authorization testing
- Business logic flaw identification

#### Phase 3: Exploitation (Week 3)
- Controlled exploitation of identified vulnerabilities
- Privilege escalation testing
- Lateral movement simulation
- Data exfiltration testing

#### Phase 4: Post-Exploitation (Week 4)
- Persistence mechanism testing
- Defense evasion techniques
- Cleanup and artifact removal
- Impact assessment

#### Phase 5: Reporting & Remediation (Week 5-6)
- Comprehensive report generation
- Risk scoring and prioritization
- Remediation guidance
- Retesting validation

## 4. Vendor Selection Criteria

### 4.1 Required Qualifications
- **Certifications:** CREST, OSCP, GPEN, or equivalent
- **Experience:** Minimum 5 years in penetration testing
- **Specializations:** Cloud security, web applications, mobile apps
- **References:** 3+ client references in similar industry

### 4.2 Evaluation Matrix

| Criteria | Weight | Description |
|----------|--------|-------------|
| Technical Expertise | 30% | Depth of knowledge in modern attack techniques |
| Reporting Quality | 25% | Clarity, actionable recommendations, executive summaries |
| Communication | 20% | Regular updates, stakeholder management |
| Cost Effectiveness | 15% | Value for money, transparent pricing |
| Compliance Knowledge | 10% | Understanding of relevant regulations |

### 4.3 Recommended Vendors
1. **Qualysec Technologies** - Specialized in compliance-driven testing
2. **Netragard** - SOC 2 and enterprise security expertise
3. **Penligent AI** - AI/ML security testing specialists
4. **Graynode Security** - Cloud and container security focus

## 5. Rules of Engagement

### 5.1 Authorized Activities
- Port scanning and service enumeration
- Vulnerability scanning and exploitation
- Password cracking (test accounts only)
- Social engineering (with prior approval)
- Physical security testing (site-specific approval)

### 5.2 Prohibited Activities
- Denial of Service (DoS/DDoS) attacks
- Data destruction or corruption
- Testing outside agreed scope
- Testing during maintenance windows
- Accessing real customer data

### 5.3 Communication Protocol
- **Primary Contact:** Security Team Lead
- **Secondary Contact:** IT Operations Manager
- **Emergency Contact:** CISO/Head of Security
- **Update Frequency:** Daily during testing, weekly summaries
- **Escalation Path:** Security Team → IT Director → Executive Team

## 6. Success Metrics

### 6.1 Quantitative Metrics
- **Vulnerability Discovery Rate:** Target > 90% of critical vulnerabilities
- **Remediation Time:** Critical issues resolved within 7 days
- **False Positive Rate:** < 10% of reported vulnerabilities
- **Coverage:** > 95% of in-scope assets tested

### 6.2 Qualitative Metrics
- **Actionable Findings:** All findings include remediation steps
- **Stakeholder Satisfaction:** > 4.5/5 rating from business units
- **Compliance Alignment:** 100% of required controls validated
- **Knowledge Transfer:** Effective handoff to internal teams

## 7. Budget & Resources

### 7.1 Estimated Costs

| Item | Q2 2026 | Q3 2026 | Q4 2026 | Annual Total |
|------|---------|---------|---------|--------------|
| External Penetration Testing | $15,000 | $15,000 | $15,000 | $45,000 |
| Internal Security Tools | $5,000 | $5,000 | $5,000 | $15,000 |
| Training & Certification | $3,000 | $3,000 | $3,000 | $9,000 |
| Incident Response Retainer | $10,000 | $10,000 | $10,000 | $30,000 |
| **Total** | **$33,000** | **$33,000** | **$33,000** | **$99,000** |

### 7.2 Resource Requirements
- **Security Team:** 2 FTE for coordination and remediation
- **Development Team:** 1 FTE for code fixes and patches
- **IT Operations:** 1 FTE for infrastructure changes
- **Executive Sponsorship:** CISO/Head of Security oversight

## 8. Risk Management

### 8.1 Identified Risks
1. **Business Disruption:** Testing during production hours
2. **Data Exposure:** Accidental access to sensitive information
3. **System Instability:** Vulnerability exploitation causing outages
4. **Compliance Violation:** Testing outside authorized scope

### 8.2 Mitigation Strategies
- **Pre-test backups:** Full system backups before testing
- **Monitoring:** Enhanced logging and alerting during tests
- **Rollback plans:** Quick restoration procedures
- **Insurance:** Cyber liability coverage for testing activities

## 9. Compliance Alignment

### 9.1 Regulatory Requirements
- **SOC 2:** Annual penetration testing requirement
- **ISO 27001:** Regular security testing (A.12.6.1)
- **PCI-DSS:** Quarterly external scans (Req. 11.3)
- **GDPR:** Security of processing (Article 32)
- **NIST CSF:** Identify, Protect, Detect functions

### 9.2 Evidence Collection
- **Testing Reports:** Detailed findings and remediation
- **Remediation Tracking:** Issue closure evidence
- **Executive Summaries:** Board-level reporting
- **Audit Trails:** Complete testing documentation

## 10. Next Steps

### Immediate Actions (Next 30 Days)
1. **Vendor Selection:** Finalize and contract with testing vendor
2. **Scope Finalization:** Detailed asset inventory and testing boundaries
3. **Communication Plan:** Notify all stakeholders of testing schedule
4. **Pre-test Preparation:** Backups, monitoring, and rollback plans

### Short-term Actions (Next 90 Days)
1. **Q2 Testing Execution:** Complete first external penetration test
2. **Remediation Planning:** Prioritize and schedule vulnerability fixes
3. **Process Refinement:** Update testing methodology based on lessons learned
4. **Team Training:** Security awareness for development and operations teams

### Long-term Actions (Next 12 Months)
1. **Program Maturity:** Establish continuous security testing program
2. **Automation:** Implement automated security validation in CI/CD
3. **Threat Intelligence:** Integrate testing with threat intelligence feeds
4. **Metrics Dashboard:** Real-time security posture monitoring

## Appendix A: Testing Checklist

### Pre-Engagement
- [ ] Scope document signed by all stakeholders
- [ ] Legal agreements and NDAs executed
- [ ] Communication channels established
- [ ] Emergency contacts documented
- [ ] System backups completed

### During Testing
- [ ] Daily status reports submitted
- [ ] Critical findings immediately escalated
- [ ] Testing boundaries respected
- [ ] Evidence properly documented
- [ ] Communication protocol followed

### Post-Testing
- [ ] Comprehensive report delivered
- [ ] Risk assessment completed
- [ ] Remediation plan created
- [ ] Retesting schedule established
- [ ] Lessons learned documented

## Appendix B: Contact Information

| Role | Name | Email | Phone | Availability |
|------|------|-------|-------|--------------|
| Security Lead | [To be assigned] | security@iih.ng | [Phone] | 24/7 during testing |
| IT Operations | [To be assigned] | it-ops@iih.ng | [Phone] | Business hours |
| Executive Sponsor | [To be assigned] | exec@iih.ng | [Phone] | As needed |
| Testing Vendor | [To be selected] | vendor@example.com | [Phone] | Per contract |

## Appendix C: Glossary

- **CVSS:** Common Vulnerability Scoring System
- **OSINT:** Open Source Intelligence
- **VAPT:** Vulnerability Assessment and Penetration Testing
- **ROE:** Rules of Engagement
- **SLA:** Service Level Agreement
- **MTTR:** Mean Time to Remediate

---

**Document Control**
- **Version History:** 1.0 (Initial Draft)
- **Approval Required:** Security Committee, Executive Team
- **Review Cycle:** Quarterly
- **Distribution:** Security Team, IT Operations, Compliance Officer

**Last Updated:** March 18, 2026  
**Next Review:** June 18, 2026