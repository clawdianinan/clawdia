/**
 * Performance Testing Automation
 * 
 * Baseline performance metrics for completed improvements:
 * - Load time impact of new features
 * - Animation performance (60fps verification)
 * - Memory usage and garbage collection
 * - CPU utilization during interactions
 */

import { describe, it, expect, beforeAll, afterAll, vi } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

// Performance monitoring utilities
import { PerformanceMonitor } from '@/utils/performance/monitor';
import { AnimationBenchmark } from '@/utils/performance/animation';
import { MemoryProfiler } from '@/utils/performance/memory';

// Components to test
import { MotionProvider } from '@/components/motion/MotionProvider';
import AccessibilityInfo from '@/components/ui/AccessibilityInfo';
import Tour from '@/components/onboarding/Tour';
import { DragDropManager } from '@/utils/dragDropAnimations';
import { SwipeActions } from '@/components/interactions/SwipeActions';
import { ProgressiveLoader } from '@/components/loading/ProgressiveLoader';

describe('Performance Test Suite - System Metrics', () => {
  let performanceMonitor: PerformanceMonitor;
  let animationBenchmark: AnimationBenchmark;
  let memoryProfiler: MemoryProfiler;

  beforeAll(() => {
    performanceMonitor = new PerformanceMonitor();
    animationBenchmark = new AnimationBenchmark();
    memoryProfiler = new MemoryProfiler();
    
    // Start monitoring
    performanceMonitor.startSession('performance-test-suite');
    memoryProfiler.startSnapshot();
  });

  afterAll(() => {
    // Stop monitoring and generate report
    performanceMonitor.endSession();
    memoryProfiler.endSnapshot();
    
    const report = performanceMonitor.generateReport();
    expect(report.passed).toBe(true);
  });

  describe('1. Load Time Performance', () => {
    it('should load accessibility components within performance budget', async () => {
      const loadStart = performance.now();
      
      render(
        <AccessibilityInfo
          elementId="performance-test"
          docSection="performance/baseline"
          tooltipText="Performance test tooltip"
        />
      );
      
      const loadEnd = performance.now();
      const loadTime = loadEnd - loadStart;
      
      // Performance budget: 100ms for initial render
      expect(loadTime).toBeLessThan(100);
      
      // Record metric
      performanceMonitor.recordMetric('accessibility-load-time', loadTime);
    });

    it('should load motion provider within performance budget', async () => {
      const loadStart = performance.now();
      
      render(
        <MotionProvider>
          <div>Test Content</div>
        </MotionProvider>
      );
      
      const loadEnd = performance.now();
      const loadTime = loadEnd - loadStart;
      
      // Performance budget: 150ms for motion system
      expect(loadTime).toBeLessThan(150);
      
      performanceMonitor.recordMetric('motion-provider-load-time', loadTime);
    });

    it('should load tour component within performance budget', async () => {
      const loadStart = performance.now();
      
      render(
        <Tour
          steps={[
            {
              target: '[data-tour="step-1"]',
              content: 'First step',
              placement: 'bottom' as const
            }
          ]}
          run={false}
        />
      );
      
      const loadEnd = performance.now();
      const loadTime = loadEnd - loadStart;
      
      // Performance budget: 200ms for tour system
      expect(loadTime).toBeLessThan(200);
      
      performanceMonitor.recordMetric('tour-load-time', loadTime);
    });

    it('should have acceptable bundle size impact', () => {
      const bundleMetrics = {
        accessibility: getBundleSize('accessibility'),
        motion: getBundleSize('motion'),
        tour: getBundleSize('tour'),
        microInteractions: getBundleSize('micro-interactions'),
        security: getBundleSize('security')
      };
      
      // Individual component budgets
      expect(bundleMetrics.accessibility).toBeLessThan(50 * 1024); // 50KB
      expect(bundleMetrics.motion).toBeLessThan(100 * 1024); // 100KB
      expect(bundleMetrics.tour).toBeLessThan(150 * 1024); // 150KB
      expect(bundleMetrics.microInteractions).toBeLessThan(200 * 1024); // 200KB
      expect(bundleMetrics.security).toBeLessThan(250 * 1024); // 250KB
      
      // Total impact budget (gzipped)
      const totalSize = Object.values(bundleMetrics).reduce((a, b) => a + b, 0);
      const gzippedSize = totalSize * 0.3; // Assume 70% gzip compression
      
      expect(gzippedSize).toBeLessThan(300 * 1024); // 300KB gzipped total
      
      performanceMonitor.recordMetric('total-bundle-size', totalSize);
      performanceMonitor.recordMetric('gzipped-bundle-size', gzippedSize);
    });
  });

  describe('2. Animation Performance (60fps Verification)', () => {
    it('should maintain 60fps during drag-drop animations', async () => {
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
      
      // Start animation benchmark
      const benchmark = await animationBenchmark.start('drag-drop-animation');
      
      // Perform drag operation
      fireEvent.mouseDown(draggable);
      
      // Animate drag movement
      for (let i = 0; i < 60; i++) {
        fireEvent.mouseMove(draggable, {
          clientX: i * 5,
          clientY: i * 5
        });
        await new Promise(resolve => requestAnimationFrame(resolve));
      }
      
      fireEvent.mouseUp(draggable);
      
      // End benchmark and get results
      const results = await benchmark.end();
      
      // Verify 60fps performance
      expect(results.averageFps).toBeGreaterThan(55); // Allow small margin
      expect(results.droppedFrames).toBeLessThan(5); // Max 5 dropped frames
      expect(results.jankPercentage).toBeLessThan(5); // Max 5% jank
      
      performanceMonitor.recordMetric('drag-drop-fps', results.averageFps);
      performanceMonitor.recordMetric('drag-drop-dropped-frames', results.droppedFrames);
    });

    it('should maintain 60fps during swipe animations', async () => {
      render(
        <MotionProvider>
          <SwipeActions
            leftActions={[
              {
                id: 'archive',
                label: 'Archive',
                color: 'white',
                backgroundColor: '#3b82f6',
                onAction: vi.fn()
              }
            ]}
          >
            <div data-testid="swipe-item" style={{ width: '300px', height: '100px' }}>
              Swipe Item
            </div>
          </SwipeActions>
        </MotionProvider>
      );
      
      const swipeItem = screen.getByTestId('swipe-item');
      
      // Start animation benchmark
      const benchmark = await animationBenchmark.start('swipe-animation');
      
      // Perform swipe gesture
      fireEvent.touchStart(swipeItem, {
        touches: [{ clientX: 300, clientY: 50 }]
      });
      
      // Animate swipe
      for (let i = 0; i < 30; i++) {
        fireEvent.touchMove(swipeItem, {
          touches: [{ clientX: 300 - (i * 10), clientY: 50 }]
        });
        await new Promise(resolve => requestAnimationFrame(resolve));
      }
      
      fireEvent.touchEnd(swipeItem);
      
      // End benchmark
      const results = await benchmark.end();
      
      // Verify performance
      expect(results.averageFps).toBeGreaterThan(55);
      expect(results.droppedFrames).toBeLessThan(3);
      expect(results.jankPercentage).toBeLessThan(3);
      
      performanceMonitor.recordMetric('swipe-fps', results.averageFps);
    });

    it('should maintain 60fps during loading animations', async () => {
      render(
        <MotionProvider>
          <ProgressiveLoader
            items={Array(10).fill(0).map((_, i) => `Item ${i + 1}`)}
            loading={true}
            skeletonAnimation="shimmer"
          />
        </MotionProvider>
      );
      
      // Start benchmark
      const benchmark = await animationBenchmark.start('loading-animation');
      
      // Wait for loading animation cycle
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      // End benchmark
      const results = await benchmark.end();
      
      // Verify performance
      expect(results.averageFps).toBeGreaterThan(55);
      expect(results.droppedFrames).toBeLessThan(5);
      
      performanceMonitor.recordMetric('loading-fps', results.averageFps);
    });

    it('should respect reduced motion preferences for performance', async () => {
      // Mock reduced motion preference
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
      
      render(
        <MotionProvider>
          <div className="motion-fade-in">Test Content</div>
        </MotionProvider>
      );
      
      const element = screen.getByText('Test Content');
      
      // With reduced motion, animations should be disabled
      expect(element).toHaveStyle('animation-duration: 0ms');
      expect(element).toHaveStyle('transition-duration: 0ms');
      
      // Record performance benefit
      const withoutAnimation = performance.now();
      // Trigger some interaction
      fireEvent.click(element);
      const afterInteraction = performance.now();
      
      const interactionTime = afterInteraction - withoutAnimation;
      expect(interactionTime).toBeLessThan(50); // Should be very fast without animations
      
      performanceMonitor.recordMetric('reduced-motion-interaction-time', interactionTime);
    });
  });

  describe('3. Memory Usage Optimization', () => {
    it('should not cause memory leaks in accessibility components', async () => {
      const initialMemory = memoryProfiler.getHeapUsage();
      
      // Render and unmount multiple times
      for (let i = 0; i < 10; i++) {
        const { unmount } = render(
          <AccessibilityInfo
            elementId={`test-${i}`}
            docSection="test"
            tooltipText="Test tooltip"
          />
        );
        
        // Interact with component
        const button = screen.getByRole('button');
        fireEvent.mouseEnter(button);
        fireEvent.click(button);
        
        // Unmount
        unmount();
        
        // Force garbage collection
        if (global.gc) global.gc();
      }
      
      const finalMemory = memoryProfiler.getHeapUsage();
      const memoryIncrease = finalMemory - initialMemory;
      
      // Allow small increase but check for leaks
      expect(memoryIncrease).toBeLessThan(5 * 1024 * 1024); // 5MB max increase
      
      performanceMonitor.recordMetric('accessibility-memory-delta', memoryIncrease);
    });

    it('should not cause memory leaks in motion system', async () => {
      const initialMemory = memoryProfiler.getHeapUsage();
      
      for (let i = 0; i < 5; i++) {
        const { unmount } = render(
          <MotionProvider>
            <div className={`motion-test-${i}`}>
              Test Content {i}
            </div>
          </MotionProvider>
        );
        
        // Trigger animations
        const element = screen.getByText(`Test Content ${i}`);
        fireEvent.mouseEnter(element);
        fireEvent.mouseLeave(element);
        
        unmount();
        if (global.gc) global.gc();
      }
      
      const finalMemory = memoryProfiler.getHeapUsage();
      const memoryIncrease = finalMemory - initialMemory;
      
      expect(memoryIncrease).toBeLessThan(10 * 1024 * 1024); // 10MB max for motion system
      
      performanceMonitor.recordMetric('motion-memory-delta', memoryIncrease);
    });

    it('should efficiently manage event listeners', () => {
      // Test that event listeners are properly cleaned up
      const initialListenerCount = getEventListenerCount();
      
      const { unmount } = render(
        <MotionProvider>
          <AccessibilityInfo
            elementId="listener-test"
            docSection="test"
            tooltipText="Test"
          />
          <SwipeActions
            leftActions={[{ id: 'test', label: 'Test', onAction: vi.fn() }]}
          >
            <div>Swipe Test</div>
          </SwipeActions>
        </MotionProvider>
      );
      
      const duringRenderCount = getEventListenerCount();
      const listenersAdded = duringRenderCount - initialListenerCount;
      
      // Should add reasonable number of listeners
      expect(listenersAdded).toBeLessThan(20);
      
      // Unmount and check cleanup
      unmount();
      if (global.gc) global.gc();
      
      const finalListenerCount = getEventListenerCount();
      const listenersRemaining = finalListenerCount - initialListenerCount;
      
      // Should clean up all listeners
      expect(listenersRemaining).toBeLessThan(5);
      
      performanceMonitor.recordMetric('event-listeners-added', listenersAdded);
      performanceMonitor.recordMetric('event-listeners-remaining', listenersRemaining);
    });

    it('should have efficient garbage collection patterns', async () => {
      // Test memory usage over time with repeated interactions
      const memorySnapshots: number[] = [];
      
      for (let cycle = 0; cycle < 3; cycle++) {
        memoryProfiler.startSnapshot(`cycle-${cycle}`);
        
        const { unmount } = render(
          <MotionProvider>
            <ProgressiveLoader
              items={Array(50).fill(0).map((_, i) => `Item ${i}`)}
              loading={true}
              skeletonAnimation="shimmer"
            />
          </MotionProvider>
        );
        
        // Simulate loading completion
        await new Promise(resolve => setTimeout(resolve, 100));
        
        unmount();
        
        const snapshot = memoryProfiler.endSnapshot();
        memorySnapshots.push(snapshot.heapUsed);
        
        if (global.gc) global.gc();
      }
      
      // Check that memory doesn't continuously increase
      const memoryIncrease = memorySnapshots[2] - memorySnapshots[0];
      expect(memoryIncrease).toBeLessThan(20 * 1024 * 1024); // 20MB max over 3 cycles
      
      performanceMonitor.recordMetric('gc-memory-increase', memoryIncrease);
    });
  });

  describe('4. CPU Utilization Optimization', () => {
    it('should have low CPU usage during idle state', async () => {
      const cpuMonitor = performanceMonitor.startCpuMonitoring();
      
      // Render components but don't interact
      render(
        <MotionProvider>
          <AccessibilityInfo
            elementId="cpu-test"
            docSection="test"
            tooltipText="Test"
          />
          <div className="motion-fade-in">Idle Content</div>
        </MotionProvider>
      );
      
      // Wait for stabilization
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      const cpuUsage = cpuMonitor.getAverageUsage();
      
      // Should have very low CPU usage when idle
      expect(cpuUsage).toBeLessThan(5); // Less than 5% CPU usage
      
      performanceMonitor.recordMetric('idle-cpu-usage', cpuUsage);
    });

    it('should have reasonable CPU usage during animations', async () => {
      const cpuMonitor = performanceMonitor.startCpuMonitoring();
      
      render(
        <MotionProvider>
          <div 
            data-testid="animated-element"
            className="motion-complex-animation"
            style={{ width: '100px', height: '100px', background: 'blue' }}
          >
            Animated
          </div>
        </MotionProvider>
      );
      
      const element = screen.getByTestId('animated-element');
      
      // Trigger complex animation
      fireEvent.mouseEnter(element);
      
      // Measure CPU during animation
      await new Promise(resolve => setTimeout(resolve, 500));
      
      const cpuUsage = cpuMonitor.getAverageUsage();
      
      // Complex animations should use reasonable CPU
      expect(cpuUsage).toBeLessThan(30); // Less than 30% CPU during animation
      
      performanceMonitor.recordMetric('animation-cpu-usage', cpuUsage);
    });

    it('should have efficient CPU usage for micro-interactions', async () => {
      const cpuMonitor = performanceMonitor.startCpuMonitoring();
      
      render(
        <MotionProvider>
          <SwipeActions
            leftActions={[
              { id: 'action1', label: 'Action 1', onAction: vi.fn() },
              { id: 'action2', label: 'Action 2', onAction: vi.fn() }
            ]}
            rightActions={[
              { id: 'action3', label: 'Action 3', onAction: vi.fn() }
            ]}
          >
            <div data-testid="swipe-target" style={{ width: '300px', height: '80px' }}>
              Swipe for Actions
            </div>
          </SwipeActions>
        </MotionProvider>
      );
      
      const target = screen.getByTestId('swipe-target');
      
      // Perform multiple swipe interactions
      for (let i = 0; i < 10; i++) {
        fireEvent.touchStart(target, { touches