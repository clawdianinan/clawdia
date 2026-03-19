# PRDForge Security Integration Guide

## Overview

This guide explains how to integrate the security monitoring and intrusion detection systems into your PRDForge application.

## 1. Security Monitoring System

### 1.1 Installation

Add the security monitoring module to your project:

```typescript
import { securityMonitor, SecurityLogger } from './src/utils/securityMonitoring';
```

### 1.2 Basic Usage

#### Logging Security Events
```typescript
// Log authentication failure
SecurityLogger.authFailure('user123', '192.168.1.100', 'Chrome/120.0', {
  reason: 'Invalid password',
  attemptCount: 3
});

// Log authentication success
SecurityLogger.authSuccess('user123', '192.168.1.100', 'Chrome/120.0');

// Log suspicious activity
SecurityLogger.suspiciousActivity('api', 'user123', {
  endpoint: '/api/sensitive-data',
  action: 'Unusual access pattern'
});

// Log API abuse
SecurityLogger.apiAbuse('/api/users', '192.168.1.100', {
  requestCount: 1000,
  timeWindow: '1 minute'
});
```

#### Configuring Alerts
```typescript
import { securityMonitor } from './src/utils/securityMonitoring';

// Configure alert settings
securityMonitor.configure({
  enabled: true,
  severityThreshold: 'HIGH', // Only alert on HIGH and CRITICAL events
  notificationChannels: ['EMAIL', 'SLACK'],
  cooldownPeriod: 300000 // 5 minutes
});

// Listen for security events
securityMonitor.on('securityEvent', (event) => {
  console.log('Security event detected:', event);
});

// Listen for alerts
securityMonitor.on('alert', (alert) => {
  console.log('Security alert triggered:', alert);
  // Send notifications via your preferred channels
});
```

### 1.3 Monitoring Dashboard

Create a security dashboard using the monitoring statistics:

```typescript
const stats = securityMonitor.getStatistics();
console.log('Security Statistics:', stats);

// Get recent events
const recentEvents = securityMonitor.getRecentEvents(50);
console.log('Recent Security Events:', recentEvents);

// Get events by type
const authFailures = securityMonitor.getEventsByType('AUTH_FAILURE', 20);
console.log('Recent Auth Failures:', authFailures);
```

## 2. Intrusion Detection Middleware

### 2.1 Installation for Express.js

First, install Express if not already installed:

```bash
npm install express
npm install @types/express --save-dev
```

### 2.2 Integration with Express

```typescript
import express from 'express';
import { intrusionDetectionMiddleware } from './src/middleware/intrusionDetection';

const app = express();

// Apply intrusion detection middleware
app.use(intrusionDetectionMiddleware);

// Store middleware instance for access
app.locals.intrusionDetection = intrusionDetectionMiddleware;

// Your routes
app.get('/api/data', (req, res) => {
  res.json({ message: 'Secure data' });
});

app.post('/auth/login', (req, res) => {
  // Authentication logic
  if (/* invalid credentials */) {
    res.status(401).json({ error: 'Invalid credentials' });
    // Auth failure will be automatically logged by middleware
  } else {
    res.json({ token: 'jwt-token' });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

### 2.3 Custom Configuration

```typescript
import { IntrusionDetectionMiddleware } from './src/middleware/intrusionDetection';

const customConfig = {
  rateLimits: {
    global: { windowMs: 10 * 60 * 1000, maxRequests: 500 },
    auth: { windowMs: 15 * 60 * 1000, maxRequests: 10 },
    api: { windowMs: 60 * 60 * 1000, maxRequests: 2000 }
  },
  bruteForceProtection: {
    enabled: true,
    maxAttempts: 10,
    lockoutTime: 60 * 60 * 1000 // 1 hour
  },
  suspiciousPatterns: {
    sqlInjection: true,
    xss: true,
    pathTraversal: true
  }
};

const customMiddleware = new IntrusionDetectionMiddleware(customConfig);
app.use(customMiddleware.middleware());
```

### 2.4 Monitoring and Statistics

```typescript
// Get intrusion detection statistics
const stats = intrusionDetectionMiddleware.getStatistics();
console.log('Intrusion Detection Stats:', stats);

// Regular cleanup of expired data
setInterval(() => {
  intrusionDetectionMiddleware.cleanup();
}, 60 * 60 * 1000); // Every hour
```

## 3. Incident Response Integration

### 3.1 Automated Incident Detection

Configure your security monitoring to trigger incident response procedures:

```typescript
securityMonitor.on('alert', (alert) => {
  if (alert.severity === 'CRITICAL' || alert.severity === 'HIGH') {
    // Trigger incident response
    triggerIncidentResponse(alert);
  }
});

async function triggerIncidentResponse(alert: any) {
  // 1. Create incident ticket
  const incidentId = await createJiraTicket(alert);
  
  // 2. Notify response team
  await notifyResponseTeam(incidentId, alert);
  
  // 3. Update status page
  await updateStatusPage(incidentId, 'investigating');
  
  // 4. Log incident
  SecurityLogger.suspiciousActivity('incident', undefined, {
    incidentId,
    alertType: alert.eventType,
    severity: alert.severity
  });
}
```

### 3.2 Integration with Monitoring Tools

```typescript
// Integrate with Datadog/Sentry/New Relic
import * as datadog from 'datadog-metrics';

securityMonitor.on('securityEvent', (event) => {
  // Send to Datadog
  datadog.gauge('security.events.count', 1);
  datadog.increment(`security.events.${event.type.toLowerCase()}`, 1);
  
  // Send to Sentry for error tracking
  if (event.severity === 'HIGH' || event.severity === 'CRITICAL') {
    Sentry.captureMessage(`Security event: ${event.type}`, {
      level: 'error',
      extra: event
    });
  }
});
```

## 4. Backup and Disaster Recovery Integration

### 4.1 Automated Backup Monitoring

```typescript
import { SecurityLogger } from './src/utils/securityMonitoring';

// Example backup completion handler
async function handleBackupCompletion(backupResult: any) {
  if (backupResult.success) {
    SecurityLogger.backupCompleted(
      backupResult.type,
      backupResult.size,
      backupResult.location
    );
    
    // Verify backup integrity
    const isValid = await verifyBackupIntegrity(backupResult);
    if (!isValid) {
      SecurityLogger.suspiciousActivity('backup', undefined, {
        backupId: backupResult.id,
        issue: 'Backup integrity check failed'
      });
    }
  } else {
    SecurityLogger.backupFailed(
      backupResult.type,
      backupResult.error
    );
    
    // Trigger backup retry or alert
    triggerBackupFailureProcedure(backupResult);
  }
}

// Schedule regular backup checks
setInterval(async () => {
  const lastBackup = await getLastBackupStatus();
  const hoursSinceBackup = (Date.now() - lastBackup.timestamp) / (1000 * 60 * 60);
  
  if (hoursSinceBackup > 24) {
    SecurityLogger.suspiciousActivity('backup', undefined, {
      issue: 'No backup in last 24 hours',
      lastBackupTime: lastBackup.timestamp
    });
  }
}, 60 * 60 * 1000); // Check every hour
```

### 4.2 Disaster Recovery Automation

```typescript
// Monitor system health for disaster recovery triggers
import { securityMonitor } from './src/utils/securityMonitoring';

class DisasterRecoveryMonitor {
  private healthChecks: Map<string, number> = new Map();
  
  constructor() {
    // Regular health checks
    setInterval(() => this.runHealthChecks(), 5 * 60 * 1000); // Every 5 minutes
  }
  
  async runHealthChecks() {
    const checks = [
      this.checkDatabaseConnectivity(),
      this.checkStorageAvailability(),
      this.checkExternalServices(),
      this.checkSystemResources()
    ];
    
    const results = await Promise.all(checks);
    const failures = results.filter(r => !r.healthy);
    
    if (failures.length > 0) {
      securityMonitor.logEvent({
        type: 'SYSTEM_INTEGRITY_ALERT',
        severity: failures.length > 2 ? 'HIGH' : 'MEDIUM',
        source: 'disaster-recovery',
        details: {
          failedChecks: failures.map(f => f.name),
          totalChecks: checks.length
        }
      });
      
      // Trigger recovery procedures if critical
      if (failures.length > 2) {
        await this.triggerDisasterRecovery();
      }
    }
  }
  
  async triggerDisasterRecovery() {
    securityMonitor.logEvent({
      type: 'DISASTER_RECOVERY_TRIGGERED',
      severity: 'CRITICAL',
      source: 'disaster-recovery',
      details: {
        trigger: 'Multiple system failures detected',
        timestamp: new Date().toISOString()
      }
    });
    
    // Execute DR procedures
    await this.failoverToDRSite();
    await this.notifyRecoveryTeam();
    await this.updateStatusPage();
  }
}
```

## 5. Testing and Validation

### 5.1 Unit Tests

Create tests for security components:

```typescript
// securityMonitoring.test.ts
import { securityMonitor, SecurityLogger } from './src/utils/securityMonitoring';

describe('Security Monitoring', () => {
  beforeEach(() => {
    // Clear event log before each test
    securityMonitor.clearOldEvents(0);
  });
  
  test('should log authentication failure', () => {
    const event = SecurityLogger.authFailure('user123', '192.168.1.1');
    expect(event.type).toBe('AUTH_FAILURE');
    expect(event.severity).toBe('MEDIUM');
  });
  
  test('should detect brute force attempts', () => {
    // Simulate multiple failed attempts
    for (let i = 0; i < 6; i++) {
      SecurityLogger.authFailure('user123', '192.168.1.1');
    }
    
    const events = securityMonitor.getEventsByType('BRUTE_FORCE_ATTEMPT');
    expect(events.length).toBeGreaterThan(0);
  });
});
```

### 5.2 Integration Tests

```typescript
// intrusionDetection.test.ts
import request from 'supertest';
import express from 'express';
import { intrusionDetectionMiddleware } from './src/middleware/intrusionDetection';

describe('Intrusion Detection Middleware', () => {
  let app: express.Application;
  
  beforeEach(() => {
    app = express();
    app.use(express.json());
    app.use(intrusionDetectionMiddleware);
    
    app.get('/api/test', (req, res) => {
      res.json({ message: 'OK' });
    });
    
    app.post('/auth/login', (req, res) => {
      res.status(401).json({ error: 'Invalid credentials' });
    });
  });
  
  test('should block excessive requests', async () => {
    // Make more requests than allowed
    for (let i = 0; i < 11; i++) {
      await request(app).post('/auth/login').send({});
    }
    
    // 11th request should be blocked
    const response = await request(app).post('/auth/login').send({});
    expect(response.status).toBe(429);
  });
});
```

## 6. Deployment and Configuration

### 6.1 Environment Variables

```bash
# Security Configuration
SECURITY_ALERTS_ENABLED=true
SECURITY_SEVERITY_THRESHOLD=MEDIUM
SECURITY_NOTIFICATION_CHANNELS=EMAIL,SLACK
SECURITY_ALERT_COOLDOWN=300000

# Intrusion Detection
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
BRUTE_FORCE_MAX_ATTEMPTS=5
BRUTE_FORCE_LOCKOUT_TIME=1800000

# Backup Configuration
BACKUP_SCHEDULE="0 2 * * *" # Daily at 2 AM
BACKUP_RETENTION_DAYS=30
BACKUP_VERIFICATION_ENABLED=true
```

### 6.2 Production Checklist

Before deploying security features to production:

- [ ] Configure real notification channels (Email, Slack, SMS)
- [ ] Set up monitoring dashboards
- [ ] Test backup and restore procedures
- [ ] Conduct security penetration testing
- [ ] Train incident response team
- [ ] Document escalation procedures
- [ ] Set up audit logging
- [ ] Configure automated security scanning

## 7. Maintenance and Updates

### 7.1 Regular Tasks

- **Daily:** Review security events and alerts
- **Weekly:** Analyze security statistics and trends
- **Monthly:** Update security rules and patterns
- **Quarterly:** Test incident response procedures
- **Annually:** Review and update security policies

### 7.2 Security Updates

Keep security components updated:

```bash
# Check for security vulnerabilities
npm audit

# Update dependencies
npm update

# Run security tests
npm test -- --coverage
```

## 8. Support and Troubleshooting

### Common Issues and Solutions

1. **High false positive rate:**
   - Adjust severity thresholds
   - Fine-tune detection patterns
   - Review and whitelist legitimate patterns

2. **Performance impact:**
   - Optimize database queries
   - Implement caching for frequent checks
   - Consider asynchronous processing

3. **Alert fatigue:**
   - Increase cooldown periods
   - Group related alerts
   - Implement intelligent alert routing

### Getting Help

- **Security Issues:** security@prdforge.com
- **Technical Support:** support@prdforge.com
- **Emergency:** +1-XXX-XXX-XXXX (24/7)

---

**Last Updated:** 2026-03-18  
**Version:** 1.0  
**Author:** Cypher Security Team