import React from 'react';
import AccessibilityInfo from '../src/components/ui/AccessibilityInfo';

interface CreditCounterProps {
  currentCredits: number;
  maxCredits: number;
  onUpgradeClick?: () => void;
}

const CreditCounter: React.FC<CreditCounterProps> = ({
  currentCredits,
  maxCredits,
  onUpgradeClick
}) => {
  const percentage = (currentCredits / maxCredits) * 100;
  
  return (
    <div className="credit-counter-container">
      <div className="credit-counter-header">
        <h3 className="credit-counter-title">Available Credits</h3>
        <AccessibilityInfo
          elementId="credit-counter"
          docSection="usage/credits"
          tooltipText="Credits are used for PRD generation and exports. Free tier includes 10 monthly credits. Upgrade for more credits and advanced features."
        />
      </div>
      
      <div className="credit-counter-display">
        <div className="credit-counter-numbers">
          <span className="current-credits">{currentCredits}</span>
          <span className="credit-separator">/</span>
          <span className="max-credits">{maxCredits}</span>
        </div>
        
        <div className="credit-counter-progress">
          <div 
            className="credit-counter-progress-bar" 
            style={{ width: `${percentage}%` }}
            role="progressbar"
            aria-valuenow={currentCredits}
            aria-valuemin={0}
            aria-valuemax={maxCredits}
          />
        </div>
        
        <div className="credit-counter-actions">
          <button 
            className="upgrade-button"
            onClick={onUpgradeClick}
            aria-label="Upgrade your plan for more credits"
          >
            Upgrade Plan
          </button>
          <AccessibilityInfo
            elementId="credit-upgrade"
            docSection="billing/upgrades"
            tooltipText="Upgrade to get more credits, priority support, and advanced features. Plans start at $29/month."
            className="upgrade-info"
          />
        </div>
      </div>
      
      <div className="credit-counter-footer">
        <p className="credit-counter-hint">
          Credits reset monthly. Unused credits do not roll over.
        </p>
      </div>
    </div>
  );
};

export default CreditCounter;