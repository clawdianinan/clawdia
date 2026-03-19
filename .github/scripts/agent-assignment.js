#!/usr/bin/env node

const core = require('@actions/core');
const github = require('@actions/github');

// Agent specialization mapping
const AGENT_SPECIALIZATION = {
  // Development Team
  'trinity-dev': {
    roles: ['backend-developer', 'frontend-developer', 'full-stack'],
    skills: ['javascript', 'typescript', 'python', 'java', 'go', 'node.js', 'react', 'vue', 'angular'],
    expertise: ['api-development', 'database-design', 'system-architecture', 'performance-optimization'],
    keywords: ['bug', 'feature', 'implementation', 'code', 'refactor', 'optimize', 'deploy']
  },
  
  'morpheus-qa': {
    roles: ['quality-assurance', 'test-engineer'],
    skills: ['testing', 'automation', 'selenium', 'cypress', 'jest', 'pytest', 'quality'],
    expertise: ['test-planning', 'test-automation', 'performance-testing', 'security-testing'],
    keywords: ['test', 'qa', 'quality', 'validation', 'verify', 'bug-report', 'test-case']
  },
  
  'cypher-security': {
    roles: ['security-engineer', 'security-analyst'],
    skills: ['security', 'authentication', 'authorization', 'encryption', 'vulnerability-assessment'],
    expertise: ['security-audit', 'penetration-testing', 'compliance', 'risk-assessment'],
    keywords: ['security', 'auth', 'encrypt', 'vulnerability', 'compliance', 'gdpr', 'secure']
  },
  
  // Design Team
  'fela-design': {
    roles: ['ui-designer', 'ux-designer', 'product-designer'],
    skills: ['figma', 'sketch', 'adobe-xd', 'ui-design', 'ux-design', 'wireframing', 'prototyping'],
    expertise: ['user-research', 'interaction-design', 'visual-design', 'design-systems'],
    keywords: ['design', 'ui', 'ux', 'interface', 'layout', 'wireframe', 'prototype', 'mockup']
  },
  
  'seun-video': {
    roles: ['video-editor', 'motion-designer'],
    skills: ['after-effects', 'premiere-pro', 'final-cut', 'video-editing', 'motion-graphics'],
    expertise: ['video-production', 'animation', 'motion-design', 'video-optimization'],
    keywords: ['video', 'animation', 'motion', 'edit', 'produce', 'render', 'graphics']
  },
  
  'femi-brand': {
    roles: ['brand-designer', 'graphic-designer'],
    skills: ['illustrator', 'photoshop', 'branding', 'logo-design', 'typography', 'color-theory'],
    expertise: ['brand-strategy', 'visual-identity', 'brand-guidelines', 'marketing-materials'],
    keywords: ['brand', 'logo', 'identity', 'style', 'guidelines', 'graphic', 'visual']
  },
  
  // Documentation Team
  'ebun-docs': {
    roles: ['technical-writer', 'documentation-specialist'],
    skills: ['technical-writing', 'markdown', 'asciidoc', 'documentation', 'content-creation'],
    expertise: ['api-documentation', 'user-guides', 'tutorials', 'knowledge-base'],
    keywords: ['documentation', 'docs', 'guide', 'tutorial', 'manual', 'write', 'content']
  },
  
  'ade-intel': {
    roles: ['market-researcher', 'business-analyst'],
    skills: ['research', 'analysis', 'data-analysis', 'market-research', 'competitive-analysis'],
    expertise: ['market-analysis', 'competitive-intelligence', 'trend-analysis', 'research-reports'],
    keywords: ['research', 'analysis', 'market', 'competitive', 'intelligence', 'data', 'report']
  },
  
  // Compliance Team
  'ruth-gdpr': {
    roles: ['compliance-officer', 'legal-analyst'],
    skills: ['compliance', 'gdpr', 'legal', 'privacy', 'regulation', 'audit'],
    expertise: ['gdpr-compliance', 'privacy-law', 'legal-review', 'compliance-audit'],
    keywords: ['gdpr', 'compliance', 'legal', 'privacy', 'regulation', 'audit', 'law']
  },
  
  'ngozi-payments': {
    roles: ['financial-analyst', 'payment-specialist'],
    skills: ['payments', 'financial', 'billing', 'invoicing', 'transactions', 'accounting'],
    expertise: ['payment-processing', 'financial-compliance', 'billing-systems', 'transaction-security'],
    keywords: ['payment', 'financial', 'billing', 'invoice', 'transaction', 'money', 'fee']
  },
  
  // Operations Team
  'shuri-ops': {
    roles: ['operations-analyst', 'process-engineer'],
    skills: ['process-improvement', 'workflow-optimization', 'operations', 'efficiency', 'analysis'],
    expertise: ['process-analysis', 'workflow-design', 'operational-efficiency', 'quality-gates'],
    keywords: ['process', 'operations', 'workflow', 'optimization', 'efficiency', 'analysis', 'quality']
  },
  
  'nova-strategy': {
    roles: ['strategic-planner', 'product-strategist'],
    skills: ['strategy', 'planning', 'roadmapping', 'vision', 'business-strategy', 'product-strategy'],
    expertise: ['strategic-planning', 'roadmap-development', 'business-analysis', 'market-positioning'],
    keywords: ['strategy', 'planning', 'roadmap', 'vision', 'direction', 'plan', 'strategic']
  },
  
  'chimamanda-comms': {
    roles: ['communications-specialist', 'content-strategist'],
    skills: ['communication', 'content-strategy', 'messaging', 'announcements', 'updates', 'news'],
    expertise: ['internal-communications', 'external-communications', 'content-strategy', 'messaging'],
    keywords: ['communication', 'message', 'announcement', 'update', 'news', 'content', 'communicate']
  },
  
  // Orchestration
  'clawdia-orchestrator': {
    roles: ['orchestrator', 'coordinator', 'approver'],
    skills: ['coordination', 'approval', 'decision-making', 'oversight', 'management'],
    expertise: ['cross-team-coordination', 'final-approval', 'decision-making', 'oversight'],
    keywords: ['orchestration', 'coordination', 'approval', 'final', 'review', 'oversee', 'manage']
  }
};

async function analyzeAndAssign() {
  try {
    const eventType = process.env.EVENT_TYPE;
    const eventPayload = JSON.parse(process.env.EVENT_PAYLOAD || '{}');
    
    core.info(`Analyzing ${eventType} event for agent assignment...`);
    
    let content = '';
    let author = '';
    let title = '';
    
    // Extract content based on event type
    switch (eventType) {
      case 'pull_request':
        content = (eventPayload.pull_request?.title || '') + ' ' + (eventPayload.pull_request?.body || '');
        author = eventPayload.pull_request?.user?.login || '';
        title = eventPayload.pull_request?.title || '';
        break;
        
      case 'issues':
        content = (eventPayload.issue?.title || '') + ' ' + (eventPayload.issue?.body || '');
        author = eventPayload.issue?.user?.login || '';
        title = eventPayload.issue?.title || '';
        break;
        
      case 'issue_comment':
        content = eventPayload.comment?.body || '';
        author = eventPayload.comment?.user?.login || '';
        title = eventPayload.issue?.title || '';
        break;
        
      default:
        core.warning(`Unsupported event type: ${eventType}`);
        return;
    }
    
    // Determine the best agent for this task
    const { agent, role, confidence, reason } = determineBestAgent(content, author, title);
    
    core.info(`Assigned to ${agent} (${role}) with ${confidence}% confidence`);
    core.info(`Reason: ${reason}`);
    
    // Set outputs for workflow
    core.setOutput('agent-assigned', 'true');
    core.setOutput('agent-name', agent);
    core.setOutput('agent-role', role);
    core.setOutput('confidence-score', confidence.toString());
    core.setOutput('assignment-reason', reason);
    
    // Determine task type
    const taskType = determineTaskType(content, title);
    core.setOutput('task-type', taskType);
    
    // Generate task description
    const taskDescription = generateTaskDescription(content, title, agent, role);
    core.setOutput('task-description', taskDescription);
    
  } catch (error) {
    core.error(`Failed to analyze and assign agent: ${error.message}`);
    core.setFailed(error.message);
  }
}

function determineBestAgent(content, author, title) {
  const normalizedContent = (content + ' ' + title).toLowerCase();
  
  // Check if author is an agent
  const authorAgent = Object.keys(AGENT_SPECIALIZATION).find(agent => 
    agent.replace('-', '').includes(author.toLowerCase())
  );
  
  if (authorAgent) {
    return {
      agent: authorAgent,
      role: AGENT_SPECIALIZATION[authorAgent].roles[0],
      confidence: 95,
      reason: `Author ${author} is agent ${authorAgent}`
    };
  }
  
  // Score each agent based on content match
  const agentScores = [];
  
  for (const [agent, spec] of Object.entries(AGENT_SPECIALIZATION)) {
    let score = 0;
    let matchedKeywords = [];
    
    // Check keywords
    for (const keyword of spec.keywords) {
      if (normalizedContent.includes(keyword)) {
        score += 10;
        matchedKeywords.push(keyword);
      }
    }
    
    // Check skills
    for (const skill of spec.skills) {
      if (normalizedContent.includes(skill)) {
        score += 8;
      }
    }
    
    // Check expertise
    for (const expertise of spec.expertise) {
      if (normalizedContent.includes(expertise.replace('-', ' '))) {
        score += 12;
      }
    }
    
    if (score > 0) {
      agentScores.push({
        agent,
        role: spec.roles[0],
        score,
        matchedKeywords
      });
    }
  }
  
  // Sort by score
  agentScores.sort((a, b) => b.score - a.score);
  
  if (agentScores.length > 0) {
    const bestMatch = agentScores[0];
    const confidence = Math.min(90, Math.max(60, bestMatch.score));
    
    return {
      agent: bestMatch.agent,
      role: bestMatch.role,
      confidence,
      reason: `Matched keywords: ${bestMatch.matchedKeywords.join(', ')}`
    };
  }
  
  // Default to orchestrator for coordination tasks
  return {
    agent: 'clawdia-orchestrator',
    role: 'orchestrator',
    confidence: 50,
    reason: 'No specific agent match, defaulting to orchestrator for coordination'
  };
}

function determineTaskType(content, title) {
  const normalizedContent = (content + ' ' + title).toLowerCase();
  
  if (normalizedContent.includes('bug') || normalizedContent.includes('error') || normalizedContent.includes('fix')) {
    return 'bug-fix';
  } else if (normalizedContent.includes('feature') || normalizedContent.includes('enhancement')) {
    return 'feature-development';
  } else if (normalizedContent.includes('design') || normalizedContent.includes('ui') || normalizedContent.includes('ux')) {
    return 'design-task';
  } else if (normalizedContent.includes('documentation') || normalizedContent.includes('docs')) {
    return 'documentation';
  } else if (normalizedContent.includes('test') || normalizedContent.includes('qa')) {
    return 'testing';
  } else if (normalizedContent.includes('security') || normalizedContent.includes('compliance')) {
    return 'security-compliance';
  } else if (normalizedContent.includes('research') || normalizedContent.includes('analysis')) {
    return 'research-analysis';
  } else if (normalizedContent.includes('process') || normalizedContent.includes('operations')) {
    return 'operations';
  } else if (normalizedContent.includes('strategy') || normalizedContent.includes('planning')) {
    return 'strategy-planning';
  } else if (normalizedContent.includes('communication') || normalizedContent.includes('message')) {
    return 'communication';
  }
  
  return 'general-task';
}

function generateTaskDescription(content, title, agent, role) {
  const taskType = determineTaskType(content, title);
  
  const descriptions = {
    'bug-fix': `Investigate and fix the issue described in: ${title}`,
    'feature-development': `Implement the feature described in: ${title}`,
    'design-task': `Create design assets for: ${title}`,
    'documentation': `Document the topic: ${title}`,
    'testing': `Test the functionality: ${title}`,
    'security-compliance': `Review security/compliance aspects: ${title}`,
    'research-analysis': `Research and analyze: ${title}`,
    'operations': `Handle operational task: ${title}`,
    'strategy-planning': `Develop strategy/plan for: ${title}`,
    'communication': `Handle communication regarding: ${title}`,
    'general-task': `Complete task: ${title}`
  };
  
  return descriptions[taskType] || `Complete assigned task: ${title}`;
}

// Run the analysis
if (require.main === module) {
  analyzeAndAssign();
}

module.exports = { analyzeAndAssign, determineBestAgent, determineTaskType };