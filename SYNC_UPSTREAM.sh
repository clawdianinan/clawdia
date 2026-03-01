#!/usr/bin/env bash
set -euo pipefail

# Sync helper for Clawdia fork strategy
# - upstream/main mirrors openclaw/main updates
# - clawdia/main carries curated customizations
# - clawdia/dev is active development branch

REMOTE_UPSTREAM="upstream"
REMOTE_ORIGIN="origin"

msg() { printf "\n[%s] %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$*"; }

ensure_clean() {
  if [[ -n "$(git status --porcelain)" ]]; then
    echo "Working tree is not clean. Commit/stash changes first."
    exit 1
  fi
}

ensure_branch_exists() {
  local branch="$1"
  if ! git show-ref --verify --quiet "refs/heads/${branch}"; then
    echo "Missing local branch: ${branch}"
    exit 1
  fi
}

msg "Checking remotes"
git remote get-url "$REMOTE_UPSTREAM" >/dev/null
git remote get-url "$REMOTE_ORIGIN" >/dev/null

ensure_clean

msg "Fetching remotes"
git fetch "$REMOTE_UPSTREAM" --prune
git fetch "$REMOTE_ORIGIN" --prune

msg "Step 1: Fast-forward local main from upstream/main"
git checkout main
git reset --hard "$REMOTE_UPSTREAM/main"

msg "Pushing main mirror to origin/main"
git push "$REMOTE_ORIGIN" main --force-with-lease

# Branch setup expectations
ensure_branch_exists "clawdia/main"
ensure_branch_exists "clawdia/dev"

msg "Step 2: Rebase clawdia/main on fresh main"
git checkout clawdia/main
git rebase main

git push "$REMOTE_ORIGIN" clawdia/main --force-with-lease

msg "Step 3: Rebase clawdia/dev on clawdia/main"
git checkout clawdia/dev
git rebase clawdia/main

git push "$REMOTE_ORIGIN" clawdia/dev --force-with-lease

msg "Sync complete"
msg "Tips:"
echo "- Open PRs from clawdia/dev -> clawdia/main"
echo "- Keep clawdia/main production-ready"
echo "- Repeat this script when upstream updates"
