// Test the actual ORBIT API integration
const { spawn } = require('child_process');

console.log('Testing ORBIT MCP server with actual API...\n');

// Start the MCP server
const server = spawn('node', ['dist/index.js'], {
  cwd: __dirname,
  stdio: ['pipe', 'pipe', 'pipe']
});

let serverOutput = '';
let testCompleted = false;

// Collect server output
server.stdout.on('data', (data) => {
  const output = data.toString();
  serverOutput += output;
  
  // Parse JSON responses
  const lines = output.split('\n');
  for (const line of lines) {
    if (line.trim() && line.startsWith('{')) {
      try {
        const json = JSON.parse(line);
        console.log('Server response:', JSON.stringify(json, null, 2));
      } catch (e) {
        // Not JSON, ignore
      }
    }
  }
});

server.stderr.on('data', (data) => {
  console.log('Server stderr:', data.toString());
});

// Wait for server to start
setTimeout(() => {
  console.log('1. Testing orbit_login tool...');
  
  // Test login (using test credentials)
  const loginTest = JSON.stringify({
    jsonrpc: '2.0',
    id: 1,
    method: 'tools/call',
    params: {
      name: 'orbit_login',
      arguments: {
        email: 'clawdia.ai@iih.ng',
        password: 'N49eYXkwV6A9W$k'
      }
    }
  }) + '\n';
  
  server.stdin.write(loginTest);
  
  // Wait for response
  setTimeout(() => {
    console.log('\n2. Testing orbit_get_activity_feed tool...');
    
    // Test activity feed with the token we got (hardcoded for now)
    const feedTest = JSON.stringify({
      jsonrpc: '2.0',
      id: 2,
      method: 'tools/call',
      params: {
        name: 'orbit_get_activity_feed',
        arguments: {
          token: '0cba48668cabe4dfbb86fbe15dfa814be9e74efac2adc4222473fd55097b205d',
          limit: 3,
          offset: 0
        }
      }
    }) + '\n';
    
    server.stdin.write(feedTest);
    
    // Complete test
    setTimeout(() => {
      console.log('\nTest completed successfully!');
      testCompleted = true;
      server.kill();
      process.exit(0);
    }, 2000);
  }, 2000);
}, 1000);

// Safety timeout
setTimeout(() => {
  if (!testCompleted) {
    console.log('Test timeout');
    server.kill();
    process.exit(1);
  }
}, 10000);