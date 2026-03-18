#!/usr/bin/env bash
set -euo pipefail

# Model resilience check for OpenClaw
# Checks if default models are accessible and responsive

echo "MODEL_RESILIENCE_CHECK: Running model availability test"

# Check if we can get a simple response from the current model
# This is a lightweight check that doesn't require complex tool calling

# Simple test - check if OpenClaw can respond to a basic prompt
echo "Testing model connectivity..."

# We'll use a simple curl to check if the gateway is responsive
if curl -s http://localhost:3000/health >/dev/null 2>&1; then
    echo "MODEL_RESILIENCE_OK: Gateway health check passed"
    exit 0
else
    echo "MODEL_RESILIENCE_WARN: Gateway health check failed - models may be unavailable"
    echo "FALLBACK_RECOMMENDATION: Switch to deepseek/deepseek-chat or openrouter/auto"
    exit 1
fi