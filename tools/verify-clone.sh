#!/usr/bin/env bash
set -euo pipefail

# Verify sparse clone output (Step 8: POST-CLONE VERIFICATION)
# Usage: verify-clone.sh <dest-path> <curation-type>
#   dest-path: Path to cloned curated repository
#   curation-type: "docs" or "code"

if [ $# -lt 2 ]; then
  echo "Usage: $0 <dest-path> <curation-type>" >&2
  echo "  curation-type: 'docs' or 'code'" >&2
  exit 1
fi

DEST="$1"
CURATION_TYPE="$2"

# Validate curation type
if [[ "$CURATION_TYPE" != "docs" && "$CURATION_TYPE" != "code" ]]; then
  echo "ERROR: curation-type must be 'docs' or 'code', got: $CURATION_TYPE" >&2
  exit 1
fi

# Check destination exists
if [ ! -d "$DEST" ]; then
  echo "ERROR: Destination directory not found: $DEST" >&2
  exit 1
fi

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Track verification status
VERIFICATION_FAILED=0

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "POST-CLONE VERIFICATION (Step 8)"
echo "Destination: $DEST"
echo "Type: $CURATION_TYPE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ============================================================================
# 8.1) Test file check (MUST PASS)
# ============================================================================
echo ""
echo "8.1) Test File Check (MUST PASS)"
echo "---------------------------------"

TEST_FILES=$(find "$DEST" -type f \( -name "*.test.*" -o -name "*.spec.*" -o -name "test_*" \) 2>/dev/null | wc -l | tr -d ' ')
echo "Test files found: $TEST_FILES"

if [ "$CURATION_TYPE" = "docs" ]; then
    # Docs: Allow very low count (tutorial examples showing how to test)
    if [ "$TEST_FILES" -gt 5 ]; then
        echo -e "${RED}❌ FAIL: Too many test files ($TEST_FILES > 5)${NC}"
        echo "Sample test files:"
        find "$DEST" -type f \( -name "*.test.*" -o -name "*.spec.*" -o -name "test_*" \) 2>/dev/null | head -5
        VERIFICATION_FAILED=1
    else
        if [ "$TEST_FILES" -eq 0 ]; then
            echo -e "${GREEN}✅ PASS: No test files${NC}"
        else
            echo -e "${YELLOW}⚠️  Low test file count (acceptable for doc examples)${NC}"
            find "$DEST" -type f \( -name "*.test.*" -o -name "*.spec.*" -o -name "test_*" \) 2>/dev/null
        fi
    fi
else
    # Code: MUST be 0
    if [ "$TEST_FILES" -ne 0 ]; then
        echo -e "${RED}❌ FAIL: Test files found (should be 0)${NC}"
        echo "Sample test files:"
        find "$DEST" -type f \( -name "*.test.*" -o -name "*.spec.*" -o -name "test_*" \) 2>/dev/null | head -5
        VERIFICATION_FAILED=1
    else
        echo -e "${GREEN}✅ PASS: No test files${NC}"
    fi
fi

# ============================================================================
# 8.2) Documentation check
# ============================================================================
echo ""
echo "8.2) Documentation Check"
echo "------------------------"

DOCS_DIRS=$(find "$DEST" -type d \( -name "docs" -o -name "doc" -o -name "documentation" -o -name "content" \) 2>/dev/null | wc -l | tr -d ' ')
echo "Documentation directories: $DOCS_DIRS"

if [ "$CURATION_TYPE" = "docs" ]; then
    # Docs: MUST have documentation directories
    if [ "$DOCS_DIRS" -eq 0 ]; then
        echo -e "${RED}❌ FAIL: No documentation directories found${NC}"
        echo "Expected at least one of: docs/, doc/, documentation/, content/"
        VERIFICATION_FAILED=1
    else
        echo -e "${GREEN}✅ PASS: Documentation directories present${NC}"
        find "$DEST" -type d \( -name "docs" -o -name "doc" -o -name "documentation" -o -name "content" \) 2>/dev/null | head -5
    fi
else
    # Code: MUST NOT have documentation directories
    if [ "$DOCS_DIRS" -ne 0 ]; then
        echo -e "${RED}❌ FAIL: Documentation directories found (should be excluded)${NC}"
        find "$DEST" -type d \( -name "docs" -o -name "doc" -o -name "documentation" -o -name "content" \) 2>/dev/null
        VERIFICATION_FAILED=1
    else
        echo -e "${GREEN}✅ PASS: No documentation directories${NC}"
    fi
fi

# ============================================================================
# Type-specific checks
# ============================================================================
if [ "$CURATION_TYPE" = "docs" ]; then
    # ========================================================================
    # 8.3) Website code check (SHOULD PASS)
    # ========================================================================
    echo ""
    echo "8.3) Website Code Check (SHOULD PASS)"
    echo "-------------------------------------"

    WEBSITE_CODE=$(find "$DEST" -type f \( -name "*.tsx" -o -name "*.jsx" \) 2>/dev/null | wc -l | tr -d ' ')
    echo "React component files: $WEBSITE_CODE"

    if [ "$WEBSITE_CODE" -eq 0 ]; then
        echo -e "${GREEN}✅ PASS: No website code${NC}"
    elif [ "$WEBSITE_CODE" -lt 10 ]; then
        echo -e "${YELLOW}⚠️  Low website code count (check if these are doc examples)${NC}"
        find "$DEST" -type f \( -name "*.tsx" -o -name "*.jsx" \) 2>/dev/null | head -5
    else
        echo -e "${YELLOW}⚠️  WARNING: High website code count ($WEBSITE_CODE)${NC}"
        echo "Top website code files:"
        find "$DEST" -type f \( -name "*.tsx" -o -name "*.jsx" \) 2>/dev/null | head -10
    fi

    # ========================================================================
    # 8.4) Infrastructure files check (SHOULD PASS)
    # ========================================================================
    echo ""
    echo "8.4) Infrastructure Files Check (SHOULD PASS)"
    echo "---------------------------------------------"

    INFRA_FILES=$(find "$DEST" -maxdepth 1 -type f \( -name "Dockerfile" -o -name "docker-compose.yml" -o -name "uv.lock" -o -name "setup.py" -o -name "pyproject.toml" \) 2>/dev/null | wc -l | tr -d ' ')
    echo "Infrastructure files at root: $INFRA_FILES"

    if [ "$INFRA_FILES" -eq 0 ]; then
        echo -e "${GREEN}✅ PASS: No infrastructure files${NC}"
    else
        echo -e "${YELLOW}⚠️  WARNING: Infrastructure files found:${NC}"
        find "$DEST" -maxdepth 1 -type f \( -name "Dockerfile" -o -name "docker-compose.yml" -o -name "uv.lock" -o -name "setup.py" -o -name "pyproject.toml" \) 2>/dev/null
    fi

    # ========================================================================
    # 8.5) Source code check (MUST PASS)
    # ========================================================================
    echo ""
    echo "8.5) Source Code Check (MUST PASS)"
    echo "----------------------------------"

    SRC_DIRS=$(find "$DEST" -type d \( -name "src" -o -name "lib" \) -not -path "*/docs/*" 2>/dev/null | wc -l | tr -d ' ')
    echo "Source code directories (not in docs/): $SRC_DIRS"

    if [ "$SRC_DIRS" -ne 0 ]; then
        echo -e "${RED}❌ FAIL: Source code directories found outside docs/${NC}"
        find "$DEST" -type d \( -name "src" -o -name "lib" \) -not -path "*/docs/*" 2>/dev/null
        VERIFICATION_FAILED=1
    else
        echo -e "${GREEN}✅ PASS: No source code directories outside docs${NC}"
    fi
fi

# ============================================================================
# 8.6) Size awareness (NOT a constraint)
# ============================================================================
echo ""
echo "8.6) Size Awareness"
echo "-------------------"

SIZE=$(du -sh "$DEST" 2>/dev/null | awk '{print $1}')
echo -e "${BLUE}ℹ️  Total size: $SIZE${NC}"

# Parse size for warning (rough heuristic)
SIZE_NUM=$(du -sk "$DEST" 2>/dev/null | awk '{print $1}')
if [ "$SIZE_NUM" -gt 1048576 ]; then  # >1GB
    echo -e "${YELLOW}⚠️  Large size detected (>1GB). Check for missed exclusions:${NC}"
    echo "  Common culprits: node_modules/, build/, dist/, .next/, .docusaurus/"
    echo ""
    echo "Largest directories:"
    du -sh "$DEST"/*/ 2>/dev/null | sort -rh | head -5
fi

# ============================================================================
# 8.7) File count awareness
# ============================================================================
echo ""
echo "8.7) File Count Awareness"
echo "-------------------------"

FILE_COUNT=$(find "$DEST" -type f 2>/dev/null | wc -l | tr -d ' ')
echo -e "${BLUE}ℹ️  Total files: $FILE_COUNT${NC}"

if [ "$CURATION_TYPE" = "docs" ]; then
    # Count markdown files
    MD_COUNT=$(find "$DEST" -type f \( -name "*.md" -o -name "*.mdx" \) 2>/dev/null | wc -l | tr -d ' ')
    echo -e "${BLUE}ℹ️  Markdown files: $MD_COUNT${NC}"
else
    # Count source code files
    CODE_COUNT=$(find "$DEST" -type f \( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.py" -o -name "*.go" -o -name "*.rs" \) 2>/dev/null | wc -l | tr -d ' ')
    echo -e "${BLUE}ℹ️  Source code files: $CODE_COUNT${NC}"
fi

# ============================================================================
# 8.8) Top subtrees report
# ============================================================================
echo ""
echo "8.8) Top Subtrees Report"
echo "------------------------"

SUBDIRS=$(find "$DEST" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
if [ "$SUBDIRS" -gt 0 ]; then
    echo "Top 10 directories by size:"
    du -sh "$DEST"/*/ 2>/dev/null | sort -rh | head -10
else
    echo "No subdirectories (flat structure)"
fi

# ============================================================================
# Summary
# ============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $VERIFICATION_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ ALL CRITICAL VERIFICATIONS PASSED${NC}"
    echo ""
    echo "Summary:"
    echo "  - Type: $CURATION_TYPE"
    echo "  - Size: $SIZE"
    echo "  - Files: $FILE_COUNT"
    echo "  - Test files: $TEST_FILES"
    echo "  - Docs dirs: $DOCS_DIRS"
    if [ "$CURATION_TYPE" = "docs" ]; then
        echo "  - Website code: $WEBSITE_CODE"
        echo "  - Source dirs: $SRC_DIRS"
    fi
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 0
else
    echo -e "${RED}❌ VERIFICATION FAILED${NC}"
    echo ""
    echo "⚠️  Fix sparse-checkout and re-clone before proceeding."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 1
fi
