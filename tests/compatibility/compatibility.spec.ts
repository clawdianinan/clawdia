/**
 * Cross-Browser Compatibility Testing
 * 
 * Test all improvements across browsers:
 * - Chrome, Firefox, Safari, Edge
 * - Mobile responsiveness of new features
 * - Accessibility compliance across platforms
 * - Touch vs mouse interaction support
 */

import { describe, it, expect, beforeAll, afterAll, vi } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

// Browser detection utilities
import { BrowserDetector } from '@/utils/compatibility/browser';
import { TouchSimulator } from '@/utils/compatibility/touch';
import { AccessibilityChecker } from '@/utils/compatibility/accessibility';

// Components to test
import { MotionProvider } from '@/components/motion/MotionProvider';
import AccessibilityInfo from '@/components/ui/AccessibilityInfo';
import Tour from '@/components/onboarding/Tour';
import { DragDropManager } from '@/utils/dragDropAnimations';
import { SwipeActions } from '@/components/interactions/SwipeActions';
import { ProgressiveLoader } from '@/components/loading/ProgressiveLoader';
import { ValidationFeedback } from '@/components/forms/ValidationFeedback';

describe('Cross-Browser Compatibility Test Suite', () => {
  let browserDetector: BrowserDetector;
  let touchSimulator: TouchSimulator;
  let accessibilityChecker: AccessibilityChecker;

  beforeAll(() => {
    browserDetector = new BrowserDetector();
    touchSimulator = new TouchSimulator();
    accessibilityChecker = new AccessibilityChecker();
  });

  describe('1. Browser-Specific Compatibility', () => {
    const browsers = [
      { name: 'Chrome', version: '120', userAgent: 'Chrome/120.0.0.0' },
      { name: 'Firefox', version: '115', userAgent: 'Firefox/115.0' },
      { name: 'Safari', version: '17', userAgent: 'Version/17.0 Safari/605.1.15' },
      { name: 'Edge', version: '120', userAgent: 'Edg/120.0.0.0' },
      { name: 'Mobile Safari', version: '17', userAgent: 'iPhone; CPU iPhone OS 17_0 like Mac OS X' },
      { name: 'Chrome Android', version: '120', userAgent: 'Android 13; Chrome/120.0.0.0' }
    ];

    browsers.forEach(browser => {
      describe(`${browser.name} ${browser.version}`, () => {
        beforeAll(() => {
          // Mock user agent for this browser
          Object.defineProperty(navigator, 'userAgent', {
            value: `Mozilla/5.0 (compatible; ${browser.userAgent})`,
            configurable: true
          });
        });

        it(`should render accessibility components correctly in ${browser.name}`, () => {
          render(
            <AccessibilityInfo
              elementId={`${browser.name.toLowerCase()}-test`}
              docSection="compatibility/browsers"
              tooltipText={`Testing in ${browser.name} ${browser.version}`}
            />
          );
          
          const button = screen.getByRole('button');
          
          // Basic rendering check
          expect(button).toBeInTheDocument();
          expect(button).toBeVisible();
          
          // Browser-specific style checks
          if (browser.name.includes('Safari')) {
            // Safari specific checks
            expect(button).toHaveStyle('-webkit-appearance: none');
          }
          
          if (browser.name.includes('Firefox')) {
            // Firefox specific checks
            expect(button).toHaveStyle('moz-appearance: none');
          }
        });

        it(`should support motion animations in ${browser.name}`, () => {
          render(
            <MotionProvider>
              <div 
                className="motion-fade-in"
                data-testid="motion-element"
              >
                Motion Test
              </div>
            </MotionProvider>
          );
          
          const element = screen.getByTestId('motion-element');
          
          // Check animation properties
          expect(element).toHaveStyle('opacity: 0');
          
          // Browser-specific animation support
          if (browser.name.includes('Safari') || browser.name.includes('iOS')) {
            expect(element).toHaveStyle('-webkit-animation-name: fadeIn');
          } else {
            expect(element).toHaveStyle('animation-name: fadeIn');
          }
        });

        it(`should handle drag-drop interactions in ${browser.name}`, async () => {
          // Skip drag-drop test for mobile browsers (touch-based)
          if (browser.name.includes('Mobile') || browser.name.includes('Android')) {
            return;
          }
          
          render(
            <MotionProvider>
              <div className="draggable-item" data-testid="draggable">
                Drag Me
              </div>
              <div className="drop-zone" data-testid="dropzone">
                Drop Here
              </div>
            </MotionProvider>
          );
          
          const draggable = screen.getByTestId('draggable');
          const dropzone = screen.getByTestId('dropzone');
          
          // Initialize drag-drop
          const dragDrop = new DragDropManager({
            dragItemSelector: '.draggable-item',
            dropZoneSelector: '.drop-zone',
            onDrop: vi.fn()
          });
          
          // Test drag operation
          fireEvent.mouseDown(draggable);
          fireEvent.mouseMove(draggable, { clientX: 100, clientY: 100 });
          
          // Browser-specific drag feedback
          if (browser.name.includes('Chrome') || browser.name.includes('Edge')) {
            expect(draggable).toHaveStyle('cursor: grabbing');
          }
          
          fireEvent.mouseUp(dropzone);
          
          await waitFor(() => {
            expect(draggable).toHaveClass('motion-drop-success');
          });
        });

        it(`should support touch interactions in ${browser.name}`, async () => {
          // Only test touch for mobile browsers
          if (!browser.name.includes('Mobile') && !browser.name.includes('Android')) {
            return;
          }
          
          render(
            <MotionProvider>
              <SwipeActions
                leftActions={[
                  {
                    id: 'mobile-action',
                    label: 'Action',
                    color: 'white',
                    backgroundColor: '#3b82f6',
                    onAction: vi.fn()
                  }
                ]}
                hapticFeedback={true}
              >
                <div 
                  data-testid="touch-target"
                  style={{ width: '300px', height: '80px' }}
                >
                  Swipe Me
                </div>
              </SwipeActions>
            </MotionProvider>
          );
          
          const target = screen.getByTestId('touch-target');
          
          // Simulate touch swipe
          touchSimulator.touchStart(target, 300, 50);
          touchSimulator.touchMove(target, 200, 50);
          touchSimulator.touchEnd(target);
          
          await waitFor(() => {
            expect(screen.getByText('Action')).toBeInTheDocument();
          });
          
          // Mobile-specific checks
          if (browser.name.includes('iOS')) {
            // Check for iOS-specific haptic feedback
            expect(global.window?.webkit?.messageHandlers?.haptic).toBeDefined();
          }
        });
      });
    });
  });

  describe('2. Mobile Responsiveness', () => {
    const viewports = [
      { name: 'Mobile Small', width: 320, height: 568 }, // iPhone SE
      { name: 'Mobile Medium', width: 375, height: 667 }, // iPhone 8
      { name: 'Mobile Large', width: 414, height: 896 }, // iPhone 11 Pro Max
      { name: 'Tablet', width: 768, height: 1024 }, // iPad
      { name: 'Desktop', width: 1440, height: 900 } // Desktop
    ];

    viewports.forEach(viewport => {
      describe(`${viewport.name} (${viewport.width}x${viewport.height})`, () => {
        beforeAll(() => {
          // Set viewport size
          window.innerWidth = viewport.width;
          window.innerHeight = viewport.height;
          window.dispatchEvent(new Event('resize'));
        });

        it(`should render accessibility info button responsively`, () => {
          render(
            <AccessibilityInfo
              elementId={`viewport-${viewport.name}`}
              docSection="responsive/design"
              tooltipText="Responsive design test"
            />
          );
          
          const button = screen.getByRole('button');
          
          // Check responsive sizing
          if (viewport.width <= 768) {
            // Mobile: larger touch target
            expect(button).toHaveStyle('min-width: 44px');
            expect(button).toHaveStyle('min-height: 44px');
            expect(button).toHaveStyle('padding: 12px');
          } else {
            // Desktop: standard size
            expect(button).toHaveStyle('min-width: 32px');
            expect(button).toHaveStyle('min-height: 32px');
          }
          
          // Check tooltip positioning
          fireEvent.mouseEnter(button);
          
          const tooltip = screen.getByRole('tooltip');
          if (viewport.width <= 375) {
            // Small mobile: tooltip should be centered
            expect(tooltip).toHaveStyle('left: 50%');
            expect(tooltip).toHaveStyle('transform: translateX(-50%)');
          }
        });

        it(`should adapt motion animations for ${viewport.name}`, () => {
          render(
            <MotionProvider>
              <div 
                className="motion-responsive"
                data-testid="responsive-motion"
              >
                Responsive Motion
              </div>
            </MotionProvider>
          );
          
          const element = screen.getByTestId('responsive-motion');
          
          // Check responsive animation properties
          if (viewport.width <= 768) {
            // Mobile: simpler animations for performance
            expect(element).toHaveStyle('animation-duration: 0.2s');
            expect(element).toHaveStyle('transition-duration: 0.2s');
          } else {
            // Desktop: full animations
            expect(element).toHaveStyle('animation-duration: 0.3s');
          }
          
          // Check reduced motion support
          Object.defineProperty(window, 'matchMedia', {
            writable: true,
            value: vi.fn().mockImplementation(query => ({
              matches: query === '(prefers-reduced-motion: reduce)',
              media: query,
              onchange: null,
              addListener: vi.fn(),
              removeListener: vi.fn(),
              addEventListener: vi.fn(),
              removeEventListener: vi.fn(),
              dispatchEvent: vi.fn(),
            })),
          });
          
          // Re-render with reduced motion
          render(
            <MotionProvider>
              <div className="motion-responsive">
                Reduced Motion
              </div>
            </MotionProvider>
          );
          
          const reducedElement = screen.getByText('Reduced Motion');
          expect(reducedElement).toHaveStyle('animation: none');
        });

        it(`should handle touch interactions appropriately on ${viewport.name}`, async () => {
          render(
            <MotionProvider>
              <SwipeActions
                leftActions={[
                  { id: 'action1', label: 'Action 1', onAction: vi.fn() }
                ]}
                swipeThreshold={viewport.width <= 768 ? 50 : 100}
              >
                <div 
                  data-testid="swipe-area"
                  style={{ 
                    width: '100%', 
                    height: viewport.width <= 768 ? '60px' : '80px' 
                  }}
                >
                  Swipe Area
                </div>
              </SwipeActions>
            </MotionProvider>
          );
          
          const swipeArea = screen.getByTestId('swipe-area');
          
          // Test touch interaction based on viewport
          if (viewport.width <= 768) {
            // Mobile: touch events
            fireEvent.touchStart(swipeArea, {
              touches: [{ clientX: viewport.width - 10, clientY: 30 }]
            });
            fireEvent.touchMove(swipeArea, {
              touches: [{ clientX: viewport.width - 60, clientY: 30 }]
            });
            fireEvent.touchEnd(swipeArea);
          } else {
            // Desktop: mouse events
            fireEvent.mouseDown(swipeArea, { clientX: viewport.width - 10, clientY: 40 });
            fireEvent.mouseMove(swipeArea, { clientX: viewport.width - 110, clientY: 40 });
            fireEvent.mouseUp(swipeArea);
          }
          
          await waitFor(() => {
            expect(screen.getByText('Action 1')).toBeInTheDocument();
          });
        });

        it(`should display tour appropriately on ${viewport.name}`, async () => {
          render(
            <Tour
              steps={[
                {
                  target: '[data-tour="responsive-step"]',
                  content: 'This is a responsive tour step',
                  placement: viewport.width <= 768 ? 'bottom' : 'right'
                }
              ]}
              run={true}
            />
          );
          
          await waitFor(() => {
            const tourTooltip = screen.getByRole('dialog');
            
            // Check responsive positioning
            if (viewport.width <= 768) {
              expect(tourTooltip).toHaveStyle('max-width: 90vw');
              expect(tourTooltip).toHaveStyle('bottom: 20px');
            } else {
              expect(tourTooltip).toHaveStyle('max-width: 400px');
              expect(tourTooltip).toHaveStyle('right: 20px');
            }
            
            // Check responsive font sizes
            if (viewport.width <= 320) {
              expect(tourTooltip).toHaveStyle('font-size: 14px');
            }
          });
        });
      });
    });
  });

  describe('3. Accessibility Compliance Across Platforms', () => {
    const platforms = [
      { name: 'Windows with NVDA', type: 'screenreader' },
      { name: 'macOS with VoiceOver', type: 'screenreader' },
      { name: 'iOS with VoiceOver', type: 'screenreader' },
      { name: 'Android with TalkBack', type: 'screenreader' },
      { name: 'High Contrast Mode', type: 'visual' },
      { name: 'Keyboard Only', type: 'input' },
      { name: 'Switch Control', type: 'input' }
    ];

    platforms.forEach(platform => {
      describe(`${platform.name}`, () => {
        it(`should support ${platform.type} accessibility`, () => {
          // Render test components
          render(
            <MotionProvider>
              <div>
                <AccessibilityInfo
                  elementId={`${platform.name.toLowerCase().replace(/ /g, '-')}`}
                  docSection="accessibility/platforms"
                  tooltipText={`${platform.name} accessibility test`}
                />
                
                <button data-testid="test-button">
                  Test Button
                </button>
                
                <div 
                  role="progressbar"
                  aria-valuenow="75"
                  aria-valuemin="0"
                  aria-valuemax="100"
                  data-testid="progress-bar"
                >
                  Progress
                </div>
              </div>
            </MotionProvider>
          );
          
          // Run platform-specific accessibility checks
          const violations = accessibilityChecker.checkPlatform(platform.name);
          
          // Should have no critical accessibility violations
          const criticalViolations = violations.filter(v => v.impact === 'critical');
          expect(criticalViolations).toHaveLength(0);
          
          // Platform-specific checks
          if (platform.type === 'screenreader') {
            // Screen reader specific checks
            const button = screen.getByTestId('test-button');
            expect(button).toHaveAttribute('aria-label');
            
            const progressBar = screen.getByTestId('progress-bar');
            expect(progressBar).toHaveAttribute('aria-valuetext');
          }
          
          if (platform.name.includes('High Contrast')) {
            // High contrast mode checks
            const elements = screen.getAllByRole('button');
            elements.forEach(element => {
              expect(element).toHaveStyle('border-width: 2px');
              expect(element).toHaveStyle('border-style: solid');
            });
          }
          
          if (platform.type === 'input' && platform.name.includes('Keyboard')) {
            // Keyboard navigation checks
            const focusableElements = screen.getAllByRole('button');
            focusableElements.forEach((element, index) => {
              element.focus();
              expect(document.activeElement).toBe(element);
              
              // Test tab order
              if (index < focusableElements.length - 1) {
                userEvent.tab();
                expect(document.activeElement).toBe(focusableElements[index + 1]);
              }
            });
          }
        });

        it(`should handle ${platform.type} interactions with motion`, () => {
          render(
            <MotionProvider>
              <div
                data-testid="accessible-motion"
                className="motion-focus-scale"
                tabIndex={0}
                role="button"
                aria-label="Accessible motion element"
              >
                Accessible Motion
              </div>
            </MotionProvider>
          );
          
          const motionElement = screen.getByTestId('accessible-motion');
          
          // Platform-specific interaction tests
          if (platform.type === 'input' && platform.name.includes('Keyboard')) {
            // Keyboard interaction
            motionElement.focus();
            expect(motionElement).toHaveClass('motion-focused');
            
            userEvent.keyboard('{Enter}');
            expect(motionElement).toHaveClass('motion-activated');
          }
          
          if (platform.name.includes('High Contrast')) {
            // High contrast motion checks
            expect(motionElement).toHaveStyle('outline: 3px solid transparent');
            expect(motionElement).toHaveStyle('outline-offset: 2px');
          }
          
          // Check reduced motion support
          Object.defineProperty(window, 'matchMedia', {
            writable: true,
            value: vi.fn().mockImplementation(query => ({
              matches: query === '(prefers-reduced-motion: reduce)',
              media: query,
              onchange: null,
              addListener: vi.fn(),
              removeListener: vi.fn(),
              add