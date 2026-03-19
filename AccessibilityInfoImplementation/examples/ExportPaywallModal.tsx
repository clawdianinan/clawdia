import React from 'react';
import AccessibilityInfo from '../src/components/ui/AccessibilityInfo';

interface ExportPaywallModalProps {
  isOpen: boolean;
  onClose: () => void;
  onUpgrade: () => void;
  exportFormat: 'pdf' | 'docx' | 'markdown';
}

const ExportPaywallModal: React.FC<ExportPaywallModalProps> = ({
  isOpen,
  onClose,
  onUpgrade,
  exportFormat
}) => {
  if (!isOpen) return null;

  const formatInfo = {
    pdf: {
      name: 'PDF',
      description: 'Professional document format suitable for sharing with stakeholders',
      credits: 2
    },
    docx: {
      name: 'Microsoft Word',
      description: 'Editable document format for further customization',
      credits: 2
    },
    markdown: {
      name: 'Markdown',
      description: 'Plain text format with lightweight markup for developers',
      credits: 1
    }
  }[exportFormat];

  return (
    <div className="export-paywall-modal-overlay" role="dialog" aria-modal="true">
      <div className="export-paywall-modal">
        <div className="modal-header">
          <h2 className="modal-title">Export to {formatInfo.name}</h2>
          <button 
            className="modal-close"
            onClick={onClose}
            aria-label="Close modal"
          >
            ×
          </button>
        </div>
        
        <div className="modal-content">
          <div className="export-format-info">
            <div className="format-header">
              <h3>{formatInfo.name} Export</h3>
              <AccessibilityInfo
                elementId={`export-${exportFormat}`}
                docSection={`export/${exportFormat}`}
                tooltipText={formatInfo.description}
              />
            </div>
            
            <p className="format-description">{formatInfo.description}</p>
            
            <div className="credits-required">
              <span className="credits-label">Credits required:</span>
              <span className="credits-value">{formatInfo.credits}</span>
              <AccessibilityInfo
                elementId="export-credits"
                docSection="export/credits"
                tooltipText="Exporting consumes credits from your monthly allowance. Different formats require different amounts of credits."
              />
            </div>
          </div>
          
          <div className="paywall-section">
            <div className="paywall-header">
              <h3 className="paywall-title">Upgrade Required</h3>
              <AccessibilityInfo
                elementId="export-paywall"
                docSection="billing/exports"
                tooltipText="Free tier users have limited export capabilities. Upgrade to unlock all export formats and higher monthly limits."
              />
            </div>
            
            <p className="paywall-message">
              Your current plan doesn't include {formatInfo.name} exports. 
              Upgrade to Pro or Enterprise to unlock this feature.
            </p>
            
            <div className="plan-comparison">
              <div className="plan-feature">
                <span className="feature-name">Free Plan</span>
                <span className="feature-status">❌ Not included</span>
                <AccessibilityInfo
                  elementId="free-plan-exports"
                  docSection="plans/free"
                  tooltipText="Free plan includes basic PRD generation with limited exports. Markdown export is available for free users."
                />
              </div>
              
              <div className="plan-feature">
                <span className="feature-name">Pro Plan</span>
                <span className="feature-status">✅ All formats</span>
                <AccessibilityInfo
                  elementId="pro-plan-exports"
                  docSection="plans/pro"
                  tooltipText="Pro plan includes unlimited exports of all formats (PDF, Word, Markdown) with 50 monthly credits."
                />
              </div>
              
              <div className="plan-feature">
                <span className="feature-name">Enterprise Plan</span>
                <span className="feature-status">✅ All formats + API</span>
                <AccessibilityInfo
                  elementId="enterprise-plan-exports"
                  docSection="plans/enterprise"
                  tooltipText="Enterprise plan includes all export formats, API access, custom templates, and priority support."
                />
              </div>
            </div>
          </div>
        </div>
        
        <div className="modal-footer">
          <button 
            className="btn-secondary"
            onClick={onClose}
          >
            Cancel
          </button>
          
          <div className="upgrade-action">
            <button 
              className="btn-primary"
              onClick={onUpgrade}
            >
              Upgrade Plan
            </button>
            <AccessibilityInfo
              elementId="upgrade-action"
              docSection="billing/upgrade-flow"
              tooltipText="Upgrade now to unlock all export formats. You'll be redirected to the billing page to complete your upgrade."
              className="action-info"
            />
          </div>
        </div>
        
        <div className="modal-help">
          <AccessibilityInfo
            elementId="export-help"
            docSection="help/export"
            tooltipText="Need help with exports? Visit our help center for tutorials, format specifications, and troubleshooting guides."
          />
          <span className="help-text">
            Questions about exports? 
            <button 
              className="help-link"
              onClick={() => window.open('/help/export', '_blank')}
              aria-label="Open export help documentation"
            >
              Visit help center
            </button>
          </span>
        </div>
      </div>
    </div>
  );
};

export default ExportPaywallModal;