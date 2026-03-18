// Quick test of fixed MCP server
const { spawn } = require('child_process');

console.log('Testing ORBIT MCP server with fixed token handling...\n');

// Get current token first
const https = require('https');

const loginData = JSON.stringify({
  p_email: 'clawdia.ai@iih.ng',
  p_password: 'N49eYXkwV6A9W$k'
});

const options = {
  hostname: 'jnlkzcmeiksqljnbtfhb.supabase.co',
  path: '/rest/v1/rpc/orbit_login',
  method: 'POST',
  headers: {
    'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpubGt6Y21laWtzcWxqbmJ0ZmhiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUwODg3MTUsImV4cCI6MjA2MDY2NDcxNX0.oHvsn37LuRdlkn3bGsgvOu2GK2PCCDku5hKtLAIbWo0',
    'Content-Type': 'application/json',
    'Prefer': 'return=representation',
    'Content-Length': loginData.length
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
      if (result.success && result.token) {
        console.log('Got token:', result.token.substring(0, 20) + '...');
        testMcpServer(result.token);
      } else {
        console.log('Login failed:', data);
      }
    } catch (e) {
      console.log('Error parsing response:', e.message);
    }
  });
});

req.on('error', (error) => {
  console.error('Request error:', error);
});

req.write(loginData);
req.end();

function testMcpServer(token) {
  // Start the MCP server
  const server = spawn('node', ['dist/index.js'], {
    cwd: __dirname,
    stdio: ['pipe', 'pipe', 'pipe']
  });

  server.stderr.on('data', (data) => {
    console.log('Server:', data.toString().trim());
  });

  // Wait for server to start
  setTimeout(() => {
    console.log('\nTesting activity feed with token...');
    
    const feedTest = JSON.stringify({
      jsonrpc: '2.0',
      id: 1,
      method: 'tools/call',
      params: {
        name: 'orbit_get_activity_feed',
        arguments: {
          token: token,
          limit: 2,
          offset: 0
        }
      }
    }) + '\n';
    
    server.stdin.write(feedTest);
    
    // Listen for response
    server.stdout.on('data', (data) => {
      const output = data.toString();
      try {
        const json = JSON.parse(output);
        if (json.result && json.result.content) {
          console.log('\nActivity feed response received!');
          const text = json.result.content[0].text;
          try {
            const feedData = JSON.parse(text);
            if (feedData.data && Array.isArray(feedData.data)) {
              console.log(`Success! Got ${feedData.data.length} activity items`);
              console.log('First item:', feedData.data[0].content?.substring(0, 100) + '...');
            } else {
              console.log('Response:', text.substring(0, 200) + '...');
            }
          } catch (e) {
            console.log('Response:', text.substring(0, 200) + '...');
          }
        }
      } catch (e) {
        // Not JSON
      }
    });
    
    // Complete test
    setTimeout(() => {
      console.log('\nTest completed!');
      server.kill();
      process.exit(0);
    }, 3000);
  }, 1000);
}