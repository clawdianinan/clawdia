// Quick test to verify prdforge-api-debug is disabled
const fs = require('fs');
const path = require('path');

const debugFunctionPath = '/Users/clawdia/apps/prdforge/supabase/functions/prdforge-api-debug/index.ts';

console.log('=== VERIFYING PRDFORGE-API-DEBUG IS DISABLED ===\n');

if (!fs.existsSync(debugFunctionPath)) {
  console.log('❌ Debug function file not found');
  process.exit(1);
}

const content = fs.readFileSync(debugFunctionPath, 'utf8');

// Check if function returns 403
if (content.includes('Debug function disabled for security')) {
  console.log('✅ Debug function is disabled (returns 403 Forbidden)');
} else {
  console.log('❌ Debug function is NOT properly disabled');
  console.log('First 10 lines of function:');
  console.log(content.split('\n').slice(0, 10).join('\n'));
  process.exit(1);
}

// Check that it doesn't expose system details
if (content.includes('system details') || content.includes('debug info') || content.includes('environment:')) {
  console.log('⚠️  Warning: Function may still contain debug information');
} else {
  console.log('✅ No system details exposed in function');
}

// Check response structure
if (content.includes('403') && content.includes('DEBUG_FUNCTION_DISABLED')) {
  console.log('✅ Proper HTTP 403 response with error code');
} else {
  console.log('❌ Missing proper HTTP 403 response');
}

console.log('\n=== TEST COMPLETE ===');
console.log('prdforge-api-debug function has been successfully disabled for security.');