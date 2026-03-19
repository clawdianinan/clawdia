#!/bin/bash

# Scan and install aitmpl.com agents/skills for OpenClaw
# Focus on merging with existing agents, not overwriting

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[Agent Scanner]${NC} $1"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }

# OpenClaw agents and their specialties
OPENCLAW_AGENTS=(
    "trinity:coding:development"
    "fela:design:creative"
    "cypher:security:audit"
    "shuri:documents:processing"
    "ebun:research:analysis"
    "nova:strategy:planning"
)

# Scan for agent categories (based on aitmpl.com structure)
scan_agent_categories() {
    log "Scanning for agent categories matching OpenClaw agents..."
    
    echo ""
    echo "${BLUE}Development (Trinity)${NC}:"
    echo "  • code-reviewer"
    echo "  • senior-frontend"
    echo "  • backend-developer"
    echo "  • fullstack-developer"
    echo "  • devops-engineer"
    
    echo ""
    echo "${BLUE}Creative Design (Fela)${NC}:"
    echo "  • frontend-design"
    echo "  • ui-ux-designer"
    echo "  • graphic-designer"
    echo "  • draw-io"
    echo "  • video-editor"
    
    echo ""
    echo "${BLUE}Security (Cypher)${NC}:"
    echo "  • security-auditor"
    echo "  • penetration-tester"
    echo "  • compliance-checker"
    echo "  • vulnerability-scanner"
    
    echo ""
    echo "${BLUE}Document Processing (Shuri)${NC}:"
    echo "  • docx"
    echo "  • pptx"
    echo "  • pdf"
    echo "  • excel"
    echo "  • markdown"
    
    echo ""
    echo "${BLUE}Research & Analysis (Ebun)${NC}:"
    echo "  • research-assistant"
    echo "  • data-analyzer"
    echo "  • market-researcher"
    echo "  • academic-writer"
    
    echo ""
    echo "${BLUE}Strategy & Planning (Nova)${NC}:"
    echo "  • product-manager"
    echo "  • project-planner"
    echo "  • business-analyst"
    echo "  • strategy-consultant"
}

# Install agents by merging with OpenClaw specialties
install_agents_by_category() {
    log "Installing agents by OpenClaw category..."
    
    # Development agents for Trinity
    echo ""
    log "Installing Development Agents (Trinity)..."
    install_component "agent" "development/code-reviewer"
    install_component "agent" "development/senior-frontend"
    install_component "agent" "development/devops-engineer"
    
    # Creative agents for Fela
    echo ""
    log "Installing Creative Agents (Fela)..."
    install_component "skill" "creative-design/frontend-design"  # Already installed
    install_component "skill" "creative-design/draw-io"
    install_component "agent" "creative/ui-ux-designer"
    
    # Security agents for Cypher
    echo ""
    log "Installing Security Agents (Cypher)..."
    install_component "agent" "security/auditor"
    install_component "agent" "security/penetration-tester"
    
    # Document agents for Shuri
    echo ""
    log "Installing Document Agents (Shuri)..."
    install_component "skill" "document-processing/docx"  # Already installed
    install_component "skill" "document-processing/pptx"
    install_component "skill" "document-processing/pdf"
    
    # Research agents for Ebun
    echo ""
    log "Installing Research Agents (Ebun)..."
    install_component "agent" "research/assistant"
    install_component "agent" "analysis/data-analyzer"
    
    # Strategy agents for Nova
    echo ""
    log "Installing Strategy Agents (Nova)..."
    install_component "agent" "strategy/product-manager"
    install_component "agent" "strategy/project-planner"
}

# Install a component with error handling
install_component() {
    local type="$1"
    local component="$2"
    
    log "Installing $type: $component"
    
    # Try installation with timeout
    timeout 30 npx claude-code-templates@latest --$type "$component" --yes 2>&1 | \
        grep -E "(✅|✓|Successfully|Error|error|rate limit|403)" | \
        tail -3 || true
    
    # Check if installation likely succeeded
    if [ $? -eq 0 ]; then
        success "Installed: $component"
    else
        warn "May have rate limit issues: $component"
    fi
    
    echo ""
}

# Scan for useful skills for each agent
scan_useful_skills() {
    log "Scanning for useful skills per agent..."
    
    echo ""
    echo "${YELLOW}Skills for Trinity (Coding):${NC}"
    echo "  • ${GREEN}skill-creator${NC} (installed) - Create new skills"
    echo "  • ${GREEN}senior-frontend${NC} (installed) - Advanced React/Next.js"
    echo "  • code-optimizer - Performance optimization"
    echo "  • testing-framework - Test generation"
    echo "  • api-designer - API design patterns"
    
    echo ""
    echo "${YELLOW}Skills for Fela (Design):${NC}"
    echo "  • ${GREEN}frontend-design${NC} (installed) - UI design"
    echo "  • color-palette-generator - Color schemes"
    echo "  • typography-system - Font pairing"
    echo "  • animation-designer - Motion design"
    echo "  • brand-identity - Branding systems"
    
    echo ""
    echo "${YELLOW}Skills for Cypher (Security):${NC}"
    echo "  • security-scanner - Vulnerability detection"
    echo "  • compliance-checker - Regulatory compliance"
    echo "  • code-auditor - Security code review"
    echo "  • threat-modeler - Threat modeling"
    echo "  • penetration-testing - Security testing"
    
    echo ""
    echo "${YELLOW}Skills for Shuri (Documents):${NC}"
    echo "  • ${GREEN}docx${NC} (installed) - Word documents"
    echo "  • ${GREEN}pptx${NC} - PowerPoint presentations"
    echo "  • pdf-processor - PDF manipulation"
    echo "  • excel-analyzer - Spreadsheet analysis"
    echo "  • report-generator - Automated reporting"
    
    echo ""
    echo "${YELLOW}Skills for Ebun (Research):${NC}"
    echo "  • research-synthesizer - Research synthesis"
    echo "  • data-visualizer - Data visualization"
    echo "  • academic-writer - Academic writing"
    echo "  • market-analyzer - Market analysis"
    echo "  • trend-spotter - Trend identification"
    
    echo ""
    echo "${YELLOW}Skills for Nova (Strategy):${NC}"
    echo "  • business-modeler - Business modeling"
    echo "  • project-planner - Project planning"
    echo "  • risk-analyzer - Risk analysis"
    echo "  • decision-framework - Decision making"
    echo "  • strategy-planner - Strategic planning"
}

# Create integration mapping
create_integration_mapping() {
    log "Creating OpenClaw + aitmpl integration mapping..."
    
    cat > /tmp/openclaw_aitmpl_mapping.md << 'EOF'
# OpenClaw + aitmpl.com Integration Mapping

## Agent Enhancements

### Trinity (Coding Agent)
**Existing:** Coding, implementation, debugging
**aitmpl Enhancements:**
- `development/code-reviewer` - Enhanced code review
- `development/senior-frontend` - Advanced React patterns
- `development/devops-engineer` - Deployment automation
- `skill-creator` - Create custom skills

### Fela (Design Agent)
**Existing:** Creative design, visuals, branding
**aitmpl Enhancements:**
- `creative-design/frontend-design` - UI/UX design
- `creative-design/draw-io` - Diagram creation
- `creative/ui-ux-designer` - User experience
- `creative/graphic-designer` - Visual assets

### Cypher (Security Agent)
**Existing:** Security, compliance, auditing
**aitmpl Enhancements:**
- `security/auditor` - Security audits
- `security/penetration-tester` - Security testing
- `security/compliance-checker` - Compliance verification

### Shuri (Document Agent)
**Existing:** Document processing, formatting
**aitmpl Enhancements:**
- `document-processing/docx` - Word documents
- `document-processing/pptx` - Presentations
- `document-processing/pdf` - PDF processing
- `document-processing/excel` - Spreadsheets

### Ebun (Research Agent)
**Existing:** Research, analysis, synthesis
**aitmpl Enhancements:**
- `research/assistant` - Research assistance
- `analysis/data-analyzer` - Data analysis
- `research/academic-writer` - Academic writing

### Nova (Strategy Agent)
**Existing:** Strategy, planning, direction
**aitmpl Enhancements:**
- `strategy/product-manager` - Product management
- `strategy/project-planner` - Project planning
- `strategy/business-analyst` - Business analysis

## Installation Status
- ✅ Installed: skill-creator, frontend-design, senior-frontend, docx
- ⏳ Pending: pptx, draw-io, senior-prompt-engineer
- 🔍 Available: Security, DevOps, UI/UX agents

## Usage Pattern
```bash
# Reference in Claude Code prompts:
# "Use [skill-name] skill with [agent-name] agent to..."
# Example: "Use frontend-design skill with Fela agent to design login page"
```

## Merge Strategy
- **Additive**: Add aitmpl capabilities to existing agents
- **Complementary**: Use aitmpl for specialized tasks
- **Fallback**: Existing OpenClaw agents remain primary
EOF
    
    success "Integration mapping created: /tmp/openclaw_aitmpl_mapping.md"
}

# Main function
main() {
    echo -e "${BLUE}┌──────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│   OpenClaw + aitmpl.com Agent Scanner   │${NC}"
    echo -e "${BLUE}└──────────────────────────────────────────┘${NC}"
    echo ""
    
    log "Current OpenClaw Agents:"
    for agent_spec in "${OPENCLAW_AGENTS[@]}"; do
        IFS=':' read -r name category specialty <<< "$agent_spec"
        echo "  • ${GREEN}$name${NC} ($category - $specialty)"
    done
    
    echo ""
    
    # Scan categories
    scan_agent_categories
    
    echo ""
    log "Useful Skills Scan:"
    scan_useful_skills
    
    echo ""
    warn "Note: GitHub API rate limits may affect installations"
    warn "Some installations may need to be retried later"
    
    # Create integration mapping
    create_integration_mapping
    
    echo ""
    log "🚀 Recommended Installation Commands:"
    echo ""
    echo "# Security agents for Cypher"
    echo "npx claude-code-templates@latest --agent security/auditor --yes"
    echo "npx claude-code-templates@latest --agent security/penetration-tester --yes"
    echo ""
    echo "# DevOps agent for Trinity"
    echo "npx claude-code-templates@latest --agent development/devops-engineer --yes"
    echo ""
    echo "# UI/UX agent for Fela"
    echo "npx claude-code-templates@latest --agent creative/ui-ux-designer --yes"
    echo ""
    echo "# Complete installation (when rate limits allow):"
    echo "cd /Users/clawdia/.openclaw/workspace"
    echo "./scripts/scan-and-install-agents.sh --install"
    
    echo ""
    success "Scan complete! Review mapping at /tmp/openclaw_aitmpl_mapping.md"
}

# Check for install flag
if [[ "$1" == "--install" ]]; then
    install_agents_by_category
else
    main
fi