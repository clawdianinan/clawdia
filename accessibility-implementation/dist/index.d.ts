/**
 * Accessibility Implementation Package
 * Comprehensive accessibility features for React applications
 */
export { ARIALiveRegion, ImageAltTextGenerator, HeadingManager, FormAccessibility, FocusManager, AccessibilityPreferencesManager, liveRegion, preferencesManager, type AccessibilityPreferences, } from './utils/accessibility';
export { useKeyboardNavigation, type KeyboardShortcut, type KeyboardNavigationConfig, } from './hooks/useKeyboardNavigation';
export { default as AccessibilityMenu } from './components/accessibility/AccessibilityMenu';
import './styles/accessibility.css';
/**
 * Initialize accessibility features
 * Call this function in your app's entry point
 */
export declare function initializeAccessibility(): void;
/**
 * Setup keyboard shortcuts for the application
 */
export declare function setupKeyboardShortcuts(additionalShortcuts?: Array<{
    key: string;
    ctrlKey?: boolean;
    shiftKey?: boolean;
    altKey?: boolean;
    metaKey?: boolean;
    description: string;
    action: () => void;
}>): void;
/**
 * Announce message to screen readers
 */
export declare function announce(message: string, priority?: 'polite' | 'assertive'): void;
/**
 * Announce PRD generation progress
 */
export declare function announcePRDProgress(step: number, total: number, message?: string): void;
/**
 * Announce credit usage
 */
export declare function announceCreditUsage(creditsUsed: number, creditsRemaining: number): void;
/**
 * Announce form error
 */
export declare function announceFormError(fieldName: string, errorMessage: string): void;
/**
 * Announce success message
 */
export declare function announceSuccess(message: string): void;
/**
 * Announce error message
 */
export declare function announceError(message: string): void;
/**
 * Announce page navigation
 */
export declare function announcePageNavigation(pageTitle: string): void;
/**
 * Generate alt text for images
 */
export declare function generateAltText(imageType: 'chart' | 'graph' | 'diagram' | 'illustration' | 'photo', content: string, context?: string): string;
/**
 * Setup form field for accessibility
 */
export declare function setupFormField(fieldId: string, fieldName: string, isRequired?: boolean): void;
/**
 * Show form field error
 */
export declare function showFormFieldError(fieldId: string, errorMessage: string): void;
/**
 * Clear form field error
 */
export declare function clearFormFieldError(fieldId: string): void;
/**
 * Validate form
 */
export declare function validateForm(formId: string): boolean;
/**
 * Trap focus within element
 */
export declare function trapFocus(element: HTMLElement): () => void;
/**
 * Restore focus to previous element
 */
export declare function restoreFocus(previousElement?: HTMLElement): void;
/**
 * Set focus with visual indicator
 */
export declare function focusWithIndicator(element: HTMLElement): void;
/**
 * Get current accessibility preferences
 */
export declare function getAccessibilityPreferences(): AccessibilityPreferences;
/**
 * Save accessibility preferences
 */
export declare function saveAccessibilityPreferences(preferences: Partial<AccessibilityPreferences>): void;
declare const _default: {
    initializeAccessibility: typeof initializeAccessibility;
    setupKeyboardShortcuts: typeof setupKeyboardShortcuts;
    announce: typeof announce;
    announcePRDProgress: typeof announcePRDProgress;
    announceCreditUsage: typeof announceCreditUsage;
    announceFormError: typeof announceFormError;
    announceSuccess: typeof announceSuccess;
    announceError: typeof announceError;
    announcePageNavigation: typeof announcePageNavigation;
    generateAltText: typeof generateAltText;
    setupFormField: typeof setupFormField;
    showFormFieldError: typeof showFormFieldError;
    clearFormFieldError: typeof clearFormFieldError;
    validateForm: typeof validateForm;
    trapFocus: typeof trapFocus;
    restoreFocus: typeof restoreFocus;
    focusWithIndicator: typeof focusWithIndicator;
    getAccessibilityPreferences: typeof getAccessibilityPreferences;
    saveAccessibilityPreferences: typeof saveAccessibilityPreferences;
    AccessibilityMenu: any;
    useKeyboardNavigation: any;
};
export default _default;
//# sourceMappingURL=index.d.ts.map