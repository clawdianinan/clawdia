/**
 * PRDForge Security Monitoring System
 * 24/7 Security Event Logging and Alerting
 * 
 * This module provides comprehensive security monitoring for PRDForge,
 * including event logging, suspicious activity detection, and alerting.
 */

import { EventEmitter } from 'events';

export interface SecurityEvent {
  id: string;
  timestamp: Date;
  type: SecurityEventType;
  severity: SecuritySeverity;
  source: string;
  userId?: string;
  ipAddress?: string;
  userAgent?: string;
  details: Record<string, any>;
  metadata?: Record<string, any>;
}

export type SecurityEventType = 
  | 'AUTH_FAILURE'
  | 'AUTH_SUCCESS'
  | 'RATE_LIMIT_EXCEEDED'
  | 'SUSPICIOUS_ACTIVITY'
  | 'API_ABUSE_DETECTED'
  | 'BRUTE_FORCE_ATTEMPT'
  | 'DATA_ACCESS_VIOLATION'
  | 'SYSTEM_INTEGRITY_ALERT'
  | 'BACKUP_COMPLETED'
  | 'BACKUP_FAILED'
  | 'DISASTER_RECOVERY_TRIGGERED';

export type SecuritySeverity = 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';

export interface AlertConfig {
  enabled: boolean;
  severityThreshold: SecuritySeverity;
  notificationChannels: NotificationChannel[];
  cooldownPeriod: number; // milliseconds
}

export type NotificationChannel = 'EMAIL' | 'SLACK' | 'WEBHOOK' | 'SMS';

export class SecurityMonitor extends EventEmitter {
  private eventLog: SecurityEvent[] = [];
  private failedLoginAttempts: Map<string, { count: number; lastAttempt: Date }> = new Map();
  private alertConfig: AlertConfig;
  private readonly MAX_FAILED_ATTEMPTS = 5;
  private readonly FAILED_ATTEMPT_WINDOW = 15 * 60 * 1000; // 15 minutes

  constructor(config: Partial<AlertConfig> = {}) {
    super();
    this.alertConfig = {
      enabled: true,
      severityThreshold: 'MEDIUM',
      notificationChannels: ['EMAIL', 'SLACK'],
      cooldownPeriod: 5 * 60 * 1000, // 5 minutes
      ...config
    };
  }

  /**
   * Log a security event
   */
  public logEvent(event: Omit<SecurityEvent, 'id' | 'timestamp'>): SecurityEvent {
    const fullEvent: SecurityEvent = {
      ...event,
      id: this.generateEventId(),
      timestamp: new Date()
    };

    this.eventLog.push(fullEvent);
    
    // Emit event for real-time processing
    this.emit('securityEvent', fullEvent);
    
    // Check if alert should be triggered
    this.evaluateAlert(fullEvent);
    
    // Track failed login attempts
    if (event.type === 'AUTH_FAILURE' && event.userId) {
      this.trackFailedLoginAttempt(event.userId, event.ipAddress);
    }
    
    // Log to console in development
    if (process.env.NODE_ENV === 'development') {
      console.log(`[SECURITY] ${fullEvent.type} - ${fullEvent.severity}:`, fullEvent.details);
    }
    
    return fullEvent;
  }

  /**
   * Track failed login attempts for brute force detection
   */
  private trackFailedLoginAttempt(userId: string, ipAddress?: string): void {
    const key = `${userId}|${ipAddress || 'unknown'}`;
    const now = new Date();
    
    const existing = this.failedLoginAttempts.get(key);
    if (existing) {
      // Check if within window
      const timeSinceLastAttempt = now.getTime() - existing.lastAttempt.getTime();
      if (timeSinceLastAttempt < this.FAILED_ATTEMPT_WINDOW) {
        existing.count++;
        existing.lastAttempt = now;
        
        // Check for brute force
        if (existing.count >= this.MAX_FAILED_ATTEMPTS) {
          this.logEvent({
            type: 'BRUTE_FORCE_ATTEMPT',
            severity: 'HIGH',
            source: 'auth',
            userId,
            ipAddress,
            details: {
              attemptCount: existing.count,
              timeWindow: this.FAILED_ATTEMPT_WINDOW,
              identifier: key
            }
          });
        }
      } else {
        // Reset if outside window
        this.failedLoginAttempts.set(key, { count: 1, lastAttempt: now });
      }
    } else {
      this.failedLoginAttempts.set(key, { count: 1, lastAttempt: now });
    }
  }

  /**
   * Evaluate if an event should trigger an alert
   */
  private evaluateAlert(event: SecurityEvent): void {
    if (!this.alertConfig.enabled) return;
    
    const severityLevels = { LOW: 1, MEDIUM: 2, HIGH: 3, CRITICAL: 4 };
    const eventLevel = severityLevels[event.severity];
    const thresholdLevel = severityLevels[this.alertConfig.severityThreshold];
    
    if (eventLevel >= thresholdLevel) {
      this.triggerAlert(event);
    }
  }

  /**
   * Trigger an alert for a security event
   */
  private triggerAlert(event: SecurityEvent): void {
    const alert = {
      eventId: event.id,
      timestamp: new Date(),
      eventType: event.type,
      severity: event.severity,
      source: event.source,
      details: event.details,
      notificationChannels: this.alertConfig.notificationChannels
    };
    
    this.emit('alert', alert);
    
    // In production, this would send notifications through configured channels
    this.sendNotifications(alert);
  }

  /**
   * Send notifications through configured channels
   */
  private sendNotifications(alert: any): void {
    // Implementation would integrate with actual notification services
    console.log(`[ALERT] Security alert triggered:`, alert);
    
    // TODO: Integrate with:
    // - Email service (SendGrid, AWS SES)
    // - Slack webhook
    // - SMS service (Twilio)
    // - Webhook endpoints
  }

  /**
   * Get recent security events
   */
  public getRecentEvents(limit: number = 100): SecurityEvent[] {
    return this.eventLog.slice(-limit);
  }

  /**
   * Get events by type
   */
  public getEventsByType(type: SecurityEventType, limit: number = 50): SecurityEvent[] {
    return this.eventLog
      .filter(event => event.type === type)
      .slice(-limit);
  }

  /**
   * Get events by severity
   */
  public getEventsBySeverity(severity: SecuritySeverity, limit: number = 50): SecurityEvent[] {
    return this.eventLog
      .filter(event => event.severity === severity)
      .slice(-limit);
  }

  /**
   * Clear old events (for memory management)
   */
  public clearOldEvents(maxAgeDays: number = 30): number {
    const cutoff = new Date();
    cutoff.setDate(cutoff.getDate() - maxAgeDays);
    
    const initialLength = this.eventLog.length;
    this.eventLog = this.eventLog.filter(event => event.timestamp > cutoff);
    
    return initialLength - this.eventLog.length;
  }

  /**
   * Generate unique event ID
   */
  private generateEventId(): string {
    return `sec_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * Get monitoring statistics
   */
  public getStatistics(): {
    totalEvents: number;
    eventsByType: Record<string, number>;
    eventsBySeverity: Record<SecuritySeverity, number>;
    recentAlerts: number;
  } {
    const eventsByType: Record<string, number> = {};
    const eventsBySeverity: Record<SecuritySeverity, number> = {
      LOW: 0,
      MEDIUM: 0,
      HIGH: 0,
      CRITICAL: 0
    };
    
    const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000);
    const recentAlerts = this.eventLog.filter(
      event => event.timestamp > oneHourAgo && 
      this.shouldTriggerAlert(event.severity)
    ).length;
    
    for (const event of this.eventLog) {
      eventsByType[event.type] = (eventsByType[event.type] || 0) + 1;
      eventsBySeverity[event.severity]++;
    }
    
    return {
      totalEvents: this.eventLog.length,
      eventsByType,
      eventsBySeverity,
      recentAlerts
    };
  }

  private shouldTriggerAlert(severity: SecuritySeverity): boolean {
    const severityLevels = { LOW: 1, MEDIUM: 2, HIGH: 3, CRITICAL: 4 };
    return severityLevels[severity] >= severityLevels[this.alertConfig.severityThreshold];
  }
}

// Export singleton instance for easy use
export const securityMonitor = new SecurityMonitor();

// Helper functions for common security events
export const SecurityLogger = {
  authFailure: (userId: string, ipAddress?: string, userAgent?: string, details?: Record<string, any>) => {
    return securityMonitor.logEvent({
      type: 'AUTH_FAILURE',
      severity: 'MEDIUM',
      source: 'auth',
      userId,
      ipAddress,
      userAgent,
      details: { reason: 'Invalid credentials', ...details }
    });
  },
  
  authSuccess: (userId: string, ipAddress?: string, userAgent?: string) => {
    return securityMonitor.logEvent({
      type: 'AUTH_SUCCESS',
      severity: 'LOW',
      source: 'auth',
      userId,
      ipAddress,
      userAgent,
      details: { action: 'User authenticated successfully' }
    });
  },
  
  suspiciousActivity: (source: string, userId?: string, details?: Record<string, any>) => {
    return securityMonitor.logEvent({
      type: 'SUSPICIOUS_ACTIVITY',
      severity: 'HIGH',
      source,
      userId,
      details: { ...details }
    });
  },
  
  apiAbuse: (endpoint: string, ipAddress: string, details?: Record<string, any>) => {
    return securityMonitor.logEvent({
      type: 'API_ABUSE_DETECTED',
      severity: 'HIGH',
      source: 'api',
      ipAddress,
      details: { endpoint, ...details }
    });
  },
  
  backupCompleted: (backupType: string, size: string, location: string) => {
    return securityMonitor.logEvent({
      type: 'BACKUP_COMPLETED',
      severity: 'LOW',
      source: 'backup',
      details: { backupType, size, location, status: 'success' }
    });
  },
  
  backupFailed: (backupType: string, error: string) => {
    return securityMonitor.logEvent({
      type: 'BACKUP_FAILED',
      severity: 'HIGH',
      source: 'backup',
      details: { backupType, error, status: 'failed' }
    });
  }
};