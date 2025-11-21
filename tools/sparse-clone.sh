#!/usr/bin/env bash
set -euo pipefail

# Perform sparse checkout clone with robust error handling
# Step 7: Clone repository with sparse-checkout patterns
# Usage: sparse-clone.sh <repo-url> <dest-path> <sparse-checkout-file>

if [ $# -lt 3 ]; then
  echo "Usage: $0 <repo-url> <dest-path> <sparse-checkout-file>" >&2
  echo "  repo-url: Git repository URL" >&2
  echo "  dest-path: Destination for sparse clone" >&2
  echo "  sparse-checkout-file: Path to sparse-checkout patterns file" >&2
  exit 1
fi

REPO_URL="$1"
DEST="$2"
SPARSE_CHECKOUT_FILE="$3"

# Validate inputs
if [ ! -f "$SPARSE_CHECKOUT_FILE" ]; then
  echo "ERROR: Sparse checkout file not found: $SPARSE_CHECKOUT_FILE" >&2
  exit 1
fi

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "SPARSE CHECKOUT CLONE"
echo "Repository: $REPO_URL"
echo "Destination: $DEST"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ============================================================================
# Determine if this is initial clone or update
# ============================================================================
if [ -d "$DEST" ]; then
  if [ -d "$DEST/.git" ]; then
    echo ""
    echo -e "${BLUE}ℹ️  Existing repository found - performing UPDATE${NC}"
    OPERATION="update"
  else
    echo ""
    echo -e "${RED}ERROR: Destination exists but is not a git repository: $DEST${NC}" >&2
    echo "Please remove the directory or choose a different destination" >&2
    exit 1
  fi
else
  echo ""
  echo -e "${BLUE}ℹ️  No existing repository - performing INITIAL CLONE${NC}"
  OPERATION="initial"
fi

# ============================================================================
# INITIAL CLONE
# ============================================================================
if [ "$OPERATION" = "initial" ]; then
  echo ""
  echo "Step 7.1: Initializing sparse checkout clone..."
  echo "-----------------------------------------------"

  # Create destination directory
  mkdir -p "$DEST"

  # Initialize git repository
  if ! git -C "$DEST" init 2>&1; then
    echo -e "${RED}ERROR: Failed to initialize git repository${NC}" >&2
    exit 1
  fi
  echo -e "${GREEN}✅ Initialized git repository${NC}"

  # Add remote
  if ! git -C "$DEST" remote add origin "$REPO_URL" 2>&1; then
    echo -e "${RED}ERROR: Failed to add remote${NC}" >&2
    exit 1
  fi
  echo -e "${GREEN}✅ Added remote: $REPO_URL${NC}"

  # Enable sparse checkout
  if ! git -C "$DEST" config core.sparseCheckout true 2>&1; then
    echo -e "${RED}ERROR: Failed to enable sparse checkout${NC}" >&2
    exit 1
  fi
  echo -e "${GREEN}✅ Enabled sparse checkout${NC}"

  # Copy sparse-checkout patterns
  SPARSE_CHECKOUT_CONFIG="$DEST/.git/info/sparse-checkout"
  mkdir -p "$(dirname "$SPARSE_CHECKOUT_CONFIG")"
  if ! cp "$SPARSE_CHECKOUT_FILE" "$SPARSE_CHECKOUT_CONFIG" 2>&1; then
    echo -e "${RED}ERROR: Failed to copy sparse-checkout patterns${NC}" >&2
    exit 1
  fi

  PATTERN_COUNT=$(wc -l < "$SPARSE_CHECKOUT_FILE" | tr -d ' ')
  echo -e "${GREEN}✅ Configured sparse-checkout ($PATTERN_COUNT patterns)${NC}"

  echo ""
  echo "Step 7.2: Fetching repository (blobless, depth=1)..."
  echo "---------------------------------------------------"

  # Fetch with optimizations: blobless, depth=1
  # --filter=blob:none = don't download blobs until needed (saves bandwidth)
  # --depth=1 = only latest commit (saves space and time)
  if ! git -C "$DEST" fetch --filter=blob:none --depth=1 origin HEAD 2>&1; then
    echo ""
    echo -e "${RED}ERROR: Git fetch failed${NC}" >&2
    echo ""
    echo "Common causes:"
    echo "  - Network connectivity issues"
    echo "  - Invalid repository URL"
    echo "  - Authentication required (private repo)"
    echo "  - Repository does not exist"
    echo ""
    echo "Troubleshooting:"
    echo "  1. Check network connection"
    echo "  2. Verify repository URL: $REPO_URL"
    echo "  3. For private repos, ensure SSH keys or credentials are configured"
    echo "  4. Try cloning manually: git clone $REPO_URL"
    exit 1
  fi
  echo -e "${GREEN}✅ Fetch complete${NC}"

  echo ""
  echo "Step 7.3: Checking out sparse working tree..."
  echo "---------------------------------------------"

  # Checkout FETCH_HEAD to working tree (applies sparse-checkout)
  if ! git -C "$DEST" checkout FETCH_HEAD 2>&1; then
    echo -e "${RED}ERROR: Checkout failed${NC}" >&2
    exit 1
  fi
  echo -e "${GREEN}✅ Checkout complete${NC}"

# ============================================================================
# UPDATE EXISTING CLONE
# ============================================================================
else
  echo ""
  echo "Step 7.1: Updating sparse-checkout patterns..."
  echo "----------------------------------------------"

  # Update sparse-checkout patterns
  SPARSE_CHECKOUT_CONFIG="$DEST/.git/info/sparse-checkout"
  if ! cp "$SPARSE_CHECKOUT_FILE" "$SPARSE_CHECKOUT_CONFIG" 2>&1; then
    echo -e "${RED}ERROR: Failed to update sparse-checkout patterns${NC}" >&2
    exit 1
  fi

  PATTERN_COUNT=$(wc -l < "$SPARSE_CHECKOUT_FILE" | tr -d ' ')
  echo -e "${GREEN}✅ Updated sparse-checkout ($PATTERN_COUNT patterns)${NC}"

  echo ""
  echo "Step 7.2: Fetching latest changes..."
  echo "------------------------------------"

  # Fetch latest changes
  if ! git -C "$DEST" fetch --filter=blob:none origin HEAD 2>&1; then
    echo -e "${RED}ERROR: Git fetch failed${NC}" >&2
    echo "Check network connection and repository access" >&2
    exit 1
  fi
  echo -e "${GREEN}✅ Fetch complete${NC}"

  echo ""
  echo "Step 7.3: Applying sparse checkout to working tree..."
  echo "-----------------------------------------------------"

  # Reset to FETCH_HEAD (applies updated sparse-checkout)
  if ! git -C "$DEST" reset --hard FETCH_HEAD 2>&1; then
    echo -e "${RED}ERROR: Reset failed${NC}" >&2
    exit 1
  fi
  echo -e "${GREEN}✅ Working tree updated${NC}"

  # Clean up files no longer in sparse-checkout
  if ! git -C "$DEST" clean -fd 2>&1; then
    echo -e "${YELLOW}⚠️  Warning: Could not clean working tree${NC}" >&2
  fi
fi

# ============================================================================
# Verify clone success
# ============================================================================
echo ""
echo "Step 7.4: Verifying clone..."
echo "----------------------------"

# Check if destination has files
FILE_COUNT=$(find "$DEST" -type f -not -path "$DEST/.git/*" 2>/dev/null | wc -l | tr -d ' ')

if [ "$FILE_COUNT" -eq 0 ]; then
  echo -e "${YELLOW}⚠️  WARNING: No files checked out${NC}"
  echo ""
  echo "Possible causes:"
  echo "  - Sparse-checkout patterns don't match any files"
  echo "  - Repository is empty"
  echo "  - Patterns are too restrictive"
  echo ""
  echo "Check patterns in: $SPARSE_CHECKOUT_FILE"
  echo "Verify with: git -C $DEST ls-tree -r HEAD"
  exit 1
fi

echo -e "${GREEN}✅ Clone verified: $FILE_COUNT files checked out${NC}"

# Get current commit
COMMIT=$(git -C "$DEST" rev-parse HEAD 2>/dev/null || echo "unknown")
echo -e "${BLUE}ℹ️  Current commit: ${COMMIT:0:8}${NC}"

# ============================================================================
# Summary
# ============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ SPARSE CLONE COMPLETE${NC}"
echo ""
echo "Summary:"
echo "  - Operation: $OPERATION"
echo "  - Files checked out: $FILE_COUNT"
echo "  - Patterns applied: $PATTERN_COUNT"
echo "  - Commit: ${COMMIT:0:8}"
echo "  - Location: $DEST"
echo ""
echo "Next step: Run post-clone verification"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

exit 0
