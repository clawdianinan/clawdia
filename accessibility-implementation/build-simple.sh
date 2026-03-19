#!/bin/bash

echo "Creating Accessibility Implementation Package..."

# Create dist directory structure
mkdir -p dist/{components/accessibility,hooks,utils,styles,examples}

# Copy source files
echo "Copying source files..."
cp -r src/components/accessibility/*.tsx dist/components/accessibility/
cp -r src/hooks/*.ts dist/hooks/
cp -r src/utils/*.ts dist/utils/
cp -r src/styles/*.css dist/styles/
cp src/index.ts dist/

# Copy examples
echo "Copying examples..."
cp examples/App.tsx dist/examples/

# Copy package files
echo "Copying package files..."
cp package.json README.md IMPLEMENTATION_SUMMARY.md tsconfig.json dist/

# Create a simple package.json for distribution
cat > dist/package.json << 'EOF'
{
  "name": "accessibility-implementation",
  "version": "1.0.0",
  "description": "Comprehensive accessibility features for React applications",
  "main": "index.ts",
  "types": "index.ts",
  "files": [
    "components/**/*",
    "hooks/**/*",
    "utils/**/*",
    "styles/**/*",
    "examples/**/*",
    "*.ts",
    "*.md"
  ],
  "keywords": [
    "accessibility",
    "a11y",
    "react",
    "screen-reader",
    "keyboard-navigation",
    "wcag"
  ],
  "author": "Clawdia AI",
  "license": "MIT",
  "peerDependencies": {
    "react": ">=16.8.0",
    "react-dom": ">=16.8.0"
  }
}
EOF

echo "Package created in dist/ directory!"
echo ""
echo "To use this package:"
echo "1. Copy the dist/ folder to your project"
echo "2. Import from the components, hooks, or utils as needed"
echo "3. Include the CSS: import './dist/styles/accessibility.css'"
echo ""
echo "See IMPLEMENTATION_SUMMARY.md for detailed usage instructions."