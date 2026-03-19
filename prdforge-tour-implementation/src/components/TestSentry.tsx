import React from 'react';
import { initializeErrorTracking, testErrorReporting, reportError } from '../utils/errorTracking';

const TestSentry: React.FC = () => {
  const handleInitialize = async () => {
    await initializeErrorTracking();
    alert('Sentry initialized! Check console for details.');
  };

  const handleTestError = () => {
    testErrorReporting();
    alert('Test error sent to Sentry!');
  };

  const handleManualError = () => {
    try {
      throw new Error('Manual test error from button click');
    } catch (error) {
      reportError(error as Error, { source: 'manual-test', component: 'TestSentry' });
      alert('Manual error reported to Sentry!');
    }
  };

  const handleUserFeedback = () => {
    // In a real app, you would capture the event ID from an actual error
    const eventId = 'test-event-' + Date.now();
    const email = 'test@example.com';
    const comments = 'This is a test feedback from the Sentry integration test';
    
    // This would normally be called after an error is captured
    alert(`User feedback prepared for event: ${eventId}\nEmail: ${email}\nComments: ${comments}`);
  };

  return (
    <div style={{ padding: '20px', fontFamily: 'Arial, sans-serif' }}>
      <h2>Sentry Integration Test</h2>
      <p>Test the Sentry error tracking integration with the following buttons:</p>
      
      <div style={{ display: 'flex', flexDirection: 'column', gap: '10px', maxWidth: '300px' }}>
        <button 
          onClick={handleInitialize}
          style={{ padding: '10px', backgroundColor: '#4CAF50', color: 'white', border: 'none', borderRadius: '4px' }}
        >
          Initialize Sentry
        </button>
        
        <button 
          onClick={handleTestError}
          style={{ padding: '10px', backgroundColor: '#2196F3', color: 'white', border: 'none', borderRadius: '4px' }}
        >
          Send Test Error
        </button>
        
        <button 
          onClick={handleManualError}
          style={{ padding: '10px', backgroundColor: '#FF9800', color: 'white', border: 'none', borderRadius: '4px' }}
        >
          Send Manual Error
        </button>
        
        <button 
          onClick={handleUserFeedback}
          style={{ padding: '10px', backgroundColor: '#9C27B0', color: 'white', border: 'none', borderRadius: '4px' }}
        >
          Test User Feedback
        </button>
      </div>
      
      <div style={{ marginTop: '20px', padding: '15px', backgroundColor: '#f5f5f5', borderRadius: '4px' }}>
        <h3>Environment Variables:</h3>
        <ul>
          <li><strong>VITE_SENTRY_DSN:</strong> {import.meta.env.VITE_SENTRY_DSN ? 'Set ✓' : 'Not set ✗'}</li>
          <li><strong>VITE_SENTRY_ENVIRONMENT:</strong> {import.meta.env.VITE_SENTRY_ENVIRONMENT || 'Not set'}</li>
          <li><strong>VITE_SENTRY_RELEASE:</strong> {import.meta.env.VITE_SENTRY_RELEASE || 'Not set'}</li>
        </ul>
      </div>
    </div>
  );
};

export default TestSentry;