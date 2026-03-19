const http = require('http');
const https = require('https');

const testURL = 'http://localhost:8080';

async function testBasicFunctionality() {
  console.log('Testing PRDForge Basic Functionality\n');
  console.log('====================================\n');
  
  const results = [];
  
  // Test 1: Basic HTTP connectivity
  console.log('1. Testing HTTP connectivity...');
  try {
    const response = await new Promise((resolve, reject) => {
      const req = http.get(testURL, (res) => {
        let data = '';
        res.on('data', chunk => data += chunk);
        res.on('end', () => resolve({ statusCode: res.statusCode, headers: res.headers, body: data }));
      });
      req.on('error', reject);
      req.setTimeout(5000, () => {
        req.destroy();
        reject(new Error('Timeout'));
      });
    });
    
    if (response.statusCode === 200) {
      console.log('   ✓ HTTP 200 OK received');
      results.push({ test: 'HTTP Connectivity', status: 'PASS', details: `Status: ${response.statusCode}` });
    } else {
      console.log(`   ✗ HTTP ${response.statusCode} received`);
      results.push({ test: 'HTTP Connectivity', status: 'FAIL', details: `Status: ${response.statusCode}` });
    }
    
    // Test 2: Check for HTML structure
    console.log('\n2. Checking HTML structure...');
    if (response.body.includes('<!DOCTYPE html>') || response.body.includes('<html')) {
      console.log('   ✓ Valid HTML detected');
      results.push({ test: 'HTML Structure', status: 'PASS', details: 'Valid HTML document' });
    } else {
      console.log('   ✗ No valid HTML detected');
      results.push({ test: 'HTML Structure', status: 'FAIL', details: 'Invalid or missing HTML' });
    }
    
    // Test 3: Check for title
    console.log('\n3. Checking page title...');
    const titleMatch = response.body.match(/<title>([^<]*)<\/title>/i);
    if (titleMatch) {
      console.log(`   ✓ Title found: "${titleMatch[1]}"`);
      results.push({ test: 'Page Title', status: 'PASS', details: `Title: ${titleMatch[1]}` });
    } else {
      console.log('   ✗ No title tag found');
      results.push({ test: 'Page Title', status: 'FAIL', details: 'Missing title tag' });
    }
    
    // Test 4: Check for JavaScript
    console.log('\n4. Checking for JavaScript...');
    const scriptCount = (response.body.match(/<script/g) || []).length;
    if (scriptCount > 0) {
      console.log(`   ✓ ${scriptCount} script tags found`);
      results.push({ test: 'JavaScript Presence', status: 'PASS', details: `${scriptCount} script tags` });
    } else {
      console.log('   ✗ No script tags found');
      results.push({ test: 'JavaScript Presence', status: 'FAIL', details: 'No JavaScript detected' });
    }
    
    // Test 5: Check for CSS
    console.log('\n5. Checking for CSS...');
    const cssCount = (response.body.match(/<link[^>]*rel=["']stylesheet["']/g) || []).length;
    if (cssCount > 0) {
      console.log(`   ✓ ${cssCount} stylesheet links found`);
      results.push({ test: 'CSS Presence', status: 'PASS', details: `${cssCount} stylesheets` });
    } else {
      console.log('   ✗ No stylesheet links found');
      results.push({ test: 'CSS Presence', status: 'FAIL', details: 'No CSS detected' });
    }
    
    // Test 6: Check for viewport meta tag (mobile responsiveness)
    console.log('\n6. Checking for mobile responsiveness...');
    if (response.body.includes('viewport') || response.body.includes('Viewport')) {
      console.log('   ✓ Viewport meta tag found');
      results.push({ test: 'Mobile Responsiveness', status: 'PASS', details: 'Viewport meta tag present' });
    } else {
      console.log('   ✗ No viewport meta tag found');
      results.push({ test: 'Mobile Responsiveness', status: 'FAIL', details: 'Missing viewport meta tag' });
    }
    
    // Test 7: Check for common framework indicators
    console.log('\n7. Checking for common frameworks...');
    const frameworks = [];
    if (response.body.includes('react') || response.body.includes('React')) frameworks.push('React');
    if (response.body.includes('vue') || response.body.includes('Vue')) frameworks.push('Vue');
    if (response.body.includes('angular') || response.body.includes('Angular')) frameworks.push('Angular');
    if (response.body.includes('next') || response.body.includes('Next')) frameworks.push('Next.js');
    
    if (frameworks.length > 0) {
      console.log(`   ✓ Framework indicators: ${frameworks.join(', ')}`);
      results.push({ test: 'Framework Detection', status: 'PASS', details: `Detected: ${frameworks.join(', ')}` });
    } else {
      console.log('   ⚠ No common framework detected');
      results.push({ test: 'Framework Detection', status: 'INFO', details: 'No common framework detected' });
    }
    
  } catch (error) {
    console.log(`   ✗ Error: ${error.message}`);
    results.push({ test: 'HTTP Connectivity', status: 'FAIL', details: `Error: ${error.message}` });
  }
  
  // Generate summary
  console.log('\n\nTest Summary');
  console.log('============');
  
  const passed = results.filter(r => r.status === 'PASS').length;
  const failed = results.filter(r => r.status === 'FAIL').length;
  const info = results.filter(r => r.status === 'INFO').length;
  const total = results.length;
  
  console.log(`Total Tests: ${total}`);
  console.log(`Passed: ${passed}`);
  console.log(`Failed: ${failed}`);
  console.log(`Info: ${info}`);
  console.log(`Pass Rate: ${((passed / total) * 100).toFixed(1)}%`);
  
  console.log('\nDetailed Results:');
  console.log('================');
  results.forEach(result => {
    const icon = result.status === 'PASS' ? '✓' : result.status === 'FAIL' ? '✗' : 'ℹ';
    console.log(`${icon} ${result.test}: ${result.details}`);
  });
  
  return results;
}

// Run the tests
testBasicFunctionality().catch(console.error);