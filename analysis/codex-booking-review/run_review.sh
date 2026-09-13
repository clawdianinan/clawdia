#!/bin/bash
# Codex booking review runner — one-shot, launchd-invoked.
set -uo pipefail
cd /Users/clawdia/.openclaw/workspace/analysis/codex-booking-review
BRIEF="$(cat REVIEW_BRIEF.md)"
echo "=== review started $(date '+%Y-%m-%d %H:%M:%S') pid $$ ===" >> codex-run.log
codex exec --skip-git-repo-check -C /Users/clawdia/.openclaw/workspace "$BRIEF" >> codex-run.log 2>&1
echo "=== review exited $? at $(date '+%Y-%m-%d %H:%M:%S') ===" >> codex-run.log
