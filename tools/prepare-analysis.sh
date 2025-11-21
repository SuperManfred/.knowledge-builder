#!/usr/bin/env bash
set -euo pipefail

# Prepare repository snapshot and chunking for pattern analysis
# Steps 3 + 4.0-4.2: Generate tree snapshot, pre-filter, calculate distribution, split chunks
# Usage: prepare-analysis.sh <full-repo-path> <snapshot-dir>

if [ $# -lt 2 ]; then
  echo "Usage: $0 <full-repo-path> <snapshot-dir>" >&2
  echo "  full-repo-path: Path to pristine full repository clone" >&2
  echo "  snapshot-dir: Directory to store analysis artifacts" >&2
  exit 1
fi

FULL_REPO_PATH="$1"
SNAPSHOT_DIR="$2"

# Validate inputs
if [ ! -d "$FULL_REPO_PATH" ]; then
  echo "ERROR: Repository path does not exist: $FULL_REPO_PATH" >&2
  exit 1
fi

if [ ! -d "$FULL_REPO_PATH/.git" ]; then
  echo "ERROR: Not a git repository: $FULL_REPO_PATH" >&2
  exit 1
fi

# Create snapshot directory
mkdir -p "$SNAPSHOT_DIR"
mkdir -p "$SNAPSHOT_DIR/pattern-analysis"

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "SNAPSHOT & CHUNKING PREPARATION"
echo "Repository: $FULL_REPO_PATH"
echo "Snapshot: $SNAPSHOT_DIR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ============================================================================
# STEP 3: Generate git tree snapshot
# ============================================================================
echo ""
echo "Step 3: Generating git tree snapshot..."
echo "---------------------------------------"

cd "$FULL_REPO_PATH"

# Generate tree snapshot
if ! git ls-tree -r -t --full-tree HEAD > "$SNAPSHOT_DIR/github-api-tree.txt" 2>&1; then
  echo "ERROR: Failed to generate git tree snapshot" >&2
  exit 1
fi

TOTAL_ENTRIES=$(wc -l < "$SNAPSHOT_DIR/github-api-tree.txt" | tr -d ' ')
echo -e "${GREEN}✅ Generated tree snapshot: $TOTAL_ENTRIES entries${NC}"

if [ "$TOTAL_ENTRIES" -eq 0 ]; then
  echo "ERROR: Empty git tree - repository may be empty or HEAD not set" >&2
  exit 1
fi

# ============================================================================
# STEP 4.0: Pre-filter git tree
# ============================================================================
echo ""
echo "Step 4.0: Pre-filtering tree (remove obvious non-documentation/code)..."
echo "------------------------------------------------------------------------"

# Determine filter pattern based on what's in the tree
# If there are docs-heavy patterns, use docs filters; otherwise use code filters
DOCS_COUNT=$(grep -cE '(docs?/|documentation/|content/|\.mdx?$)' "$SNAPSHOT_DIR/github-api-tree.txt" || echo "0")
CODE_COUNT=$(grep -cE '\.(js|ts|py|go|rs|java|c|cpp|h)$' "$SNAPSHOT_DIR/github-api-tree.txt" || echo "0")

if [ "$DOCS_COUNT" -gt "$CODE_COUNT" ]; then
  REPO_TYPE="docs"
  # Docs pre-filter: Remove build artifacts, node_modules, but keep docs
  grep -vE '(node_modules/|\.git/|dist/|build/|\.next/|\.docusaurus/|\.cache/|vendor/|__pycache__/|\.min\.|\.map$|\.woff|\.ttf|\.eot|package-lock\.json|yarn\.lock|pnpm-lock\.yaml)' \
    "$SNAPSHOT_DIR/github-api-tree.txt" > "$SNAPSHOT_DIR/filtered-tree.txt" || {
    # If grep fails (no matches), create empty file
    touch "$SNAPSHOT_DIR/filtered-tree.txt"
  }
else
  REPO_TYPE="code"
  # Code pre-filter: Remove build artifacts, docs, media files
  grep -vE '(node_modules/|\.git/|dist/|build/|\.next/|\.cache/|vendor/|__pycache__/|\.min\.|\.map$|\.png$|\.jpg$|\.svg$|\.ico$|\.woff|\.ttf|docs?/|documentation/|website/)' \
    "$SNAPSHOT_DIR/github-api-tree.txt" > "$SNAPSHOT_DIR/filtered-tree.txt" || {
    touch "$SNAPSHOT_DIR/filtered-tree.txt"
  }
fi

FILTERED_ENTRIES=$(wc -l < "$SNAPSHOT_DIR/filtered-tree.txt" | tr -d ' ')

if [ "$FILTERED_ENTRIES" -eq 0 ]; then
  echo "ERROR: Filtered tree is empty - pre-filter may be too aggressive" >&2
  echo "Check $SNAPSHOT_DIR/github-api-tree.txt for content" >&2
  exit 1
fi

REDUCTION_PCT=$(( (TOTAL_ENTRIES - FILTERED_ENTRIES) * 100 / TOTAL_ENTRIES ))

echo -e "${GREEN}✅ Pre-filter complete:${NC}"
echo -e "   Repository type: ${BLUE}$REPO_TYPE${NC}"
echo -e "   $TOTAL_ENTRIES → $FILTERED_ENTRIES entries (${REDUCTION_PCT}% reduction)"

# ============================================================================
# STEP 4.1: Calculate agent distribution
# ============================================================================
echo ""
echo "Step 4.1: Calculating agent distribution..."
echo "-------------------------------------------"

# Target ~100k tokens per agent (50% of 200k limit for safety)
# Estimate: ~20 tokens per tree entry (path + metadata)
# Target: 5000 entries per agent = ~100k tokens
ENTRIES_PER_AGENT=5000

NUM_AGENTS=$(( (FILTERED_ENTRIES + ENTRIES_PER_AGENT - 1) / ENTRIES_PER_AGENT ))

# Cap at 10 agents max (for repos >50k entries)
if [ $NUM_AGENTS -gt 10 ]; then
  echo -e "${YELLOW}⚠️  Capping agents at 10 (large repository)${NC}"
  NUM_AGENTS=10
  ENTRIES_PER_AGENT=$(( (FILTERED_ENTRIES + NUM_AGENTS - 1) / NUM_AGENTS ))
fi

# Minimum 1 agent
if [ $NUM_AGENTS -lt 1 ]; then
  NUM_AGENTS=1
fi

echo -e "${GREEN}✅ Distribution calculated:${NC}"
echo -e "   Agents: ${BLUE}$NUM_AGENTS${NC}"
echo -e "   Entries per agent: ${BLUE}$ENTRIES_PER_AGENT${NC}"
echo -e "   Estimated tokens per agent: ~$(( ENTRIES_PER_AGENT * 20 / 1000 ))k"

# Store metadata
cat > "$SNAPSHOT_DIR/analysis-metadata.txt" << EOF
total_entries=$TOTAL_ENTRIES
filtered_entries=$FILTERED_ENTRIES
reduction_pct=$REDUCTION_PCT
repo_type=$REPO_TYPE
num_agents=$NUM_AGENTS
entries_per_agent=$ENTRIES_PER_AGENT
generated_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
EOF

# ============================================================================
# STEP 4.2: Split tree into chunks
# ============================================================================
echo ""
echo "Step 4.2: Splitting tree into chunks for parallel analysis..."
echo "-------------------------------------------------------------"

# Clean up any existing chunks
rm -f "$SNAPSHOT_DIR"/tree-chunk-*

# Split filtered tree into chunks
# Use split with line count
if ! split -l "$ENTRIES_PER_AGENT" "$SNAPSHOT_DIR/filtered-tree.txt" "$SNAPSHOT_DIR/tree-chunk-"; then
  echo "ERROR: Failed to split tree into chunks" >&2
  exit 1
fi

# Count actual chunks created
CHUNKS_CREATED=$(find "$SNAPSHOT_DIR" -name "tree-chunk-*" -type f | wc -l | tr -d ' ')

echo -e "${GREEN}✅ Created $CHUNKS_CREATED chunks${NC}"

# List chunks with sizes
echo ""
echo "Chunks created:"
for chunk in "$SNAPSHOT_DIR"/tree-chunk-*; do
  if [ -f "$chunk" ]; then
    CHUNK_LINES=$(wc -l < "$chunk" | tr -d ' ')
    CHUNK_NAME=$(basename "$chunk")
    echo "  - $CHUNK_NAME: $CHUNK_LINES entries"
  fi
done

# ============================================================================
# Summary
# ============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ SNAPSHOT & CHUNKING COMPLETE${NC}"
echo ""
echo "Summary:"
echo "  - Total entries: $TOTAL_ENTRIES"
echo "  - Filtered entries: $FILTERED_ENTRIES (${REDUCTION_PCT}% reduction)"
echo "  - Repository type: $REPO_TYPE"
echo "  - Agents to launch: $NUM_AGENTS"
echo "  - Chunks created: $CHUNKS_CREATED"
echo ""
echo "Next steps:"
echo "  1. Launch $NUM_AGENTS pattern analysis agents in parallel"
echo "  2. Each agent analyzes one chunk: $SNAPSHOT_DIR/tree-chunk-*"
echo "  3. Agents save results to: $SNAPSHOT_DIR/pattern-analysis/"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

exit 0
