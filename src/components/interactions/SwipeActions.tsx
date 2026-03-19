/**
 * Swipe Actions Component
 * 
 * Mobile swipe gestures with visual feedback, action reveal animations,
 * and haptic feedback integration (where supported).
 */

import React, { useState, useRef, useEffect, useCallback } from 'react';
import { MotionClasses, applyMotionClasses, removeMotionClasses } from '../../styles/motion-utils';

/**
 * Swipe action configuration
 */
export interface SwipeAction {
  id: string;
  label: string;
  icon?: React.ReactNode;
  color: string;
  backgroundColor: string;
  onAction: () => void;
  threshold?: number; // Percentage of width to trigger (0-1)
  confirm?: boolean; // Require confirmation
  destructive?: boolean; // Destructive action (requires extra swipe)
}

/**
 * SwipeActions component props
 */
export interface SwipeActionsProps {
  children: React.ReactNode;
  leftActions?: SwipeAction[];
  rightActions?: SwipeAction[];
  swipeThreshold?: number; // Percentage of width to trigger swipe (0-1)
  maxSwipeDistance?: number; // Maximum swipe distance in pixels
  hapticFeedback?: boolean; // Enable haptic feedback
  vibrationPattern?: number[]; // Custom vibration pattern for haptic feedback
  onSwipeStart?: () => void;
  onSwipeEnd?: () => void;
  className?: string;
  disabled?: boolean;
}

/**
 * Swipe state
 */
interface SwipeState {
  isSwiping: boolean;
  startX: number;
  currentX: number;
  velocity: number;
  direction: 'left' | 'right' | null;
  activeAction: SwipeAction | null;
  isConfirming: boolean;
  confirmedAction: SwipeAction | null;
}

/**
 * SwipeActions Component
 */
export const SwipeActions: React.FC<SwipeActionsProps> = ({
  children,
  leftActions = [],
  rightActions = [],
  swipeThreshold = 0.2, // 20% of width
  maxSwipeDistance = 120, // pixels
  hapticFeedback = true,
  vibrationPattern = [50], // 50ms vibration
  onSwipeStart,
  onSwipeEnd,
  className = '',
  disabled = false,
}) => {
  const containerRef = useRef<HTMLDivElement>(null);
  const contentRef = useRef<HTMLDivElement>(null);
  const actionsRef = useRef<HTMLDivElement>(null);
  
  const [state, setState] = useState<SwipeState>({
    isSwiping: false,
    startX: 0,
    currentX: 0,
    velocity: 0,
    direction: null,
    activeAction: null,
    isConfirming: false,
    confirmedAction: null,
  });

  const lastTimestamp = useRef<number>(0);
  const animationFrame = useRef<number>(0);
  const isTouchDevice = 'ontouchstart' in window;

  /**
   * Trigger haptic feedback
   */
  const triggerHaptic = useCallback(() => {
    if (!hapticFeedback || !('vibrate' in navigator)) return;
    
    try {
      if (vibrationPattern.length > 0) {
        navigator.vibrate(vibrationPattern);
      }
    } catch (error) {
      console.warn('Haptic feedback failed:', error);
    }
  }, [hapticFeedback, vibrationPattern]);

  /**
   * Get container width
   */
  const getContainerWidth = useCallback(() => {
    return containerRef.current?.offsetWidth || 0;
  }, []);

  /**
   * Calculate swipe percentage
   */
  const getSwipePercentage = useCallback((distance: number) => {
    const width = getContainerWidth();
    return width > 0 ? Math.abs(distance) / width : 0;
  }, [getContainerWidth]);

  /**
   * Find action at swipe position
   */
  const getActionAtPosition = useCallback(
    (distance: number, actions: SwipeAction[]): SwipeAction | null => {
      if (actions.length === 0) return null;

      const percentage = getSwipePercentage(distance);
      const actionWidth = 1 / actions.length; // Each action takes equal width

      for (let i = 0; i < actions.length; i++) {
        const actionThreshold = actions[i].threshold || (i + 1) * actionWidth;
        if (percentage >= actionThreshold) {
          return actions[i];
        }
      }

      return null;
    },
    [getSwipePercentage]
  );

  /**
   * Update visual feedback
   */
  const updateVisualFeedback = useCallback(
    (distance: number, direction: 'left' | 'right') => {
      if (!contentRef.current || !actionsRef.current) return;

      const actions = direction === 'left' ? leftActions : rightActions;
      const action = getActionAtPosition(distance, actions);

      // Update content position
      contentRef.current.style.transform = `translateX(${distance}px)`;
      contentRef.current.style.transition = state.isSwiping ? 'none' : 'transform 300ms var(--motion-easing-standard)';

      // Update active action
      if (action !== state.activeAction) {
        if (state.activeAction) {
          removeMotionClasses(contentRef.current, 'CARD_SPATIAL_LIFT');
        }
        
        if (action) {
          applyMotionClasses(contentRef.current, 'CARD_SPATIAL_LIFT');
          triggerHaptic();
        }
        
        setState(prev => ({ ...prev, activeAction: action }));
      }

      // Update action indicators
      if (actionsRef.current) {
        const percentage = getSwipePercentage(distance);
        actions.forEach((act, index) => {
          const actionWidth = 1 / actions.length;
          const actionThreshold = act.threshold || (index + 1) * actionWidth;
          const actionElement = actionsRef.current?.children[index] as HTMLElement;
          
          if (actionElement) {
            const actionProgress = Math.min(Math.max((percentage - index * actionWidth) / actionWidth, 0), 1);
            actionElement.style.opacity = String(actionProgress);
            actionElement.style.transform = `scale(${0.8 + actionProgress * 0.2})`;
            
            // Highlight destructive actions
            if (act.destructive && percentage >= actionThreshold) {
              applyMotionClasses(actionElement, 'ERROR_SHAKE');
            } else {
              removeMotionClasses(actionElement, 'ERROR_SHAKE');
            }
          }
        });
      }
    },
    [leftActions, rightActions, getActionAtPosition, getSwipePercentage, state.activeAction, state.isSwiping, triggerHaptic]
  );

  /**
   * Handle touch/mouse start
   */
  const handleStart = useCallback(
    (clientX: number) => {
      if (disabled) return;

      setState(prev => ({
        ...prev,
        isSwiping: true,
        startX: clientX,
        currentX: clientX,
        velocity: 0,
        direction: null,
        isConfirming: false,
      }));

      onSwipeStart?.();
      lastTimestamp.current = performance.now();
    },
    [disabled, onSwipeStart]
  );

  /**
   * Handle touch/mouse move
   */
  const handleMove = useCallback(
    (clientX: number) => {
      if (!state.isSwiping || disabled) return;

      const now = performance.now();
      const deltaTime = now - lastTimestamp.current;
      lastTimestamp.current = now;

      const deltaX = clientX - state.currentX;
      const distance = clientX - state.startX;
      const velocity = deltaTime > 0 ? deltaX / deltaTime : 0;

      // Determine direction
      const direction = distance > 0 ? 'right' : 'left';
      const actions = direction === 'left' ? leftActions : rightActions;

      // Check if swipe is allowed in this direction
      if ((direction === 'left' && leftActions.length === 0) || 
          (direction === 'right' && rightActions.length === 0)) {
        return;
      }

      // Apply resistance
      const maxDistance = maxSwipeDistance;
      const resistance = 0.5;
      const resistedDistance = distance > 0 
        ? maxDistance * (1 - Math.exp(-distance / maxDistance))
        : -maxDistance * (1 - Math.exp(-Math.abs(distance) / maxDistance));

      setState(prev => ({
        ...prev,
        currentX: clientX,
        velocity,
        direction,
      }));

      updateVisualFeedback(resistedDistance, direction);

      // Check for confirm state on destructive actions
      if (state.activeAction?.destructive) {
        const percentage = getSwipePercentage(resistedDistance);
        const actionThreshold = state.activeAction.threshold || 0.5;
        const confirmThreshold = actionThreshold * 1.5; // 50% extra for confirmation
        
        if (percentage >= confirmThreshold && !state.isConfirming) {
          setState(prev => ({ ...prev, isConfirming: true }));
          triggerHaptic();
        } else if (percentage < confirmThreshold && state.isConfirming) {
          setState(prev => ({ ...prev, isConfirming: false }));
        }
      }
    },
    [state.isSwiping, state.currentX, state.startX, state.activeAction, state.isConfirming, disabled, leftActions, rightActions, maxSwipeDistance, updateVisualFeedback, getSwipePercentage, triggerHaptic]
  );

  /**
   * Handle touch/mouse end
   */
  const handleEnd = useCallback(() => {
    if (!state.isSwiping || disabled) return;

    const distance = state.currentX - state.startX;
    const percentage = getSwipePercentage(distance);
    const thresholdMet = percentage >= swipeThreshold;
    const actions = state.direction === 'left' ? leftActions : rightActions;
    const action = getActionAtPosition(distance, actions);

    // Animate back or trigger action
    if (contentRef.current) {
      if (thresholdMet && action && (!action.destructive || state.isConfirming)) {
        // Trigger action
        if (action.confirm && !state.confirmedAction) {
          // Show confirmation
          setState(prev => ({ ...prev, confirmedAction: action }));
          applyMotionClasses(contentRef.current, 'SUCCESS_CHECKMARK');
          triggerHaptic();
          
          // Auto-confirm after delay
          setTimeout(() => {
            if (contentRef.current) {
              removeMotionClasses(contentRef.current, 'SUCCESS_CHECKMARK');
              action.onAction();
              resetPosition();
            }
          }, 1000);
        } else {
          // Execute action immediately
          action.onAction();
          applyMotionClasses(contentRef.current, 'CELEBRATION_CONFETTI');
          triggerHaptic();
          
          setTimeout(() => {
            if (contentRef.current) {
              removeMotionClasses(contentRef.current, 'CELEBRATION_CONFETTI');
              resetPosition();
            }
          }, 800);
        }
      } else {
        // Return to original position
        resetPosition();
        
        // Shake feedback for failed destructive action
        if (action?.destructive && !state.isConfirming) {
          applyMotionClasses(contentRef.current, 'ERROR_SHAKE');
          triggerHaptic();
          
          setTimeout(() => {
            if (contentRef.current) {
              removeMotionClasses(contentRef.current, 'ERROR_SHAKE');
            }
          }, 600);
        }
      }
    }

    setState(prev => ({
      ...prev,
      isSwiping: false,
      activeAction: null,
      isConfirming: false,
    }));

    onSwipeEnd?.();
  }, [state.isSwiping, state.currentX, state.startX, state.direction, state.isConfirming, state.confirmedAction, disabled, getSwipePercentage, swipeThreshold, leftActions, rightActions, getActionAtPosition, onSwipeEnd, triggerHaptic]);

  /**
   * Reset content position
   */
  const resetPosition = useCallback(() => {
    if (contentRef.current) {
      contentRef.current.style.transform = 'translateX(0)';
      contentRef.current.style.transition = 'transform 400ms var(--motion-easing-bounce)';
    }
    
    if (actionsRef.current) {
      Array.from(actionsRef.current.children).forEach(child => {
        const element = child as HTMLElement;
        element.style.opacity = '0';
        element.style.transform = 'scale(0.8)';
        removeMotionClasses(element, 'ERROR_SHAKE');
      });
    }
  }, []);

  /**
   * Event handlers
   */
  const handleTouchStart = useCallback((e: React.TouchEvent) => {
    handleStart(e.touches[0].clientX);
  }, [handleStart]);

  const handleTouchMove = useCallback((e: React.TouchEvent) => {
    handleMove(e.touches[0].clientX);
  }, [handleMove]);

  const handleTouchEnd = useCallback(() => {
    handleEnd();
  }, [handleEnd]);

  const handleMouseDown = useCallback((e: React.MouseEvent) => {
    handleStart(e.clientX);
  }, [handleStart]);

  const handleMouseMove = useCallback((e: MouseEvent) => {
    handleMove(e.clientX);
  }, [handleMove]);

  const handleMouseUp = useCallback(() => {
    handleEnd();
  }, [handleEnd]);

  /**
   * Set up mouse event listeners
   */
  useEffect(() => {
    if (state.isSwiping && !isTouchDevice) {
      document.addEventListener('mousemove', handleMouseMove);
      document.addEventListener('mouseup', handleMouseUp);
      
      return () => {
        document.removeEventListener('mousemove', handleMouseMove);
        document.removeEventListener('mouseup', handleMouseUp);
      };
    }
  }, [state.isSwiping, isTouchDevice, handleMouseMove, handleMouseUp]);

  /**
   * Cancel animation frame on unmount
   */
  useEffect(() => {
    return () => {
      if (animationFrame.current) {
        cancelAnimationFrame(animationFrame.current);
      }
    };
  }, []);

  /**
   * Render action buttons
   */
  const renderActions = (actions: SwipeAction[], side: 'left' | 'right') => {
    if (actions.length === 0) return null;

    return (
      <div
        className={`swipe-actions-${side}`}
        style={{
          position: 'absolute',
          top: 0,
          [side]: 0,
          bottom: 0,
          display: 'flex',
          flexDirection: side === 'left' ? 'row' : 'row-reverse',
          width: '100%',
          overflow: 'hidden',
        }}
      >
        {actions.map((action, index) => (
          <div
            key={action.id}
            className="swipe-action"
            style={{
              flex: 1,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              backgroundColor: action.backgroundColor,
              color: action.color,
              opacity: 0,
              transform: 'scale(0.8)',
              transition: 'all 200ms var(--motion-easing-standard)',
              minWidth: '80px',
            }}
          >
            {action.icon && <span className="swipe-action-icon">{action.icon}</span>}
            <span className="swipe-action-label" style={{ marginLeft: action.icon ? '8px' : 0 }}>
              {state.isConfirming && action.destructive ? 'Release to confirm' : action.label}
            </span>
          </div>
        ))}
      </div>
    );
  };

  return (
    <div
      ref={containerRef}
      className={`swipe-actions-container ${className}`}
      style={{
        position: 'relative',
        overflow: 'hidden',
        userSelect: 'none',
        touchAction: 'pan-y',
      }}
      onTouchStart={handleTouchStart}
      onTouchMove={handleTouchMove}
      onTouchEnd={handleTouchEnd}
      onMouseDown={handleMouseDown}
    >
      {/* Background actions */}
      <div ref={actionsRef} style={{ position: 'absolute', top: 0, left: 0, right: 0, bottom: 0 }}>
        {renderActions(leftActions, 'left')}
        {renderActions(rightActions, 'right')}
      </div>

      {/* Content */}
      <div
        ref={contentRef}
        className="swipe-content"
        style={{
          position: 'relative',
          zIndex: 1,
          backgroundColor: 'var(--color-background)',
          transition: 'transform 300ms var(--motion-easing-standard)',
        }}
      >
        {children}
      </div>

      {/* Confirmation overlay */}
      {state.isConfirming && state.activeAction?.destructive && (
        <div
          className="swipe-confirm-overlay"
          style={{
            position: 'absolute',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            backgroundColor: 'rgba(239, 68, 68, 0.1)',
            zIndex: 2,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            pointerEvents: 'none',
          }}
        >
          <div
            style={{
              backgroundColor: 'rgba(239, 68, 68, 0.9)',
              color: 'white',
              padding: '8px 16px',
              borderRadius: '20px',
              fontSize: '14px',
              fontWeight: '600',
              animation: 'pulse 1.5s infinite',
            }}
          >
            Swipe further to confirm
          </div>
        </div>
      )}
    </div>
  );
};

/**
 * CSS styles for swipe actions
 */
export const swipeActionsStyles = `
.swipe-actions-container {
  position: relative;
  overflow: hidden;
  user-select: none;
  touch-action: pan-y;
}

.swipe-content {
  position: relative;
  z-index: 1;
  background-color: var(--color-background);
  transition: transform 300ms var(--motion-easing-standard);
  will-change: transform;
}

.swipe-action {
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 200ms var(--motion-easing-standard);
  min-width: 80