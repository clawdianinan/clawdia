/**
 * DarkModeExample Component
 * 
 * Demonstrates the dark mode improvements with:
 * - Theme toggle
 * - Image optimization
 * - Color contrast examples
 * - Code block styling
 */

import React from 'react';
import { useDarkMode, ThemeToggle } from '../../hooks/useDarkMode';
import { DarkModeImage } from '../media/DarkModeImage';
import { checkContrast } from '../../utils/colorContrast';

/**
 * DarkModeExample component
 */
export const DarkModeExample: React.FC = () => {
  const { isDarkMode, theme } = useDarkMode();
  
  // Example colors for contrast testing
  const exampleColors = {
    textOnBackground: checkContrast('#ffffff', '#12141a'),
    primaryOnBackground: checkContrast('#ff5c5c', '#12141a'),
    mutedOnBackground: checkContrast('#71717a', '#12141a'),
  };

  return (
    <div className="dark-mode-example" style={{ padding: '2rem', maxWidth: '800px', margin: '0 auto' }}>
      <header style={{ marginBottom: '2rem' }}>
        <h1 style={{ fontSize: '2rem', fontWeight: 'bold', marginBottom: '1rem' }}>
          Dark Mode Polish Demo
        </h1>
        <p style={{ color: 'var(--muted-foreground)', marginBottom: '1.5rem' }}>
          Demonstrating enhanced dark mode with true black optimization, WCAG compliance, and improved legibility.
        </p>
        
        <div style={{ display: 'flex', alignItems: 'center', gap: '1rem', marginBottom: '2rem' }}>
          <ThemeToggle size="lg" showLabels />
          <span style={{ color: 'var(--muted-foreground)' }}>
            Current theme: <strong>{theme === 'system' ? 'System' : isDarkMode ? 'Dark' : 'Light'}</strong>
          </span>
        </div>
      </header>

      <section style={{ marginBottom: '3rem' }}>
        <h2 style={{ fontSize: '1.5rem', fontWeight: '600', marginBottom: '1rem' }}>
          Color Contrast Compliance
        </h2>
        
        <div style={{ 
          display: 'grid', 
          gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', 
          gap: '1rem',
          marginBottom: '2rem'
        }}>
          {Object.entries(exampleColors).map(([key, result]) => (
            <div 
              key={key}
              style={{
                padding: '1rem',
                borderRadius: '8px',
                backgroundColor: 'var(--card)',
                border: '1px solid var(--border)',
              }}
            >
              <div style={{ 
                display: 'flex', 
                alignItems: 'center', 
                justifyContent: 'space-between',
                marginBottom: '0.5rem'
              }}>
                <span style={{ fontWeight: '500' }}>{key.replace(/([A-Z])/g, ' $1')}</span>
                <span style={{
                  padding: '0.25rem 0.5rem',
                  borderRadius: '4px',
                  backgroundColor: result.score === 'fail' ? 'var(--destructive-subtle)' : 
                                 result.score === 'AAA' ? 'var(--success-subtle)' : 'var(--info-subtle)',
                  color: result.score === 'fail' ? 'var(--destructive)' : 
                         result.score === 'AAA' ? 'var(--success)' : 'var(--info)',
                  fontSize: '0.75rem',
                  fontWeight: '600',
                }}>
                  {result.score} ({result.ratio}:1)
                </span>
              </div>
              <div style={{ fontSize: '0.875rem', color: 'var(--muted-foreground)' }}>
                {result.meetsAA ? '✓ Meets WCAG AA' : '✗ Fails WCAG AA'}
                {result.meetsAAA && ' • ✓ Meets WCAG AAA'}
              </div>
            </div>
          ))}
        </div>
      </section>

      <section style={{ marginBottom: '3rem' }}>
        <h2 style={{ fontSize: '1.5rem', fontWeight: '600', marginBottom: '1rem' }}>
          Image Optimization
        </h2>
        
        <div style={{ marginBottom: '2rem' }}>
          <p style={{ color: 'var(--muted-foreground)', marginBottom: '1rem' }}>
            Images are automatically optimized for dark mode with brightness and contrast adjustments.
            Hover to see the difference.
          </p>
          
          <div style={{ 
            display: 'grid', 
            gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', 
            gap: '1.5rem'
          }}>
            <div>
              <h3 style={{ fontSize: '1rem', fontWeight: '500', marginBottom: '0.5rem' }}>
                With Dark Mode Filter
              </h3>
              <DarkModeImage
                src="https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=600&h=400&fit=crop"
                alt="Example landscape with dark mode filter"
                applyDarkFilter={true}
                style={{ borderRadius: '8px', height: '200px' }}
              />
            </div>
            
            <div>
              <h3 style={{ fontSize: '1rem', fontWeight: '500', marginBottom: '0.5rem' }}>
                Without Dark Mode Filter
              </h3>
              <DarkModeImage
                src="https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=600&h=400&fit=crop"
                alt="Example landscape without dark mode filter"
                applyDarkFilter={false}
                style={{ borderRadius: '8px', height: '200px' }}
              />
            </div>
          </div>
        </div>
      </section>

      <section style={{ marginBottom: '3rem' }}>
        <h2 style={{ fontSize: '1.5rem', fontWeight: '600', marginBottom: '1rem' }}>
          Code Block Styling
        </h2>
        
        <pre style={{ 
          backgroundColor: 'var(--code-background)',
          border: '1px solid var(--border)',
          borderRadius: '8px',
          padding: '1rem',
          overflowX: 'auto',
          fontSize: '0.875rem',
          lineHeight: '1.5',
        }}>
          <code>{`// Example TypeScript code with syntax highlighting
interface User {
  id: string;
  name: string;
  email: string;
  preferences: {
    theme: 'light' | 'dark' | 'system';
    notifications: boolean;
  };
}

function getUserTheme(user: User): string {
  if (user.preferences.theme === 'system') {
    return window.matchMedia('(prefers-color-scheme: dark)').matches 
      ? 'dark' 
      : 'light';
  }
  return user.preferences.theme;
}

// Dark mode optimized colors
const darkTheme = {
  background: 'hsl(240 10% 8%)',
  foreground: 'hsl(0 0% 98%)',
  primary: 'hsl(230 75% 65%)',
  border: 'hsl(240 5% 26%)',
};`}</code>
        </pre>
      </section>

      <section style={{ marginBottom: '3rem' }}>
        <h2 style={{ fontSize: '1.5rem', fontWeight: '600', marginBottom: '1rem' }}>
          Form Elements
        </h2>
        
        <div style={{ 
          display: 'grid', 
          gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', 
          gap: '1.5rem'
        }}>
          <div>
            <label style={{ display: 'block', marginBottom: '0.5rem', fontWeight: '500' }}>
              Text Input
            </label>
            <input
              type="text"
              placeholder="Enter your name"
              style={{
                width: '100%',
                padding: '0.75rem',
                borderRadius: '6px',
                border: '1px solid var(--border)',
                backgroundColor: 'var(--input)',
                color: 'var(--foreground)',
              }}
            />
          </div>
          
          <div>
            <label style={{ display: 'block', marginBottom: '0.5rem', fontWeight: '500' }}>
              Select
            </label>
            <select
              style={{
                width: '100%',
                padding: '0.75rem',
                borderRadius: '6px',
                border: '1px solid var(--border)',
                backgroundColor: 'var(--input)',
                color: 'var(--foreground)',
              }}
            >
              <option value="">Choose an option</option>
              <option value="light">Light Theme</option>
              <option value="dark">Dark Theme</option>
              <option value="system">System Preference</option>
            </select>
          </div>
          
          <div>
            <label style={{ display: 'block', marginBottom: '0.5rem', fontWeight: '500' }}>
              Button
            </label>
            <button
              style={{
                width: '100%',
                padding: '0.75rem 1.5rem',
                borderRadius: '6px',
                border: 'none',
                backgroundColor: 'var(--primary)',
                color: 'var(--primary-foreground)',
                fontWeight: '600',
                cursor: 'pointer',
              }}
            >
              Submit
            </button>
          </div>
        </div>
      </section>

      <section>
        <h2 style={{ fontSize: '1.5rem', fontWeight: '600', marginBottom: '1rem' }}>
          Accessibility Features
        </h2>
        
        <div style={{ 
          display: 'grid', 
          gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', 
          gap: '1rem',
          marginBottom: '2rem'
        }}>
          <div style={{ 
            padding: '1rem',
            borderRadius: '8px',
            backgroundColor: 'var(--card)',
            border: '1px solid var(--border)',
          }}>
            <div style={{ fontSize: '0.875rem', fontWeight: '600', marginBottom: '0.5rem' }}>
              Reduced Motion
            </div>
            <div style={{ fontSize: '0.75rem', color: 'var(--muted-foreground)' }}>
              Smooth transitions respect user preferences
            </div>
          </div>
          
          <div style={{ 
            padding: '1rem',
            borderRadius: '8px',
            backgroundColor: 'var(--card)',
            border: '1px solid var(--border)',
          }}>
            <div style={{ fontSize: '0.875rem', fontWeight: '600', marginBottom: '0.5rem' }}>
              High Contrast
            </div>
            <div style={{ fontSize: '0.75rem', color: 'var(--muted-foreground)' }}>
              Enhanced borders and text for better visibility
            </div>
          </div>
          
          <div style={{ 
            padding: '1rem',
            borderRadius: '8px',
            backgroundColor: 'var(--card)',
            border: '1px solid var(--border)',
          }}>
            <div style={{ fontSize: '0.875rem', fontWeight: '600', marginBottom: '0.5rem' }}>
              Keyboard Navigation
            </div>
            <div style={{ fontSize: '0.75rem', color: 'var(--muted-foreground)' }}>
              Full keyboard support with focus indicators
            </div>
          </div>
          
          <div style={{ 
            padding: '1rem',
            borderRadius: '8px',
            backgroundColor: 'var(--card)',
            border: '1px solid var(--border)',
          }}>
            <div style={{ fontSize: '0.875rem', fontWeight: '600', marginBottom: '0.5rem' }}>
              Screen Reader Ready
            </div>
            <div style={{ fontSize: '0.75rem', color: 'var(--muted-foreground)' }}>
              Proper ARIA labels and semantic HTML
            </div>
          </div>
        </div>
      </section>

      <footer style={{ 
        marginTop: '3rem', 
        paddingTop: '2rem', 
        borderTop: '1px solid var(--border)',
        textAlign: 'center',
        color: 'var(--muted-foreground)',
        fontSize: '0.875rem'
      }}>
        <p>
          Dark Mode Polish Implementation • WCAG 2.1 AA Compliant • {isDarkMode ? 'Dark' : 'Light'} Mode Active
        </p>
      </footer>
    </div>
  );
};

export default DarkModeExample;