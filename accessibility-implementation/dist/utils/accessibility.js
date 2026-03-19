/**
 * Accessibility Utilities for React Applications
 * Provides screen reader optimization, ARIA utilities, and accessibility helpers
 */
// ARIA Live Region Manager
export class ARIALiveRegion {
    constructor() {
        this.container = null;
        this.regions = new Map();
        this.initialize();
    }
    static getInstance() {
        if (!ARIALiveRegion.instance) {
            ARIALiveRegion.instance = new ARIALiveRegion();
        }
        return ARIALiveRegion.instance;
    }
    initialize() {
        if (typeof document === 'undefined')
            return;
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
    announce(message, priority = 'polite') {
        if (typeof document === 'undefined')
            return;
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
    announcePRDProgress(step, total, message) {
        const progress = Math.round((step / total) * 100);
        const announcement = message || `PRD generation: ${progress}% complete. ${step} of ${total} steps finished.`;
        this.announce(announcement, 'polite');
    }
    /**
     * Announce credit usage notification
     */
    announceCreditUsage(creditsUsed, creditsRemaining) {
        const announcement = `Credit usage: ${creditsUsed} credits used. ${creditsRemaining} credits remaining.`;
        this.announce(announcement, 'polite');
    }
    /**
     * Announce form validation error
     */
    announceFormError(fieldName, errorMessage) {
        const announcement = `Error in ${fieldName}: ${errorMessage}`;
        this.announce(announcement, 'assertive');
    }
    /**
     * Announce success message
     */
    announceSuccess(message) {
        this.announce(`Success: ${message}`, 'polite');
    }
    /**
     * Announce error message
     */
    announceError(message) {
        this.announce(`Error: ${message}`, 'assertive');
    }
    /**
     * Announce page navigation
     */
    announcePageNavigation(pageTitle) {
        this.announce(`Navigated to ${pageTitle}`, 'polite');
    }
}
// Image Alt Text Generator
export class ImageAltTextGenerator {
    /**
     * Generate alt text for AI-created visuals
     */
    static generateAltText(imageType, content, context) {
        const baseText = `A ${imageType} showing ${content}`;
        if (context) {
            return `${baseText}. ${context}`;
        }
        return baseText;
    }
    /**
     * Generate alt text for data visualization
     */
    static generateChartAltText(chartType, dataDescription, keyInsights) {
        const insightsText = keyInsights.length > 0
            ? ` Key insights: ${keyInsights.join(', ')}.`
            : '';
        return `A ${chartType} chart showing ${dataDescription}.${insightsText}`;
    }
}
// Heading Hierarchy Manager
export class HeadingManager {
    /**
     * Get appropriate heading level based on context
     */
    static getHeadingLevel(baseLevel = 1) {
        this.currentLevel = baseLevel;
        return this.currentLevel;
    }
    /**
     * Increment heading level for nested sections
     */
    static incrementLevel() {
        if (this.currentLevel < 6) {
            this.currentLevel++;
        }
        return this.currentLevel;
    }
    /**
     * Decrement heading level
     */
    static decrementLevel() {
        if (this.currentLevel > 1) {
            this.currentLevel--;
        }
        return this.currentLevel;
    }
    /**
     * Reset heading level
     */
    static resetLevel() {
        this.currentLevel = 0;
    }
    /**
     * Validate heading hierarchy
     */
    static validateHierarchy(headings) {
        const errors = [];
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
HeadingManager.currentLevel = 0;
// Form Accessibility Utilities
export class FormAccessibility {
    /**
     * Add ARIA attributes to form field for error announcements
     */
    static setupFormField(fieldId, fieldName, isRequired = false) {
        if (typeof document === 'undefined')
            return;
        const field = document.getElementById(fieldId);
        if (!field)
            return;
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
    static showFieldError(fieldId, errorMessage) {
        if (typeof document === 'undefined')
            return;
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
            liveRegion.announceFormError((field === null || field === void 0 ? void 0 : field.getAttribute('aria-label')) || fieldId, errorMessage);
        }
    }
    /**
     * Clear form field error
     */
    static clearFieldError(fieldId) {
        if (typeof document === 'undefined')
            return;
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
    static validateForm(formId) {
        if (typeof document === 'undefined')
            return false;
        const form = document.getElementById(formId);
        if (!form)
            return false;
        const requiredFields = form.querySelectorAll('[aria-required="true"]');
        let isValid = true;
        const errors = [];
        requiredFields.forEach((field) => {
            const input = field;
            const fieldId = input.id;
            const fieldName = input.getAttribute('aria-label') || fieldId;
            if (!input.value.trim()) {
                isValid = false;
                const errorMessage = `${fieldName} is required`;
                this.showFieldError(fieldId, errorMessage);
                errors.push(errorMessage);
            }
            else {
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
    static trapFocus(element) {
        const focusableElements = element.querySelectorAll('button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])');
        const firstFocusable = focusableElements[0];
        const lastFocusable = focusableElements[focusableElements.length - 1];
        const handleTabKey = (e) => {
            if (e.key !== 'Tab')
                return;
            if (e.shiftKey) {
                // Shift + Tab
                if (document.activeElement === firstFocusable) {
                    e.preventDefault();
                    lastFocusable.focus();
                }
            }
            else {
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
    static restoreFocus(previousElement) {
        if (previousElement && typeof previousElement.focus === 'function') {
            previousElement.focus();
        }
    }
    /**
     * Set focus to element with visual indicator
     */
    static focusWithIndicator(element) {
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
export class AccessibilityPreferencesManager {
    /**
     * Get current preferences
     */
    static getPreferences() {
        if (typeof localStorage === 'undefined') {
            return Object.assign({}, this.DEFAULT_PREFERENCES);
        }
        try {
            const stored = localStorage.getItem(this.STORAGE_KEY);
            return stored
                ? Object.assign(Object.assign({}, this.DEFAULT_PREFERENCES), JSON.parse(stored)) : Object.assign({}, this.DEFAULT_PREFERENCES);
        }
        catch (_a) {
            return Object.assign({}, this.DEFAULT_PREFERENCES);
        }
    }
    /**
     * Save preferences
     */
    static savePreferences(preferences) {
        if (typeof localStorage === 'undefined')
            return;
        const current = this.getPreferences();
        const updated = Object.assign(Object.assign({}, current), preferences);
        localStorage.setItem(this.STORAGE_KEY, JSON.stringify(updated));
        this.applyPreferences(updated);
    }
    /**
     * Apply preferences to document
     */
    static applyPreferences(preferences) {
        if (typeof document === 'undefined')
            return;
        const root = document.documentElement;
        // Apply high contrast
        if (preferences.highContrast) {
            root.classList.add('high-contrast');
        }
        else {
            root.classList.remove('high-contrast');
        }
        // Apply text scaling
        root.style.setProperty('--text-scale', preferences.textScale.toString());
        // Apply simplified UI
        if (preferences.simplifiedUI) {
            root.classList.add('simplified-ui');
        }
        else {
            root.classList.remove('simplified-ui');
        }
        // Apply dyslexia-friendly font
        if (preferences.dyslexiaFriendly) {
            root.classList.add('dyslexia-friendly');
        }
        else {
            root.classList.remove('dyslexia-friendly');
        }
        // Apply reduced motion
        if (preferences.reducedMotion) {
            root.classList.add('reduced-motion');
        }
        else {
            root.classList.remove('reduced-motion');
        }
    }
    /**
     * Initialize preferences on page load
     */
    static initialize() {
        if (typeof document === 'undefined')
            return;
        const preferences = this.getPreferences();
        this.applyPreferences(preferences);
        // Listen for system preference changes
        if (typeof window !== 'undefined' && window.matchMedia) {
            const reducedMotionQuery = window.matchMedia('(prefers-reduced-motion: reduce)');
            const handleReducedMotionChange = (e) => {
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
AccessibilityPreferencesManager.STORAGE_KEY = 'accessibility-preferences';
AccessibilityPreferencesManager.DEFAULT_PREFERENCES = {
    highContrast: false,
    textScale: 1.0,
    simplifiedUI: false,
    dyslexiaFriendly: false,
    reducedMotion: false,
};
// Export singleton instances
export const liveRegion = ARIALiveRegion.getInstance();
export const preferencesManager = AccessibilityPreferencesManager;
//# sourceMappingURL=accessibility.js.map