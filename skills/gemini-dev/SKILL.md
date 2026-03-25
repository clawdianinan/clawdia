# Skill: Gemini CLI Development

## Purpose
Integrate Gemini CLI for cost-effective AI coding and text generation using Google's Gemini models.

## Overview
Gemini CLI provides access to Google's Gemini models through a terminal interface. Balanced cost/quality ratio for general development tasks.

## Prerequisites

### Installation
```bash
# Already installed via npm/yarn/pnpm
# Binary: /opt/homebrew/bin/gemini
```

### API Key Configuration
```bash
# Set environment variable (already done)
export GEMINI_API_KEY="AIzaSyAIlDA0sH91OViySTCEktWbsVxZ-K_odMM"

# Verify setup
gemini --prompt "3 + 3 ="
# Should respond with correct answer
```

## Available Features

### Text/Code Generation
- Code completion and generation
- Bug fixing and debugging
- Code review and optimization
- Documentation generation
- Q&A and explanations

### Model Support
- Default: Latest Gemini model
- Can specify model with `--model` flag
- Supports various Gemini model sizes

## Commands

### Basic Usage
```bash
# Interactive mode (default)
gemini "Write a React component for a login form"

# Non-interactive (headless) mode
gemini --prompt "Fix the bug in this Python function"

# With model specification
gemini --model "gemini-2.0-flash" --prompt "Optimize this SQL query"

# Interactive prompt then continue
gemini --prompt-interactive "Start with this code review"
```

### Advanced Features
```bash
# Sandbox mode (safer)
gemini --sandbox --prompt "Analyze this code"

# YOLO mode (auto-approve all actions)
gemini --yolo --prompt "Generate and test code"

# Specific approval mode
gemini --approval-mode auto_edit --prompt "Refactor code"

# With extensions
gemini --extensions code-review,security-scan --prompt "Review this code"
```

### Session Management
```bash
# Resume latest session
gemini --resume latest

# Resume specific session
gemini --resume 3

# List available extensions
gemini --list-extensions
```

## Integration with OpenClaw

### For Development Agents
```bash
# General coding tasks
gemini --prompt "Implement feature based on requirements"

# Code review
gemini --prompt "Review this code for bugs and improvements"

# Documentation
gemini --prompt "Generate documentation for this API"
```

### Cost-Effective Workflow
```bash
# When cost is a concern but speed needed
gemini --prompt "Quick bug fix"  # Lower cost than Claude/Codex

# For medium-complexity tasks
gemini --prompt "Implement medium-complexity feature"
```

## Use Cases

### 1. General Coding
```bash
# Component generation
gemini --prompt "Create a responsive navbar component with React and Tailwind CSS"

# API implementation
gemini --prompt "Implement REST API endpoints for user management"

# Utility functions
gemini --prompt "Write utility functions for date formatting and validation"
```

### 2. Bug Fixing & Debugging
```bash
# Debug assistance
gemini --prompt "Debug this error: [paste error]"

# Performance optimization
gemini --prompt "Optimize this slow database query"

# Security fixes
gemini --prompt "Fix security vulnerability in this authentication code"
```

### 3. Code Review & Quality
```bash
# Code review
gemini --prompt "Review this code for best practices and potential issues"

# Refactoring suggestions
gemini --prompt "Suggest refactoring improvements for this module"

# Testing
gemini --prompt "Write unit tests for this function"
```

### 4. Documentation
```bash
# API documentation
gemini --prompt "Generate OpenAPI/Swagger documentation for these endpoints"

# Code comments
gemini --prompt "Add comprehensive comments to this code"

# README generation
gemini --prompt "Create a README.md for this project"
```

## Model Selection

### Default Model
- Automatically uses latest appropriate Gemini model
- Good balance of cost, speed, and quality

### Specifying Models
```bash
# For faster, lighter tasks
gemini --model "gemini-2.0-flash" --prompt "Simple task"

# For more complex reasoning (if available)
gemini --model "gemini-2.0-pro" --prompt "Complex analysis"
```

## Cost Optimization

### Why Gemini is Cost-Effective
1. **Competitive pricing** - Often lower than OpenAI/Anthropic
2. **Free tier** - Generous free usage limits
3. **Efficient models** - Good performance per token

### Usage Strategy
```bash
# Use for medium-priority tasks
gemini --prompt "Implement standard feature"

# Avoid for extremely complex tasks (use Claude instead)
# Use for tasks where 90% quality is acceptable (vs 95%+)
```

## Workflow Integration

### MCP Server Support
```bash
# Manage MCP servers
gemini mcp list
gemini mcp install [server-name]

# Use with specific servers
gemini --allowed-mcp-server-names canva,github --prompt "Task"
```

### Policy Engine
```bash
# Load policy files
gemini --policy ./security-policy.json --prompt "Secure code"

# Control tool permissions
gemini --policy ./code-only-policy.json --prompt "Generate code"
```

### Extensions System
```bash
# List available extensions
gemini extensions list

# Install extension
gemini extensions install code-review

# Use specific extensions
gemini --extensions code-review,test-gen --prompt "Task"
```

## Best Practices

### 1. Prompt Engineering
```bash
# Be specific
gemini --prompt "Create a React component that: 1) Has form validation, 2) Uses Tailwind, 3) Handles errors"

# Provide context
gemini --prompt "Given this existing code: [code], add error handling"

# Chain prompts
gemini --prompt-interactive "First, analyze this problem"  # Then continue interactively
```

### 2. Output Control
```bash
# For scripts/automation
gemini --prompt "Generate JSON output"  # Request specific format

# For code generation
gemini --prompt "Output only code, no explanations"
```

### 3. Error Handling
```bash
# Use sandbox for unknown code
gemini --sandbox --prompt "Execute this potentially risky code"

# Review before accepting
# Don't use --yolo unless absolutely certain
```

### 4. Session Management
```bash
# Use resume for related work
gemini --resume latest --prompt "Continue from previous"

# Start fresh for unrelated tasks
gemini --prompt "New unrelated task"
```

## Performance Tips

### Speed Optimization
```bash
# Use --prompt for non-interactive (faster)
gemini --prompt "Task"  # Faster than interactive

# Simpler models for simple tasks
gemini --model "gemini-2.0-flash" --prompt "Simple fix"
```

### Quality Optimization
```bash
# Provide more context
gemini --prompt "Context: [detailed context]. Task: [specific task]"

# Use interactive for complex work
gemini --prompt-interactive "Start complex analysis"  # Then iterate
```

## Integration Examples

### With OpenClaw Agents
```bash
# Trinity (Implementation - cost-sensitive)
gemini --prompt "Implement the shopping cart feature with medium priority"

# Morpheus (QA - general testing)
gemini --prompt "Write test cases for this module"

# Cypher (Security - initial scan)
gemini --prompt "Perform initial security scan on this code"
```

### In Development Scripts
```bash
#!/bin/bash
# Automated code generation script
PROMPT="Generate a $1 component with props: $2"
OUTPUT=$(gemini --prompt "$PROMPT")
echo "$OUTPUT" > "src/components/$1.js"
```

### CI/CD Pipeline
```bash
# Automated code review in CI
gemini --prompt "Review this PR diff for issues" --output-format json > review.json
```

## Cost Tracking

### Monitoring Usage
1. **Google AI Studio Dashboard** - Track API usage
2. **Set budget alerts** - In Google Cloud Console
3. **Free tier monitoring** - Stay within limits

### Optimization Strategies
- Use for medium-complexity tasks
- Batch related requests
- Cache common responses
- Use simpler models when possible

## Troubleshooting

### Common Issues

1. **API Key not set**
   ```bash
   echo $GEMINI_API_KEY  # Should show key
   export GEMINI_API_KEY="your_key"  # Set if missing
   ```

2. **Rate limiting**
   ```bash
   # Wait and retry
   # Check Google Cloud Console for quotas
   ```

3. **Model not available**
   ```bash
   # Use default model
   gemini --prompt "Task"  # Let it choose
   ```

4. **Output quality issues**
   ```bash
   # Provide more context
   # Use more specific prompts
   # Consider switching to Claude for critical tasks
   ```

### Debug Mode
```bash
# Enable debug console
gemini --debug --prompt "Task"
# Press F12 for debug console in interactive mode
```

## Security Considerations

### Safe Usage
```bash
# Use sandbox for unknown code
gemini --sandbox --prompt "Execute this code"

# Review generated code
# Never auto-execute untrusted code
```

### Policy Configuration
```bash
# Create policy files for different risk levels
# Restrict tools based on task
```

## Updates & Maintenance

### Check Version
```bash
# Version info in help
gemini --help | head -5
```

### Update CLI
```bash
# Update via package manager
# npm update -g @google/gemini
# or check gemini CLI docs
```

---

**Integration**: Use `dev-tool-router` to determine when Gemini CLI is the best choice (cost-sensitive, general coding, balanced tasks).