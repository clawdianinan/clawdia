/**
 * Drag & Drop Micro-interactions Utility
 * 
 * Implements visual feedback for drag and drop operations with:
 * - Visual preview during drag
 * - Drop zone highlighting
 * - Success confirmation animation
 * - Spatial awareness cues
 */

import { MotionClasses, applyMotionClasses, removeMotionClasses } from '../styles/motion-utils';

/**
 * Drag state interface
 */
export interface DragState {
  isDragging: boolean;
  dragElement: HTMLElement | null;
  dragGhost: HTMLElement | null;
  dropZones: HTMLElement[];
  originalPosition: { x: number; y: number } | null;
}

/**
 * Drag configuration
 */
export interface DragConfig {
  dragHandleSelector?: string;
  dragItemSelector: string;
  dropZoneSelector: string;
  onDragStart?: (element: HTMLElement) => void;
  onDragEnd?: (element: HTMLElement, dropZone: HTMLElement | null) => void;
  onDrop?: (element: HTMLElement, dropZone: HTMLElement) => void;
  ghostOpacity?: number;
  ghostScale?: number;
  highlightColor?: string;
}

/**
 * Drag & Drop Manager
 */
export class DragDropManager {
  private state: DragState = {
    isDragging: false,
    dragElement: null,
    dragGhost: null,
    dropZones: [],
    originalPosition: null,
  };

  private config: DragConfig;
  private isTouchDevice = 'ontouchstart' in window;

  constructor(config: DragConfig) {
    this.config = {
      ghostOpacity: 0.7,
      ghostScale: 0.95,
      highlightColor: 'rgba(59, 130, 246, 0.1)',
      ...config,
    };

    this.initialize();
  }

  /**
   * Initialize drag and drop listeners
   */
  private initialize(): void {
    const dragItems = document.querySelectorAll<HTMLElement>(this.config.dragItemSelector);
    
    dragItems.forEach(item => {
      const dragHandle = this.config.dragHandleSelector 
        ? item.querySelector<HTMLElement>(this.config.dragHandleSelector) || item
        : item;

      this.addDragListeners(dragHandle, item);
    });

    // Initialize drop zones
    this.updateDropZones();
  }

  /**
   * Add drag listeners to an element
   */
  private addDragListeners(dragHandle: HTMLElement, dragItem: HTMLElement): void {
    if (this.isTouchDevice) {
      this.addTouchListeners(dragHandle, dragItem);
    } else {
      this.addMouseListeners(dragHandle, dragItem);
    }
  }

  /**
   * Add mouse-based drag listeners
   */
  private addMouseListeners(dragHandle: HTMLElement, dragItem: HTMLElement): void {
    let isMouseDown = false;
    let startX = 0;
    let startY = 0;

    dragHandle.addEventListener('mousedown', (e) => {
      isMouseDown = true;
      startX = e.clientX;
      startY = e.clientY;

      // Store original position for potential return animation
      const rect = dragItem.getBoundingClientRect();
      this.state.originalPosition = { x: rect.left, y: rect.top };

      // Apply lift effect on mouse down
      applyMotionClasses(dragItem, 'CARD_SPATIAL_LIFT');
    });

    document.addEventListener('mousemove', (e) => {
      if (!isMouseDown) return;

      const deltaX = e.clientX - startX;
      const deltaY = e.clientY - startY;

      // Start dragging after threshold
      if (!this.state.isDragging && (Math.abs(deltaX) > 5 || Math.abs(deltaY) > 5)) {
        this.startDrag(dragItem, e.clientX, e.clientY);
      }

      if (this.state.isDragging && this.state.dragGhost) {
        this.updateGhostPosition(e.clientX, e.clientY);
        this.highlightDropZones(e.clientX, e.clientY);
      }
    });

    document.addEventListener('mouseup', () => {
      if (isMouseDown) {
        isMouseDown = false;
        
        if (this.state.isDragging) {
          this.endDrag();
        } else {
          // If drag didn't start, remove lift effect
          removeMotionClasses(dragItem, 'CARD_SPATIAL_LIFT');
        }
      }
    });
  }

  /**
   * Add touch-based drag listeners
   */
  private addTouchListeners(dragHandle: HTMLElement, dragItem: HTMLElement): void {
    let touchId: number | null = null;
    let startX = 0;
    let startY = 0;

    dragHandle.addEventListener('touchstart', (e) => {
      if (touchId !== null) return; // Ignore multi-touch

      const touch = e.touches[0];
      touchId = touch.identifier;
      startX = touch.clientX;
      startY = touch.clientY;

      // Store original position
      const rect = dragItem.getBoundingClientRect();
      this.state.originalPosition = { x: rect.left, y: rect.top };

      // Apply lift effect
      applyMotionClasses(dragItem, 'CARD_SPATIAL_LIFT');
      e.preventDefault();
    });

    document.addEventListener('touchmove', (e) => {
      if (touchId === null) return;

      const touch = Array.from(e.touches).find(t => t.identifier === touchId);
      if (!touch) return;

      const deltaX = touch.clientX - startX;
      const deltaY = touch.clientY - startY;

      if (!this.state.isDragging && (Math.abs(deltaX) > 10 || Math.abs(deltaY) > 10)) {
        this.startDrag(dragItem, touch.clientX, touch.clientY);
      }

      if (this.state.isDragging && this.state.dragGhost) {
        this.updateGhostPosition(touch.clientX, touch.clientY);
        this.highlightDropZones(touch.clientX, touch.clientY);
      }

      e.preventDefault();
    });

    document.addEventListener('touchend', (e) => {
      if (touchId === null) return;

      const touch = Array.from(e.changedTouches).find(t => t.identifier === touchId);
      if (!touch) return;

      if (this.state.isDragging) {
        this.endDrag();
      } else {
        removeMotionClasses(dragItem, 'CARD_SPATIAL_LIFT');
      }

      touchId = null;
      e.preventDefault();
    });

    document.addEventListener('touchcancel', () => {
      if (this.state.isDragging) {
        this.cancelDrag();
      }
      touchId = null;
    });
  }

  /**
   * Start drag operation
   */
  private startDrag(element: HTMLElement, clientX: number, clientY: number): void {
    this.state.isDragging = true;
    this.state.dragElement = element;

    // Create drag ghost
    this.createDragGhost(element, clientX, clientY);

    // Hide original element
    element.style.opacity = '0.3';

    // Call drag start callback
    if (this.config.onDragStart) {
      this.config.onDragStart(element);
    }

    // Update drop zones
    this.updateDropZones();
  }

  /**
   * Create visual drag ghost
   */
  private createDragGhost(element: HTMLElement, clientX: number, clientY: number): void {
    const ghost = element.cloneNode(true) as HTMLElement;
    ghost.classList.add('drag-ghost');
    
    // Style the ghost
    ghost.style.position = 'fixed';
    ghost.style.zIndex = '9999';
    ghost.style.pointerEvents = 'none';
    ghost.style.opacity = String(this.config.ghostOpacity);
    ghost.style.transform = `scale(${this.config.ghostScale})`;
    ghost.style.transition = 'transform 150ms var(--motion-easing-standard)';
    ghost.style.boxShadow = '0 20px 60px rgba(0, 0, 0, 0.3)';
    ghost.style.borderRadius = '8px';
    
    // Apply GPU acceleration
    applyMotionClasses(ghost, 'GPU_ACCELERATED');

    document.body.appendChild(ghost);
    this.state.dragGhost = ghost;

    // Position ghost
    this.updateGhostPosition(clientX, clientY);
  }

  /**
   * Update ghost position
   */
  private updateGhostPosition(clientX: number, clientY: number): void {
    if (!this.state.dragGhost) return;

    const ghost = this.state.dragGhost;
    const rect = ghost.getBoundingClientRect();

    ghost.style.left = `${clientX - rect.width / 2}px`;
    ghost.style.top = `${clientY - rect.height / 2}px`;

    // Add subtle rotation based on movement
    const rotation = Math.min(Math.max((clientX - window.innerWidth / 2) / 100, -5), 5);
    ghost.style.transform = `scale(${this.config.ghostScale}) rotate(${rotation}deg)`;
  }

  /**
   * Highlight potential drop zones
   */
  private highlightDropZones(clientX: number, clientY: number): void {
    let closestZone: HTMLElement | null = null;
    let closestDistance = Infinity;

    this.state.dropZones.forEach(zone => {
      const rect = zone.getBoundingClientRect();
      const zoneCenterX = rect.left + rect.width / 2;
      const zoneCenterY = rect.top + rect.height / 2;
      
      const distance = Math.sqrt(
        Math.pow(clientX - zoneCenterX, 2) + 
        Math.pow(clientY - zoneCenterY, 2)
      );

      // Remove previous highlight
      zone.classList.remove('drop-zone-highlight');
      zone.style.backgroundColor = '';

      if (distance < closestDistance && distance < 150) {
        closestDistance = distance;
        closestZone = zone;
      }
    });

    // Highlight closest zone
    if (closestZone) {
      closestZone.classList.add('drop-zone-highlight');
      closestZone.style.backgroundColor = this.config.highlightColor || 'rgba(59, 130, 246, 0.1)';
      
      // Add pulse animation
      applyMotionClasses(closestZone, 'VALIDATION_PULSE');
    }
  }

  /**
   * End drag operation
   */
  private endDrag(): void {
    if (!this.state.dragElement || !this.state.dragGhost) return;

    const element = this.state.dragElement;
    const ghost = this.state.dragGhost;

    // Find drop zone
    const dropZone = this.findDropZone(ghost);

    if (dropZone && this.config.onDrop) {
      // Successful drop
      this.config.onDrop(element, dropZone);
      this.showSuccessAnimation(element, dropZone);
    } else {
      // Return to original position
      this.returnToOriginalPosition(element);
    }

    // Cleanup
    this.cleanupDrag();
    
    // Call drag end callback
    if (this.config.onDragEnd) {
      this.config.onDragEnd(element, dropZone);
    }
  }

  /**
   * Find drop zone under ghost
   */
  private findDropZone(ghost: HTMLElement): HTMLElement | null {
    const ghostRect = ghost.getBoundingClientRect();
    const ghostCenterX = ghostRect.left + ghostRect.width / 2;
    const ghostCenterY = ghostRect.top + ghostRect.height / 2;

    for (const zone of this.state.dropZones) {
      const zoneRect = zone.getBoundingClientRect();
      
      if (
        ghostCenterX >= zoneRect.left &&
        ghostCenterX <= zoneRect.right &&
        ghostCenterY >= zoneRect.top &&
        ghostCenterY <= zoneRect.bottom
      ) {
        return zone;
      }
    }

    return null;
  }

  /**
   * Show success animation
   */
  private showSuccessAnimation(element: HTMLElement, dropZone: HTMLElement): void {
    // Show element in new position
    element.style.opacity = '1';
    element.style.transition = 'all 300ms var(--motion-easing-bounce)';
    
    // Apply success animation to drop zone
    applyMotionClasses(dropZone, 'SUCCESS_CHECKMARK');
    
    // Apply celebration to element
    applyMotionClasses(element, 'CELEBRATION_CONFETTI');

    // Remove animation classes after completion
    setTimeout(() => {
      removeMotionClasses(dropZone, 'SUCCESS_CHECKMARK');
      removeMotionClasses(element, 'CELEBRATION_CONFETTI');
      element.style.transition = '';
    }, 1000);
  }

  /**
   * Return element to original position
   */
  private returnToOriginalPosition(element: HTMLElement): void {
    if (!this.state.originalPosition) return;

    element.style.transition = 'all 400ms var(--motion-easing-bounce)';
    element.style.opacity = '1';
    
    // Apply return animation
    applyMotionClasses(element, 'BOUNCE_IN');

    setTimeout(() => {
      removeMotionClasses(element, 'BOUNCE_IN');
      element.style.transition = '';
    }, 400);
  }

  /**
   * Cancel drag operation
   */
  private cancelDrag(): void {
    if (this.state.dragElement) {
      this.returnToOriginalPosition(this.state.dragElement);
    }
    this.cleanupDrag();
  }

  /**
   * Cleanup drag state
   */
  private cleanupDrag(): void {
    // Remove ghost
    if (this.state.dragGhost) {
      this.state.dragGhost.remove();
    }

    // Clear drop zone highlights
    this.state.dropZones.forEach(zone => {
      zone.classList.remove('drop-zone-highlight');
      zone.style.backgroundColor = '';
      removeMotionClasses(zone, 'VALIDATION_PULSE');
    });

    // Reset state
    this.state = {
      isDragging: false,
      dragElement: null,
      dragGhost: null,
      dropZones: [],
      originalPosition: null,
    };
  }

  /**
   * Update drop zones list
   */
  private updateDropZones(): void {
    this.state.dropZones = Array.from(
      document.querySelectorAll<HTMLElement>(this.config.dropZoneSelector)
    );
  }

  /**
   * Refresh drag items and drop zones
   */
  public refresh(): void {
    // Remove all existing listeners
    document.querySelectorAll('.drag-ghost').forEach(ghost => ghost.remove());
    
    // Reinitialize
    this.state = {
      isDragging: false,
      dragElement: null,
      dragGhost: null,
      dropZones: [],
      originalPosition: null,
    };
    
    this.initialize();
  }

  /**
   * Destroy drag and drop manager
   */
  public destroy(): void {
    this.cleanupDrag();
    
    // Remove all drag ghosts
    document.querySelectorAll('.drag-ghost').forEach(ghost => ghost.remove());
    
    // Clear state
    this.state = {
      isDragging: false,
      dragElement: null,
      dragGhost: null,
      dropZones: [],
      originalPosition: null,
    };
  }
}

/**
 * CSS styles for drag and drop
 */
export const dragDropStyles = `
/* Drag Ghost */
.drag-ghost {
  position: fixed;
  z-index: 9999;
  pointer-events: none;
  opacity: 0.7;
  transform: scale(0.95);
  transition: transform 150ms var(--motion-easing-standard);
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  border-radius: 8px;
  filter: brightness(1.1) saturate(1.2);
}

/* Drop Zone Highlight */
.drop-zone-highlight {
  position: relative;
  transition: background-color 200ms var(--motion-easing-standard);
}

.drop-zone-highlight::before {
  content: '';
  position: absolute;
  top: -4px;
  left: -4px;
  right: -4px;
  bottom: -4px;
  border: 2px dashed var(--color-primary);
  border-radius: 12px;
  animation: drop-zone-pulse 2s infinite;
  pointer-events: none;
}

@keyframes drop-zone-pulse {
  0%, 100% {
    opacity: 0.3;
    transform: scale(1);
  }
  50% {
    opacity: 0.7;
    transform: scale(1.02);
  }
}

/* Drag Handle */
.drag-handle {
  cursor: grab;
  touch-action: none;
  user-select: none;
}

.drag-handle:active {
  cursor: grabbing;
}

/* Accessibility */
@media (prefers-reduced-motion: reduce) {
  .drag-ghost {
    transition: none;
    animation: none;
  }
  
  .drop-zone-highlight::before {
    animation: none;
    border-style: solid;
  }
}
`;

/**
 * Initialize drag and drop system
 */
export function initializeDragDropSystem(): void {
  // Add CSS styles
  if (!document.querySelector('#drag-drop-styles')) {
    const style = document.createElement('style');
    style.id = 'drag-drop-styles';
    style.textContent = dragDropStyles;
    document.head.appendChild(style);
  }

  console.log('Drag & Drop Micro-interactions System initialized');
}

// Export default instance creator
export function createDragDrop(config: DragConfig): DragDropManager {
  return new DragDropManager(config);
}