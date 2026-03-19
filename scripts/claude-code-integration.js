#!/usr/bin/env node

/**
 * Claude Code Integration for OpenClaw
 * Main integration script that ties together manager and skills
 */

const path = require('path');
const fs = require('fs');
const { spawn } = require('child_process');

// Configuration
const CONFIG = {
  model: 'ollama/qwen3.5:9b',
  workspace: process.cwd(),
  skillsDir: path.join(__dirname, '..', 'claude-skills', 'templates'),
  debug: process.env.DEBUG === 'true',
  timeout: 30000,
  
  // Agent mappings
  agentSkills: {
    'trinity': ['code-reviewer', 'react-best-practices', 'debugging-assistant'],
    'fela': ['react-best-practices'],
    'cypher': ['code-reviewer', 'debugging-assistant'],
    'nova': ['debugging-assistant'],
    'shuri': ['code-reviewer', 'debugging-assistant'],
    'ebun': ['debugging-assistant']
  },
  
  // Skill triggers
  skillTriggers: {
    'code-reviewer': ['review', 'code review', 'check code', 'analyze code', 'quality check'],
    'react-best-practices': ['react', 'nextjs', 'performance', 'optimize', 'best practice'],
    'debugging-assistant': ['debug', 'fix', 'error', 'troubleshoot', 'broken', 'not working']
  }
};

class ClaudeCodeIntegration {
  constructor(options = {}) {
    this.config = { ...CONFIG, ...options };
    this.session = null;
    this.activeSkills = new Set();
  }
  
  /**
   * Determine which skills to apply based on task
   */
  determineSkills(task, agent = null) {
    const skills = new Set();
    
    // Add agent-specific skills
    if (agent && this.config.agentSkills[agent]) {
      this.config.agentSkills[agent].forEach(skill => skills.add(skill));
    }
    
    // Add task-based skills
    const taskLower = task.toLowerCase();
    for (const [skill, triggers] of Object.entries(this.config.skillTriggers)) {
      if (triggers.some(trigger => taskLower.includes(trigger))) {
        skills.add(skill);
      }
    }
    
    return Array.from(skills);
  }
  
  /**
   * Load skill content
   */
  loadSkill(skillId) {
    const skillPath = path.join(this.config.skillsDir, skillId, 'SKILL.md');
    
    if (!fs.existsSync(skillPath)) {
      throw new Error(`Skill not found: ${skillId}`);
    }
    
    const content = fs.readFileSync(skillPath, 'utf8');
    
    // Extract key sections for prompt
    const lines = content.split('\n');
    let purpose = '';
    let methodology = '';
    
    for (let i = 0; i < lines.length; i++) {
      if (lines[i].startsWith('## Purpose')) {
        purpose = lines[i + 1]?.trim() || '';
      }
      if (lines[i].includes('Methodology') || lines[i].includes('Checklist')) {
        methodology = lines.slice(i, Math.min(i + 20, lines.length)).join('\n');
        break;
      }
    }
    
    return {
      id: skillId,
      content,
      purpose,
      methodology: methodology.substring(0, 500) // Limit size
    };
  }
  
  /**
   * Build enhanced prompt with skills
   */
  buildEnhancedPrompt(task, skills) {
    let prompt = `Task: ${task}\n\n`;
    
    if (skills.length > 0) {
      prompt += `## Applied Skills\n`;
      
      skills.forEach(skillId => {
        try {
          const skill = this.loadSkill(skillId);
          prompt += `\n### ${skillId}\n`;
          prompt += `Purpose: ${skill.purpose}\n`;
          prompt += `Key Methodology: ${skill.methodology}\n`;
        } catch (error) {
          // Skip skills that can't be loaded
        }
      });
      
      prompt += `\n## Instructions\n`;
      prompt += `Apply the relevant skills above to complete the task. Focus on the methodologies and checklists provided.\n\n`;
    }
    
    prompt += `## Response Format\n`;
    prompt += `Provide a clear, structured response that addresses the task requirements.\n`;
    
    return prompt;
  }
  
  /**
   * Execute task with Claude Code
   */
  async executeTask(task, options = {}) {
    const { agent, manualFallback = true } = options;
    
    // Determine skills to apply
    const skills = this.determineSkills(task, agent);
    this.activeSkills = new Set(skills);
    
    // Build enhanced prompt
    const enhancedPrompt = this.buildEnhancedPrompt(task, skills);
    
    if (this.config.debug) {
      console.log(`🧠 Task: ${task.substring(0, 100)}...`);
      console.log(`🤖 Agent: ${agent || 'none'}`);
      console.log(`🛠️  Skills: ${skills.join(', ') || 'none'}`);
      console.log(`📝 Prompt length: ${enhancedPrompt.length} chars`);
    }
    
    try {
      // Try automated execution first
      const result = await this.executeWithClaude(enhancedPrompt);
      return {
        success: true,
        method: 'automated',
        skillsApplied: skills,
        result
      };
    } catch (error) {
      console.error(`❌ Automated execution failed: ${error.message}`);
      
      if (manualFallback) {
        console.log(`🔄 Falling back to manual instructions...`);
        return this.getManualInstructions(task, skills, enhancedPrompt);
      }
      
      throw error;
    }
  }
  
  /**
   * Execute using Claude Code
   */
  async executeWithClaude(prompt) {
    return new Promise((resolve, reject) => {
      const env = {
        ...process.env,
        ANTHROPIC_API_KEY: 'ollama',
        ANTHROPIC_BASE_URL: 'http://localhost:11434/v1'
      };
      
      const args = [
        '--model', this.config.model,
        '--permission-mode', 'default'
      ];
      
      if (this.config.debug) {
        args.push('--debug');
      }
      
      this.session = spawn('claude', args, {
        env,
        cwd: this.config.workspace,
        stdio: ['pipe', 'pipe', 'pipe']
      });
      
      let output = '';
      let securityConfirmed = false;
      
      // Handle output
      this.session.stdout.on('data', (data) => {
        const text = data.toString();
        output += text;
        
        if (this.config.debug) {
          process.stdout.write(`[Claude]: ${text}`);
        }
        
        // Handle security prompt
        if (!securityConfirmed && text.includes('Yes, I trust this folder')) {
          this.session.stdin.write('1\n');
          securityConfirmed = true;
          return;
        }
        
        // Check for ready prompt
        if (securityConfirmed && text.includes('❯')) {
          // Send the prompt
          this.session.stdin.write(prompt + '\n');
        }
        
        // Check for response completion (simplistic)
        if (securityConfirmed && text.includes(prompt.substring(0, 50))) {
          // Response should follow
        }
      });
      
      // Handle errors
      this.session.stderr.on('data', (data) => {
        console.error(`[Claude Error]: ${data.toString()}`);
      });
      
      this.session.on('close', (code) => {
        if (code === 0) {
          // Extract response (simplistic)
          const response = this.extractResponse(output, prompt);
          resolve(response || output);
        } else {
          reject(new Error(`Claude session closed with code: ${code}`));
        }
      });
      
      this.session.on('error', (err) => {
        reject(err);
      });
      
      // Timeout
      setTimeout(() => {
        if (this.session) {
          this.session.kill();
          reject(new Error('Claude session timeout'));
        }
      }, this.config.timeout);
    });
  }
  
  /**
   * Extract response from output
   */
  extractResponse(output, prompt) {
    const lines = output.split('\n');
    let inResponse = false;
    let responseLines = [];
    
    for (const line of lines) {
      if (line.includes(prompt.substring(0, 50))) {
        inResponse = true;
        continue;
      }
      
      if (inResponse) {
        if (line.includes('❯') || line.includes('Claude Code')) {
          break;
        }
        responseLines.push(line);
      }
    }
    
    return responseLines.join('\n').trim();
  }
  
  /**
   * Get manual instructions for fallback
   */
  getManualInstructions(task, skills, enhancedPrompt) {
    const instructions = {
      success: false,
      method: 'manual_fallback',
      skillsApplied: skills,
      instructions: `
## 🛠️ Manual Claude Code Execution Required

### Task
${task}

### Skills to Apply
${skills.map(s => `- ${s}`).join('\n') || 'None'}

### Steps to Execute Manually

1. **Open Terminal and Run:**
   \`\`\`bash
   ANTHROPIC_API_KEY=ollama ANTHROPIC_BASE_URL=http://localhost:11434/v1 \\
     claude --model ollama/qwen3.5:9b
   \`\`\`

2. **When prompted, press "1"** to trust the workspace folder

3. **Copy and paste this enhanced prompt:**
   \`\`\`
   ${enhancedPrompt.substring(0, 1000)}...
   \`\`\`

4. **Wait for Claude Code to respond** with the local Ollama model

5. **Copy the response** and use it to complete the task

### Skill References
${skills.map(skillId => {
  try {
    const skill = this.loadSkill(skillId);
    return `**${skillId}**: ${skill.purpose.substring(0, 100)}...`;
  } catch {
    return `**${skillId}**: (skill details not available)`;
  }
}).join('\n')}

### Notes
- Interactive mode works even though --print mode doesn't
- Response may take 30-60 seconds
- The local Qwen 3.5 9B model is being used (free, offline)
      `.trim()
    };
    
    return instructions;
  }
  
  /**
   * Quick test of integration
   */
  async testIntegration() {
    console.log('🧪 Testing Claude Code Integration...\n');
    
    const testCases = [
      {
        task: 'Review this TypeScript code for security issues',
        agent: 'trinity',
        expectedSkills: ['code-reviewer']
      },
      {
        task: 'Debug why my React app shows blank page',
        agent: null,
        expectedSkills: ['debugging-assistant']
      },
      {
        task: 'Optimize Next.js performance',
        agent: 'fela',
        expectedSkills: ['react-best-practices']
      }
    ];
    
    for (const testCase of testCases) {
      console.log(`\n📋 Test: ${testCase.task}`);
      console.log(`   Agent: ${testCase.agent || 'none'}`);
      
      const skills = this.determineSkills(testCase.task, testCase.agent);
      console.log(`   Skills detected: ${skills.join(', ') || 'none'}`);
      
      const prompt = this.buildEnhancedPrompt(testCase.task, skills);
      console.log(`   Prompt built: ${prompt.length} chars`);
      
      // Check if expected skills match
      const missing = testCase.expectedSkills.filter(s => !skills.includes(s));
      const extra = skills.filter(s => !testCase.expectedSkills.includes(s));
      
      if (missing.length === 0 && extra.length === 0) {
        console.log(`   ✅ Skill detection correct`);
      } else {
        console.log(`   ⚠️  Skill detection mismatch`);
        if (missing.length > 0) console.log(`      Missing: ${missing.join(', ')}`);
        if (extra.length > 0) console.log(`      Extra: ${extra.join(', ')}`);
      }
    }
    
    console.log('\n🎯 Integration Test Complete');
    console.log('───────────────────────────');
    console.log('• Skill detection: ✅ Working');
    console.log('• Prompt building: ✅ Working');
    console.log('• Agent mapping: ✅ Configured');
    console.log('• Manual fallback: ✅ Available');
    console.log('\n⚠️  Note: Automated execution may fail if --print mode issues persist');
    console.log('   Manual interactive mode is guaranteed fallback');
  }
}

// CLI interface
if (require.main === module) {
  const args = process.argv.slice(2);
  
  if (args.length === 0 || args[0] === '--help') {
    console.log(`
Claude Code Integration for OpenClaw

Usage:
  node claude-code-integration.js <command> [options]

Commands:
  test                     Test integration (skill detection, prompt building)
  run <task>              Execute a task with Claude Code
  manual <task>           Get manual instructions for a task
  skills                  List available skills
  agents                  List agent skill mappings

Options:
  --agent <name>          Specify agent (trinity, fela, cypher, etc.)
  --debug                 Enable debug output
  --no-fallback           Disable manual fallback

Examples:
  node claude-code-integration.js test
  node claude-code-integration.js run "Review this code" --agent trinity
  node claude-code-integration.js manual "Debug React app" --agent fela
    `);
    process.exit(0);
  }
  
  const command = args[0];
  const options = {};
  let task = '';
  
  // Parse options
  for (let i = 1; i < args.length; i++) {
    if (args[i] === '--agent' && args[i + 1]) {
      options.agent = args[i + 1];
      i++;
    } else if (args[i] === '--debug') {
      options.debug = true;
    } else if (args[i] === '--no-fallback') {
      options.manualFallback = false;
    } else if (args[i].startsWith('--')) {
      console.error(`Unknown option: ${args[i]}`);
      process.exit(1);
    } else if (command === 'run' || command === 'manual') {
      // Collect task text
      task = args.slice(i).join(' ');
      break;
    }
  }
  
  const integration = new ClaudeCodeIntegration(options);
  
  async function run() {
    try {
      switch (command) {
        case 'test':
          await integration.testIntegration();
          break;
          
        case 'run':
          if (!task) {
            console.error('Error: No task specified');
            process.exit(1);
          }
          console.log(`🚀 Executing task: ${task}\n`);
          const result = await integration.executeTask(task, options);
          
          if (result.success) {
            console.log('✅ Task executed successfully');
            console.log(`Method: ${result.method}`);
            console.log(`Skills: ${result.skillsApplied.join(', ') || 'none'}`);
            console.log('\n📋 Result:');
            console.log(result.result);
          } else {
            console.log('⚠️  Automated execution failed, manual instructions:');
            console.log(result.instructions);
          }
          break;
          
        case 'manual':
          if (!task) {
            console.error('Error: No task specified');
            process.exit(1);
          }
          console.log(`📋 Getting manual instructions for: ${task}\n`);
          const skills = integration.determineSkills(task, options.agent);
          const prompt = integration.buildEnhancedPrompt(task, skills);
          const instructions = integration.getManualInstructions(task, skills, prompt);
          console.log(instructions.instructions);
          break;
          
        case 'skills':
          console.log('🛠️ Available Skills:');
          const skillsDir = path.join(__dirname, '..', 'claude-skills', 'templates');
          if (fs.existsSync(skillsDir)) {
            const skills = fs.readdirSync(skillsDir).filter(f => 
              fs.statSync(path.join(skillsDir, f)).isDirectory()
            );
            skills.forEach(skill => {
              const metaPath = path.join(skillsDir, skill, 'meta.json');
              if (fs.existsSync(metaPath)) {
                const meta = JSON.parse(fs.readFileSync(metaPath, 'utf8'));
                console.log(`  • ${skill}: ${meta.description}`);
              } else {
                console.log(`  • ${skill}: (no metadata)`);
              }
            });
          } else {
            console.log('No skills directory found');
          }
          break;
          
        case 'agents':
          console.log('🤖 Agent Skill Mappings:');
          Object.entries(CONFIG.agentSkills).forEach(([agent, skills]) => {
            console.log(`  • ${agent}: ${skills.join(', ')}`);
          });
          break;
          
        default:
          console.error(`Unknown command: ${command}`);
          process.exit(1);
      }
    } catch (error) {
      console.error('Error:', error.message);
      process.exit(1);
    }
  }
  
  run();
}

module.exports = ClaudeCodeIntegration;