#!/usr/bin/env node
// PRDForge Test Tracker - Simplified Version
// Works with consolidated master documents

const fs = require('fs');
const path = require('path');

// Read test status from testing master
function getTestStatus() {
  try {
    const content = fs.readFileSync(
      path.join(__dirname, 'PRDFORGE_TESTING_MASTER.md'), 
      'utf8'
    );
    
    // Extract test coverage section
    const coverageMatch = content.match(/Test Coverage:[\s\S]*?OVERALL[\s\S]*?(\d+)\s*\/\s*(\d+)/);
    const overallMatch = content.match(/OVERALL\s+(\d+)\s+(\d+)\s+(\d+)%/);
    
    if (overallMatch) {
      return {
        passed: parseInt(overallMatch[1]),
        total: parseInt(overallMatch[2]),
        percentage: parseInt(overallMatch[3])
      };
    }
  } catch (err) {
    // Fallback if file doesn't exist yet
    return { passed: 107, total: 232, percentage: 46 };
  }
}

// Get critical tests from testing master
function getCriticalTests() {
  const tests = [
    { id: 'EXPORT-001', name: 'Export Functionality Fix', status: '❌ FAIL', priority: 'P0 🚨' },
    { id: 'PAYMENT-001', name: 'Payment Flow ($9/$19 verification)', status: '⚠️ NOT TESTED', priority: 'P0 🚨' },
    { id: 'CREDIT-001', name: 'Credit System Validation', status: '⚠️ NOT TESTED', priority: 'P0 🚨' },
    { id: 'PRICING-001', name: 'Pricing Logic ($9/$19 correctness)', status: '⚠️ NOT TESTED', priority: 'P0 🚨' },
    { id: 'STATE-001', name: 'State Consistency Flow', status: '⚠️ NOT TESTED', priority: 'P0 🚨' }
  ];
  
  return tests;
}

// Get priority actions
function getPriorityActions() {
  return [
    { action: 'Fix export [object] bug', priority: '🚨 TODAY', estimate: '2-4 hours' },
    { action: 'Test payment flows ($9/$19 verification)', priority: '⚠️ TODAY', estimate: '1-2 hours' },
    { action: 'Rotate exposed credentials', priority: '⚠️ TODAY', estimate: '1-2 hours' },
    { action: 'Validate credit system end-to-end', priority: '⚠️ TODAY', estimate: '1-2 hours' },
    { action: 'Create critical user journey tests', priority: '⚠️ TOMORROW', estimate: '2-3 hours' }
  ];
}

// Display test tracker
function displayTracker() {
  const status = getTestStatus();
  const criticalTests = getCriticalTests();
  const priorityActions = getPriorityActions();
  
  console.log('📊 PRDForge Test Tracker');
  console.log('=======================\n');
  
  console.log(`🧪 OVERALL TEST STATUS: ${status.percentage}% (${status.passed}/${status.total})\n`);
  
  console.log('🚨 CRITICAL TEST SCENARIOS (P0):\n');
  criticalTests.forEach(test => {
    console.log(`${test.status} ${test.id}: ${test.name} (${test.priority})`);
  });
  
  console.log('\n🎯 PRIORITY TESTING ACTIONS (AGENT TIMING):\n');
  priorityActions.forEach((action, index) => {
    console.log(`${index + 1}. ${action.priority} ${action.action} (${action.estimate})`);
  });
  
  console.log('\n🔧 RECOMMENDED EXECUTION ORDER:');
  console.log('1. Fix export functionality (P0)');
  console.log('2. Test payment flows ($9/$19 verification)');
  console.log('3. Rotate exposed credentials');
  console.log('4. Validate credit system');
  console.log('5. Create user journey tests');
  
  console.log('\n📝 For detailed test cases, see:');
  console.log('• PRDFORGE_TESTING_MASTER.md');
  console.log('• PRDFORGE_PROJECT_MASTER.md');
  console.log('• PRDFORGE_SECURITY_MASTER.md');
  console.log('• PRDFORGE_AGENT_TEAM.md');
}

// Run the tracker
displayTracker();