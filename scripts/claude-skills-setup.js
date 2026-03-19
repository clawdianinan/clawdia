#!/usr/bin/env node

/**
 * Claude Skills Setup for OpenClaw
 * Creates basic skill templates for Claude Code integration
 */

const fs = require('fs');
const path = require('path');

const SKILLS_DIR = path.join(__dirname, '..', 'claude-skills');
const TEMPLATES_DIR = path.join(SKILLS_DIR, 'templates');

// Basic skill templates
const skillTemplates = {
  'code-reviewer': {
    name: 'Code Reviewer',
    description: 'Comprehensive code review for TypeScript, JavaScript, Python, Swift, Kotlin, Go',
    trigger: 'code review, review this code, check code quality',
    template: `# Code Reviewer Skill

## Purpose
Perform comprehensive code reviews including:
- Code quality and best practices
- Security vulnerabilities
- Performance optimizations
- Architecture and design patterns
- Testing and maintainability

## Supported Languages
- TypeScript/JavaScript
- Python
- Swift
- Kotlin
- Go
- Java
- C#

## Review Checklist

### 1. Security
- [ ] Input validation and sanitization
- [ ] Authentication/authorization checks
- [ ] SQL injection prevention
- [ ] XSS prevention
- [ ] Secure storage of secrets
- [ ] API rate limiting

### 2. Performance
- [ ] Efficient algorithms and data structures
- [ ] Memory usage optimization
- [ ] Database query optimization
- [ ] Network call optimization
- [ ] Caching strategy

### 3. Code Quality
- [ ] Consistent coding style
- [ ] Proper error handling
- [ ] Code documentation
- [ ] Test coverage
- [ ] Modularity and reusability

### 4. Architecture
- [ ] Separation of concerns
- [ ] Dependency management
- [ ] Scalability considerations
- [ ] Maintainability
- [ ] Deployment considerations

## Output Format
\`\`\`
## Code Review Report

### Summary
[Brief overview of findings]

### Critical Issues (Must Fix)
1. [Issue 1]
2. [Issue 2]

### High Priority Issues
1. [Issue 1]
2. [Issue 2]

### Medium Priority Issues
1. [Issue 1]
2. [Issue 2]

### Low Priority Issues
1. [Issue 1]
2. [Issue 2]

### Recommendations
1. [Recommendation 1]
2. [Recommendation 2]

### Security Assessment
- [ ] No critical vulnerabilities found
- [ ] [List any vulnerabilities]

### Performance Assessment
- [ ] Performance acceptable
- [ ] [Performance issues]

### Next Steps
1. [Immediate action]
2. [Follow-up action]
\`\`\``
  },
  
  'react-best-practices': {
    name: 'React Best Practices',
    description: 'Vercel-optimized React/Next.js performance and best practices',
    trigger: 'react, nextjs, performance, optimization, best practices',
    template: `# React Best Practices Skill

## Purpose
Apply Vercel-optimized React/Next.js performance guidelines and best practices.

## Priority Categories

### 1. Eliminating Waterfalls (CRITICAL)
- async-defer-await: Move await into branches where actually used
- async-parallel: Use Promise.all() for independent operations
- async-dependencies: Use better-all for partial dependencies
- async-api-routes: Start promises early, await late in API routes
- async-suspense-boundaries: Use Suspense to stream content

### 2. Bundle Size Optimization (CRITICAL)
- bundle-barrel-imports: Import directly, avoid barrel files
- bundle-dynamic-imports: Use next/dynamic for heavy components
- bundle-defer-third-party: Load analytics/logging after hydration
- bundle-conditional: Load modules only when feature is activated
- bundle-preload: Preload on hover/focus for perceived speed

### 3. Server-Side Performance (HIGH)
- server-cache-react: Use React.cache() for per-request deduplication
- server-cache-lru: Use LRU cache for cross-request caching
- server-serialization: Minimize data passed to client components
- server-parallel-fetching: Restructure components to parallelize fetches
- server-after-nonblocking: Use after() for non-blocking operations

### 4. Client-Side Data Fetching (MEDIUM-HIGH)
- client-swr-dedup: Use SWR for automatic request deduplication
- client-event-listeners: Deduplicate global event listeners

### 5. Re-render Optimization (MEDIUM)
- rerender-defer-reads: Don't subscribe to state only used in callbacks
- rerender-memo: Extract expensive work into memoized components
- rerender-dependencies: Use primitive dependencies in effects
- rerender-derived-state: Subscribe to derived booleans, not raw values
- rerender-functional-setstate: Use functional setState for stable callbacks
- rerender-lazy-state-init: Pass function to useState for expensive values
- rerender-transitions: Use startTransition for non-urgent updates

## Implementation Examples

### Dynamic Imports
\`\`\`typescript
// ❌ Avoid
import HeavyComponent from '@/components/HeavyComponent';

// ✅ Use
const HeavyComponent = dynamic(() => import('@/components/HeavyComponent'), {
  ssr: false,
  loading: () => <Skeleton />
});
\`\`\`

### React.cache() for Data Fetching
\`\`\`typescript
import { cache } from 'react';

const getData = cache(async (id: string) => {
  const res = await fetch(\`/api/data/\${id}\`);
  return res.json();
});

// Same request in same render = cached
const data1 = await getData('123');
const data2 = await getData('123'); // Returns cached result
\`\`\`

### SWR for Client Data
\`\`\`typescript
import useSWR from 'swr';

function UserProfile({ userId }) {
  const { data, error, isLoading } = useSWR(
    \`/api/user/\${userId}\`,
    (url) => fetch(url).then(res => res.json())
  );
  
  // Automatic deduplication, caching, revalidation
}
\`\`\``
  },
  
  'debugging-assistant': {
    name: 'Debugging Assistant',
    description: 'Systematic debugging methodology for runtime issues',
    trigger: 'debug, fix error, troubleshooting, why is this broken',
    template: `# Debugging Assistant Skill

## Purpose
Follow systematic debugging methodology to diagnose and fix runtime issues.

## Four-Phase Debugging Methodology

### Phase 1: Root Cause Investigation
1. **Reproduce the issue**
   - Exact steps to trigger
   - Environment details
   - Frequency (always/sometimes)

2. **Gather evidence**
   - Error messages and stack traces
   - Console logs
   - Network requests
   - System logs

3. **Isolate the component**
   - Minimal reproduction
   - Remove unrelated code
   - Test in isolation

### Phase 2: Pattern Analysis
1. **Identify patterns**
   - When does it work vs. fail?
   - Common factors in failures
   - Timing or sequence issues

2. **Check dependencies**
   - Version compatibility
   - Configuration differences
   - Environment variables

3. **Review recent changes**
   - Code changes
   - Dependency updates
   - Configuration changes
   - Deployment changes

### Phase 3: Hypothesis Testing
1. **Formulate hypotheses**
   - Based on evidence
   - Testable predictions
   - Prioritize by likelihood

2. **Test hypotheses**
   - Create controlled tests
   - Modify one variable at a time
   - Document results

3. **Validate findings**
   - Confirm root cause
   - Verify fix addresses issue
   - Test edge cases

### Phase 4: Implementation & Validation
1. **Implement fix**
   - Minimal changes
   - Follow coding standards
   - Add tests

2. **Test thoroughly**
   - Original issue fixed
   - No regression
   - Edge cases handled

3. **Document solution**
   - Root cause analysis
   - Fix description
   - Prevention measures

## Common Debugging Scenarios

### React/Next.js Blank Page
1. Check browser console for errors
2. Verify React hydration
3. Check environment variables
4. Verify build process
5. Check runtime dependencies

### API/Network Issues
1. Check network tab
2. Verify CORS headers
3. Check authentication
4. Verify request/response format
5. Test with curl/postman

### Database Issues
1. Check connection strings
2. Verify schema compatibility
3. Check query performance
4. Verify data migration
5. Check transaction isolation

## Output Format
\`\`\`
## Debugging Report

### Issue Summary
[Brief description]

### Reproduction Steps
1. [Step 1]
2. [Step 2]

### Evidence Collected
- Error: [Error message]
- Logs: [Relevant logs]
- Network: [Network issues]
- Environment: [Env details]

### Root Cause Analysis
[Detailed analysis]

### Hypothesis Testing Results
1. [Hypothesis 1]: [Result]
2. [Hypothesis 2]: [Result]

### Identified Root Cause
[Root cause]

### Recommended Fix
[Fix description]

### Implementation Steps
1. [Step 1]
2. [Step 2]

### Validation Plan
1. [Test 1]
2. [Test 2]

### Prevention Measures
1. [Measure 1]
2. [Measure 2]
\`\`\``
  }
};

// Create skills directory structure
function setupSkillsDirectory() {
  if (!fs.existsSync(SKILLS_DIR)) {
    fs.mkdirSync(SKILLS_DIR, { recursive: true });
    console.log(`✅ Created skills directory: ${SKILLS_DIR}`);
  }
  
  if (!fs.existsSync(TEMPLATES_DIR)) {
    fs.mkdirSync(TEMPLATES_DIR, { recursive: true });
    console.log(`✅ Created templates directory: ${TEMPLATES_DIR}`);
  }
}

// Create skill files
function createSkills() {
  console.log('\n📦 Creating Claude Code skills...');
  
  let createdCount = 0;
  
  for (const [skillId, skill] of Object.entries(skillTemplates)) {
    const skillDir = path.join(TEMPLATES_DIR, skillId);
    
    if (!fs.existsSync(skillDir)) {
      fs.mkdirSync(skillDir, { recursive: true });
    }
    
    // Create skill file
    const skillFile = path.join(skillDir, 'SKILL.md');
    fs.writeFileSync(skillFile, skill.template);
    
    // Create metadata
    const metaFile = path.join(skillDir, 'meta.json');
    fs.writeFileSync(metaFile, JSON.stringify({
      id: skillId,
      name: skill.name,
      description: skill.description,
      trigger: skill.trigger,
      version: '1.0.0',
      created: new Date().toISOString(),
      author: 'OpenClaw Integration'
    }, null, 2));
    
    console.log(`✅ Created skill: ${skill.name} (${skillId})`);
    createdCount++;
  }
  
  return createdCount;
}

// Create integration guide
function createIntegrationGuide() {
  const guidePath = path.join(SKILLS_DIR, 'INTEGRATION_GUIDE.md');
  
  const guide = `# Claude Code Skills Integration Guide

## Overview
This directory contains skill templates for enhancing Claude Code capabilities when used with OpenClaw.

## Available Skills

### 1. Code Reviewer
- **Purpose:** Comprehensive code review for multiple languages
- **Trigger:** "code review", "review this code", "check code quality"
- **Use with:** Trinity (coding agent), Cypher (security agent)

### 2. React Best Practices
- **Purpose:** Vercel-optimized React/Next.js performance guidelines
- **Trigger:** "react", "nextjs", "performance", "optimization"
- **Use with:** Trinity (React development), Fela (design system)

### 3. Debugging Assistant
- **Purpose:** Systematic debugging methodology
- **Trigger:** "debug", "fix error", "troubleshooting"
- **Use with:** All agents for issue diagnosis

## How to Use

### Manual Usage
When using Claude Code interactively, reference these skills by their triggers:

\`\`\`
Claude, please use the "code reviewer" skill to review this TypeScript code:
[code here]
\`\`\`

### OpenClaw Integration
The \`claude-code-manager.js\` script can be extended to automatically apply relevant skills based on task type.

## Skill Development

### Creating New Skills
1. Add skill template to \`scripts/claude-skills-setup.js\`
2. Run \`node scripts/claude-skills-setup.js\`
3. Test skill with Claude Code

### Skill Structure
Each skill should include:
- Clear purpose and scope
- Trigger phrases
- Methodology or checklist
- Expected output format

## Integration with aitmpl.com Skills
When aitmpl.com CLI becomes available, additional skills can be installed:

\`\`\`bash
# Example installation commands
npx claude-code-templates@latest --skill development/code-reviewer
npx claude-code-templates@latest --skill development/react-best-practices
npx claude-code-templates@latest --skill security/security-audit
\`\`\`

## Fallback Strategy
If automated Claude Code integration fails, use manual interactive mode:

\`\`\`bash
# Manual interactive session
ANTHROPIC_API_KEY=ollama ANTHROPIC_BASE_URL=http://localhost:11434/v1 \\
  claude --model ollama/qwen3.5:9b

# Then reference skills manually
\`\`\`

## Next Steps
1. Test each skill with sample tasks
2. Extend claude-code-manager.js to use skills
3. Integrate with specific OpenClaw agents
4. Add more specialized skills as needed
`;

  fs.writeFileSync(guidePath, guide);
  console.log(`✅ Created integration guide: ${guidePath}`);
}

// Main function
function main() {
  console.log('🚀 Setting up Claude Code Skills for OpenClaw\n');
  
  try {
    setupSkillsDirectory();
    const createdCount = createSkills();
    createIntegrationGuide();
    
    console.log(`\n🎉 Successfully created ${createdCount} Claude Code skills!`);
    console.log('\n📁 Skills location:', SKILLS_DIR);
    console.log('\n📋 Next steps:');
    console.log('1. Test skills with manual Claude Code sessions');
    console.log('2. Extend claude-code-manager.js to use these skills');
    console.log('3. Integrate with OpenClaw agents (Trinity first)');
    console.log('4. Add more skills as needed');
    console.log('\n🔧 Fallback: Manual interactive usage is always available');
    
  } catch (error) {
    console.error('❌ Error setting up skills:', error.message);
    process.exit(1);
  }
}

// Run if called directly
if (require.main === module) {
  main();
}

module.exports = {
  skillTemplates,
  setupSkillsDirectory,
  createSkills,
  createIntegrationGuide
};