/**
 * Accessibility Menu Component
 * Provides accessibility controls for users with different needs
 */

import React, { useState, useEffect, useRef } from 'react';
import { AccessibilityPreferences, preferencesManager } from '../../utils/accessibility';

interface AccessibilityMenuProps {
  position?: 'top-right' | 'top-left' | 'bottom-right' | 'bottom-left';
  showFloatingButton?: boolean;
  showInSettings?: boolean;
  onPreferencesChange?: (preferences: AccessibilityPreferences) => void;
}

const AccessibilityMenu: React.FC<AccessibilityMenuProps> = ({
  position = 'bottom-right',
  showFloatingButton = true,
  showInSettings = false,
  onPreferencesChange,
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const [preferences, setPreferences] = useState<AccessibilityPreferences>(
    preferencesManager.getPreferences()
  );
  const [showResetConfirm, setShowResetConfirm] = useState(false);
  const menuRef = useRef<HTMLDivElement>(null);
  const buttonRef = useRef<HTMLButtonElement>(null);

  // Load preferences on mount
  useEffect(() => {
    const currentPreferences = preferencesManager.getPreferences();
    setPreferences(currentPreferences);
    preferencesManager.applyPreferences(currentPreferences);
  }, []);

  // Close menu when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (
        menuRef.current &&
        !menuRef.current.contains(event.target as Node) &&
        buttonRef.current &&
        !buttonRef.current.contains(event.target as Node)
      ) {
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
    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape' && isOpen) {
        setIsOpen(false);
        buttonRef.current?.focus();
      }
    };

    document.addEventListener('keydown', handleKeyDown);
    return () => document.removeEventListener('keydown', handleKeyDown);
  }, [isOpen]);

  // Update preference
  const updatePreference = (key: keyof AccessibilityPreferences, value: any) => {
    const newPreferences = { ...preferences, [key]: value };
    setPreferences(newPreferences);
    preferencesManager.savePreferences({ [key]: value });
    onPreferencesChange?.(newPreferences);
  };

  // Reset to defaults
  const resetToDefaults = () => {
    const defaultPreferences: AccessibilityPreferences = {
      highContrast: false,
      textScale: 1.0,
      simplifiedUI: false,
      dyslexiaFriendly: false,
      reducedMotion: false,
    };
    
    setPreferences(defaultPreferences);
    preferencesManager.savePreferences(defaultPreferences);
    onPreferencesChange?.(defaultPreferences);
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
  const FloatingButton = () => (
    <button
      ref={buttonRef}
      onClick={() => setIsOpen(!isOpen)}
      className={`fixed ${getPositionClasses()} z-50 flex items-center justify-center w-12 h-12 rounded-full bg-indigo-600 text-white shadow-lg hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition-all duration-200`}
      aria-label="Accessibility settings"
      aria-expanded={isOpen}
      aria-controls="accessibility-menu"
    >
      <svg
        className="w-6 h-6"
        fill="none"
        stroke="currentColor"
        viewBox="0 0 24 24"
        xmlns="http://www.w3.org/2000/svg"
      >
        <path
          strokeLinecap="round"
          strokeLinejoin="round"
          strokeWidth={2}
          d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"
        />
      </svg>
    </button>
  );

  // Menu content
  const MenuContent = () => (
    <div
      ref={menuRef}
      id="accessibility-menu"
      role="dialog"
      aria-label="Accessibility settings"
      className="fixed z-50 w-80 bg-white rounded-lg shadow-xl border border-gray-200"
      style={{
        [position.includes('right') ? 'right' : 'left']: '1rem',
        [position.includes('top') ? 'top' : 'bottom']: '4rem',
      }}
    >
      <div className="p-4">
        {/* Header */}
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold text-gray-900">
            Accessibility Settings
          </h2>
          <button
            onClick={() => setIsOpen(false)}
            className="text-gray-400 hover:text-gray-600 focus:outline-none"
            aria-label="Close accessibility menu"
          >
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        {/* High Contrast Mode */}
        <div className="mb-4">
          <label className="flex items-center justify-between cursor-pointer">
            <div>
              <span className="font-medium text-gray-900">High Contrast Mode</span>
              <p className="text-sm text-gray-500">Increase contrast for better visibility</p>
            </div>
            <div className="relative">
              <input
                type="checkbox"
                checked={preferences.highContrast}
                onChange={(e) => updatePreference('highContrast', e.target.checked)}
                className="sr-only"
                aria-label="Toggle high contrast mode"
              />
              <div className={`block w-12 h-6 rounded-full transition-colors duration-200 ${
                preferences.highContrast ? 'bg-indigo-600' : 'bg-gray-300'
              }`} />
              <div className={`absolute left-1 top-1 bg-white w-4 h-4 rounded-full transition-transform duration-200 ${
                preferences.highContrast ? 'transform translate-x-6' : ''
              }`} />
            </div>
          </label>
        </div>

        {/* Text Scaling */}
        <div className="mb-4">
          <div className="flex items-center justify-between mb-2">
            <span className="font-medium text-gray-900">Text Size</span>
            <span className="text-sm text-gray-600">{preferences.textScale * 100}%</span>
          </div>
          <input
            type="range"
            min="100"
            max="200"
            step="25"
            value={preferences.textScale * 100}
            onChange={(e) => updatePreference('textScale', parseInt(e.target.value) / 100)}
            className="w-full h-2 bg-gray-300 rounded-lg appearance-none cursor-pointer"
            aria-label="Adjust text size"
            aria-valuemin={100}
            aria-valuemax={200}
            aria-valuenow={preferences.textScale * 100}
          />
          <div className="flex justify-between text-xs text-gray-500 mt-1">
            <span>100%</span>
            <span>125%</span>
            <span>150%</span>
            <span>175%</span>
            <span>200%</span>
          </div>
        </div>

        {/* Simplified UI */}
        <div className="mb-4">
          <label className="flex items-center justify-between cursor-pointer">
            <div>
              <span className="font-medium text-gray-900">Simplified Interface</span>
              <p className="text-sm text-gray-500">Reduce visual complexity</p>
            </div>
            <div className="relative">
              <input
                type="checkbox"
                checked={preferences.simplifiedUI}
                onChange={(e) => updatePreference('simplifiedUI', e.target.checked)}
                className="sr-only"
                aria-label="Toggle simplified interface"
              />
              <div className={`block w-12 h-6 rounded-full transition-colors duration-200 ${
                preferences.simplifiedUI ? 'bg-indigo-600' : 'bg-gray-300'
              }`} />
              <div className={`absolute left-1 top-1 bg-white w-4 h-4 rounded-full transition-transform duration-200 ${
                preferences.simplifiedUI ? 'transform translate-x-6' : ''
              }`} />
            </div>
          </label>
        </div>

        {/* Dyslexia-Friendly Font */}
        <div className="mb-4">
          <label className="flex items-center justify-between cursor-pointer">
            <div>
              <span className="font-medium text-gray-900">Dyslexia-Friendly Font</span>
              <p className="text-sm text-gray-500">Use OpenDyslexic font</p>
            </div>
            <div className="relative">
              <input
                type="checkbox"
                checked={preferences.dyslexiaFriendly}
                onChange={(e) => updatePreference('dyslexiaFriendly', e.target.checked)}
                className="sr-only"
                aria-label="Toggle dyslexia-friendly font"
              />
              <div className={`block w-12 h-6 rounded-full transition-colors duration-200 ${
                preferences.dyslexiaFriendly ? 'bg-indigo-600' : 'bg-gray-300'
              }`} />
              <div className={`absolute left-1 top-1 bg-white w-4 h-4 rounded-full transition-transform duration-200 ${
                preferences.dyslexiaFriendly ? 'transform translate-x-6' : ''
              }`} />
            </div>
          </label>
        </div>

        {/* Reduced Motion */}
        <div className="mb-6">
          <label className="flex items-center justify-between cursor-pointer">
            <div>
              <span className="font-medium text-gray-900">Reduced Motion</span>
              <p className="text-sm text-gray-500">Minimize animations</p>
            </div>
            <div className="relative">
              <input
                type="checkbox"
                checked={preferences.reducedMotion}
                onChange={(e) => updatePreference('reducedMotion', e.target.checked)}
                className="sr-only"
                aria-label="Toggle reduced motion"
              />
              <div className={`block w-12 h-6 rounded-full transition-colors duration-200 ${
                preferences.reducedMotion ? 'bg-indigo-600' : 'bg-gray-300'
              }`} />
              <div className={`absolute left-1 top-1 bg-white w-4 h-4 rounded-full transition-transform duration-200 ${
                preferences.reducedMotion ? 'transform translate-x-6' : ''
              }`} />
            </div>
          </label>
        </div>

        {/* Reset Button */}
        <div className="border-t border-gray-200 pt-4">
          {showResetConfirm ? (
            <div className="space-y-2">
              <p className="text-sm text-gray-700">Reset all settings to defaults?</p>
              <div className="flex space-x-2">
                <button
                  onClick={resetToDefaults}
                  className="flex-1 px-3 py-2 text-sm font-medium text-white bg-red-600 rounded-md hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
                >
                  Yes, Reset
                </button>
                <button
                  onClick={() => setShowResetConfirm(false)}
                  className="flex-1 px-3 py-2 text-sm font-medium text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500"
                >
                  Cancel
                </button>
              </div>
            </div>
          ) : (
            <button
              onClick={() => setShowResetConfirm(true)}
              className="w-full px-3 py-2 text-sm font-medium text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500"
            >
              Reset to Defaults
            </button>
          )}
        </div>

        {/* Keyboard Shortcuts Link */}
        <div className="mt-4 pt-4 border-t border-gray-200">
          <button
            onClick={() => {
              const event = new CustomEvent('show-keyboard-shortcuts');
              window.dispatchEvent(event);
              setIsOpen(false);
            }}
            className="w-full px-3 py-2 text-sm font-medium text-indigo-600 bg-indigo-50 rounded-md hover:bg-indigo-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
          >
            View Keyboard Shortcuts
          </button>
        </div>
      </div>
    </div>
  );

  // Settings panel version (for integration into app settings)
  const SettingsPanel = () => (
    <div className="space-y-6">
      <div>
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Accessibility</h2>
        <p className="text-sm text-gray-600 mb-6">
          Customize the interface to match your accessibility needs.
        </p>
      </div>

      {/* High Contrast Mode */}
      <div className="flex items-center justify-between">
        <div>
          <h3 className="font-medium text-gray-900">High Contrast Mode</h3>
          <p className="text-sm text-gray-500">Increase contrast for better visibility</p>
        </div>
        <button
          onClick={() => updatePreference('highContrast', !preferences.highContrast)}
          className={`relative inline-flex h-6 w-11 items-center rounded-full ${
            preferences.highContrast ? 'bg-indigo-600' : 'bg-gray-300'
          }`}
          aria-label={preferences.highContrast ? 'Disable high contrast mode' : 'Enable high contrast mode'}
        >
          <span
            className={`inline-block h-4 w-4 transform rounded-full bg-white transition ${
              preferences.highContrast ? 'translate-x-6' : 'translate-x-1'
            }`}
          />
        </button>
      </div>

      {/* Text Scaling */}
      <div>
        <div className="flex items-center justify-between mb-2">
          <h3 className="font-medium text-gray-900">Text Size</h3>
          <span className="text-sm text-gray-600">{preferences.textScale * 100}%</span>
        </div>
        <input
          type="range"
          min="100"
          max="200"
          step="25"
          value={preferences.textScale * 100}
          onChange={(e) => updatePreference('textScale', parseInt(e.target.value) / 100)}
          className="w-full h-2 bg-gray-300 rounded-lg appearance-none cursor-pointer"
          aria-label="Adjust text size"
        />
        <div className="flex justify-between text-xs text-gray-500 mt-1">
          <span>100%</span>
          <span>125%</span>
          <span>150%</span>
          <span>175%</span>
          <span>200%</span>
        </div>
      </div>

      {/* Simplified UI */}
      <div className="flex items-center justify-between">
        <div>
          <h3 className="font-medium text-gray-900">Simplified Interface</h3>
          <p className="text-sm text-gray-500">Reduce visual complexity</p>
        </div>
        <button
          onClick={() => updatePreference('simplifiedUI', !preferences.simplifiedUI)}
          className={`relative inline-flex h-6 w-11 items-center rounded-full ${
            preferences.simplifiedUI ? 'bg-indigo-600' : 'bg-gray-300'
          }`}
          aria-label={preferences.simplifiedUI ? 'Disable simplified interface' : 'Enable simplified interface'}
        >
          <span
            className={`inline-block h-4 w-4 transform rounded-full bg-white transition ${
              preferences.simplifiedUI ? 'translate-x-6' : 'translate-x-1'
            }`}
          />
        </button>
      </div>

      {/* Dyslexia-Friendly Font */}
      <div className="flex items-center justify-between">
        <div>
          <h3 className="font-medium text-gray-900">Dyslexia-Friendly Font</h3>
          <p className="text-sm text-gray-500">Use OpenDyslexic font</p>
        </div>
        <button
          onClick={() => updatePreference('dyslexiaFriendly', !preferences.dyslexiaFriendly)}
          className={`relative inline-flex h-6 w-11 items-center rounded-full ${
            preferences.dyslexiaFriendly ? 'bg-indigo-600' : 'bg-gray-300'
          }`}
          aria-label={preferences.dyslexiaFriendly ? 'Disable dyslexia-friendly font' : 'Enable dyslexia-friendly font'}
        >
          <span
            className={`inline-block h-4 w-4 transform rounded-full bg-white transition ${
              preferences.dyslexiaFriendly ? 'translate-x-6' : 'translate-x-1'
            }`}
          />
        </button>
      </div>

      {/* Reduced Motion */}
      <div className="flex items-center justify-between">
        <div>
          <h3 className="font-medium text-gray-900">Reduced Motion</h3>
          <p className="text-sm text-gray-500">Minimize animations</p>
        </div>
        <button
          onClick={() => updatePreference('reducedMotion', !preferences.reducedMotion)}
          className={`relative inline-flex h-6 w-11 items-center rounded-full ${
            preferences.reducedMotion ? 'bg-indigo-600' : 'bg-gray-300'
          }`}
          aria-label={preferences.reducedMotion ? 'Disable reduced motion' : 'Enable reduced motion'}
        >
          <span
            className={`inline-block h-4 w-4 transform rounded-full bg-white transition ${
              preferences.reducedMotion ? 'translate-x-6' : 'translate-x-1'
            }`}
          />
        </button>
      </div>

      {/* Reset Button */}
      <div className="pt-6 border-t border-gray-200">
        <button
          onClick={() => setShowResetConfirm(true)}
          className="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500"
        >
          Reset to Defaults
        </button>
        
        {showResetConfirm && (
          <div className="mt-4 p-4 bg-yellow-50 rounded-md">
            <p className="text-sm text-yellow-800 mb-2">Reset all settings to defaults?</p>
            <div className="flex space-x-2">
              <button
                onClick={resetToDefaults}
                className="px-3 py-1 text-sm font-medium text-white bg-red-600 rounded hover:bg-red-700"
              >
                Yes, Reset
              </button>
              <button
                onClick={() => setShowResetConfirm(false)}
                className="px-3 py-1 text-sm font-medium text-gray-700 bg-gray-200 rounded hover:bg-gray-300"
              >
                Cancel
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Keyboard Shortcuts */}
      <div className="pt-6 border-t border-gray-200">
        <button
          onClick={() => {
            const event = new CustomEvent('show-keyboard-shortcuts');
            window.dispatchEvent(event);
          }}
          className="px-4 py-2 text-sm font-medium text-indigo-600 bg-indigo-50 rounded-md hover:bg-indigo-100 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
        >
          View Keyboard Shortcuts
        </button>
      </div>
    </div>
  );

  // Render based on mode
  if (showInSettings) {
    return <SettingsPanel />;
  }

  return (
    <>
      {showFloatingButton && <FloatingButton />}
      {isOpen && <MenuContent />}
    </>
  );
};

export default AccessibilityMenu;