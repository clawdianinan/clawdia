import React, { useState, useEffect } from 'react';
import { TourProvider, useTour } from './src/components/onboarding/TourProvider';
import Tour from './src/components/onboarding/Tour';
import './src/styles/tour.css';

// Example dashboard component with tour targets
const Dashboard: React.FC = () => {
  const { startTour, hasCompleted, restartTour } = useTour();
  const [userSignedUp, setUserSignedUp] = useState(false);

  // Simulate user signup - in real app, this would be after successful signup
  useEffect(() => {
    const timer = setTimeout(() => {
      setUserSignedUp(true);
    }, 1000);
    
    return () => clearTimeout(timer);
  }, []);

  // Auto-start tour after signup if not completed
  useEffect(() => {
    if (userSignedUp && !hasCompleted) {
      const timer = setTimeout(() => {
        startTour();
      }, 500);
      
      return () => clearTimeout(timer);
    }
  }, [userSignedUp, hasCompleted, startTour]);

  return (
    <div className="app-container">
      <header className="app-header">
        <h1>PRDForge</h1>
        <div className="header-actions">
          <div className="credit-counter" data-tour="credit-counter">
            <span className="credit-label">Credits:</span>
            <span className="credit-value">10</span>
            <span className="credit-info">/month</span>
          </div>
          <button className="upgrade-button" data-tour="upgrade-cta">
            Upgrade
          </button>
        </div>
      </header>

      <main className="app-main">
        <div className="dashboard-welcome" data-tour="dashboard">
          <h2>Welcome to PRDForge!</h2>
          <p>Create professional Product Requirements Documents in minutes</p>
        </div>

        <div className="dashboard-actions">
          <button 
            className="create-prd-button" 
            data-tour="create-prd-button"
            onClick={() => alert('Create PRD clicked!')}
          >
            Create New PRD
          </button>
          
          <input
            type="text"
            className="idea-input"
            data-tour="idea-input"
            placeholder="Describe your app idea..."
          />
        </div>

        <div className="templates-section" data-tour="templates-section">
          <h3>Templates</h3>
          <div className="templates-grid" data-tour="templates">
            <div className="template-card">
              <h4>SaaS Application</h4>
              <p>Complete template for software-as-a-service products</p>
            </div>
            <div className="template-card">
              <h4>Mobile App</h4>
              <p>Template for iOS and Android applications</p>
            </div>
            <div className="template-card">
              <h4>Web Platform</h4>
              <p>Template for web-based platforms and dashboards</p>
            </div>
            <div className="template-card">
              <h4>Enterprise Software</h4>
              <p>Template for large-scale enterprise systems</p>
            </div>
          </div>
        </div>

        <div className="tour-controls">
          {hasCompleted ? (
            <button onClick={restartTour} className="restart-tour-button">
              Restart Tour
            </button>
          ) : (
            <button onClick={startTour} className="start-tour-button">
              Take Tour
            </button>
          )}
          <div className="tour-status">
            {hasCompleted ? 'Tour completed' : 'Tour available'}
          </div>
        </div>
      </main>

      {/* Upgrade Modal (hidden by default) */}
      <div className="upgrade-modal" data-tour="upgrade-modal" style={{ display: 'none' }}>
        <div className="upgrade-modal-content">
          <h3>Upgrade to Premium</h3>
          <p>Get unlimited credits, advanced AI models, and team features.</p>
          <button onClick={() => document.querySelector('[data-tour="upgrade-modal"]')!.style.display = 'none'}>
            Close
          </button>
        </div>
      </div>
    </div>
  );
};

// Main App component with TourProvider
const App: React.FC = () => {
  const [showWelcome, setShowWelcome] = useState(true);

  const handleTourStart = () => {
    console.log('Tour started');
    // Analytics: track tour start
  };

  const handleTourComplete = () => {
    console.log('Tour completed');
    // Analytics: track tour completion
    // Show success message or next steps
  };

  const handleTourSkip = () => {
    console.log('Tour skipped');
    // Analytics: track tour skip
  };

  return (
    <TourProvider
      autoStart={false} // Set to true to auto-start on page load
      onTourStart={handleTourStart}
      onTourComplete={handleTourComplete}
      onTourSkip={handleTourSkip}
    >
      {showWelcome ? (
        <div className="welcome-screen">
          <div className="welcome-content">
            <h1>Welcome to PRDForge</h1>
            <p>Your AI-powered PRD creation platform</p>
            <button 
              onClick={() => setShowWelcome(false)}
              className="get-started-button"
            >
              Get Started
            </button>
          </div>
        </div>
      ) : (
        <>
          <Dashboard />
          <Tour 
            continuous={true}
            showProgress={true}
            showSkipButton={true}
            disableCloseOnEsc={false}
            disableOverlayClose={false}
            hideBackButton={false}
          />
        </>
      )}
    </TourProvider>
  );
};

// Example styles for the demo app
const demoStyles = `
.app-container {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.app-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 0;
  border-bottom: 1px solid #e5e7eb;
  margin-bottom: 40px;
}

.app-header h1 {
  margin: 0;
  color: #4f46e5;
  font-size: 24px;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 20px;
}

.credit-counter {
  background: #f3f4f6;
  padding: 8px 16px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
}

.credit-label {
  color: #6b7280;
}

.credit-value {
  font-weight: 600;
  color: #1f2937;
  font-size: 16px;
}

.credit-info {
  color: #9ca3af;
  font-size: 12px;
}

.upgrade-button {
  background: linear-gradient(135deg, #4f46e5, #7c3aed);
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
}

.upgrade-button:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 6px -1px rgba(79, 70, 229, 0.2);
}

.dashboard-welcome {
  text-align: center;
  margin-bottom: 40px;
  padding: 40px;
  background: linear-gradient(135deg, #f3f4f6, #e5e7eb);
  border-radius: 16px;
}

.dashboard-welcome h2 {
  margin: 0 0 12px 0;
  color: #1f2937;
  font-size: 32px;
}

.dashboard-welcome p {
  margin: 0;
  color: #6b7280;
  font-size: 18px;
}

.dashboard-actions {
  display: flex;
  flex-direction: column;
  gap: 20px;
  margin-bottom: 40px;
  align-items: center;
}

.create-prd-button {
  background: #10b981;
  color: white;
  border: none;
  padding: 16px 32px;
  border-radius: 12px;
  font-size: 18px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
  min-width: 300px;
}

.create-prd-button:hover {
  background: #059669;
  transform: translateY(-2px);
  box-shadow: 0 10px 15px -3px rgba(16, 185, 129, 0.2);
}

.idea-input {
  width: 100%;
  max-width: 500px;
  padding: 16px;
  border: 2px solid #e5e7eb;
  border-radius: 12px;
  font-size: 16px;
  transition: all 0.2s ease;
}

.idea-input:focus {
  outline: none;
  border-color: #4f46e5;
  box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
}

.templates-section {
  margin-bottom: 40px;
}

.templates-section h3 {
  margin: 0 0 20px 0;
  color: #1f2937;
  font-size: 24px;
}

.templates-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
}

.template-card {
  background: white;
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  padding: 24px;
  transition: all 0.2s ease;
  cursor: pointer;
}

.template-card:hover {
  transform: translateY(-4px);
  border-color: #4f46e5;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
}

.template-card h4 {
  margin: 0 0 8px 0;
  color: #1f2937;
  font-size: 18px;
}

.template-card p {
  margin: 0;
  color: #6b7280;
  font-size: 14px;
  line-height: 1.5;
}

.tour-controls {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 20px;
  margin-top: 40px;
  padding: 20px;
  background: #f9fafb;
  border-radius: 12px;
}

.start-tour-button,
.restart-tour-button {
  background: #4f46e5;
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 8px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
}

.start-tour-button:hover,
.restart-tour-button:hover {
  background: #4338ca;
  transform: translateY(-1px);
}

.tour-status {
  color: #6b7280;
  font-size: 14px;
}

.upgrade-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.upgrade-modal-content {
  background: white;
  padding: 32px;
  border-radius: 16px;
  max-width: 400px;
  width: 90%;
  text-align: center;
}

.upgrade-modal-content h3 {
  margin: 0 0 16px 0;
  color: #1f2937;
}

.upgrade-modal-content p {
  margin: 0 0 24px 0;
  color: #6b7280;
}

.upgrade-modal-content button {
  background: #4f46e5;
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 8px;
  cursor: pointer;
}

.welcome-screen {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, #4f46e5, #7c3aed);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.welcome-content {
  text-align: center;
  padding: 40px;
}

.welcome-content h1 {
  font-size: 48px;
  margin: 0 0 16px 0;
}

.welcome-content p {
  font-size: 20px;
  margin: 0 0 32px 0;
  opacity: 0.9;
}

.get-started-button {
  background: white;
  color: #4f46e5;
  border: none;
  padding: 16px 32px;
  border-radius: 12px;
  font-size: 18px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
}

.get-started-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
}

@media (max-width: 768px) {
  .app-header {
    flex-direction: column;
    gap: 16px;
    text-align: center;
  }
  
  .dashboard-welcome {
    padding: 24px;
  }
  
  .dashboard-welcome h2 {
    font-size: 24px;
  }
  
  .dashboard-welcome p {
    font-size: 16px;
  }
  
  .create-prd-button {
    min-width: auto;
    width: 100%;
  }
  
  .templates-grid {
    grid-template-columns: 1fr;
  }
  
  .tour-controls {
    flex-direction: column;
    text-align: center;
  }
  
  .welcome-content h1 {
    font-size: 32px;
  }
  
  .welcome-content p {
    font-size: 16px;
  }
}
`;

// Add styles to document
if (typeof document !== 'undefined') {
  const style = document.createElement('style');
  style.textContent = demoStyles;
  document.head.appendChild(style);
}

export default App;