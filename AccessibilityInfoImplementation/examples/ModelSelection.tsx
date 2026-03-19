import React, { useState } from 'react';
import AccessibilityInfo from '../src/components/ui/AccessibilityInfo';

interface ModelOption {
  id: string;
  name: string;
  description: string;
  tier: 'free' | 'pro' | 'enterprise';
  creditsPerUse: number;
}

const ModelSelection: React.FC = () => {
  const [selectedModel, setSelectedModel] = useState<string>('gpt-4');
  
  const models: ModelOption[] = [
    {
      id: 'gpt-3.5',
      name: 'GPT-3.5 Turbo',
      description: 'Fast and cost-effective for simple PRDs',
      tier: 'free',
      creditsPerUse: 1
    },
    {
      id: 'gpt-4',
      name: 'GPT-4',
      description: 'High quality with better reasoning for complex projects',
      tier: 'pro',
      creditsPerUse: 3
    },
    {
      id: 'claude-3',
      name: 'Claude 3 Opus',
      description: 'Excellent for technical documentation and detailed specifications',
      tier: 'enterprise',
      creditsPerUse: 5
    }
  ];

  return (
    <div className="model-selection-container">
      <div className="model-selection-header">
        <h3 className="model-selection-title">AI Model Selection</h3>
        <AccessibilityInfo
          elementId="model-selection"
          docSection="ai/models"
          tooltipText="Choose the AI model that best fits your needs. Higher-tier models provide better quality but use more credits per generation."
        />
      </div>
      
      <div className="model-selection-grid">
        {models.map((model) => (
          <div 
            key={model.id}
            className={`model-option ${selectedModel === model.id ? 'selected' : ''} ${model.tier}`}
            onClick={() => setSelectedModel(model.id)}
            role="radio"
            aria-checked={selectedModel === model.id}
            tabIndex={0}
            onKeyDown={(e) => {
              if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                setSelectedModel(model.id);
              }
            }}
          >
            <div className="model-option-header">
              <div className="model-option-name">
                <h4>{model.name}</h4>
                <span className={`model-tier-badge ${model.tier}`}>
                  {model.tier.charAt(0).toUpperCase() + model.tier.slice(1)}
                </span>
              </div>
              <AccessibilityInfo
                elementId={`model-${model.id}`}
                docSection={`ai/models/${model.id}`}
                tooltipText={`${model.description}. Uses ${model.creditsPerUse} credit${model.creditsPerUse !== 1 ? 's' : ''} per generation.`}
                className="model-info"
              />
            </div>
            
            <p className="model-description">{model.description}</p>
            
            <div className="model-option-footer">
              <div className="model-credits">
                <span className="credits-label">Credits:</span>
                <span className="credits-value">{model.creditsPerUse} per use</span>
              </div>
              
              {model.tier !== 'free' && (
                <div className="model-upgrade-note">
                  <AccessibilityInfo
                    elementId={`model-upgrade-${model.id}`}
                    docSection="billing/tiers"
                    tooltipText={`${model.tier.charAt(0).toUpperCase() + model.tier.slice(1)} tier required. Upgrade your plan to access this model.`}
                    className="upgrade-info"
                  />
                  <span className="upgrade-text">Upgrade required</span>
                </div>
              )}
            </div>
          </div>
        ))}
      </div>
      
      <div className="model-selection-footer">
        <div className="credits-explanation">
          <AccessibilityInfo
            elementId="credits-explanation"
            docSection="usage/credits"
            tooltipText="Credits are consumed based on the model you select. Higher quality models use more credits but produce better results."
          />
          <span className="explanation-text">
            Higher quality models consume more credits per generation.
          </span>
        </div>
      </div>
    </div>
  );
};

export default ModelSelection;