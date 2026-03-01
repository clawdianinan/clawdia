#!/usr/bin/env bash
set -euo pipefail

SNAP_ROOT="/Users/clawdia/.openclaw/backups/sessions"
LATEST="$(ls -1 "$SNAP_ROOT" 2>/dev/null | sort | tail -1 || true)"

if [[ -z "$LATEST" ]]; then
  echo "RESTORE_DRILL: FAIL - no backups found"
  exit 1
fi

BASE="$SNAP_ROOT/$LATEST"
MANIFEST="$BASE/sha256-manifest.txt"

if [[ ! -f "$MANIFEST" ]]; then
  echo "RESTORE_DRILL: FAIL - missing manifest in $BASE"
  exit 1
fi

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

# Sample restore check: copy one jsonl file and verify hash
sample_rel="$(grep -m1 '\.jsonl$' "$MANIFEST" | awk '{print $2}' || true)"
if [[ -z "$sample_rel" ]]; then
  echo "RESTORE_DRILL: FAIL - no jsonl entries in manifest"
  exit 1
fi

src="$BASE/$sample_rel"
dst="$tmpdir/$(basename "$sample_rel")"
cp "$src" "$dst"

expected="$(grep "  $sample_rel$" "$MANIFEST" | awk '{print $1}')"
actual="$(shasum -a 256 "$dst" | awk '{print $1}')"

if [[ "$expected" == "$actual" ]]; then
  echo "RESTORE_DRILL: PASS - backup=$LATEST sample=$sample_rel"
  exit 0
else
  echo "RESTORE_DRILL: FAIL - checksum mismatch sample=$sample_rel"
  exit 1
fi
