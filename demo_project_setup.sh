#!/bin/bash
# Demo Project Setup for Cursor CLI Agent Training
# Shows how to link Cursor CLI to a local project version

set -e

echo "🚀 Demo: Linking Cursor CLI to Local Project Version"
echo "====================================================="

# Create demo project
DEMO_DIR="/tmp/demo-cursor-project-$(date +%s)"
echo "Creating demo project at: $DEMO_DIR"
mkdir -p "$DEMO_DIR"
cd "$DEMO_DIR"

# Initialize as a Node.js project
echo "1. Initializing Node.js project..."
cat > package.json << 'EOF'
{
  "name": "demo-cursor-project",
  "version": "1.0.0",
  "description": "Demo project for Cursor CLI agent training",
  "main": "src/index.js",
  "scripts": {
    "start": "node src/index.js",
    "test": "jest",
    "dev": "nodemon src/index.js"
  },
  "dependencies": {
    "express": "^4.18.0"
  },
  "devDependencies": {
    "jest": "^29.0.0",
    "nodemon": "^3.0.0"
  }
}
EOF

# Create basic project structure
echo "2. Creating project structure..."
mkdir -p src
mkdir -p tests
mkdir -p config

# Create initial files
cat > src/index.js << 'EOF'
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

app.get('/', (req, res) => {
  res.json({ message: 'Welcome to Demo API', version: '1.0.0' });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
EOF

cat > tests/index.test.js << 'EOF'
const request = require('supertest');
const app = require('../src/index');

describe('Demo API', () => {
  test('GET / returns welcome message', async () => {
    const response = await request(app).get('/');
    expect(response.status).toBe(200);
    expect(response.body.message).toBe('Welcome to Demo API');
  });

  test('GET /health returns healthy status', async () => {
    const response = await request(app).get('/health');
    expect(response.status).toBe(200);
    expect(response.body.status).toBe('healthy');
  });
});
EOF

# Initialize git
echo "3. Initializing git repository..."
git init
git add .
git commit -m "Initial commit: Demo project setup"

# Now demonstrate Cursor CLI integration
echo ""
echo "4. Demonstrating Cursor CLI Integration..."
echo "-------------------------------------------"

# Show current project state
echo "Current project structure:"
find . -type f -name "*.js" -o -name "*.json" | sort

echo ""
echo "5. Using Cursor CLI within project context..."
echo "----------------------------------------------"

# Example 1: Analyze project
echo "Example 1: Analyzing project structure with Cursor CLI"
agent chat "Analyze this Node.js project structure and suggest improvements" --print --trust

echo ""
echo "Example 2: Adding a new feature"
# Create feature branch
git checkout -b feat/user-endpoints

# Use Cursor CLI to add user endpoints
agent chat "Add user management endpoints to the Express app: GET /users, POST /users, GET /users/:id" --print --trust

echo ""
echo "Example 3: Updating tests"
agent chat "Update tests to cover the new user endpoints" --print --trust

echo ""
echo "Example 4: Documentation"
agent chat "Update README.md with API documentation for the new endpoints" --print --trust

# Show git status
echo ""
echo "6. Git integration demonstration..."
echo "------------------------------------"
echo "Current branch: $(git branch --show-current)"
echo ""
echo "Staged changes:"
git diff --cached --name-status || echo "No staged changes"

# Commit the changes
echo ""
echo "7. Committing changes with Cursor CLI help..."
agent chat "Generate a descriptive commit message for the user endpoints feature" --print --trust

echo ""
echo "Example commit command:"
echo "  git add ."
echo "  git commit -m 'feat: add user management endpoints with tests and docs'"

# Show project summary
echo ""
echo "📊 Demo Project Summary"
echo "======================="
echo "Project: demo-cursor-project"
echo "Location: $DEMO_DIR"
echo "Files created: $(find . -type f | wc -l)"
echo "Git commits: $(git log --oneline | wc -l)"
echo "Branches: $(git branch | wc -l | xargs)"

# Create project configuration
echo ""
echo "8. Creating project configuration for agents..."
echo "------------------------------------------------"

# Run the project configuration script
bash /Users/clawdia/.openclaw/workspace/project_cursor_config.sh "demo-cursor-project" "$DEMO_DIR"

echo ""
echo "🎯 Training Complete!"
echo "====================="
echo ""
echo "Agents have learned:"
echo "1. ✅ Project setup and initialization"
echo "2. ✅ Working within project directory context"
echo "3. ✅ Using Cursor CLI for feature development"
echo "4. ✅ Git integration and version control"
echo "5. ✅ Project-specific configuration"
echo "6. ✅ Linking to local project version"
echo ""
echo "📁 Project preserved at: $DEMO_DIR"
echo ""
echo "To continue training:"
echo "1. cd $DEMO_DIR"
echo "2. Review AGENTS.md for instructions"
echo "3. Use ./cursor-agent-helper.sh for guided workflows"
echo "4. Practice with: agent chat \"<task>\" --print --trust"
echo ""
echo "Real project integration steps:"
echo "1. Navigate to your project: cd /path/to/your/project"
echo "2. Run configuration: bash /Users/clawdia/.openclaw/workspace/project_cursor_config.sh \"Your Project\" \$(pwd)"
echo "3. Train agents using the created helper scripts"
echo "4. Commit .cursor/ directory to version control"