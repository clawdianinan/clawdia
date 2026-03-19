/**
 * Accessibility Implementation Package
 * Comprehensive accessibility features for React applications
 */
// Export utilities
export { ARIALiveRegion, ImageAltTextGenerator, HeadingManager, FormAccessibility, FocusManager, AccessibilityPreferencesManager, liveRegion, preferencesManager, } from './utils/accessibility';
// Export hooks
export { useKeyboardNavigation, } from './hooks/useKeyboardNavigation';
// Export components
export { default as AccessibilityMenu } from './components/accessibility/AccessibilityMenu';
// Export styles
import './styles/accessibility.css';
/**
 * Initialize accessibility features
 * Call this function in your app's entry point
 */
export function initializeAccessibility() {
    if (typeof document === 'undefined')
        return;
    // Add skip to content link
    const skipLink = document.createElement('a');
    skipLink.href = '#main-content';
    skipLink.className = 'skip-to-content';
    skipLink.textContent = 'Skip to main content';
    document.body.prepend(skipLink);
    // Add main content landmark if not present
    const mainContent = document.getElementById('main-content');
    if (!mainContent) {
        const main = document.querySelector('main');
        if (main) {
            main.id = 'main-content';
        }
        else {
            // Find the main content area
            const content = document.querySelector('[role="main"], .main, .content');
            if (content) {
                content.id = 'main-content';
            }
        }
    }
    // Initialize preferences manager
    preferencesManager.initialize();
    // Add ARIA landmark roles if missing
    const addLandmarkRoles = () => {
        const header = document.querySelector('header');
        if (header && !header.getAttribute('role')) {
            header.setAttribute('role', 'banner');
        }
        const nav = document.querySelector('nav');
        if (nav && !nav.getAttribute('role')) {
            nav.setAttribute('role', 'navigation');
        }
        const main = document.querySelector('main');
        if (main && !main.getAttribute('role')) {
            main.setAttribute('role', 'main');
        }
        const footer = document.querySelector('footer');
        if (footer && !footer.getAttribute('role')) {
            footer.setAttribute('role', 'contentinfo');
        }
        const search = document.querySelector('form[role="search"]');
        if (search && !search.getAttribute('role')) {
            search.setAttribute('role', 'search');
        }
    };
    addLandmarkRoles();
    // Observe DOM changes to maintain accessibility
    if (typeof MutationObserver !== 'undefined') {
        const observer = new MutationObserver((mutations) => {
            mutations.forEach((mutation) => {
                if (mutation.type === 'childList') {
                    addLandmarkRoles();
                }
            });
        });
        observer.observe(document.body, {
            childList: true,
            subtree: true,
        });
    }
    console.log('Accessibility features initialized');
}
/**
 * Setup keyboard shortcuts for the application
 */
export function setupKeyboardShortcuts(additionalShortcuts) {
    if (typeof window === 'undefined')
        return;
    const shortcuts = additionalShortcuts || [];
    window.addEventListener('keydown', (event) => {
        // Handle ? key for showing shortcuts
        if (event.key === '?' && !event.ctrlKey && !event.altKey && !event.metaKey) {
            event.preventDefault();
            showKeyboardShortcutsDialog(shortcuts);
        }
    });
}
/**
 * Show keyboard shortcuts dialog
 */
function showKeyboardShortcutsDialog(shortcuts) {
    const dialog = document.createElement('div');
    dialog.className = 'keyboard-shortcuts-dialog';
    dialog.setAttribute('role', 'dialog');
    dialog.setAttribute('aria-label', 'Keyboard Shortcuts');
    dialog.setAttribute('aria-modal', 'true');
    const defaultShortcuts = [
        { key: '?', description: 'Show keyboard shortcuts' },
        { key: 'n', ctrlKey: true, description: 'Create new PRD' },
        { key: 's', ctrlKey: true, description: 'Save PRD' },
        { key: 'e', ctrlKey: true, description: 'Export PRD' },
        { key: 'Escape', description: 'Close modal or go back' },
        { key: 'Tab', description: 'Navigate between interactive elements' },
        { key: 'Shift+Tab', description: 'Navigate backwards' },
        { key: 'ArrowUp', description: 'Navigate up in lists' },
        { key: 'ArrowDown', description: 'Navigate down in lists' },
        { key: 'ArrowLeft', description: 'Navigate left in carousels' },
        { key: 'ArrowRight', description: 'Navigate right in carousels' },
        { key: 'Enter', description: 'Activate selected item' },
        { key: 'Space', description: 'Toggle selection' },
    ];
    const allShortcuts = [...defaultShortcuts, ...shortcuts];
    dialog.innerHTML = `
    <div class="keyboard-shortcuts-header">
      <h2>Keyboard Shortcuts</h2>
      <button class="close-button" aria-label="Close dialog">×</button>
    </div>
    <div class="keyboard-shortcuts-content">
      <table>
        <thead>
          <tr>
            <th>Shortcut</th>
            <th>Description</th>
          </tr>
        </thead>
        <tbody>
          ${allShortcuts.map(shortcut => `
            <tr>
              <td><kbd>${formatShortcutDisplay(shortcut)}</kbd></td>
              <td>${shortcut.description}</td>
            </tr>
          `).join('')}
        </tbody>
      </table>
    </div>
  `;
    document.body.appendChild(dialog);
    // Focus trap
    const focusableElements = dialog.querySelectorAll('button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])');
    const firstFocusable = focusableElements[0];
    const lastFocusable = focusableElements[focusableElements.length - 1];
    const handleKeyDown = (e) => {
        if (e.key === 'Escape') {
            closeDialog();
        }
        else if (e.key === 'Tab') {
            if (e.shiftKey) {
                if (document.activeElement === firstFocusable) {
                    e.preventDefault();
                    lastFocusable.focus();
                }
            }
            else {
                if (document.activeElement === lastFocusable) {
                    e.preventDefault();
                    firstFocusable.focus();
                }
            }
        }
    };
    const closeDialog = () => {
        dialog.removeEventListener('keydown', handleKeyDown);
        document.body.removeChild(dialog);
    };
    const closeButton = dialog.querySelector('.close-button');
    closeButton.addEventListener('click', closeDialog);
    dialog.addEventListener('keydown', handleKeyDown);
    // Focus first element
    setTimeout(() => {
        firstFocusable.focus();
    }, 0);
}
/**
 * Format shortcut for display
 */
function formatShortcutDisplay(shortcut) {
    const parts = [];
    if (shortcut.ctrlKey)
        parts.push('Ctrl');
    if (shortcut.shiftKey)
        parts.push('Shift');
    if (shortcut.altKey)
        parts.push('Alt');
    if (shortcut.metaKey)
        parts.push('Cmd');
    if (shortcut.key === ' ') {
        parts.push('Space');
    }
    else if (shortcut.key === 'Escape') {
        parts.push('Esc');
    }
    else if (shortcut.key === 'ArrowUp') {
        parts.push('↑');
    }
    else if (shortcut.key === 'ArrowDown') {
        parts.push('↓');
    }
    else if (shortcut.key === 'ArrowLeft') {
        parts.push('←');
    }
    else if (shortcut.key === 'ArrowRight') {
        parts.push('→');
    }
    else if (shortcut.key === 'Shift+Tab') {
        return 'Shift + Tab';
    }
    else {
        parts.push(shortcut.key.toUpperCase());
    }
    return parts.join(' + ');
}
/**
 * Announce message to screen readers
 */
export function announce(message, priority = 'polite') {
    liveRegion.announce(message, priority);
}
/**
 * Announce PRD generation progress
 */
export function announcePRDProgress(step, total, message) {
    liveRegion.announcePRDProgress(step, total, message);
}
/**
 * Announce credit usage
 */
export function announceCreditUsage(creditsUsed, creditsRemaining) {
    liveRegion.announceCreditUsage(creditsUsed, creditsRemaining);
}
/**
 * Announce form error
 */
export function announceFormError(fieldName, errorMessage) {
    liveRegion.announceFormError(fieldName, errorMessage);
}
/**
 * Announce success message
 */
export function announceSuccess(message) {
    liveRegion.announceSuccess(message);
}
/**
 * Announce error message
 */
export function announceError(message) {
    liveRegion.announceError(message);
}
/**
 * Announce page navigation
 */
export function announcePageNavigation(pageTitle) {
    liveRegion.announcePageNavigation(pageTitle);
}
/**
 * Generate alt text for images
 */
export function generateAltText(imageType, content, context) {
    return ImageAltTextGenerator.generateAltText(imageType, content, context);
}
/**
 * Setup form field for accessibility
 */
export function setupFormField(fieldId, fieldName, isRequired = false) {
    FormAccessibility.setupFormField(fieldId, fieldName, isRequired);
}
/**
 * Show form field error
 */
export function showFormFieldError(fieldId, errorMessage) {
    FormAccessibility.showFieldError(fieldId, errorMessage);
}
/**
 * Clear form field error
 */
export function clearFormFieldError(fieldId) {
    FormAccessibility.clearFieldError(fieldId);
}
/**
 * Validate form
 */
export function validateForm(formId) {
    return FormAccessibility.validateForm(formId);
}
/**
 * Trap focus within element
 */
export function trapFocus(element) {
    return FocusManager.trapFocus(element);
}
/**
 * Restore focus to previous element
 */
export function restoreFocus(previousElement) {
    FocusManager.restoreFocus(previousElement);
}
/**
 * Set focus with visual indicator
 */
export function focusWithIndicator(element) {
    FocusManager.focusWithIndicator(element);
}
/**
 * Get current accessibility preferences
 */
export function getAccessibilityPreferences() {
    return preferencesManager.getPreferences();
}
/**
 * Save accessibility preferences
 */
export function saveAccessibilityPreferences(preferences) {
    preferencesManager.savePreferences(preferences);
}
// Default export
export default {
    initializeAccessibility,
    setupKeyboardShortcuts,
    announce,
    announcePRDProgress,
    announceCreditUsage,
    announceFormError,
    announceSuccess,
    announceError,
    announcePageNavigation,
    generateAltText,
    setupFormField,
    showFormFieldError,
    clearFormFieldError,
    validateForm,
    trapFocus,
    restoreFocus,
    focusWithIndicator,
    getAccessibilityPreferences,
    saveAccessibilityPreferences,
    AccessibilityMenu,
    useKeyboardNavigation,
};
//# sourceMappingURL=index.js.map