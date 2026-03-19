/**
 * useDarkMode Hook
 * 
 * System preference detection with manual override, persistence,
 * and smooth theme transitions.
 */

import { useState, useEffect, useCallback, useRef } from 'react';

/**
 * Theme modes
 */
export type ThemeMode = 'light' | 'dark' | 'system';

/**
 * Theme preference storage
 */
export interface ThemePreference {
  mode: ThemeMode;
  lastUpdated: number;
}

/**
 * useDarkMode hook return type
 */
export interface UseDarkModeReturn {
  /** Current theme mode */
  theme: ThemeMode;
  /** Whether dark mode is active */
  isDarkMode: boolean;
  /** Set theme mode */
  setTheme: (mode: ThemeMode) => void;
  /** Toggle between light and dark */
  toggleTheme: () => void;
  /** Reset to system preference */
  resetToSystem: () => void;
  /** Whether theme is being changed */
  isChanging: boolean;
}

/**
 * Storage keys
 */
const STORAGE_KEY = 'theme-preference';
const DEFAULT_THEME: ThemeMode = 'system';

/**
 * Get system preference
 */
function getSystemPreference(): boolean {
  if (typeof window === 'undefined') return false;
  return window.matchMedia('(prefers-color-scheme: dark)').matches;
}

/**
 * Get stored preference
 */
function getStoredPreference(): ThemePreference | null {
  if (typeof window === 'undefined') return null;
  
  try {
    const stored = localStorage.getItem(STORAGE_KEY);
    if (stored) {
      return JSON.parse(stored);
    }
  } catch (error) {
    console.warn('Failed to parse theme preference:', error);
  }
  
  return null;
}

/**
 * Store preference
 */
function storePreference(preference: ThemePreference): void {
  if (typeof window === 'undefined') return;
  
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(preference));
  } catch (error) {
    console.warn('Failed to store theme preference:', error);
  }
}

/**
 * Apply theme to document
 */
function applyTheme(mode: ThemeMode, isDark: boolean): void {
  if (typeof document === 'undefined') return;
  
  const root = document.documentElement;
  
  // Remove previous theme attributes
  root.removeAttribute('data-theme');
  root.classList.remove('theme-transition');
  
  // Add transition class for smooth changes
  root.classList.add('theme-transition');
  
  // Apply theme
  if (mode === 'system') {
    root.removeAttribute('data-theme');
  } else {
    root.setAttribute('data-theme', mode);
  }
  
  // Update color scheme meta tag
  updateColorSchemeMeta(isDark);
  
  // Dispatch theme change event
  window.dispatchEvent(new CustomEvent('themechange', { 
    detail: { theme: mode, isDark } 
  }));
  
  // Remove transition class after animation
  setTimeout(() => {
    root.classList.remove('theme-transition');
  }, 300);
}

/**
 * Update color-scheme meta tag
 */
function updateColorSchemeMeta(isDark: boolean): void {
  if (typeof document === 'undefined') return;
  
  let meta = document.querySelector('meta[name="color-scheme"]');
  
  if (!meta) {
    meta = document.createElement('meta');
    meta.setAttribute('name', 'color-scheme');
    document.head.appendChild(meta);
  }
  
  meta.setAttribute('content', isDark ? 'dark' : 'light');
}

/**
 * Check if theme transition is supported
 */
function supportsThemeTransition(): boolean {
  if (typeof CSS === 'undefined' || !CSS.supports) return false;
  return CSS.supports('transition', 'color 300ms ease');
}

/**
 * useDarkMode hook
 */
export function useDarkMode(): UseDarkModeReturn {
  const [theme, setThemeState] = useState<ThemeMode>(DEFAULT_THEME);
  const [isDarkMode, setIsDarkMode] = useState(false);
  const [isChanging, setIsChanging] = useState(false);
  const systemPreferenceRef = useRef(getSystemPreference());
  const mediaQueryRef = useRef<MediaQueryList | null>(null);

  /**
   * Calculate if dark mode should be active
   */
  const calculateIsDarkMode = useCallback((mode: ThemeMode): boolean => {
    if (mode === 'system') {
      return systemPreferenceRef.current;
    }
    return mode === 'dark';
  }, []);

  /**
   * Update theme state
   */
  const updateTheme = useCallback((mode: ThemeMode, skipAnimation = false) => {
    if (skipAnimation || !supportsThemeTransition()) {
      const isDark = calculateIsDarkMode(mode);
      applyTheme(mode, isDark);
      setThemeState(mode);
      setIsDarkMode(isDark);
      return;
    }

    setIsChanging(true);
    
    // Apply theme with transition
    const isDark = calculateIsDarkMode(mode);
    applyTheme(mode, isDark);
    
    // Update state after a short delay to ensure transition starts
    setTimeout(() => {
      setThemeState(mode);
      setIsDarkMode(isDark);
      setIsChanging(false);
    }, 50);
  }, [calculateIsDarkMode]);

  /**
   * Set theme mode
   */
  const setTheme = useCallback((mode: ThemeMode) => {
    const preference: ThemePreference = {
      mode,
      lastUpdated: Date.now(),
    };
    
    storePreference(preference);
    updateTheme(mode);
  }, [updateTheme]);

  /**
   * Toggle between light and dark
   */
  const toggleTheme = useCallback(() => {
    const newMode = theme === 'dark' ? 'light' : 'dark';
    setTheme(newMode);
  }, [theme, setTheme]);

  /**
   * Reset to system preference
   */
  const resetToSystem = useCallback(() => {
    setTheme('system');
  }, [setTheme]);

  /**
   * Handle system preference change
   */
  const handleSystemPreferenceChange = useCallback((event: MediaQueryListEvent) => {
    systemPreferenceRef.current = event.matches;
    
    if (theme === 'system') {
      updateTheme('system');
    }
  }, [theme, updateTheme]);

  /**
   * Initialize theme
   */
  useEffect(() => {
    // Get stored preference or default
    const stored = getStoredPreference();
    const initialTheme = stored?.mode || DEFAULT_THEME;
    
    // Update system preference ref
    systemPreferenceRef.current = getSystemPreference();
    
    // Apply initial theme
    updateTheme(initialTheme, true);
    
    // Set up media query listener
    mediaQueryRef.current = window.matchMedia('(prefers-color-scheme: dark)');
    mediaQueryRef.current.addEventListener('change', handleSystemPreferenceChange);
    
    return () => {
      if (mediaQueryRef.current) {
        mediaQueryRef.current.removeEventListener('change', handleSystemPreferenceChange);
      }
    };
  }, [handleSystemPreferenceChange, updateTheme]);

  /**
   * Handle page visibility changes
   */
  useEffect(() => {
    const handleVisibilityChange = () => {
      if (document.visibilityState === 'visible') {
        // Re-apply theme when page becomes visible
        updateTheme(theme, true);
      }
    };

    document.addEventListener('visibilitychange', handleVisibilityChange);
    
    return () => {
      document.removeEventListener('visibilitychange', handleVisibilityChange);
    };
  }, [theme, updateTheme]);

  /**
   * Prevent flash of wrong theme (FOWT)
   */
  useEffect(() => {
    if (typeof document === 'undefined') return;
    
    // Add critical styles to prevent FOWT
    const style = document.createElement('style');
    style.textContent = `
      :root:not([data-theme]) {
        color-scheme: dark light;
      }
      
      :root[data-theme="dark"] {
        color-scheme: dark;
      }
      
      :root[data-theme="light"] {
        color-scheme: light;
      }
    `;
    
    document.head.appendChild(style);
    
    return () => {
      document.head.removeChild(style);
    };
  }, []);

  return {
    theme,
    isDarkMode,
    setTheme,
    toggleTheme,
    resetToSystem,
    isChanging,
  };
}

/**
 * ThemeToggle component props
 */
export interface ThemeToggleProps {
  /** Size of the toggle */
  size?: 'sm' | 'md' | 'lg';
  /** Show labels */
  showLabels?: boolean;
  /** Custom class name */
  className?: string;
}

/**
 * ThemeToggle component
 */
export const ThemeToggle: React.FC<ThemeToggleProps> = ({
  size = 'md',
  showLabels = false,
  className = '',
}) => {
  const { theme, isDarkMode, toggleTheme, isChanging } = useDarkMode();
  
  const sizeClasses = {
    sm: 'w-10 h-6',
    md: 'w-12 h-7',
    lg: 'w-14 h-8',
  };
  
  const knobSize = {
    sm: 'h-4 w-4',
    md: 'h-5 w-5',
    lg: 'h-6 w-6',
  };
  
  const knobPosition = {
    sm: isDarkMode ? 'translate-x-5' : 'translate-x-1',
    md: isDarkMode ? 'translate-x-6' : 'translate-x-1',
    lg: isDarkMode ? 'translate-x-7' : 'translate-x-1',
  };

  return (
    <div className={`theme-toggle ${className}`}>
      <button
        type="button"
        onClick={toggleTheme}
        disabled={isChanging}
        className={`
          relative inline-flex items-center rounded-full
          ${sizeClasses[size]}
          bg-gray-300 dark:bg-gray-700
          transition-all duration-300 ease-in-out
          focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary
          disabled:opacity-50 disabled:cursor-not-allowed
          ${isChanging ? 'opacity-70' : ''}
        `}
        aria-label={`Switch to ${isDarkMode ? 'light' : 'dark'} mode`}
      >
        {/* Sun icon */}
        <span
          className={`
            absolute left-1 top-1/2 -translate-y-1/2
            ${size === 'sm' ? 'text-xs' : size === 'md' ? 'text-sm' : 'text-base'}
            transition-opacity duration-300
            ${isDarkMode ? 'opacity-0' : 'opacity-100'}
          `}
          aria-hidden="true"
        >
          ☀️
        </span>
        
        {/* Moon icon */}
        <span
          className={`
            absolute right-1 top-1/2 -translate-y-1/2
            ${size === 'sm' ? 'text-xs' : size === 'md' ? 'text-sm' : 'text-base'}
            transition-opacity duration-300
            ${isDarkMode ? 'opacity-100' : 'opacity-0'}
          `}
          aria-hidden="true"
        >
          🌙
        </span>
        
        {/* Toggle knob */}
        <span
          className={`
            absolute inline-block rounded-full bg-white dark:bg-gray-900
            ${knobSize[size]} ${knobPosition[size]}
            transition-all duration-300 ease-in-out
            shadow-md
          `}
          aria-hidden="true"
        />
      </button>
      
      {showLabels && (
        <span className="ml-2 text-sm text-gray-600 dark:text-gray-400">
          {theme === 'system' ? 'System' : isDarkMode ? 'Dark' : 'Light'}
        </span>
      )}
      
      {/* Loading indicator */}
      {isChanging && (
        <div className="absolute inset-0 flex items-center justify-center">
          <div className="w-4 h-4 border-2 border-primary border-t-transparent rounded-full animate-spin" />
        </div>
      )}
    </div>
  );
};

/**
 * Initialize theme system
 */
export function initializeThemeSystem(): void {
  if (typeof window === 'undefined') return;
  
  // Prevent flash of wrong theme
  const stored = getStoredPreference();
  const systemDark = getSystemPreference();
  
  let initialTheme: ThemeMode = 'system';
  let isDark = systemDark;
  
  if (stored) {
    initialTheme = stored.mode;
    isDark = initialTheme === 'system' ? systemDark : initialTheme === 'dark';
  }
  
  // Apply theme immediately
  applyTheme(initialTheme, isDark);
  
  // Store initial preference if not already stored
  if (!stored) {
    storePreference({
      mode: initialTheme,
      lastUpdated: Date.now(),
    });
  }
  
  console.log('Theme system initialized:', { theme: initialTheme, isDark });
}

/**
 * Get current theme information
 */
export function getCurrentThemeInfo(): {
  theme: ThemeMode;
  isDark: boolean;
  isSystem: boolean;
} {
  if (typeof window === 'undefined') {
    return { theme: 'system', isDark: false, isSystem: true };
  }
  
  const stored = getStoredPreference();
  const systemDark = getSystemPreference();
  
  const theme = stored?.mode || 'system';
  const isSystem = theme === 'system';
  const isDark = isSystem ? systemDark : theme === 'dark';
  
  return { theme, isDark, isSystem };
}

/**
 * Subscribe to theme changes
 */
export function subscribeToThemeChanges(
  callback: (theme: ThemeMode, isDark: boolean) => void
): () => void {
  if (typeof window === 'undefined') return () => {};
  
  const handler = (event: CustomEvent) => {
    callback(event.detail.theme, event.detail.isDark);
  };
  
  window.addEventListener('themechange', handler as EventListener);
  
  return () => {
    window.removeEventListener('themechange', handler as EventListener);
  };
}

export default useDarkMode;