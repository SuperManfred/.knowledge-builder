#!/usr/bin/env bash
set -euo pipefail

# Scaffold a new curated project under .context-builder/projects/<owner>-<repo>/
# Usage: .context-builder/tools/scaffold.sh <repo-url> [branch]

if [ $# -lt 1 ]; then
  echo "Usage: $0 <repo-url> [branch]" >&2
  exit 1
fi

REPO_URL="$1"
BRANCH="${2:-main}"

# Parse owner and repo from URL
TRIMMED_URL="${REPO_URL%.git}"
TRIMMED_URL="${TRIMMED_URL%/}"
PAIR=$(printf "%s\n" "$TRIMMED_URL" | sed -E 's#.*github.com[:/]+([^/]+)/([^/]+)$#\1 \2#') || true
OWNER=$(printf "%s" "$PAIR" | awk '{print $1}')
REPO_NAME=$(printf "%s" "$PAIR" | awk '{print $2}')
if [ -z "${OWNER:-}" ] || [ -z "${REPO_NAME:-}" ]; then
  echo "ERROR: Could not parse owner/repo from URL: $REPO_URL" >&2
  exit 1
fi

BUILDER_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST_DIR="$BUILDER_ROOT/projects/${OWNER}-${REPO_NAME}"

if [ -e "$DEST_DIR" ]; then
  echo "ERROR: Destination already exists: $DEST_DIR" >&2
  exit 1
fi

mkdir -p "$DEST_DIR/scripts"

# Copy and fill curation.yaml
cp "$BUILDER_ROOT/_template/curation.yaml.example" "$DEST_DIR/curation.yaml"
today=$(date +%F)
sed -i '' \
  -e "s#https://github.com/<owner>/<repo>.git#$REPO_URL#g" \
  -e "s#branch: main#branch: $BRANCH#g" \
  -e "s#date: .*#date: $today#g" \
  "$DEST_DIR/curation.yaml"

# Copy sparse-checkout (no owner/repo placeholders inside)
cp "$BUILDER_ROOT/_template/sparse-checkout.example" "$DEST_DIR/sparse-checkout"

# Copy and fill script
cp "$BUILDER_ROOT/_template/scripts/curate.sh.template" "$DEST_DIR/scripts/curate.sh"
sed -i '' \
  -e "s#https://github.com/<owner>/<repo>.git#$REPO_URL#g" \
  "$DEST_DIR/scripts/curate.sh"
chmod +x "$DEST_DIR/scripts/curate.sh"

echo "Scaffolded project at: $DEST_DIR"
echo "- curation.yaml"
echo "- sparse-checkout"
echo "- scripts/curate.sh"
echo "Next: run .context-builder/tools/generate-manifest.sh ${OWNER}-${REPO_NAME} $BRANCH, then bash $DEST_DIR/scripts/curate.sh"
