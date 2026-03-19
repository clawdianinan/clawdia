/**
 * Keyboard Navigation Hook for React Applications
 * Provides comprehensive keyboard navigation support
 */
export interface KeyboardShortcut {
    key: string;
    ctrlKey?: boolean;
    shiftKey?: boolean;
    altKey?: boolean;
    metaKey?: boolean;
    description: string;
    action: () => void;
}
export interface KeyboardNavigationConfig {
    enableShortcuts?: boolean;
    enableFocusTraps?: boolean;
    enableArrowNavigation?: boolean;
    enableEscapeClose?: boolean;
    shortcuts?: KeyboardShortcut[];
}
export declare const useKeyboardNavigation: (config?: KeyboardNavigationConfig) => {
    setupFocusTrap: any;
    showKeyboardShortcuts: any;
    navigateList: any;
    navigateCarousel: any;
    activateSelectedItem: any;
    toggleSelection: any;
};
//# sourceMappingURL=useKeyboardNavigation.d.ts.map