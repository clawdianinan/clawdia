#!/bin/bash
# Self-Healing Morning Digest Wrapper

# Use self-healing wrapper
/Users/clawdia/.openclaw/workspace/scripts/self_healing_wrapper.sh "morning_digest" \
    '/Users/clawdia/.openclaw/workspace/morning_digest.sh | /opt/homebrew/bin/openclaw message send --channel imessage --target temikolawole@icloud.com --best-effort'