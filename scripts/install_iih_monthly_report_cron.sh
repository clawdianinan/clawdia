#!/usr/bin/env bash
set -euo pipefail
MODE="${1:-on}"
TAG_BEGIN="# BEGIN_IIH_MONTHLY_REPORT_AUTOMATION"
TAG_END="# END_IIH_MONTHLY_REPORT_AUTOMATION"
JOB1="10 9 * * 1-5 /usr/bin/python3 /Users/clawdia/.openclaw/workspace/scripts/iih_monthly_report_automation.py >> /Users/clawdia/.openclaw/workspace/logs/iih_monthly_report_automation.log 2>&1"
JOB2="10 16 * * 1-5 /usr/bin/python3 /Users/clawdia/.openclaw/workspace/scripts/iih_monthly_report_automation.py >> /Users/clawdia/.openclaw/workspace/logs/iih_monthly_report_automation.log 2>&1"
# Deadline hardening: extra runs on 7th and 8th of each month
JOB3="5 12 7 * * /usr/bin/python3 /Users/clawdia/.openclaw/workspace/scripts/iih_monthly_report_automation.py >> /Users/clawdia/.openclaw/workspace/logs/iih_monthly_report_automation.log 2>&1"
JOB4="5 9 8 * * /usr/bin/python3 /Users/clawdia/.openclaw/workspace/scripts/iih_monthly_report_automation.py >> /Users/clawdia/.openclaw/workspace/logs/iih_monthly_report_automation.log 2>&1"

current=$(crontab -l 2>/dev/null || true)
clean=$(printf "%s\n" "$current" | awk -v b="$TAG_BEGIN" -v e="$TAG_END" 'BEGIN{skip=0} $0==b{skip=1;next} $0==e{skip=0;next} !skip{print}')

if [[ "$MODE" == "off" ]]; then
  printf "%s\n" "$clean" | crontab -
  echo "cron removed"
  exit 0
fi

mkdir -p /Users/clawdia/.openclaw/workspace/logs
{
  printf "%s\n" "$clean"
  echo "$TAG_BEGIN"
  echo "$JOB1"
  echo "$JOB2"
  echo "$JOB3"
  echo "$JOB4"
  echo "$TAG_END"
} | crontab -

echo "cron installed (conservative: weekdays 09:10 + 16:10, plus 7th@12:05 and 8th@09:05)"
