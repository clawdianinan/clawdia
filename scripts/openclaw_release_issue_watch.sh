#!/usr/bin/env bash
# Daily (or manual): notify when an OpenClaw GitHub release likely includes the
# Control UI model-picker fix tracked as https://github.com/openclaw/openclaw/issues/51957
set -euo pipefail

STATE_DIR="${HOME}/.openclaw/state"
NOTIFIED="${STATE_DIR}/openclaw_issue_51957_notified_releases.log"
LOG="${HOME}/.openclaw/logs/openclaw-release-watch.log"
REPO="openclaw/openclaw"
ISSUE="51957"
PER_PAGE="${PER_PAGE:-25}"

mkdir -p "$STATE_DIR" "${HOME}/.openclaw/logs"
touch "$NOTIFIED"

log() {
  echo "$(date -Iseconds) $*" | tee -a "$LOG"
}

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

if ! curl -fsSL -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/${REPO}/releases?per_page=${PER_PAGE}" -o "$tmp"; then
  log "error: failed to fetch GitHub releases"
  exit 1
fi

export OPENCLAW_RELEASE_WATCH_JSON="$tmp"
export OPENCLAW_RELEASE_WATCH_NOTIFIED="$NOTIFIED"
export OPENCLAW_RELEASE_WATCH_ISSUE="$ISSUE"
export OPENCLAW_RELEASE_WATCH_REPO="$REPO"
node <<'NODE'
const fs = require("fs");
const { execFileSync } = require("child_process");
const tmp = process.env.OPENCLAW_RELEASE_WATCH_JSON;
const notifiedPath = process.env.OPENCLAW_RELEASE_WATCH_NOTIFIED;
const issue = process.env.OPENCLAW_RELEASE_WATCH_ISSUE;
const repo = process.env.OPENCLAW_RELEASE_WATCH_REPO || "openclaw/openclaw";
const notified = new Set(
  fs.readFileSync(notifiedPath, "utf8").split("\n").map((l) => l.trim()).filter(Boolean),
);
const releases = JSON.parse(fs.readFileSync(tmp, "utf8"));
if (!Array.isArray(releases)) {
  console.error("unexpected releases payload");
  process.exit(1);
}
const bodyHaystack = (r) => `${r.body || ""}\n${r.name || ""}\n${r.tag_name || ""}`;
// Only notify when the release explicitly references this issue (avoid noisy heuristics).
const mentionsIssue = (text) =>
  new RegExp(`(?:#|issues/)${issue}(?:\\b|[^0-9])`).test(text) ||
  text.includes(`pull/${issue}`) ||
  text.includes(`github.com/${repo}/issues/${issue}`);

for (const r of releases) {
  const tag = (r.tag_name || r.name || "").trim();
  if (!tag || notified.has(tag)) continue;
  const text = bodyHaystack(r);
  if (!mentionsIssue(text)) continue;
  notified.add(tag);
  const msg = `OpenClaw ${tag} may include fix for issue #${issue} (Control UI model picker). Run: npm view openclaw version`;
  try {
    execFileSync(
      "osascript",
      [
        "-e",
        `display notification ${JSON.stringify(msg)} with title ${JSON.stringify("OpenClaw release watch")}`,
      ],
      { stdio: "inherit" },
    );
  } catch {
    console.error("osascript failed (non-macOS or automation denied?)");
  }
  fs.appendFileSync(notifiedPath, tag + "\n");
  console.log("notified:", tag);
}
NODE

log "ok: scan complete"
