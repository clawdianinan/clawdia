# Cookie Consent Implementation Guide

**Last Updated:** 2026-03-18  
**Effective Date:** 2026-03-18

## Overview

This document provides implementation guidelines for the GDPR-compliant cookie consent system for PRDForge. The system ensures compliance with the General Data Protection Regulation (GDPR), ePrivacy Directive (Cookie Law), and other applicable privacy regulations.

## 1. Cookie Consent Component

### 1.1 Component Location
```
src/components/compliance/
├── CookieConsent.tsx    # React component with TypeScript
└── CookieConsent.css    # Styling for the component
```

### 1.2 Component Features
- **GDPR Compliance:** Fully compliant with GDPR and ePrivacy Directive requirements
- **Granular Consent:** Four cookie categories with individual toggles
- **Persistent Storage:** User preferences stored in localStorage
- **Responsive Design:** Works on all device sizes
- **Accessibility:** WCAG 2.1 AA compliant
- **Dark Mode Support:** Automatic theme detection

### 1.3 Cookie Categories
| Category | Description | Default | Required |
|----------|-------------|---------|----------|
| **Necessary** | Essential for website functionality | Enabled | Yes |
| **Analytics** | Helps understand how visitors interact | Disabled | No |
| **Marketing** | Used for personalized advertising | Disabled | No |
| **Preferences** | Remembers user settings and preferences | Disabled | No |

## 2. Implementation Steps

### 2.1 Installation

#### 2.1.1 Copy Component Files
```bash
# Copy component files to your project
cp src/components/compliance/CookieConsent.tsx /path/to/your/project/src/components/
cp src/components/compliance/CookieConsent.css /path/to/your/project/src/components/
```

#### 2.1.2 Install Dependencies
Ensure your project has the required dependencies:
```json
{
  "dependencies": {
    "react": "^18.0.0",
    "react-dom": "^18.0.0",
    "typescript": "^5.0.0"
  }
}
```

### 2.2 Integration

#### 2.2.1 Import Component
```typescript
// In your main App.tsx or equivalent
import CookieConsent from './components/compliance/CookieConsent';
```

#### 2.2.2 Add to Application
```tsx
// Add the component to your application layout
function App() {
  return (
    <div className="App">
      {/* Your application content */}
      <CookieConsent />
    </div>
  );
}
```

#### 2.2.3 Configuration Options
The component accepts the following props:

```tsx
interface CookieConsentProps {
  /**
   * Company name for display in banner
   * @default "PRDForge"
   */
  companyName?: string;
  
  /**
   * Privacy policy URL
   * @default "/privacy-policy"
   */
  privacyPolicyUrl?: string;
  
  /**
   * Cookie policy URL
   * @default "/cookie-policy"
   */
  cookiePolicyUrl?: string;
  
  /**
   * Language for banner text
   * @default "en"
   */
  language?: 'en' | 'es' | 'fr' | 'de' | 'it';
  
  /**
   * Position of the banner
   * @default "bottom"
   */
  position?: 'bottom' | 'top';
  
  /**
   * Show banner on every page load until consent is given
   * @default true
   */
  showUntilConsent?: boolean;
  
  /**
   * Days until the banner reappears after consent
   * @default 365
   */
  expirationDays?: number;
  
  /**
   * Callback when consent preferences change
   */
  onConsentChange?: (preferences: CookiePreferences) => void;
}
```

### 2.3 Cookie Management

#### 2.3.1 Setting Cookies Based on Consent
```typescript
// Example: Setting analytics cookies only when consent is given
import { getCookiePreferences } from './utils/cookieUtils';

function setAnalyticsCookies() {
  const preferences = getCookiePreferences();
  
  if (preferences.analytics) {
    // Initialize Google Analytics, Mixpanel, etc.
    window.gtag('config', 'GA_MEASUREMENT_ID');
  }
}

// Example: Setting preference cookies
function setUserPreferences() {
  const preferences = getCookiePreferences();
  
  if (preferences.preferences) {
    // Store user preferences in cookies
    document.cookie = `theme=dark; max-age=31536000; path=/`;
    document.cookie = `language=en; max-age=31536000; path=/`;
  }
}
```

#### 2.3.2 Checking Consent Status
```typescript
// Utility function to check if specific cookie category is allowed
export function isCookieCategoryAllowed(category: CookieCategory): boolean {
  const preferences = JSON.parse(localStorage.getItem('cookiePreferences') || '{}');
  
  switch (category) {
    case 'necessary':
      return true; // Always allowed
    case 'analytics':
      return preferences.analytics === true;
    case 'marketing':
      return preferences.marketing === true;
    case 'preferences':
      return preferences.preferences === true;
    default:
      return false;
  }
}

// Usage
if (isCookieCategoryAllowed('analytics')) {
  // Load analytics scripts
}
```

## 3. Cookie Policy

### 3.1 Required Cookie Policy Page
Create a `/cookie-policy` page that includes:

#### 3.1.1 Cookie Declaration
```html
<table class="cookie-table">
  <thead>
    <tr>
      <th>Cookie Name</th>
      <th>Provider</th>
      <th>Purpose</th>
      <th>Expiry</th>
      <th>Type</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>session_id</td>
      <td>PRDForge</td>
      <td>Maintain user session</td>
      <td>Session</td>
      <td>Necessary</td>
    </tr>
    <tr>
      <td>_ga</td>
      <td>Google Analytics</td>
      <td>Distinguish users</td>
      <td>2 years</td>
      <td>Analytics</td>
    </tr>
    <!-- Add all cookies used by your application -->
  </tbody>
</table>
```

#### 3.1.2 How to Manage Cookies
Include instructions for users to manage cookies through:
- Browser settings
- Our cookie consent banner
- Third-party opt-out tools

### 3.2 Cookie Storage Implementation
```typescript
// Cookie storage utility
export class CookieManager {
  private static readonly PREFERENCES_KEY = 'cookiePreferences';
  private static readonly CONSENT_DATE_KEY = 'cookieConsentDate';
  
  /**
   * Save user cookie preferences
   */
  static savePreferences(preferences: CookiePreferences): void {
    localStorage.setItem(this.PREFERENCES_KEY, JSON.stringify(preferences));
    localStorage.setItem(this.CONSENT_DATE_KEY, new Date().toISOString());
    
    // Apply preferences immediately
    this.applyPreferences(preferences);
  }
  
  /**
   * Get current cookie preferences
   */
  static getPreferences(): CookiePreferences {
    const stored = localStorage.getItem(this.PREFERENCES_KEY);
    
    if (stored) {
      return JSON.parse(stored);
    }
    
    // Default preferences (only necessary cookies)
    return {
      necessary: true,
      analytics: false,
      marketing: false,
      preferences: false
    };
  }
  
  /**
   * Apply preferences to current cookie state
   */
  private static applyPreferences(preferences: CookiePreferences): void {
    // Remove cookies for categories that are not allowed
    if (!preferences.analytics) {
      this.removeAnalyticsCookies();
    }
    
    if (!preferences.marketing) {
      this.removeMarketingCookies();
    }
    
    if (!preferences.preferences) {
      this.removePreferenceCookies();
    }
  }
  
  /**
   * Check if consent is expired
   */
  static isConsentExpired(expirationDays: number = 365): boolean {
    const consentDate = localStorage.getItem(this.CONSENT_DATE_KEY);
    
    if (!consentDate) {
      return true; // No consent given yet
    }
    
    const consentTime = new Date(consentDate).getTime();
    const currentTime = new Date().getTime();
    const daysSinceConsent = (currentTime - consentTime) / (1000 * 60 * 60 * 24);
    
    return daysSinceConsent > expirationDays;
  }
}
```

## 4. Integration with Analytics Tools

### 4.1 Google Analytics
```typescript
// Conditional Google Analytics loading
export function loadGoogleAnalytics(measurementId: string): void {
  if (!isCookieCategoryAllowed('analytics')) {
    return;
  }
  
  // Load gtag.js script
  const script = document.createElement('script');
  script.src = `https://www.googletagmanager.com/gtag/js?id=${measurementId}`;
  script.async = true;
  document.head.appendChild(script);
  
  // Initialize gtag
  window.dataLayer = window.dataLayer || [];
  function gtag(...args: any[]) {
    window.dataLayer.push(args);
  }
  gtag('js', new Date());
  gtag('config', measurementId);
  
  // Set consent state
  gtag('consent', 'default', {
    'ad_storage': isCookieCategoryAllowed('marketing') ? 'granted' : 'denied',
    'analytics_storage': isCookieCategoryAllowed('analytics') ? 'granted' : 'denied',
    'personalization_storage': isCookieCategoryAllowed('preferences') ? 'granted' : 'denied',
    'functionality_storage': isCookieCategoryAllowed('preferences') ? 'granted' : 'denied',
    'security_storage': 'granted' // Always granted for necessary cookies
  });
}
```

### 4.2 Other Analytics Tools
Similar patterns should be implemented for:
- Mixpanel
- Amplitude
- Hotjar
- Facebook Pixel
- LinkedIn Insight Tag
- Any other tracking tools

## 5. Testing and Validation

### 5.1 Test Cases

#### 5.1.1 Initial Visit
- [ ] Banner appears on first visit
- [ ] Default settings show only necessary cookies enabled
- [ ] User can toggle individual categories
- [ ] "Accept All" enables all categories
- [ ] "Reject All" enables only necessary cookies
- [ ] "Accept Selected" saves chosen preferences

#### 5.1.2 Subsequent Visits
- [ ] Banner does not appear if consent was given
- [ ] Preferences are remembered
- [ ] User can update preferences via "Manage Cookies" button
- [ ] Consent expiration works correctly

#### 5.1.3 Cookie Behavior
- [ ] Analytics cookies only set when category is enabled
- [ ] Marketing cookies only set when category is enabled
- [ ] Preference cookies only set when category is enabled
- [ ] Necessary cookies always set

### 5.2 Compliance Testing
- [ ] Test with GDPR compliance checkers
- [ ] Verify with cookie consent auditing tools
- [ ] Check accessibility (keyboard navigation, screen readers)
- [ ] Test on different browsers and devices
- [ ] Validate with legal counsel

## 6. Legal Requirements

### 6.1 GDPR Compliance Checklist
- [ ] **Prior Consent:** No non-essential cookies before consent
- [ ] **Granular Control:** Separate consent for different cookie categories
- [ ] **Freely Given:** No coercion or bundling of consent
- [ ] **Informed Consent:** Clear information about cookie purposes
- [ ] **Easy Withdrawal:** Simple way to change or withdraw consent
- [ ] **Documentation:** Record of consent obtained
- [ ] **Regular Review:** Periodic review of cookie usage

### 6.2 Required Documentation
1. **Cookie Policy:** Detailed list of all cookies used
2. **Privacy Policy:** Includes cookie information section
3. **Data Processing Records:** Documentation of consent mechanisms
4. **DPA with Processors:** Agreements with analytics providers

### 6.3 International Considerations
- **EU:** GDPR and ePrivacy Directive
- **UK:** UK GDPR and PECR
- **California:** CCPA/CPRA (opt-out for sale of data)
- **Canada:** PIPEDA
- **Brazil:** LGPD
- **Other jurisdictions:** Check local cookie laws

## 7. Maintenance and Updates

### 7.1 Regular Audits
- Quarterly review of cookie usage
- Update cookie policy when new cookies are added
- Test consent mechanism functionality
- Review compliance with new regulations

### 7.2 Adding New Cookies
When adding new cookies to your application:

1. **Categorize:** Determine which category the cookie belongs to
2. **Document:** Add to cookie policy page
3. **Implement:** Update cookie consent logic
4. **Test:** Verify consent controls work correctly
5. **Notify:** Update users if significant changes

### 7.3 User Communication
- Notify users of significant changes to cookie usage
- Provide clear instructions for managing cookies
- Respond to user inquiries about cookie usage
- Maintain transparency about data practices

## 8. Troubleshooting

### 8.1 Common Issues

#### Issue: Banner doesn't appear
**Solution:** Check localStorage for existing consent. Clear browser data for testing.

#### Issue: Preferences not saved
**Solution:** Verify localStorage is available and not blocked. Check for JavaScript errors.

#### Issue: Cookies still set after rejection
**Solution:** Ensure all third-party scripts respect consent. Implement proper conditional loading.

#### Issue: Banner appears on every page load
**Solution:** Check consent expiration logic. Verify preferences are being saved correctly.

### 8.2 Debugging Tools
```javascript
// Debug function to check cookie consent state
function debugCookieConsent() {
  console.log('Cookie Preferences:', CookieManager.getPreferences());
  console.log('Consent Date:', localStorage.getItem('cookieConsentDate'));
  console.log('All Cookies:', document.cookie);
  
  // Check specific cookie categories
  console.log('Analytics Allowed:', isCookieCategoryAllowed('analytics'));
  console.log('Marketing Allowed:', isCookieCategoryAllowed('marketing'));
  console.log('Preferences Allowed:', isCookieCategoryAllowed('preferences'));
}
```

## 9. Resources

### 9.1 Documentation
- [GDPR Official Text](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX:32016R0679)
- [ePrivacy Directive](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX:32002L0058)
- [ICO Cookie Guidance](https://ico.org.uk/for-organisations/guide-to-pecr/cookies-and-similar-technologies/)
- [CNIL Cookie Guidelines](https://www.cnil.fr/en/cookies-tracements-que-dit-la-loi)

### 9.2 Testing Tools
- [Cookiebot Scanner](https://www.cookiebot.com/en/cookie-scanner/)
- [OneTrust Cookie Consent Testing](https://www.onetrust.com/products/cookie-consent/)
- [IAB Europe Transparency & Consent Framework](https://iabeurope.eu/transparency-consent-framework/)

### 9.3 Legal Templates
- Cookie Policy Template
- Privacy Policy Template
- Data Processing Agreement Template
- Record of Processing Activities Template

## 10. Support

For technical support with cookie consent implementation:
- **Email:** support@prdforge.com
- **Documentation:** https://docs.prdforge.com/compliance/cookies
- **GitHub Issues:** https://github.com/prdforge/prdforge/issues

For legal questions about cookie compliance:
- **Legal Email:** legal@prdforge.com
- **DPO Contact:** dpo@prdforge.com

---
*This implementation guide is provided as a template and should be reviewed by legal counsel before deployment. Compliance requirements may vary by jurisdiction and specific use case.*