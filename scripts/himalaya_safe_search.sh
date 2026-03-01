#!/usr/bin/env bash
set -euo pipefail

# Safe Himalaya search wrapper that avoids IMAP sort/parser issues on some providers.
# Usage:
#   himalaya_safe_search.sh <account> <folder> <query> [page_size]
# Example:
#   himalaya_safe_search.sh icloud INBOX "from @ihstowers.com" 100

ACCOUNT="${1:-}"
FOLDER="${2:-INBOX}"
QUERY="${3:-}"
PAGE_SIZE="${4:-100}"

if [[ -z "$ACCOUNT" || -z "$QUERY" ]]; then
  echo "Usage: $0 <account> <folder> <query> [page_size]" >&2
  exit 2
fi

run_query() {
  local q="$1"
  himalaya -o json envelope list \
    --account "$ACCOUNT" \
    --folder "$FOLDER" \
    --page-size "$PAGE_SIZE" \
    "$q"
}

# 1) exact query
if OUT=$(run_query "$QUERY" 2>/dev/null); then
  echo "$OUT"
  exit 0
fi

# 2) remove explicit sort clause if present (common IMAP BAD parse source)
NOSORT=$(echo "$QUERY" | sed -E 's/[[:space:]]+order[[:space:]]+by[[:space:]].*$//I')
if [[ "$NOSORT" != "$QUERY" ]]; then
  if OUT=$(run_query "$NOSORT" 2>/dev/null); then
    echo "$OUT"
    exit 0
  fi
fi

# 3) fallback to broad list without query (still mailbox-scoped)
if OUT=$(himalaya -o json envelope list --account "$ACCOUNT" --folder "$FOLDER" --page-size "$PAGE_SIZE" 2>/dev/null); then
  echo "$OUT"
  exit 0
fi

echo "[]"
exit 1
