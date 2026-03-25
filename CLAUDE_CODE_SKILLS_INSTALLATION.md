# 🚀 CLAUDE CODE SKILLS INSTALLATION GUIDE

## 📋 QUICK START

### **1. Install Claude Code Templates CLI:**
```bash
npm install -g claude-code-templates
# OR use npx directly
```

### **2. Install Critical Skills (Phase 1):**
```bash
# Skill Creator (MOST IMPORTANT - 7,113+ downloads)
npx claude-code-templates@latest --skill development/skill-creator

# React Best Practices (1,315+ downloads)
npx claude-code-templates@latest --skill development/react-best-practices

# Frontend Design (Professional UI)
npx claude-code-templates@latest --skill creative-design/frontend-design
```

### **3. Verify Installation:**
```bash
# Check installed skills
ls ~/.claude-code/skills/
```

## 🎯 AGENT-SPECIFIC SKILL SETUP

### **For TRINITY (Implementation Agent):**
```bash
# Core development skills
npx claude-code-templates@latest --skill development/react-best-practices
npx claude-code-templates@latest --skill creative-design/frontend-design
npx claude-code-templates@latest --skill creative-design/ui-ux-pro-max
npx claude-code-templates@latest --skill creative-design/ui-design-system

# Optional: Search for Supabase/Edge Function skills
```

### **For MORPHEUS (QA Agent):**
```bash
# Search for testing/QA skills on aitmpl.com
# Likely: testing-patterns, quality-assurance, etc.
```

### **For CYPHER (Security Agent):**
```bash
# Search for security skills on aitmpl.com
# Likely: security-scanning, compliance-checks, etc.
```

### **For SHURI (Operations Agent):**
```bash
# Document processing skills
npx claude-code-templates@latest --skill document-processing/pptx
# Search for documentation/jira skills
```

### **For ALL AGENTS:**
```bash
# Skill Creator (essential for skill optimization)
npx claude-code-templates@latest --skill development/skill-creator
```

## 🔧 INTEGRATION WITH OUR QWEN WORKFLOW

### **Current Command:**
```bash
ollama launch claude --model qwen3.5:9b "coding task"
```

### **Enhanced Command with Skills:**
```bash
# Skills should auto-load based on context
# Or manually specify skills in prompt
ollama launch claude --model qwen3.5:9b "
Use React Best Practices skill for this task:
[Task description]
"
```

### **Skill Loading Pattern:**
```javascript
// In Claude Code prompts:
"Using skills: [react-best-practices, frontend-design]
Task: [Your task here]"
```

## 📁 SKILL DIRECTORY STRUCTURE

### **Expected Location:**
```
~/.claude-code/skills/
├── development/
│   ├── skill-creator/
│   ├── react-best-practices/
│   └── [other skills]
├── creative-design/
│   ├── frontend-design/
│   ├── ui-ux-pro-max/
│   └── ui-design-system/
└── document-processing/
    └── pptx/
```

### **Skill Contents:**
Each skill contains:
- `SKILL.md` - Documentation and triggers
- `rules/` - Rule files and patterns
- `examples/` - Usage examples
- `templates/` - Code templates

## 🚀 USING SKILLS IN DEVELOPMENT

### **Example: React Component with Best Practices**
```javascript
// Prompt to Claude Code with Qwen:
"Using react-best-practices and frontend-design skills,
create a responsive dashboard component with:
1. Async data loading (avoid waterfalls)
2. Optimized bundle size
3. Professional UI design
4. Accessibility compliance"
```

### **Example: Skill Optimization**
```javascript
// Using skill-creator to improve our claude-qwen-dev skill:
"Using skill-creator skill,
optimize our claude-qwen-dev skill for:
1. Better triggering conditions
2. Improved error handling
3. Enhanced validation
4. Performance optimization"
```

## ⚠️ TROUBLESHOOTING

### **Common Issues:**

#### **1. Skill Not Found:**
```bash
# Update templates
npx claude-code-templates@latest --update

# Search for correct skill name
npx claude-code-templates@latest --search "react"
```

#### **2. Skill Not Loading:**
- Check `~/.claude-code/config.json`
- Verify skill directory exists
- Check skill triggers in `SKILL.md`

#### **3. Performance Issues:**
- Too many skills loaded simultaneously
- Large skill files causing memory issues
- Consider skill pruning or lazy loading

### **Debug Commands:**
```bash
# List installed skills
npx claude-code-templates@latest --list

# Get skill info
npx claude-code-templates@latest --info development/skill-creator

# Update all skills
npx claude-code-templates@latest --update-all
```

## 📊 SKILL EVALUATION METRICS

### **Before Installation:**
1. Current development speed
2. Code quality metrics
3. Bug rate
4. Agent productivity

### **After Installation:**
1. Compare metrics
2. Skill usage frequency
3. Quality improvements
4. Time savings

### **Evaluation Questions:**
- Does the skill trigger appropriately?
- Is the output quality improved?
- Are there any conflicts with other skills?
- Is performance impacted?

## 🔄 MAINTENANCE & UPDATES

### **Regular Updates:**
```bash
# Weekly skill updates
npx claude-code-templates@latest --update-all

# Check for new skills
npx claude-code-templates@latest --search "supabase"
```

### **Skill Audit:**
```bash
# Monthly audit
npx claude-code-templates@latest --list
# Review usage statistics
# Remove unused skills
```

### **Backup:**
```bash
# Backup skills directory
cp -r ~/.claude-code/skills/ ~/backups/claude-code-skills-$(date +%Y%m%d)
```

## 🎯 NEXT STEPS AFTER INSTALLATION

### **1. Skill Testing:**
- Test each skill with sample tasks
- Verify output quality
- Check for conflicts

### **2. Agent Training:**
- Train agents on skill usage
- Create skill reference guides
- Establish best practices

### **3. Process Integration:**
- Update agent workflows
- Modify task templates
- Integrate with Jira/Slack

### **4. Continuous Improvement:**
- Collect skill performance data
- Optimize skill combinations
- Contribute back improvements

## 📞 SUPPORT

### **aitmpl.com Resources:**
- Website: https://www.aitmpl.com
- Skills Directory: https://www.aitmpl.com/skills/
- Documentation: In each skill's `SKILL.md`

### **Community:**
- GitHub repository (likely)
- Discord community (if exists)
- Issue tracking for bugs

### **Our Internal Support:**
- Contact Clawdia for integration issues
- SHURI for documentation updates
- Trinity for technical troubleshooting

---

**Installation Priority:** HIGH  
**Expected Impact:** Significant agent productivity improvement  
**Risk Level:** LOW (skills are community-vetted)  
**Maintenance:** MODERATE (regular updates needed)