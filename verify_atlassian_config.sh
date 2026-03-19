#!/bin/bash

# Load Atlassian token from .env.atlassian
if [ -f .env.atlassian ]; then
    source .env.atlassian
    echo "✅ Loaded Atlassian token from .env.atlassian"
    echo "   Variable name: ATLASSIAN_API_TOKEN"
    echo "   Token length: ${#ATLASSIAN_API_TOKEN} characters"
    echo "   First 20 chars: ${ATLASSIAN_API_TOKEN:0:20}..."
    echo "   Last 20 chars: ...${ATLASSIAN_API_TOKEN: -20}"
    echo ""
    echo "📋 Token stored in:"
    echo "   1. .env.atlassian (local config file)"
    echo "   2. ~/.zshrc (persistent shell profile)"
    echo "   3. memory/2026-03-18-0415.md (secure memory)"
    echo ""
    echo "🔧 Usage examples:"
    echo "   # In shell scripts:"
    echo "   source .env.atlassian"
    echo "   # Jira:"
    echo "   curl -H \"Authorization: Bearer \$ATLASSIAN_API_TOKEN\" https://your-domain.atlassian.net/rest/api/3/..."
    echo "   # Trello:"
    echo "   curl -H \"Authorization: OAuth oauth_consumer_key=\\\"...\\\", oauth_token=\\\"\$ATLASSIAN_API_TOKEN\\\"\" ..."
    echo ""
    echo "   # Direct usage:"
    echo "   ATLASSIAN_API_TOKEN=\"\$(grep '^ATLASSIAN_API_TOKEN=' .env.atlassian | cut -d'=' -f2)\""
    echo "   echo \$ATLASSIAN_API_TOKEN"
else
    echo "❌ .env.atlassian file not found"
    exit 1
fi