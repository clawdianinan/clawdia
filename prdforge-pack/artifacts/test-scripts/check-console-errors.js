// Check for JavaScript console errors
const puppeteer = require('puppeteer');

async function checkConsoleErrors() {
  console.log('Launching browser to check console errors...');
  let browser;
  
  try {
    browser = await puppeteer.launch({
      headless: 'new',
      args: ['--no-sandbox', '--disable-setuid-sandbox']
    });
    
    const page = await browser.newPage();
    const consoleMessages = [];
    const errors = [];
    
    // Capture console messages
    page.on('console', msg => {
      consoleMessages.push({
        type: msg.type(),
        text: msg.text(),
        location: msg.location()
      });
      
      if (msg.type() === 'error') {
        errors.push({
          text: msg.text(),
          location: msg.location()
        });
      }
    });
    
    // Navigate to the application
    console.log('Navigating to http://localhost:8080...');
    await page.goto('http://localhost:8080', { 
      waitUntil: 'networkidle0',
      timeout: 30000 
    });
    
    // Wait a bit for any async errors
    await page.waitForTimeout(2000);
    
    console.log('\nConsole Messages Found:');
    console.log('=======================');
    consoleMessages.forEach((msg, i) => {
      console.log(`${i+1}. [${msg.type.toUpperCase()}] ${msg.text}`);
      if (msg.location && msg.location.url) {
        console.log(`   Source: ${msg.location.url}:${msg.location.lineNumber}`);
      }
    });
    
    console.log('\nError Summary:');
    console.log('==============');
    if (errors.length === 0) {
      console.log('✅ No JavaScript console errors detected');
    } else {
      console.log(`❌ Found ${errors.length} JavaScript error(s):`);
      errors.forEach((error, i) => {
        console.log(`\n${i+1}. ${error.text}`);
        if (error.location && error.location.url) {
          console.log(`   Source: ${error.location.url}:${error.location.lineNumber}`);
        }
      });
    }
    
    // Check page title
    const title = await page.title();
    console.log(`\nPage Title: "${title}"`);
    
    // Check for common issues
    const hasReact = await page.evaluate(() => {
      return typeof window.React !== 'undefined';
    });
    
    console.log(`React detected: ${hasReact ? '✅ Yes' : '❌ No'}`);
    
    // Take screenshot for documentation
    await page.screenshot({ 
      path: '/Users/clawdia/.openclaw/workspace/prdforge-pack/artifacts/test-results/chrome-desktop-screenshot.png',
      fullPage: true 
    });
    console.log('Screenshot saved to chrome-desktop-screenshot.png');
    
    return {
      consoleMessages,
      errors,
      title,
      hasReact,
      screenshot: 'chrome-desktop-screenshot.png'
    };
    
  } catch (error) {
    console.error('Error during testing:', error);
    return { error: error.message };
  } finally {
    if (browser) {
      await browser.close();
    }
  }
}

// Run the check
checkConsoleErrors().then(results => {
  console.log('\nTest completed.');
  
  // Save detailed results
  const fs = require('fs');
  const path = require('path');
  
  const resultsFile = path.join(__dirname, '..', 'test-results', 'console-check-results.json');
  fs.writeFileSync(resultsFile, JSON.stringify(results, null, 2));
  console.log(`Detailed results saved to: ${resultsFile}`);
  
  // Exit with appropriate code
  if (results.errors && results.errors.length > 0) {
    process.exit(1);
  } else {
    process.exit(0);
  }
}).catch(error => {
  console.error('Fatal error:', error);
  process.exit(1);
});