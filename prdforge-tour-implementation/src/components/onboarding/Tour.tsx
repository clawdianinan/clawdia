import React, { useEffect } from 'react';
import Joyride, { CallBackProps, STATUS, Step } from 'react-joyride';
import { useTour } from './TourProvider';
import '../../styles/tour.css';

interface TourProps {
  continuous?: boolean;
  showProgress?: boolean;
  showSkipButton?: boolean;
  disableCloseOnEsc?: boolean;
  disableOverlayClose?: boolean;
  hideBackButton?: boolean;
}

const Tour: React.FC<TourProps> = ({
  continuous = true,
  showProgress = true,
  showSkipButton = true,
  disableCloseOnEsc = false,
  disableOverlayClose = false,
  hideBackButton = false
}) => {
  const {
    isActive,
    stepIndex,
    steps,
    nextStep,
    prevStep,
    skipTour,
    stopTour,
    progressPercentage
  } = useTour();

  const handleJoyrideCallback = (data: CallBackProps) => {
    const { status, index, type } = data;

    if (type === 'step:after' || status === STATUS.FINISHED) {
      // Step completed or tour finished
      if (status === STATUS.FINISHED) {
        stopTour();
      }
    } else if (status === STATUS.SKIPPED) {
      skipTour();
    } else if (type === 'error:target_not_found') {
      console.warn('Tour target not found:', data.step?.target);
      // Try to continue to next step if target not found
      if (index < steps.length - 1) {
        nextStep();
      } else {
        stopTour();
      }
    }
  };

  // Add data-tour attributes to body when tour is active
  useEffect(() => {
    if (isActive) {
      document.body.setAttribute('data-tour-active', 'true');
    } else {
      document.body.removeAttribute('data-tour-active');
    }

    return () => {
      document.body.removeAttribute('data-tour-active');
    };
  }, [isActive]);

  // Custom tooltip component for better styling
  const renderTooltip = (data: {
    step: Step;
    tooltipProps: any;
    primaryProps: any;
    skipProps: any;
    backProps: any;
    closeProps: any;
    isLastStep: boolean;
  }) => {
    const {
      step,
      tooltipProps,
      primaryProps,
      skipProps,
      backProps,
      isLastStep
    } = data;

    return (
      <div {...tooltipProps} className="custom-tour-tooltip">
        {step.title && (
          <div className="tour-tooltip-header">
            <h3 className="tour-tooltip-title">{step.title}</h3>
            {showProgress && (
              <div className="tour-progress-indicator">
                Step {stepIndex + 1} of {steps.length}
                <div className="tour-progress-bar">
                  <div 
                    className="tour-progress-fill" 
                    style={{ width: `${progressPercentage}%` }}
                  />
                </div>
              </div>
            )}
          </div>
        )}
        
        <div className="tour-tooltip-content">
          {step.content}
        </div>
        
        <div className="tour-tooltip-footer">
          <div className="tour-button-group">
            {!hideBackButton && stepIndex > 0 && (
              <button
                {...backProps}
                className="tour-button tour-button-secondary"
                aria-label="Go to previous step"
              >
                Back
              </button>
            )}
            
            <button
              {...primaryProps}
              className="tour-button tour-button-primary"
              aria-label={isLastStep ? 'Finish tour' : 'Go to next step'}
            >
              {isLastStep ? 'Finish' : 'Next'}
            </button>
          </div>
          
          {showSkipButton && (
            <button
              {...skipProps}
              className="tour-button tour-button-skip"
              aria-label="Skip tour"
            >
              Skip Tour
            </button>
          )}
        </div>
      </div>
    );
  };

  if (!isActive) {
    return null;
  }

  return (
    <>
      <Joyride
        steps={steps}
        run={isActive}
        stepIndex={stepIndex}
        continuous={continuous}
        showProgress={showProgress}
        showSkipButton={showSkipButton}
        disableCloseOnEsc={disableCloseOnEsc}
        disableOverlayClose={disableOverlayClose}
        hideBackButton={hideBackButton}
        callback={handleJoyrideCallback}
        styles={{
          options: {
            arrowColor: '#4f46e5',
            backgroundColor: '#ffffff',
            overlayColor: 'rgba(0, 0, 0, 0.8)',
            primaryColor: '#4f46e5',
            textColor: '#1f2937',
            width: 400,
            zIndex: 10000,
          },
          tooltip: {
            borderRadius: 12,
            padding: 20,
          },
          tooltipContainer: {
            textAlign: 'left',
          },
          buttonNext: {
            backgroundColor: '#4f46e5',
            color: '#ffffff',
            borderRadius: 8,
            padding: '10px 20px',
            fontSize: '14px',
            fontWeight: 600,
          },
          buttonBack: {
            color: '#6b7280',
            fontSize: '14px',
            marginRight: 10,
          },
          buttonSkip: {
            color: '#6b7280',
            fontSize: '14px',
          },
          beacon: {
            inner: '#4f46e5',
            outer: 'rgba(79, 70, 229, 0.3)',
          },
        }}
        floaterProps={{
          disableAnimation: false,
          styles: {
            floater: {
              filter: 'drop-shadow(0 10px 15px rgba(0, 0, 0, 0.2))',
            },
          },
        }}
        locale={{
          back: 'Back',
          close: 'Close',
          last: 'Finish',
          next: 'Next',
          skip: 'Skip',
        }}
        tooltipComponent={renderTooltip}
      />
      
      {/* Welcome Modal for first-time users */}
      {stepIndex === 0 && (
        <div className="tour-welcome-overlay">
          <div className="tour-welcome-modal">
            <div className="tour-welcome-header">
              <h2>Welcome to PRDForge! 🎉</h2>
              <p>Let's take a quick 2-minute tour to show you around</p>
            </div>
            <div className="tour-welcome-content">
              <div className="tour-welcome-features">
                <div className="tour-welcome-feature">
                  <div className="tour-welcome-icon">📋</div>
                  <h4>Create PRDs Fast</h4>
                  <p>Generate professional Product Requirements Documents in minutes</p>
                </div>
                <div className="tour-welcome-feature">
                  <div className="tour-welcome-icon">🎯</div>
                  <h4>AI-Powered</h4>
                  <p>Smart templates and AI assistance for better results</p>
                </div>
                <div className="tour-welcome-feature">
                  <div className="tour-welcome-icon">🚀</div>
                  <h4>Get Started Quickly</h4>
                  <p>Simple workflow from idea to finished document</p>
                </div>
              </div>
            </div>
            <div className="tour-welcome-footer">
              <button
                onClick={skipTour}
                className="tour-button tour-button-secondary"
              >
                Skip Tour
              </button>
              <button
                onClick={nextStep}
                className="tour-button tour-button-primary"
              >
                Start Tour (2 min)
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default Tour;