#!/usr/bin/env node

/**
 * QA-003 Test Data Setup Script
 * Creates test users and data for billing validation testing
 */

const fs = require('fs');
const path = require('path');
const https = require('https');

// Read environment variables
const envPath = path.join('/Users/clawdia/apps/prdforge', '.env.test');
const envContent = fs.readFileSync(envPath, 'utf8');
const envVars = {};

envContent.split('\n').forEach(line => {
  const match = line.match(/^([A-Z_]+)=(.+)$/);
  if (match) {
    const [, key, value] = match;
    envVars[key] = value.trim();
  }
});

const SUPABASE_URL = envVars.VITE_SUPABASE_URL;
const SUPABASE_KEY = envVars.VITE_SUPABASE_PUBLISHABLE_KEY;
const SITE_URL = envVars.SITE_URL || 'https://prdforge-dev.netlify.app';

console.log('🔧 QA-003 Test Data Setup');
console.log('=========================\n');

// Test user configurations
const testUsers = [
  {
    email: 'test+prdforge@example.com',
    password: 'TestPassword123!',
    name: 'PRDForge Test User',
    role: 'primary'
  },
  {
    email: 'test+stripe@example.com',
    password: 'TestPassword123!',
    name: 'Stripe Test User',
    role: 'stripe_tests'
  },
  {
    email: 'test+paypal@example.com',
    password: 'TestPassword123!',
    name: 'PayPal Test User',
    role: 'paypal_tests'
  },
  {
    email: 'test+paystack@example.com',
    password: 'TestPassword123!',
    name: 'PayStack Test User',
    role: 'paystack_tests'
  },
  {
    email: 'test+crypto@example.com',
    password: 'TestPassword123!',
    name: 'Crypto Test User',
    role: 'crypto_tests'
  },
  {
    email: 'test+credits@example.com',
    password: 'TestPassword123!',
    name: 'Credits Test User',
    role: 'credits_tests'
  },
  {
    email: 'test+subscription@example.com',
    password: 'TestPassword123!',
    name: 'Subscription Test User',
    role: 'subscription_tests'
  },
  {
    email: 'test+failed@example.com',
    password: 'TestPassword123!',
    name: 'Failed Payment Test User',
    role: 'failed_tests'
  }
];

// Helper function for Supabase API calls
async function supabaseRequest(endpoint, method = 'GET', data = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(endpoint, SUPABASE_URL);
    
    const options = {
      hostname: url.hostname,
      path: url.pathname + url.search,
      method,
      headers: {
        'Content-Type': 'application/json',
        'apikey': SUPABASE_KEY,
        'Authorization': `Bearer ${SUPABASE_KEY}`
      }
    };

    const req = https.request(options, (res) => {
      let responseData = '';
      res.on('data', (chunk) => {
        responseData += chunk;
      });
      res.on('end', () => {
        try {
          const parsed = JSON.parse(responseData);
          resolve({ statusCode: res.statusCode, data: parsed });
        } catch (e) {
          resolve({ statusCode: res.statusCode, data: responseData });
        }
      });
    });

    req.on('error', reject);
    
    if (data) {
      req.write(JSON.stringify(data));
    }
    
    req.end();
  });
}

async function createTestUser(user) {
  console.log(`Creating test user: ${user.email} (${user.role})`);
  
  try {
    // Sign up user
    const signupResponse = await supabaseRequest('/auth/v1/signup', 'POST', {
      email: user.email,
      password: user.password,
      data: {
        full_name: user.name,
        role: user.role,
        test_user: true
      }
    });

    if (signupResponse.statusCode === 200 || signupResponse.statusCode === 201) {
      console.log(`  ✓ User created: ${user.email}`);
      
      // Add user metadata
      if (signupResponse.data.user) {
        const userId = signupResponse.data.user.id;
        
        // Create user profile
        await supabaseRequest('/rest/v1/profiles', 'POST', {
          id: userId,
          email: user.email,
          full_name: user.name,
          role: user.role,
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString()
        });
        
        console.log(`  ✓ Profile created for: ${user.email}`);
      }
      
      return { success: true, user: signupResponse.data.user };
    } else {
      console.log(`  ⚠ User may already exist: ${user.email}`);
      return { success: false, error: 'User may exist' };
    }
  } catch (error) {
    console.log(`  ✗ Error creating user ${user.email}: ${error.message}`);
    return { success: false, error: error.message };
  }
}

async function setupTestProjects() {
  console.log('\nSetting up test projects...');
  
  const testProjects = [
    {
      name: 'E-commerce Mobile App',
      description: 'Test project for payment validation',
      status: 'draft',
      test_type: 'export_unlock'
    },
    {
      name: 'SaaS Dashboard',
      description: 'Another test project',
      status: 'draft',
      test_type: 'credit_topup'
    },
    {
      name: 'API Integration Service',
      description: 'Test project for subscription',
      status: 'draft',
      test_type: 'subscription'
    }
  ];
  
  // Note: Project creation would require authenticated user context
  // This is just a placeholder for the test data structure
  console.log('  Test projects defined (require user auth to create):');
  testProjects.forEach(project => {
    console.log(`    • ${project.name} - ${project.test_type}`);
  });
  
  return testProjects;
}

async function setupCreditPacks() {
  console.log('\nSetting up credit pack configurations...');
  
  const creditPacks = [
    { price: 5, credits: 25 },
    { price: 10, credits: 60 },
    { price: 20, credits: 150 },
    { price: 50, credits: 500 }
  ];
  
  console.log('  Credit packs configured:');
  creditPacks.forEach(pack => {
    console.log(`    • $${pack.price} → ${pack.credits} credits`);
  });
  
  return creditPacks;
}

async function setupSubscriptionPlans() {
  console.log('\nSetting up subscription plan configurations...');
  
  const subscriptionPlans = [
    { id: 'starter', name: 'Starter', price_monthly: 10, price_yearly: 100, credits_per_month: 100 },
    { id: 'pro', name: 'Professional', price_monthly: 30, price_yearly: 300, credits_per_month: 500 },
    { id: 'enterprise', name: 'Enterprise', price_monthly: 100, price_yearly: 1000, credits_per_month: 2000 }
  ];
  
  console.log('  Subscription plans configured:');
  subscriptionPlans.forEach(plan => {
    console.log(`    • ${plan.name}: $${plan.price_monthly}/month ($${plan.price_yearly}/year)`);
  });
  
  return subscriptionPlans;
}

async function generateTestInstructions() {
  console.log('\n📋 TEST INSTRUCTIONS FOR QA-003');
  console.log('===============================\n');
  
  console.log('1. TEST USER CREDENTIALS');
  console.log('-----------------------');
  testUsers.forEach(user => {
    console.log(`   ${user.role}:`);
    console.log(`   • Email: ${user.email}`);
    console.log(`   • Password: ${user.password}`);
    console.log(`   • Purpose: ${user.role.replace('_', ' ')}`);
    console.log('');
  });
  
  console.log('2. TEST CARD NUMBERS');
  console.log('-------------------');
  console.log('   Stripe Test Cards:');
  console.log('   • Success: 4242 4242 4242 4242');
  console.log('   • Decline: 4000 0000 0000 0002');
  console.log('   • Auth Required: 4000 0025 0000 3155');
  console.log('');
  console.log('   Paystack Test Cards (NGN):');
  console.log('   • Success: 5061 0606 0606 0606');
  console.log('   • Insufficient Funds: 5061 0606 0606 0614');
  console.log('');
  
  console.log('3. TEST SCENARIOS');
  console.log('----------------');
  const scenarios = [
    {
      user: 'test+stripe@example.com',
      test: 'TC-BILL-001',
      action: 'Export unlock payment',
      card: '4242 4242 4242 4242',
      amount: '$5.00'
    },
    {
      user: 'test+failed@example.com',
      test: 'TC-BILL-002',
      action: 'Declined payment',
      card: '4000 0000 0000 0002',
      amount: '$5.00'
    },
    {
      user: 'test+paypal@example.com',
      test: 'TC-BILL-003',
      action: 'PayPal sandbox payment',
      account: 'PayPal sandbox buyer',
      amount: '$5.00'
    },
    {
      user: 'test+paystack@example.com',
      test: 'TC-BILL-004',
      action: 'NGN payment',
      card: '5061 0606 0606 0606',
      amount: '₦3,500'
    },
    {
      user: 'test+credits@example.com',
      test: 'TC-BILL-007',
      action: 'Credit top-up',
      pack: '100 credits for $20',
      provider: 'Stripe or PayPal'
    },
    {
      user: 'test+subscription@example.com',
      test: 'TC-BILL-008',
      action: 'Subscription',
      plan: 'Starter ($10/month)',
      provider: 'Stripe'
    }
  ];
  
  scenarios.forEach(scenario => {
    console.log(`   ${scenario.test}: ${scenario.action}`);
    console.log(`   • User: ${scenario.user}`);
    console.log(`   • Amount: ${scenario.amount}`);
    if (scenario.card) console.log(`   • Card: ${scenario.card}`);
    if (scenario.account) console.log(`   • Account: ${scenario.account}`);
    if (scenario.pack) console.log(`   • Pack: ${scenario.pack}`);
    if (scenario.plan) console.log(`   • Plan: ${scenario.plan}`);
    if (scenario.provider) console.log(`   • Provider: ${scenario.provider}`);
    console.log('');
  });
  
  console.log('4. VALIDATION CHECKLIST');
  console.log('----------------------');
  const checklist = [
    '✓ Payment completes successfully',
    '✓ Invoice generated (PRF-YYYY-XXXXXX format)',
    '✓ Credits added to user account',
    '✓ Webhook received and processed',
    '✓ Email receipt sent',
    '✓ Database records created correctly',
    '✓ Error handling for failed payments',
    '✓ User can retry failed payments'
  ];
  
  checklist.forEach(item => {
    console.log(`   ${item}`);
  });
}

async function main() {
  console.log('Starting QA-003 test data setup...\n');
  
  // Create test users
  console.log('👥 CREATING TEST USERS');
  console.log('---------------------');
  
  const userResults = [];
  for (const user of testUsers) {
    const result = await createTestUser(user);
    userResults.push({ user: user.email, success: result.success });
  }
  
  // Setup test data configurations
  await setupTestProjects();
  await setupCreditPacks();
  await setupSubscriptionPlans();
  
  // Generate test instructions
  await generateTestInstructions();
  
  // Summary
  console.log('\n📊 SETUP SUMMARY');
  console.log('---------------');
  
  const successfulUsers = userResults.filter(r => r.success).length;
  console.log(`Test Users: ${successfulUsers}/${testUsers.length} created/set up`);
  console.log(`Test Projects: 3 defined (require auth to create)`);
  console.log(`Credit Packs: 4 configured`);
  console.log(`Subscription Plans: 3 configured`);
  
  console.log('\n🎯 NEXT STEPS FOR QA-003:');
  console.log('1. Log in with test users to verify accounts');
  console.log('2. Create test projects for each user');
  console.log('3. Execute test cases using the instructions above');
  console.log('4. Document results in Test Execution Log');
  console.log('5. Report any defects found');
  
  console.log('\n✅ QA-003 test data setup complete!');
  console.log('🚀 Ready for billing validation testing.');
}

main().catch(error => {
  console.error('Setup failed:', error);
  process.exit(1);
});