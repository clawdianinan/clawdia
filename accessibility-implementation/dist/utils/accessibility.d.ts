/**
 * Accessibility Utilities for React Applications
 * Provides screen reader optimization, ARIA utilities, and accessibility helpers
 */
export declare class ARIALiveRegion {
    private static instance;
    private container;
    private regions;
    private constructor();
    static getInstance(): ARIALiveRegion;
    private initialize;
    /**
     * Announce a message to screen readers
     */
    announce(message: string, priority?: 'polite' | 'assertive'): void;
    /**
     * Announce PRD generation progress
     */
    announcePRDProgress(step: number, total: number, message?: string): void;
    /**
     * Announce credit usage notification
     */
    announceCreditUsage(creditsUsed: number, creditsRemaining: number): void;
    /**
     * Announce form validation error
     */
    announceFormError(fieldName: string, errorMessage: string): void;
    /**
     * Announce success message
     */
    announceSuccess(message: string): void;
    /**
     * Announce error message
     */
    announceError(message: string): void;
    /**
     * Announce page navigation
     */
    announcePageNavigation(pageTitle: string): void;
}
export declare class ImageAltTextGenerator {
    /**
     * Generate alt text for AI-created visuals
     */
    static generateAltText(imageType: 'chart' | 'graph' | 'diagram' | 'illustration' | 'photo', content: string, context?: string): string;
    /**
     * Generate alt text for data visualization
     */
    static generateChartAltText(chartType: string, dataDescription: string, keyInsights: string[]): string;
}
export declare class HeadingManager {
    private static currentLevel;
    /**
     * Get appropriate heading level based on context
     */
    static getHeadingLevel(baseLevel?: 1 | 2 | 3 | 4 | 5 | 6): number;
    /**
     * Increment heading level for nested sections
     */
    static incrementLevel(): number;
    /**
     * Decrement heading level
     */
    static decrementLevel(): number;
    /**
     * Reset heading level
     */
    static resetLevel(): void;
    /**
     * Validate heading hierarchy
     */
    static validateHierarchy(headings: Array<{
        level: number;
        text: string;
    }>): string[];
}
export declare class FormAccessibility {
    /**
     * Add ARIA attributes to form field for error announcements
     */
    static setupFormField(fieldId: string, fieldName: string, isRequired?: boolean): void;
    /**
     * Show form field error
     */
    static showFieldError(fieldId: string, errorMessage: string): void;
    /**
     * Clear form field error
     */
    static clearFieldError(fieldId: string): void;
    /**
     * Validate form and announce errors
     */
    static validateForm(formId: string): boolean;
}
export declare class FocusManager {
    /**
     * Trap focus within a modal or dialog
     */
    static trapFocus(element: HTMLElement): () => void;
    /**
     * Restore focus to previously focused element
     */
    static restoreFocus(previousElement?: HTMLElement): void;
    /**
     * Set focus to element with visual indicator
     */
    static focusWithIndicator(element: HTMLElement): void;
}
export interface AccessibilityPreferences {
    highContrast: boolean;
    textScale: number;
    simplifiedUI: boolean;
    dyslexiaFriendly: boolean;
    reducedMotion: boolean;
}
export declare class AccessibilityPreferencesManager {
    private static STORAGE_KEY;
    private static DEFAULT_PREFERENCES;
    /**
     * Get current preferences
     */
    static getPreferences(): AccessibilityPreferences;
    /**
     * Save preferences
     */
    static savePreferences(preferences: Partial<AccessibilityPreferences>): void;
    /**
     * Apply preferences to document
     */
    static applyPreferences(preferences: AccessibilityPreferences): void;
    /**
     * Initialize preferences on page load
     */
    static initialize(): void;
}
export declare const liveRegion: ARIALiveRegion;
export declare const preferencesManager: typeof AccessibilityPreferencesManager;
//# sourceMappingURL=accessibility.d.ts.map