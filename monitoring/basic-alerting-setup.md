# Basic Alerting Setup - Zero Budget Configuration

## Overview
This document provides a comprehensive guide to setting up free alerting systems for monitoring infrastructure, applications, and security events. All solutions are completely free and suitable for organizations with limited budgets.

## 1. Alerting Architecture

### 1.1 Basic Alerting Flow
```
Monitoring Tools → Alert Manager → Notification Channels → Response Team
      ↓                   ↓               ↓                   ↓
[Prometheus]      [Prometheus Alert]  [Telegram]       [On-call Rotation]
[Wazuh]           [Custom Scripts]    [Email]          [Escalation Policy]
[ELK Stack]       [Webhooks]          [Slack]          [Documentation]
[UptimeRobot]                         [SMS (Free Tier)]
```

### 1.2 Alert Severity Levels
| Level | Color | Response Time | Example Triggers |
|-------|-------|---------------|------------------|
| **Critical** | 🔴 Red | Immediate | Service down, security breach |
| **High** | 🟠 Orange | 30 minutes | High CPU, disk full |
| **Medium** | 🟡 Yellow | 2 hours | Performance degradation |
| **Low** | 🔵 Blue | Next business day | Informational alerts |
| **Info** | ⚪ White | Log only | System updates, scans completed |

## 2. Free Notification Channels

### 2.1 Telegram Bot Alerts

#### Create Telegram Bot
1. Message @BotFather on Telegram
2. Send `/newbot` command
3. Follow prompts to name your bot
4. Save the API token provided

#### Get Chat ID
```bash
# Send a message to your bot
# Then visit: https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates
# Find "chat":{"id":<YOUR_CHAT_ID>}
```

#### Basic Alert Script
```bash
#!/bin/bash
# telegram-alert.sh

TOKEN="YOUR_BOT_TOKEN"
CHAT_ID="YOUR_CHAT_ID"
MESSAGE="$1"
SEVERITY="${2:-INFO}"

case $SEVERITY in
    CRITICAL) EMOJI="🚨" ;;
    HIGH) EMOJI="⚠️" ;;
    MEDIUM) EMOJI="🔶" ;;
    LOW) EMOJI="🔷" ;;
    *) EMOJI="ℹ️" ;;
esac

curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" \
  -d chat_id="${CHAT_ID}" \
  -d text="${EMOJI} *${SEVERITY} Alert*: ${MESSAGE}" \
  -d parse_mode="Markdown" \
  -d disable_notification="false"
```

#### Advanced Telegram Bot with Buttons
```python
#!/usr/bin/env python3
# telegram-bot-advanced.py

import telebot
from datetime import datetime

bot = telebot.TeleBot('YOUR_BOT_TOKEN')

@bot.message_handler(commands=['start'])
def send_welcome(message):
    bot.reply_to(message, "Alert Bot Ready! Send /help for commands.")

@bot.message_handler(commands=['alert'])
def send_alert(message):
    # Parse alert details from message
    parts = message.text.split(' ', 2)
    if len(parts) < 3:
        bot.reply_to(message, "Usage: /alert <severity> <message>")
        return
    
    severity = parts[1]
    alert_msg = parts[2]
    
    # Create inline keyboard
    markup = telebot.types.InlineKeyboardMarkup()
    markup.row(
        telebot.types.InlineKeyboardButton('Acknowledge', callback_data='ack'),
        telebot.types.InlineKeyboardButton('Escalate', callback_data='esc')
    )
    
    # Send alert
    bot.send_message(
        chat_id=message.chat.id,
        text=f"*{severity} Alert*\n{alert_msg}",
        parse_mode='Markdown',
        reply_markup=markup
    )

@bot.callback_query_handler(func=lambda call: True)
def handle_callback(call):
    if call.data == 'ack':
        bot.answer_callback_query(call.id, "Alert acknowledged")
        bot.edit_message_text(
            chat_id=call.message.chat.id,
            message_id=call.message.message_id,
            text=f"✅ {call.message.text}\n*Acknowledged by {call.from_user.first_name}*",
            parse_mode='Markdown'
        )
    elif call.data == 'esc':
        bot.answer_callback_query(call.id, "Alert escalated")
        # Implement escalation logic

if __name__ == '__main__':
    bot.polling()
```

### 2.2 Email Alerts (Free SMTP Services)

#### SendGrid (100 emails/day free)
```bash
#!/bin/bash
# email-alert-sendgrid.sh

SENDGRID_API_KEY="YOUR_API_KEY"
TO_EMAIL="$1"
SUBJECT="$2"
BODY="$3"

curl --request POST \
  --url https://api.sendgrid.com/v3/mail/send \
  --header "Authorization: Bearer $SENDGRID_API_KEY" \
  --header 'Content-Type: application/json' \
  --data '{
    "personalizations": [
      {
        "to": [
          {
            "email": "'"$TO_EMAIL"'"
          }
        ]
      }
    ],
    "from": {
      "email": "alerts@yourdomain.com",
      "name": "Alert System"
    },
    "subject": "'"$SUBJECT"'",
    "content": [
      {
        "type": "text/plain",
        "value": "'"$BODY"'"
      }
    ]
  }'
```

#### Mailgun (10,000 emails/month free)
```bash
#!/bin/bash
# email-alert-mailgun.sh

MAILGUN_API_KEY="YOUR_API_KEY"
MAILGUN_DOMAIN="yourdomain.com"
TO_EMAIL="$1"
SUBJECT="$2"
BODY="$3"

curl -s --user "api:$MAILGUN_API_KEY" \
  https://api.mailgun.net/v3/$MAILGUN_DOMAIN/messages \
  -F from="Alerts <alerts@$MAILGUN_DOMAIN>" \
  -F to="$TO_EMAIL" \
  -F subject="$SUBJECT" \
  -F text="$BODY"
```

#### Gmail SMTP (Free with Google Account)
```python
#!/usr/bin/env python3
# email-alert-gmail.py

import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

def send_gmail_alert(to_email, subject, body):
    # Gmail credentials (use app password for security)
    gmail_user = 'your-email@gmail.com'
    gmail_password = 'your-app-password'
    
    # Create message
    msg = MIMEMultipart()
    msg['From'] = f'Alerts <{gmail_user}>'
    msg['To'] = to_email
    msg['Subject'] = subject
    
    # Add body
    msg.attach(MIMEText(body, 'plain'))
    
    # Send email
    try:
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.starttls()
        server.login(gmail_user, gmail_password)
        server.send_message(msg)
        server.quit()
        print(f"Alert sent to {to_email}")
    except Exception as e:
        print(f"Failed to send alert: {e}")
```

### 2.3 Slack Webhooks (Free Tier)

#### Create Incoming Webhook
1. Go to https://api.slack.com/apps
2. Create new app
3. Enable "Incoming Webhooks"
4. Add new webhook to workspace
5. Copy webhook URL

#### Slack Alert Script
```bash
#!/bin/bash
# slack-alert.sh

WEBHOOK_URL="YOUR_WEBHOOK_URL"
CHANNEL="#alerts"
MESSAGE="$1"
SEVERITY="${2:-info}"

case $SEVERITY in
    critical) COLOR="danger" ;;
    high) COLOR="warning" ;;
    medium) COLOR="good" ;;
    *) COLOR="#439FE0" ;;
esac

curl -X POST -H 'Content-type: application/json' \
  --data '{
    "channel": "'"$CHANNEL"'",
    "attachments": [
      {
        "color": "'"$COLOR"'",
        "title": "'"$SEVERITY"' Alert",
        "text": "'"$MESSAGE"'",
        "ts": '"$(date +%s)"'
      }
    ]
  }' \
  $WEBHOOK_URL
```

#### Slack Block Kit Format
```python
#!/usr/bin/env python3
# slack-blocks-alert.py

import requests
import json
from datetime import datetime

def send_slack_blocks_alert(webhook_url, severity, message, details=None):
    blocks = [
        {
            "type": "header",
            "text": {
                "type": "plain_text",
                "text": f"{severity.upper()} ALERT",
                "emoji": True
            }
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": message
            }
        },
        {
            "type": "section",
            "fields": [
                {
                    "type": "mrkdwn",
                    "text": f"*Time:*\n{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
                },
                {
                    "type": "mrkdwn",
                    "text": f"*Severity:*\n{severity}"
                }
            ]
        }
    ]
    
    if details:
        blocks.append({
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": f"*Details:*\n{details}"
            }
        })
    
    blocks.append({
        "type": "actions",
        "elements": [
            {
                "type": "button",
                "text": {
                    "type": "plain_text",
                    "text": "Acknowledge",
                    "emoji": True
                },
                "value": "acknowledge",
                "style": "primary"
            },
            {
                "type": "button",
                "text": {
                    "type": "plain_text",
                    "text": "Escalate",
                    "emoji": True
                },
                "value": "escalate",
                "style": "danger"
            }
        ]
    })
    
    payload = {"blocks": blocks}
    response = requests.post(webhook_url, json=payload)
    return response.status_code == 200
```

### 2.4 SMS Alerts (Free Options)

#### Twilio (Free Trial Credits)
```python
#!/usr/bin/env python3
# sms-alert-twilio.py

from twilio.rest import Client

def send_sms_alert(to_number, message):
    # Twilio credentials (free trial available)
    account_sid = 'YOUR_ACCOUNT_SID'
    auth_token = 'YOUR_AUTH_TOKEN'
    from_number = '+1234567890'  # Your Twilio number
    
    client = Client(account_sid, auth_token)
    
    try:
        message = client.messages.create(
            body=message,
            from_=from_number,
            to=to_number
        )
        print(f"SMS sent: {message.sid}")
        return True
    except Exception as e:
        print(f"Failed to send SMS: {e}")
        return False
```

#### TextBelt (1 free SMS/day)
```bash
#!/bin/bash
# sms-alert-textbelt.sh

PHONE_NUMBER="$1"
MESSAGE="$2"

curl -X POST https://textbelt.com/text \
  --data-urlencode phone="$PHONE_NUMBER" \
  --data-urlencode message="$MESSAGE" \
  -d key=textbelt
```

## 3. Alert Manager Configuration

### 3.1 Prometheus Alertmanager

#### Docker Installation
```yaml
# docker-compose.yml
version: '3'
services:
  alertmanager:
    image: prom/alertmanager:latest
    container_name: alertmanager
    ports:
      - "9093:9093"
    volumes:
      - ./alertmanager.yml:/etc/alertmanager/alertmanager.yml
      - ./alerts.yml:/etc/alertmanager/alerts.yml
    command:
      - '--config.file=/etc/alertmanager/alertmanager.yml'
      - '--storage.path=/alertmanager'
```

#### Basic Configuration
```yaml
# alertmanager.yml
global:
  smtp_smarthost: 'smtp.gmail.com:587'
  smtp_from: 'alerts@yourdomain.com'
  smtp_auth_username: 'your-email@gmail.com'
  smtp_auth_password: 'your-app-password'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'telegram-alerts'

receivers:
  - name: 'telegram-alerts'
    webhook_configs:
      - url: 'http://alert-bridge:5000/telegram'
        send_resolved: true
  
  - name: 'email-alerts'
    email_configs:
      - to: 'admin@yourdomain.com'
        send_resolved: true
  
  - name: 'slack-alerts'
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/XXX/YYY/ZZZ'
        channel: '#alerts'
        send_resolved: true

inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'instance']
```

#### Alert Rules
```yaml
# alerts.yml
groups:
  - name: infrastructure
    rules:
      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: high
        annotations:
          summary: "High CPU usage on {{ $labels.instance }}"
          description: "CPU usage is above 80% for 5 minutes"
      
      - alert: DiskSpaceLow
        expr: (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100 < 10
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "Low disk space on {{ $labels.instance }}"
          description: "Disk space is below 10% on {{ $labels.mountpoint }}"
      
      - alert: ServiceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Service {{ $labels.job }} down on {{ $labels.instance }}"
          description: "Service has been down for more than 1 minute"
```

### 3.2 Custom Alert Bridge

#### Python Alert Bridge
```python
#!/usr/bin/env python3
# alert-bridge.py

from flask import Flask, request, jsonify
import requests
import logging

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)

# Configuration
TELEGRAM_TOKEN = 'YOUR_BOT_TOKEN'
TELEGRAM_CHAT_ID = 'YOUR_CHAT_ID'
SLACK_WEBHOOK = 'YOUR_SLACK_WEBHOOK'

@app.route('/webhook', methods=['POST'])
def handle_webhook():
    data = request.json
    
    if not data:
        return jsonify({'error': 'No data provided'}), 400
    
    # Parse alert data
    alerts = data.get('alerts', [])
    
    for alert in alerts:
        severity = alert['labels'].get('severity', 'info')
        alertname = alert['labels'].get('alertname', 'Unknown')
        instance = alert['labels'].get('instance', 'Unknown')
        status = alert['status']
        
        message = f"{severity.upper()}: {alertname} on {instance} is {status}"
        
        # Send to Telegram
        send_telegram_alert(message, severity)
        
        # Send to Slack
        send_slack_alert(message, severity)
        
        # Log alert
        logging.info(f"Alert processed: {message}")
    
    return jsonify({'status': 'success'}), 200

def send_telegram_alert(message, severity):
    url = f"https://api.telegram.org/bot{TELEGRAM_TOKEN}/sendMessage"
    payload = {
        'chat_id': TELEGRAM_CHAT_ID,
        'text': message,
        'parse_mode': 'Markdown'
    }
    try:
        requests.post(url, json=payload)
    except Exception as e:
        logging.error(f"Failed to send Telegram alert: {e}")

def send_slack_alert(message, severity):
    color_map = {
        'critical': 'danger',
        'high': 'warning',
        'medium': 'good',
        'low': '#439FE0'
    }
    
    payload = {
        'attachments': [{
            'color': color_map.get(severity, '#439FE0'),
            'title': f'{severity.upper()} Alert',
            'text': message,
            'ts': requests.get('http://worldtimeapi.org/api/timezone/UTC').json()['unixtime']
        }]
    }
    
    try:
        requests.post(SLACK_WEBHOOK, json=payload)
    except Exception as e:
        logging.error(f"Failed to send Slack alert: {e}")

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

## 4. Integration with Monitoring Tools

### 4.1 Wazuh Alert Integration

#### Custom Rules for Alerting
```xml
<!-- /var/ossec/etc/rules/local_rules.xml -->
<group name="syslog,">
  <rule id="100001" level="12">
    <if_sid>5716</if_sid>
    <match>Failed password</match>
    <description>SSH brute force attempt detected</description>
    <group>authentication_failed,</group>
  </rule>
</group>
```

#### Wazuh Integration Script
```bash
#!/bin/bash
# wazuh-alert-integration.sh

# Monitor Wazuh alerts and forward to notification channels
ALERT_FILE="/var/ossec/logs/alerts/alerts.json"

tail -f $ALERT_FILE | while read line; do
    # Parse alert
    ALERT_LEVEL=$(echo $line | jq -r '.rule.level')
    ALERT_DESC=$(echo $line | jq -r '.rule.description')
    ALERT_SRC=$(echo $line | jq -r '.srcip')
    
    # Determine severity
    if [ $ALERT_LEVEL -ge 12 ]; then
        SEVERITY="critical"
    elif [ $ALERT_LEVEL -ge 10 ]; then
        SEVERITY="high"
    elif [ $ALERT_LEVEL -ge 7 ]; then
        SEVERITY="medium"
    else
        SEVERITY="low"
    fi
    
    # Send alert
    MESSAGE="Wazuh Alert: $ALERT_DESC from $ALERT_SRC (Level: $ALERT_LEVEL)"
    ./telegram-alert.sh "$MESSAGE" "$SEVERITY"
done
```

### 4.2 ELK Stack Alert Integration

#### Watcher Configuration
```json
{
  "trigger": {
    "schedule": {
      "interval": "5m"
    }
  },
  "input": {
    "search": {
      "request": {
        "indices": ["logs-*"],
        "body": {
          "query": {
            "bool": {
              "must": [
                {
                  "range": {
                    "@timestamp": {
                      "gte": "now-5m"
                    }
                  }
                },
                {
                  "term": {
                    "level": "ERROR"
                  }
                }
              ]
            }
          }
        }
      }
    }
  },
  "condition": {
    "compare": {
      "ctx.payload.hits.total": {
        "gt": 0
      }
    }
  },
  "actions": {
    "send_alert": {
      "webhook": {
        "scheme": "http",
        "host": "alert-bridge:5000",
        "port": 5000,
        "method": "post",
        "path": "/webhook",
        "body": "{{#ctx.payload.hits.hits}}Alert: {{_source.message}}{{/ctx.payload.hits.hits}}"
      }
    }
  }
}
```

### 4.3 UptimeRobot Webhook Integration

#### Webhook Configuration
1. In UptimeRobot, go to My Settings → Alert Contacts
2. Add new Alert Contact → Webhook
3. Configure:
   - URL: `http://your-alert-bridge:5000/uptimerobot`
   - Method: POST
   - Post Type: JSON

#### Webhook Handler
```python
@app.route('/uptimerobot', methods=['POST'])
def handle_uptimerobot():
    data = request.json
    
    monitor_name = data.get('monitorFriendlyName', 'Unknown')
    alert_type = data.get('alertType', 'Unknown')
    alert_details = data.get('alertDetails', '')
    
    if alert_type == '1':  # Down
        severity = 'critical'
        message = f"🚨 {monitor_name} is DOWN: {alert_details}"
    elif alert_type == '2':  # Up
        severity = 'info'
        message = f"✅ {monitor_name} is back UP"
    else:
        severity = 'medium'
        message = f"⚠️ {monitor_name}: {alert_details}"
    
    # Send to all channels
    send_telegram_alert(message, severity)
    send_slack_alert(message, severity)
    
    return jsonify({'status': 'success'}), 200
```

## 5. On-Call Rotation & Escalation

### 5.1 Simple On-Call Schedule

#### Google Sheets Rotation
```markdown
# On-Call Rotation Schedule

| Week | Primary | Secondary | Backup |
|------|---------|-----------|--------|
| 2024-W01 | Alice | Bob | Charlie |
| 2024-W02 | Bob | Charlie | Alice |
| 2024-W03 | Charlie | Alice | Bob |
```

#### Automated Rotation Script
```python
#!/usr/bin/env python3
# oncall-rotation.py

import datetime
import json

TEAM_MEMBERS = ['Alice', 'Bob', 'Charlie', 'David']
ROTATION_FILE = 'oncall_rotation.json'

def get_current_oncall():
    today = datetime.date.today()
    week_num = today.isocalendar()[1]
    
    # Simple round-robin
    primary_index = (week_num - 1) % len(TEAM_MEMBERS)
    secondary_index = (week_num) % len(TEAM_MEMBERS)
    backup_index = (week_num + 1) % len(TEAM_MEMBERS)
    
    return {
        'week': week_num,
        'primary': TEAM_MEMBERS[primary_index],
        'secondary': TEAM_MEMBERS[secondary_index],
        'backup': TEAM_MEMBERS[backup_index],
        'updated': today.isoformat()
    }

def update_rotation():
    rotation = get_current_oncall()
    
    with open(ROTATION_FILE, 'w') as f:
        json.dump(rotation, f, indent=2)
    
    # Send notification
    message = f"📅 On-call rotation updated for week {rotation['week']}:\n"
    message += f"• Primary: {rotation['primary']}\n"
    message += f"• Secondary: {rotation['secondary']}\n"
    message += f"• Backup: {rotation['backup']}"
    
    send_telegram_alert(message, 'info')
    
    return rotation
```

### 5.2 Escalation Policies

#### Escalation Matrix
```yaml
# escalation-policy.yml
escalation_policies:
  - name: "Critical Infrastructure"
    steps:
      - delay: 0
        notify:
          - type: "telegram"
            target: "primary_oncall"
      
      - delay: 300  # 5 minutes
        notify:
          - type: "telegram"
            target: "secondary_oncall"
          - type: "sms"
            target: "primary_oncall"
      
      - delay: 900  # 15 minutes
        notify:
          - type: "phone"
            target: "team_lead"
          - type: "email"
            target: "all_team_members"
  
  - name: "Business Hours Only"
    schedule: "Mon-Fri 09:00-18:00"
    steps:
      - delay: 0
        notify:
          - type: "slack"
            target: "team_channel"
```

#### Escalation Engine
```python
#!/usr/bin/env python3
# escalation-engine.py

import time
import threading
from datetime import datetime

class EscalationEngine:
    def __init__(self):
        self.active_alerts = {}
        
    def trigger_escalation(self, alert_id, policy_name):
        alert = {
            'id': alert_id,
            'policy': policy_name,
            'triggered_at': datetime.now(),
            'steps_completed': 0,
            'acknowledged': False
        }
        
        self.active_alerts[alert_id] = alert
        self._execute_policy(alert_id, policy_name)
    
    def _execute_policy(self, alert_id, policy_name):
        policy = self._load_policy(policy_name)
        
        for step in policy['steps']:
            if not self.active_alerts[alert_id]['acknowledged']:
                time.sleep(step['delay'])
                self._execute_step(alert_id, step)
    
    def _execute_step(self, alert_id, step):
        for notification in step['notify']:
            if notification['type'] == 'telegram':
                self._send_telegram(alert_id, notification['target'])
            elif notification['type'] == 'sms':
                self._send_sms(alert_id, notification['target'])
            # Add more notification types
    
    def acknowledge_alert(self, alert_id):
        if alert_id in self.active_alerts:
            self.active_alerts[alert_id]['acknowledged'] = True
            return True
        return False
```

## 6. Alert Dashboard & Reporting

### 6.1 Simple Alert Dashboard

#### HTML Dashboard
```html
<!-- alert-dashboard.html -->
<!DOCTYPE html>
<html>
<head>
    <title>Alert Dashboard</title>
    <style>
        .alert { padding: 10px; margin: 5px; border-radius: 5px; }
        .critical { background: #ffcccc; border: 2px solid #ff0000; }
        .high { background: #ffebcc; border: 2px solid #ff9900; }
        .medium { background: #ffffcc; border: 2px solid #ffcc00; }
        .low { background: #ccffcc; border: 2px solid #00cc00; }
    </style>
</head>
<body>
    <h1>Alert Dashboard</h1>
    <div id="alerts"></div>
    
    <script>
        async function loadAlerts() {
            const response = await fetch('/api/alerts');
            const alerts = await response.json();
            
            const container = document.getElementById('alerts');
            container.innerHTML = '';
            
            alerts.forEach(alert => {
                const div = document.createElement('div');
                div.className = `alert ${alert.severity}`;
                div.innerHTML = `
                    <strong>${alert.severity.toUpperCase()}</strong>
                    <br>${alert.message}
                    <br><small>${alert.timestamp}</small>
                `;
                container.appendChild(div);
            });
        }
        
        // Refresh every 30 seconds
        setInterval(loadAlerts, 30000);
        loadAlerts();
    </script>
</body>
</html>
```

#### Flask API for Dashboard
```python
@app.route('/api/alerts')
def get_alerts():
    # Read alerts from log file or database
    alerts = []
    
    try:
        with open('/var/log/alerts.json', 'r') as f:
            for line in f:
                alert = json.loads(line.strip())
                if alert['timestamp'] > (time.time() - 86400):  # Last 24 hours
                    alerts.append(alert)
    except FileNotFoundError:
        pass
    
    return jsonify(alerts)
```

### 6.2 Alert Metrics & Reporting

#### Daily Alert Summary
```python
def generate_daily_summary():
    today = datetime.now().date()
    alerts_today = []
    
    with open('/var/log/alerts.json', 'r') as f:
        for line in f:
            alert = json.loads(line.strip())
            alert_date = datetime.fromtimestamp(alert['timestamp']).date()
            if alert_date == today:
                alerts_today.append(alert)
    
    # Calculate metrics
    total_alerts = len(alerts_today)
    critical_alerts = len([a for a in alerts_today if a['severity'] == 'critical'])
    acknowledged_alerts = len([a for a in alerts_today if a.get('acknowledged', False)])
    
    # Generate report
    report = f"""
    📊 Daily Alert Summary - {today}
    ================================
    • Total Alerts: {total_alerts}
    • Critical Alerts: {critical_alerts}
    • Acknowledged: {acknowledged_alerts}
    • Response Rate: {(acknowledged_alerts/total_alerts*100 if total_alerts > 0 else 0):.1f}%
    
    Top Alerts:
    """
    
    # Add top 5 alerts
    for alert in sorted(alerts_today, key=lambda x: x['severity'], reverse=True)[:5]:
        report += f"\n• {alert['severity'].upper()}: {alert['message'][:100]}..."
    
    return report
```

## 7. Testing & Validation

### 7.1 Alert Testing Script
```bash
#!/bin/bash
# test-alerts.sh

echo "Testing alert system..."

# Test critical alert
./telegram-alert.sh "TEST: Critical alert - Service down" "CRITICAL"
sleep 2

# Test high alert
./telegram-alert.sh "TEST: High alert - CPU at 90%" "HIGH"
sleep 2

# Test medium alert
./telegram-alert.sh "TEST: Medium alert - Disk at 80%" "MEDIUM"
sleep 2

# Test low alert
./telegram-alert.sh "TEST: Low alert - Informational" "LOW"
sleep 2

# Test email alert
./email-alert.sh "admin@example.com" "Test Alert" "This is a test alert"
sleep 2

# Test Slack alert
./slack-alert.sh "TEST: Slack integration test" "medium"

echo "Alert testing completed. Check all channels for test messages."
```

### 7.2 Monthly Test Schedule
```markdown
# Monthly Alert Testing Schedule

## First Monday of Month
- [ ] Test all notification channels
- [ ] Verify escalation policies
- [ ] Test on-call rotation notifications
- [ ] Validate alert dashboard

## Weekly
- [ ] Test one notification channel
- [ ] Verify alert bridge functionality
- [ ] Check alert logs for errors

## After Changes
- [ ] Test affected components
- [ ] Update documentation
- [ ] Notify team of changes
```

## 8. Maintenance & Optimization

### 8.1 Regular Maintenance Tasks
1. **Daily:** Check alert logs for failures
2. **Weekly:** Review undelivered alerts
3. **Monthly:** Update contact information
4. **Quarterly:** Review and update escalation policies
5. **Annually:** Complete system review and upgrade

### 8.2 Performance Optimization
```python
# alert-optimization.py

class AlertOptimizer:
    def __init__(self):
        self.alert_cache = {}
        self.cooldown_period = 300  # 5 minutes
        
    def should_send_alert(self, alert_key, severity):
        current_time = time.time()
        
        # Check cache
        if alert_key in self.alert_cache:
            last_sent, count = self.alert_cache[alert_key]
            
            # Apply cooldown for non-critical alerts
            if severity != 'critical' and (current_time - last_sent) < self.cooldown_period:
                return False
            
            # Limit repeated alerts
            if count > 10 and (current_time - last_sent) < 3600:  # 1 hour
                return False
        
        # Update cache
        self.alert_cache[alert_key] = (current_time, 
                                      self.alert_cache.get(alert_key, (0, 0))[1] + 1)
        
        # Clean old cache entries
        self._clean_cache()
        
        return True
    
    def _clean_cache(self):
        current_time = time.time()
        old_keys = [k for k, (t, _) in self.alert_cache.items() 
                   if (current_time - t) > 86400]  # 24 hours
        for k in old_keys:
            del self.alert_cache[k]
```

## Conclusion

This zero-budget alerting setup provides comprehensive notification capabilities using free tools and services. The system is modular, allowing you to start simple and add complexity as needed.

**Immediate Actions:**
1. Set up Telegram bot for basic alerts
2. Configure email alerts using free SMTP service
3. Create simple on-call rotation schedule
4. Test alert system end-to-end
5. Document procedures for team members

**Key Success Factors:**
- Regular testing of all alert channels
- Clear escalation policies
- Proper documentation
- Team training on alert response
- Continuous improvement based on feedback

**Remember:** The most sophisticated alerting system is useless if alerts are ignored or misunderstood. Focus on clear, actionable alerts and ensure your team knows how to respond effectively.