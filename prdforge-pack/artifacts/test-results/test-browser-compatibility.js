// Browser compatibility test script
import http from 'http';

const url = 'http://localhost:8080';

console.log('=== PRDForge Browser Compatibility Testing ===');
console.log(`Testing URL: ${url}`);
console.log(`Date: ${new Date().toISOString()}\n`);

// Make a request to get the HTML
const req = http.get(url, (res) => {
  let data = '';
  
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    console.log('=== BASIC HTTP TESTS ===');
    console.log(`Status Code: ${res.statusCode} ${res.statusCode === 200 ? '✅' : '❌'}`);
    console.log(`Content-Type: ${res.headers['content-type']}`);
    console.log(`Content Length: ${data.length} bytes\n`);
    
    // Parse HTML for compatibility checks
    console.log('=== HTML STRUCTURE CHECKS ===');
    
    // Check for DOCTYPE
    const hasDoctype = data.includes('<!DOCTYPE');
    console.log(`DOCTYPE present: ${hasDoctype ? '✅' : '❌'}`);
    
    // Check for viewport meta tag
    const hasViewport = data.includes('viewport') && data.includes('width=device-width');
    console.log(`Viewport meta tag: ${hasViewport ? '✅' : '❌'}`);
    
    // Check for charset
    const hasCharset = data.includes('charset="UTF-8"') || data.includes('charset=UTF-8');
    console.log(`UTF-8 charset: ${hasCharset ? '✅' : '❌'}`);
    
    // Check for title
    const titleMatch = data.match(/<title>(.*?)<\/title>/);
    const title = titleMatch ? titleMatch[1] : 'Not found';
    console.log(`Page title: "${title}" ${title.includes('PRDForge') ? '✅' : '❌'}`);
    
    // Check for React/Vite markers
    console.log('\n=== FRAMEWORK CHECKS ===');
    const hasReact = data.includes('react') || data.includes('React');
    const hasVite = data.includes('vite') || data.includes('VITE');
    console.log(`React detected: ${hasReact ? '✅' : '❌'}`);
    console.log(`Vite detected: ${hasVite ? '✅' : '❌'}`);
    
    // Check script tags
    const scriptTags = (data.match(/<script/g) || []).length;
    console.log(`Script tags: ${scriptTags} ${scriptTags > 0 ? '✅' : '❌'}`);
    
    // Check for modern JavaScript features
    console.log('\n=== MODERN JAVASCRIPT FEATURES ===');
    const hasModuleScripts = data.includes('type="module"');
    console.log(`ES Modules: ${hasModuleScripts ? '✅' : '❌'}`);
    
    // Check for CSS
    const hasCSS = data.includes('<style') || data.includes('rel="stylesheet"');
    console.log(`CSS present: ${hasCSS ? '✅' : '❌'}`);
    
    // Check for common compatibility issues
    console.log('\n=== COMPATIBILITY RED FLAGS ===');
    
    // Check for IE-specific code (should not be present)
    const hasIEConditionals = data.includes('<!--[if') || data.includes('<![endif]-->');
    console.log(`IE conditionals: ${hasIEConditionals ? '❌ (Avoid for modern apps)' : '✅'}`);
    
    // Check for deprecated tags
    const hasDeprecatedTags = data.includes('<center>') || data.includes('<font>') || data.includes('<marquee>');
    console.log(`Deprecated HTML tags: ${hasDeprecatedTags ? '❌' : '✅'}`);
    
    // Check for inline styles (can cause compatibility issues)
    const inlineStyleCount = (data.match(/style="/g) || []).length;
    console.log(`Inline styles: ${inlineStyleCount} ${inlineStyleCount < 10 ? '✅' : '⚠️ (Consider using CSS classes)'}`);
    
    // Browser-specific feature detection
    console.log('\n=== BROWSER-SPECIFIC COMPATIBILITY ===');
    
    // Check for Web Components/Shadow DOM
    const hasShadowDOM = data.includes('shadowroot') || data.includes('attachShadow');
    console.log(`Shadow DOM usage: ${hasShadowDOM ? '⚠️ (Check Safari compatibility)' : '✅'}`);
    
    // Check for CSS Grid/Flexbox indicators
    const hasModernCSS = data.includes('display: grid') || data.includes('display: flex');
    console.log(`Modern CSS layout: ${hasModernCSS ? '✅' : '⚠️ (Consider fallbacks)'}`);
    
    // Generate compatibility report
    console.log('\n=== COMPATIBILITY SUMMARY ===');
    console.log('Overall compatibility assessment:');
    
    const checks = [
      res.statusCode === 200,
      hasDoctype,
      hasViewport,
      hasCharset,
      title.includes('PRDForge'),
      hasReact,
      scriptTags > 0,
      !hasIEConditionals,
      !hasDeprecatedTags,
    ];
    
    const passed = checks.filter(Boolean).length;
    const total = checks.length;
    const percentage = Math.round((passed / total) * 100);
    
    console.log(`Passed: ${passed}/${total} (${percentage}%)`);
    
    if (percentage >= 90) {
      console.log('✅ EXCELLENT: High compatibility likely');
    } else if (percentage >= 70) {
      console.log('⚠️ GOOD: Generally compatible, some issues may exist');
    } else {
      console.log('❌ POOR: Significant compatibility issues likely');
    }
    
    console.log('\n=== RECOMMENDATIONS ===');
    console.log('1. Test manually in Chrome, Firefox, Safari, and Edge');
    console.log('2. Verify responsive design on mobile/tablet viewports');
    console.log('3. Check JavaScript console for errors in each browser');
    console.log('4. Test core functionality (authentication, PRD creation)');
    console.log('5. Consider using BrowserStack or similar for comprehensive testing');
  });
});

req.on('error', (error) => {
  console.error(`Error fetching ${url}:`, error.message);
});

req.end();