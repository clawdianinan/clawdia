#!/usr/bin/env node

/**
 * Claude Code Session Manager for OpenClaw
 * Manages interactive Claude Code sessions with Ollama models
 */

const { exec } = require('child_process');
const { spawn } = require('child_process');
const readline = require('readline');
const fs = require('fs');
const path = require('path');

class ClaudeCodeManager {
  constructor(options = {}) {
    this.options = {
      model: 'ollama/qwen3.5:9b',
      workspace: process.cwd(),
      timeout: 30000, // 30 seconds
      debug: false,
      ...options
    };
    
    this.session = null;
    this.sessionId = null;
    this.outputBuffer = '';
    this.resolvePromise = null;
    this.rejectPromise = null;
    this.securityConfirmed = false;
  }

  /**
   * Start a new Claude Code session
   */
  async startSession() {
    return new Promise((resolve, reject) => {
      this.resolvePromise = resolve;
      this.rejectPromise = reject;
      
      const env = {
        ...process.env,
        ANTHROPIC_API_KEY: 'ollama',
        ANTHROPIC_BASE_URL: 'http://localhost:11434/v1'
      };
      
      const args = [
        '--model', this.options.model,
        '--permission-mode', 'default'
      ];
      
      if (this.options.debug) {
        args.push('--debug');
      }
      
      this.log(`Starting Claude Code session with model: ${this.options.model}`);
      this.log(`Command: claude ${args.join(' ')}`);
      
      this.session = spawn('claude', args, {
        env,
        cwd: this.options.workspace,
        stdio: ['pipe', 'pipe', 'pipe']
      });
      
      this.sessionId = `claude-${Date.now()}`;
      
      // Set up output handlers
      this.session.stdout.on('data', (data) => {
        this.handleOutput(data.toString());
      });
      
      this.session.stderr.on('data', (data) => {
        this.handleError(data.toString());
      });
      
      this.session.on('close', (code) => {
        this.log(`Session closed with code: ${code}`);
        this.session = null;
        if (this.rejectPromise) {
          this.rejectPromise(new Error(`Session closed with code: ${code}`));
        }
      });
      
      this.session.on('error', (err) => {
        this.log(`Session error: ${err.message}`);
        if (this.rejectPromise) {
          this.rejectPromise(err);
        }
      });
      
      // Set timeout
      setTimeout(() => {
        if (this.resolvePromise) {
          this.rejectPromise(new Error('Session startup timeout'));
        }
      }, this.options.timeout);
    });
  }

  /**
   * Handle session output
   */
  handleOutput(data) {
    if (this.options.debug) {
      console.log(`[Claude Code Output]: ${data}`);
    }
    
    this.outputBuffer += data;
    
    // Check for security confirmation prompt
    if (!this.securityConfirmed && data.includes('Yes, I trust this folder')) {
      this.log('Security confirmation detected, sending "1" to confirm...');
      this.sendInput('1\n');
      this.securityConfirmed = true;
      return;
    }
    
    // Check for ready prompt (❯)
    if (data.includes('❯') && this.securityConfirmed) {
      this.log('Claude Code session ready');
      if (this.resolvePromise) {
        this.resolvePromise({
          sessionId: this.sessionId,
          status: 'ready',
          message: 'Claude Code session started successfully'
        });
        this.resolvePromise = null;
      }
    }
  }

  /**
   * Handle errors
   */
  handleError(data) {
    console.error(`[Claude Code Error]: ${data}`);
    
    // Check for common errors
    if (data.includes('Not logged in')) {
      this.rejectPromise(new Error('Claude Code authentication required. Run: claude auth login'));
    } else if (data.includes('model may not exist')) {
      this.rejectPromise(new Error(`Model ${this.options.model} not found. Check Ollama installation.`));
    }
  }

  /**
   * Send input to the session
   */
  sendInput(input) {
    if (!this.session || !this.session.stdin.writable) {
      throw new Error('Session not active');
    }
    
    this.session.stdin.write(input);
    this.log(`Sent input: ${input.trim()}`);
  }

  /**
   * Execute a command and wait for response
   */
  async executeCommand(command, waitForPrompt = true) {
    return new Promise((resolve, reject) => {
      if (!this.session) {
        reject(new Error('No active session'));
        return;
      }
      
      // Clear output buffer
      this.outputBuffer = '';
      
      // Set up response handler
      const responseHandler = (data) => {
        this.outputBuffer += data.toString();
        
        // Check for prompt indicating command completion
        if (waitForPrompt && data.includes('❯')) {
          this.session.stdout.removeListener('data', responseHandler);
          
          // Extract just the command output (remove the prompt)
          const lines = this.outputBuffer.split('\n');
          const response = lines
            .filter(line => !line.includes('❯') && line.trim() !== '')
            .join('\n')
            .trim();
          
          resolve(response);
        }
      };
      
      this.session.stdout.on('data', responseHandler);
      
      // Send the command
      this.sendInput(command + '\n');
      
      // If not waiting for prompt, resolve after short delay
      if (!waitForPrompt) {
        setTimeout(() => {
          this.session.stdout.removeListener('data', responseHandler);
          resolve(this.outputBuffer.trim());
        }, 2000);
      }
    });
  }

  /**
   * Stop the session
   */
  async stopSession() {
    if (this.session) {
      this.log('Stopping Claude Code session...');
      this.session.kill('SIGTERM');
      this.session = null;
      this.sessionId = null;
      this.securityConfirmed = false;
    }
  }

  /**
   * Quick one-off command execution
   */
  static async quickCommand(command, options = {}) {
    const manager = new ClaudeCodeManager(options);
    
    try {
      await manager.startSession();
      
      // Wait a bit for session to stabilize
      await new Promise(resolve => setTimeout(resolve, 2000));
      
      const result = await manager.executeCommand(command);
      await manager.stopSession();
      
      return result;
    } catch (error) {
      await manager.stopSession();
      throw error;
    }
  }

  /**
   * Logging helper
   */
  log(message) {
    if (this.options.debug) {
      console.log(`[ClaudeCodeManager] ${message}`);
    }
  }
}

// Export for use in OpenClaw
module.exports = ClaudeCodeManager;

// CLI interface
if (require.main === module) {
  const args = process.argv.slice(2);
  
  if (args.length === 0) {
    console.log(`
Claude Code Manager for OpenClaw

Usage:
  node claude-code-manager.js <command> [options]

Commands:
  start          Start a Claude Code session
  run <cmd>      Run a single command
  test           Test Claude Code integration

Options:
  --model <model>    Model to use (default: ollama/qwen3.5:9b)
  --debug            Enable debug output
  --workspace <path> Workspace directory

Examples:
  node claude-code-manager.js start --debug
  node claude-code-manager.js run "Write a Python function" --model ollama/qwen3.5:9b
    `);
    process.exit(0);
  }
  
  const command = args[0];
  const options = {};
  
  // Parse options
  for (let i = 1; i < args.length; i++) {
    if (args[i] === '--model' && args[i + 1]) {
      options.model = args[ + 1];
      i++;
    } else if (args[i] === '--debug') {
      options.debug = true;
    } else if (args[i] === '--workspace' && args[i + 1]) {
      options.workspace = args[i + 1];
      i++;
    }
  }
  
  const manager = new ClaudeCodeManager(options);
  
  async function run() {
    try {
      switch (command) {
        case 'start':
          console.log('Starting Claude Code session...');
          const result = await manager.startSession();
          console.log('Session started:', result);
          
          // Keep session alive
          console.log('Session active. Press Ctrl+C to exit.');
          process.on('SIGINT', async () => {
            console.log('\nStopping session...');
            await manager.stopSession();
            process.exit(0);
          });
          break;
          
        case 'run':
          if (!args[1]) {
            console.error('Error: No command specified');
            process.exit(1);
          }
          const cmd = args.slice(1).join(' ').replace(/^"|"$/g, '');
          console.log(`Running command: ${cmd}`);
          const output = await manager.quickCommand(cmd, options);
          console.log('\nOutput:', output);
          break;
          
        case 'test':
          console.log('Testing Claude Code integration...');
          try {
            const testResult = await ClaudeCodeManager.quickCommand('Write "Hello, World!" in Python', options);
            console.log('✅ Test successful!');
            console.log('Output:', testResult);
          } catch (error) {
            console.error('❌ Test failed:', error.message);
            process.exit(1);
          }
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