#!/usr/bin/env python3
import argparse
import json
from pathlib import Path

POLICY_PATH = Path('/Users/clawdia/.openclaw/workspace/config/email_classification_policy.json')


def score(subject: str, body: str, external: bool):
    policy = json.loads(POLICY_PATH.read_text())
    text = f"{subject} {body}".lower()
    sensitive_hits = [k for k in policy['sensitive_keywords'] if k in text]

    confidence = 0.9
    if len(text) < 40:
        confidence -= 0.2
    if sensitive_hits:
        confidence -= 0.15
    if external:
        confidence -= 0.05
    confidence = max(0.0, min(1.0, confidence))

    if sensitive_hits and external:
        action = 'draft_only'
    elif confidence < policy['thresholds']['medium_confidence']:
        action = 'draft_only'
    else:
        action = 'can_suggest_action'

    return {
        'confidence': round(confidence, 3),
        'sensitive_hits': sensitive_hits,
        'external': external,
        'recommended_action': action,
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--subject', required=True)
    ap.add_argument('--body', default='')
    ap.add_argument('--external', action='store_true')
    args = ap.parse_args()

    print(json.dumps(score(args.subject, args.body, args.external), indent=2))


if __name__ == '__main__':
    main()
