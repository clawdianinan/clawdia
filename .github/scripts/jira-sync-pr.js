#!/usr/bin/env node

const core = require('@actions/core');
const github = require('@actions/github');
const axios = require('axios');

// Jira configuration
const JIRA_BASE_URL = process.env.JIRA_BASE_URL;
const JIRA_API_TOKEN = process.env.JIRA_API_TOKEN;
const JIRA_USER_EMAIL = process.env.JIRA_USER_EMAIL;

// GitHub context
const PR_NUMBER = process.env.PR_NUMBER;
const PR_TITLE = process.env.PR_TITLE;
const PR_BODY = process.env.PR_BODY;
const PR_STATE = process.env.PR_STATE;
const PR_AUTHOR = process.env.PR_AUTHOR;

// Agent mapping
const AGENT_MAPPING = {
  // Development Team
  'trinity-dev': ['backend', 'frontend', 'api', 'database', 'infrastructure'],
  'morpheus-qa': ['test', 'qa', 'testing', 'quality', 'validation'],
  'cypher-security': ['security', 'auth', 'encryption', 'vulnerability', 'compliance'],
  
  // Design Team
  'fela-design': ['design', 'ui', 'ux', 'interface', 'layout', 'visual'],
  'seun-video': ['video', 'animation', 'motion', 'media', 'graphics'],
  'femi-brand': ['brand', 'logo', 'identity', 'style', 'guidelines'],
  
  // Documentation Team
  'ebun-docs': ['documentation', 'docs', 'guide', 'tutorial', 'manual'],
  'ade-intel': ['research', 'analysis', 'market', 'competitive', 'intelligence'],
  
  // Compliance Team
  'ruth-gdpr': ['gdpr', 'compliance', 'legal', 'privacy', 'regulation'],
  'ngozi-payments': ['payment', 'financial', 'billing', 'invoice', 'transaction'],
  
  // Operations Team
  'shuri-ops': ['process', 'operations', 'workflow', 'optimization', 'efficiency'],
  'nova-strategy': ['strategy', 'planning', 'roadmap', 'vision', 'direction'],
  'chimamanda-comms': ['communication', 'message', 'announcement', 'update', 'news'],
  
  // Orchestration
  'clawdia-orchestrator': ['orchestration', 'coordination', 'approval', 'final', 'review']
};

// Jira issue key pattern
const JIRA_ISSUE_PATTERN = /([A-Z]+-\d+)/g;

async function syncPRToJira() {
  try {
    core.info(`Syncing PR #${PR_NUMBER} to Jira...`);
    
    // Extract Jira issue keys from PR title and body
    const jiraKeys = extractJiraKeys(PR_TITLE + ' ' + PR_BODY);
    
    if (jiraKeys.length === 0) {
      core.info('No Jira issue keys found in PR');
      return;
    }
    
    core.info(`Found Jira issues: ${jiraKeys.join(', ')}`);
    
    // Determine agent based on PR content
    const assignedAgent = determineAgent(PR_TITLE, PR_BODY, PR_AUTHOR);
    
    // Update each Jira issue
    for (const issueKey of jiraKeys) {
      await updateJiraIssue(issueKey, assignedAgent);
    }
    
    core.setOutput('jira-updates', jiraKeys.length);
    core.setOutput('assigned-agent', assignedAgent);
    
  } catch (error) {
    core.error(`Failed to sync PR to Jira: ${error.message}`);
    core.setFailed(error.message);
  }
}

function extractJiraKeys(text) {
  const matches = text.match(JIRA_ISSUE_PATTERN) || [];
  return [...new Set(matches)]; // Remove duplicates
}

function determineAgent(title, body, author) {
  const content = (title + ' ' + body).toLowerCase();
  
  // Check if author is an agent
  const authorAgent = Object.keys(AGENT_MAPPING).find(agent => 
    agent.replace('-', '').includes(author.toLowerCase())
  );
  
  if (authorAgent) {
    core.info(`Author ${author} is agent ${authorAgent}`);
    return authorAgent;
  }
  
  // Determine agent based on content
  let bestMatch = { agent: null, score: 0 };
  
  for (const [agent, keywords] of Object.entries(AGENT_MAPPING)) {
    let score = 0;
    for (const keyword of keywords) {
      if (content.includes(keyword)) {
        score++;
      }
    }
    
    if (score > bestMatch.score) {
      bestMatch = { agent, score };
    }
  }
  
  if (bestMatch.agent && bestMatch.score > 0) {
    core.info(`Assigned agent ${bestMatch.agent} with score ${bestMatch.score}`);
    return bestMatch.agent;
  }
  
  // Default to orchestrator for coordination
  core.info('No specific agent match, defaulting to orchestrator');
  return 'clawdia-orchestrator';
}

async function updateJiraIssue(issueKey, agent) {
  const jiraUrl = `${JIRA_BASE_URL}/rest/api/3/issue/${issueKey}`;
  
  // Get current issue
  const issueResponse = await axios.get(jiraUrl, {
    auth: {
      username: JIRA_USER_EMAIL,
      password: JIRA_API_TOKEN
    },
    headers: {
      'Accept': 'application/json'
    }
  });
  
  const currentIssue = issueResponse.data;
  
  // Prepare update payload
  const updatePayload = {
    update: {
      comment: [{
        add: {
          body: {
            type: 'doc',
            version: 1,
            content: [{
              type: 'paragraph',
              content: [{
                type: 'text',
                text: `GitHub PR #${PR_NUMBER} created: ${PR_TITLE}`
              }]
            }]
          }
        }
      }]
    },
    fields: {
      // Update status based on PR state
      status: mapPRStateToJiraStatus(PR_STATE),
      // Assign to agent if not already assigned
      assignee: currentIssue.fields.assignee ? undefined : {
        name: agent
      }
    }
  };
  
  // Update Jira issue
  await axios.put(jiraUrl, updatePayload, {
    auth: {
      username: JIRA_USER_EMAIL,
      password: JIRA_API_TOKEN
    },
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    }
  });
  
  core.info(`Updated Jira issue ${issueKey} for agent ${agent}`);
  
  // Add PR link as remote link
  await addPRLink(issueKey);
}

function mapPRStateToJiraStatus(prState) {
  const statusMap = {
    'open': 'In Progress',
    'closed': 'Done',
    'merged': 'Done'
  };
  
  return statusMap[prState] || 'In Progress';
}

async function addPRLink(issueKey) {
  const prUrl = `https://github.com/${process.env.GITHUB_REPOSITORY}/pull/${PR_NUMBER}`;
  
  const linkUrl = `${JIRA_BASE_URL}/rest/api/3/issue/${issueKey}/remotelink`;
  
  const linkPayload = {
    object: {
      url: prUrl,
      title: `GitHub PR #${PR_NUMBER}`,
      icon: {
        url16x16: 'https://github.githubassets.com/favicons/favicon.png',
        title: 'GitHub'
      }
    }
  };
  
  await axios.post(linkUrl, linkPayload, {
    auth: {
      username: JIRA_USER_EMAIL,
      password: JIRA_API_TOKEN
    },
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    }
  });
  
  core.info(`Added PR link to Jira issue ${issueKey}`);
}

// Run the sync
if (require.main === module) {
  syncPRToJira();
}

module.exports = { syncPRToJira, extractJiraKeys, determineAgent };