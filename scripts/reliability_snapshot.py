#!/usr/bin/env python3
import json
import subprocess
from datetime import datetime
from pathlib import Path

WORKSPACE = Path('/Users/clawdia/.openclaw/workspace')


def run(cmd):
    try:
        return subprocess.check_output(cmd, text=True).strip()
    except Exception:
        return ''


def main():
    ts = datetime.now().isoformat(timespec='seconds')

    # memory health
    mh_raw = run(['python3', str(WORKSPACE / 'scripts' / 'memory_health_check.py')])
    memory_health = json.loads(mh_raw) if mh_raw else {'status': 'unknown'}

    # duplicate-safety signal from config (best-effort)
    cfg = run(['python3', '-c', "import json;print(json.dumps(json.load(open('/Users/clawdia/.openclaw/openclaw.json')).get('messages',{})))"])
    messages_cfg = json.loads(cfg) if cfg else {}

    # Model resilience check (replaces ollama check)
    model_check = {}
    if Path(WORKSPACE / 'scripts' / 'model_resilience_check.sh').exists():
        try:
            result = subprocess.run([str(WORKSPACE / 'scripts' / 'model_resilience_check.sh')], 
                                   capture_output=True, text=True, timeout=30)
            model_check = {
                'status': 'ok' if result.returncode == 0 else 'warning',
                'output': result.stdout.strip()[:200],
                'timestamp': ts
            }
        except Exception as e:
            model_check = {'status': 'error', 'error': str(e)}

    report = {
        'timestamp': ts,
        'memory': memory_health,
        'model_resilience': model_check,
        'messaging': {
            'queue_mode': messages_cfg.get('queue', {}).get('mode'),
            'inbound_debounce_ms': messages_cfg.get('inbound', {}).get('debounceMs'),
            'imessage_inbound_debounce_ms': messages_cfg.get('inbound', {}).get('byChannel', {}).get('imessage'),
        },
        'email': {
            'policy_file': str(WORKSPACE / 'config' / 'email_classification_policy.json'),
            'confidence_gating': 'enabled-via-script'
        }
    }

    out = WORKSPACE / 'logs' / 'reliability_snapshot.json'
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(report, indent=2))
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()
