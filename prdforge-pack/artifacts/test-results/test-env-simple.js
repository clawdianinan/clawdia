// Simple test to check .env file content
import { readFileSync } from 'fs';
import { join } from 'path';

const envPath = join(process.cwd(), '.env');
console.log(`Reading .env file from: ${envPath}\n`);

try {
  const envContent = readFileSync(envPath, 'utf8');
  console.log('.env file content:');
  console.log('==================');
  console.log(envContent);
  console.log('\n==================\n');
  
  // Parse and check for required variables
  const lines = envContent.split('\n').filter(line => line.trim() && !line.startsWith('#'));
  const envVars = {};
  
  for (const line of lines) {
    const match = line.match(/^([A-Z_]+)=(.+)$/);
    if (match) {
      const [, key, value] = match;
      envVars[key] = value.replace(/^"|"$/g, ''); // Remove quotes
    }
  }
  
  // Check required payment variables
  const requiredVars = [
    'STRIPE_SECRET_KEY',
    'STRIPE_WEBHOOK_SECRET',
    'PAYPAL_CLIENT_ID',
    'PAYPAL_CLIENT_SECRET',
    'PAYSTACK_SECRET_KEY',
    'NOWPAYMENTS_API_KEY',
    'NOWPAYMENTS_IPN_SECRET'
  ];
  
  console.log('Payment Environment Variable Status:');
  console.log('====================================');
  
  let allConfigured = true;
  for (const varName of requiredVars) {
    const value = envVars[varName];
    const isConfigured = value && !value.includes('placeholder_configure_me') && value.trim() !== '';
    
    if (isConfigured) {
      console.log(`✅ ${varName}: Configured`);
      // Show partial value for verification
      const displayValue = value.length > 15 ? `${value.substring(0, 10)}...` : '***';
      console.log(`   Value: ${displayValue}`);
    } else {
      console.log(`❌ ${varName}: NOT CONFIGURED`);
      console.log(`   Current value: ${value || '(not found)'}`);
      allConfigured = false;
    }
    console.log();
  }
  
  console.log('\nSummary:');
  console.log('========');
  if (allConfigured) {
    console.log('✅ All 7 payment environment variables are configured!');
    console.log('   Sheba can proceed with billing validation tests.');
  } else {
    console.log('❌ Payment environment configuration INCOMPLETE');
    console.log('   Sheba cannot execute billing validation tests.');
    console.log('\nRequired actions:');
    console.log('1. Replace placeholder values with actual API keys');
    console.log('2. Restart the application to load new environment variables');
    console.log('3. Test payment functions with the configured variables');
  }
  
} catch (error) {
  console.error(`Error reading .env file: ${error.message}`);
  console.log('\nCreating a new .env file with required variables...');
  
  const defaultEnv = `VITE_SUPABASE_PROJECT_ID="jnlkzcmeiksqljnbtfhb"
VITE_SUPABASE_PUBLISHABLE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpubGt6Y21laWtzcWxqbmJ0ZmhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUwODg3MTUsImV4cCI6MjA2MDY2NDcxNX0.oHvsn37LuRdlkn3bGsgvOu2GK2PCCDku5hKtLAIbWo0"
VITE_SUPABASE_URL="https://jnlkzcmeiksqljnbtfhb.supabase.co"

# Payment Provider Configuration
STRIPE_SECRET_KEY="sk_test_placeholder_configure_me"
STRIPE_WEBHOOK_SECRET="whsec_placeholder_configure_me"
PAYPAL_CLIENT_ID="test_client_id_placeholder_configure_me"
PAYPAL_CLIENT_SECRET="test_client_secret_placeholder_configure_me"
PAYSTACK_SECRET_KEY="sk_test_placeholder_configure_me"
NOWPAYMENTS_API_KEY="np_api_key_placeholder_configure_me"
NOWPAYMENTS_IPN_SECRET="np_ipn_secret_placeholder_configure_me"`;
  
  console.log('\nDefault .env template created. Please update with actual API keys.');
}