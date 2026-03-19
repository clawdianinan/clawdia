import { jsx as _jsx, jsxs as _jsxs, Fragment as _Fragment } from "react/jsx-runtime";
/**
 * Accessibility Menu Component
 * Provides accessibility controls for users with different needs
 */
import React, { useState, useEffect, useRef } from 'react';
import { preferencesManager } from '../../utils/accessibility';
const AccessibilityMenu = ({ position = 'bottom-right', showFloatingButton = true, showInSettings = false, onPreferencesChange, }) => {
    const [isOpen, setIsOpen] = useState(false);
    const [preferences, setPreferences] = useState(preferencesManager.getPreferences());
    const [showResetConfirm, setShowResetConfirm] = useState(false);
    const menuRef = useRef(null);
    const buttonRef = useRef(null);
    // Load preferences on mount
    useEffect(() => {
        const currentPreferences = preferencesManager.getPreferences();
        setPreferences(currentPreferences);
        preferencesManager.applyPreferences(currentPreferences);
    }, []);
    // Close menu when clicking outside
    useEffect(() => {
        const handleClickOutside = (event) => {
            if (menuRef.current &&
                !menuRef.current.contains(event.target) &&
                buttonRef.current &&
                !buttonRef.current.contains(event.target)) {
                setIsOpen(false);
            }
        };
        if (isOpen) {
            document.addEventListener('mousedown', handleClickOutside);
        }
        return () => {
            document.removeEventListener('mousedown', handleClickOutside);
        };
    }, [isOpen]);
    // Handle keyboard navigation
    useEffect(() => {
        const handleKeyDown = (event) => {
            var _a;
            if (event.key === 'Escape' && isOpen) {
                setIsOpen(false);
                (_a = buttonRef.current) === null || _a === void 0 ? void 0 : _a.focus();
            }
        };
        document.addEventListener('keydown', handleKeyDown);
        return () => document.removeEventListener('keydown', handleKeyDown);
    }, [isOpen]);
    // Update preference
    const updatePreference = (key, value) => {
        const newPreferences = Object.assign(Object.assign({}, preferences), { [key]: value });
        setPreferences(newPreferences);
        preferencesManager.savePreferences({ [key]: value });
        onPreferencesChange === null || onPreferencesChange === void 0 ? void 0 : onPreferencesChange(newPreferences);
    };
    // Reset to defaults
    const resetToDefaults = () => {
        const defaultPreferences = {
            highContrast: false,
            textScale: 1.0,
            simplifiedUI: false,
            dyslexiaFriendly: false,
            reducedMotion: false,
        };
        setPreferences(defaultPreferences);
        preferencesManager.savePreferences(defaultPreferences);
        onPreferencesChange === null || onPreferencesChange === void 0 ? void 0 : onPreferencesChange(defaultPreferences);
        setShowResetConfirm(false);
    };
    // Get position classes
    const getPositionClasses = () => {
        switch (position) {
            case 'top-right':
                return 'top-4 right-4';
            case 'top-left':
                return 'top-4 left-4';
            case 'bottom-left':
                return 'bottom-4 left-4';
            case 'bottom-right':
            default:
                return 'bottom-4 right-4';
        }
    };
    // Floating button component
    const FloatingButton = () => (_jsx("button", { ref: buttonRef, onClick: () => setIsOpen(!isOpen), className: `fixed ${getPositionClasses()} z-50 flex items-center justify-center w-12 h-12 rounded-full bg-indigo-600 text-white shadow-lg hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition-all duration-200`, "aria-label": "Accessibility settings", "aria-expanded": isOpen, "aria-controls": "accessibility-menu", children: _jsx("svg", { className: "w-6 h-6", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", xmlns: "http://www.w3.org/2000/svg", children: _jsx("path", { strokeLinecap: "round", strokeLinejoin: "round", strokeWidth: 2, d: "M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" }) }) }));
    // Menu content
    const MenuContent = () => (_jsx("div", { ref: menuRef, id: "accessibility-menu", role: "dialog", "aria-label": "Accessibility settings", className: "fixed z-50 w-80 bg-white rounded-lg shadow-xl border border-gray-200", style: {
            [position.includes('right') ? 'right' : 'left']: '1rem',
            [position.includes('top') ? 'top' : 'bottom']: '4rem',
        }, children: _jsxs("div", { className: "p-4", children: [_jsxs("div", { className: "flex items-center justify-between mb-4", children: [_jsx("h2", { className: "text-lg font-semibold text-gray-900", children: "Accessibility Settings" }), _jsx("button", { onClick: () => setIsOpen(false), className: "text-gray-400 hover:text-gray-600 focus:outline-none", "aria-label": "Close accessibility menu", children: _jsx("svg", { className: "w-5 h-5", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", children: _jsx("path", { strokeLinecap: "round", strokeLinejoin: "round", strokeWidth: 2, d: "M6 18L18 6M6 6l12 12" }) }) })] }), _jsx("div", { className: "mb-4", children: _jsxs("label", { className: "flex items-center justify-between cursor-pointer", children: [_jsxs("div", { children: [_jsx("span", { className: "font-medium text-gray-900", children: "High Contrast Mode" }), _jsx("p", { className: "text-sm text-gray-500", children: "Increase contrast for better visibility" })] }), _jsxs("div", { className: "relative", children: [_jsx("input", { type: "checkbox", checked: preferences.highContrast, onChange: (e) => updatePreference('highContrast', e.target.checked), className: "sr-only", "aria-label": "Toggle high contrast mode" }), _jsx("div", { className: `block w-12 h-6 rounded-full transition-colors duration-200 ${preferences.highContrast ? 'bg-indigo-600' : 'bg-gray-300'}` }), _jsx("div", { className: `absolute left-1 top-1 bg-white w-4 h-4 rounded-full transition-transform duration-200 ${preferences.highContrast ? 'transform translate-x-6' : ''}` })] })] }) }), _jsxs("div", { className: "mb-4", children: [_jsxs("div", { className: "flex items-center justify-between mb-2", children: [_jsx("span", { className: "font-medium text-gray-900", children: "Text Size" }), _jsxs("span", { className: "text-sm text-gray-600", children: [preferences.textScale * 100, "%"] })] }), _jsx("input", { type: "range", min: "100", max: "200", step: "25", value: preferences.textScale * 100, onChange: (e) => updatePreference('textScale', parseInt(e.target.value) / 100), className: "w-full h-2 bg-gray-300 rounded-lg appearance-none cursor-pointer", "aria-label": "Adjust text size", "aria-valuemin": 100, "aria-valuemax": 200, "aria-valuenow": preferences.textScale * 100 }), _jsxs("div", { className: "flex justify-between text-xs text-gray-500 mt-1", children: [_jsx("span", { children: "100%" }), _jsx("span", { children: "125%" }), _jsx("span", { children: "150%" }), _jsx("span", { children: "175%" }), _jsx("span", { children: "200%" })] })] }), _jsx("div", { className: "mb-4", children: _jsxs("label", { className: "flex items-center justify-between cursor-pointer", children: [_jsxs("div", { children: [_jsx("span", { className: "font-medium text-gray-900", children: "Simplified Interface" }), _jsx("p", { className: "text-sm text-gray-500", children: "Reduce visual complexity" })] }), _jsxs("div", { className: "relative", children: [_jsx("input", { type: "checkbox", checked: preferences.simplifiedUI, onChange: (e) => updatePreference('simplifiedUI', e.target.checked), className: "sr-only", "aria-label": "Toggle simplified interface" }), _jsx("div", { className: `block w-12 h-6 rounded-full transition-colors duration-200 ${preferences.simplifiedUI ? 'bg-indigo-600' : 'bg-gray-300'}` }), _jsx("div", { className: `absolute left-1 top-1 bg-white w-4 h-4 rounded-full transition-transform duration-200 ${preferences.simplifiedUI ? 'transform translate-x-6' : ''}` })] })] }) }), _jsx("div", { className: "mb-4", children: _jsxs("label", { className: "flex items-center justify-between cursor-pointer", children: [_jsxs("div", { children: [_jsx("span", { className: "font-medium text-gray-900", children: "Dyslexia-Friendly Font" }), _jsx("p", { className: "text-sm text-gray-500", children: "Use OpenDyslexic font" })] }), _jsxs("div", { className: "relative", children: [_jsx("input", { type: "checkbox", checked: preferences.dyslexiaFriendly, onChange: (e) => updatePreference('dyslexiaFriendly', e.target.checked), className: "sr-only", "aria-label": "Toggle dyslexia-friendly font" }), _jsx("div", { className: `block w-12 h-6 rounded-full transition-colors duration-200 ${preferences.dyslexiaFriendly ? 'bg-indigo-600' : 'bg-gray-300'}` }), _jsx("div", { className: `absolute left-1 top-1 bg-white w-4 h-4 rounded-full transition-transform duration-200 ${preferences.dyslexiaFriendly ? 'transform translate-x-6' : ''}` })] })] }) }), _jsx("div", { className: "mb-6", children: _jsxs("label", { className: "flex items-center justify-between cursor-pointer", children: [_jsxs("div", { children: [_jsx("span", { className: "font-medium text-gray-900", children: "Reduced Motion" }), _jsx("p", { className: "text-sm text-gray-500", children: "Minimize animations" })] }), _jsxs("div", { className: "relative", children: [_jsx("input", { type: "checkbox", checked: preferences.reducedMotion, onChange: (e) => updatePreference('reducedMotion', e.target.checked), className: "sr-only", "aria-label": "Toggle reduced motion" }), _jsx("div", { className: `block w-12 h-6 rounded-full transition-colors duration-200 ${preferences.reducedMotion ? 'bg-indigo-600' : 'bg-gray-300'}` }), _jsx("div", { className: `absolute left-1 top-1 bg-white w-4 h-4 rounded-full transition-transform duration-200 ${preferences.reducedMotion ? 'transform translate-x-6' : ''}` })] })] }) }), _jsx("div", { className: "border-t border-gray-200 pt-4", children: showResetConfirm ? (_jsxs("div", { className: "space-y-2", children: [_jsx("p", { className: "text-sm text-gray-700", children: "Reset all settings to defaults?" }), _jsxs("div", { className: "flex space-x-2", children: [_jsx("button", { onClick: resetToDefaults, className: "flex-1 px-3 py-2 text-sm font-medium text-white bg-red-600 rounded-md hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500", children: "Yes, Reset" }), _jsx("button", { onClick: () => setShowResetConfirm(false), className: "flex-1 px-3 py-2 text-sm font-medium text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500", children: "Cancel" })] })] })) : (_jsx("button", { onClick: () => setShowResetConfirm(true), className: "w-full px-3 py-2 text-sm font-medium text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500", children: "Reset to Defaults" })) }), _jsx("div", { className: "mt-4 pt-4 border-t border-gray-200", children: _jsx("button", { onClick: () => {
                            const event = new CustomEvent('show-keyboard-shortcuts');
                            window.dispatchEvent(event);
                            setIsOpen(false);
                        }, className: "w-full px-3 py-2 text-sm font-medium text-indigo-600 bg-indigo-50 rounded-md hover:bg-indigo-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500", children: "View Keyboard Shortcuts" }) })] }) }));
    // Settings panel version (for integration into app settings)
    const SettingsPanel = () => (_jsxs("div", { className: "space-y-6", children: [_jsxs("div", { children: [_jsx("h2", { className: "text-lg font-semibold text-gray-900 mb-4", children: "Accessibility" }), _jsx("p", { className: "text-sm text-gray-600 mb-6", children: "Customize the interface to match your accessibility needs." })] }), _jsxs("div", { className: "flex items-center justify-between", children: [_jsxs("div", { children: [_jsx("h3", { className: "font-medium text-gray-900", children: "High Contrast Mode" }), _jsx("p", { className: "text-sm text-gray-500", children: "Increase contrast for better visibility" })] }), _jsx("button", { onClick: () => updatePreference('highContrast', !preferences.highContrast), className: `relative inline-flex h-6 w-11 items-center rounded-full ${preferences.highContrast ? 'bg-indigo-600' : 'bg-gray-300'}`, "aria-label": preferences.highContrast ? 'Disable high contrast mode' : 'Enable high contrast mode', children: _jsx("span", { className: `inline-block h-4 w-4 transform rounded-full bg-white transition ${preferences.highContrast ? 'translate-x-6' : 'translate-x-1'}` }) })] }), _jsxs("div", { children: [_jsxs("div", { className: "flex items-center justify-between mb-2", children: [_jsx("h3", { className: "font-medium text-gray-900", children: "Text Size" }), _jsxs("span", { className: "text-sm text-gray-600", children: [preferences.textScale * 100, "%"] })] }), _jsx("input", { type: "range", min: "100", max: "200", step: "25", value: preferences.textScale * 100, onChange: (e) => updatePreference('textScale', parseInt(e.target.value) / 100), className: "w-full h-2 bg-gray-300 rounded-lg appearance-none cursor-pointer", "aria-label": "Adjust text size" }), _jsxs("div", { className: "flex justify-between text-xs text-gray-500 mt-1", children: [_jsx("span", { children: "100%" }), _jsx("span", { children: "125%" }), _jsx("span", { children: "150%" }), _jsx("span", { children: "175%" }), _jsx("span", { children: "200%" })] })] }), _jsxs("div", { className: "flex items-center justify-between", children: [_jsxs("div", { children: [_jsx("h3", { className: "font-medium text-gray-900", children: "Simplified Interface" }), _jsx("p", { className: "text-sm text-gray-500", children: "Reduce visual complexity" })] }), _jsx("button", { onClick: () => updatePreference('simplifiedUI', !preferences.simplifiedUI), className: `relative inline-flex h-6 w-11 items-center rounded-full ${preferences.simplifiedUI ? 'bg-indigo-600' : 'bg-gray-300'}`, "aria-label": preferences.simplifiedUI ? 'Disable simplified interface' : 'Enable simplified interface', children: _jsx("span", { className: `inline-block h-4 w-4 transform rounded-full bg-white transition ${preferences.simplifiedUI ? 'translate-x-6' : 'translate-x-1'}` }) })] }), _jsxs("div", { className: "flex items-center justify-between", children: [_jsxs("div", { children: [_jsx("h3", { className: "font-medium text-gray-900", children: "Dyslexia-Friendly Font" }), _jsx("p", { className: "text-sm text-gray-500", children: "Use OpenDyslexic font" })] }), _jsx("button", { onClick: () => updatePreference('dyslexiaFriendly', !preferences.dyslexiaFriendly), className: `relative inline-flex h-6 w-11 items-center rounded-full ${preferences.dyslexiaFriendly ? 'bg-indigo-600' : 'bg-gray-300'}`, "aria-label": preferences.dyslexiaFriendly ? 'Disable dyslexia-friendly font' : 'Enable dyslexia-friendly font', children: _jsx("span", { className: `inline-block h-4 w-4 transform rounded-full bg-white transition ${preferences.dyslexiaFriendly ? 'translate-x-6' : 'translate-x-1'}` }) })] }), _jsxs("div", { className: "flex items-center justify-between", children: [_jsxs("div", { children: [_jsx("h3", { className: "font-medium text-gray-900", children: "Reduced Motion" }), _jsx("p", { className: "text-sm text-gray-500", children: "Minimize animations" })] }), _jsx("button", { onClick: () => updatePreference('reducedMotion', !preferences.reducedMotion), className: `relative inline-flex h-6 w-11 items-center rounded-full ${preferences.reducedMotion ? 'bg-indigo-600' : 'bg-gray-300'}`, "aria-label": preferences.reducedMotion ? 'Disable reduced motion' : 'Enable reduced motion', children: _jsx("span", { className: `inline-block h-4 w-4 transform rounded-full bg-white transition ${preferences.reducedMotion ? 'translate-x-6' : 'translate-x-1'}` }) })] }), _jsxs("div", { className: "pt-6 border-t border-gray-200", children: [_jsx("button", { onClick: () => setShowResetConfirm(true), className: "px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500", children: "Reset to Defaults" }), showResetConfirm && (_jsxs("div", { className: "mt-4 p-4 bg-yellow-50 rounded-md", children: [_jsx("p", { className: "text-sm text-yellow-800 mb-2", children: "Reset all settings to defaults?" }), _jsxs("div", { className: "flex space-x-2", children: [_jsx("button", { onClick: resetToDefaults, className: "px-3 py-1 text-sm font-medium text-white bg-red-600 rounded hover:bg-red-700", children: "Yes, Reset" }), _jsx("button", { onClick: () => setShowResetConfirm(false), className: "px-3 py-1 text-sm font-medium text-gray-700 bg-gray-200 rounded hover:bg-gray-300", children: "Cancel" })] })] }))] }), _jsx("div", { className: "pt-6 border-t border-gray-200", children: _jsx("button", { onClick: () => {
                        const event = new CustomEvent('show-keyboard-shortcuts');
                        window.dispatchEvent(event);
                    }, className: "px-4 py-2 text-sm font-medium text-indigo-600 bg-indigo-50 rounded-md hover:bg-indigo-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500", children: "View Keyboard Shortcuts" }) })] }));
    // Render based on mode
    if (showInSettings) {
        return _jsx(SettingsPanel, {});
    }
    return (_jsxs(_Fragment, { children: [showFloatingButton && _jsx(FloatingButton, {}), isOpen && _jsx(MenuContent, {})] }));
};
export default AccessibilityMenu;
//# sourceMappingURL=AccessibilityMenu.js.map