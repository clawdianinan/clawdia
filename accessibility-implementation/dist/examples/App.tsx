/**
 * Example React App with Accessibility Implementation
 */

import React, { useState, useEffect, useRef } from 'react';
import {
  initializeAccessibility,
  AccessibilityMenu,
  useKeyboardNavigation,
  announcePRDProgress,
  announceSuccess,
  announceError,
  setupFormField,
  showFormFieldError,
  clearFormFieldError,
  validateForm,
  generateAltText,
  trapFocus,
} from '../src/index';
import '../src/styles/accessibility.css';

// Initialize accessibility on app load
initializeAccessibility();

const App: React.FC = () => {
  const [prdProgress, setPrdProgress] = useState(0);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const modalRef = useRef<HTMLDivElement>(null);
  
  // Setup keyboard navigation
  const { showKeyboardShortcuts, setupFocusTrap } = useKeyboardNavigation({
    enableShortcuts: true,
    enableFocusTraps: true,
    enableArrowNavigation: true,
    shortcuts: [
      {
        key: 'k',
        ctrlKey: true,
        description: 'Open keyboard shortcuts',
        action: showKeyboardShortcuts,
      },
    ],
  });

  // Setup form fields on mount
  useEffect(() => {
    setupFormField('prd-title', 'PRD Title', true);
    setupFormField('prd-description', 'PRD Description', true);
  }, []);

  // Handle modal focus trap
  useEffect(() => {
    if (isModalOpen && modalRef.current) {
      const cleanup = setupFocusTrap(modalRef.current);
      return cleanup;
    }
  }, [isModalOpen, setupFocusTrap]);

  // Simulate PRD generation
  const simulatePRDGeneration = () => {
    setPrdProgress(0);
    
    const steps = 5;
    let currentStep = 0;
    
    const interval = setInterval(() => {
      currentStep++;
      setPrdProgress((currentStep / steps) * 100);
      
      // Announce progress to screen readers
      announcePRDProgress(currentStep, steps);
      
      if (currentStep >= steps) {
        clearInterval(interval);
        announceSuccess('PRD generation completed successfully!');
      }
    }, 1000);
  };

  // Handle form submission
  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    if (validateForm('prd-form')) {
      announceSuccess('PRD saved successfully!');
      // Submit form logic here
    } else {
      showFormFieldError('prd-title', 'Title is required');
    }
  };

  // Generate alt text for example image
  const exampleAltText = generateAltText(
    'chart',
    'user growth over the past 12 months',
    'Shows a steady increase from 1,000 to 10,000 active users'
  );

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Skip to content link is automatically added by initializeAccessibility() */}
      
      <header className="bg-white shadow" role="banner">
        <div className="max-w-7xl mx-auto px-4 py-6">
          <div className="flex justify-between items-center">
            <h1 className="text-3xl font-bold text-gray-900">PRDForge</h1>
            <div className="flex items-center space-x-4">
              <button
                onClick={showKeyboardShortcuts}
                className="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                aria-label="Show keyboard shortcuts (press ?)"
              >
                Keyboard Shortcuts (?)
              </button>
              <button
                onClick={() => setIsModalOpen(true)}
                className="px-4 py-2 text-sm font-medium text-white bg-indigo-600 rounded-md hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
              >
                Create New PRD
              </button>
            </div>
          </div>
        </div>
      </header>

      <main id="main-content" className="max-w-7xl mx-auto px-4 py-8" role="main">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Left column - Form */}
          <div className="lg:col-span-2">
            <div className="bg-white shadow rounded-lg p-6">
              <h2 className="text-2xl font-bold text-gray-900 mb-6">Create Product Requirements Document</h2>
              
              <form id="prd-form" onSubmit={handleSubmit}>
                <div className="space-y-6">
                  <div>
                    <label htmlFor="prd-title" className="block text-sm font-medium text-gray-700 mb-2">
                      PRD Title *
                    </label>
                    <input
                      id="prd-title"
                      type="text"
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
                      placeholder="Enter PRD title"
                      onChange={() => clearFormFieldError('prd-title')}
                    />
                  </div>
                  
                  <div>
                    <label htmlFor="prd-description" className="block text-sm font-medium text-gray-700 mb-2">
                      Description *
                    </label>
                    <textarea
                      id="prd-description"
                      rows={4}
                      className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
                      placeholder="Describe your product requirements..."
                      onChange={() => clearFormFieldError('prd-description')}
                    />
                  </div>
                  
                  <div>
                    <button
                      type="submit"
                      className="px-4 py-2 text-sm font-medium text-white bg-indigo-600 rounded-md hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                    >
                      Save PRD
                    </button>
                    
                    <button
                      type="button"
                      onClick={simulatePRDGeneration}
                      className="ml-4 px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500"
                    >
                      Generate with AI
                    </button>
                  </div>
                </div>
              </form>
              
              {/* Progress indicator */}
              {prdProgress > 0 && (
                <div className="mt-6">
                  <div className="flex justify-between mb-2">
                    <span className="text-sm font-medium text-gray-700">Generating PRD...</span>
                    <span className="text-sm font-medium text-gray-700">{prdProgress.toFixed(0)}%</span>
                  </div>
                  <div className="w-full bg-gray-200 rounded-full h-2">
                    <div
                      className="bg-indigo-600 h-2 rounded-full transition-all duration-300"
                      style={{ width: `${prdProgress}%` }}
                      role="progressbar"
                      aria-valuenow={prdProgress}
                      aria-valuemin={0}
                      aria-valuemax={100}
                    />
                  </div>
                </div>
              )}
            </div>
          </div>
          
          {/* Right column - Accessibility demo */}
          <div>
            <div className="bg-white shadow rounded-lg p-6">
              <h2 className="text-2xl font-bold text-gray-900 mb-6">Accessibility Features</h2>
              
              <div className="space-y-6">
                <div>
                  <h3 className="text-lg font-medium text-gray-900 mb-3">Screen Reader Demo</h3>
                  <div className="space-y-3">
                    <button
                      onClick={() => announceSuccess('Demo announcement sent to screen readers')}
                      className="w-full px-4 py-2 text-sm font-medium text-white bg-green-600 rounded-md hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
                    >
                      Send Success Announcement
                    </button>
                    
                    <button
                      onClick={() => announceError('Demo error sent to screen readers')}
                      className="w-full px-4 py-2 text-sm font-medium text-white bg-red-600 rounded-md hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
                    >
                      Send Error Announcement
                    </button>
                  </div>
                </div>
                
                <div>
                  <h3 className="text-lg font-medium text-gray-900 mb-3">Image Alt Text Generation</h3>
                  <div className="bg-gray-50 p-4 rounded-md">
                    <p className="text-sm text-gray-600 mb-2">Generated alt text for chart:</p>
                    <p className="text-sm font-medium text-gray-900">{exampleAltText}</p>
                  </div>
                </div>
                
                <div>
                  <h3 className="text-lg font-medium text-gray-900 mb-3">Keyboard Navigation</h3>
                  <ul className="space-y-2 text-sm text-gray-600">
                    <li>• Press <kbd className="px-2 py-1 bg-gray-100 rounded border">Tab</kbd> to navigate</li>
                    <li>• Press <kbd className="px-2 py-1 bg-gray-100 rounded border">Shift</kbd> + <kbd className="px-2 py-1 bg-gray-100 rounded border">Tab</kbd> to navigate back</li>
                    <li>• Press <kbd className="px-2 py-1 bg-gray-100 rounded border">?</kbd> for all shortcuts</li>
                    <li>• Press <kbd className="px-2 py-1 bg-gray-100 rounded border">Esc</kbd> to close modals</li>
                  </ul>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>

      {/* Modal Dialog */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div
            ref={modalRef}
            role="dialog"
            aria-modal="true"
            aria-label="Create new PRD"
            className="bg-white rounded-lg shadow-xl w-full max-w-md"
          >
            <div className="p-6">
              <div className="flex justify-between items-center mb-6">
                <h3 className="text-lg font-medium text-gray-900">Create New PRD</h3>
                <button
                  onClick={() => setIsModalOpen(false)}
                  className="text-gray-400 hover:text-gray-600 focus:outline-none"
                  aria-label="Close dialog"
                >
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>
              
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Template
                  </label>
                  <select className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500">
                    <option>Standard PRD</option>
                    <option>Feature Specification</option>
                    <option>MVP Requirements</option>
                  </select>
                </div>
                
                <div className="flex justify-end space-x-3 pt-4">
                  <button
                    onClick={() => setIsModalOpen(false)}
                    className="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500"
                  >
                    Cancel
                  </button>
                  <button
                    onClick={() => {
                      setIsModalOpen(false);
                      announceSuccess('New PRD created');
                    }}
                    className="px-4 py-2 text-sm font-medium text-white bg-indigo-600 rounded-md hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                  >
                    Create
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Accessibility Menu (floating button) */}
      <AccessibilityMenu position="bottom-right" />
      
      <footer className="bg-white shadow mt-8" role="contentinfo">
        <div className="max-w-7xl mx-auto px-4 py-6">
          <p className="text-center text-gray-500 text-sm">
            PRDForge - Accessible Product Requirements Documentation
          </p>
        </div>
      </footer>
    </div>
  );
};

export default App;