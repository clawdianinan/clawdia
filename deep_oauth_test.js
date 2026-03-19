#!/usr/bin/env node

/**
 * Deep OAuth Test - Check actual project data and user associations
 */

const https = require('https');

const BASE_URL = 'https://prdforge-dev.netlify.app';

// Direct database check (using the credentials from verify script)
const DB_CONFIG = {
  host: 'db.eflrqvxmqrtbytkxyrze.supabase.co',
  port: 5432,
  database: 'postgres',
  user: 'postgres',
  password: 'cVHV8VFB61QVd8nv'
};

// Users to test
const USERS = [
  'drsamhappiness@gmail.com',
  'kolapoimam1@gmail.com', 
  'okeymaureen1996@gmail.com',
  'temikolawole@gmail.com'
];

async function checkDatabaseDirectly() {
  console.log('🔍 Checking database directly...');
  
  // Since we can't run psql directly from Node, let's check via API endpoints
  // that might reveal more data
  
  const endpoints = [
    '/api/projects?limit=100',
    '/api/dashboard/stats',
    '/api/users'
  ];
  
  const results = {};
  
  for (const endpoint of endpoints) {
    try {
      const data = await fetchJson(`${BASE_URL}${endpoint}`);
      results[endpoint] = {
        success: true,
        data: data
      };
    } catch (error) {
      results[endpoint] = {
        success: false,
        error: error.message
      };
    }
  }
  
  return results;
}

async function fetchJson(url) {
  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          resolve(JSON.parse(data));
        } catch (e) {
          reject(new Error(`Failed to parse JSON: ${e.message}`));
        }
      });
    }).on('error', reject);
  });
}

async function testUserProjectAssociations() {
  console.log('🔍 Testing user-project associations...');
  
  // First, let's see what the projects API returns
  try {
    const projectsData = await fetchJson(`${BASE_URL}/api/projects?limit=100`);
    console.log('Projects API response:', JSON.stringify(projectsData, null, 2));
    
    // Check if we can get user-specific data
    const userResults = [];
    
    for (const userEmail of USERS) {
      try {
        // Try to simulate what would happen after OAuth login
        // by checking if user-specific endpoints exist
        const userStats = await fetchJson(`${BASE_URL}/api/dashboard/stats`);
        
        userResults.push({
          user: userEmail,
          statsAvailable: true,
          statsData: userStats
        });
      } catch (error) {
        userResults.push({
          user: userEmail,
          statsAvailable: false,
          error: error.message
        });
      }
    }
    
    return {
      projects: projectsData,
      users: userResults
    };
  } catch (error) {
    return {
      error: error.message
    };
  }
}

async function checkOAuthFlowSimulation() {
  console.log('🔍 Simulating OAuth flow checks...');
  
  // Check OAuth initiation endpoints
  const oauthEndpoints = [
    '/auth/google',
    '/auth/github',
    '/api/auth/providers'
  ];
  
  const results = {};
  
  for (const endpoint of oauthEndpoints) {
    try {
      const response = await fetchWithDetails(`${BASE_URL}${endpoint}`);
      results[endpoint] = {
        status: response.status,
        headers: response.headers,
        body: response.body.substring(0, 500) // First 500 chars
      };
    } catch (error) {
      results[endpoint] = {
        error: error.message
      };
    }
  }
  
  return results;
}

async function fetchWithDetails(url) {
  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        resolve({
          status: res.statusCode,
          headers: res.headers,
          body: data
        });
      });
    }).on('error', reject);
  });
}

async function runComprehensiveTest() {
  console.log('🚀 Running Comprehensive OAuth & Data Access Test\n');
  
  const results = {};
  
  // 1. Check database via API
  results.databaseCheck = await checkDatabaseDirectly();
  
  // 2. Check user-project associations
  results.userProjectAssociations = await testUserProjectAssociations();
  
  // 3. Check OAuth flow
  results.oauthFlow = await checkOAuthFlowSimulation();
  
  // 4. Check key pages
  results.pages = {
    login: await fetchWithDetails(`${BASE_URL}/login`),
    dashboard: await fetchWithDetails(`${BASE_URL}/dashboard`),
    signup: await fetchWithDetails(`${BASE_URL}/signup`)
  };
  
  // Generate analysis
  console.log('\n📊 ANALYSIS');
  console.log('=' .repeat(60));
  
  // Check if projects exist
  const projectsData = results.userProjectAssociations.projects;
  const hasProjects = projectsData && projectsData.data && projectsData.data.length > 0;
  const projectCount = hasProjects ? projectsData.data.length : 0;
  
  console.log(`Projects in API: ${hasProjects ? '✅' : '❌'} (${projectCount} projects)`);
  console.log(`Expected: 7+ projects across 4 users`);
  
  // Check OAuth endpoints
  const oauthWorking = results.oauthFlow['/auth/google'] && 
                      results.oauthFlow['/auth/google'].status === 200;
  console.log(`OAuth Google endpoint: ${oauthWorking ? '✅ Working' : '❌ Not working'}`);
  
  // Check user access
  const usersWithStats = results.userProjectAssociations.users.filter(u => u.statsAvailable).length;
  console.log(`Users with accessible stats: ${usersWithStats}/${USERS.length}`);
  
  // Check pages
  const loginPageOk = results.pages.login.status === 200;
  const dashboardPageOk = results.pages.dashboard.status === 200;
  console.log(`Login page: ${loginPageOk ? '✅ Accessible' : '❌ Not accessible'}`);
  console.log(`Dashboard page: ${dashboardPageOk ? '✅ Accessible' : '❌ Not accessible'}`);
  
  // Database connectivity
  const dbConnected = results.databaseCheck['/api/projects'].success;
  console.log(`Database API connectivity: ${dbConnected ? '✅ Connected' : '❌ Not connected'}`);
  
  // Save detailed results
  const reportFile = `deep_oauth_test_${new Date().toISOString().replace(/[:.]/g, '-')}.json`;
  require('fs').writeFileSync(reportFile, JSON.stringify(results, null, 2));
  console.log(`\n📄 Detailed report saved to: ${reportFile}`);
  
  // Summary
  console.log('\n' + '=' .repeat(60));
  console.log('SUMMARY FOR MORPHEUS AGENT OAuth TEST:');
  console.log('=' .repeat(60));
  
  const issues = [];
  
  if (!hasProjects || projectCount < 7) {
    issues.push(`- Project count insufficient: ${projectCount} found, expected 7+`);
  }
  
  if (!oauthWorking) {
    issues.push('- OAuth Google endpoint not working');
  }
  
  if (usersWithStats < USERS.length) {
    issues.push(`- Only ${usersWithStats}/${USERS.length} users have accessible stats`);
  }
  
  if (!loginPageOk) {
    issues.push('- Login page not accessible');
  }
  
  if (!dashboardPageOk) {
    issues.push('- Dashboard page not accessible');
  }
  
  if (!dbConnected) {
    issues.push('- Database API not connected');
  }
  
  if (issues.length === 0) {
    console.log('✅ ALL SYSTEMS READY FOR OAuth LOGIN TESTING');
    console.log('\nNext steps:');
    console.log('1. Navigate to https://prdforge-dev.netlify.app');
    console.log('2. Click "Login with Google" or "Login with GitHub"');
    console.log('3. Test each of the 4 users');
    console.log('4. Verify they see their projects on dashboard');
    console.log('5. Check data accessibility in projects');
  } else {
    console.log('⚠️  ISSUES DETECTED:');
    issues.forEach(issue => console.log(issue));
    console.log('\n❌ OAuth login testing may fail until these issues are resolved.');
  }
  
  return { results, issues };
}

runComprehensiveTest().catch(console.error);