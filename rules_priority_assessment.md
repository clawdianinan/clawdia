# Rules & Priorities Assessment for Context Compaction
**Date:** March 2, 2026  
**Purpose:** Identify which rules must be kept in context during memory/context compaction

## 1. Existing Rules Inventory

### A. TOOLS.md Rules (Operational)

#### **TIER 1: CRITICAL SAFETY RULES** (Must always be in context)
1. **Email Sending Guardrail (Rule 11)**
   - Never send email without explicit instruction
   - Default: prepare/review only, wait for "send" command
   - **Priority: HIGHEST** - Prevents unauthorized communication

2. **IIH Email Action Guardrail (Rule 13)**
   - Never respond to IIH email requests without checking with Temi
   - **Priority: HIGHEST** - Prevents unauthorized institutional communication

3. **IHS Towers Priority (Section 2)**
   - Prioritize all emails from `@ihstowers.com`
   - Treat as high-priority traffic
   - **Priority: HIGHEST** - Government partner relationship

4. **WhatsApp VIP Alert Rules (Section 2.1)**
   - HE, Darwish, Oladepo = emergency alerts
   - Immediate escalation required
   - **Priority: HIGHEST** - Critical stakeholder communication

5. **ENVIRONMENT_GUARD (Rule 17)**
   - Prevent misconfiguration/cross-account contamination
   - Configuration drift detection
   - **Priority: HIGH** - System integrity

#### **TIER 2: OPERATIONAL RULES** (Important for daily work)
6. **Email Formatting Rules (Rule 18)**
   - Send as HTML, not markdown
   - No .md attachments
   - Professional subject lines (no "HTML")
   - **Priority: HIGH** - Professional communication standards

7. **IIH CC Rule (Rule 14)**
   - Always copy Temi (`temi@iih.ng`) on IIH emails
   - **Priority: HIGH** - Transparency and oversight

8. **Mandatory Signature Rule (Rule 15)**
   - Use exact Clawdia signature block
   - **Priority: MEDIUM-HIGH** - Brand consistency

9. **IIH Document Formatting (Rule 16)**
   - Black text, IIH letterhead, publication-ready
   - **Priority: MEDIUM** - Professional presentation

10. **Account Preferences (Sections 1.1-1.2)**
    - iCloud: Primary communication
    - Gmail: Public compatibility
    - **Priority: MEDIUM** - Correct account usage

#### **TIER 3: PROCEDURAL RULES** (Good practice)
11. **Change Management Rules (Section 9)**
    - Preserve working configurations
    - Flag `CONFIG_CONFLICT_DETECTED`
    - **Priority: MEDIUM** - System stability

12. **Alias Management (Section 3)**
    - Document durable aliases only
    - **Priority: LOW-MEDIUM** - Reference information

### B. HEARTBEAT.md Rules (Urgency Management)

#### **CRITICAL URGENCY RULES** (Must always be in context)
1. **Urgent Escalation Triggers**
   - IHS Towers emails = Highest priority
   - WhatsApp VIP contacts = Emergency alerts
   - Financial/contract exposure = Immediate review
   - Deadlines <24h = Time-sensitive
   - **Priority: HIGHEST** - Risk management

2. **Daily Checks**
   - Email triage: Urgent/Action/Info
   - Calendar: Today + 48h lookahead
   - IHS Towers follow-ups = Priority
   - **Priority: HIGH** - Daily operations

3. **Quiet Hours Enforcement**
   - 23:00-08:00 = No non-urgent interruptions
   - Break only for: Deadline risk, critical issues, stakeholder escalation
   - **Priority: HIGH** - Work-life balance respect

### C. MEMORY.md Rules (Strategic Context)

#### **STRATEGIC CONTEXT** (Must be preserved)
1. **Institutional & Government Layer**
   - IIH = Government-aligned innovation infrastructure
   - KWSG = Primary government partner
   - **Priority: HIGHEST** - Core identity

2. **IIH Organizational Structure**
   - Roles and Grading System (v3.6)
   - Program Officer role (Grade 4B)
   - **Priority: HIGH** - Organizational knowledge

3. **Active Strategic Bets**
   - STREAMS financial infrastructure
   - AI-native system architecture
   - Institutional digital infrastructure
   - **Priority: HIGH** - Strategic direction

## 2. Proposed Priority Tiers for Context Compaction

### **TIER 0: NON-NEGOTIABLE CORE** (Always in context)
- Email sending restrictions (Rules 11, 13)
- IHS Towers priority handling
- WhatsApp VIP emergency alerts
- Institutional identity (IIH/KWSG relationship)

### **TIER 1: HIGH-PRIORITY OPERATIONAL** (Usually in context)
- Email formatting standards
- Professional communication rules
- Urgency/HEARTBEAT triggers
- Daily operational checks

### **TIER 2: IMPORTANT REFERENCE** (Context when relevant)
- Account preferences and aliases
- Document formatting standards
- Change management procedures
- Strategic direction context

### **TIER 3: ARCHIVAL/REFERENCE** (Can be compressed/archived)
- Historical troubleshooting logs
- Old endpoint configurations
- Deprecated integration maps
- Completed project details

## 3. Memory System Test Results

### ✅ Working:
- Memory search returns results for institutional context
- Memory files exist and are organized by date
- MEMORY.md contains strategic narrative

### ⚠️ Needs Improvement:
- Some operational rules not appearing in memory search
- TOOLS.md rules not indexed in memory system
- HEARTBEAT.md rules separate from memory

### 🔧 Recommendations:
1. **Add rules to MEMORY.md** - Create "Operational Rules" section
2. **Improve indexing** - Ensure all critical rules are searchable
3. **Regular compaction** - Archive Tier 3 items, preserve Tier 0-1
4. **Cross-reference** - Link TOOLS.md, HEARTBEAT.md, MEMORY.md rules

## 4. Implementation Plan for Context Compaction

### Phase 1: Immediate (This Week)
1. Add "Operational Rules" section to MEMORY.md with Tier 0-1 rules
2. Update memory search to include TOOLS.md and HEARTBEAT.md
3. Create rules index for quick reference

### Phase 2: Short-term (Next 2 Weeks)
1. Implement automatic context tiering
2. Create compaction schedule (weekly/monthly)
3. Add rule compliance checking

### Phase 3: Ongoing
1. Regular review of rule priorities
2. Update based on usage patterns
3. Optimize context size vs. coverage

## 5. Key Metrics for Success

1. **Rule Recall Accuracy:** Can assistant recall and apply critical rules?
2. **Context Size:** Is working context optimized for performance?
3. **Compliance Rate:** Are rules being followed consistently?
4. **Update Frequency:** Are rules updated when patterns change?

## 6. Next Actions

1. **Immediate:** Add critical rules to MEMORY.md for better recall
2. **Today:** Test rule application in current IHS email response task
3. **This Week:** Implement Phase 1 improvements
4. **Ongoing:** Monitor and adjust priority tiers as needed

**Status:** Memory system functional but could be optimized for rule recall. Priority tiers established for context compaction.