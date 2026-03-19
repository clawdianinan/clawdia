/**
 * Accessibility Utilities for React Applications
 * Provides screen reader optimization, ARIA utilities, and accessibility helpers
 */

// ARIA Live Region Manager
export class ARIALiveRegion {
  private static instance: ARIALiveRegion;
  private container: HTMLElement | null = null;
  private regions: Map<string, HTMLElement> = new Map();

  private constructor() {
    this.initialize();
  }

  static getInstance(): ARIALiveRegion {
    if (!ARIALiveRegion.instance) {
      ARIALiveRegion.instance = new ARIALiveRegion();
    }
    return ARIALiveRegion.instance;
  }

  private initialize(): void {
    if (typeof document === 'undefined') return;

    this.container = document.createElement('div');
    this.container.setAttribute('aria-live', 'polite');
    this.container.setAttribute('aria-atomic', 'true');
    this.container.setAttribute('aria-relevant', 'additions text');
    this.container.style.cssText = `
      position: absolute;
      width: 1px;
      height: 1px;
      padding: 0;
      margin: -1px;
      overflow: hidden;
      clip: rect(0, 0, 0, 0);
      white-space: nowrap;
      border: 0;
    `;
    document.body.appendChild(this.container);
  }

  /**
   * Announce a message to screen readers
   */
  announce(message: string, priority: 'polite' | 'assertive' = 'polite'): void {
    if (typeof document === 'undefined') return;

    const regionId = `live-region-${Date.now()}`;
    const region = document.createElement('div');
    region.id = regionId;
    region.setAttribute('aria-live', priority);
    region.setAttribute('aria-atomic', 'true');
    region.textContent = message;

    if (this.container) {
      this.container.appendChild(region);
      this.regions.set(regionId, region);

      // Remove after announcement is read
      setTimeout(() => {
        if (region.parentNode) {
          region.parentNode.removeChild(region);
        }
        this.regions.delete(regionId);
      }, 1000);
    }
  }

  /**
   * Announce PRD generation progress
   */
  announcePRDProgress(step: number, total: number, message?: string): void {
    const progress = Math.round((step / total) * 100);
    const announcement = message || `PRD generation: ${progress}% complete. ${step} of ${total} steps finished.`;
    this.announce(announcement, 'polite');
  }

  /**
   * Announce credit usage notification
   */
  announceCreditUsage(creditsUsed: number, creditsRemaining: number): void {
    const announcement = `Credit usage: ${creditsUsed} credits used. ${creditsRemaining} credits remaining.`;
    this.announce(announcement, 'polite');
  }

  /**
   * Announce form validation error
   */
  announceFormError(fieldName: string, errorMessage: string): void {
    const announcement = `Error in ${fieldName}: ${errorMessage}`;
    this.announce(announcement, 'assertive');
  }

  /**
   * Announce success message
   */
  announceSuccess(message: string): void {
    this.announce(`Success: ${message}`, 'polite');
  }

  /**
   * Announce error message
   */
  announceError(message: string): void {
    this.announce(`Error: ${message}`, 'assertive');
  }

  /**
   * Announce page navigation
   */
  announcePageNavigation(pageTitle: string): void {
    this.announce(`Navigated to ${pageTitle}`, 'polite');
  }
}

// Image Alt Text Generator
export class ImageAltTextGenerator {
  /**
   * Generate alt text for AI-created visuals
   */
  static generateAltText(
    imageType: 'chart' | 'graph' | 'diagram' | 'illustration' | 'photo',
    content: string,
    context?: string
  ): string {
    const baseText = `A ${imageType} showing ${content}`;
    
    if (context) {
      return `${baseText}. ${context}`;
    }
    
    return baseText;
  }

  /**
   * Generate alt text for data visualization
   */
  static generateChartAltText(
    chartType: string,
    dataDescription: string,
    keyInsights: string[]
  ): string {
    const insightsText = keyInsights.length > 0 
      ? ` Key insights: ${keyInsights.join(', ')}.`
      : '';
    
    return `A ${chartType} chart showing ${dataDescription}.${insightsText}`;
  }
}

// Heading Hierarchy Manager
export class HeadingManager {
  private static currentLevel = 0;

  /**
   * Get appropriate heading level based on context
   */
  static getHeadingLevel(baseLevel: 1 | 2 | 3 | 4 | 5 | 6 = 1): number {
    this.currentLevel = baseLevel;
    return this.currentLevel;
  }

  /**
   * Increment heading level for nested sections
   */
  static incrementLevel(): number {
    if (this.currentLevel < 6) {
      this.currentLevel++;
    }
    return this.currentLevel;
  }

  /**
   * Decrement heading level
   */
  static decrementLevel(): number {
    if (this.currentLevel > 1) {
      this.currentLevel--;
    }
    return this.currentLevel;
  }

  /**
   * Reset heading level
   */
  static resetLevel(): void {
    this.currentLevel = 0;
  }

  /**
   * Validate heading hierarchy
   */
  static validateHierarchy(headings: Array<{ level: number; text: string }>): string[] {
    const errors: string[] = [];
    let previousLevel = 0;

    for (const heading of headings) {
      if (heading.level > previousLevel + 1) {
        errors.push(`Heading "${heading.text}" jumps from level ${previousLevel} to ${heading.level}. Skipping heading levels is not recommended.`);
      }
      previousLevel = heading.level;
    }

    return errors;
  }
}

// Form Accessibility Utilities
export class FormAccessibility {
  /**
   * Add ARIA attributes to form field for error announcements
   */
  static setupFormField(
    fieldId: string,
    fieldName: string,
    isRequired: boolean = false
  ): void {
    if (typeof document === 'undefined') return;

    const field = document.getElementById(fieldId);
    if (!field) return;

    // Add ARIA attributes
    field.setAttribute('aria-label', fieldName);
    
    if (isRequired) {
      field.setAttribute('aria-required', 'true');
    }

    // Create error container
    const errorId = `${fieldId}-error`;
    let errorContainer = document.getElementById(errorId);
    
    if (!errorContainer) {
      errorContainer = document.createElement('div');
      errorContainer.id = errorId;
      errorContainer.setAttribute('role', 'alert');
      errorContainer.setAttribute('aria-live', 'assertive');
      errorContainer.style.cssText = `
        color: #dc2626;
        font-size: 0.875rem;
        margin-top: 0.25rem;
        min-height: 1.25rem;
      `;
      
      const parent = field.parentElement;
      if (parent) {
        parent.appendChild(errorContainer);
      }
    }

    // Link field to error container
    field.setAttribute('aria-describedby', errorId);
    field.setAttribute('aria-invalid', 'false');
  }

  /**
   * Show form field error
   */
  static showFieldError(fieldId: string, errorMessage: string): void {
    if (typeof document === 'undefined') return;

    const field = document.getElementById(fieldId);
    const errorId = `${fieldId}-error`;
    const errorContainer = document.getElementById(errorId);

    if (field) {
      field.setAttribute('aria-invalid', 'true');
    }

    if (errorContainer) {
      errorContainer.textContent = errorMessage;
      errorContainer.setAttribute('role', 'alert');
      
      // Announce error to screen readers
      const liveRegion = ARIALiveRegion.getInstance();
      liveRegion.announceFormError(
        field?.getAttribute('aria-label') || fieldId,
        errorMessage
      );
    }
  }

  /**
   * Clear form field error
   */
  static clearFieldError(fieldId: string): void {
    if (typeof document === 'undefined') return;

    const field = document.getElementById(fieldId);
    const errorId = `${fieldId}-error`;
    const errorContainer = document.getElementById(errorId);

    if (field) {
      field.setAttribute('aria-invalid', 'false');
    }

    if (errorContainer) {
      errorContainer.textContent = '';
      errorContainer.removeAttribute('role');
    }
  }

  /**
   * Validate form and announce errors
   */
  static validateForm(formId: string): boolean {
    if (typeof document === 'undefined') return false;

    const form = document.getElementById(formId);
    if (!form) return false;

    const requiredFields = form.querySelectorAll('[aria-required="true"]');
    let isValid = true;
    const errors: string[] = [];

    requiredFields.forEach((field: Element) => {
      const input = field as HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement;
      const fieldId = input.id;
      const fieldName = input.getAttribute('aria-label') || fieldId;

      if (!input.value.trim()) {
        isValid = false;
        const errorMessage = `${fieldName} is required`;
        this.showFieldError(fieldId, errorMessage);
        errors.push(errorMessage);
      } else {
        this.clearFieldError(fieldId);
      }
    });

    if (!isValid) {
      const liveRegion = ARIALiveRegion.getInstance();
      liveRegion.announce(`Form has ${errors.length} error${errors.length > 1 ? 's' : ''}. Please check the form and try again.`, 'assertive');
    }

    return isValid;
  }
}

// Focus Management Utilities
export class FocusManager {
  /**
   * Trap focus within a modal or dialog
   */
  static trapFocus(element: HTMLElement): () => void {
    const focusableElements = element.querySelectorAll(
      'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
    );
    
    const firstFocusable = focusableElements[0] as HTMLElement;
    const lastFocusable = focusableElements[focusableElements.length - 1] as HTMLElement;

    const handleTabKey = (e: KeyboardEvent) => {
      if (e.key !== 'Tab') return;

      if (e.shiftKey) {
        // Shift + Tab
        if (document.activeElement === firstFocusable) {
          e.preventDefault();
          lastFocusable.focus();
        }
      } else {
        // Tab
        if (document.activeElement === lastFocusable) {
          e.preventDefault();
          firstFocusable.focus();
        }
      }
    };

    element.addEventListener('keydown', handleTabKey);

    // Focus first element
    if (firstFocusable) {
      firstFocusable.focus();
    }

    // Return cleanup function
    return () => {
      element.removeEventListener('keydown', handleTabKey);
    };
  }

  /**
   * Restore focus to previously focused element
   */
  static restoreFocus(previousElement?: HTMLElement): void {
    if (previousElement && typeof previousElement.focus === 'function') {
      previousElement.focus();
    }
  }

  /**
   * Set focus to element with visual indicator
   */
  static focusWithIndicator(element: HTMLElement): void {
    element.focus();
    
    // Add visual focus indicator class
    element.classList.add('focus-visible');
    
    // Remove class after focus is lost
    const removeClass = () => {
      element.classList.remove('focus-visible');
      element.removeEventListener('blur', removeClass);
    };
    
    element.addEventListener('blur', removeClass);
  }
}

// Accessibility Preferences Manager
export interface AccessibilityPreferences {
  highContrast: boolean;
  textScale: number; // 1.0 to 2.0
  simplifiedUI: boolean;
  dyslexiaFriendly: boolean;
  reducedMotion: boolean;
}

export class AccessibilityPreferencesManager {
  private static STORAGE_KEY = 'accessibility-preferences';
  private static DEFAULT_PREFERENCES: AccessibilityPreferences = {
    highContrast: false,
    textScale: 1.0,
    simplifiedUI: false,
    dyslexiaFriendly: false,
    reducedMotion: false,
  };

  /**
   * Get current preferences
   */
  static getPreferences(): AccessibilityPreferences {
    if (typeof localStorage === 'undefined') {
      return { ...this.DEFAULT_PREFERENCES };
    }

    try {
      const stored = localStorage.getItem(this.STORAGE_KEY);
      return stored 
        ? { ...this.DEFAULT_PREFERENCES, ...JSON.parse(stored) }
        : { ...this.DEFAULT_PREFERENCES };
    } catch {
      return { ...this.DEFAULT_PREFERENCES };
    }
  }

  /**
   * Save preferences
   */
  static savePreferences(preferences: Partial<AccessibilityPreferences>): void {
    if (typeof localStorage === 'undefined') return;

    const current = this.getPreferences();
    const updated = { ...current, ...preferences };
    
    localStorage.setItem(this.STORAGE_KEY, JSON.stringify(updated));
    this.applyPreferences(updated);
  }

  /**
   * Apply preferences to document
   */
  static applyPreferences(preferences: AccessibilityPreferences): void {
    if (typeof document === 'undefined') return;

    const root = document.documentElement;
    
    // Apply high contrast
    if (preferences.highContrast) {
      root.classList.add('high-contrast');
    } else {
      root.classList.remove('high-contrast');
    }

    // Apply text scaling
    root.style.setProperty('--text-scale', preferences.textScale.toString());

    // Apply simplified UI
    if (preferences.simplifiedUI) {
      root.classList.add('simplified-ui');
    } else {
      root.classList.remove('simplified-ui');
    }

    // Apply dyslexia-friendly font
    if (preferences.dyslexiaFriendly) {
      root.classList.add('dyslexia-friendly');
    } else {
      root.classList.remove('dyslexia-friendly');
    }

    // Apply reduced motion
    if (preferences.reducedMotion) {
      root.classList.add('reduced-motion');
    } else {
      root.classList.remove('reduced-motion');
    }
  }

  /**
   * Initialize preferences on page load
   */
  static initialize(): void {
    if (typeof document === 'undefined') return;

    const preferences = this.getPreferences();
    this.applyPreferences(preferences);

    // Listen for system preference changes
    if (typeof window !== 'undefined' && window.matchMedia) {
      const reducedMotionQuery = window.matchMedia('(prefers-reduced-motion: reduce)');
      
      const handleReducedMotionChange = (e: MediaQueryListEvent) => {
        this.savePreferences({ reducedMotion: e.matches });
      };

      reducedMotionQuery.addEventListener('change', handleReducedMotionChange);
      
      // Apply system preference on load
      if (reducedMotionQuery.matches) {
        this.savePreferences({ reducedMotion: true });
      }
    }
  }
}

// Export singleton instances
export const liveRegion = ARIALiveRegion.getInstance();
export const preferencesManager = AccessibilityPreferencesManager;