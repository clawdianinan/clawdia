#!/usr/bin/env bash
set -euo pipefail

# Checks configured Himalaya accounts and prints concise status lines.
ACCOUNTS=(iih_clawdia iih_temi gmail icloud)

for a in "${ACCOUNTS[@]}"; do
  if himalaya account doctor "$a" >/tmp/him_doc_${a}.log 2>&1; then
    echo "$a: OK"
  else
    err=$(grep -m1 -E "authentication failed|cannot|Error:" /tmp/him_doc_${a}.log | sed 's/\x1b\[[0-9;]*m//g')
    [[ -z "$err" ]] && err="FAILED"
    echo "$a: DEGRADED - $err"
  fi
done
