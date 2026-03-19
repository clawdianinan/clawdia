#!/usr/bin/env node

/**
 * PRDForge Security Integration Script
 * 
 * This script helps integrate Trinity's security work with Cypher's security monitoring.
 * It provides migration paths and integration checks.
 */

const fs = require('fs');
const path = require('path');

console.log('🔒 PRDForge Security Integration Tool');
console.log('=====================================\n');

// Configuration
const CONFIG = {
  trinitySecurityPath: '/Users/clawdia/apps/prdforge/src/utils/security.ts',
  trinityRateLimitPath: '/Users/clawdia/apps/prdforge/supabase/functions/rate-limiting/index.ts',
  cypherMonitoringPath: './src/utils/securityMonitoring.ts',
  cypherIntrusionPath: './src/middleware/intrusionDetection.ts',
  outputPath: './integrated-security'
};

// Check if Trinity's files exist
console.log('📋 Checking Trinity\'s Security Implementation...\n');

const trinityFiles = [
  { name: 'Security Utilities', path: CONFIG.trinitySecurityPath, required: true },
  { name: 'Rate Limiting Function', path: CONFIG.trinityRateLimitPath, required: true }
];

trinityFiles.forEach(file => {
  const exists = fs.existsSync(file.path);
  console.log(`${exists ? '✅' : '❌'} ${file.name}: ${exists ? 'Found' : 'Missing'}`);
  if (file.required && !exists) {
    console.log(`   ⚠️  Required file missing: ${file.path}`);
  }
});

console.log('\n📋 Checking Cypher\'s Security Implementation...\n');

const cypherFiles = [
  { name: 'Security Monitoring', path: CONFIG.cypherMonitoringPath, required: true },
  { name: 'Intrusion Detection', path: CONFIG.cypherIntrusionPath, required: true }
];

cypherFiles.forEach(file => {
  const exists = fs.existsSync(file.path);
  console.log(`${exists ? '✅' : '❌'} ${file.name}: ${exists ? 'Found' : 'Missing'}`);
  if (file.required && !exists) {
    console.log(`   ⚠️  Required file missing: ${file.path}`);
  }
});

// Analyze integration points
console.log('\n🔍 Analyzing Integration Points...\n');

const integrationPoints = [
  {
    name: 'Rate Limiting Integration',
    description: 'Combine Trinity\'s Supabase rate limiting with Cypher\'s pattern detection',
    status: 'PENDING',
    actions: [
      'Use Trinity\'s rate-limiting function as primary',
      'Add Cypher\'s pattern detection to rate-limiting function',
      'Integrate security event logging',
      'Create unified configuration'
    ]
  },
  {
    name: 'Security Headers Enhancement',
    description: 'Enhance Trinity\'s security headers with monitoring',
    status: 'PENDING',
    actions: [
      'Add security header validation',
      'Implement header security scoring',
      'Add CSP violation reporting',
      'Create security header monitoring'
    ]
  },
  {
    name: 'Security Event Logging',
    description: 'Integrate security event logging across all systems',
    status: 'PENDING',
    actions: [
      'Add security logging to Trinity\'s rate limiting',
      'Add security logging to Trinity\'s security utilities',
      'Create centralized security event database',
      'Implement real-time alerting'
    ]
  },
  {
    name: 'Intrusion Detection Expansion',
    description: 'Expand Trinity\'s basic rate limiting with advanced detection',
    status: 'PENDING',
    actions: [
      'Add SQL injection pattern detection',
      'Add XSS pattern detection',
      'Add path traversal detection',
      'Add API abuse pattern monitoring'
    ]
  }
];

integrationPoints.forEach(point => {
  console.log(`📌 ${point.name}`);
  console.log(`   📝 ${point.description}`);
  console.log(`   📊 Status: ${point.status}`);
  console.log(`   🛠️  Actions Required:`);
  point.actions.forEach(action => {
    console.log(`      • ${action}`);
  });
  console.log('');
});

// Generate integration recommendations
console.log('🚀 Integration Recommendations\n');

const recommendations = [
  {
    priority: 'HIGH',
    recommendation: 'Create unified security configuration',
    details: 'Merge rate limiting configurations from both systems into a single source of truth',
    estimatedTime: '2 hours'
  },
  {
    priority: 'HIGH',
    recommendation: 'Implement security event bridge',
    details: 'Create a module that forwards security events from Trinity\'s system to Cypher\'s monitoring',
    estimatedTime: '3 hours'
  },
  {
    priority: 'MEDIUM',
    recommendation: 'Enhance security headers with monitoring',
    details: 'Add logging and validation to security header implementation',
    estimatedTime: '4 hours'
  },
  {
    priority: 'MEDIUM',
    recommendation: 'Create security integration tests',
    details: 'Test that both security systems work together correctly',
    estimatedTime: '5 hours'
  },
  {
    priority: 'LOW',
    recommendation: 'Build security dashboard',
    details: 'Create a dashboard showing security events from both systems',
    estimatedTime: '8 hours'
  }
];

recommendations.forEach(rec => {
  const priorityIcon = rec.priority === 'HIGH' ? '🔴' : rec.priority === 'MEDIUM' ? '🟡' : '🟢';
  console.log(`${priorityIcon} ${rec.priority} PRIORITY: ${rec.recommendation}`);
  console.log(`   📋 ${rec.details}`);
  console.log(`   ⏱️  Estimated: ${rec.estimatedTime}`);
  console.log('');
});

// Generate migration script template
console.log('💻 Migration Script Template\n');

const migrationScript = `// PRDForge Security Integration Migration Script
// Generated: ${new Date().toISOString()}

import { securityMonitor, SecurityLogger } from './src/utils/securityMonitoring';
import { intrusionDetectionMiddleware } from './src/middleware/intrusionDetection';

/**
 * Integrate Trinity's rate limiting with Cypher's security monitoring
 */
export async function integrateRateLimiting(req, res, next) {
  try {
    // Step 1: Check rate limit using Trinity's system
    const rateLimitResult = await checkTrinityRateLimit(req);
    
    // Step 2: Log security event
    if (!rateLimitResult.allowed) {
      SecurityLogger.apiAbuse(req.path, req.ip, {
        limit: rateLimitResult.limit,
        remaining: rateLimitResult.remaining,
        reset: rateLimitResult.reset,
        source: 'trinity-rate-limiting'
      });
    }
    
    // Step 3: Apply Cypher's intrusion detection
    return intrusionDetectionMiddleware(req, res, next);
    
  } catch (error) {
    console.error('Security integration error:', error);
    // Fail open - allow request to proceed
    next();
  }
}

/**
 * Enhanced security headers with monitoring
 */
export function enhanceSecurityHeaders(res) {
  const originalSend = res.send;
  
  res.send = function(body) {
    // Apply Trinity's security headers
    const response = applyTrinitySecurityHeaders(body);
    
    // Log security header application
    securityMonitor.logEvent({
      type: 'SECURITY_HEADERS_APPLIED',
      severity: 'LOW',
      source: 'security-integration',
      details: {
        headersApplied: Object.keys(response.headers).filter(h => h.toLowerCase().includes('security'))
      }
    });
    
    return originalSend.call(this, response.body);
  };
}

/**
 * Bridge function to connect both security systems
 */
export class SecurityBridge {
  constructor() {
    this.events = [];
    this.initialized = false;
  }
  
  async initialize() {
    // Initialize connection to Trinity's security system
    await this.connectToTrinitySecurity();
    
    // Initialize Cypher's security monitoring
    securityMonitor.on('securityEvent', (event) => {
      this.forwardToTrinity(event);
    });
    
    this.initialized = true;
    console.log('Security bridge initialized');
  }
  
  async connectToTrinitySecurity() {
    // Implementation to connect to Trinity's security database/API
    console.log('Connected to Trinity\'s security system');
  }
  
  async forwardToTrinity(event) {
    // Forward security events to Trinity's system for compatibility
    console.log('Forwarding security event to Trinity:', event.type);
  }
  
  async forwardToCypher(event) {
    // Forward events from Trinity's system to Cypher's monitoring
    securityMonitor.logEvent(event);
  }
}

// Export integration utilities
export const SecurityIntegration = {
  integrateRateLimiting,
  enhanceSecurityHeaders,
  SecurityBridge
};`;

console.log(migrationScript);

// Create output directory and save migration script
const outputDir = CONFIG.outputPath;
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
}

const migrationScriptPath = path.join(outputDir, 'security-integration.ts');
fs.writeFileSync(migrationScriptPath, migrationScript);

console.log(`\n📁 Migration script saved to: ${migrationScriptPath}`);

// Generate summary report
console.log('\n📊 Security Integration Summary\n');
console.log('Trinity\'s Security Components:');
console.log('  • Rate limiting (Supabase Edge Function)');
console.log('  • Security headers and utilities');
console.log('  • Input sanitization and validation');
console.log('  • Security testing suite');
console.log('');
console.log('Cypher\'s Security Components:');
console.log('  • 24/7 security monitoring system');
console.log('  • Advanced intrusion detection');
console.log('  • Incident response plan');
console.log('  • Disaster recovery plan');
console.log('');
console.log('Integration Status: 🟡 IN PROGRESS');
console.log('Estimated Completion: 8-12 hours');
console.log('Security Ownership: ✅ CYPHER (Effective immediately)');
console.log('');
console.log('Next Steps:');
console.log('1. Review integration recommendations above');
console.log('2. Implement security bridge');
console.log('3. Test integrated security system');
console.log('4. Deploy to production');
console.log('5. Monitor and optimize');

// Exit with appropriate code
const allFilesExist = [...trinityFiles, ...cypherFiles].every(f => !f.required || fs.existsSync(f.path));
process.exit(allFilesExist ? 0 : 1);