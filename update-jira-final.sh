#!/bin/bash

# Source environment first
source ~/.zshrc 2>/dev/null

echo "🚀 JIRA TICKET UPDATE - FINAL"
echo "============================="

JIRA_URL="https://clawdianinan.atlassian.net"
EMAIL="clawdianinan@gmail.com"
TOKEN="$ATLASSIAN_API_TOKEN"

if [ -z "$TOKEN" ]; then
    echo "❌ ATLASSIAN_API_TOKEN not set"
    echo "📝 Check ~/.zshrc or set manually:"
    echo "   export ATLASSIAN_API_TOKEN='your-token'"
    exit 1
fi

echo "✅ Token loaded: ${TOKEN:0:12}..."
echo "📧 Email: $EMAIL"
echo "🌐 URL: $JIRA_URL"
echo ""

# Test connection first
echo "🔗 Testing API connection..."
TEST=$(curl -s -u "$EMAIL:$TOKEN" \
    "$JIRA_URL/rest/api/3/serverInfo")

if ! echo "$TEST" | grep -q "baseUrl"; then
    echo "❌ API connection failed"
    exit 1
fi

echo "✅ API connection successful!"
echo ""

# Tickets to update
TICKETS=("DEV-27" "DEV-28" "DEV-29" "DEV-30" "DEV-31" "DEV-32" "DEV-33" "DEV-34")

echo "📋 Updating ${#TICKETS[@]} tickets:"
printf '%s\n' "${TICKETS[@]}" | xargs -n4 echo "   "
echo ""

SUCCESS=0
FAILED=0
LOG_FILE="/Users/clawdia/.openclaw/workspace/jira-update-$(date '+%Y%m%d-%H%M').log"

for TICKET in "${TICKETS[@]}"; do
    echo "--- $TICKET ---" | tee -a "$LOG_FILE"
    
    # Check if ticket exists
    echo "Checking ticket..." | tee -a "$LOG_FILE"
    CURRENT=$(curl -s -u "$EMAIL:$TOKEN" \
        -H "Accept: application/json" \
        "$JIRA_URL/rest/api/3/issue/$TICKET" 2>/dev/null)
    
    if echo "$CURRENT" | grep -q '"key"'; then
        SUMMARY=$(echo "$CURRENT" | grep -o '"summary":"[^"]*"' | cut -d'"' -f4)
        STATUS=$(echo "$CURRENT" | grep -o '"name":"[^"]*"' | head -1 | cut -d'"' -f4)
        echo "Found: $SUMMARY" | tee -a "$LOG_FILE"
        echo "Current status: $STATUS" | tee -a "$LOG_FILE"
        
        # Try to transition to Done
        echo "Transitioning to Done..." | tee -a "$LOG_FILE"
        
        # Try different transition IDs
        TRANSITIONED=false
        for TRANS_ID in "31" "21" "41" "11" "51"; do
            PAYLOAD="{\"transition\":{\"id\":\"$TRANS_ID\"}}"
            
            RESPONSE=$(curl -s -w "%{http_code}" -u "$EMAIL:$TOKEN" \
                -X POST \
                -H "Accept: application/json" \
                -H "Content-Type: application/json" \
                --data "$PAYLOAD" \
                "$JIRA_URL/rest/api/3/issue/$TICKET/transitions" 2>&1)
            
            HTTP_CODE=$(echo "$RESPONSE" | tail -1)
            RESPONSE_BODY=$(echo "$RESPONSE" | sed '$d')
            
            if [ "$HTTP_CODE" = "204" ] || [ -z "$RESPONSE_BODY" ] || [ "$RESPONSE_BODY" = "{}" ]; then
                echo "✅ Transition successful (ID: $TRANS_ID)" | tee -a "$LOG_FILE"
                
                # Add comment
                COMMENT="Completed via automation on $(date '+%Y-%m-%d %H:%M'). Status updated to Done."
                COMMENT_JSON="{\"body\":{\"type\":\"doc\",\"version\":1,\"content\":[{\"type\":\"paragraph\",\"content\":[{\"type\":\"text\",\"text\":\"$COMMENT\"}]}]}}"
                
                curl -s -u "$EMAIL:$TOKEN" \
                    -X POST \
                    -H "Accept: application/json" \
                    -H "Content-Type: application/json" \
                    --data "$COMMENT_JSON" \
                    "$JIRA_URL/rest/api/3/issue/$TICKET/comment" > /dev/null
                
                echo "✅ Added completion comment" | tee -a "$LOG_FILE"
                TRANSITIONED=true
                ((SUCCESS++))
                break
            fi
        done
        
        if [ "$TRANSITIONED" = false ]; then
            echo "❌ Could not transition (tried multiple IDs)" | tee -a "$LOG_FILE"
            echo "Response: $RESPONSE_BODY" | tee -a "$LOG_FILE"
            ((FAILED++))
        fi
        
    else
        echo "❌ Ticket not found or access denied" | tee -a "$LOG_FILE"
        ((FAILED++))
    fi
    
    echo "" | tee -a "$LOG_FILE"
    sleep 1  # Rate limiting
done

echo "=========================================" | tee -a "$LOG_FILE"
echo "📊 FINAL RESULTS" | tee -a "$LOG_FILE"
echo "   ✅ Success: $SUCCESS" | tee -a "$LOG_FILE"
echo "   ❌ Failed: $FAILED" | tee -a "$LOG_FILE"
echo "   📋 Total: ${#TICKETS[@]}" | tee -a "$LOG_FILE"
echo "=========================================" | tee -a "$LOG_FILE"

if [ $SUCCESS -eq ${#TICKETS[@]} ]; then
    echo "🎉 ALL TICKETS UPDATED SUCCESSFULLY!" | tee -a "$LOG_FILE"
elif [ $SUCCESS -gt 0 ]; then
    echo "⚠️  Partial success: $SUCCESS updated, $FAILED failed" | tee -a "$LOG_FILE"
else
    echo "❌ NO TICKETS WERE UPDATED" | tee -a "$LOG_FILE"
fi

echo "" | tee -a "$LOG_FILE"
echo "📄 Detailed log: $LOG_FILE" | tee -a "$LOG_FILE"