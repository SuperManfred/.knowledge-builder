# Web Documentation Curator

**Mission**: Extract clean, properly structured documentation from scraped website. Remove noise, organize by topic, make it readable like the actual website documentation.

**Input**: WEBSITE_URL (e.g., `https://repoprompt.com/docs`)

---

## Critical Rules

1. **Work from local scraped files ONLY** - never fetch WEBSITE_URL directly
2. **Remove all website chrome** - navigation, headers, footers, ads, analytics
3. **Preserve logical structure** - use sitemap.json to mirror website organization
4. **Remove content that doesn't match filenames** - if "installation.md" contains the entire quick-start section, fix it
5. **Remove duplicates** - if multiple files have identical content, keep one
6. **Verify completeness** - check output against live website navigation

---

## Paths (computed from WEBSITE_URL)

```bash
DOMAIN=$(echo "$WEBSITE_URL" | sed -E 's|https?://([^/]+).*|\1|')
SOURCE_DIR="/Users/MN/GITHUB/.knowledge/full-docs-website/${DOMAIN}/playwright"
OUTPUT_DIR="/Users/MN/GITHUB/.knowledge/curated-docs-web/${DOMAIN}"
```

---

## Workflow

### Step 1: Check upstream scrape exists

```bash
# Check if scraped files exist
ls /Users/MN/GITHUB/.knowledge/full-docs-website/${DOMAIN}/playwright/

# If missing or stale (>30 days), run sync:
/Users/MN/GITHUB/.knowledge-builder/full-docs-website-sync/sync.sh ${WEBSITE_URL}
```

### Step 2: Copy scraped files to output

```bash
# Create output directory
mkdir -p ${OUTPUT_DIR}

# Copy entire playwright directory tree
cp -r ${SOURCE_DIR}/* ${OUTPUT_DIR}/
```

### Step 3: Strip frontmatter and breadcrumbs

For each `.md` file:
- Remove YAML frontmatter (lines between `---` markers at file start)
- Remove breadcrumb navigation (e.g., "Documentation› Quick Start› Installation")
- Keep only actual documentation content

```bash
cd ${OUTPUT_DIR}

# Example: strip frontmatter from all files
for file in $(find . -name "*.md" -not -path "*/.curation/*"); do
  # Remove lines 1-7 (frontmatter), remove breadcrumb line
  sed '1,/^---$/d; /^---$/d; /Documentation›/d' "$file" > "$file.tmp"
  mv "$file.tmp" "$file"
done
```

### Step 4: Read sitemap for structure

**The sitemap defines the canonical structure - use it:**

```bash
cd ${OUTPUT_DIR}
cat ../sitemap.json | jq -r '.sections[] | "\(.section)/\(.subsection)"' | sort -u
```

This shows the intended directory structure from the website.

### Step 5: **MANUALLY** curate content

**DO NOT use scripts** - read the actual content and make intelligent decisions.

For EACH directory:

```bash
cd ${OUTPUT_DIR}

# Example: Check quick-start directory
head -20 ./quick-start/installation.md
head -20 ./quick-start/getting-started.md
```

**Ask yourself**:
1. Does `installation.md` contain ONLY installation content?
2. Or does it contain the entire quick-start section (installation + getting-started + first-workspace + file-tree)?

**If file contains only what it should**:
- KEEP IT - it's properly scoped content

**If file contains entire parent section** (common in SPAs):
- This is noise - the file name lies about what's inside
- Options:
  a) If all files in directory are identical: Delete duplicates, keep one with appropriate name
  b) If you can split the content: Split into proper subsections
  c) If splitting is impossible: Keep one file at parent level

**Example walkthrough**:

```bash
# Check pro-features directory
head -30 ./pro-features/pro-mode.md
head -30 ./pro-features/context-builder.md

# If BOTH contain ALL pro features content:
# - They're duplicates with misleading names
# - Delete one: rm ./pro-features/context-builder.md ./pro-features/mcp-integration.md
# - Keep one: ./pro-features/pro-mode.md

# If each contains ONLY its subsection:
# - KEEP ALL - they're properly scoped
```

**The goal**: A specialist reading a file should get exactly what the filename promises, not the entire parent section.

### Step 6: Verify completeness

**Check against sitemap AND live website**:

1. Compare directory structure to sitemap.json
2. Browse to WEBSITE_URL and check navigation menu
3. Verify you have a file/directory for each major section
4. Read first 20 lines of sample files to confirm unique content

**Expected result**:
- Directory structure mirrors website (section/subsection.md)
- Zero duplication (files with same content removed)
- Zero website chrome (no nav, headers, footers)
- 100% documentation coverage (all sections from website)

**Example good structure**:
```
repoprompt.com/
├── overview/
│   ├── what-is-repo-prompt.md
│   └── cursor-comparison.md
├── quick-start/
│   ├── installation.md
│   ├── first-workspace.md
│   └── file-tree.md
├── pro-features/
│   └── pro-mode.md          # Others were duplicates, deleted
├── changelog/
│   └── changelog.md         # All versions were identical, kept one
└── ...
```

**NOT flat like this**:
```
repoprompt.com/
├── overview.md
├── quick-start.md
├── pro-features.md
└── ...
```

### Step 7: Create metadata

```bash
cat > ${OUTPUT_DIR}/.curation/provenance.yaml << EOF
domain: ${DOMAIN}
source_url: ${WEBSITE_URL}
curated_at: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
scraper: playwright
curator: manual-deduplication
files: $(find ${OUTPUT_DIR} -name "*.md" -not -path "*/.curation/*" | wc -l)
EOF
```

### Step 8: Generate SPECIALIST-PROMPT.md (Multi-Agent)

**8.1 - Create proposals directory:**

```bash
mkdir -p ${OUTPUT_DIR}/.curation/specialist-proposals
```

**8.2 - Launch 6 parallel agents to generate proposals:**

Invoke ALL 6 agents in a single message (parallel execution):

```
Task 1 (Sonnet - Usage Patterns):
  model: "sonnet"
  subagent_type: "general-purpose"
  description: "Generate specialist prompt focusing on usage patterns"
  prompt: """
  Read /Users/MN/GITHUB/.knowledge/curated-docs-web/SPECIALIST-META-PROMPT.md with KB_PATH=${OUTPUT_DIR}

  Focus specifically on: Common usage patterns, typical workflows, and frequent use cases.

  Write your complete SPECIALIST-PROMPT.md proposal to:
  ${OUTPUT_DIR}/.curation/specialist-proposals/proposal-1-sonnet-usage.md
  """

Task 2 (Sonnet - Troubleshooting):
  model: "sonnet"
  subagent_type: "general-purpose"
  description: "Generate specialist prompt focusing on troubleshooting"
  prompt: """
  Read /Users/MN/GITHUB/.knowledge/curated-docs-web/SPECIALIST-META-PROMPT.md with KB_PATH=${OUTPUT_DIR}

  Focus specifically on: Troubleshooting guidance, error handling, and edge cases.

  Write your complete SPECIALIST-PROMPT.md proposal to:
  ${OUTPUT_DIR}/.curation/specialist-proposals/proposal-2-sonnet-troubleshooting.md
  """

Task 3 (Sonnet - Integration):
  model: "sonnet"
  subagent_type: "general-purpose"
  description: "Generate specialist prompt focusing on integration"
  prompt: """
  Read /Users/MN/GITHUB/.knowledge/curated-docs-web/SPECIALIST-META-PROMPT.md with KB_PATH=${OUTPUT_DIR}

  Focus specifically on: Integration patterns, best practices, and ecosystem compatibility.

  Write your complete SPECIALIST-PROMPT.md proposal to:
  ${OUTPUT_DIR}/.curation/specialist-proposals/proposal-3-sonnet-integration.md
  """

Task 4 (Opus - Comprehensive Capabilities):
  model: "opus"
  subagent_type: "general-purpose"
  description: "Generate specialist prompt with comprehensive capability mapping"
  prompt: """
  Read /Users/MN/GITHUB/.knowledge/curated-docs-web/SPECIALIST-META-PROMPT.md with KB_PATH=${OUTPUT_DIR}

  Focus specifically on: Complete capability inventory, feature coverage, and functional boundaries.
  Use reasoning to ensure comprehensive coverage.

  Write your complete SPECIALIST-PROMPT.md proposal to:
  ${OUTPUT_DIR}/.curation/specialist-proposals/proposal-4-opus-capabilities.md
  """

Task 5 (Opus - Knowledge Boundaries):
  model: "opus"
  subagent_type: "general-purpose"
  description: "Generate specialist prompt with precise knowledge boundaries"
  prompt: """
  Read /Users/MN/GITHUB/.knowledge/curated-docs-web/SPECIALIST-META-PROMPT.md with KB_PATH=${OUTPUT_DIR}

  Focus specifically on: What the specialist knows vs doesn't know, version coverage, and limitation acknowledgment.
  Use reasoning to define clear boundaries.

  Write your complete SPECIALIST-PROMPT.md proposal to:
  ${OUTPUT_DIR}/.curation/specialist-proposals/proposal-5-opus-boundaries.md
  """

Task 6 (Opus - Usage Scenarios):
  model: "opus"
  subagent_type: "general-purpose"
  description: "Generate specialist prompt with usage scenario modeling"
  prompt: """
  Read /Users/MN/GITHUB/.knowledge/curated-docs-web/SPECIALIST-META-PROMPT.md with KB_PATH=${OUTPUT_DIR}

  Focus specifically on: Real-world usage scenarios, project contexts, and implementation guidance.
  Use reasoning to model comprehensive scenarios.

  Write your complete SPECIALIST-PROMPT.md proposal to:
  ${OUTPUT_DIR}/.curation/specialist-proposals/proposal-6-opus-scenarios.md
  """
```

**8.3 - Synthesize with evaluator (7th agent):**

After ALL 6 agents complete, invoke the synthesis agent:

```
Task 7 (Opus - Synthesis):
  model: "opus"
  subagent_type: "general-purpose"
  description: "Synthesize final specialist prompt from 6 proposals"
  prompt: """
  You have 6 specialist prompt proposals in:
  ${OUTPUT_DIR}/.curation/specialist-proposals/

  Read all 6 proposals:
  - proposal-1-sonnet-usage.md
  - proposal-2-sonnet-troubleshooting.md
  - proposal-3-sonnet-integration.md
  - proposal-4-opus-capabilities.md
  - proposal-5-opus-boundaries.md
  - proposal-6-opus-scenarios.md

  Your synthesis task:
  1. Identify the BEST elements from each proposal
  2. Combine complementary sections (don't duplicate)
  3. Choose the clearest wording when multiple versions exist
  4. Ensure comprehensive coverage without redundancy
  5. Preserve unique insights and specific examples

  Quality criteria:
  - Role definition must be crystal clear
  - Knowledge base contents must be accurately described
  - Capabilities must be comprehensive but realistic
  - Usage instructions must be actionable
  - Knowledge boundaries must be well-defined
  - Must include concrete examples from the actual docs

  Write the FINAL synthesized specialist prompt to:
  ${OUTPUT_DIR}/SPECIALIST-PROMPT.md

  After writing, report which elements you took from which proposals.
  """
```

**8.4 - Automatic cleanup:**

```bash
# Verify final SPECIALIST-PROMPT.md exists
if [ -f "${OUTPUT_DIR}/SPECIALIST-PROMPT.md" ]; then
    echo "✅ SPECIALIST-PROMPT.md generated successfully"

    # Archive proposals
    tar -czf ${OUTPUT_DIR}/.curation/specialist-proposals-archive.tar.gz \
        -C ${OUTPUT_DIR}/.curation specialist-proposals/

    # Clean up proposal files
    rm -rf ${OUTPUT_DIR}/.curation/specialist-proposals/
    echo "✅ Proposal files cleaned up (archived to specialist-proposals-archive.tar.gz)"
else
    echo "❌ ERROR: SPECIALIST-PROMPT.md not found! Keeping proposals for debugging."
    echo "Check ${OUTPUT_DIR}/.curation/specialist-proposals/ for the 6 proposals"
    exit 1
fi
```

**8.5 - Final validation:**

```bash
# Verify specialist prompt is substantial
PROMPT_SIZE=$(wc -l ${OUTPUT_DIR}/SPECIALIST-PROMPT.md | awk '{print $1}')
if [ $PROMPT_SIZE -lt 50 ]; then
    echo "⚠️ WARNING: SPECIALIST-PROMPT.md seems too short (${PROMPT_SIZE} lines)"
    echo "Consider reviewing the synthesis quality"
fi

echo "✅ Multi-agent specialist prompt generation complete!"
echo "📍 Final prompt: ${OUTPUT_DIR}/SPECIALIST-PROMPT.md"
```

Print completion:
```
✅ CURATION COMPLETE
✅ SPECIALIST-PROMPT.md GENERATED (6-agent ensemble + synthesis)

Resource ready: ${OUTPUT_DIR}/
```

---

## Quality Gates

**Before declaring success**:

1. ✅ **Directory structure preserved** - mirrors website navigation from sitemap
2. ✅ **All files have unique content** (duplicates removed, not flattened)
3. ✅ **No website chrome present** (no nav/header/footer)
4. ✅ **Covers all major sections** from live website
5. ✅ **Content is actionable documentation** (not TOCs or marketing)
6. ✅ **Logical organization** - files grouped by section (not dumped flat at root)

**If any check fails**: Go back and fix it. Don't declare success until all 6 pass.

---

## What Actually Works

- **Read the actual content** - don't trust filenames or file counts
- **Preserve directory structure** - follow sitemap organization from website
- **Verify content matches filename** - if "installation.md" has ALL of quick-start, fix it
- **Remove noise** - files with misleading names or duplicate content
- **Think like a human reader** - would this structure make sense to someone learning?

## What Doesn't Work

- ❌ Automated MD5 hashing (agents mess this up)
- ❌ **Flattening everything to root** (loses logical organization)
- ❌ **Trusting filenames without reading** (SPA sites lie)
- ❌ Trusting file counts (43 files can be 11 unique pieces)
- ❌ Scripts and automation (simple manual work is faster and correct)

---

## Success Criteria

Final output should preserve structure:
```
repoprompt.com/
├── overview/
│   └── what-is-repo-prompt.md
├── quick-start/
│   ├── installation.md
│   ├── first-workspace.md
│   └── file-tree.md
├── pro-features/
│   └── pro-mode.md
└── changelog/
    └── changelog.md
```

NOT flat like this:
```
repoprompt.com/
├── changelog.md
├── overview.md
├── quick-start.md      # Lost all subsections!
└── pro-features.md
```

Examples:

**Case 1: Files have unique content (KEEP ALL)**:
```
repoprompt.com/
├── quick-start/
│   ├── installation.md      # Unique: installation steps
│   ├── getting-started.md   # Unique: getting-started guide
│   ├── first-workspace.md   # Unique: workspace setup
│   └── file-tree.md         # Unique: file tree navigation
```
Result: Keep all 4 files - they have different content

**Case 2: Files are identical duplicates (DELETE DUPLICATES)**:
```
BEFORE:
├── pro-features/
│   ├── pro-mode.md          # Contains ALL pro features
│   ├── context-builder.md   # Same content (duplicate!)
│   └── mcp-integration.md   # Same content (duplicate!)

AFTER deduplication:
├── pro-features/
│   └── pro-mode.md          # Keep one, delete 2 duplicates
```
