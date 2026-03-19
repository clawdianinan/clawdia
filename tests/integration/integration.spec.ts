/**
 * Integration Testing Pipeline
 * 
 * Tests interactions between different improvements:
 * - Motion Design + Micro-interactions compatibility
 * - Security + GDPR + Payment compliance integration
 * - Cross-feature dependencies and workflows
 */

import { describe, it, expect, beforeAll, afterAll, vi } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

// Import all components for integration testing
import { MotionProvider } from '@/components/motion/MotionProvider';
import AccessibilityInfo from '@/components/ui/AccessibilityInfo';
import Tour from '@/components/onboarding/Tour';
import { TourProvider } from '@/components/onboarding/TourProvider';
import { validateGDPRCompliance } from '@/utils/compliance/gdpr';
import { checkPaymentSecurity } from '@/utils/security/payment';
import { DragDropManager } from '@/utils/dragDropAnimations';
import { SwipeActions } from '@/components/interactions/SwipeActions';
import { ProgressiveLoader } from '@/components/loading/ProgressiveLoader';
import { ValidationFeedback } from '@/components/forms/ValidationFeedback';
import { DelightfulMoments } from '@/components/delight/DelightfulMoments';

describe('Integration Test Suite - Feature Interactions', () => {
  
  describe('1. Motion Design + Micro-interactions Compatibility', () => {
    it('should integrate drag-drop animations with motion system', async () => {
      const user = userEvent.setup();
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
      
      // Simulate drag start
      fireEvent.mouseDown(draggable);
      fireEvent.mouseMove(draggable, { clientX: 100, clientY: 100 });
      
      // Check motion classes applied
      expect(draggable).toHaveClass('motion-dragging');
      expect(dropzone).toHaveClass('motion-drop-highlight');
      
      // Simulate drop
      fireEvent.mouseUp(dropzone);
      
      await waitFor(() => {
        expect(draggable).toHaveClass('motion-drop-success');
      });
    });

    it('should integrate swipe actions with motion feedback', async () => {
      const user = userEvent.setup();
      const mockAction = vi.fn();
      
      render(
        <MotionProvider>
          <SwipeActions
            leftActions={[
              {
                id: 'archive',
                label: 'Archive',
                color: 'white',
                backgroundColor: '#3b82f6',
                onAction: mockAction
              }
            ]}
            hapticFeedback={true}
          >
            <div data-testid="swipe-item">Swipe Item</div>
          </SwipeActions>
        </MotionProvider>
      );
      
      const swipeItem = screen.getByTestId('swipe-item');
      
      // Simulate swipe
      fireEvent.touchStart(swipeItem, { touches: [{ clientX: 100, clientY: 50 }] });
      fireEvent.touchMove(swipeItem, { touches: [{ clientX: 50, clientY: 50 }] });
      fireEvent.touchEnd(swipeItem);
      
      // Check motion feedback
      expect(swipeItem).toHaveClass('motion-swipe-reveal');
      
      // Click action button
      const archiveButton = screen.getByText('Archive');
      await user.click(archiveButton);
      
      expect(mockAction).toHaveBeenCalled();
      expect(swipeItem).toHaveClass('motion-action-complete');
    });

    it('should integrate progressive loading with motion animations', async () => {
      render(
        <MotionProvider>
          <ProgressiveLoader
            items={['item1', 'item2', 'item3']}
            loading={true}
            skeletonAnimation="shimmer"
            onLoadComplete={vi.fn()}
          />
        </MotionProvider>
      );
      
      // Check skeleton animations
      const skeletons = screen.getAllByTestId('skeleton-item');
      expect(skeletons).toHaveLength(3);
      
      skeletons.forEach((skeleton, index) => {
        expect(skeleton).toHaveClass('motion-shimmer');
        // Check staggered animation delay
        expect(skeleton).toHaveStyle(`animation-delay: ${index * 100}ms`);
      });
      
      // Simulate loading complete
      render(
        <MotionProvider>
          <ProgressiveLoader
            items={['item1', 'item2', 'item3']}
            loading={false}
            skeletonAnimation="shimmer"
            onLoadComplete={vi.fn()}
          />
        </MotionProvider>
      );
      
      await waitFor(() => {
        const items = screen.getAllByText(/item/);
        expect(items).toHaveLength(3);
        items.forEach(item => {
          expect(item).toHaveClass('motion-fade-in');
        });
      });
    });
  });

  describe('2. Security + GDPR + Payment Compliance Integration', () => {
    it('should integrate GDPR compliance with payment security', async () => {
      // Test that GDPR requirements are met in payment flow
      const gdprCompliance = await validateGDPRCompliance();
      const paymentSecurity = await checkPaymentSecurity();
      
      // GDPR requirements for payment processing
      expect(gdprCompliance.dataProcessingAgreements).toBe(true);
      expect(gdprCompliance.securityMeasures).toBe(true);
      
      // Payment security requirements
      expect(paymentSecurity.encryption).toBe(true);
      expect(paymentSecurity.pciCompliance).toBe(true);
      
      // Integration points
      expect(gdprCompliance.consentManagement).toHaveProperty('paymentProcessing');
      expect(paymentSecurity.dataProtection).toHaveProperty('gdprCompliant');
    });

    it('should handle sensitive data with proper encryption and consent', () => {
      const paymentData = {
        cardNumber: '4111111111111111',
        expiry: '12/25',
        cvv: '123',
        consentGiven: true,
        gdprConsent: true
      };
      
      // Test encryption
      const encrypted = encryptPaymentData(paymentData);
      expect(encrypted).not.toContain('4111');
      expect(encrypted).toHaveProperty('encryptionLevel', 'AES-256');
      
      // Test consent tracking
      expect(paymentData.consentGiven).toBe(true);
      expect(paymentData.gdprConsent).toBe(true);
      
      // Test data minimization
      const minimizedData = minimizePaymentData(paymentData);
      expect(minimizedData).not.toHaveProperty('cvv');
      expect(minimizedData).toHaveProperty('token');
    });

    it('should integrate security with form validation', async () => {
      const user = userEvent.setup();
      
      render(
        <ValidationFeedback
          fields={[
            {
              id: 'password',
              label: 'Password',
              type: 'password',
              validation: {
                required: true,
                minLength: 8,
                pattern: /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/
              }
            }
          ]}
          onSubmit={vi.fn()}
          showLiveValidation={true}
          securityLevel="high"
        />
      );
      
      const passwordInput = screen.getByLabelText('Password');
      await user.type(passwordInput, 'weak');
      
      // Should show security validation error
      await waitFor(() => {
        expect(screen.getByText(/must contain/i)).toBeInTheDocument();
        expect(screen.getByText(/at least 8 characters/i)).toBeInTheDocument();
      });
      
      // Enter strong password
      await user.clear(passwordInput);
      await user.type(passwordInput, 'Str0ngP@ssw0rd!');
      
      await waitFor(() => {
        expect(screen.getByText(/strong password/i)).toBeInTheDocument();
      });
    });

    it('should handle data subject rights in payment context', async () => {
      const user = userEvent.setup();
      
      // Test data export for payment history
      const exportResponse = await exportUserData('payment-history');
      expect(exportResponse).toHaveProperty('data');
      expect(exportResponse.data).toHaveProperty('payments');
      expect(exportResponse.data).toHaveProperty('invoices');
      expect(exportResponse.data).toHaveProperty('subscriptions');
      
      // Test data deletion
      const deleteResponse = await deleteUserData('payment-data');
      expect(deleteResponse).toHaveProperty('success', true);
      expect(deleteResponse).toHaveProperty('confirmationId');
      
      // Test that sensitive data is properly anonymized
      const anonymizedData = anonymizePaymentData(exportResponse.data);
      expect(anonymizedData.payments[0]).not.toHaveProperty('cardNumber');
      expect(anonymizedData.payments[0]).toHaveProperty('maskedCard', '**** **** **** 1111');
    });
  });

  describe('3. Accessibility + Motion + Tour Integration', () => {
    it('should integrate accessibility with motion animations', () => {
      render(
        <MotionProvider>
          <AccessibilityInfo
            elementId="animated-element"
            docSection="motion/accessibility"
            tooltipText="This element has motion animations with accessibility support"
            motionClass="motion-bounce-on-hover"
          />
        </MotionProvider>
      );
      
      const button = screen.getByRole('button');
      
      // Check accessibility attributes
      expect(button).toHaveAttribute('aria-describedby');
      expect(button).toHaveAttribute('aria-label');
      
      // Check motion integration
      expect(button).toHaveClass('motion-bounce-on-hover');
      
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
          <AccessibilityInfo
            elementId="animated-element"
            docSection="motion/accessibility"
            tooltipText="Test"
          />
        </MotionProvider>
      );
      
      const reducedMotionButton = screen.getByRole('button');
      expect(reducedMotionButton).toHaveStyle('animation: none');
    });

    it('should integrate tour with accessibility features', async () => {
      const user = userEvent.setup();
      
      render(
        <TourProvider>
          <div>
            <button data-tour="step-1" aria-label="First step button">
              Step 1
            </button>
            <AccessibilityInfo
              elementId="tour-step-1"
              docSection="onboarding/first-steps"
              tooltipText="This is the first step of the tour"
            />
          </div>
        </TourProvider>
      );
      
      // Start tour
      await user.click(screen.getByText('Start Tour'));
      
      // Check tour step has accessibility support
      await waitFor(() => {
        const tourStep = screen.getByRole('dialog');
        expect(tourStep).toHaveAttribute('aria-label', 'Tour step 1 of 5');
        expect(tourStep).toHaveAttribute('aria-describedby', 'tour-step-description');
        
        // Check focus management
        expect(document.activeElement).toBe(screen.getByText('Next'));
      });
      
      // Test keyboard navigation through tour
      await user.keyboard('{Tab}');
      expect(document.activeElement).toBe(screen.getByText('Skip'));
      
      await user.keyboard('{Enter}'); // Activate Skip
      expect(screen.queryByRole('dialog')).not.toBeInTheDocument();
    });

    it('should integrate delightful moments with accessibility', async () => {
      const user = userEvent.setup();
      
      render(
        <MotionProvider>
          <DelightfulMoments
            achievements={[
              {
                id: 'first-prd',
                title: 'First PRD Created',
                description: 'Created your first Product Requirements Document',
                unlocked: false
              }
            ]}
            onAchievementUnlock={vi.fn()}
            accessibilityMode="high-contrast"
          />
        </MotionProvider>
      );
      
      // Simulate achievement unlock
      fireEvent.click(screen.getByText('Create First PRD'));
      
      await waitFor(() => {
        // Check celebration animation
        const celebration = screen.getByTestId('celebration-animation');
        expect(celebration).toBeInTheDocument();
        
        // Check accessibility features
        expect(celebration).toHaveAttribute('aria-live', 'polite');
        expect(celebration).toHaveAttribute('aria-label', 'Achievement unlocked: First PRD Created');
        
        // Check high contrast mode
        expect(celebration).toHaveClass('high-contrast');
        expect(celebration).toHaveStyle('border-width: 3px');
      });
    });
  });

  describe('4. Cross-Feature Dependency Tests', () => {
    it('should handle complex user workflow with all features', async () => {
      const user = userEvent.setup();
      
      // Simulate complete user journey
      render(
        <TourProvider>
          <MotionProvider>
            <div>
              {/* Step 1: Tour introduction */}
              <button data-tour="welcome">Get Started</button>
              
              {/* Step 2: Form with validation */}
              <ValidationFeedback
                fields={[
                  { id: 'email', label: 'Email', type: 'email', required: true },
                  { id: 'password', label: 'Password', type: 'password', required: true }
                ]}
                onSubmit={vi.fn()}
              />
              
              {/* Step 3: Drag-drop interface */}
              <div className="draggable-item" data-tour="drag-drop">
                Template Item
              </div>
              <div className="drop-zone">Workspace</div>
              
              {/* Step 4: Accessibility info */}
              <AccessibilityInfo
                elementId="export-button"
                docSection="export/options"
                tooltipText="Export your PRD in multiple formats"
              />
              
              {/* Step 5: Payment with security */}
              <button data-tour="payment">Upgrade Plan</button>
            </div>
          </MotionProvider>
        </TourProvider>
      );
      
      // 1. Start tour
      await user.click(screen.getByText('Get Started'));
      await waitFor(() => {
        expect(screen.getByText('Welcome to PRDForge')).toBeInTheDocument();
      });
      await user.click(screen.getByText('Next'));
      
      // 2. Fill form with validation
      await user.type(screen.getByLabelText('Email'), 'test@example.com');
      await user.type(screen.getByLabelText('Password'), 'Str0ngP@ss1!');
      await user.click(screen.getByText('Submit'));
      
      // 3. Use drag-drop
      const draggable = screen.getByText('Template Item');
      const dropzone = screen.getByText('Workspace');
      
      fireEvent.mouseDown(draggable);
      fireEvent.mouseMove(draggable, { clientX: 100, clientY: 100 });
      fireEvent.mouseUp(dropzone);
      
      // 4. Use accessibility info
      const infoButton = screen.getByRole('button', { name: /information/i });
      await user.hover(infoButton);
      await waitFor(() => {
        expect(screen.getByText(/Export your PRD/i)).toBeInTheDocument();
      });
      
      // 5. Proceed to payment
      await user.click(screen.getByText('Upgrade Plan'));
      
      // Verify all features worked together
      expect(vi.mocked(window.open)).toHaveBeenCalled(); // Documentation opened
      expect(screen.getByText('Template Item')).toHaveClass('motion-drop-success');
      expect(screen.getByLabelText('Email')).toHaveValue('test@example.com');
    });

    it('should handle error states across integrated features', async () => {
      const user = userEvent.setup();
      
      render(
        <MotionProvider>
          <div>
            {/* Form with validation error */}
            <ValidationFeedback
              fields={[
                { 
                  id: 'credit-card', 
                  label: 'Credit Card', 
                  type: 'text',
                  validation: {
                    required: true,
                    pattern: /^\d{16}$/
                  }
                }
              ]}
              onSubmit={vi.fn()}
              showLiveValidation={true}
            />
            
            {/* Accessibility info for error */}
            <AccessibilityInfo
              elementId="credit-card-error"
              docSection="billing/troubleshooting"
              tooltipText="Common credit card errors and solutions"
            />
            
            {/* Delightful moment for recovery */}
            <DelightfulMoments
              achievements={[
                {
                  id: 'payment-recovered',
                  title: 'Payment Issue Resolved',
                  description: 'Successfully fixed a payment problem',
                  unlocked: false
                }
              ]}
              onAchievementUnlock={vi.fn()}
            />
          </div>
        </MotionProvider>
      );
      
      // Enter invalid credit card
      await user.type(screen.getByLabelText('Credit Card'), '1234');
      
      // Check validation error with motion
      await waitFor(() => {
        const errorElement = screen.getByText(/Invalid credit card number