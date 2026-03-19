#!/usr/bin/env node

/**
 * Trinity (Coding Agent) Claude Code Integration Example
 * Shows how Trinity would use Claude Code for coding tasks
 */

const ClaudeCodeIntegration = require('./claude-code-integration.js');

class TrinityWithClaudeCode {
  constructor() {
    this.integration = new ClaudeCodeIntegration({
      debug: process.env.DEBUG === 'true'
    });
    
    this.agentName = 'trinity';
  }
  
  /**
   * Handle coding task with Claude Code assistance
   */
  async handleCodingTask(task, code = null) {
    console.log(`🤖 Trinity received task: ${task.substring(0, 100)}...\n`);
    
    // Build enhanced task with code if provided
    let enhancedTask = task;
    if (code) {
      enhancedTask = `${task}\n\nCode to analyze:\n\`\`\`\n${code}\n\`\`\``;
    }
    
    // Try to execute with Claude Code
    console.log('🔄 Attempting Claude Code execution...');
    const result = await this.integration.executeTask(enhancedTask, {
      agent: this.agentName,
      manualFallback: true
    });
    
    if (result.success) {
      console.log('✅ Claude Code execution successful!\n');
      return this.processClaudeResult(result);
    } else {
      console.log('⚠️  Automated execution failed, using manual fallback\n');
      return this.processManualFallback(result);
    }
  }
  
  /**
   * Process successful Claude Code result
   */
  processClaudeResult(result) {
    return {
      type: 'claude_automated',
      skills: result.skillsApplied,
      response: result.result,
      nextSteps: [
        'Review Claude Code suggestions',
        'Apply relevant changes to code',
        'Test implementation',
        'Commit changes if satisfactory'
      ]
    };
  }
  
  /**
   * Process manual fallback instructions
   */
  processManualFallback(result) {
    return {
      type: 'manual_fallback',
      skills: result.skillsApplied,
      instructions: result.instructions,
      nextSteps: [
        'Follow manual instructions to run Claude Code',
        'Copy enhanced prompt into interactive session',
        'Apply Claude Code suggestions to code',
        'Return with results'
      ]
    };
  }
  
  /**
   * Example: Code review task
   */
  async exampleCodeReview() {
    const code = `
function calculateTotal(items) {
  let total = 0;
  for (let i = 0; i < items.length; i++) {
    total += items[i].price * items[i].quantity;
  }
  return total;
}

function processOrder(order) {
  const total = calculateTotal(order.items);
  const tax = total * 0.08;
  const shipping = order.shippingMethod === 'express' ? 10 : 5;
  return total + tax + shipping;
}
    `;
    
    const task = 'Review this JavaScript code for security issues, performance improvements, and best practices';
    
    return await this.handleCodingTask(task, code);
  }
  
  /**
   * Example: React optimization task
   */
  async exampleReactOptimization() {
    const code = `
import React, { useState, useEffect } from 'react';
import HeavyComponent from './HeavyComponent';
import AnotherHeavyComponent from './AnotherHeavyComponent';
import { fetchUserData, fetchOrders, fetchProducts } from './api';

function UserDashboard({ userId }) {
  const [user, setUser] = useState(null);
  const [orders, setOrders] = useState([]);
  const [products, setProducts] = useState([]);
  
  useEffect(() => {
    fetchUserData(userId).then(setUser);
    fetchOrders(userId).then(setOrders);
    fetchProducts().then(setProducts);
  }, [userId]);
  
  if (!user) return <div>Loading...</div>;
  
  return (
    <div>
      <HeavyComponent data={user} />
      <AnotherHeavyComponent data={orders} />
      <ProductList products={products} />
    </div>
  );
}
    `;
    
    const task = 'Optimize this React component for performance, bundle size, and Next.js best practices';
    
    return await this.handleCodingTask(task, code);
  }
  
  /**
   * Example: Debugging task
   */
  async exampleDebugging() {
    const task = 'Debug why my Next.js app shows blank page after deployment. The app works locally but shows blank page in production.';
    
    return await this.handleCodingTask(task);
  }
  
  /**
   * Run all examples
   */
  async runExamples() {
    console.log('🚀 Trinity Claude Code Integration Examples\n');
    console.log('=' .repeat(60));
    
    // Example 1: Code Review
    console.log('\n📋 Example 1: Code Review');
    console.log('-' .repeat(40));
    const reviewResult = await this.exampleCodeReview();
    this.printResult(reviewResult);
    
    // Example 2: React Optimization
    console.log('\n📋 Example 2: React Optimization');
    console.log('-' .repeat(40));
    const reactResult = await this.exampleReactOptimization();
    this.printResult(reactResult);
    
    // Example 3: Debugging
    console.log('\n📋 Example 3: Debugging');
    console.log('-' .repeat(40));
    const debugResult = await this.exampleDebugging();
    this.printResult(debugResult);
    
    console.log('\n🎯 Summary');
    console.log('=' .repeat(60));
    console.log('Trinity can now use Claude Code with:');
    console.log('• Local Ollama model (qwen3.5:9b)');
    console.log('• Specialized skills (code review, React, debugging)');
    console.log('• Automated execution when possible');
    console.log('• Guaranteed manual fallback');
    console.log('\n🔧 Integration ready for production use!');
  }
  
  /**
   * Print result in readable format
   */
  printResult(result) {
    console.log(`Type: ${result.type}`);
    console.log(`Skills: ${result.skills.join(', ') || 'none'}`);
    
    if (result.type === 'claude_automated') {
      console.log(`Response preview: ${result.response.substring(0, 150)}...`);
    } else {
      console.log('Manual instructions generated');
    }
    
    console.log(`Next steps: ${result.nextSteps[0]}...`);
  }
}

// Run examples if called directly
if (require.main === module) {
  const trinity = new TrinityWithClaudeCode();
  
  const args = process.argv.slice(2);
  
  if (args.length === 0) {
    // Run all examples
    trinity.runExamples();
  } else if (args[0] === 'review') {
    // Run specific example
    trinity.exampleCodeReview().then(result => {
      console.log(JSON.stringify(result, null, 2));
    });
  } else if (args[0] === 'react') {
    trinity.exampleReactOptimization().then(result => {
      console.log(JSON.stringify(result, null, 2));
    });
  } else if (args[0] === 'debug') {
    trinity.exampleDebugging().then(result => {
      console.log(JSON.stringify(result, null, 2));
    });
  } else {
    // Custom task
    const task = args.join(' ');
    trinity.handleCodingTask(task).then(result => {
      console.log(JSON.stringify(result, null, 2));
    });
  }
}

module.exports = TrinityWithClaudeCode;