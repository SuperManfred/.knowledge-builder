#!/bin/bash

# Verify Curation Script
# Validates SPECIALIST-PROMPT.md structure and content quality
# Checks for anti-patterns and ensures 10X Engineer 10x engineer expertise

set -e

# Usage
if [ $# -lt 1 ]; then
    echo "Usage: $0 <path-to-SPECIALIST-PROMPT.md>"
    echo ""
    echo "Validates specialist prompt structure and content quality."
    echo "Checks for:"
    echo "  - Required XML sections"
    echo "  - Metadata completeness"
    echo "  - Anti-patterns (Q&A, navigation, abstraction)"
    echo "  - Expertise indicators"
    echo "  - Cutting-edge awareness"
    exit 1
fi

SPECIALIST_FILE="$1"

# Verify file exists
if [ ! -f "$SPECIALIST_FILE" ]; then
    echo "❌ ERROR: File not found: $SPECIALIST_FILE"
    exit 1
fi

echo "========================================="
echo "Validating SPECIALIST-PROMPT.md"
echo "========================================="
echo "File: $SPECIALIST_FILE"
echo ""

# Track overall validation status
WARNINGS=0
ERRORS=0

# ==========================================
# 1. Check for required XML sections
# ==========================================
echo "📋 Checking required XML sections..."

MISSING_SECTIONS=""
grep -q "<role>" "$SPECIALIST_FILE" || MISSING_SECTIONS="${MISSING_SECTIONS}<role> "
grep -q "<knowledge_base>" "$SPECIALIST_FILE" || MISSING_SECTIONS="${MISSING_SECTIONS}<knowledge_base> "
grep -q "<metadata>" "$SPECIALIST_FILE" || MISSING_SECTIONS="${MISSING_SECTIONS}<metadata> "
grep -q "<internalized_expertise>" "$SPECIALIST_FILE" || MISSING_SECTIONS="${MISSING_SECTIONS}<internalized_expertise> "
grep -q "<initialization>" "$SPECIALIST_FILE" || MISSING_SECTIONS="${MISSING_SECTIONS}<initialization> "

if [ -n "$MISSING_SECTIONS" ]; then
    echo "❌ ERROR: Missing required sections: $MISSING_SECTIONS"
    echo "   The specialist prompt structure is invalid."
    ERRORS=$((ERRORS + 1))
else
    echo "✅ All required sections present"
fi

echo ""

# ==========================================
# 2. Validate metadata section
# ==========================================
echo "📅 Validating metadata section..."

METADATA_SECTION=$(sed -n '/<metadata>/,/<\/metadata>/p' "$SPECIALIST_FILE")

if [ -z "$METADATA_SECTION" ]; then
    echo "❌ ERROR: No metadata section found"
    ERRORS=$((ERRORS + 1))
else
    MISSING_METADATA=""

    # Check for curation date (YYYY-MM-DD format)
    echo "$METADATA_SECTION" | grep -q "Curated.*202[0-9]" || MISSING_METADATA="${MISSING_METADATA}curation-date "

    # Check for changelog/freshness protocol
    echo "$METADATA_SECTION" | grep -iq "changelog\|freshness.*protocol" || MISSING_METADATA="${MISSING_METADATA}changelog-protocol "

    # Check for user collaboration
    echo "$METADATA_SECTION" | grep -iq "discuss.*user\|collaborate.*user" || MISSING_METADATA="${MISSING_METADATA}user-collaboration "

    if [ -n "$MISSING_METADATA" ]; then
        echo "⚠️  WARNING: Metadata section missing fields: $MISSING_METADATA"
        echo "   Should include: curation date, Knowledge Freshness Protocol, user collaboration"
        WARNINGS=$((WARNINGS + 1))
    else
        echo "✅ Metadata section complete"
    fi
fi

echo ""

# ==========================================
# 3. Verify substantial content
# ==========================================
echo "📏 Checking content size..."

PROMPT_SIZE=$(wc -l "$SPECIALIST_FILE" | awk '{print $1}')
if [ $PROMPT_SIZE -lt 50 ]; then
    echo "⚠️  WARNING: Specialist prompt seems too short (${PROMPT_SIZE} lines)"
    echo "   Consider reviewing the synthesis quality"
    WARNINGS=$((WARNINGS + 1))
else
    echo "✅ Content size: ${PROMPT_SIZE} lines"
fi

echo ""

# ==========================================
# 4. Check for anti-patterns
# ==========================================
echo "🚫 Checking for anti-patterns..."

# Q&A anti-patterns (wrong approach - questions require prompting)
QUESTION_COUNT=$(grep -iE "when should you|how do you|what is the|why use|should i|can i|do i need" "$SPECIALIST_FILE" | wc -l)
if [ $QUESTION_COUNT -gt 5 ]; then
    echo "⚠️  WARNING: Q&A-style language detected (${QUESTION_COUNT} instances)"
    echo "   Specialist should create internalized knowledge, not answer questions"
    echo "   This suggests prompt is oriented toward Q&A interaction rather than 10X Engineer expertise"
    WARNINGS=$((WARNINGS + 1))
else
    echo "✅ Q&A patterns: ${QUESTION_COUNT} instances (acceptable)"
fi

# Navigation anti-patterns (wrong focus - file locations)
NAVIGATION_COUNT=$(grep -iE "located in|found in|check.*file|see.*\.ts:|\.tsx:|\.js:|\.jsx:|\.py:|\.go:" "$SPECIALIST_FILE" | wc -l)
if [ $NAVIGATION_COUNT -gt 10 ]; then
    echo "⚠️  WARNING: Navigation/location focus detected (${NAVIGATION_COUNT} instances)"
    echo "   Specialist should guide implementation decisions, not file navigation"
    echo "   This suggests prompt is a codebase navigation guide rather than 10x engineer expertise"
    WARNINGS=$((WARNINGS + 1))
else
    echo "✅ Navigation patterns: ${NAVIGATION_COUNT} instances (acceptable)"
fi

# Abstraction anti-patterns (wrong content - paraphrasing)
ABSTRACTION_COUNT=$(grep -iE "allows you to|enables you to|provides|offers|supports" "$SPECIALIST_FILE" | wc -l)
if [ $ABSTRACTION_COUNT -gt 10 ]; then
    echo "⚠️  WARNING: High abstraction language count (${ABSTRACTION_COUNT} instances)"
    echo "   Verify prompt preserves implementation reality, not just describes capabilities"
    WARNINGS=$((WARNINGS + 1))
else
    echo "✅ Abstraction patterns: ${ABSTRACTION_COUNT} instances (acceptable)"
fi

echo ""

# ==========================================
# 5. Check for expertise indicators
# ==========================================
echo "💡 Checking for expertise indicators..."

# Expertise indicators (correct approach - internalized knowledge)
EXPERTISE_COUNT=$(grep -iE "automatically|instinctively|naturally|by default|optimal pattern|internalized" "$SPECIALIST_FILE" | wc -l)
if [ $EXPERTISE_COUNT -lt 5 ]; then
    echo "⚠️  WARNING: Low 10X Engineer expertise language (${EXPERTISE_COUNT} instances)"
    echo "   Specialist should describe automatic/instinctive decision-making"
    echo "   This suggests prompt may not create 10x engineer expertise"
    WARNINGS=$((WARNINGS + 1))
else
    echo "✅ Expertise indicators: ${EXPERTISE_COUNT} instances"
fi

# Cutting-edge awareness
CUTTING_EDGE_COUNT=$(grep -iE "canary|beta|latest|cutting.edge|newest|preview|experimental" "$SPECIALIST_FILE" | wc -l)
if [ $CUTTING_EDGE_COUNT -lt 2 ]; then
    echo "⚠️  WARNING: Limited cutting-edge pattern awareness (${CUTTING_EDGE_COUNT} instances)"
    echo "   Specialist should include latest/canary/beta patterns"
    WARNINGS=$((WARNINGS + 1))
else
    echo "✅ Cutting-edge awareness: ${CUTTING_EDGE_COUNT} instances"
fi

echo ""

# ==========================================
# Summary
# ==========================================
echo "========================================="
echo "Validation Summary"
echo "========================================="
echo "Errors:   $ERRORS"
echo "Warnings: $WARNINGS"
echo ""

if [ $ERRORS -gt 0 ]; then
    echo "❌ VALIDATION FAILED"
    echo "   Fix errors before proceeding"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo "⚠️  VALIDATION PASSED WITH WARNINGS"
    echo "   Review warnings to improve specialist quality"
    exit 0
else
    echo "✅ VALIDATION PASSED"
    echo "   Specialist prompt meets all quality criteria"
    exit 0
fi
