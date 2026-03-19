# PRDForge Intro Tour - Integration Guide

## Overview
This guide explains how to integrate the Intro Tour into your PRDForge React application. The tour is designed to be triggered after user signup and provides a guided walkthrough of key features.

## Quick Start

### 1. Install Dependencies
```bash
npm install react-joyride
```

### 2. Copy Tour Files
Copy the following files to your project:
- `src/components/onboarding/Tour.tsx`
- `src/components/onboarding/TourProvider.tsx`
- `src/data/tourSteps.ts`
- `src/styles/tour.css`

### 3. Update Your App Structure
Wrap your main app component with `TourProvider`:

```tsx
// App.tsx or main entry file
import React from 'react';
import { TourProvider } from './src/components/onboarding/TourProvider';
import Tour from './src/components/onboarding/Tour';
import './src/styles/tour.css';

function App() {
  return (
    <TourProvider
      autoStart={false} // Set based on your logic
      onTourStart={() => console.log('Tour started')}
      onTourComplete={() => console.log('Tour completed')}
      onTourSkip={() => console.log('Tour skipped')}
    >
      {/* Your app components */}
      <YourAppContent />
      
      {/* Tour component - will auto-show when triggered */}
      <Tour />
    </TourProvider>
  );
}
```

### 4. Add Data Attributes to Target Elements
Add `data-tour` attributes to elements you want to highlight:

```tsx
// Example dashboard elements
<div data-tour="dashboard">
  <h1>Welcome to PRDForge</h1>
</div>

<button data-tour="create-prd-button">
  Create PRD
</button>

<div data-tour="credit-counter">
  Credits: 10
</div>

<div data-tour="templates">
  {/* Templates section */}
</div>

<button data-tour="upgrade-cta">
  Upgrade
</button>
```

### 5. Trigger Tour After Signup
Trigger the tour after successful user signup:

```tsx
import { useTour } from './src/components/onboarding/TourProvider';

function SignupComplete() {
  const { startTour } = useTour();
  
  const handleSignupSuccess = () => {
    // After successful signup
    setTimeout(() => {
      startTour();
    }, 1000); // Small delay for better UX
  };
  
  return (
    <button onClick={handleSignupSuccess}>
      Sign Up
    </button>
  );
}
```

## Configuration Options

### TourProvider Props
| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `autoStart` | boolean | `false` | Auto-start tour on page load |
| `onTourStart` | function | `undefined` | Called when tour starts |
| `onTourComplete` | function | `undefined` | Called when tour completes |
| `onTourSkip` | function | `undefined` | Called when tour is skipped |

### Tour Component Props
| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `continuous` | boolean | `true` | Show next button on all steps |
| `showProgress` | boolean | `true` | Show progress indicator |
| `showSkipButton` | boolean | `true` | Show skip button |
| `disableCloseOnEsc` | boolean | `false` | Disable closing with ESC key |
| `disableOverlayClose` | boolean | `false` | Disable closing by clicking overlay |
| `hideBackButton` | boolean | `false` | Hide back button |

## Customizing Tour Steps

### Modify Step Definitions
Edit `src/data/tourSteps.ts` to customize:

```typescript
export const tourSteps: TourStep[] = [
  {
    target: '[data-tour="your-element"]',
    title: 'Your Title',
    content: 'Your content here',
    placement: 'right', // 'top', 'bottom', 'left', 'right', 'center'
    action: () => {
      // Optional action when step is shown
    }
  },
  // Add more steps as needed
];
```

### Available Step Properties
- `target`: CSS selector for the element to highlight
- `title`: Step title (supports emoji)
- `content`: Step description/content
- `placement`: Tooltip position relative to target
- `action`: Optional function to execute when step is shown
- `disableBeacon`: Hide beacon indicator
- `spotlightPadding`: Padding around highlighted element

## Analytics Integration

### Built-in Analytics Events
The tour automatically tracks these events (if `gtag` is available):

1. `tour_started` - When tour begins
2. `tour_step_completed` - When each step is completed
3. `tour_skipped` - When tour is skipped
4. `tour_completed` - When tour finishes
5. `tour_restarted` - When tour is restarted

### Custom Analytics
Add your own analytics in the callback functions:

```tsx
<TourProvider
  onTourStart={() => {
    // Your analytics code
    mixpanel.track('Tour Started');
  }}
  onTourComplete={() => {
    // Your analytics code
    mixpanel.track('Tour Completed');
  }}
/>
```

## Styling Customization

### CSS Variables
Override CSS variables in your main stylesheet:

```css
:root {
  --tour-primary-color: #4f46e5;
  --tour-secondary-color: #7c3aed;
  --tour-overlay-opacity: 0.8;
  --tour-tooltip-width: 400px;
}
```

### Custom Styles
Modify `src/styles/tour.css` for:
- Colors and gradients
- Typography
- Spacing and sizing
- Animations and transitions
- Mobile responsiveness

## Mobile Optimization

The tour is mobile-responsive by default. For custom mobile adjustments:

```css
/* Mobile-specific overrides */
@media (max-width: 768px) {
  .custom-tour-tooltip {
    max-width: 90vw;
    margin: 0 16px;
  }
  
  .tour-button-group {
    flex-direction: column;
  }
}
```

## Accessibility Features

### Built-in Accessibility
- Keyboard navigation (Tab, Enter, Escape)
- Screen reader support
- High contrast mode support
- Reduced motion preferences
- Focus management

### ARIA Labels
All interactive elements include appropriate ARIA labels:
- `aria-label` on buttons
- `aria-describedby` for tooltip content
- `aria-live` for dynamic updates

## Testing

### Manual Testing Checklist
1. [ ] Tour starts correctly after signup
2. [ ] All steps display properly
3. [ ] Navigation works (Next, Back, Skip)
4. [ ] Mobile responsiveness
5. [ ] Keyboard navigation
6. [ ] Screen reader compatibility
7. [ ] Progress saving in LocalStorage
8. [ ] Analytics events fire correctly

### Automated Testing
Example test using React Testing Library:

```typescript
import { render, screen, fireEvent } from '@testing-library/react';
import { TourProvider } from './TourProvider';
import Tour from './Tour';

test('tour starts when triggered', () => {
  render(
    <TourProvider>
      <Tour />
      <button data-testid="start-tour">Start Tour</button>
    </TourProvider>
  );
  
  fireEvent.click(screen.getByTestId('start-tour'));
  expect(screen.getByText('Welcome to PRDForge!')).toBeInTheDocument();
});
```

## Performance Considerations

### Bundle Size
- `react-joyride`: ~15KB gzipped
- Tour components: ~5KB gzipped
- CSS: ~3KB gzipped

### Optimization Tips
1. **Lazy Loading**: Load tour components only when needed
2. **Code Splitting**: Split tour into separate chunk
3. **Tree Shaking**: Ensure unused code is removed
4. **CSS Purge**: Remove unused CSS in production

### Lazy Loading Example
```tsx
import React, { lazy, Suspense } from 'react';

const Tour = lazy(() => import('./src/components/onboarding/Tour'));

function App() {
  return (
    <TourProvider>
      <Suspense fallback={<div>Loading...</div>}>
        <Tour />
      </Suspense>
    </TourProvider>
  );
}
```

## Troubleshooting

### Common Issues

#### 1. Tour targets not found
**Solution**: Ensure elements with `data-tour` attributes exist in DOM when tour starts.

#### 2. Tour doesn't start
**Solution**: Check that `startTour()` is called after elements are rendered.

#### 3. Mobile layout issues
**Solution**: Test on real devices and adjust CSS breakpoints.

#### 4. Analytics not working
**Solution**: Ensure `gtag` is loaded before tour starts.

#### 5. Performance issues
**Solution**: Implement lazy loading and code splitting.

### Debug Mode
Enable console logging for debugging:

```typescript
// In tourSteps.ts
console.log('Tour step shown:', stepIndex);
console.log('Target element:', document.querySelector(target));
```

## Support

For issues or questions:
1. Check the [GitHub repository](https://github.com/prdforge/intro-tour)
2. Review this integration guide
3. Test with the provided example app
4. Contact the development team

## Changelog

### v1.0.0
- Initial release
- Complete tour implementation
- Mobile responsive design
- Accessibility compliance
- Analytics integration
- LocalStorage support
- Comprehensive documentation