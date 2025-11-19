#!/usr/bin/env bash
set -euo pipefail

REPO="${REPO:-https://github.com/<owner>/<repo>.git}"
BRANCH="${BRANCH:-main}"
# Clone target is the repo root (no /repo suffix)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$(dirname "$SCRIPT_DIR")" && pwd)"  # .../.context-builder/projects/<owner>-<repo>
BUILDER_ROOT="$(cd "$PROJECT_DIR/../.." && pwd)"
ROOT_PARENT="$(cd "$BUILDER_ROOT/.." && pwd)"
CONTEXT_ROOT="$ROOT_PARENT/.context"
# Derive OWNER-REPO from REPO URL
.*[:/]([^/]+)/([^/.]+)(\.git)?/?$#\1 \2#')
OWNER=${OWNER:-$(printf "%s" "$_pair" | awk '{print $1}')}
REPO_NAME=${REPO_NAME:-$(printf "%s" "$_pair" | awk '{print $2}')}
DEST="${DEST:-$CONTEXT_ROOT/${OWNER}-${REPO_NAME}}"
PATTERNS_FILE="${PATTERNS_FILE:-$PROJECT_DIR/sparse-checkout}"
DEPTH="${DEPTH:-1}"

echo "Repo:    $REPO"
echo "Branch:  $BRANCH"
echo "Dest:    $DEST"
echo "Patterns:$PATTERNS_FILE"
echo "Depth:   $DEPTH"

if [ ! -f "$PATTERNS_FILE" ]; then
  echo "ERROR: patterns file not found: $PATTERNS_FILE" >&2
  exit 1
fi

mkdir -p "$DEST"

if [ -d "$DEST/.git" ]; then
  echo "Updating existing curated clone at $DEST ..."
  cd "$DEST"
  git fetch --filter=blob:none --depth="$DEPTH" origin "$BRANCH" || true
  git reset --hard "origin/$BRANCH" || true
  git clean -ffd || true
  git sparse-checkout init --no-cone >/dev/null 2>&1 || true
  install -m 0644 "$PATTERNS_FILE" .git/info/sparse-checkout
  git sparse-checkout reapply || true
else
  echo "Cloning curated repo to $DEST ..."
  git clone --filter=blob:none --no-checkout --depth "$DEPTH" --branch "$BRANCH" "$REPO" "$DEST"
  cd "$DEST"
  git sparse-checkout init --no-cone
  install -m 0644 "$PATTERNS_FILE" .git/info/sparse-checkout
  git checkout "$BRANCH"
fi

WORKING_FILES=$(find . -type f -not -path "./.git/*" | wc -l | tr -d ' ')
echo "Working tree files: $WORKING_FILES"
du -sh . 2>/dev/null | awk '{print "Working tree size:",$1}' || true
du -sh .git 2>/dev/null | awk '{print "Git dir size:",$1}' || true
