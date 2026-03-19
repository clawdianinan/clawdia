# Zero-Budget Monitoring Stack

## Overview
This document outlines a comprehensive free monitoring solution using open-source tools and free cloud services. All tools are completely free to use and suitable for small to medium-sized deployments.

## 1. Wazuh (SIEM) - Open Source Security Monitoring

### What is Wazuh?
Wazuh is a free, open-source security monitoring solution that provides:
- Intrusion detection
- Log analysis
- File integrity monitoring
- Vulnerability detection
- Compliance monitoring

### Installation Guide

#### Option A: Docker (Recommended for quick setup)
```bash
# 1. Install Docker and Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo apt-get install docker-compose

# 2. Clone Wazuh repository
git clone https://github.com/wazuh/wazuh-docker.git
cd wazuh-docker/single-node

# 3. Start Wazuh
docker-compose up -d
```

#### Option B: Manual Installation
```bash
# 1. Add Wazuh repository
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | sudo apt-key add -
echo "deb https://packages.wazuh.com/4.x/apt/ stable main" | sudo tee /etc/apt/sources.list.d/wazuh.list

# 2. Install Wazuh manager
sudo apt-get update
sudo apt-get install wazuh-manager

# 3. Start and enable service
sudo systemctl daemon-reload
sudo systemctl enable wazuh-manager
sudo systemctl start wazuh-manager
```

### Configuration
1. Access Wazuh dashboard: `http://localhost:5601`
2. Default credentials: `admin` / `admin`
3. Add agents to monitor:
   ```bash
   # On target systems
   curl -so wazuh-agent.deb https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.7.3-1_amd64.deb
   sudo dpkg -i wazuh-agent.deb
   sudo systemctl daemon-reload
   sudo systemctl enable wazuh-agent
   sudo systemctl start wazuh-agent
   ```

## 2. ELK Stack (Elasticsearch, Logstash, Kibana)

### Installation

#### Docker Compose Setup
```yaml
# docker-compose.yml
version: '3.7'
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.17.0
    container_name: elasticsearch
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    ports:
      - "9200:9200"
    volumes:
      - elasticsearch-data:/usr/share/elasticsearch/data

  logstash:
    image: docker.elastic.co/logstash/logstash:7.17.0
    container_name: logstash
    volumes:
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf
    ports:
      - "5000:5000"
    depends_on:
      - elasticsearch

  kibana:
    image: docker.elastic.co/kibana/kibana:7.17.0
    container_name: kibana
    ports:
      - "5601:5601"
    environment:
      ELASTICSEARCH_HOSTS: http://elasticsearch:9200
    depends_on:
      - elasticsearch

volumes:
  elasticsearch-data:
```

#### Basic Logstash Configuration
```conf
# logstash.conf
input {
  beats {
    port => 5044
  }
}

filter {
  grok {
    match => { "message" => "%{COMBINEDAPACHELOG}" }
  }
  date {
    match => [ "timestamp", "dd/MMM/yyyy:HH:mm:ss Z" ]
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "logs-%{+YYYY.MM.dd}"
  }
}
```

### Filebeat for Log Collection
```bash
# Install Filebeat
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.17.0-linux-x86_64.tar.gz
tar xzvf filebeat-7.17.0-linux-x86_64.tar.gz
cd filebeat-7.17.0-linux-x86_64

# Configure Filebeat
cat > filebeat.yml << EOF
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/*.log

output.logstash:
  hosts: ["localhost:5044"]
EOF

# Start Filebeat
./filebeat -e
```

## 3. Free Cloud Monitoring Services

### UptimeRobot
- **URL:** https://uptimerobot.com
- **Free Tier:** 50 monitors, 5-minute checks
- **Features:**
  - HTTP(s) monitoring
  - Keyword monitoring
  - Port monitoring
  - Email/SMS alerts
  - Public status pages

### StatusCake
- **URL:** https://www.statuscake.com
- **Free Tier:** 10 uptime tests, 5-minute intervals
- **Features:**
  - Uptime monitoring
  - SSL certificate monitoring
  - Domain monitoring
  - Page speed monitoring
  - Real user monitoring (limited)

### HetrixTools
- **URL:** https://hetrixtools.com
- **Free Tier:** 15 uptime monitors, 5-minute checks
- **Features:**
  - Blacklist monitoring
  - Port monitoring
  - RBL monitoring
  - Email alerts

## 4. Basic Alerting Configuration

### Telegram Bot for Alerts
1. Create a Telegram bot via @BotFather
2. Get your bot token
3. Create a script for sending alerts:

```bash
#!/bin/bash
# telegram-alert.sh

TOKEN="YOUR_BOT_TOKEN"
CHAT_ID="YOUR_CHAT_ID"
MESSAGE="$1"

curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" \
  -d chat_id="${CHAT_ID}" \
  -d text="${MESSAGE}" \
  -d parse_mode="Markdown"
```

### Email Alerts with SendGrid (Free Tier)
1. Sign up at https://sendgrid.com (100 emails/day free)
2. Configure SMTP:

```bash
#!/bin/bash
# email-alert.sh

SUBJECT="$1"
BODY="$2"
RECIPIENT="$3"

echo "$BODY" | mail -s "$SUBJECT" -a "From: alerts@yourdomain.com" "$RECIPIENT"
```

## 5. Monitoring Dashboard with Grafana

### Installation
```bash
# Docker installation
docker run -d -p 3000:3000 --name=grafana grafana/grafana
```

### Data Sources
1. Add Prometheus (for metrics)
2. Add Elasticsearch (for logs)
3. Add InfluxDB (for time-series data)

### Sample Dashboards
- Import dashboard ID `1860` for Node Exporter
- Import dashboard ID `405` for Docker monitoring
- Import dashboard ID `11074` for Elasticsearch

## 6. System Metrics with Prometheus + Node Exporter

### Node Exporter Installation
```bash
# Download and install
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
tar xvfz node_exporter-1.3.1.linux-amd64.tar.gz
cd node_exporter-1.3.1.linux-amd64
./node_exporter &
```

### Prometheus Configuration
```yaml
# prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']
```

## 7. Application Performance Monitoring (APM)

### Jaeger (Distributed Tracing)
```bash
# Docker installation
docker run -d --name jaeger \
  -e COLLECTOR_ZIPKIN_HTTP_PORT=9411 \
  -p 5775:5775/udp \
  -p 6831:6831/udp \
  -p 6832:6832/udp \
  -p 5778:5778 \
  -p 16686:16686 \
  -p 14268:14268 \
  -p 14250:14250 \
  -p 9411:9411 \
  jaegertracing/all-in-one:1.32
```

## 8. Network Monitoring

### ntopng
```bash
# Docker installation
docker run -d --name ntopng \
  -p 3000:3000 \
  -p 3001:3001 \
  ntop/ntopng
```

### Smokeping
```bash
# Docker installation
docker run -d --name smokeping \
  -p 80:80 \
  dperson/smokeping
```

## 9. Database Monitoring

### pgMonitor for PostgreSQL
```bash
# Clone and setup
git clone https://github.com/CrunchyData/pgmonitor.git
cd pgmonitor
```

### MySQL Monitoring with Percona
```bash
# Install Percona Monitoring Plugins
wget https://www.percona.com/downloads/percona-monitoring-plugins/percona-monitoring-plugins-1.1.8/binary/debian/bionic/x86_64/percona-monitoring-plugins_1.1.8-1.bionic_amd64.deb
sudo dpkg -i percona-monitoring-plugins_1.1.8-1.bionic_amd64.deb
```

## 10. Cost Optimization Tips

1. **Use Docker:** Containerization reduces resource overhead
2. **Schedule Scans:** Run intensive scans during off-peak hours
3. **Data Retention:** Configure appropriate retention periods
4. **Compression:** Enable compression for log storage
5. **Sampling:** Use sampling for high-volume logs
6. **Cloud Credits:** Leverage free tiers from cloud providers

## 11. Maintenance Schedule

| Task | Frequency | Duration |
|------|-----------|----------|
| Log rotation | Daily | 5 minutes |
| Database optimization | Weekly | 15 minutes |
| Security updates | Weekly | 30 minutes |
| Backup verification | Weekly | 10 minutes |
| Performance review | Monthly | 1 hour |
| Capacity planning | Quarterly | 2 hours |

## 12. Troubleshooting Common Issues

### High CPU Usage
1. Check for runaway processes
2. Adjust monitoring intervals
3. Enable sampling for high-frequency metrics

### Disk Space Issues
1. Implement log rotation
2. Adjust retention policies
3. Use compression

### Alert Fatigue
1. Implement alert deduplication
2. Create escalation policies
3. Use maintenance windows

## Conclusion

This zero-budget monitoring stack provides comprehensive coverage for infrastructure, applications, and security. All components are free and open-source, making this solution sustainable for organizations with limited budgets. Regular maintenance and optimization will ensure the system remains effective and efficient.

**Next Steps:**
1. Start with UptimeRobot for basic uptime monitoring
2. Deploy Wazuh for security monitoring
3. Set up ELK for log analysis
4. Configure Telegram alerts for immediate notifications