// Simple JavaScript error detection script
import http from 'http';

const url = 'http://localhost:8080';

console.log(`Testing ${url} for JavaScript errors...`);

// Make a request to get the HTML
const req = http.get(url, (res) => {
  let data = '';
  
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    console.log(`Status Code: ${res.statusCode}`);
    console.log(`Content Length: ${data.length} bytes`);
    
    // Check for common JavaScript error patterns
    const checks = {
      'Uncaught ReferenceError': data.includes('Uncaught ReferenceError'),
      'Uncaught TypeError': data.includes('Uncaught TypeError'),
      'Uncaught SyntaxError': data.includes('Uncaught SyntaxError'),
      'Failed to load resource': data.includes('Failed to load resource'),
      '404 Not Found': data.includes('404') && data.includes('Not Found'),
      '500 Internal Server Error': data.includes('500') && data.includes('Internal Server Error'),
    };
    
    console.log('\n=== JavaScript Error Checks ===');
    let hasErrors = false;
    
    for (const [errorType, found] of Object.entries(checks)) {
      if (found) {
        console.log(`❌ ${errorType}: DETECTED`);
        hasErrors = true;
      } else {
        console.log(`✅ ${errorType}: Not found`);
      }
    }
    
    // Check for script tags
    const scriptTags = (data.match(/<script/g) || []).length;
    console.log(`\nScript tags found: ${scriptTags}`);
    
    // Check for common React patterns
    const hasReact = data.includes('react') || data.includes('React');
    const hasVite = data.includes('vite') || data.includes('VITE');
    console.log(`React detected: ${hasReact ? '✅' : '❌'}`);
    console.log(`Vite detected: ${hasReact ? '✅' : '❌'}`);
    
    if (!hasErrors) {
      console.log('\n✅ No obvious JavaScript error patterns detected in HTML');
      console.log('Note: This is a basic check. Manual browser testing is still required.');
    } else {
      console.log('\n⚠️ Potential JavaScript issues detected. Manual verification required.');
    }
  });
});

req.on('error', (error) => {
  console.error(`Error fetching ${url}:`, error.message);
});

req.end();