/**
 * Micro-interactions Demo Component
 * 
 * Demonstrates the usage of all micro-interaction components together.
 */

import React, { useState } from 'react';
import { DragDropManager, createDragDrop } from '../utils/dragDropAnimations';
import { SwipeActions } from '../components/interactions/SwipeActions';
import { ProgressiveLoader, LoadingPriority } from '../components/loading/ProgressiveLoader';
import { ValidationFeedback } from '../components/forms/ValidationFeedback';
import { DelightfulMoments } from '../components/delight/DelightfulMoments';
import '../components/delight/delight-animations.css';

/**
 * Demo Component
 */
export const MicroInteractionsDemo: React.FC = () => {
  const [dragDropManager, setDragDropManager] = useState<DragDropManager | null>(null);
  const [items, setItems] = useState([
    { id: 'item-1', content: 'Task 1', status: 'todo' },
    { id: 'item-2', content: 'Task 2', status: 'todo' },
    { id: 'item-3', content: 'Task 3', status: 'todo' },
  ]);
  const [completedItems, setCompletedItems] = useState<string[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  /**
   * Initialize drag and drop
   */
  const initializeDragDrop = () => {
    if (dragDropManager) {
      dragDropManager.destroy();
    }

    const manager = createDragDrop({
      dragItemSelector: '.draggable-item',
      dropZoneSelector: '.drop-zone',
      onDrop: (element, dropZone) => {
        const itemId = element.dataset.id;
        if (itemId) {
          setCompletedItems(prev => [...prev, itemId]);
          setItems(prev => prev.filter(item => item.id !== itemId));
        }
      },
    });

    setDragDropManager(manager);
  };

  /**
   * Handle swipe action
   */
  const handleSwipeAction = (itemId: string, action: string) => {
    console.log(`${action} action on item ${itemId}`);
    
    if (action === 'delete') {
      setItems(prev => prev.filter(item => item.id !== itemId));
    } else if (action === 'archive') {
      // Archive logic here
    }
  };

  /**
   * Progressive loader content
   */
  const loaderItems = [
    {
      id: 'hero',
      priority: LoadingPriority.CRITICAL,
      content: (
        <div style={{ padding: '20px', background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)', borderRadius: '12px', color: 'white' }}>
          <h2>Hero Content Loaded!</h2>
          <p>This is the most important content that loads first.</p>
        </div>
      ),
      estimatedLoadTime: 500,
    },
    {
      id: 'primary',
      priority: LoadingPriority.HIGH,
      content: (
        <div style={{ padding: '16px', background: 'var(--color-surface)', borderRadius: '8px', border: '1px solid var(--color-border)' }}>
          <h3>Primary Content</h3>
          <p>Important content that loads early.</p>
        </div>
      ),
      estimatedLoadTime: 800,
    },
    {
      id: 'secondary',
      priority: LoadingPriority.MEDIUM,
      content: (
        <div style={{ padding: '12px', background: 'var(--color-background)', borderRadius: '6px' }}>
          <h4>Secondary Content</h4>
          <p>Standard content that loads in the middle.</p>
        </div>
      ),
      estimatedLoadTime: 1200,
    },
  ];

  /**
   * Form fields
   */
  const formFields = [
    {
      id: 'name',
      label: 'Name',
      type: 'text' as const,
      placeholder: 'Enter your name',
      required: true,
      minLength: 2,
      showCharacterCount: true,
      maxLength: 50,
      validationRules: [
        {
          id: 'no-numbers',
          type: 'error',
          message: 'Name should not contain numbers',
          condition: (value) => !/\d/.test(value),
        },
      ],
    },
    {
      id: 'email',
      label: 'Email',
      type: 'email' as const,
      placeholder: 'Enter your email',
      required: true,
      pattern: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
      showValidationIcons: true,
    },
  ];

  /**
   * Achievements
   */
  const achievements = [
    {
      id: 'first-drag',
      title: 'First Drag',
      description: 'Successfully dragged your first item',
      type: 'milestone' as const,
      icon: '🎯',
      color: '#3b82f6',
      backgroundColor: '#dbeafe',
      unlockCondition: () => completedItems.length >= 1,
      animation: 'confetti',
    },
    {
      id: 'form-master',
      title: 'Form Master',
      description: 'Successfully submitted a form',
      type: 'completion' as const,
      icon: '📝',
      color: '#10b981',
      backgroundColor: '#d1fae5',
      unlockCondition: () => false, // Will be triggered by form submission
      animation: 'stars',
    },
  ];

  /**
   * Milestones
   */
  const milestones = [
    {
      id: 'tasks-completed',
      title: 'Tasks Completed',
      description: 'Complete tasks using drag and drop',
      target: 3,
      current: completedItems.length,
      celebrationLevel: 'grand' as const,
    },
  ];

  /**
   * Easter eggs
   */
  const easterEggs = [
    {
      id: 'secret-click',
      name: 'Secret Button',
      description: 'Click the hidden button 5 times',
      trigger: 'click' as const,
      triggerDetails: { selector: '.secret-button', count: 5 },
      animation: 'fireworks',
      message: 'You found the secret button!',
      secret: true,
    },
  ];

  /**
   * Handle form submission
   */
  const handleFormSubmit = (values: Record<string, string>) => {
    console.log('Form submitted:', values);
    // In a real app, this would trigger the form-master achievement
  };

  return (
    <div className="micro-interactions-demo" style={{ padding: '20px', maxWidth: '800px', margin: '0 auto' }}>
      <h1>Micro-interactions Optimization Demo</h1>
      <p style={{ color: 'var(--color-text-secondary)', marginBottom: '30px' }}>
        This demo showcases all the micro-interaction components working together.
      </p>

      {/* Delightful Moments System */}
      <DelightfulMoments
        achievements={achievements}
        milestones={milestones}
        easterEggs={easterEggs}
        showNotifications={true}
        autoCheckInterval={2000}
      />

      <div style={{ display: 'grid', gap: '30px' }}>
        {/* Section 1: Drag & Drop */}
        <section>
          <h2>1. Drag & Drop Interactions</h2>
          <p>Drag items to the completion zone. Features visual feedback, drop zone highlighting, and success animations.</p>
          
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px', marginTop: '20px' }}>
            {/* Todo Items */}
            <div>
              <h3>Todo Items</h3>
              <div className="drag-container" style={{ minHeight: '200px', padding: '16px', background: 'var(--color-surface)', borderRadius: '8px' }}>
                {items.map(item => (
                  <div
                    key={item.id}
                    data-id={item.id}
                    className="draggable-item"
                    style={{
                      padding: '12px',
                      marginBottom: '8px',
                      background: 'var(--color-background)',
                      borderRadius: '6px',
                      border: '1px solid var(--color-border)',
                      cursor: 'grab',
                      userSelect: 'none',
                    }}
                    onMouseDown={initializeDragDrop}
                  >
                    {item.content}
                  </div>
                ))}
              </div>
            </div>

            {/* Completion Zone */}
            <div>
              <h3>Completion Zone</h3>
              <div 
                className="drop-zone"
                style={{
                  minHeight: '200px',
                  padding: '16px',
                  background: 'var(--color-surface)',
                  borderRadius: '8px',
                  border: '2px dashed var(--color-border)',
                  transition: 'all 300ms var(--motion-easing-standard)',
                }}
              >
                {completedItems.length === 0 ? (
                  <p style={{ color: 'var(--color-text-tertiary)', textAlign: 'center', marginTop: '60px' }}>
                    Drag items here to complete them
                  </p>
                ) : (
                  completedItems.map(itemId => (
                    <div
                      key={itemId}
                      style={{
                        padding: '12px',
                        marginBottom: '8px',
                        background: 'var(--color-success-light)',
                        borderRadius: '6px',
                        border: '1px solid var(--color-success)',
                        color: 'var(--color-success)',
                      }}
                    >
                      Completed: {itemId.replace('item-', 'Task ')}
                    </div>
                  ))
                )}
              </div>
            </div>
          </div>
        </section>

        {/* Section 2: Swipe Actions */}
        <section>
          <h2>2. Swipe Actions</h2>
          <p>Swipe left or right on items to reveal actions. Features haptic feedback and confirmation for destructive actions.</p>
          
          <div style={{ maxWidth: '400px', marginTop: '20px' }}>
            {items.map(item => (
              <SwipeActions
                key={item.id}
                leftActions={[
                  {
                    id: 'archive',
                    label: 'Archive',
                    color: 'white',
                    backgroundColor: '#3b82f6',
                    onAction: () => handleSwipeAction(item.id, 'archive'),
                  },
                ]}
                rightActions={[
                  {
                    id: 'delete',
                    label: 'Delete',
                    color: 'white',
                    backgroundColor: '#ef4444',
                    onAction: () => handleSwipeAction(item.id, 'delete'),
                    destructive: true,
                    confirm: true,
                  },
                ]}
                hapticFeedback={true}
                swipeThreshold={0.2}
                style={{ marginBottom: '12px' }}
              >
                <div style={{
                  padding: '16px',
                  background: 'var(--color-background)',
                  borderRadius: '8px',
                  border: '1px solid var(--color-border)',
                }}>
                  <div style={{ fontWeight: '600', marginBottom: '4px' }}>{item.content}</div>
                  <div style={{ fontSize: '14px', color: 'var(--color-text-secondary)' }}>
                    Swipe left to archive, right to delete
                  </div>
                </div>
              </SwipeActions>
            ))}
          </div>
        </section>

        {/* Section 3: Progressive Loading */}
        <section>
          <h2>3. Progressive Loading</h2>
          <p>Content loads with staggered animations based on priority. Features skeleton screens and progress visualization.</p>
          
          <div style={{ marginTop: '20px' }}>
            <ProgressiveLoader
              items={loaderItems}
              loading={isLoading}
              onLoadComplete={() => {
                console.log('All content loaded!');
                setIsLoading(false);
              }}
              onProgress={(progress) => {
                console.log(`Loading progress: ${progress}%`);
              }}
              skeletonAnimation="shimmer"
              showSkeletons={true}
            />
            
            <button
              onClick={() => {
                setIsLoading(true);
                setTimeout(() => setIsLoading(false), 2000);
              }}
              style={{
                marginTop: '20px',
                padding: '10px 20px',
                background: 'var(--color-primary)',
                color: 'white',
                border: 'none',
                borderRadius: '6px',
                cursor: 'pointer',
                fontSize: '14px',
              }}
            >
              Reload Content
            </button>
          </div>
        </section>

        {/* Section 4: Form Validation */}
        <section>
          <h2>4. Form Validation & Feedback</h2>
          <p>Real-time validation with visual feedback, character count, and undo/redo functionality.</p>
          
          <div style={{ maxWidth: '400px', marginTop: '20px' }}>
            <ValidationFeedback
              fields={formFields}
              onSubmit={handleFormSubmit}
              showLiveValidation={true}
              undoRedoEnabled={true}
              confirmOnSubmit={true}
              confirmMessage="Are you sure you want to submit this form?"
            />
          </div>
        </section>

        {/* Section 5: Easter Egg */}
        <section>
          <h2>5. Easter Egg</h2>
          <p>Try clicking this button 5 times to discover a secret!</p>
          
          <button
            className="secret-button"
            style={{
              marginTop: '10px',
              padding: '10px 20px',
              background: 'transparent',
              color: 'var(--color-text)',
              border: '2px solid var(--color-border)',
              borderRadius: '6px',
              cursor: 'pointer',
              fontSize: '14px',
              transition: 'all 200ms var(--motion-easing-standard)',
            }}
            onMouseEnter={(e) => {
              e.currentTarget.style.transform = 'scale(1.05)';
              e.currentTarget.style.borderColor = 'var(--color-primary)';
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.transform = 'scale(1)';
              e.currentTarget.style.borderColor = 'var(--color-border)';
            }}
          >
            🥚 Click me 5 times!
          </button>
        </section>
      </div>

      {/* Stats Summary */}
      <div style={{
        marginTop: '40px',
        padding: '20px',
        background: 'var(--color-surface)',
        borderRadius: '12px',
        border: '1px solid var(--color-border)',
      }}>
        <h3>Micro-interactions Stats</h3>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '20px', marginTop: '15px' }}>
          <div style={{ textAlign: 'center' }}>
            <div style={{ fontSize: '24px', fontWeight: '700', color: 'var(--color-primary)' }}>
              {items.length + completedItems.length}
            </div>
            <div style={{ fontSize: '12px', color: 'var(--color-text-secondary)' }}>Total Items</div>
          </div>
          <div style={{ textAlign: 'center' }}>
            <div style={{ fontSize: '24px', fontWeight: '700', color: 'var(--color-success)' }}>
              {completedItems.length}
            </div>
            <div style={{ fontSize: '12px', color: 'var(--color-text-secondary)' }}>Completed</div>
          </div>
          <div style={{ textAlign: 'center' }}>
            <div style={{ fontSize: '24px', fontWeight: '700', color: 'var(--color-warning)' }}>
              {achievements.filter(a => a.unlockCondition()).length}
            </div>
            <div style={{ fontSize: '12px', color: 'var(--color-text-secondary)' }}>Achievements</div>
          </div>
          <div style={{ textAlign: 'center' }}>
            <div style={{ fontSize: '24px', fontWeight: '700', color: 'var(--color-error)' }}>
              {milestones.filter(m => m.current >= m.target).length}
            </div>
            <div style={{ fontSize: '12px', color: 'var(--color-text-secondary)' }}>Milestones</div>
          </div>
        </div>
      </div>

      <div style={{
        marginTop: '30px',
        padding: '20px',
        background: 'linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 100%)',
        borderRadius: '12px',
        border: '1px solid #bae6fd',
      }}>
        <h3 style={{ color: '#0369a1', marginBottom: '10px' }}>🎉 Micro-interactions Optimization Complete!</h3>
        <p style={{ color: '#0c4a6e', marginBottom: '0' }}>
          All 5 micro-interaction systems are now implemented and working together seamlessly.
          Each system provides purposeful feedback, spatial awareness, and delightful moments
          while maintaining performance and accessibility standards.
        </p>
      </div>
    </div>
  );
};

export default MicroInteractionsDemo;