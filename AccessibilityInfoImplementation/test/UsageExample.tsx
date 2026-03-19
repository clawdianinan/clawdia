import React from 'react';
import AccessibilityInfo from '../src/components/ui/AccessibilityInfo';

const UsageExample: React.FC = () => {
  return (
    <div className="usage-example">
      <h1>Accessibility Info Buttons - Usage Examples</h1>
      
      <section className="example-section">
        <h2>1. Credit Counter Example</h2>
        <div className="example-container">
          <div className="credit-display">
            <span className="credit-label">Credits: 5/10</span>
            <AccessibilityInfo
              elementId="example-credit-counter"
              docSection="usage/credits"
              tooltipText="Credits are used for PRD generation and exports. Free tier includes 10 monthly credits. Upgrade for more credits and advanced features."
            />
          </div>
          <p className="example-note">Hover over the ? button to see tooltip, click to open documentation.</p>
        </div>
      </section>
      
      <section className="example-section">
        <h2>2. Model Selection Example</h2>
        <div className="example-container">
          <div className="model-option">
            <span className="model-name">GPT-4</span>
            <AccessibilityInfo
              elementId="example-model-gpt4"
              docSection="ai/models/gpt-4"
              tooltipText="High quality AI model with better reasoning for complex projects. Uses 3 credits per generation. Pro tier required."
            />
          </div>
          <p className="example-note">Each model can have its own info button with specific documentation.</p>
        </div>
      </section>
      
      <section className="example-section">
        <h2>3. Export Format Example</h2>
        <div className="example-container">
          <div className="export-option">
            <button className="export-button">Export as PDF</button>
            <AccessibilityInfo
              elementId="example-export-pdf"
              docSection="export/pdf"
              tooltipText="PDF format provides professional formatting suitable for sharing with stakeholders. Requires 2 credits per export."
            />
          </div>
          <p className="example-note">Info buttons work well beside action buttons to explain requirements.</p>
        </div>
      </section>
      
      <section className="example-section">
        <h2>4. Keyboard Navigation Test</h2>
        <div className="example-container">
          <p>Try navigating using only keyboard:</p>
          <ol>
            <li>Press Tab to focus on the button below</li>
            <li>Press Enter or Space to activate</li>
            <li>Notice focus styles and tooltip behavior</li>
          </ol>
          <div className="keyboard-test">
            <span>Test Element</span>
            <AccessibilityInfo
              elementId="keyboard-test"
              docSection="help/keyboard"
              tooltipText="This component is fully keyboard accessible. Use Tab to navigate, Enter or Space to activate."
            />
          </div>
        </div>
      </section>
      
      <section className="example-section">
        <h2>5. Mobile Touch Test</h2>
        <div className="example-container">
          <p>On touch devices:</p>
          <ul>
            <li>Touch to show tooltip immediately</li>
            <li>Tap again to open documentation</li>
            <li>Large 44px touch target for easy interaction</li>
          </ul>
          <div className="mobile-test">
            <span>Mobile Element</span>
            <AccessibilityInfo
              elementId="mobile-test"
              docSection="help/mobile"
              tooltipText="Optimized for touch devices with larger tap targets and immediate feedback."
            />
          </div>
        </div>
      </section>
      
      <div className="implementation-notes">
        <h3>Implementation Notes</h3>
        <ul>
          <li><strong>Tooltip Text:</strong> Keep concise (2-3 sentences maximum)</li>
          <li><strong>Documentation Links:</strong> Use consistent docSection format</li>
          <li><strong>Accessibility:</strong> All ARIA attributes are automatically set</li>
          <li><strong>Performance:</strong> Efficient rendering with minimal reflows</li>
          <li><strong>Browser Support:</strong> Works in all modern browsers</li>
        </ul>
      </div>
    </div>
  );
};

export default UsageExample;