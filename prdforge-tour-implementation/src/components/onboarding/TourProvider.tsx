import React, { createContext, useContext, useState, useCallback, ReactNode } from 'react';
import { tourSteps, TourStep, saveTourProgress, getSavedTourProgress, markTourStarted, hasCompletedTour, resetTourProgress } from '../../data/tourSteps';

interface TourContextType {
  isActive: boolean;
  stepIndex: number;
  steps: TourStep[];
  startTour: () => void;
  stopTour: () => void;
  nextStep: () => void;
  prevStep: () => void;
  skipTour: () => void;
  restartTour: () => void;
  hasCompleted: boolean;
  progressPercentage: number;
}

const TourContext = createContext<TourContextType | undefined>(undefined);

interface TourProviderProps {
  children: ReactNode;
  autoStart?: boolean;
  onTourStart?: () => void;
  onTourComplete?: () => void;
  onTourSkip?: () => void;
}

export const TourProvider: React.FC<TourProviderProps> = ({ 
  children, 
  autoStart = false,
  onTourStart,
  onTourComplete,
  onTourSkip
}) => {
  const [isActive, setIsActive] = useState(false);
  const [stepIndex, setStepIndex] = useState(getSavedTourProgress());
  const [hasCompleted, setHasCompleted] = useState(hasCompletedTour());
  
  const steps = tourSteps;
  const totalSteps = steps.length;
  const progressPercentage = totalSteps > 0 ? Math.round(((stepIndex + 1) / totalSteps) * 100) : 0;

  const startTour = useCallback(() => {
    if (hasCompleted && !confirm('You\'ve already completed the tour. Would you like to take it again?')) {
      return;
    }
    
    setIsActive(true);
    setStepIndex(0);
    markTourStarted();
    saveTourProgress(0);
    
    // Analytics event
    if (typeof window !== 'undefined' && (window as any).gtag) {
      (window as any).gtag('event', 'tour_started', {
        event_category: 'onboarding',
        event_label: 'intro_tour'
      });
    }
    
    onTourStart?.();
  }, [hasCompleted, onTourStart]);

  const stopTour = useCallback(() => {
    setIsActive(false);
    
    // Analytics event
    if (typeof window !== 'undefined' && (window as any).gtag) {
      (window as any).gtag('event', 'tour_stopped', {
        event_category: 'onboarding',
        event_label: 'intro_tour',
        value: stepIndex
      });
    }
  }, [stepIndex]);

  const nextStep = useCallback(() => {
    if (stepIndex < totalSteps - 1) {
      const nextIndex = stepIndex + 1;
      setStepIndex(nextIndex);
      saveTourProgress(nextIndex);
      
      // Execute step action if defined
      const currentStep = steps[stepIndex];
      if (currentStep.action) {
        currentStep.action();
      }
      
      // Analytics event
      if (typeof window !== 'undefined' && (window as any).gtag) {
        (window as any).gtag('event', 'tour_step_completed', {
          event_category: 'onboarding',
          event_label: `step_${stepIndex + 1}`,
          value: stepIndex + 1
        });
      }
    } else {
      // Tour completed
      setIsActive(false);
      setHasCompleted(true);
      saveTourProgress(totalSteps - 1, true);
      
      // Analytics event
      if (typeof window !== 'undefined' && (window as any).gtag) {
        (window as any).gtag('event', 'tour_completed', {
          event_category: 'onboarding',
          event_label: 'intro_tour',
          value: totalSteps
        });
      }
      
      onTourComplete?.();
    }
  }, [stepIndex, totalSteps, steps, onTourComplete]);

  const prevStep = useCallback(() => {
    if (stepIndex > 0) {
      const prevIndex = stepIndex - 1;
      setStepIndex(prevIndex);
      saveTourProgress(prevIndex);
    }
  }, [stepIndex]);

  const skipTour = useCallback(() => {
    setIsActive(false);
    
    // Analytics event
    if (typeof window !== 'undefined' && (window as any).gtag) {
      (window as any).gtag('event', 'tour_skipped', {
        event_category: 'onboarding',
        event_label: 'intro_tour',
        value: stepIndex
      });
    }
    
    onTourSkip?.();
  }, [stepIndex, onTourSkip]);

  const restartTour = useCallback(() => {
    resetTourProgress();
    setHasCompleted(false);
    setStepIndex(0);
    setIsActive(true);
    markTourStarted();
    saveTourProgress(0);
    
    // Analytics event
    if (typeof window !== 'undefined' && (window as any).gtag) {
      (window as any).gtag('event', 'tour_restarted', {
        event_category: 'onboarding',
        event_label: 'intro_tour'
      });
    }
  }, []);

  // Auto-start tour if configured and user hasn't completed it
  React.useEffect(() => {
    if (autoStart && !hasCompleted && !isActive) {
      const timer = setTimeout(() => {
        startTour();
      }, 1000); // Delay to ensure page is fully loaded
      
      return () => clearTimeout(timer);
    }
  }, [autoStart, hasCompleted, isActive, startTour]);

  const value: TourContextType = {
    isActive,
    stepIndex,
    steps,
    startTour,
    stopTour,
    nextStep,
    prevStep,
    skipTour,
    restartTour,
    hasCompleted,
    progressPercentage
  };

  return (
    <TourContext.Provider value={value}>
      {children}
    </TourContext.Provider>
  );
};

export const useTour = (): TourContextType => {
  const context = useContext(TourContext);
  if (context === undefined) {
    throw new Error('useTour must be used within a TourProvider');
  }
  return context;
};