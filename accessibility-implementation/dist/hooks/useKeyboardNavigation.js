/**
 * Keyboard Navigation Hook for React Applications
 * Provides comprehensive keyboard navigation support
 */
import { useEffect, useCallback, useRef } from 'react';
export const useKeyboardNavigation = (config = {}) => {
    const { enableShortcuts = true, enableFocusTraps = true, enableArrowNavigation = true, enableEscapeClose = true, shortcuts = [], } = config;
    const focusTrapRef = useRef(null);
    const previousFocusRef = useRef(null);
    const shortcutMapRef = useRef(new Map());
    // Default keyboard shortcuts
    const defaultShortcuts = [
        {
            key: '?',
            description: 'Show keyboard shortcuts',
            action: () => showKeyboardShortcuts(),
        },
        {
            key: 'n',
            ctrlKey: true,
            description: 'Create new PRD',
            action: () => {
                const event = new CustomEvent('keyboard-shortcut', {
                    detail: { action: 'new-prd' }
                });
                window.dispatchEvent(event);
            },
        },
        {
            key: 's',
            ctrlKey: true,
            description: 'Save PRD',
            action: () => {
                const event = new CustomEvent('keyboard-shortcut', {
                    detail: { action: 'save-prd' }
                });
                window.dispatchEvent(event);
            },
        },
        {
            key: 'e',
            ctrlKey: true,
            description: 'Export PRD',
            action: () => {
                const event = new CustomEvent('keyboard-shortcut', {
                    detail: { action: 'export-prd' }
                });
                window.dispatchEvent(event);
            },
        },
        {
            key: 'Escape',
            description: 'Close modal or go back',
            action: () => {
                const event = new CustomEvent('keyboard-shortcut', {
                    detail: { action: 'close-modal' }
                });
                window.dispatchEvent(event);
            },
        },
        {
            key: 'Tab',
            description: 'Navigate between interactive elements',
            action: () => { }, // Default browser behavior
        },
        {
            key: 'Shift',
            shiftKey: true,
            key: 'Tab',
            description: 'Navigate backwards',
            action: () => { }, // Default browser behavior
        },
        {
            key: 'ArrowUp',
            description: 'Navigate up in lists',
            action: () => navigateList('up'),
        },
        {
            key: 'ArrowDown',
            description: 'Navigate down in lists',
            action: () => navigateList('down'),
        },
        {
            key: 'ArrowLeft',
            description: 'Navigate left in carousels',
            action: () => navigateCarousel('left'),
        },
        {
            key: 'ArrowRight',
            description: 'Navigate right in carousels',
            action: () => navigateCarousel('right'),
        },
        {
            key: 'Enter',
            description: 'Activate selected item',
            action: () => activateSelectedItem(),
        },
        {
            key: 'Space',
            description: 'Toggle selection',
            action: () => toggleSelection(),
        },
    ];
    // Initialize shortcut map
    useEffect(() => {
        const allShortcuts = [...defaultShortcuts, ...shortcuts];
        const map = new Map();
        allShortcuts.forEach(shortcut => {
            const key = getShortcutKey(shortcut);
            map.set(key, shortcut);
        });
        shortcutMapRef.current = map;
    }, [shortcuts]);
    // Show keyboard shortcuts dialog
    const showKeyboardShortcuts = useCallback(() => {
        const dialog = document.createElement('div');
        dialog.className = 'keyboard-shortcuts-dialog';
        dialog.setAttribute('role', 'dialog');
        dialog.setAttribute('aria-label', 'Keyboard Shortcuts');
        dialog.setAttribute('aria-modal', 'true');
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
            var _a;
            dialog.removeEventListener('keydown', handleKeyDown);
            document.body.removeChild(dialog);
            (_a = previousFocusRef.current) === null || _a === void 0 ? void 0 : _a.focus();
        };
        const closeButton = dialog.querySelector('.close-button');
        closeButton.addEventListener('click', closeDialog);
        dialog.addEventListener('keydown', handleKeyDown);
        // Store previous focus and focus first element
        previousFocusRef.current = document.activeElement;
        firstFocusable.focus();
    }, [shortcuts]);
    // Navigate lists with arrow keys
    const navigateList = useCallback((direction) => {
        const activeElement = document.activeElement;
        const listItems = Array.from(document.querySelectorAll('[role="listitem"], [role="option"], [role="menuitem"]'));
        if (listItems.length === 0)
            return;
        const currentIndex = listItems.indexOf(activeElement);
        let nextIndex = -1;
        if (direction === 'down') {
            nextIndex = currentIndex < listItems.length - 1 ? currentIndex + 1 : 0;
        }
        else {
            nextIndex = currentIndex > 0 ? currentIndex - 1 : listItems.length - 1;
        }
        if (nextIndex >= 0 && nextIndex < listItems.length) {
            listItems[nextIndex].focus();
        }
    }, []);
    // Navigate carousels with arrow keys
    const navigateCarousel = useCallback((direction) => {
        const carousel = document.querySelector('[role="region"][aria-label*="carousel"]');
        if (!carousel)
            return;
        const items = Array.from(carousel.querySelectorAll('[role="tabpanel"], [role="group"]'));
        const activeItem = carousel.querySelector('[aria-current="true"]');
        const currentIndex = activeItem ? items.indexOf(activeItem) : 0;
        let nextIndex = -1;
        if (direction === 'right') {
            nextIndex = currentIndex < items.length - 1 ? currentIndex + 1 : 0;
        }
        else {
            nextIndex = currentIndex > 0 ? currentIndex - 1 : items.length - 1;
        }
        if (nextIndex >= 0 && nextIndex < items.length) {
            // Update aria-current
            items.forEach((item, index) => {
                if (index === nextIndex) {
                    item.setAttribute('aria-current', 'true');
                    item.focus();
                }
                else {
                    item.removeAttribute('aria-current');
                }
            });
        }
    }, []);
    // Activate selected item
    const activateSelectedItem = useCallback(() => {
        const activeElement = document.activeElement;
        if (activeElement.tagName === 'BUTTON' || activeElement.tagName === 'A') {
            activeElement.click();
        }
        else if (activeElement.getAttribute('role') === 'button') {
            activeElement.click();
        }
        else if (activeElement.getAttribute('role') === 'option') {
            // Handle selection
            const event = new CustomEvent('select-item', {
                detail: { element: activeElement }
            });
            activeElement.dispatchEvent(event);
        }
    }, []);
    // Toggle selection
    const toggleSelection = useCallback(() => {
        const activeElement = document.activeElement;
        if (activeElement.getAttribute('role') === 'checkbox') {
            const isChecked = activeElement.getAttribute('aria-checked') === 'true';
            activeElement.setAttribute('aria-checked', (!isChecked).toString());
            const event = new CustomEvent('toggle-checkbox', {
                detail: { checked: !isChecked }
            });
            activeElement.dispatchEvent(event);
        }
        else if (activeElement.getAttribute('role') === 'switch') {
            const isPressed = activeElement.getAttribute('aria-pressed') === 'true';
            activeElement.setAttribute('aria-pressed', (!isPressed).toString());
            const event = new CustomEvent('toggle-switch', {
                detail: { pressed: !isPressed }
            });
            activeElement.dispatchEvent(event);
        }
    }, []);
    // Handle keyboard events
    const handleKeyDown = useCallback((event) => {
        const { key, ctrlKey, shiftKey, altKey, metaKey } = event;
        // Handle Escape key for closing modals
        if (enableEscapeClose && key === 'Escape') {
            const modals = document.querySelectorAll('[role="dialog"][aria-modal="true"]');
            if (modals.length > 0) {
                const lastModal = modals[modals.length - 1];
                const closeEvent = new Event('close', { bubbles: true });
                lastModal.dispatchEvent(closeEvent);
                event.preventDefault();
                return;
            }
        }
        // Handle arrow key navigation
        if (enableArrowNavigation) {
            if (['ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight'].includes(key)) {
                const activeElement = document.activeElement;
                const role = activeElement.getAttribute('role');
                if (role === 'listitem' || role === 'option' || role === 'menuitem') {
                    if (key === 'ArrowUp' || key === 'ArrowDown') {
                        event.preventDefault();
                        navigateList(key === 'ArrowUp' ? 'up' : 'down');
                        return;
                    }
                }
                if (activeElement.closest('[role="region"][aria-label*="carousel"]')) {
                    if (key === 'ArrowLeft' || key === 'ArrowRight') {
                        event.preventDefault();
                        navigateCarousel(key === 'ArrowLeft' ? 'left' : 'right');
                        return;
                    }
                }
            }
        }
        // Handle keyboard shortcuts
        if (enableShortcuts) {
            const shortcutKey = getShortcutKey({ key, ctrlKey, shiftKey, altKey, metaKey });
            const shortcut = shortcutMapRef.current.get(shortcutKey);
            if (shortcut) {
                event.preventDefault();
                shortcut.action();
                return;
            }
        }
    }, [enableEscapeClose, enableArrowNavigation, enableShortcuts, navigateList, navigateCarousel]);
    // Setup focus trap
    const setupFocusTrap = useCallback((element) => {
        if (!enableFocusTraps)
            return () => { };
        focusTrapRef.current = element;
        previousFocusRef.current = document.activeElement;
        const focusableElements = element.querySelectorAll('button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])');
        if (focusableElements.length === 0)
            return () => { };
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
        setTimeout(() => {
            firstFocusable.focus();
        }, 0);
        // Return cleanup function
        return () => {
            var _a;
            element.removeEventListener('keydown', handleTabKey);
            (_a = previousFocusRef.current) === null || _a === void 0 ? void 0 : _a.focus();
        };
    }, [enableFocusTraps]);
    // Add visual focus indicators
    const setupFocusIndicators = useCallback(() => {
        const style = document.createElement('style');
        style.textContent = `
      .focus-visible {
        outline: 3px solid #4f46e5 !important;
        outline-offset: 2px !important;
        box-shadow: 0 0 0 4px rgba(79, 70, 229, 0.1) !important;
      }
      
      .keyboard-shortcuts-dialog {
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        background: white;
        border-radius: 12px;
        padding: 24px;
        box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
        z-index: 10000;
        max-width: 600px;
        width: 90%;
        max-height: 80vh;
        overflow-y: auto;
      }
      
      .keyboard-shortcuts-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 20px;
      }
      
      .keyboard-shortcuts-header h2 {
        margin: 0;
        font-size: 1.5rem;
        font-weight: 600;
      }
      
      .close-button {
        background: none;
        border: none;
        font-size: 1.5rem;
        cursor: pointer;
        padding: 4px 12px;
        border-radius: 6px;
      }
      
      .close-button:hover {
        background: #f3f4f6;
      }
      
      .keyboard-shortcuts-content table {
        width: 100%;
        border-collapse: collapse;
      }
      
      .keyboard-shortcuts-content th,
      .keyboard-shortcuts-content td {
        padding: 12px;
        text-align: left;
        border-bottom: 1px solid #e5e7eb;
      }
      
      .keyboard-shortcuts-content th {
        font-weight: 600;
        background: #f9fafb;
      }
      
      .keyboard-shortcuts-content kbd {
        background: #f3f4f6;
        border: 1px solid #d1d5db;
        border-radius: 4px;
        padding: 2px 6px;
        font-family: monospace;
        font-size: 0.875rem;
      }
    `;
        document.head.appendChild(style);
        // Add focus-visible class on keyboard navigation
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Tab') {
                document.body.classList.add('keyboard-navigation');
            }
        });
        document.addEventListener('mousedown', () => {
            document.body.classList.remove('keyboard-navigation');
        });
        // Style focus for keyboard navigation only
        const focusStyle = document.createElement('style');
        focusStyle.textContent = `
      .keyboard-navigation :focus {
        outline: 3px solid #4f46e5 !important;
        outline-offset: 2px !important;
      }
      
      .keyboard-navigation :focus:not(.focus-visible) {
        outline: none !important;
      }
    `;
        document.head.appendChild(focusStyle);
        return () => {
            document.head.removeChild(style);
            document.head.removeChild(focusStyle);
        };
    }, []);
    // Initialize keyboard navigation
    useEffect(() => {
        if (typeof document === 'undefined')
            return;
        const cleanupFocusIndicators = setupFocusIndicators();
        document.addEventListener('keydown', handleKeyDown);
        // Initialize preferences
        import('../utils/accessibility').then(({ preferencesManager }) => {
            preferencesManager.initialize();
        });
        return () => {
            document.removeEventListener('keydown', handleKeyDown);
            cleanupFocusIndicators === null || cleanupFocusIndicators === void 0 ? void 0 : cleanupFocusIndicators();
        };
    }, [handleKeyDown, setupFocusIndicators]);
    // Helper function to get shortcut key
    const getShortcutKey = (shortcut) => {
        const parts = [];
        if (shortcut.ctrlKey)
            parts.push('Ctrl');
        if (shortcut.shiftKey)
            parts.push('Shift');
        if (shortcut.altKey)
            parts.push('Alt');
        if (shortcut.metaKey)
            parts.push('Cmd');
        parts.push(shortcut.key || '');
        return parts.join('+');
    };
    // Helper function to format shortcut for display
    const formatShortcutDisplay = (shortcut) => {
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
        else {
            parts.push(shortcut.key.toUpperCase());
        }
        return parts.join(' + ');
    };
    return {
        setupFocusTrap,
        showKeyboardShortcuts,
        navigateList,
        navigateCarousel,
        activateSelectedItem,
        toggleSelection,
    };
};
//# sourceMappingURL=useKeyboardNavigation.js.map