// Viewport compatibility test
import http from 'http';

const url = 'http://localhost:8080';

console.log('=== PRDForge Viewport Compatibility Testing ===\n');

// Viewport sizes to test
const viewports = {
  'Desktop (Large)': { width: 1920, height: 1080 },
  'Desktop (Medium)': { width: 1366, height: 768 },
  'Desktop (Small)': { width: 1024, height: 768 },
  'Tablet (Landscape)': { width: 1024, height: 768 },
  'Tablet (Portrait)': { width: 768, height: 1024 },
  'Mobile (Large)': { width: 414, height: 896 }, // iPhone X/XS/11 Pro
  'Mobile (Medium)': { width: 375, height: 667 }, // iPhone 6/7/8
  'Mobile (Small)': { width: 320, height: 568 }, // iPhone SE
};

// Make request to check viewport meta tag
const req = http.get(url, (res) => {
  let data = '';
  
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    // Extract viewport meta tag content
    const viewportMatch = data.match(/<meta[^>]*name=["']viewport["'][^>]*>/i);
    let viewportContent = 'Not found';
    
    if (viewportMatch) {
      const contentMatch = viewportMatch[0].match(/content=["']([^"']+)["']/i);
      if (contentMatch) {
        viewportContent = contentMatch[1];
      }
    }
    
    console.log('=== VIEWPORT CONFIGURATION ===');
    console.log(`Viewport meta tag: ${viewportMatch ? '✅ Found' : '❌ Missing'}`);
    console.log(`Viewport content: ${viewportContent}\n`);
    
    // Check for responsive design indicators
    console.log('=== RESPONSIVE DESIGN INDICATORS ===');
    
    const hasMediaQueries = data.includes('@media') || data.includes('media=');
    console.log(`CSS media queries: ${hasMediaQueries ? '✅ Likely' : '⚠️ Not detected'}`);
    
    const hasResponsiveImages = data.includes('srcset=') || data.includes('sizes=');
    console.log(`Responsive images: ${hasResponsiveImages ? '✅' : '⚠️ Not detected'}`);
    
    const hasFlexboxGrid = data.includes('flex') || data.includes('grid');
    console.log(`Flexbox/Grid CSS: ${hasFlexboxGrid ? '✅' : '⚠️ Not detected'}`);
    
    // Viewport compatibility assessment
    console.log('\n=== VIEWPORT COMPATIBILITY ASSESSMENT ===');
    console.log('Testing against common viewport sizes:\n');
    
    for (const [device, size] of Object.entries(viewports)) {
      let compatibility = '✅ Good';
      
      // Simple heuristic based on viewport meta tag
      if (viewportContent.includes('width=device-width')) {
        if (size.width < 768 && !viewportContent.includes('initial-scale=1')) {
          compatibility = '⚠️ Check zoom';
        }
      } else {
        compatibility = '❌ Fixed width';
      }
      
      console.log(`${device.padEnd(25)} ${size.width}x${size.height.toString().padEnd(8)} ${compatibility}`);
    }
    
    // Recommendations
    console.log('\n=== RECOMMENDATIONS ===');
    
    if (!viewportMatch) {
      console.log('1. ❌ CRITICAL: Add viewport meta tag for mobile compatibility');
      console.log('   <meta name="viewport" content="width=device-width, initial-scale=1">');
    }
    
    if (!hasMediaQueries) {
      console.log('2. ⚠️ Consider adding CSS media queries for responsive design');
    }
    
    if (!hasResponsiveImages) {
      console.log('3. ⚠️ Consider using srcset for responsive images');
    }
    
    console.log('\n4. ✅ Manual testing required for:');
    console.log('   - Mobile touch interactions');
    console.log('   - Form input on small screens');
    console.log('   - Navigation menus on mobile');
    console.log('   - Text readability on all devices');
    
    // Generate test checklist
    console.log('\n=== MANUAL TEST CHECKLIST ===');
    console.log('Desktop (1920x1080):');
    console.log('  [ ] Layout fills screen appropriately');
    console.log('  [ ] Text is readable (not too small)');
    console.log('  [ ] Navigation is accessible');
    console.log('\nTablet (768x1024):');
    console.log('  [ ] Layout adapts to portrait mode');
    console.log('  [ ] Touch targets are large enough');
    console.log('  [ ] Forms are usable');
    console.log('\nMobile (375x667):');
    console.log('  [ ] No horizontal scrolling');
    console.log('  [ ] Text size is comfortable');
    console.log('  [ ] Buttons are tappable');
    console.log('  [ ] Keyboard doesn\'t obscure inputs');
  });
});

req.on('error', (error) => {
  console.error(`Error: ${error.message}`);
});

req.end();