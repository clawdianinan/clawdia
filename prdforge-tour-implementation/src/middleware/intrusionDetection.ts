/**
 * PRDForge Intrusion Detection System Middleware
 * 
 * This middleware provides rate limiting, API abuse detection,
 * and brute force attack prevention for PRDForge API endpoints.
 */

import { Request, Response, NextFunction } from 'express';
import { securityMonitor, SecurityLogger } from '../utils/securityMonitoring';

export interface RateLimitConfig {
  windowMs: number; // Time window in milliseconds
  maxRequests: number; // Maximum requests per window
  message?: string;
  statusCode?: number;
  skipSuccessfulRequests?: boolean;
}

export interface IntrusionDetectionConfig {
  rateLimits: {
    global: RateLimitConfig;
    auth: RateLimitConfig;
    api: RateLimitConfig;
  };
  bruteForceProtection: {
    enabled: boolean;
    maxAttempts: number;
    lockoutTime: number; // milliseconds
  };
  suspiciousPatterns: {
    sqlInjection: boolean;
    xss: boolean;
    pathTraversal: boolean;
  };
}

export class IntrusionDetectionMiddleware {
  private requestCounts: Map<string, { count: number; resetTime: number }> = new Map();
  private lockedIPs: Map<string, number> = new Map();
  private config: IntrusionDetectionConfig;

  constructor(config: Partial<IntrusionDetectionConfig> = {}) {
    this.config = {
      rateLimits: {
        global: { windowMs: 15 * 60 * 1000, maxRequests: 100, message: 'Too many requests, please try again later.', statusCode: 429 },
        auth: { windowMs: 15 * 60 * 1000, maxRequests: 5, message: 'Too many authentication attempts.', statusCode: 429 },
        api: { windowMs: 60 * 60 * 1000, maxRequests: 1000, message: 'API rate limit exceeded.', statusCode: 429 }
      },
      bruteForceProtection: {
        enabled: true,
        maxAttempts: 5,
        lockoutTime: 30 * 60 * 1000 // 30 minutes
      },
      suspiciousPatterns: {
        sqlInjection: true,
        xss: true,
        pathTraversal: true
      },
      ...config
    };
  }

  /**
   * Main middleware function
   */
  public middleware() {
    return (req: Request, res: Response, next: NextFunction) => {
      const ip = this.getClientIP(req);
      const path = req.path;
      const method = req.method;

      // Check if IP is locked out
      if (this.isIPLocked(ip)) {
        SecurityLogger.suspiciousActivity('intrusion', undefined, {
          ip,
          path,
          method,
          reason: 'IP is locked out due to previous violations'
        });
        return res.status(403).json({
          error: 'Access temporarily blocked due to security violations',
          retryAfter: this.getLockoutRemaining(ip)
        });
      }

      // Check for suspicious patterns in request
      if (this.detectSuspiciousPatterns(req)) {
        this.handleSuspiciousRequest(req, res, ip);
        return;
      }

      // Apply rate limiting based on endpoint type
      const rateLimitKey = this.getRateLimitKey(req, ip);
      const rateLimitConfig = this.getRateLimitConfig(req);

      if (!this.checkRateLimit(rateLimitKey, rateLimitConfig)) {
        SecurityLogger.apiAbuse(path, ip, {
          method,
          rateLimitKey,
          limit: rateLimitConfig.maxRequests,
          window: rateLimitConfig.windowMs
        });
        
        res.setHeader('Retry-After', Math.ceil(rateLimitConfig.windowMs / 1000));
        return res.status(rateLimitConfig.statusCode || 429).json({
          error: rateLimitConfig.message || 'Rate limit exceeded',
          retryAfter: Math.ceil(rateLimitConfig.windowMs / 1000)
        });
      }

      // Track authentication failures for brute force detection
      if (path.includes('/auth') || path.includes('/login')) {
        this.trackAuthAttempt(req, res, ip, next);
      } else {
        next();
      }
    };
  }

  /**
   * Get client IP address
   */
  private getClientIP(req: Request): string {
    return req.ip || 
           (req.headers['x-forwarded-for'] as string)?.split(',')[0] || 
           req.socket.remoteAddress || 
           'unknown';
  }

  /**
   * Get rate limit key for tracking
   */
  private getRateLimitKey(req: Request, ip: string): string {
    const path = req.path;
    
    if (path.includes('/auth') || path.includes('/login')) {
      return `auth:${ip}`;
    } else if (path.startsWith('/api/')) {
      return `api:${ip}:${path.split('/')[2] || 'general'}`;
    } else {
      return `global:${ip}`;
    }
  }

  /**
   * Get appropriate rate limit configuration
   */
  private getRateLimitConfig(req: Request): RateLimitConfig {
    const path = req.path;
    
    if (path.includes('/auth') || path.includes('/login')) {
      return this.config.rateLimits.auth;
    } else if (path.startsWith('/api/')) {
      return this.config.rateLimits.api;
    } else {
      return this.config.rateLimits.global;
    }
  }

  /**
   * Check rate limit for a key
   */
  private checkRateLimit(key: string, config: RateLimitConfig): boolean {
    const now = Date.now();
    const existing = this.requestCounts.get(key);

    if (!existing || now > existing.resetTime) {
      // Reset or create new entry
      this.requestCounts.set(key, {
        count: 1,
        resetTime: now + config.windowMs
      });
      return true;
    }

    if (existing.count >= config.maxRequests) {
      return false;
    }

    existing.count++;
    return true;
  }

  /**
   * Detect suspicious patterns in request
   */
  private detectSuspiciousPatterns(req: Request): boolean {
    if (!this.config.suspiciousPatterns) return false;

    const checkString = JSON.stringify({
      url: req.url,
      body: req.body,
      query: req.query,
      headers: req.headers
    }).toLowerCase();

    // SQL Injection patterns
    if (this.config.suspiciousPatterns.sqlInjection) {
      const sqlPatterns = [
        /(\%27)|(\')|(\-\-)|(\%23)|(#)/i,
        /((\%3D)|(=))[^\n]*((\%27)|(\')|(\-\-)|(\%3B)|(;))/i,
        /\w*((\%27)|(\'))((\%6F)|o|(\%4F))((\%72)|r|(\%52))/i,
        /((\%27)|(\'))union/i
      ];
      
      if (sqlPatterns.some(pattern => pattern.test(checkString))) {
        return true;
      }
    }

    // XSS patterns
    if (this.config.suspiciousPatterns.xss) {
      const xssPatterns = [
        /<script\b[^>]*>([\s\S]*?)<\/script>/i,
        /javascript:/i,
        /on\w+\s*=/i,
        /<iframe\b[^>]*>([\s\S]*?)<\/iframe>/i
      ];
      
      if (xssPatterns.some(pattern => pattern.test(checkString))) {
        return true;
      }
    }

    // Path traversal patterns
    if (this.config.suspiciousPatterns.pathTraversal) {
      const pathPatterns = [
        /\.\.\//,
        /\.\.\\/,
        /\/etc\/passwd/,
        /\/etc\/shadow/,
        /\/proc\/self/
      ];
      
      if (pathPatterns.some(pattern => pattern.test(checkString))) {
        return true;
      }
    }

    return false;
  }

  /**
   * Handle suspicious request
   */
  private handleSuspiciousRequest(req: Request, res: Response, ip: string): void {
    SecurityLogger.suspiciousActivity('intrusion', undefined, {
      ip,
      path: req.path,
      method: req.method,
      userAgent: req.headers['user-agent'],
      reason: 'Suspicious pattern detected'
    });

    // Increment violation count
    const violations = (this.lockedIPs.get(ip) || 0) + 1;
    this.lockedIPs.set(ip, violations);

    // Lock IP if too many violations
    if (violations >= 3) {
      this.lockIP(ip);
    }

    res.status(400).json({
      error: 'Invalid request detected',
      code: 'SECURITY_VIOLATION'
    });
  }

  /**
   * Track authentication attempts for brute force detection
   */
  private trackAuthAttempt(req: Request, res: Response, ip: string, next: NextFunction): void {
    if (!this.config.bruteForceProtection.enabled) {
      next();
      return;
    }

    // Store original send function
    const originalSend = res.send;
    const originalJson = res.json;

    // Override to detect authentication failures
    res.send = function(body: any) {
      if (res.statusCode === 401 || res.statusCode === 403) {
        // Authentication failed
        securityMonitor.logEvent({
          type: 'AUTH_FAILURE',
          severity: 'MEDIUM',
          source: 'auth',
          ipAddress: ip,
          userAgent: req.headers['user-agent'] as string,
          details: {
            path: req.path,
            method: req.method,
            statusCode: res.statusCode
          }
        });

        // Track for brute force detection
        const middleware = (this as any).req.app.locals.intrusionDetection;
        if (middleware) {
          middleware.recordAuthFailure(ip);
        }
      }
      return originalSend.call(this, body);
    };

    res.json = function(body: any) {
      if (res.statusCode === 401 || res.statusCode === 403) {
        // Authentication failed
        securityMonitor.logEvent({
          type: 'AUTH_FAILURE',
          severity: 'MEDIUM',
          source: 'auth',
          ipAddress: ip,
          userAgent: req.headers['user-agent'] as string,
          details: {
            path: req.path,
            method: req.method,
            statusCode: res.statusCode
          }
        });

        // Track for brute force detection
        const middleware = (this as any).req.app.locals.intrusionDetection;
        if (middleware) {
          middleware.recordAuthFailure(ip);
        }
      }
      return originalJson.call(this, body);
    };

    next();
  }

  /**
   * Record authentication failure for brute force detection
   */
  public recordAuthFailure(ip: string): void {
    if (!this.config.bruteForceProtection.enabled) return;

    const failures = (this.lockedIPs.get(`auth_failures:${ip}`) || 0) + 1;
    this.lockedIPs.set(`auth_failures:${ip}`, failures);

    if (failures >= this.config.bruteForceProtection.maxAttempts) {
      SecurityLogger.suspiciousActivity('intrusion', undefined, {
        ip,
        reason: 'Brute force attack detected',
        attemptCount: failures
      });
      
      this.lockIP(ip);
    }
  }

  /**
   * Lock an IP address
   */
  private lockIP(ip: string): void {
    const lockUntil = Date.now() + this.config.bruteForceProtection.lockoutTime;
    this.lockedIPs.set(`locked:${ip}`, lockUntil);

    SecurityLogger.suspiciousActivity('intrusion', undefined, {
      ip,
      reason: 'IP locked due to security violations',
      lockDuration: this.config.bruteForceProtection.lockoutTime
    });
  }

  /**
   * Check if IP is locked
   */
  private isIPLocked(ip: string): boolean {
    const lockTime = this.lockedIPs.get(`locked:${ip}`);
    if (!lockTime) return false;

    if (Date.now() > lockTime) {
      // Lock expired
      this.lockedIPs.delete(`locked:${ip}`);
      return false;
    }

    return true;
  }

  /**
   * Get remaining lockout time for IP
   */
  private getLockoutRemaining(ip: string): number {
    const lockTime = this.lockedIPs.get(`locked:${ip}`);
    if (!lockTime) return 0;

    const remaining = lockTime - Date.now();
    return Math.max(0, Math.ceil(remaining / 1000)); // Return in seconds
  }

  /**
   * Get intrusion detection statistics
   */
  public getStatistics(): {
    lockedIPs: number;
    totalRequests: number;
    blockedRequests: number;
    suspiciousPatternsDetected: number;
  } {
    const now = Date.now();
    let lockedIPs = 0;

    // Count active locks
    for (const [key, lockTime] of this.lockedIPs.entries()) {
      if (key.startsWith('locked:') && now < lockTime) {
        lockedIPs++;
      }
    }

    return {
      lockedIPs,
      totalRequests: this.requestCounts.size,
      blockedRequests: Array.from(this.requestCounts.values())
        .filter(entry => entry.count >= this.config.rateLimits.global.maxRequests)
        .length,
      suspiciousPatternsDetected: Array.from(this.lockedIPs.entries())
        .filter(([key]) => key.startsWith('auth_failures:'))
        .reduce((sum, [, count]) => sum + count, 0)
    };
  }

  /**
   * Clear expired data
   */
  public cleanup(): void {
    const now = Date.now();

    // Clear expired rate limits
    for (const [key, entry] of this.requestCounts.entries()) {
      if (now > entry.resetTime) {
        this.requestCounts.delete(key);
      }
    }

    // Clear expired locks
    for (const [key, lockTime] of this.lockedIPs.entries()) {
      if (key.startsWith('locked:') && now > lockTime) {
        this.lockedIPs.delete(key);
      }
    }

    // Clear old auth failures (keep for 1 hour)
    for (const [key] of this.lockedIPs.entries()) {
      if (key.startsWith('auth_failures:')) {
        // Simple cleanup - could be enhanced with timestamps
        if (Math.random() < 0.1) { // 10% chance to clean up on each cleanup call
          this.lockedIPs.delete(key);
        }
      }
    }
  }
}

// Export default middleware instance
export const intrusionDetection = new IntrusionDetectionMiddleware();

// Express middleware export
export const intrusionDetectionMiddleware = intrusionDetection.middleware();