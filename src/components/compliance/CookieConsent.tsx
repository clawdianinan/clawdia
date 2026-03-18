import React, { useState, useEffect } from 'react';
import './CookieConsent.css';

interface CookiePreferences {
  necessary: boolean;
  analytics: boolean;
  marketing: boolean;
  preferences: boolean;
}

interface CookieConsentProps {
  onPreferencesChange?: (preferences: CookiePreferences) => void;
  showOnLoad?: boolean;
  privacyPolicyUrl?: string;
  cookiePolicyUrl?: string;
}

const CookieConsent: React.FC<CookieConsentProps> = ({
  onPreferencesChange,
  showOnLoad = true,
  privacyPolicyUrl = '/privacy-policy',
  cookiePolicyUrl = '/cookie-policy',
}) => {
  const [isVisible, setIsVisible] = useState(false);
  const [showDetails, setShowDetails] = useState(false);
  const [preferences, setPreferences] = useState<CookiePreferences>({
    necessary: true, // Always required
    analytics: false,
    marketing: false,
    preferences: false,
  });

  // Cookie types with descriptions
  const cookieTypes = [
    {
      id: 'necessary' as const,
      name: 'Necessary Cookies',
      description: 'These cookies are essential for the website to function properly. They enable basic functions like page navigation and access to secure areas of the website. The website cannot function properly without these cookies.',
      required: true,
    },
    {
      id: 'analytics' as const,
      name: 'Analytics Cookies',
      description: 'These cookies help us understand how visitors interact with our website by collecting and reporting information anonymously. This helps us improve our website and services.',
      required: false,
    },
    {
      id: 'marketing' as const,
      name: 'Marketing Cookies',
      description: 'These cookies are used to track visitors across websites. The intention is to display ads that are relevant and engaging for the individual user.',
      required: false,
    },
    {
      id: 'preferences' as const,
      name: 'Preference Cookies',
      description: 'These cookies allow the website to remember choices you make (such as your username, language, or region) and provide enhanced, more personal features.',
      required: false,
    },
  ];

  // Load saved preferences from localStorage
  useEffect(() => {
    const savedConsent = localStorage.getItem('cookieConsent');
    const savedPreferences = localStorage.getItem('cookiePreferences');
    
    if (savedConsent === 'accepted' && savedPreferences) {
      try {
        const parsedPreferences = JSON.parse(savedPreferences);
        setPreferences(parsedPreferences);
        setIsVisible(false);
        
        // Apply cookie preferences
        applyCookiePreferences(parsedPreferences);
        
        if (onPreferencesChange) {
          onPreferencesChange(parsedPreferences);
        }
      } catch (error) {
        console.error('Error parsing saved cookie preferences:', error);
        setIsVisible(showOnLoad);
      }
    } else if (savedConsent === 'rejected') {
      setIsVisible(false);
      // Apply minimal cookies (necessary only)
      applyCookiePreferences({ necessary: true, analytics: false, marketing: false, preferences: false });
    } else {
      setIsVisible(showOnLoad);
    }
  }, [showOnLoad, onPreferencesChange]);

  // Apply cookie preferences by setting/removing cookies
  const applyCookiePreferences = (prefs: CookiePreferences) => {
    // Necessary cookies are always set
    setCookie('necessary_cookie', 'true', 365);
    
    if (prefs.analytics) {
      setCookie('analytics_consent', 'true', 365);
      // Initialize analytics scripts here
      initializeAnalytics();
    } else {
      deleteCookie('analytics_consent');
      // Remove analytics scripts here
      removeAnalytics();
    }
    
    if (prefs.marketing) {
      setCookie('marketing_consent', 'true', 365);
      // Initialize marketing scripts here
      initializeMarketing();
    } else {
      deleteCookie('marketing_consent');
      // Remove marketing scripts here
      removeMarketing();
    }
    
    if (prefs.preferences) {
      setCookie('preferences_consent', 'true', 365);
      // Initialize preference scripts here
      initializePreferences();
    } else {
      deleteCookie('preferences_consent');
      // Remove preference scripts here
      removePreferences();
    }
    
    // Save the consent choice
    setCookie('cookie_consent', 'true', 365);
  };

  // Helper functions for cookie management
  const setCookie = (name: string, value: string, days: number) => {
    const date = new Date();
    date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
    const expires = `expires=${date.toUTCString()}`;
    document.cookie = `${name}=${value};${expires};path=/;SameSite=Strict`;
  };

  const deleteCookie = (name: string) => {
    document.cookie = `${name}=;expires=Thu, 01 Jan 1970 00:00:00 GMT;path=/`;
  };

  // Placeholder functions for analytics/marketing initialization
  const initializeAnalytics = () => {
    // Initialize Google Analytics, Mixpanel, etc.
    console.log('Analytics initialized');
  };

  const removeAnalytics = () => {
    // Remove analytics scripts
    console.log('Analytics removed');
  };

  const initializeMarketing = () => {
    // Initialize marketing scripts
    console.log('Marketing initialized');
  };

  const removeMarketing = () => {
    // Remove marketing scripts
    console.log('Marketing removed');
  };

  const initializePreferences = () => {
    // Initialize preference scripts
    console.log('Preferences initialized');
  };

  const removePreferences = () => {
    // Remove preference scripts
    console.log('Preferences removed');
  };

  const handleAcceptAll = () => {
    const newPreferences: CookiePreferences = {
      necessary: true,
      analytics: true,
      marketing: true,
      preferences: true,
    };
    
    setPreferences(newPreferences);
    localStorage.setItem('cookieConsent', 'accepted');
    localStorage.setItem('cookiePreferences', JSON.stringify(newPreferences));
    applyCookiePreferences(newPreferences);
    setIsVisible(false);
    
    if (onPreferencesChange) {
      onPreferencesChange(newPreferences);
    }
  };

  const handleAcceptSelected = () => {
    localStorage.setItem('cookieConsent', 'accepted');
    localStorage.setItem('cookiePreferences', JSON.stringify(preferences));
    applyCookiePreferences(preferences);
    setIsVisible(false);
    
    if (onPreferencesChange) {
      onPreferencesChange(preferences);
    }
  };

  const handleRejectAll = () => {
    const newPreferences: CookiePreferences = {
      necessary: true, // Necessary cookies cannot be rejected
      analytics: false,
      marketing: false,
      preferences: false,
    };
    
    setPreferences(newPreferences);
    localStorage.setItem('cookieConsent', 'rejected');
    localStorage.setItem('cookiePreferences', JSON.stringify(newPreferences));
    applyCookiePreferences(newPreferences);
    setIsVisible(false);
    
    if (onPreferencesChange) {
      onPreferencesChange(newPreferences);
    }
  };

  const handleToggleCookie = (cookieId: keyof CookiePreferences) => {
    if (cookieId === 'necessary') return; // Cannot toggle necessary cookies
    
    setPreferences(prev => ({
      ...prev,
      [cookieId]: !prev[cookieId],
    }));
  };

  const handleShowDetails = () => {
    setShowDetails(!showDetails);
  };

  const handleManagePreferences = () => {
    // If banner is hidden, show it with details expanded
    if (!isVisible) {
      setIsVisible(true);
      setShowDetails(true);
    } else {
      setShowDetails(!showDetails);
    }
  };

  if (!isVisible) {
    // Return a small button to manage preferences when banner is hidden
    return (
      <button 
        className="cookie-manage-button"
        onClick={handleManagePreferences}
        aria-label="Manage cookie preferences"
      >
        🍪
      </button>
    );
  }

  return (
    <div className="cookie-consent-banner" role="dialog" aria-label="Cookie consent">
      <div className="cookie-consent-content">
        <div className="cookie-consent-header">
          <h3 className="cookie-consent-title">Cookie Preferences</h3>
          <button 
            className="cookie-consent-close"
            onClick={handleRejectAll}
            aria-label="Close and reject non-essential cookies"
          >
            ×
          </button>
        </div>
        
        <div className="cookie-consent-message">
          <p>
            We use cookies to enhance your browsing experience, analyze site traffic, and personalize content. 
            By clicking "Accept All", you consent to our use of cookies. You can manage your preferences below 
            or learn more in our{' '}
            <a href={privacyPolicyUrl} target="_blank" rel="noopener noreferrer">Privacy Policy</a>
            {' '}and{' '}
            <a href={cookiePolicyUrl} target="_blank" rel="noopener noreferrer">Cookie Policy</a>.
          </p>
        </div>

        {showDetails && (
          <div className="cookie-consent-details">
            <h4 className="cookie-details-title">Cookie Settings</h4>
            
            {cookieTypes.map(cookie => (
              <div key={cookie.id} className="cookie-type">
                <div className="cookie-type-header">
                  <div className="cookie-type-info">
                    <h5 className="cookie-type-name">{cookie.name}</h5>
                    <span className={`cookie-type-status ${cookie.required ? 'required' : preferences[cookie.id] ? 'enabled' : 'disabled'}`}>
                      {cookie.required ? 'Always active' : preferences[cookie.id] ? 'Enabled' : 'Disabled'}
                    </span>
                  </div>
                  {!cookie.required && (
                    <label className="cookie-toggle">
                      <input
                        type="checkbox"
                        checked={preferences[cookie.id]}
                        onChange={() => handleToggleCookie(cookie.id)}
                        aria-label={`Toggle ${cookie.name}`}
                      />
                      <span className="cookie-toggle-slider"></span>
                    </label>
                  )}
                </div>
                <p className="cookie-type-description">{cookie.description}</p>
              </div>
            ))}
          </div>
        )}

        <div className="cookie-consent-actions">
          <div className="cookie-action-buttons">
            <button 
              className="cookie-button cookie-button-secondary"
              onClick={handleShowDetails}
            >
              {showDetails ? 'Hide Details' : 'Customize Settings'}
            </button>
            
            <div className="cookie-primary-actions">
              <button 
                className="cookie-button cookie-button-reject"
                onClick={handleRejectAll}
              >
                Reject All
              </button>
              <button 
                className="cookie-button cookie-button-accept-selected"
                onClick={handleAcceptSelected}
                disabled={!preferences.analytics && !preferences.marketing && !preferences.preferences}
              >
                Accept Selected
              </button>
              <button 
                className="cookie-button cookie-button-accept-all"
                onClick={handleAcceptAll}
              >
                Accept All
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default CookieConsent;