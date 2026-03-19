#!/usr/bin/env node

const core = require('@actions/core');
const axios = require('axios');

// Jira configuration
const JIRA_BASE_URL = process.env.JIRA_BASE_URL;
const JIRA_API_TOKEN = process.env.JIRA_API_TOKEN;
const JIRA_USER_EMAIL = process.env.JIRA_USER_EMAIL;

// GitHub context
const ISSUE_NUMBER = process.env.ISSUE_NUMBER;
const ISSUE_TITLE = process.env.ISSUE_TITLE;
const ISSUE_BODY = process.env.ISSUE_BODY;
const ISSUE_STATE = process.env.ISSUE_STATE;
const ISSUE_AUTHOR = process.env.ISSUE_AUTHOR;

// Agent mapping (reuse from PR script)
const AGENT_MAPPING = {
  'trinity-dev': ['backend', 'frontend', 'api', 'database', 'infrastructure'],
  'morpheus-qa': ['test', 'qa', 'testing', 'quality', 'validation'],
  'cypher-security': ['security', 'auth', 'encryption', 'vulnerability', 'compliance'],
  'fela-design': ['design', 'ui', 'ux', 'interface', 'layout', 'visual'],
  'seun-video': ['video', 'animation', 'motion', 'media', 'graphics'],
  'femi-brand': ['brand', 'logo', 'identity', 'style', 'guidelines'],
  'ebun-docs': ['documentation', 'docs', 'guide', 'tutorial', 'manual'],
  'ade-intel': ['research', 'analysis', 'market', 'competitive', 'intelligence'],
  'ruth-gdpr': ['gdpr', 'compliance', 'legal', 'privacy', 'regulation'],
  'ngozi-payments': ['payment', 'financial', 'billing', 'invoice', 'transaction'],
  'shuri-ops': ['process', 'operations', 'workflow', 'optimization', 'efficiency'],
  'nova-strategy': ['strategy', 'planning', 'roadmap', 'vision', 'direction'],
  'chimamanda-comms': ['communication', 'message', 'announcement', 'update', 'news'],
  'clawdia-orchestrator': ['orchestration', 'coordination', 'approval', 'final', 'review']
};

// Jira project mapping based on agent
const JIRA_PROJECT_MAPPING = {
  'trinity-dev': 'DEV',
  'morpheus-qa': 'DEV',
  'cypher-security': 'DEV',
  'fela-design': 'DES',
  'seun-video': 'DES',
  'femi-brand': 'DES',
  'ebun-docs': 'DOC',
  'ade-intel': 'DOC',
  'ruth-gdpr': 'COMP',
  'ngozi-payments': 'COMP',
  'shuri-ops': 'OPS',
  'nova-strategy': 'OPS',
  'chimamanda-comms': 'OPS',
  'clawdia-orchestrator': 'ORCH'
};

async function syncIssueToJira() {
  try {
    core.info(`Syncing GitHub Issue #${ISSUE_NUMBER} to Jira...`);
    
    // Determine agent based on issue content
    const assignedAgent = determineAgent(ISSUE_TITLE, ISSUE_BODY, ISSUE_AUTHOR);
    const jiraProject = JIRA_PROJECT_MAPPING[assignedAgent];
    
    if (!jiraProject) {
      core.error(`No Jira project mapping for agent ${assignedAgent}`);
      return;
    }
    
    // Create or update Jira issue
    const jiraIssueKey = await createOrUpdateJiraIssue(assignedAgent, jiraProject);
    
    // Add GitHub link to Jira issue
    await addGitHubLink(jiraIssueKey);
    
    // Update GitHub issue with Jira link
    await updateGitHubIssue(jiraIssueKey);
    
    core.setOutput('jira-issue-key', jiraIssueKey);
    core.setOutput('assigned-agent', assignedAgent);
    core.setOutput('jira-project', jiraProject);
    
  } catch (error) {
    core.error(`Failed to sync issue to Jira: ${error.message}`);
    core.setFailed(error.message);
  }
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
  
  // Default based on issue type
  if (content.includes('bug') || content.includes('error') || content.includes('fix')) {
    core.info('Issue appears to be a bug, assigning to development');
    return 'trinity-dev';
  } else if (content.includes('feature') || content.includes('enhancement')) {
    core.info('Issue appears to be a feature, assigning to development');
    return 'trinity-dev';
  } else if (content.includes('documentation') || content.includes('docs')) {
    core.info('Issue appears to be documentation, assigning to documentation');
    return 'ebun-docs';
  }
  
  // Default to orchestrator
  core.info('No specific agent match, defaulting to orchestrator');
  return 'clawdia-orchestrator';
}

async function createOrUpdateJiraIssue(agent, project) {
  const issueUrl = `${JIRA_BASE_URL}/rest/api/3/issue`;
  
  // Check if Jira issue already exists for this GitHub issue
  const existingIssueKey = await findExistingJiraIssue();
  
  if (existingIssueKey) {
    core.info(`Updating existing Jira issue ${existingIssueKey}`);
    await updateJiraIssue(existingIssueKey, agent);
    return existingIssueKey;
  }
  
  // Create new Jira issue
  core.info(`Creating new Jira issue in project ${project} for agent ${agent}`);
  
  const issuePayload = {
    fields: {
      project: {
        key: project
      },
      summary: `GitHub Issue #${ISSUE_NUMBER}: ${ISSUE_TITLE}`,
      description: {
        type: 'doc',
        version: 1,
        content: [
          {
            type: 'paragraph',
            content: [
              {
                type: 'text',
                text: ISSUE_BODY || 'No description provided'
              }
            ]
          },
          {
            type: 'paragraph',
            content: [
              {
                type: 'text',
                text: `\n\nGitHub Issue: https://github.com/${process.env.GITHUB_REPOSITORY}/issues/${ISSUE_NUMBER}`
              }
            ]
          }
        ]
      },
      issuetype: {
        name: mapIssueType(ISSUE_TITLE, ISSUE_BODY)
      },
      assignee: {
        name: agent
      },
      labels: [
        'github',
        'agent-assigned',
        agent.replace('-', '_')
      ],
      priority: {
        name: determinePriority(ISSUE_TITLE, ISSUE_BODY)
      }
    }
  };
  
  const response = await axios.post(issueUrl, issuePayload, {
    auth: {
      username: JIRA_USER_EMAIL,
      password: JIRA_API_TOKEN
    },
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    }
  });
  
  const jiraIssueKey = response.data.key;
  core.info(`Created Jira issue ${jiraIssueKey}`);
  
  return jiraIssueKey;
}

async function findExistingJiraIssue() {
  const searchUrl = `${JIRA_BASE_URL}/rest/api/3/search`;
  
  const jql = `summary ~ "GitHub Issue #${ISSUE_NUMBER}" AND labels = github`;
  
  const searchPayload = {
    jql: jql,
    maxResults: 1
  };
  
  try {
    const response = await axios.post(searchUrl, searchPayload, {
      auth: {
        username: JIRA_USER_EMAIL,
        password: JIRA_API_TOKEN
      },
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      }
    });
    
    if (response.data.issues && response.data.issues.length > 0) {
      return response.data.issues[0].key;
    }
  } catch (error) {
    core.warning(`Error searching for existing Jira issue: ${error.message}`);
  }
  
  return null;
}

async function updateJiraIssue(issueKey, agent) {
  const updateUrl = `${JIRA_BASE_URL}/rest/api/3/issue/${issueKey}`;
  
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
                text: `GitHub Issue #${ISSUE_NUMBER} ${ISSUE_STATE === 'closed' ? 'closed' : 'updated'}: ${ISSUE_TITLE}`
              }]
            }]
          }
        }
      }]
    },
    fields: {
      status: mapIssueStateToJiraStatus(ISSUE_STATE),
      assignee: {
        name: agent
      }
    }
  };
  
  await axios.put(updateUrl, updatePayload, {
    auth: {
      username: JIRA_USER_EMAIL,
      password: JIRA_API_TOKEN
    },
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    }
  });
  
  core.info(`Updated Jira issue ${issueKey}`);
}

function mapIssueType(title, body) {
  const content = (title + ' ' + body).toLowerCase();
  
  if (content.includes('bug') || content.includes('error') || content.includes('fix')) {
    return 'Bug';
  } else if (content.includes('feature') || content.includes('enhancement')) {
    return 'Story';
  } else if (content.includes('task') || content.includes('chore')) {
    return 'Task';
  } else if (content.includes('epic') || content.includes('major')) {
    return 'Epic';
  }
  
  return 'Task';
}

function determinePriority(title, body) {
  const content = (title + ' ' + body).toLowerCase();
  
  if (content.includes('critical') || content.includes('urgent') || content.includes('blocker')) {
    return 'Highest';
  } else if (content.includes('high') || content.includes('important')) {
    return 'High';
  } else if (content.includes('medium') || content.includes('normal')) {
    return 'Medium';
  } else if (content.includes('low') || content.includes('minor')) {
    return 'Low';
  }
  
  return 'Medium';
}

function mapIssueStateToJiraStatus(state) {
  const statusMap = {
    'open': 'To Do',
    'closed': 'Done'
  };
  
  return statusMap[state] || 'To Do';
}

async function addGitHubLink(jiraIssueKey) {
  const issueUrl = `https://github.com/${process.env.GITHUB_REPOSITORY}/issues/${ISSUE_NUMBER}`;
  
  const linkUrl = `${JIRA_BASE_URL}/rest/api/3/issue/${jiraIssueKey}/remotelink`;
  
  const linkPayload = {
    object: {
      url: issueUrl,
      title: `GitHub Issue #${ISSUE_NUMBER}`,
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
  
  core.info(`Added GitHub link to Jira issue ${jiraIssueKey}`);
}

async function updateGitHubIssue(jiraIssueKey) {
  // This would typically use GitHub API to add a comment with Jira link
  // For now, we'll just log it
  const jiraUrl = `${JIRA_BASE_URL}/browse/${jiraIssueKey}`;
  core.info(`Jira Issue Created: ${jiraUrl}`);
  
  // In a real implementation, you would:
  // 1. Use GitHub API to add comment to issue
  // 2. Include the Jira link
  // 3. Update issue labels if needed
}

// Run the sync
if (require.main === module) {
  syncIssueToJira();
}

module.exports = { syncIssueToJira, determineAgent };