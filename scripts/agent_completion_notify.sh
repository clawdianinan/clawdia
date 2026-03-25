#!/bin/bash

# agent_completion_notify.sh
# Send Slack notification when agent tasks complete
# Posted by Clawdia on behalf of all agents

set -e

AGENT_NAME="$1"
TASK="$2"
STATUS="$3"
DETAILS="$4"

SLACK_TOKEN="xoxb-10752295117408-10724380225666-jDMryiNyIBV1mjGbVpgJIjPI"
SLACK_CHANNEL="C0AM41CFBV1"

if [ "$STATUS" = "success" ]; then
    EMOJI="✅"
    COLOR="good"
    STATUS_TEXT="COMPLETED"
elif [ "$STATUS" = "started" ]; then
    EMOJI="🚀"
    COLOR="#439FE0"
    STATUS_TEXT="STARTED"
elif [ "$STATUS" = "in_progress" ]; then
    EMOJI="⚡"
    COLOR="#FFA500"
    STATUS_TEXT="IN PROGRESS"
else
    EMOJI="❌"
    COLOR="danger"
    STATUS_TEXT="FAILED"
fi

# Post as Clawdia on behalf of the agent
curl -s -X POST "https://slack.com/api/chat.postMessage" \
  -H "Authorization: Bearer $SLACK_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"channel\": \"$SLACK_CHANNEL\",
    \"text\": \"$EMOJI *Agent Update*: $AGENT_NAME - $TASK\",
    \"username\": \"Clawdia AI\",
    \"icon_emoji\": \"🐾\",
    \"blocks\": [
      {
        \"type\": \"header\",
        \"text\": {
          \"type\": \"plain_text\",
          \"text\": \"$EMOJI Agent Update: $AGENT_NAME\"
        }
      },
      {
        \"type\": \"section\",
        \"fields\": [
          {
            \"type\": \"mrkdwn\",
            \"text\": \"*Agent:*\\n$AGENT_NAME\"
          },
          {
            \"type\": \"mrkdwn\", 
            \"text\": \"*Status:*\\n$STATUS_TEXT\"
          }
        ]
      },
      {
        \"type\": \"section\",
        \"text\": {
          \"type\": \"mrkdwn\",
          \"text\": \"*Task:*\\n$TASK\"
        }
      },
      {
        \"type\": \"section\",
        \"text\": {
          \"type\": \"mrkdwn\", 
          \"text\": \"*Details:*\\n$DETAILS\"
        }
      },
      {
        \"type\": \"context\",
        \"elements\": [
          {
            \"type\": \"mrkdwn\",
            \"text\": \"Posted by Clawdia AI on behalf of $AGENT_NAME | $(date '+%Y-%m-%d %H:%M')\"
          }
        ]
      }
    ]
  }" > /dev/null 2>&1

echo "Clawdia posted Slack update for $AGENT_NAME: $STATUS_TEXT"
