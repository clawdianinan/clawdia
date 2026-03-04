#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-}"
CFG="$HOME/.openclaw/openclaw.json"
BKP="$HOME/.openclaw/openclaw.pre_codex_optimization.json"

if [[ "$MODE" != "on" && "$MODE" != "off" ]]; then
  echo "Usage: $0 on|off"
  exit 1
fi

if [[ "$MODE" == "on" ]]; then
  cp "$CFG" "$BKP"
  python3 - <<'PY'
import json, os
p=os.path.expanduser('~/.openclaw/openclaw.json')
with open(p) as f:data=json.load(f)
a=data.setdefault('agents',{}).setdefault('defaults',{})
a['maxConcurrent']=2
a.setdefault('subagents',{})['maxConcurrent']=4
m=data.setdefault('messages',{})
m.setdefault('queue',{})['debounceMs']=2500
m.setdefault('inbound',{})['debounceMs']=1800
with open(p,'w') as f: json.dump(data,f,indent=2)
print('optimization ON')
PY
else
  if [[ -f "$BKP" ]]; then
    cp "$BKP" "$CFG"
    echo "optimization OFF (restored backup)"
  else
    echo "No backup found at $BKP"
    exit 2
  fi
fi

openclaw gateway restart >/dev/null 2>&1 || true
echo "done"
