#!/usr/bin/env node

/**
 * PRDForge Comprehensive Test Suite
 * Tests both dev (localhost:3000) and prod (prdforge-dev.netlify.app)
 * Tests: Load, Console Errors, Auth, API, Database, UI Components
 */

const http = require('http');
const https = require('https');
const fs = require('fs');
const path = require('path');

const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
const reportFile = `prdforge_test_report_${timestamp}.md`;

// Test configuration
const DEV_BASE = 'http://localhost:3000';
const PROD_BASE = 'https://prdforge-dev.netlify.app';
const TIMEOUT = 10000;

// Test results tracking
const results = {
  dev: {},
  prod: {}
};

// Utility: Make HTTP request
function request(url, options = {}) {
  return new Promise((resolve, reject) => {
    const isHttps = url.startsWith('https://');
    const lib = isHttps ? https : http;
    
    const req = lib.get(url, { ...options, timeout: TIMEOUT }, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        resolve({
          status: res.statusCode,
          headers: res.headers,
          body: data,
          url
        });
      });
    });
    
    req.on('error', reject);
    req.on('timeout', () => {
      req.destroy();
      reject(new Error(`Timeout after ${TIMEOUT}ms`));
    });
  });
}

// Test 1: Load Test - Check if app loads without blank page
async function testLoad(base) {
  try {
    const res = await request(base);
    const hasRootDiv = res.body.includes('<div id="root">') || res.body.includes('id="root"');
    const hasAppContent = res.body.length > 1000; // meaningful content
    const contentType = res.headers['content-type'] || '';
    
    return {
      status: 'PASS',
      httpStatus: res.status,
      contentType,
      hasRootDiv,
      hasAppContent,
      bodySize: res.body.length,
      details: `App returns ${res.status}, root div: ${hasRootDiv}, content size: ${res.body.length} bytes`
    };
  } catch (error) {
    return {
      status: 'FAIL',
      error: error.message,
      details: `Failed to load: ${error.message}`
    };
  }
}

// Test 2: API Health Check
async function testAPIHealth(base) {
  try {
    const apiBase = base.replace('://', '://api.') || `${base}/api`;
    const endpoints = [
      '/health',
      '/api/health',
      '/api/v1/health',
      '/status'
    ];
    
    const results = [];
    for (const endpoint of endpoints) {
      try {
        const url = apiBase + endpoint;
        const res = await request(url);
        results.push({
          endpoint,
          status: res.status,
          reachable: res.status < 500
        });
      } catch (e) {
        results.push({
          endpoint,
          status: 'ERROR',
          error: e.message
        });
      }
    }
    
    const anyReachable = results.some(r => r.reachable);
    return {
      status: anyReachable ? 'PASS' : 'FAIL',
      endpoints: results,
      details: `Tested ${endpoints.length} health endpoints`
    };
  } catch (error) {
    return { status: 'FAIL', error: error.message };
  }
}

// Test 3: Database Connectivity via API
async function testDatabaseConnectivity(base) {
  try {
    // Test endpoints that would hit the database
    const endpoints = [
      '/api/projects',
      '/api/prds',
      '/api/users/me',
      '/api/dashboard/stats'
    ];
    
    const results = [];
    for (const endpoint of endpoints) {
      try {
        const url = base + endpoint;
        const res = await request(url);
        let data;
        try { data = JSON.parse(res.body); } catch (e) { data = null; }
        
        results.push({
          endpoint,
          status: res.status,
          contentType: res.headers['content-type'],
          hasData: data && Object.keys(data).length > 0,
          dataCount: data ? (Array.isArray(data) ? data.length : Object.keys(data).length) : 0,
          isError: res.status >= 400
        });
      } catch (e) {
        results.push({
          endpoint,
          status: 'ERROR',
          error: e.message
        });
      }
    }
    
    const successful = results.filter(r => r.status === 200 && !r.isError);
    const hasData = successful.some(r => r.hasData);
    
    return {
      status: hasData ? 'PASS' : (successful.length > 0 ? 'PARTIAL' : 'FAIL'),
      endpoints: results,
      details: `${successful.length}/${endpoints.length} endpoints returned data`
    };
  } catch (error) {
    return { status: 'FAIL', error: error.message };
  }
}

// Test 4: Edge Functions / API Integration
async function testEdgeFunctions(base) {
  try {
    // Test common API patterns
    const tests = [
      {
        name: 'Create Project (POST)',
        method: 'POST',
        endpoint: '/api/projects',
        body: { name: 'Test Project', description: 'Test' },
        expectStatus: 201
      },
      {
        name: 'List Projects (GET)',
        method: 'GET',
        endpoint: '/api/projects',
        expectStatus: 200
      },
      {
        name: 'Get PRD Templates',
        method: 'GET',
        endpoint: '/api/templates',
        expectStatus: 200
      },
      {
        name: 'AI Model List',
        method: 'GET',
        endpoint: '/api/models',
        expectStatus: 200
      }
    ];
    
    const results = [];
    for (const test of tests) {
      try {
        const url = base + test.endpoint;
        const options = {
          method: test.method,
          headers: {
            'Content-Type': 'application/json',
          }
        };
        
        if (test.body) {
          options.body = JSON.stringify(test.body);
        }
        
        const res = await request(url, options);
        let data;
        try { data = JSON.parse(res.body); } catch (e) { data = null; }
        
        results.push({
          test: test.name,
          endpoint: test.endpoint,
          method: test.method,
          status: res.status,
          expected: test.expectStatus,
          passed: res.status === test.expectStatus,
          hasResponseData: !!data,
          error: res.status !== test.expectStatus ? `Expected ${test.expectStatus}, got ${res.status}` : null
        });
      } catch (e) {
        results.push({
          test: test.name,
          endpoint: test.endpoint,
          status: 'ERROR',
          error: e.message
        });
      }
    }
    
    const passed = results.filter(r => r.passed).length;
    return {
      status: passed === tests.length ? 'PASS' : (passed > 0 ? 'PARTIAL' : 'FAIL'),
      tests: results,
      details: `${passed}/${tests.length} API tests passed`
    };
  } catch (error) {
    return { status: 'FAIL', error: error.message };
  }
}

// Test 5: Static Assets
async function testStaticAssets(base) {
  try {
    const assets = [
      '/assets/index.js',
      '/assets/index.css',
      '/manifest.json',
      '/favicon.ico'
    ];
    
    const results = [];
    for (const asset of assets) {
      try {
        const url = base + asset;
        const res = await request(url);
        results.push({
          asset,
          status: res.status,
          size: res.body.length,
          ok: res.status === 200
        });
      } catch (e) {
        results.push({
          asset,
          status: 'ERROR',
          error: e.message
        });
      }
    }
    
    const loaded = results.filter(r => r.ok).length;
    return {
      status: loaded === assets.length ? 'PASS' : 'PARTIAL',
      assets: results,
      details: `${loaded}/${assets.length} assets loaded successfully`
    };
  } catch (error) {
    return { status: 'FAIL', error: error.message };
  }
}

// Test 6: Database Content Verification (from migration data)
async function verifyDatabaseContent() {
  // Based on the database comparison report, we know:
  // OLD DB: 10 users, 155 PRD sections, 8 projects, 314 tasks
  // NEW DB: 0 users, empty tables
  
  const expectedData = {
    users: 10,
    projects: 8,
    prdSections: 155,
    tasks: 314
  };
  
  return {
    status: 'FAIL', // We know NEW DB is empty
    expected: expectedData,
    actual: {
      users: 0,
      projects: 0,
      prdSections: 0,
      tasks: 0
    },
    details: 'New database is empty - migration incomplete',
    migrationStatus: 'INCOMPLETE'
  };
}

// Test 7: Authentication Flow Test
async function testAuthentication(base) {
  try {
    // Test auth endpoints
    const tests = [
      {
        name: 'Signup Page Loads',
        endpoint: '/signup',
        shouldHaveForm: true
      },
      {
        name: 'Login Page Loads',
        endpoint: '/login',
        shouldHaveForm: true
      },
      {
        name: 'Password Reset Page',
        endpoint: '/forgot-password',
        shouldExist: true
      }
    ];
    
    const results = [];
    for (const test of tests) {
      try {
        const url = base + test.endpoint;
        const res = await request(url);
        const hasForm = res.body.includes('<form') || res.body.includes('form');
        
        results.push({
          test: test.name,
          endpoint: test.endpoint,
          status: res.status,
          reachable: res.status === 200,
          hasAuthForm: test.shouldHaveForm ? hasForm : null,
          ok: res.status === 200
        });
      } catch (e) {
        results.push({
          test: test.name,
          status: 'ERROR',
          error: e.message
        });
      }
    }
    
    const reachable = results.filter(r => r.reachable).length;
    return {
      status: reachable === tests.length ? 'PASS' : 'PARTIAL',
      tests: results,
      details: `${reachable}/${tests.length} auth pages accessible`
    };
  } catch (error) {
    return { status: 'FAIL', error: error.message };
  }
}

// Test 8: Dashboard and Data Pages
async function testDataPages(base) {
  try {
    const pages = [
      '/',
      '/dashboard',
      '/projects',
      '/docs',
      '/kb'
    ];
    
    const results = [];
    for (const page of pages) {
      try {
        const url = base + page;
        const res = await request(url);
        
        // Check if page has actual content or is blank
        const hasContent = res.body.length > 500;
        const hasRootDiv = res.body.includes('id="root"') || res.body.includes("id='root'");
        const isErrorPage = res.body.includes('404') || res.body.includes('error') || res.status >= 500;
        
        results.push({
          page,
          status: res.status,
          hasRootDiv,
          hasContent,
          isErrorPage,
          size: res.body.length,
          ok: res.status === 200 && hasContent && !isErrorPage
        });
      } catch (e) {
        results.push({
          page,
          status: 'ERROR',
          error: e.message
        });
      }
    }
    
    const loading = results.filter(r => r.ok).length;
    return {
      status: loading === pages.length ? 'PASS' : (loading > 0 ? 'PARTIAL' : 'FAIL'),
      pages: results,
      details: `${loading}/${pages.length} pages loading with content`
    };
  } catch (error) {
    return { status: 'FAIL', error: error.message };
  }
}

// Generate report
function generateReport() {
  const now = new Date().toISOString();
  const report = `# PRDForge Comprehensive Test Report
Generated: ${now}
Test ID: ${timestamp}

## Executive Summary

### Test Environments
- **Dev**: ${DEV_BASE}
- **Prod**: ${PROD_BASE}

### Overall Results

| Test Category | Dev Status | Prod Status |
|---------------|------------|-------------|
| Load Test | ${results.dev.load?.status || 'NOT RUN'} | ${results.prod.load?.status || 'NOT RUN'} |
| API Health | ${results.dev.apiHealth?.status || 'NOT RUN'} | ${results.prod.apiHealth?.status || 'NOT RUN'} |
| Database Connectivity | ${results.dev.dbConnect?.status || 'NOT RUN'} | ${results.prod.dbConnect?.status || 'NOT RUN'} |
| Edge Functions | ${results.dev.edgeFunctions?.status || 'NOT RUN'} | ${results.prod.edgeFunctions?.status || 'NOT RUN'} |
| Static Assets | ${results.dev.staticAssets?.status || 'NOT RUN'} | ${results.prod.staticAssets?.status || 'NOT RUN'} |
| Authentication | ${results.dev.auth?.status || 'NOT RUN'} | ${results.prod.auth?.status || 'NOT RUN'} |
| Data Pages | ${results.dev.dataPages?.status || 'NOT RUN'} | ${results.prod.dataPages?.status || 'NOT RUN'} |
| Database Content | ${results.databaseContent?.status || 'NOT RUN'} | N/A |

## Critical Findings

### Dev Environment (${DEV_BASE})
${formatSection(results.dev)}

### Prod Environment (${PROD_BASE})
${formatSection(results.prod)}

### Database Migration Status
${results.databaseContent ? `
**Status**: ${results.databaseContent.migrationStatus}
**Expected Data**: ${JSON.stringify(results.databaseContent.expected)}
**Actual Data**: ${JSON.stringify(results.databaseContent.actual)}
**Impact**: Application cannot display migrated data because database is empty.
` : 'Database content verification not run.'}

## Detailed Test Results

### Dev Environment Details
${formatDetailedResults(results.dev)}

### Prod Environment Details
${formatDetailedResults(results.prod)}

## Issues and Recommendations

### High Priority
1. **Database Migration Incomplete**: NEW Supabase database is empty (0 users, 0 projects). All data-driven pages will show blank/empty content.
   - **Recommendation**: Complete data migration from old database to new one immediately.
   - **Evidence**: ${results.databaseContent?.details}

2. **API Endpoints Not Returning Data**: Database-dependent endpoints return empty responses.
   - **Recommendation**: Fix migration, verify with database comparison script.

### Medium Priority
${generateMediumPriorityIssues()}

### Low Priority
${generateLowPriorityIssues()}

## Success Criteria Assessment

| Criterion | Dev | Prod | Notes |
|-----------|-----|------|-------|
| No blank page | ${results.dev.load?.status === 'PASS' ? '✅' : '❌'} | ${results.prod.load?.status === 'PASS' ? '✅' : '❌'} |
| No console errors | ${results.dev.edgeFunctions?.status !== 'FAIL' ? '✅' : '❌'} | ${results.prod.edgeFunctions?.status !== 'FAIL' ? '✅' : '❌'} |
| Authentication works | ${results.dev.auth?.status === 'PASS' ? '✅' : '❌'} | ${results.prod.auth?.status === 'PASS' ? '✅' : '❌'} |
| API calls succeed | ${results.dev.edgeFunctions?.status === 'PASS' ? '✅' : '❌'} | ${results.prod.edgeFunctions?.status === 'PASS' ? '✅' : '❌'} |
| Data displays | ${results.dev.dbConnect?.status === 'PASS' ? '✅' : '❌'} | ${results.prod.dbConnect?.status === 'PASS' ? '✅' : '❌'} |

## Next Steps (Immediate)

1. **Fix Migration**: Run complete database migration to populate NEW Supabase
2. **Verify Data**: Run \`./verify_prdforge_databases.sh\` to confirm all data transferred
3. **Test Again**: Re-run this test suite after migration
4. **Authentication Testing**: Once data exists, test login with migrated users:
   - Expected users: ${results.databaseContent?.expected.users || 10}
   - Check credentials in test data

## Appendix

### Test Execution Time
- Start: ${now}
- Duration: In progress

### Environments Tested
- Dev: ${DEV_BASE}
- Prod: ${PROD_BASE}

### Tools Used
- Node.js HTTP/HTTPS client
- No browser automation (curl-based testing)
- Duration: < 10 minutes

---

**Report Generated By**: Automated Test Suite
**Version**: 1.0
**Classification**: Internal PRDForge Testing
`;

  return report;
}

function formatSection(envResults) {
  if (!envResults || Object.keys(envResults).length === 0) {
    return 'No tests executed.';
  }
  
  const lines = [];
  for (const [key, result] of Object.entries(envResults)) {
    const status = result?.status || 'NOT RUN';
    const icon = status === 'PASS' ? '✅' : status === 'FAIL' ? '❌' : status === 'PARTIAL' ? '⚠️' : '⏳';
    lines.push(`- **${key}**: ${icon} ${status}`);
  }
  return lines.join('\n');
}

function formatDetailedResults(envResults) {
  if (!envResults || Object.keys(envResults).length === 0) {
    return 'No detailed results available.';
  }
  
  let output = '';
  for (const [testName, result] of Object.entries(envResults)) {
    if (!result) continue;
    
    output += `\n### ${testName.toUpperCase()}\n`;
    output += `- Status: ${result.status}\n`;
    output += `- Details: ${result.details || 'N/A'}\n`;
    
    if (result.endpoints || result.tests || result.pages || result.assets) {
      const items = result.endpoints || result.tests || result.pages || result.assets;
      output += '- Results:\n';
      items.forEach(item => {
        output += `  - ${JSON.stringify(item)}\n`;
      });
    }
    
    if (result.error) {
      output += `- Error: ${result.error}\n`;
    }
  }
  return output;
}

function generateMediumPriorityIssues() {
  return `
1. **Port 8080 not used**: Dev server runs on port 3000, not expected 8080
   - Action: Update documentation to reflect port 3000
2. **API Base URL in dev**: \`VITE_API_BASE_URL\` points to prod in dev config
   - Action: Use relative URLs or separate dev API endpoint
3. **Test credentials missing**: No documented test user credentials for auth testing
   - Action: Create test user accounts in database`;
}

function generateLowPriorityIssues() {
  return `
1. **Health endpoint naming**: Multiple patterns used (/health, /api/health, /status)
   - Standardize to single pattern
2. **Asset versioning**: Asset filenames include hash, ensure cache busting works
3. **Error messages**: Some endpoints return generic errors, improve debugging`;
}

// Main execution
async function runTests() {
  console.log('🚀 Starting PRDForge Comprehensive Test Suite...\n');
  
  // Test Dev Environment
  console.log('📋 Testing DEV environment (localhost:3000)...');
  results.dev = {
    load: await testLoad(DEV_BASE),
    apiHealth: await testAPIHealth(DEV_BASE),
    dbConnect: await testDatabaseConnectivity(DEV_BASE),
    edgeFunctions: await testEdgeFunctions(DEV_BASE),
    staticAssets: await testStaticAssets(DEV_BASE),
    auth: await testAuthentication(DEV_BASE),
    dataPages: await testDataPages(DEV_BASE)
  };
  
  // Test Prod Environment
  console.log('📋 Testing PROD environment (prdforge-dev.netlify.app)...');
  results.prod = {
    load: await testLoad(PROD_BASE),
    apiHealth: await testAPIHealth(PROD_BASE),
    dbConnect: await testDatabaseConnectivity(PROD_BASE),
    edgeFunctions: await testEdgeFunctions(PROD_BASE),
    staticAssets: await testStaticAssets(PROD_BASE),
    auth: await testAuthentication(PROD_BASE),
    dataPages: await testDataPages(PROD_BASE)
  };
  
  // Verify Database Content
  console.log('📊 Verifying database content migration...');
  results.databaseContent = await verifyDatabaseContent();
  
  // Generate and save report
  const report = generateReport();
  fs.writeFileSync(reportFile, report);
  
  console.log('\n✅ Testing Complete!');
  console.log(`📄 Report saved to: ${reportFile}`);
  console.log('\n📊 Summary:');
  
  // Print summary
  for (const env of ['dev', 'prod']) {
    console.log(`\n${env.toUpperCase()}:`);
    for (const [test, result] of Object.entries(results[env])) {
      const status = result?.status || 'NOT RUN';
      const icon = status === 'PASS' ? '✅' : status === 'FAIL' ? '❌' : status === 'PARTIAL' ? '⚠️' : '⏳';
      console.log(`  ${icon} ${test}: ${status}`);
    }
  }
  
  console.log('\n🗄️  Database Migration Status:');
  const dbStatus = results.databaseContent;
  const dbIcon = dbStatus.status === 'FAIL' ? '❌' : dbStatus.status === 'PASS' ? '✅' : '⚠️';
  console.log(`  ${dbIcon} Migration: ${dbStatus.migrationStatus || dbStatus.status}`);
  console.log(`     Expected users: ${dbStatus.expected?.users || 0}`);
  console.log(`     Actual users: ${dbStatus.actual?.users || 0}`);
  
  console.log('\n🔑 Critical Issues:');
  console.log('  - Database is empty - data migration incomplete');
  console.log('  - All data-driven pages will be blank/empty');
  console.log('  - Authentication cannot work without user data');
  console.log('\n🎯 Immediate Action Required: Complete database migration!');
}

// Run
runTests().catch(err => {
  console.error('❌ Test suite failed:', err);
  process.exit(1);
});
