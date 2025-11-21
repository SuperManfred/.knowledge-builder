#!/usr/bin/env bash
set -euo pipefail

# Validate curation artifacts (Step 6: VALIDATION GATES)
# Usage: validate-curation.sh <project-dir> <curation-type>
#   project-dir: Path to projects/<owner>-<repo>/ containing artifacts
#   curation-type: "docs" or "code"

if [ $# -lt 2 ]; then
  echo "Usage: $0 <project-dir> <curation-type>" >&2
  echo "  curation-type: 'docs' or 'code'" >&2
  exit 1
fi

PROJECT_DIR="$1"
CURATION_TYPE="$2"

# Validate curation type
if [[ "$CURATION_TYPE" != "docs" && "$CURATION_TYPE" != "code" ]]; then
  echo "ERROR: curation-type must be 'docs' or 'code', got: $CURATION_TYPE" >&2
  exit 1
fi

# Files to validate
CURATED_TREE="$PROJECT_DIR/curated-tree.json"
SPARSE_CHECKOUT="$PROJECT_DIR/sparse-checkout"
CURATION_YAML="$PROJECT_DIR/curation.yaml"

# Check files exist
for file in "$CURATED_TREE" "$SPARSE_CHECKOUT" "$CURATION_YAML"; do
  if [ ! -f "$file" ]; then
    echo "ERROR: Required file not found: $file" >&2
    exit 1
  fi
done

# Exit codes
EXIT_SUCCESS=0
EXIT_SCHEMA_FAIL=1
EXIT_CONSISTENCY_FAIL=2
EXIT_PATTERN_FAIL=3

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track validation status
VALIDATION_FAILED=0

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "VALIDATION GATES (Step 6)"
echo "Project: $PROJECT_DIR"
echo "Type: $CURATION_TYPE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ============================================================================
# 6.1) Schema validation
# ============================================================================
echo ""
echo "6.1) Schema Validation"
echo "----------------------"

# Check JSON is valid
if ! jq empty "$CURATED_TREE" 2>/dev/null; then
    echo -e "${RED}❌ FAIL: Invalid JSON in curated-tree.json${NC}"
    VALIDATION_FAILED=1
else
    echo -e "${GREEN}✅ Valid JSON${NC}"
fi

# Check required fields
REQUIRED_FIELDS=("repo" "branch" "commit" "truncated" "entries")
for field in "${REQUIRED_FIELDS[@]}"; do
    if ! jq -e ".$field" "$CURATED_TREE" >/dev/null 2>&1; then
        echo -e "${RED}❌ FAIL: Missing required field: $field${NC}"
        VALIDATION_FAILED=1
    fi
done

# Check reason formats (MUST be exactly one of three formats)
echo "Validating reason formats..."

INVALID_REASONS=$(jq -r '.entries[].reasons[]' "$CURATED_TREE" 2>/dev/null | while IFS= read -r reason; do
    # Check if matches any valid pattern
    if [[ "$reason" =~ ^Included\ by\ pattern\ \'.+\'$ ]] || \
       [[ "$reason" =~ ^Excluded\ by\ pattern\ \'.+\'$ ]] || \
       [[ "$reason" == "Outside include patterns" ]]; then
        : # Valid, skip
    else
        echo "$reason"
    fi
done)

if [ -n "$INVALID_REASONS" ]; then
    echo -e "${RED}❌ FAIL: Invalid reason formats found:${NC}"
    echo "$INVALID_REASONS" | head -5
    echo ""
    echo "Allowed formats:"
    echo "  - \"Included by pattern '<actual_glob>'\""
    echo "  - \"Excluded by pattern '<actual_glob>'\""
    echo "  - \"Outside include patterns\""
    VALIDATION_FAILED=1
else
    echo -e "${GREEN}✅ All reasons match allowed formats${NC}"
fi

# Check path slash rules (dirs end with /, files don't)
INVALID_DIR_PATHS=$(jq -r '.entries[] | select(.node == "dir" and (.path | endswith("/") | not)) | .path' "$CURATED_TREE" 2>/dev/null)
if [ -n "$INVALID_DIR_PATHS" ]; then
    echo -e "${RED}❌ FAIL: Directory paths not ending with /:${NC}"
    echo "$INVALID_DIR_PATHS" | head -5
    VALIDATION_FAILED=1
else
    echo -e "${GREEN}✅ Directory paths end with /${NC}"
fi

INVALID_FILE_PATHS=$(jq -r '.entries[] | select(.node == "file" and (.path | endswith("/"))) | .path' "$CURATED_TREE" 2>/dev/null)
if [ -n "$INVALID_FILE_PATHS" ]; then
    echo -e "${RED}❌ FAIL: File paths ending with /:${NC}"
    echo "$INVALID_FILE_PATHS" | head -5
    VALIDATION_FAILED=1
else
    echo -e "${GREEN}✅ File paths don't end with /${NC}"
fi

# ============================================================================
# 6.2) Consistency validation
# ============================================================================
echo ""
echo "6.2) Consistency Validation"
echo "---------------------------"

# Check for mixed directories with children
MIXED_DIRS=$(jq -r '.entries[] | select(.decision == "mixed" and .node == "dir") | .path' "$CURATED_TREE" 2>/dev/null)
if [ -n "$MIXED_DIRS" ]; then
    MIXED_VALIDATION_PASS=1
    while IFS= read -r dir; do
        # Check if children exist
        CHILDREN_COUNT=$(jq -r --arg dir "$dir" '.entries[] | select(.path | startswith($dir) and .path != $dir) | .path' "$CURATED_TREE" | wc -l | tr -d ' ')
        if [ "$CHILDREN_COUNT" -eq 0 ]; then
            echo -e "${RED}❌ FAIL: Mixed directory has no children: $dir${NC}"
            VALIDATION_FAILED=1
            MIXED_VALIDATION_PASS=0
        fi
    done <<< "$MIXED_DIRS"

    if [ $MIXED_VALIDATION_PASS -eq 1 ]; then
        MIXED_COUNT=$(echo "$MIXED_DIRS" | wc -l | tr -d ' ')
        echo -e "${GREEN}✅ All mixed directories have children ($MIXED_COUNT dirs)${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  No mixed directories to validate${NC}"
fi

# Check global exclusions present
echo "Checking mandatory global exclusions..."

if [ "$CURATION_TYPE" = "docs" ]; then
    REQUIRED_EXCLUSIONS=(
        "!**/__tests__/**"
        "!**/test/**"
        "!**/tests/**"
        "!**/*.test.*"
        "!**/*.spec.*"
        "!**/*.tsx"
        "!**/*.jsx"
    )
else
    REQUIRED_EXCLUSIONS=(
        "!**/__tests__/**"
        "!**/test/**"
        "!**/tests/**"
        "!**/*.test.*"
        "!**/*.spec.*"
        "!docs/**"
        "!doc/**"
    )
fi

MISSING_EXCLUSIONS=""
for exclusion in "${REQUIRED_EXCLUSIONS[@]}"; do
    if ! grep -qF "$exclusion" "$SPARSE_CHECKOUT"; then
        echo -e "${RED}❌ FAIL: Missing mandatory exclusion: $exclusion${NC}"
        VALIDATION_FAILED=1
        MISSING_EXCLUSIONS="$MISSING_EXCLUSIONS\n  - $exclusion"
    fi
done

if [ -z "$MISSING_EXCLUSIONS" ]; then
    echo -e "${GREEN}✅ All mandatory global exclusions present (${#REQUIRED_EXCLUSIONS[@]} patterns)${NC}"
fi

# ============================================================================
# 6.3) Pattern validation
# ============================================================================
echo ""
echo "6.3) Pattern Validation"
echo "----------------------"

# Every keep/omit decision must cite a pattern
MISSING_PATTERN=$(jq -r '.entries[] | select(.decision == "keep" or .decision == "omit") | select(.reasons == [] or .reasons == null) | .path' "$CURATED_TREE" 2>/dev/null)
if [ -n "$MISSING_PATTERN" ]; then
    echo -e "${RED}❌ FAIL: Entries without pattern citations:${NC}"
    echo "$MISSING_PATTERN" | head -5
    VALIDATION_FAILED=1
else
    echo -e "${GREEN}✅ All keep/omit decisions cite patterns${NC}"
fi

# Check for "Outside include patterns" in top-level directories (suspicious)
OUTSIDE_TOPLEVEL=$(jq -r '.entries[] | select(.path | split("/") | length == 2) | select(.reasons[] | contains("Outside include patterns")) | .path' "$CURATED_TREE" 2>/dev/null)
if [ -n "$OUTSIDE_TOPLEVEL" ]; then
    echo -e "${YELLOW}⚠️  Top-level directories marked 'Outside include patterns':${NC}"
    echo "$OUTSIDE_TOPLEVEL"
fi

# Type-specific validation
if [ "$CURATION_TYPE" = "docs" ]; then
    echo ""
    echo "Docs-specific validation:"
    echo "-------------------------"

    # Docs: Check that docs directories are being kept
    DOCS_KEPT=$(jq -r '.entries[] | select(.path | test("docs?/|documentation/|content/")) | select(.decision == "keep" or .decision == "keep_all" or .decision == "mixed") | .path' "$CURATED_TREE" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$DOCS_KEPT" -eq 0 ]; then
        echo -e "${RED}❌ FAIL: No documentation directories being kept${NC}"
        VALIDATION_FAILED=1
    else
        echo -e "${GREEN}✅ Documentation directories being kept ($DOCS_KEPT)${NC}"
    fi

    # Docs: Check that website infrastructure is being excluded
    WEBSITE_EXCLUDED=$(jq -r '.entries[] | select(.path | test("website/.*\\.(jsx|tsx)|next\\.config|docusaurus\\.config")) | select(.decision == "omit" or .decision == "omit_all") | .path' "$CURATED_TREE" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$WEBSITE_EXCLUDED" -gt 0 ]; then
        echo -e "${GREEN}✅ Website infrastructure excluded ($WEBSITE_EXCLUDED items)${NC}"
    else
        echo -e "${YELLOW}⚠️  No website infrastructure found to exclude${NC}"
    fi
else
    echo ""
    echo "Code-specific validation:"
    echo "-------------------------"

    # Code: Check that docs directories are being excluded
    DOCS_EXCLUDED=$(jq -r '.entries[] | select(.path | test("^docs?/|^documentation/|^website/")) | select(.decision == "omit" or .decision == "omit_all") | .path' "$CURATED_TREE" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$DOCS_EXCLUDED" -eq 0 ]; then
        echo -e "${YELLOW}⚠️  No documentation directories found to exclude${NC}"
    else
        echo -e "${GREEN}✅ Documentation directories excluded ($DOCS_EXCLUDED)${NC}"
    fi

    # Code: Check source directories are being kept
    SRC_KEPT=$(jq -r '.entries[] | select(.path | test("^src/|^lib/|^packages/.*/src/")) | select(.decision == "keep" or .decision == "keep_all" or .decision == "mixed") | .path' "$CURATED_TREE" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$SRC_KEPT" -eq 0 ]; then
        echo -e "${YELLOW}⚠️  No source directories being kept (unusual for code curation)${NC}"
    else
        echo -e "${GREEN}✅ Source directories being kept ($SRC_KEPT)${NC}"
    fi
fi

# ============================================================================
# Summary
# ============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $VALIDATION_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ ALL VALIDATION GATES PASSED${NC}"
    echo ""
    TOTAL_ENTRIES=$(jq '.entries | length' "$CURATED_TREE")
    KEPT_ENTRIES=$(jq '[.entries[] | select(.decision == "keep" or .decision == "keep_all")] | length' "$CURATED_TREE")
    echo "Summary:"
    echo "  - Total entries: $TOTAL_ENTRIES"
    echo "  - Kept entries: $KEPT_ENTRIES"
    echo "  - Curation type: $CURATION_TYPE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit $EXIT_SUCCESS
else
    echo -e "${RED}❌ VALIDATION FAILED${NC}"
    echo ""
    echo "⚠️  Fix errors above and regenerate artifacts before proceeding."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit $EXIT_SCHEMA_FAIL
fi
