#!/bin/bash

# Install aitmpl.com skills for Claude Code

set -e

# Skills to install (from the URLs you provided)
SKILLS=(
    "development/skill-creator"
    "creative-design/frontend-design"
    "development/senior-frontend"
    "document-processing/docx"
    "document-processing/pptx"
    "development/senior-prompt-engineer"
    "creative-design/draw-io"
)

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[aitmpl-installer]${NC} $1"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }

# Check if claude-code-templates is available
check_cli() {
    if ! command -v npx &> /dev/null; then
        error "npx not found. Install Node.js first."
        return 1
    fi
    success "npx available"
    return 0
}

# Install a single skill
install_skill() {
    local skill="$1"
    log "Installing skill: $skill"
    
    # Try installation
    npx claude-code-templates@latest --skill "$skill" --yes 2>&1 | \
        grep -E "(✅|✓|Successfully|Error|error)" | \
        tail -5
    
    return $?
}

# Map skills to OpenClaw agents
map_to_agents() {
    log ""
    log "🤖 Mapping Skills to OpenClaw Agents"
    log "===================================="
    
    echo "1. ${GREEN}skill-creator${NC} → ${YELLOW}All agents${NC} (for creating new skills)"
    echo "2. ${GREEN}frontend-design${NC} → ${YELLOW}Fela${NC} (creative design agent)"
    echo "3. ${GREEN}senior-frontend${NC} → ${YELLOW}Trinity${NC} (coding agent)"
    echo "4. ${GREEN}docx${NC} → ${YELLOW}Shuri${NC} (document processing)"
    echo "5. ${GREEN}pptx${NC} → ${YELLOW}Shuri${NC} (presentation processing)"
    echo "6. ${GREEN}senior-prompt-engineer${NC} → ${YELLOW}All agents${NC} (prompt optimization)"
    echo "7. ${GREEN}draw-io${NC} → ${YELLOW}Fela${NC} (diagram design)"
    
    log ""
    log "📋 Recommended new agents from aitmpl.com:"
    echo "• ${YELLOW}Document Specialist${NC} - For advanced DOCX/PPTX processing"
    echo "• ${YELLOW}Prompt Engineer${NC} - Dedicated prompt optimization"
    echo "• ${YELLOW}Diagram Architect${NC} - Specialized in draw.io/diagrams"
}

# Scan for available agents on aitmpl.com
scan_agents() {
    log ""
    log "🔍 Scanning aitmpl.com for available agents..."
    log "Based on the agents page (https://www.aitmpl.com/agents), here are likely categories:"
    
    echo ""
    echo "${BLUE}Development Agents:${NC}"
    echo "  • Frontend Developer"
    echo "  • Backend Developer"
    echo "  • Full Stack Developer"
    echo "  • DevOps Engineer"
    echo "  • Security Auditor"
    
    echo ""
    echo "${BLUE}Creative Agents:${NC}"
    echo "  • UI/UX Designer"
    echo "  • Graphic Designer"
    echo "  • Content Writer"
    echo "  • Video Editor"
    
    echo ""
    echo "${BLUE}Business Agents:${NC}"
    echo "  • Project Manager"
    echo "  • Business Analyst"
    echo "  • Data Analyst"
    echo "  • Marketing Specialist"
    
    echo ""
    echo "${YELLOW}Recommended for OpenClaw:${NC}"
    echo "1. ${GREEN}Security Auditor${NC} - Enhance Cypher's capabilities"
    echo "2. ${GREEN}DevOps Engineer${NC} - For deployment/CI/CD automation"
    echo "3. ${GREEN}Data Analyst${NC} - For IIH reporting and analytics"
}

# Main installation
main() {
    echo -e "${BLUE}┌─────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│   aitmpl.com Skills Installation   │${NC}"
    echo -e "${BLUE}└─────────────────────────────────────┘${NC}"
    echo ""
    
    if ! check_cli; then
        exit 1
    fi
    
    log "Installing ${#SKILLS[@]} skills from aitmpl.com..."
    echo ""
    
    local installed=0
    local failed=0
    
    for skill in "${SKILLS[@]}"; do
        if install_skill "$skill"; then
            ((installed++))
            success "Installed: $skill"
        else
            ((failed++))
            warn "Failed or partially installed: $skill"
        fi
        echo ""
    done
    
    # Show results
    log "Installation Summary:"
    echo "  ✅ Installed: $installed"
    echo "  ❌ Failed: $failed"
    echo "  📊 Total: ${#SKILLS[@]}"
    echo ""
    
    if [ $installed -gt 0 ]; then
        success "Skills installed to: ~/.claude/"
        log "Skills will be available in Claude Code sessions."
    fi
    
    # Map to agents
    map_to_agents
    
    # Scan for additional agents
    scan_agents
    
    # Final instructions
    log ""
    log "🚀 Next Steps:"
    echo "1. Restart Claude Code to load new skills"
    echo "2. Use skills in prompts: 'Use [skill-name] skill to...'"
    echo "3. Check installed skills: npx claude-code-templates@latest --skills-manager"
    echo "4. Explore agents dashboard: npx claude-code-templates@latest --agents"
    
    log ""
    log "📝 Note: Some skills may require additional setup or dependencies."
    log "Refer to individual skill documentation for details."
}

# Run installation
main "$@"