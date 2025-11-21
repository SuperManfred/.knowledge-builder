#!/usr/bin/env bash
set -euo pipefail

# Intelligently sync upstream repo based on initial vs re-curation
# Usage: check-and-sync.sh <repo-url> <dest-curated-path>

if [ $# -lt 2 ]; then
  echo "Usage: $0 <repo-url> <dest-curated-path>" >&2
  exit 1
fi

REPO_URL="$1"
DEST_CURATED="$2"
MANIFEST_PATH="/Users/MN/GITHUB/.knowledge/full-repo/MANIFEST.yaml"
SYNC_SCRIPT="$(cd "$(dirname "$0")" && pwd)/sync.sh"

# Parse repo name from URL (format: owner-repo)
parse_repo_name() {
  echo "$1" | sed -E 's#^https?://github\.com/([^/]+)/([^/\.]+)(\.git)?.*$#\1-\2#'
}

REPO_NAME=$(parse_repo_name "$REPO_URL")

# Check if this is initial curation
if [ ! -d "$DEST_CURATED" ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Initial curation detected for: $REPO_NAME"
  echo "Policy: ALWAYS sync to get absolute latest source"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exec "$SYNC_SCRIPT" "$REPO_URL"
fi

# Re-curation: Check manifest for freshness
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Re-curation detected for: $REPO_NAME"
echo "Checking upstream freshness..."

if [ ! -f "$MANIFEST_PATH" ]; then
  echo "⚠️  No manifest found - syncing to be safe"
  exec "$SYNC_SCRIPT" "$REPO_URL"
fi

# Extract last_synced date for this repo
LAST_SYNC=$(grep -A 3 "repo_name: $REPO_NAME" "$MANIFEST_PATH" | grep "last_synced:" | awk '{print $2}' || echo "")

if [ -z "$LAST_SYNC" ]; then
  echo "⚠️  Repo not in manifest - syncing"
  exec "$SYNC_SCRIPT" "$REPO_URL"
fi

# Calculate days since sync (portable: macOS & Linux)
# Detect OS and use appropriate date command
if date --version >/dev/null 2>&1; then
  # GNU date (Linux)
  LAST_SYNC_EPOCH=$(date -d "$LAST_SYNC" "+%s" 2>/dev/null || echo "0")
else
  # BSD date (macOS)
  LAST_SYNC_EPOCH=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$LAST_SYNC" "+%s" 2>/dev/null || echo "0")
fi

NOW_EPOCH=$(date "+%s")
DAYS_OLD=$(( (NOW_EPOCH - LAST_SYNC_EPOCH) / 86400 ))

# Fallback if date parsing failed
if [ "$LAST_SYNC_EPOCH" -eq 0 ]; then
  echo "⚠️  Could not parse date: $LAST_SYNC - syncing to be safe"
  exec "$SYNC_SCRIPT" "$REPO_URL"
fi

echo "Last synced: $LAST_SYNC ($DAYS_OLD days ago)"

if [ "$DAYS_OLD" -gt 7 ]; then
  echo "❌ Stale (>7 days) - syncing to get latest"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exec "$SYNC_SCRIPT" "$REPO_URL"
else
  echo "✅ Fresh (<7 days) - using existing pristine clone"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 0
fi
