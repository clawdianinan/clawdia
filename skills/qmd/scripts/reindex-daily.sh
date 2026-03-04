#!/bin/bash
# QMD Daily Reindex Helper
# Rebuilds memory index for daily maintenance jobs.

set -euo pipefail

WORKSPACE="/Users/clawdia/.openclaw/workspace"
cd "$WORKSPACE"

python3 skills/qmd/qmd.py index --path memory
