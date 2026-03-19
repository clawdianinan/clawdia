import { Step } from 'react-joyride';

export interface TourStep extends Step {
  action?: () => void;
}

export const tourSteps: TourStep[] = [
  {
    target: '[data-tour="dashboard"]',
    title: 'Welcome to PRDForge! 🎉',
    content: 'Create professional Product Requirements Documents in minutes. Let\'s get started with a quick tour of the key features.',
    placement: 'center' as const,
    disableBeacon: true,
    spotlightPadding: 10,
  },
  {
    target: '[data-tour="create-prd-button"]',
    title: 'Create Your First PRD',
    content: 'Click here to start creating your Product Requirements Document. Describe your app idea and AI will generate a complete PRD with sections, tasks, and timeline.',
    placement: 'right' as const,
    spotlightPadding: 8,
    action: () => {
      // Optional: Pre-fill example idea
      const ideaInput = document.querySelector('[data-tour="idea-input"]') as HTMLInputElement;
      if (ideaInput) {
        ideaInput.value = 'A project management tool for remote teams';
      }
    }
  },
  {
    target: '[data-tour="credit-counter"]',
    title: 'How Credits Work',
    content: 'Each PRD generation uses credits. Your free tier includes 10 credits monthly. Upgrade to premium plans for more credits and advanced features.',
    placement: 'left' as const,
    spotlightPadding: 8,
  },
  {
    target: '[data-tour="templates"]',
    title: 'Start with Templates',
    content: 'Browse our library of proven templates for different project types: SaaS applications, mobile apps, web platforms, and more. Templates help you get started faster.',
    placement: 'top' as const,
    spotlightPadding: 8,
    action: () => {
      // Optional: Open template selector
      const templateSection = document.querySelector('[data-tour="templates-section"]');
      if (templateSection) {
        templateSection.scrollIntoView({ behavior: 'smooth' });
      }
    }
  },
  {
    target: '[data-tour="upgrade-cta"]',
    title: 'Ready for More?',
    content: 'Upgrade to premium for advanced AI models, team collaboration features, unlimited exports, and priority support. Start with our 14-day free trial.',
    placement: 'bottom' as const,
    spotlightPadding: 8,
    action: () => {
      // Optional: Show upgrade modal (subtle, not pushy)
      const upgradeModal = document.querySelector('[data-tour="upgrade-modal"]');
      if (upgradeModal) {
        (upgradeModal as HTMLElement).style.display = 'block';
      }
    }
  }
];

// Tour progress storage keys
export const TOUR_STORAGE_KEYS = {
  COMPLETED: 'prdforge_tour_completed',
  STEP_INDEX: 'prdforge_tour_step_index',
  STARTED: 'prdforge_tour_started'
};

// Check if user has completed tour
export const hasCompletedTour = (): boolean => {
  if (typeof window === 'undefined') return false;
  return localStorage.getItem(TOUR_STORAGE_KEYS.COMPLETED) === 'true';
};

// Save tour progress
export const saveTourProgress = (stepIndex: number, completed: boolean = false): void => {
  if (typeof window === 'undefined') return;
  
  localStorage.setItem(TOUR_STORAGE_KEYS.STEP_INDEX, stepIndex.toString());
  if (completed) {
    localStorage.setItem(TOUR_STORAGE_KEYS.COMPLETED, 'true');
  }
};

// Get saved tour progress
export const getSavedTourProgress = (): number => {
  if (typeof window === 'undefined') return 0;
  
  const savedIndex = localStorage.getItem(TOUR_STORAGE_KEYS.STEP_INDEX);
  return savedIndex ? parseInt(savedIndex, 10) : 0;
};

// Mark tour as started
export const markTourStarted = (): void => {
  if (typeof window === 'undefined') return;
  localStorage.setItem(TOUR_STORAGE_KEYS.STARTED, 'true');
};

// Check if tour was started
export const wasTourStarted = (): boolean => {
  if (typeof window === 'undefined') return false;
  return localStorage.getItem(TOUR_STORAGE_KEYS.STARTED) === 'true';
};

// Reset tour progress (for testing or user restart)
export const resetTourProgress = (): void => {
  if (typeof window === 'undefined') return;
  
  localStorage.removeItem(TOUR_STORAGE_KEYS.COMPLETED);
  localStorage.removeItem(TOUR_STORAGE_KEYS.STEP_INDEX);
  localStorage.removeItem(TOUR_STORAGE_KEYS.STARTED);
};