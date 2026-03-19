// Test script to verify environment variables are loaded
import { config } from 'dotenv';
config();

console.log('Testing PRDForge environment variable configuration...\n');

// Check required payment environment variables
const requiredVars = [
  'STRIPE_SECRET_KEY',
  'STRIPE_WEBHOOK_SECRET',
  'PAYPAL_CLIENT_ID',
  'PAYPAL_CLIENT_SECRET',
  'PAYSTACK_SECRET_KEY',
  'NOWPAYMENTS_API_KEY',
  'NOWPAYMENTS_IPN_SECRET'
];

console.log('Required Payment Environment Variables:');
console.log('=======================================');

let allPresent = true;
for (const varName of requiredVars) {
  const value = process.env[varName];
  const isPresent = value && value !== 'placeholder_configure_me' && value !== '';
  const status = isPresent ? '✅ PRESENT' : '❌ MISSING/PLACEHOLDER';
  
  console.log(`${varName}: ${status}`);
  if (isPresent) {
    // Show first few chars for verification (but not full secret)
    const displayValue = value.length > 20 ? `${value.substring(0, 10)}...${value.substring(value.length - 4)}` : '***';
    console.log(`  Value: ${displayValue}`);
  } else {
    console.log(`  Value: ${value || '(empty)'}`);
    allPresent = false;
  }
  console.log();
}

// Check Supabase variables
console.log('\nSupabase Environment Variables:');
console.log('===============================');
const supabaseVars = [
  'VITE_SUPABASE_URL',
  'VITE_SUPABASE_PUBLISHABLE_KEY',
  'VITE_SUPABASE_PROJECT_ID'
];

for (const varName of supabaseVars) {
  const value = process.env[varName];
  const isPresent = value && value !== '';
  const status = isPresent ? '✅ PRESENT' : '❌ MISSING';
  
  console.log(`${varName}: ${status}`);
  if (isPresent && varName.includes('KEY')) {
    // Show partial key for verification
    const displayValue = value.length > 20 ? `${value.substring(0, 15)}...` : '***';
    console.log(`  Value: ${displayValue}`);
  }
  console.log();
}

// Summary
console.log('\nSummary:');
console.log('========');
if (allPresent) {
  console.log('✅ All payment environment variables are configured!');
  console.log('   Sheba can proceed with billing validation tests.');
} else {
  console.log('❌ Some payment environment variables are missing or contain placeholders.');
  console.log('   Sheba cannot execute billing validation tests until all are configured.');
  console.log('\nNext steps:');
  console.log('1. Replace placeholder values with actual API keys');
  console.log('2. Test payment functions with the configured variables');
  console.log('3. Update documentation with configuration status');
}

// Test if variables can be accessed by payment functions
console.log('\nPayment Function Access Test:');
console.log('============================');
console.log('Environment variables should be accessible via:');
console.log('- Deno.env.get("VAR_NAME") in Supabase Edge Functions');
console.log('- process.env.VAR_NAME in Node.js/backend code');
console.log('- import.meta.env.VAR_NAME in Vite frontend (prefixed with VITE_)');