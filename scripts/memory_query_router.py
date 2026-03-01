#!/usr/bin/env python3
"""
Canonical memory query router.
Current design:
1) Try QMD hybrid (if index looks healthy)
2) Fallback to keyword grep over MEMORY.md + memory/*.md
"""
import argparse
import json
import subprocess
from pathlib import Path

WORKSPACE = Path('/Users/clawdia/.openclaw/workspace')
HEALTH_SCRIPT = WORKSPACE / 'scripts' / 'memory_health_check.py'


def run_health():
    out = subprocess.check_output(['python3', str(HEALTH_SCRIPT)], text=True)
    return json.loads(out)


def keyword_fallback(query: str, limit: int):
    targets = [str(WORKSPACE / 'MEMORY.md')] + [str(p) for p in (WORKSPACE / 'memory').glob('*.md')]
    cmd = ['grep', '-RinE', query] + targets
    try:
        out = subprocess.check_output(cmd, text=True, stderr=subprocess.DEVNULL)
        lines = [ln for ln in out.splitlines() if ln.strip()][:limit]
        return {'mode': 'keyword-fallback', 'results': lines}
    except subprocess.CalledProcessError:
        return {'mode': 'keyword-fallback', 'results': []}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('query')
    ap.add_argument('--limit', type=int, default=10)
    args = ap.parse_args()

    health = run_health()

    # Placeholder for future QMD hybrid tool invocation.
    # While vector/hybrid remains unstable, use deterministic fallback.
    result = keyword_fallback(args.query, args.limit)
    payload = {
        'health': health,
        'query': args.query,
        'result': result,
    }
    print(json.dumps(payload, indent=2))


if __name__ == '__main__':
    main()
