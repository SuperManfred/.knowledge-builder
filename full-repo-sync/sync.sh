#!/usr/bin/env bash
set -euo pipefail

# Full Repo Sync - Maintain pristine git repository clones
# Usage: ./sync.sh <github-url> [--branch=BRANCH] [--force]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
KNOWLEDGE_ROOT="$(cd "$SCRIPT_DIR/../../.knowledge" && pwd)"
FULL_REPO_DIR="$KNOWLEDGE_ROOT/full-repo"
MANIFEST_FILE="$FULL_REPO_DIR/MANIFEST.yaml"
STALENESS_DAYS=7

# Parse arguments
REPO_URL=""
BRANCH=""
FORCE=false

for arg in "$@"; do
  case $arg in
    --branch=*)
      BRANCH="${arg#*=}"
      shift
      ;;
    --force)
      FORCE=true
      shift
      ;;
    *)
      if [ -z "$REPO_URL" ]; then
        REPO_URL="$arg"
      fi
      ;;
  esac
done

if [ -z "$REPO_URL" ]; then
  echo "Usage: $0 <repo-url> [--branch=BRANCH] [--force]" >&2
  echo "" >&2
  echo "Examples:" >&2
  echo "  $0 https://github.com/vercel/next.js" >&2
  echo "  $0 https://bitbucket.org/owner/repo" >&2
  echo "  $0 https://github.com/vercel/next.js --branch=canary" >&2
  echo "  $0 https://github.com/vercel/next.js --force" >&2
  exit 1
fi

# Parse owner and repo from URL (platform-agnostic: GitHub, Bitbucket, GitLab, etc.)
TRIMMED_URL="${REPO_URL%.git}"
TRIMMED_URL="${TRIMMED_URL%/}"
PAIR=$(printf "%s\n" "$TRIMMED_URL" | sed -E 's#.*[:/]([^/]+)/([^/]+?)$#\1 \2#') || true
OWNER=$(printf "%s" "$PAIR" | awk '{print $1}')
REPO_NAME=$(printf "%s" "$PAIR" | awk '{print $2}')

if [ -z "${OWNER:-}" ] || [ -z "${REPO_NAME:-}" ]; then
  echo "ERROR: Could not parse owner/repo from URL: $REPO_URL" >&2
  exit 1
fi

# Normalize to lowercase with hyphen
REPO_DIR_NAME=$(printf "%s-%s" "$OWNER" "$REPO_NAME" | tr '[:upper:]' '[:lower:]')
REPO_DIR="$FULL_REPO_DIR/$REPO_DIR_NAME"

echo "==> Syncing: $OWNER/$REPO_NAME"
echo "    URL: $REPO_URL"
echo "    Target: $REPO_DIR"

# Create full-repo directory if needed
mkdir -p "$FULL_REPO_DIR"

# Initialize MANIFEST.yaml if it doesn't exist
if [ ! -f "$MANIFEST_FILE" ]; then
  echo "repos: []" > "$MANIFEST_FILE"
  echo "    Created MANIFEST.yaml"
fi

# Check if repo exists in manifest
check_staleness() {
  if ! command -v yq &> /dev/null; then
    echo "    WARNING: yq not found, skipping staleness check (install with: brew install yq)" >&2
    return 1  # Treat as stale if we can't check
  fi

  local last_synced
  last_synced=$(yq eval ".repos[] | select(.name == \"$REPO_DIR_NAME\") | .last_synced" "$MANIFEST_FILE" 2>/dev/null || echo "null")

  if [ "$last_synced" = "null" ] || [ -z "$last_synced" ]; then
    echo "    Not in manifest (first sync)"
    return 1  # Stale (doesn't exist)
  fi

  # Calculate age in days
  if command -v gdate &> /dev/null; then
    DATE_CMD=gdate  # macOS with coreutils
  else
    DATE_CMD=date
  fi

  local last_epoch
  local now_epoch
  last_epoch=$($DATE_CMD -d "$last_synced" +%s 2>/dev/null || $DATE_CMD -j -f "%Y-%m-%dT%H:%M:%SZ" "$last_synced" +%s 2>/dev/null || echo "0")
  now_epoch=$($DATE_CMD +%s)
  local age_days=$(( (now_epoch - last_epoch) / 86400 ))

  echo "    Last synced: $last_synced ($age_days days ago)"

  if [ "$age_days" -gt "$STALENESS_DAYS" ]; then
    echo "    Status: STALE (>$STALENESS_DAYS days)"
    return 1  # Stale
  else
    echo "    Status: FRESH (<$STALENESS_DAYS days)"
    return 0  # Fresh
  fi
}

# Determine if we should sync
SHOULD_SYNC=false

if [ "$FORCE" = true ]; then
  echo "    Force flag set, will sync"
  SHOULD_SYNC=true
elif [ ! -d "$REPO_DIR" ]; then
  echo "    Directory doesn't exist, will clone"
  SHOULD_SYNC=true
elif ! check_staleness; then
  SHOULD_SYNC=true
fi

if [ "$SHOULD_SYNC" = false ]; then
  echo "    Skipping sync (fresh and not forced)"
  exit 0
fi

# Clone or pull
if [ ! -d "$REPO_DIR" ]; then
  echo "==> Cloning repository..."

  # Determine branch
  if [ -z "$BRANCH" ]; then
    # Clone without specifying branch (get default)
    git clone "$REPO_URL" "$REPO_DIR"
    cd "$REPO_DIR"
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
    echo "    Detected default branch: $BRANCH"
  else
    # Clone specific branch
    git clone --branch "$BRANCH" "$REPO_URL" "$REPO_DIR"
    cd "$REPO_DIR"
  fi
else
  echo "==> Updating existing repository..."
  cd "$REPO_DIR"

  # Determine branch
  if [ -z "$BRANCH" ]; then
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
    echo "    Current branch: $BRANCH"
  else
    echo "    Switching to branch: $BRANCH"
    git checkout "$BRANCH" 2>/dev/null || git checkout -b "$BRANCH" "origin/$BRANCH"
  fi

  # Pull latest
  git pull origin "$BRANCH"
fi

# Get current commit SHA
COMMIT_SHA=$(git rev-parse HEAD)
echo "    Current commit: $COMMIT_SHA"

# Update MANIFEST.yaml
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

if command -v yq &> /dev/null; then
  # Remove existing entry for this repo (if any)
  yq eval -i "del(.repos[] | select(.name == \"$REPO_DIR_NAME\"))" "$MANIFEST_FILE"

  # Add new entry
  yq eval -i ".repos += [{
    \"name\": \"$REPO_DIR_NAME\",
    \"url\": \"$REPO_URL\",
    \"branch\": \"$BRANCH\",
    \"last_synced\": \"$TIMESTAMP\",
    \"commit\": \"$COMMIT_SHA\"
  }]" "$MANIFEST_FILE"

  echo "==> Updated MANIFEST.yaml"
else
  echo "WARNING: yq not found, cannot update MANIFEST.yaml (install with: brew install yq)" >&2
  echo "         Manual entry needed:" >&2
  echo "         - name: $REPO_DIR_NAME" >&2
  echo "           url: $REPO_URL" >&2
  echo "           branch: $BRANCH" >&2
  echo "           last_synced: $TIMESTAMP" >&2
  echo "           commit: $COMMIT_SHA" >&2
fi

echo "==> Sync complete: $REPO_DIR_NAME"
