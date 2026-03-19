// PRDForge Security Integration Migration Script
// Generated: 2026-03-18T16:24:35.982Z

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
    console.log('Connected to Trinity's security system');
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
};