import React, { useState, useRef, useEffect } from 'react';
import './AccessibilityInfo.css';

interface AccessibilityInfoProps {
  elementId: string;
  docSection: string;
  tooltipText: string;
  className?: string;
}

const AccessibilityInfo: React.FC<AccessibilityInfoProps> = ({
  elementId,
  docSection,
  tooltipText,
  className = ''
}) => {
  const [isTooltipVisible, setIsTooltipVisible] = useState(false);
  const [tooltipPosition, setTooltipPosition] = useState<'top' | 'bottom' | 'left' | 'right'>('top');
  const tooltipRef = useRef<HTMLDivElement>(null);
  const buttonRef = useRef<HTMLButtonElement>(null);

  const handleMouseEnter = () => {
    setIsTooltipVisible(true);
    updateTooltipPosition();
  };

  const handleMouseLeave = () => {
    setIsTooltipVisible(false);
  };

  const handleClick = () => {
    // Open documentation in new tab
    window.open(`/docs#${docSection}`, '_blank', 'noopener,noreferrer');
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      handleClick();
    }
  };

  const updateTooltipPosition = () => {
    if (!buttonRef.current || !tooltipRef.current) return;

    const buttonRect = buttonRef.current.getBoundingClientRect();
    const viewportHeight = window.innerHeight;
    const viewportWidth = window.innerWidth;

    // Default to top, adjust if near viewport edges
    let position: 'top' | 'bottom' | 'left' | 'right' = 'top';

    if (buttonRect.top < 100) {
      position = 'bottom';
    } else if (buttonRect.left < 100) {
      position = 'right';
    } else if (viewportWidth - buttonRect.right < 100) {
      position = 'left';
    } else if (viewportHeight - buttonRect.bottom < 100) {
      position = 'top';
    }

    setTooltipPosition(position);
  };

  useEffect(() => {
    const handleResize = () => {
      if (isTooltipVisible) {
        updateTooltipPosition();
      }
    };

    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, [isTooltipVisible]);

  return (
    <div className={`accessibility-info-container ${className}`}>
      <button
        ref={buttonRef}
        className="accessibility-info-button"
        aria-label={`Information about ${elementId}. Press Enter to open documentation.`}
        aria-describedby={`tooltip-${elementId}`}
        onMouseEnter={handleMouseEnter}
        onMouseLeave={handleMouseLeave}
        onFocus={handleMouseEnter}
        onBlur={handleMouseLeave}
        onClick={handleClick}
        onKeyDown={handleKeyDown}
        tabIndex={0}
      >
        <span className="accessibility-info-icon" aria-hidden="true">?</span>
      </button>

      {isTooltipVisible && (
        <div
          ref={tooltipRef}
          id={`tooltip-${elementId}`}
          className={`accessibility-info-tooltip tooltip-${tooltipPosition}`}
          role="tooltip"
        >
          <div className="tooltip-content">
            {tooltipText}
            <div className="tooltip-hint">
              Click to open detailed documentation in a new tab.
            </div>
          </div>
          <div className={`tooltip-arrow arrow-${tooltipPosition}`} />
        </div>
      )}
    </div>
  );
};

export default AccessibilityInfo;