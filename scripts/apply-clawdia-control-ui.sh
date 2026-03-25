#!/usr/bin/env bash
# Rebuild Control UI from the clawdia fork and copy it over the global openclaw install.
# Run again after: npm update -g openclaw
set -euo pipefail

CLAWDIA_REPO="${CLAWDIA_REPO:-${HOME}/.openclaw/workspace/clawdia-repo}"
UI_DIR="${CLAWDIA_REPO}/ui"
SRC="${CLAWDIA_REPO}/dist/control-ui"
ROOT="$(npm root -g)"
DST="${ROOT}/openclaw/dist/control-ui"

if [[ ! -d "${UI_DIR}" ]]; then
  echo "error: UI dir not found: ${UI_DIR}" >&2
  exit 1
fi
if [[ ! -d "${DST}" ]]; then
  echo "error: global openclaw control-ui not found: ${DST}" >&2
  exit 1
fi

echo "Building Control UI in ${UI_DIR} ..."
( cd "${UI_DIR}" && npm run build )

stamp="$(date +%Y%m%d_%H%M%S)"
echo "Backing up ${DST} -> ${DST}.bak.${stamp}"
cp -R "${DST}" "${DST}.bak.${stamp}"

echo "Syncing ${SRC}/ -> ${DST}/"
rsync -a --delete "${SRC}/" "${DST}/"

echo "Done. Hard-refresh the Control UI in your browser (e.g. Cmd+Shift+R). Restart the gateway if it still serves an old bundle."
