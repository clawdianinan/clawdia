import * as Sentry from '@sentry/react';
import { BrowserTracing } from '@sentry/browser';

// Initialize Sentry with dynamic imports for better performance
let sentryInitialized = false;

/**
 * Initialize Sentry error tracking
 * Uses dynamic imports to avoid loading Sentry in development if not needed
 */
export async function initializeErrorTracking() {
  // Only initialize once
  if (sentryInitialized) {
    return;
  }

  try {
    // Get DSN from environment variables
    const dsn = import.meta.env.VITE_SENTRY_DSN;
    const environment = import.meta.env.VITE_SENTRY_ENVIRONMENT || 'development';
    const release = import.meta.env.VITE_SENTRY_RELEASE || 'prdforge@1.0.0';

    if (!dsn) {
      console.warn('Sentry DSN not found in environment variables. Error tracking disabled.');
      return;
    }

    // Initialize Sentry
    Sentry.init({
      dsn,
      environment,
      release,
      integrations: [
        new BrowserTracing({
          tracingOrigins: ['localhost', 'prdforge.com'],
        }),
      ],
      tracesSampleRate: environment === 'production' ? 0.1 : 1.0,
      beforeSend(event) {
        // Filter out development errors in production
        if (environment === 'production' && event.tags?.environment === 'development') {
          return null;
        }
        return event;
      },
    });

    sentryInitialized = true;
    console.log(`Sentry initialized for ${environment} environment`);
  } catch (error) {
    console.error('Failed to initialize Sentry:', error);
  }
}

/**
 * Report an error to Sentry
 * @param error Error object or string
 * @param context Additional context for the error
 */
export function reportError(error: Error | string, context?: Record<string, any>) {
  if (!sentryInitialized) {
    console.warn('Sentry not initialized. Error:', error, 'Context:', context);
    return;
  }

  if (typeof error === 'string') {
    Sentry.captureMessage(error, context);
  } else {
    Sentry.captureException(error, { extra: context });
  }
}

/**
 * Set user context for Sentry
 * @param user User object with id, email, username, etc.
 */
export function setUserContext(user: {
  id?: string;
  email?: string;
  username?: string;
  [key: string]: any;
}) {
  if (!sentryInitialized) {
    return;
  }

  Sentry.setUser(user);
}

/**
 * Clear user context
 */
export function clearUserContext() {
  if (!sentryInitialized) {
    return;
  }

  Sentry.setUser(null);
}

/**
 * Add breadcrumb for tracking user actions
 * @param message Breadcrumb message
 * @param category Breadcrumb category
 * @param data Additional data
 */
export function addBreadcrumb(
  message: string,
  category: string = 'user',
  data?: Record<string, any>
) {
  if (!sentryInitialized) {
    return;
  }

  Sentry.addBreadcrumb({
    message,
    category,
    data,
    level: 'info',
  });
}

/**
 * Start a transaction for performance monitoring
 * @param name Transaction name
 * @param op Operation type
 * @returns Transaction object
 */
export function startTransaction(name: string, op: string = 'task') {
  if (!sentryInitialized) {
    return null;
  }

  return Sentry.startTransaction({
    name,
    op,
  });
}

/**
 * Capture user feedback
 * @param eventId The event ID from Sentry
 * @param email User email
 * @param comments User comments
 */
export function captureUserFeedback(eventId: string, email: string, comments: string) {
  if (!sentryInitialized) {
    return;
  }

  Sentry.captureUserFeedback({
    event_id: eventId,
    email,
    comments,
  });
}

/**
 * Test error reporting (for development only)
 */
export function testErrorReporting() {
  if (import.meta.env.VITE_SENTRY_ENVIRONMENT === 'development') {
    try {
      // Throw a test error
      throw new Error('Test error for Sentry integration');
    } catch (error) {
      reportError(error as Error, { test: true });
      console.log('Test error reported to Sentry');
    }
  }
}

// Export Sentry components for React Error Boundary
export { ErrorBoundary } from '@sentry/react';