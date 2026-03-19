# Accessibility Implementation

A comprehensive accessibility package for React applications that provides screen reader optimization, full keyboard navigation, cognitive accessibility features, and WCAG 2.1 AA compliance.

## Features

### 1. Screen Reader Optimization
- **ARIA Live Regions** for dynamic content announcements
- **Proper heading hierarchy** (h1-h6 semantic structure)
- **Image alt text generation** for AI-created visuals
- **Form field error announcements** with ARIA attributes
- **Page navigation announcements**

### 2. Full Keyboard Navigation
- **Complete tab navigation** throughout application
- **Visual focus indicators** for all interactive elements
- **Escape key** to close all modals/dialogs
- **Arrow key navigation** for lists, selects, carousels
- **Keyboard shortcuts** for power users (documented)
- **Focus trapping** for modals

### 3. Cognitive Accessibility Features
- **High contrast mode** toggle
- **Text scaling support** (up to 200% without breaking)
- **Simplified UI mode** option
- **Dyslexia-friendly font** option
- **Reduced motion preferences** respected
- **Accessibility menu** (floating button or in settings)

### 4. Complex Component Accessibility
- **Data tables** with proper ARIA roles
- **Charts and graphs** with text alternatives
- **Modal dialogs** with focus trapping
- **Drag-and-drop** with keyboard alternatives
- **Progress indicators** with ARIA labels

## Installation

```bash
npm install accessibility-implementation
```

## Quick Start

```jsx
import React from 'react';
import ReactDOM from 'react-dom/client';
import { 
  initializeAccessibility, 
  AccessibilityMenu,
  useKeyboardNavigation 
} from 'accessibility-implementation';
import 'accessibility-implementation/dist/styles/accessibility.css';

// Initialize accessibility features
initializeAccessibility();

function App() {
  // Use keyboard navigation hook
  const { showKeyboardShortcuts } = useKeyboardNavigation();

  return (
    <div>
      {/* Skip to content link is automatically added */}
      
      <header role="banner">
        <h1>My Accessible App</h1>
      </header>
      
      <main id="main-content" role="main">
        <button onClick={showKeyboardShortcuts}>
          Show Keyboard Shortcuts (?)
        </button>
        
        {/* Your app content */}
      </main>
      
      {/* Accessibility menu (floating button) */}
      <AccessibilityMenu />
    </div>
  );
}

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(<App />);
```

## Usage

### Screen Reader Announcements

```jsx
import { announce, announcePRDProgress, announceSuccess } from 'accessibility-implementation';

// Announce general messages
announce('Form submitted successfully', 'polite');

// Announce PRD generation progress
announcePRDProgress(2, 5, 'Generating requirements section...');

// Announce success/error
announceSuccess('Document saved successfully');
announceError('Failed to save document');
```

### Keyboard Navigation

```jsx
import { useKeyboardNavigation } from 'accessibility-implementation';

function MyComponent() {
  const { setupFocusTrap } = useKeyboardNavigation({
    enableShortcuts: true,
    enableFocusTraps: true,
    enableArrowNavigation: true,
    shortcuts: [
      {
        key: 'p',
        ctrlKey: true,
        description: 'Print document',
        action: () => window.print()
      }
    ]
  });

  const modalRef = useRef(null);

  useEffect(() => {
    if (modalRef.current) {
      const cleanup = setupFocusTrap(modalRef.current);
      return cleanup;
    }
  }, []);

  return (
    <div ref={modalRef} role="dialog">
      {/* Modal content */}
    </div>
  );
}
```

### Form Accessibility

```jsx
import { 
  setupFormField, 
  showFormFieldError, 
  validateForm 
} from 'accessibility-implementation';

function MyForm() {
  useEffect(() => {
    // Setup form fields for accessibility
    setupFormField('email', 'Email address', true);
    setupFormField('password', 'Password', true);
  }, []);

  const handleSubmit = (e) => {
    e.preventDefault();
    
    if (validateForm('my-form')) {
      // Form is valid
    } else {
      // Show specific field errors
      showFormFieldError('email', 'Email is required');
    }
  };

  return (
    <form id="my-form" onSubmit={handleSubmit}>
      <input id="email" type="email" />
      <input id="password" type="password" />
      <button type="submit">Submit</button>
    </form>
  );
}
```

### Accessibility Preferences

```jsx
import { 
  AccessibilityMenu,
  getAccessibilityPreferences,
  saveAccessibilityPreferences 
} from 'accessibility-implementation';

function SettingsPage() {
  const [preferences, setPreferences] = useState(getAccessibilityPreferences());

  const handlePreferenceChange = (newPreferences) => {
    saveAccessibilityPreferences(newPreferences);
    setPreferences(newPreferences);
  };

  return (
    <div>
      <h2>Accessibility Settings</h2>
      
      {/* Use the settings panel version */}
      <AccessibilityMenu 
        showInSettings={true}
        onPreferencesChange={handlePreferenceChange}
      />
    </div>
  );
}
```

## Components

### AccessibilityMenu

A floating button or settings panel for accessibility controls.

```jsx
import { AccessibilityMenu } from 'accessibility-implementation';

// Floating button (default)
<AccessibilityMenu 
  position="bottom-right" // or 'top-right', 'top-left', 'bottom-left'
  showFloatingButton={true}
/>

// Settings panel version
<AccessibilityMenu showInSettings={true} />
```

### Keyboard Shortcuts

Press `?` to show available keyboard shortcuts:

| Shortcut | Description |
|----------|-------------|
| `?` | Show keyboard shortcuts |
| `Ctrl/Cmd + N` | Create new PRD |
| `Ctrl/Cmd + S` | Save PRD |
| `Ctrl/Cmd + E` | Export PRD |
| `Esc` | Close modal/back |
| `Tab` | Navigate forward |
| `Shift + Tab` | Navigate backward |
| `Arrow Keys` | Navigate lists/carousels |
| `Enter` | Activate selected item |
| `Space` | Toggle selection |

## Advanced Usage

### Custom ARIA Live Regions

```jsx
import { liveRegion } from 'accessibility-implementation';

// Custom announcements
liveRegion.announce('Custom announcement', 'assertive');

// Progress updates
liveRegion.announcePRDProgress(3, 10);

// Credit usage
liveRegion.announceCreditUsage(5, 95);
```

### Image Alt Text Generation

```jsx
import { generateAltText } from 'accessibility-implementation';

const altText = generateAltText(
  'chart',
  'monthly revenue growth from January to December',
  'Revenue increased by 15% compared to last year'
);
// Returns: "A chart showing monthly revenue growth from January to December. Revenue increased by 15% compared to last year."
```

### Focus Management

```jsx
import { trapFocus, restoreFocus, focusWithIndicator } from 'accessibility-implementation';

// Trap focus in modal
const cleanup = trapFocus(modalElement);

// Restore focus when modal closes
restoreFocus(previousElement);

// Focus with visual indicator
focusWithIndicator(buttonElement);
```

## CSS Customization

The package includes CSS that can be customized with CSS variables:

```css
:root {
  --text-scale: 1;
  --high-contrast-text: #000000;
  --high-contrast-bg: #ffffff;
  --high-contrast-accent: #0066cc;
  --high-contrast-border: #000000;
}
```

## WCAG 2.1 AA Compliance

This package helps achieve WCAG 2.1 AA compliance by addressing:

- **1.1.1 Non-text Content** (Image alt text generation)
- **1.3.1 Info and Relationships** (Proper heading hierarchy, ARIA roles)
- **1.4.3 Contrast (Minimum)** (High contrast mode)
- **1.4.4 Resize Text** (Text scaling up to 200%)
- **1.4.10 Reflow** (Responsive design support)
- **2.1.1 Keyboard** (Full keyboard navigation)
- **2.1.2 No Keyboard Trap** (Focus trapping)
- **2.4.3 Focus Order** (Logical tab order)
- **2.4.7 Focus Visible** (Visual focus indicators)
- **3.3.1 Error Identification** (Form error announcements)
- **4.1.2 Name, Role, Value** (ARIA attributes)

## Browser Support

- Chrome 60+
- Firefox 55+
- Safari 12+
- Edge 79+
- iOS Safari 12+
- Chrome for Android 60+

## License

MIT

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `npm test`
5. Submit a pull request

## Support

For issues and questions, please file an issue on GitHub.