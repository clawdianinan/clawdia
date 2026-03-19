/**
 * Accessibility Menu Component
 * Provides accessibility controls for users with different needs
 */
import React from 'react';
import { AccessibilityPreferences } from '../../utils/accessibility';
interface AccessibilityMenuProps {
    position?: 'top-right' | 'top-left' | 'bottom-right' | 'bottom-left';
    showFloatingButton?: boolean;
    showInSettings?: boolean;
    onPreferencesChange?: (preferences: AccessibilityPreferences) => void;
}
declare const AccessibilityMenu: React.FC<AccessibilityMenuProps>;
export default AccessibilityMenu;
//# sourceMappingURL=AccessibilityMenu.d.ts.map