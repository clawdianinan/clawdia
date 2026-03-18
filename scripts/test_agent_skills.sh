#!/bin/bash

# Agent Skill Test Script
# Tests basic functionality of newly upskilled agents

echo "=== Agent Skill Test Suite ==="
echo "Started: $(date)"
echo ""

# Test 1: Check if skills are installed
echo "Test 1: Checking installed skills..."
if [ -d "skills/openai-image-gen" ]; then
    echo "✅ openai-image-gen installed"
else
    echo "❌ openai-image-gen missing"
fi

if [ -d "skills/xurl" ]; then
    echo "✅ xurl installed"
else
    echo "❌ xurl missing"
fi

if [ -d "skills/n8n-workflow-automation" ]; then
    echo "✅ n8n-workflow-automation installed"
else
    echo "❌ n8n-workflow-automation missing"
fi

echo ""

# Test 2: Check bundled skills availability
echo "Test 2: Checking bundled skills..."
BUNDLED_SKILLS="/opt/homebrew/lib/node_modules/openclaw/skills"
if [ -d "$BUNDLED_SKILLS/summarize" ]; then
    echo "✅ summarize available (bundled)"
else
    echo "❌ summarize not found in bundled skills"
fi

if [ -d "$BUNDLED_SKILLS/mcporter" ]; then
    echo "✅ mcporter available (bundled)"
else
    echo "❌ mcporter not found in bundled skills"
fi

if [ -d "$BUNDLED_SKILLS/video-frames" ]; then
    echo "✅ video-frames available (bundled)"
else
    echo "❌ video-frames not found in bundled skills"
fi

if [ -d "$BUNDLED_SKILLS/blogwatcher" ]; then
    echo "✅ blogwatcher available (bundled)"
else
    echo "❌ blogwatcher not found in bundled skills"
fi

echo ""

# Test 3: Check configuration
echo "Test 3: Checking OpenClaw configuration..."
if grep -q "openai-image-gen" ~/.openclaw/openclaw.json; then
    echo "✅ openai-image-gen enabled in config"
else
    echo "❌ openai-image-gen not in config"
fi

if grep -q "xurl" ~/.openclaw/openclaw.json; then
    echo "✅ xurl enabled in config"
else
    echo "❌ xurl not in config"
fi

echo ""

# Test 4: Agent skill mapping verification
echo "Test 4: Agent Skill Mapping Summary"
echo "-----------------------------------"
echo "Trinity (Coding):"
echo "  - coding-agent, github, frontend-design"
echo "  - n8n-workflow-automation, mcporter, skill-creator"
echo ""
echo "Shuri (Operations):"
echo "  - email-ops, todo-management, office-document-specialist-suite"
echo "  - summarize, pdf, healthcheck"
echo ""
echo "Ebun (Research/Writing):"
echo "  - summarize, web_search, graphic-design"
echo "  - openai-image-gen, video-frames, blogwatcher"
echo ""
echo "Nova (Strategy/Product):"
echo "  - trello, github, calendly-api"
echo "  - zoho-crm, xurl, clawhub"
echo ""

# Test 5: Quick functionality checks
echo "Test 5: Quick functionality checks..."
echo "Note: Full testing requires agent sessions"
echo ""
echo "To test Trinity:"
echo "  openclaw sessions_spawn runtime=subagent agentId=trinity task='Test n8n workflow creation'"
echo ""
echo "To test Shuri:"
echo "  openclaw sessions_spawn runtime=subagent agentId=shuri task='Create a monthly report template'"
echo ""
echo "To test Ebun:"
echo "  openclaw sessions_spawn runtime=subagent agentId=ebun task='Research latest AI trends'"
echo ""
echo "To test Nova:"
echo "  openclaw sessions_spawn runtime=subagent agentId=nova task='Analyze competitor social media'"
echo ""

echo "=== Test Complete ==="
echo "Reference: AGENT_UPSKILLING_REFERENCE.md"
echo "Next: Run actual agent tests with sample tasks"