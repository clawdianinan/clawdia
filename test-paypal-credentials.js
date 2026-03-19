#!/usr/bin/env node

/**
 * Simple PayPal Credential Test
 * Tests if the provided PayPal credentials are valid
 */

const https = require('https');

// Provided credentials from the task
const PAYPAL_CLIENT_ID = 'AVr-s5kGXqnsht9K4k30Iahz1hHjQtYxlsNhxWVSAiDaZOgWopkMG1AM64UvDx3s1Bnog30P0gqyVM6v';
const PAYPAL_CLIENT_SECRET = 'EN3dcrJt-LNpWEt1LbDxsO8O5m5UNJoALZht5w3HA0JXA_j5VY9TJv7HVPtsz6Tj3uV-joudQBT6rT5p';
const PAYPAL_MODE = 'sandbox';

console.log('🔍 Testing PayPal Credentials');
console.log('============================\n');
console.log(`Client ID: ${PAYPAL_CLIENT_ID}`);
console.log(`Client Secret: ${PAYPAL_CLIENT_SECRET.substring(0, 10)}...`);
console.log(`Mode: ${PAYPAL_MODE}\n`);

// Test 1: Basic authentication
function testBasicAuth() {
  return new Promise((resolve, reject) => {
    const auth = Buffer.from(`${PAYPAL_CLIENT_ID}:${PAYPAL_CLIENT_SECRET}`).toString('base64');
    
    const options = {
      hostname: 'api-m.sandbox.paypal.com',
      path: '/v1/oauth2/token',
      method: 'POST',
      headers: {
        'Authorization': `Basic ${auth}`,
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json'
      }
    };
    
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        try {
          const result = JSON.parse(data);
          resolve({
            statusCode: res.statusCode,
            data: result
          });
        } catch (e) {
          resolve({
            statusCode: res.statusCode,
            data: data
          });
        }
      });
    });
    
    req.on('error', reject);
    req.write('grant_type=client_credentials');
    req.end();
  });
}

// Test 2: Check if credentials might be production instead of sandbox
function testProductionAuth() {
  return new Promise((resolve, reject) => {
    const auth = Buffer.from(`${PAYPAL_CLIENT_ID}:${PAYPAL_CLIENT_SECRET}`).toString('base64');
    
    const options = {
      hostname: 'api-m.paypal.com',
      path: '/v1/oauth2/token',
      method: 'POST',
      headers: {
        'Authorization': `Basic ${auth}`,
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json'
      }
    };
    
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        try {
          const result = JSON.parse(data);
          resolve({
            statusCode: res.statusCode,
            data: result
          });
        } catch (e) {
          resolve({
            statusCode: res.statusCode,
            data: data
          });
        }
      });
    });
    
    req.on('error', reject);
    req.write('grant_type=client_credentials');
    req.end();
  });
}

async function runTests() {
  console.log('1. Testing Sandbox Authentication...');
  try {
    const sandboxResult = await testBasicAuth();
    console.log(`   Status Code: ${sandboxResult.statusCode}`);
    
    if (sandboxResult.statusCode === 200) {
      console.log('   ✅ SUCCESS: Sandbox credentials are valid!');
      console.log(`      Access Token: ${sandboxResult.data.access_token?.substring(0, 20)}...`);
      console.log(`      Expires in: ${sandboxResult.data.expires_in} seconds`);
      return { valid: true, mode: 'sandbox', data: sandboxResult.data };
    } else if (sandboxResult.statusCode === 401) {
      console.log('   ❌ FAILED: Sandbox authentication failed');
      console.log(`      Error: ${sandboxResult.data.error || 'Unknown error'}`);
      console.log(`      Description: ${sandboxResult.data.error_description || 'No description'}`);
      
      // Test production
      console.log('\n2. Testing Production Authentication (in case mode is wrong)...');
      try {
        const productionResult = await testProductionAuth();
        console.log(`   Status Code: ${productionResult.statusCode}`);
        
        if (productionResult.statusCode === 200) {
          console.log('   ⚠ WARNING: Credentials work in PRODUCTION, not sandbox!');
          console.log(`      Access Token: ${productionResult.data.access_token?.substring(0, 20)}...`);
          console.log('   ⚠ CRITICAL: These are LIVE production credentials!');
          return { valid: true, mode: 'production', data: productionResult.data };
        } else {
          console.log('   ❌ FAILED: Production authentication also failed');
          console.log(`      Error: ${productionResult.data.error || 'Unknown error'}`);
          return { valid: false, mode: 'invalid' };
        }
      } catch (prodError) {
        console.log(`   ❌ ERROR testing production: ${prodError.message}`);
        return { valid: false, mode: 'error' };
      }
    } else {
      console.log(`   ❌ UNEXPECTED: Status ${sandboxResult.statusCode}`);
      console.log(`      Response: ${JSON.stringify(sandboxResult.data)}`);
      return { valid: false, mode: 'unexpected' };
    }
  } catch (error) {
    console.log(`   ❌ NETWORK ERROR: ${error.message}`);
    
    // Check if it's a DNS/network issue
    if (error.code === 'ENOTFOUND' || error.code === 'ECONNREFUSED') {
      console.log('   ⚠ Network issue - cannot reach PayPal API');
      console.log('   Please check internet connection and DNS');
    }
    
    return { valid: false, mode: 'network_error' };
  }
}

// Run tests
runTests().then(result => {
  console.log('\n📊 TEST SUMMARY');
  console.log('==============');
  
  if (result.valid) {
    if (result.mode === 'sandbox') {
      console.log('✅ PayPal sandbox credentials are VALID and working!');
      console.log('🚀 Ready for extensive PayPal testing.');
    } else if (result.mode === 'production') {
      console.log('⚠️ WARNING: Credentials are for PRODUCTION, not sandbox!');
      console.log('❌ DO NOT USE for testing - could result in real charges!');
      console.log('💡 Update PAYPAL_MODE to "live" if intentional.');
    }
  } else {
    console.log('❌ PayPal credentials are INVALID or not working.');
    console.log('💡 Possible issues:');
    console.log('   1. Credentials are incorrect/expired');
    console.log('   2. Account is restricted/suspended');
    console.log('   3. Network/firewall blocking API access');
    console.log('   4. Credentials are for different environment (live vs sandbox)');
  }
  
  console.log('\n🔍 Credential Analysis:');
  console.log(`   Client ID format: ${PAYPAL_CLIENT_ID.startsWith('A') ? '✅ Starts with A (typical)' : '❌ Unexpected format'}`);
  console.log(`   Client ID length: ${PAYPAL_CLIENT_ID.length} chars (expected: ~80)`);
  console.log(`   Client Secret length: ${PAYPAL_CLIENT_SECRET.length} chars (expected: ~80)`);
  
  process.exit(result.valid && result.mode === 'sandbox' ? 0 : 1);
});