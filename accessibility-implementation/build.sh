#!/bin/bash

echo "Building Accessibility Implementation Package..."

# Create dist directory
mkdir -p dist/styles

# Compile TypeScript
echo "Compiling TypeScript..."
npx tsc

# Copy CSS files
echo "Copying CSS files..."
cp src/styles/accessibility.css dist/styles/

# Create package files
echo "Creating package files..."
cp package.json README.md dist/

echo "Build complete! Files are in dist/ directory."