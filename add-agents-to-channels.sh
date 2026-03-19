#!/bin/bash
# Add all 6 agents to appropriate Slack channels

TOKEN="xoxp-10752295117408-10721969604214-10720956806053-2d89834682ea00843afbce63f78d73a1"

# Agent user IDs (from previous output)
declare -A AGENTS=(
    ["trinity"]="U0ALV2DSETH"
    ["fela"]="U0AMPCW6NU9"
    ["shuri"]="U0AMPCTAG1X"
    ["ebun"]="U0AM444RY75"
    ["nova"]="U0AMPCUUT33"
    ["sheba"]="U0AME3HL9LL"
)

# Get channel IDs
echo "🔍 Getting channel IDs..."
CHANNELS_RESPONSE=$(curl -s -X GET "https://slack.com/api/conversations.list?types=public_channel&limit=100" \
  -H "Authorization: Bearer $TOKEN")

# Extract channel IDs
PRDFORGE_LAUNCH=$(echo "$CHANNELS_RESPONSE" | python3 -c "
import sys,json
data=json.load(sys.stdin)
if data.get('ok'):
    for channel in data.get('channels', []):
        if channel.get('name') == 'prdforge-launch':
            print(channel.get('id'))
" 2>/dev/null)

PHASE1=$(echo "$CHANNELS_RESPONSE" | python3 -c "
import sys,json
data=json.load(sys.stdin)
if data.get('ok'):
    for channel in data.get('channels', []):
        if channel.get('name') == 'phase1-stabilization':
            print(channel.get('id'))
" 2>/dev/null)

PHASE2=$(echo "$CHANNELS_RESPONSE" | python3 -c "
import sys,json
data=json.load(sys.stdin)
if data.get('ok'):
    for channel in data.get('channels', []):
        if channel.get('name') == 'phase2-qa-uat':
            print(channel.get('id'))
" 2>/dev/null)

PHASE3=$(echo "$CHANNELS_RESPONSE" | python3 -c "
import sys,json
data=json.load(sys.stdin)
if data.get('ok'):
    for channel in data.get('channels', []):
        if channel.get('name') == 'phase3-commercial':
            print(channel.get('id'))
" 2>/dev/null)

PHASE4=$(echo "$CHANNELS_RESPONSE" | python3 -c "
import sys,json
data=json.load(sys.stdin)
if data.get('ok'):
    for channel in data.get('channels', []):
        if channel.get('name') == 'phase4-gtm':
            print(channel.get('id'))
" 2>/dev/null)

AGENT_COORD=$(echo "$CHANNELS_RESPONSE" | python3 -c "
import sys,json
data=json.load(sys.stdin)
if data.get('ok'):
    for channel in data.get('channels', []):
        if channel.get('name') == 'agent-coordination':
            print(channel.get('id'))
" 2>/dev/null)

DECISIONS=$(echo "$CHANNELS_RESPONSE" | python3 -c "
import sys,json
data=json.load(sys.stdin)
if data.get('ok'):
    for channel in data.get('channels', []):
        if channel.get('name') == 'decisions':
            print(channel.get('id'))
" 2>/dev/null)

BLOCKERS=$(echo "$CHANNELS_RESPONSE" | python3 -c "
import sys,json
data=json.load(sys.stdin)
if data.get('ok'):
    for channel in data.get('channels', []):
        if channel.get('name') == 'blockers':
            print(channel.get('id'))
" 2>/dev/null)

echo "📋 Channel IDs:"
echo "  #prdforge-launch: $PRDFORGE_LAUNCH"
echo "  #phase1-stabilization: $PHASE1"
echo "  #phase2-qa-uat: $PHASE2"
echo "  #phase3-commercial: $PHASE3"
echo "  #phase4-gtm: $PHASE4"
echo "  #agent-coordination: $AGENT_COORD"
echo "  #decisions: $DECISIONS"
echo "  #blockers: $BLOCKERS"
echo ""

# Add all agents to common channels
echo "🚀 Adding agents to common channels..."
COMMON_CHANNELS=("$AGENT_COORD" "$DECISIONS" "$BLOCKERS" "$PRDFORGE_LAUNCH")

for AGENT_NAME in "${!AGENTS[@]}"; do
    USER_ID="${AGENTS[$AGENT_NAME]}"
    echo "Adding $AGENT_NAME to common channels..."
    
    for CHANNEL_ID in "${COMMON_CHANNELS[@]}"; do
        if [ -n "$CHANNEL_ID" ]; then
            RESPONSE=$(curl -s -X POST "https://slack.com/api/conversations.invite" \
                -H "Authorization: Bearer $TOKEN" \
                -H "Content-Type: application/json" \
                -d "{\"channel\":\"$CHANNEL_ID\",\"users\":[\"$USER_ID\"]}")
            
            if echo "$RESPONSE" | grep -q '"ok":true'; then
                echo "  ✅ Added to channel"
            else
                ERROR=$(echo "$RESPONSE" | python3 -c "import sys,json; data=json.load(sys.stdin); print(data.get('error', 'Unknown'))" 2>/dev/null)
                echo "  ⚠️  Already in channel or error: $ERROR"
            fi
            sleep 0.5
        fi
    done
done

# Add specific agents to their phase channels
echo ""
echo "🎯 Adding agents to phase-specific channels..."

# Trinity to phase1
if [ -n "$PHASE1" ] && [ -n "${AGENTS[trinity]}" ]; then
    echo "Adding Trinity to #phase1-stabilization..."
    curl -s -X POST "https://slack.com/api/conversations.invite" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"channel\":\"$PHASE1\",\"users\":[\"${AGENTS[trinity]}\"]}" | grep -q '"ok":true' && echo "  ✅ Added" || echo "  ⚠️  Error"
fi

# Shuri to phase2
if [ -n "$PHASE2" ] && [ -n "${AGENTS[shuri]}" ]; then
    echo "Adding Shuri to #phase2-qa-uat..."
    curl -s -X POST "https://slack.com/api/conversations.invite" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"channel\":\"$PHASE2\",\"users\":[\"${AGENTS[shuri]}\"]}" | grep -q '"ok":true' && echo "  ✅ Added" || echo "  ⚠️  Error"
fi

# Sheba to phase3
if [ -n "$PHASE3" ] && [ -n "${AGENTS[sheba]}" ]; then
    echo "Adding Sheba to #phase3-commercial..."
    curl -s -X POST "https://slack.com/api/conversations.invite" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"channel\":\"$PHASE3\",\"users\":[\"${AGENTS[sheba]}\"]}" | grep -q '"ok":true' && echo "  ✅ Added" || echo "  ⚠️  Error"
fi

# Fela, Ebun, Nova to phase4
if [ -n "$PHASE4" ]; then
    echo "Adding Fela, Ebun, Nova to #phase4-gtm..."
    PHASE4_USERS="${AGENTS[fela]},${AGENTS[ebun]},${AGENTS[nova]}"
    curl -s -X POST "https://slack.com/api/conversations.invite" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"channel\":\"$PHASE4\",\"users\":[\"${AGENTS[fela]}\",\"${AGENTS[ebun]}\",\"${AGENTS[nova]}\"]}" | grep -q '"ok":true' && echo "  ✅ Added" || echo "  ⚠️  Error"
fi

echo ""
echo "🎉 Agent channel assignment complete!"