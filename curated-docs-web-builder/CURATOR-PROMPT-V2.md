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
