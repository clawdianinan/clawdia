/**
 * Progressive Loader Component
 * 
 * Implements staggered content reveal, priority loading animations,
 * and enhanced skeleton screens with spatial awareness.
 */

import React, { useState, useEffect, useRef } from 'react';
import { MotionClasses, applyMotionClasses, removeMotionClasses } from '../../styles/motion-utils';

/**
 * Loading priority levels
 */
export enum LoadingPriority {
  CRITICAL = 'critical',    // First to load (hero content)
  HIGH = 'high',            // Early load (primary content)
  MEDIUM = 'medium',        // Standard load (secondary content)
  LOW = 'low',              // Late load (tertiary content)
  BACKGROUND = 'background', // Last to load (decorative)
}

/**
 * Content item configuration
 */
export interface ContentItem {
  id: string;
  priority: LoadingPriority;
  content: React.ReactNode;
  skeleton?: React.ReactNode;
  estimatedLoadTime?: number; // ms
  dependencies?: string[]; // IDs of items that must load first
}

/**
 * ProgressiveLoader props
 */
export interface ProgressiveLoaderProps {
  items: ContentItem[];
  loading?: boolean;
  onLoadComplete?: () => void;
  onProgress?: (progress: number) => void;
  staggerDelay?: number; // ms between staggered items
  maxConcurrent?: number; // Maximum items loading simultaneously
  showSkeletons?: boolean;
  skeletonAnimation?: 'shimmer' | 'pulse' | 'wave';
  className?: string;
}

/**
 * Loading state for an item
 */
interface ItemLoadingState {
  id: string;
  priority: LoadingPriority;
  isLoading: boolean;
  isLoaded: boolean;
  loadStartTime: number | null;
  progress: number;
  dependencies: string[];
}

/**
 * ProgressiveLoader Component
 */
export const ProgressiveLoader: React.FC<ProgressiveLoaderProps> = ({
  items,
  loading = true,
  onLoadComplete,
  onProgress,
  staggerDelay = 100,
  maxConcurrent = 3,
  showSkeletons = true,
  skeletonAnimation = 'shimmer',
  className = '',
}) => {
  const [loadingStates, setLoadingStates] = useState<ItemLoadingState[]>([]);
  const [overallProgress, setOverallProgress] = useState(0);
  const [isComplete, setIsComplete] = useState(false);
  
  const loadingQueue = useRef<string[]>([]);
  const activeLoads = useRef<Set<string>>(new Set());
  const loadTimeouts = useRef<Map<string, NodeJS.Timeout>>(new Map());
  const containerRef = useRef<HTMLDivElement>(null);

  /**
   * Initialize loading states
   */
  useEffect(() => {
    const states: ItemLoadingState[] = items.map(item => ({
      id: item.id,
      priority: item.priority,
      isLoading: false,
      isLoaded: false,
      loadStartTime: null,
      progress: 0,
      dependencies: item.dependencies || [],
    }));

    setLoadingStates(states);
    setIsComplete(false);
    setOverallProgress(0);
    loadingQueue.current = [];
    activeLoads.current.clear();
    
    // Clear any existing timeouts
    loadTimeouts.current.forEach(timeout => clearTimeout(timeout));
    loadTimeouts.current.clear();
  }, [items]);

  /**
   * Calculate loading order based on priority and dependencies
   */
  const calculateLoadingOrder = useCallback((): string[] => {
    const order: string[] = [];
    const visited = new Set<string>();
    const temp = new Set<string>();

    // Priority weights
    const priorityWeights: Record<LoadingPriority, number> = {
      [LoadingPriority.CRITICAL]: 5,
      [LoadingPriority.HIGH]: 4,
      [LoadingPriority.MEDIUM]: 3,
      [LoadingPriority.LOW]: 2,
      [LoadingPriority.BACKGROUND]: 1,
    };

    // Topological sort with priority consideration
    const visit = (itemId: string) => {
      if (temp.has(itemId)) {
        console.warn('Circular dependency detected:', itemId);
        return;
      }
      
      if (!visited.has(itemId)) {
        temp.add(itemId);
        
        const item = items.find(i => i.id === itemId);
        if (item) {
          // Visit dependencies first
          item.dependencies?.forEach(depId => {
            if (items.some(i => i.id === depId)) {
              visit(depId);
            }
          });
        }
        
        temp.delete(itemId);
        visited.add(itemId);
        order.push(itemId);
      }
    };

    // Sort items by priority first, then visit
    const sortedItems = [...items].sort((a, b) => {
      const priorityDiff = priorityWeights[b.priority] - priorityWeights[a.priority];
      if (priorityDiff !== 0) return priorityDiff;
      
      // If same priority, sort by estimated load time (shorter first)
      const timeA = a.estimatedLoadTime || 1000;
      const timeB = b.estimatedLoadTime || 1000;
      return timeA - timeB;
    });

    sortedItems.forEach(item => visit(item.id));
    return order;
  }, [items]);

  /**
   * Start loading an item
   */
  const startLoadingItem = useCallback((itemId: string) => {
    const item = items.find(i => i.id === itemId);
    if (!item) return;

    setLoadingStates(prev => prev.map(state => {
      if (state.id === itemId) {
        return {
          ...state,
          isLoading: true,
          loadStartTime: Date.now(),
          progress: 0,
        };
      }
      return state;
    }));

    activeLoads.current.add(itemId);

    // Simulate progressive loading
    const estimatedTime = item.estimatedLoadTime || 1000;
    const steps = 10;
    const stepTime = estimatedTime / steps;

    let step = 0;
    const updateProgress = () => {
      step++;
      const progress = Math.min((step / steps) * 100, 100);

      setLoadingStates(prev => prev.map(state => {
        if (state.id === itemId) {
          return { ...state, progress };
        }
        return state;
      }));

      if (step < steps) {
        const timeout = setTimeout(updateProgress, stepTime);
        loadTimeouts.current.set(itemId, timeout);
      } else {
        finishLoadingItem(itemId);
      }
    };

    const timeout = setTimeout(updateProgress, stepTime);
    loadTimeouts.current.set(itemId, timeout);
  }, [items]);

  /**
   * Finish loading an item
   */
  const finishLoadingItem = useCallback((itemId: string) => {
    setLoadingStates(prev => prev.map(state => {
      if (state.id === itemId) {
        return {
          ...state,
          isLoading: false,
          isLoaded: true,
          progress: 100,
        };
      }
      return state;
    }));

    activeLoads.current.delete(itemId);
    loadTimeouts.current.delete(itemId);

    // Trigger reveal animation
    const element = document.getElementById(`content-${itemId}`);
    if (element) {
      applyMotionClasses(element, 'FADE_IN', 'SLIDE_IN_UP');
      
      // Add stagger delay based on priority
      const state = loadingStates.find(s => s.id === itemId);
      if (state) {
        const priorityDelay = {
          [LoadingPriority.CRITICAL]: 0,
          [LoadingPriority.HIGH]: 50,
          [LoadingPriority.MEDIUM]: 100,
          [LoadingPriority.LOW]: 150,
          [LoadingPriority.BACKGROUND]: 200,
        }[state.priority];
        
        element.style.animationDelay = `${priorityDelay}ms`;
      }
    }
  }, [loadingStates]);

  /**
   * Process loading queue
   */
  const processQueue = useCallback(() => {
    if (!loading || isComplete) return;

    // Calculate available slots
    const availableSlots = maxConcurrent - activeLoads.current.size;
    if (availableSlots <= 0) return;

    // Find next items to load
    const nextItems = loadingQueue.current.filter(itemId => {
      const state = loadingStates.find(s => s.id === itemId);
      if (!state) return false;
      
      // Check if already loading or loaded
      if (state.isLoading || state.isLoaded) return false;
      
      // Check dependencies
      const allDependenciesLoaded = state.dependencies.every(depId => {
        const depState = loadingStates.find(s => s.id === depId);
        return depState?.isLoaded;
      });
      
      return allDependenciesLoaded;
    }).slice(0, availableSlots);

    // Start loading next items
    nextItems.forEach(itemId => {
      startLoadingItem(itemId);
      loadingQueue.current = loadingQueue.current.filter(id => id !== itemId);
    });
  }, [loading, isComplete, maxConcurrent, loadingStates, startLoadingItem]);

  /**
   * Update overall progress
   */
  useEffect(() => {
    if (loadingStates.length === 0) return;

    const loadedCount = loadingStates.filter(s => s.isLoaded).length;
    const totalCount = loadingStates.length;
    const progress = totalCount > 0 ? (loadedCount / totalCount) * 100 : 0;

    setOverallProgress(progress);
    onProgress?.(progress);

    // Check if all items are loaded
    if (loadedCount === totalCount && totalCount > 0 && !isComplete) {
      setIsComplete(true);
      onLoadComplete?.();
      
      // Trigger completion celebration
      if (containerRef.current) {
        applyMotionClasses(containerRef.current, 'CELEBRATION_CONFETTI');
        setTimeout(() => {
          if (containerRef.current) {
            removeMotionClasses(containerRef.current, 'CELEBRATION_CONFETTI');
          }
        }, 1500);
      }
    }
  }, [loadingStates, isComplete, onProgress, onLoadComplete]);

  /**
   * Initialize loading queue
   */
  useEffect(() => {
    if (loading && items.length > 0) {
      const order = calculateLoadingOrder();
      loadingQueue.current = order;
      processQueue();
    }
  }, [loading, items, calculateLoadingOrder, processQueue]);

  /**
   * Process queue when states change
   */
  useEffect(() => {
    processQueue();
  }, [loadingStates, processQueue]);

  /**
   * Clean up on unmount
   */
  useEffect(() => {
    return () => {
      loadTimeouts.current.forEach(timeout => clearTimeout(timeout));
      loadTimeouts.current.clear();
    };
  }, []);

  /**
   * Render skeleton for an item
   */
  const renderSkeleton = (item: ContentItem, state: ItemLoadingState) => {
    if (!showSkeletons || state.isLoaded) return null;

    const skeletonClasses = {
      shimmer: 'skeleton-shimmer',
      pulse: 'skeleton-pulse',
      wave: 'skeleton-wave',
    }[skeletonAnimation];

    return (
      <div
        id={`skeleton-${item.id}`}
        className={`skeleton-item ${skeletonClasses}`}
        style={{
          opacity: state.isLoading ? 1 : 0.7,
          transition: 'opacity 300ms var(--motion-easing-standard)',
          animationDelay: `${Math.random() * 200}ms`, // Random delay for natural feel
        }}
      >
        {item.skeleton || (
          <div className="default-skeleton">
            <div className="skeleton-line" style={{ width: '80%', height: '20px' }} />
            <div className="skeleton-line" style={{ width: '60%', height: '16px', marginTop: '12px' }} />
            <div className="skeleton-line" style={{ width: '40%', height: '16px', marginTop: '8px' }} />
          </div>
        )}
      </div>
    );
  };

  /**
   * Render content for an item
   */
  const renderContent = (item: ContentItem, state: ItemLoadingState) => {
    if (!state.isLoaded) return null;

    return (
      <div
        id={`content-${item.id}`}
        className="content-item"
        style={{
          opacity: 0, // Will be animated in via CSS
          animationFillMode: 'forwards',
        }}
      >
        {item.content}
      </div>
    );
  };

  /**
   * Get priority badge color
   */
  const getPriorityColor = (priority: LoadingPriority): string => {
    const colors: Record<LoadingPriority, string> = {
      [LoadingPriority.CRITICAL]: 'var(--color-error)',
      [LoadingPriority.HIGH]: 'var(--color-warning)',
      [LoadingPriority.MEDIUM]: 'var(--color-primary)',
      [LoadingPriority.LOW]: 'var(--color-success)',
      [LoadingPriority.BACKGROUND]: 'var(--color-muted)',
    };
    return colors[priority];
  };

  /**
   * Render loading indicator
   */
  const renderLoadingIndicator = () => {
    if (!loading || isComplete) return null;

    return (
      <div className="loading-indicator" style={{
        position: 'sticky',
        top: 0,
        zIndex: 10,
        backgroundColor: 'var(--color-background)',
        padding: '12px',
        borderBottom: '1px solid var(--color-border)',
        display: 'flex',
        alignItems: 'center',
        gap: '12px',
      }}>
        <div className="progress-bar" style={{
          flex: 1,
          height: '4px',
          backgroundColor: 'var(--color-border)',
          borderRadius: '2px',
          overflow: 'hidden',
        }}>
          <div
            className="progress-fill"
            style={{
              height: '100%',
              backgroundColor: 'var(--color-primary)',
              width: `${overallProgress}%`,
              transition: 'width 300ms var(--motion-easing-standard)',
              borderRadius: '2px',
            }}
          />
        </div>
        
        <div className="progress-text" style={{
          fontSize: '14px',
          color: 'var(--color-text-secondary)',
          minWidth: '60px',
          textAlign: 'right',
        }}>
          {Math.round(overallProgress)}%
        </div>
        
        <div className="loading-stats" style={{
          display: 'flex',
          gap: '8px',
          fontSize: '12px',
          color: 'var(--color-text-tertiary)',
        }}>
          <span className="loading-count">
            {loadingStates.filter(s => s.isLoading).length} loading
          </span>
          <span className="loaded-count">
            {loadingStates.filter(s => s.isLoaded).length}/{items.length}
          </span>
        </div>
      </div>
    );
  };

  /**
   * Render priority visualization
   */
  const renderPriorityVisualization = () => {
    if (!loading) return null;

    return (
      <div className="priority-visualization" style={{
        marginBottom: '20px',
        padding: '16px',
        backgroundColor: 'var(--color-surface)',
        borderRadius: '8px',
        border: '1px solid var(--color-border)',
      }}>
        <div className="priority-title" style={{
          fontSize: '14px',
          fontWeight: '600',
          marginBottom: '12px',
          color: 'var(--color-text-secondary)',
        }}>
          Loading Priority
        </div>
        
        <div className="priority-bars" style={{
          display: 'flex',
          flexDirection: 'column',
          gap: '8px',
        }}>
          {loadingStates.map(state => (
            <div key={state.id} className="priority-item" style={{
              display: 'flex',
              alignItems: 'center',
              gap: '12px',
            }}>
              <div className="priority-label" style={{
                width: '100px',
                fontSize: '12px',
                color: 'var(--color-text-tertiary)',
                overflow: 'hidden',
                textOverflow: 'ellipsis',
                whiteSpace: 'nowrap',
              }}>
                {state.id}
              </div>
              
              <div className="priority-bar" style={{
                flex: 1,
                height: '8px',
                backgroundColor: 'var(--color-border)',
                borderRadius: '4px',
                overflow: 'hidden',
                position: 'relative',
              }}>
                <div
                  className="priority-fill"
                  style={{
                    position: 'absolute',
                    top: 0,
                    left: 0,
                    height: '100%',
                    width: `${state.progress}%`,
                    backgroundColor: getPriorityColor(state.priority),
                    transition: 'width 300ms var(--motion-easing-standard)',
                    borderRadius: '4px',
                  }}
                />
                
                {state.isLoading && (
                  <div className="loading-pulse" style={{
                    position: 'absolute',
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    background: `linear-gradient(90deg, 
                      transparent 0%, 
                      rgba(255, 255, 255, 0.3) 50%, 
                      transparent 100%)`,
                    animation: 'shimmer 1.5s infinite',
                    backgroundSize: '200% 100%',
                  }} />
                )}
              </div>
              
              <div className="priority-status" style={{
                width: '60px',
                fontSize: '11px',
                fontWeight: '500',
                textAlign: 'right',
                color: state.isLoaded ? 'var(--color-success)' : 
                       state.isLoading ? 'var(--color-primary)' : 'var(--color-text-tertiary)',
              }}>
                {state.isLoaded ? 'Loaded' : 
                 state.isLoading ? `${Math.round(state.progress)}%` : 'Pending'}
              </div>
            </div>
          ))}
        </div>
      </div>
    );
  };

  return (
    <div
      ref={containerRef}
      className={`progressive-loader ${className}`}
      style={{
        position: 'relative',
        minHeight: '200px',
      }}
    >
      {renderLoadingIndicator()}
      
      {renderPriorityVisualization()}
      
      <div className="content-container" style={{
        display: 'flex',
        flexDirection: 'column',
        gap: '24px