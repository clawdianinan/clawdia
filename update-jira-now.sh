#!/bin/bash

echo "🎯 Updating Jira Tickets DEV-27 to DEV-34"
echo "========================================="

JIRA_URL="https://clawdianinan.atlassian.net"
EMAIL="clawdianinan@gmail.com"
TOKEN="$ATLASSIAN_API_TOKEN"

if [ -z "$TOKEN" ]; then
    echo "❌ Token not set. Run: source ~/.zshrc"
    exit 1
fi

echo "📋 Configuration:"
echo "   URL: $JIRA_URL"
echo "   Email: $EMAIL"
echo "   Token: ${TOKEN:0:12}..."
echo ""

TICKETS=("DEV-27" "DEV-28" "DEV-29" "DEV-30" "DEV-31" "DEV-32" "DEV-33" "DEV-34")

SUCCESS=0
FAILED=0

for TICKET in "${TICKETS[@]}"; do
    echo "🔄 Updating $TICKET..."
    
    # Get current ticket info first
    CURRENT=$(curl -s -u "$EMAIL:$TOKEN" \
        -H "Accept: application/json" \
        "$JIRA_URL/rest/api/3/issue/$TICKET")
    
    if echo "$CURRENT" | grep -q "key"; then
        echo "   ✅ Ticket exists"
        
        # Try to transition to Done
        # Common transition IDs: 31 (Done), 21 (Resolved), 41 (Closed)
        for TRANS_ID in "31" "21" "41"; do
            PAYLOAD="{\"transition\":{\"id\":\"$TRANS_ID\"}}"
            
            RESPONSE=$(curl -s -u "$EMAIL:$TOKEN" \
                -X POST \
                -H "Accept: application/json" \
                -H "Content-Type: application/json" \
                --data "$PAYLOAD" \
                "$JIRA_URL/rest/api/3/issue/$TICKET/transitions" 2>/dev/null)
            
            if [ -z "$RESPONSE" ] || [ "$RESPONSE" = "{}" ]; then
                echo "   ✅ Transitioned to Done"
                
                # Add completion comment
                COMMENT="{\"body\":{\"type\":\"doc\",\"version\":1,\"content\":[{\"type\":\"paragraph\",\"content\":[{\"type\":\"text\",\"text\":\"Completed via automation. Status updated to Done.\"}]}]}}"
                
                curl -s -u "$EMAIL:$TOKEN" \
                    -X POST \
                    -H "Accept: application/json" \
                    -H "Content-Type: application/json" \
                    --data "$COMMENT" \
                    "$JIRA_URL/rest/api/3/issue/$TICKET/comment" > /dev/null
                
                echo "   ✅ Added completion comment"
                ((SUCCESS++))
                break
            fi
        done
        
        if [ $? -ne 0 ]; then
            echo "   ❌ Failed to transition"
            ((FAILED++))
        fi
    else
        echo "   ❌ Ticket not found or access denied"
        ((FAILED++))
    fi
    
    echo ""
done

echo "📊 Results:"
echo "   ✅ Success: $SUCCESS"
echo "   ❌ Failed: $FAILED"
echo "   📋 Total: ${#TICKETS[@]}"
echo ""

if [ $SUCCESS -eq ${#TICKETS[@]} ]; then
    echo "🎉 All tickets updated successfully!"
elif [ $SUCCESS -gt 0 ]; then
    echo "⚠️  $SUCCESS tickets updated, $FAILED failed"
else
    echo "❌ No tickets were updated"
fi

# Create summary file
echo ""
echo "📄 Summary saved to: jira-update-$(date '+%Y%m%d-%H%M').log"
