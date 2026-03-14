#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$HOME/.openclaw/workspace}"
AGENTS_DIR="$ROOT/agents"
RECOVERY_DIR="$AGENTS_DIR/_recovery"
TEMPLATES_DIR="$RECOVERY_DIR/templates"
ARCHIVES_DIR="$RECOVERY_DIR/archives"
MANIFEST="$RECOVERY_DIR/manifest.sha256"

mkdir -p "$TEMPLATES_DIR" "$ARCHIVES_DIR"

if [[ ! -d "$AGENTS_DIR" ]]; then
  echo "❌ agents directory not found: $AGENTS_DIR"
  exit 1
fi

# Build list of agent dirs dynamically (excludes internal/system dirs)
AGENT_NAMES=()
while IFS= read -r agent; do
  AGENT_NAMES+=("$agent")
done < <(find "$AGENTS_DIR" -mindepth 1 -maxdepth 1 -type d \
  ! -name '_recovery' \
  ! -name '__pycache__' \
  ! -name '.git' \
  -exec basename {} \; | sort)

if [[ ${#AGENT_NAMES[@]} -eq 0 ]]; then
  echo "⚠️ No agent folders found under $AGENTS_DIR"
  exit 0
fi

# Refresh template snapshot for each agent
for agent in "${AGENT_NAMES[@]}"; do
  src="$AGENTS_DIR/$agent"
  dst="$TEMPLATES_DIR/$agent"
  mkdir -p "$dst"

  # Copy all markdown config/system files + optional yaml/json configs
  rsync -a --delete \
    --include='*/' \
    --include='*.md' \
    --include='*.yaml' \
    --include='*.yml' \
    --include='*.json' \
    --exclude='*' \
    "$src/" "$dst/"

  echo "✅ Snapshotted agent templates: $agent"
done

# Write an agent index for restore automation
printf "%s\n" "${AGENT_NAMES[@]}" > "$RECOVERY_DIR/agents.index"

# Rebuild checksum manifest
find "$TEMPLATES_DIR" -type f | sort | xargs shasum -a 256 > "$MANIFEST"

# Create timestamped full archive (includes scripts, templates, manifest)
stamp="$(date +%Y%m%d_%H%M%S)"
archive="$ARCHIVES_DIR/agents_recovery_bundle_${stamp}.tar.gz"
tmp_archive="/tmp/agents_recovery_bundle_${stamp}.tar.gz"

tar -czf "$tmp_archive" -C "$AGENTS_DIR" _recovery
mv "$tmp_archive" "$archive"

# Update stable latest copy for quick restore portability
cp "$archive" "$ARCHIVES_DIR/latest_agents_recovery_bundle.tar.gz"

echo
echo "Backup complete"
echo "- Agents captured: ${#AGENT_NAMES[@]}"
echo "- Index: $RECOVERY_DIR/agents.index"
echo "- Manifest: $MANIFEST"
echo "- Archive: $archive"
echo "- Latest: $ARCHIVES_DIR/latest_agents_recovery_bundle.tar.gz"