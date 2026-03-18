// Test script for MCP server
const { spawn } = require('child_process');
const { Writable } = require('stream');

// Create a simple test message
const testMessage = JSON.stringify({
  jsonrpc: '2.0',
  id: 1,
  method: 'tools/list',
  params: {}
}) + '\n';

console.log('Starting MCP server test...');

// Start the MCP server
const server = spawn('node', ['dist/index.js'], {
  cwd: __dirname,
  stdio: ['pipe', 'pipe', 'pipe']
});

// Handle server output
server.stdout.on('data', (data) => {
  console.log('Server stdout:', data.toString());
});

server.stderr.on('data', (data) => {
  console.log('Server stderr:', data.toString());
});

// Send test message
server.stdin.write(testMessage);
server.stdin.end();

// Wait for response
setTimeout(() => {
  console.log('Test completed');
  server.kill();
  process.exit(0);
}, 2000);