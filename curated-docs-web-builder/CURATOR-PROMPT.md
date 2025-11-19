One-Shot Web Documentation Curation Prompt
===========================================

MISSION
-------
Create a comprehensive, clean documentation knowledge base for ONE specialist AI agent from a scraped website, removing all website chrome (navigation, headers, footers, ads, analytics) to extract pure educational content.

MANDATORY READS (Before Starting)
- `/Users/MN/GITHUB/.knowledge-builder/curated-docs-web-builder/CONTEXT.md` — Vision and goals
- `/Users/MN/GITHUB/.knowledge-builder/curated-docs-web-builder/CONSTRAINTS.md` — Invariants and rules you MUST follow

ACKNOWLEDGEMENT (Required)
- Before any action, print EXACTLY this single line:
  ACK: ReadConstraints→Snapshot→Analyze→Derive→Validate→Copy→Verify

CRITICAL RULES
--------------
1. NEVER fetch or access WEBSITE_URL directly - work ONLY from local scraped files
2. ALWAYS check/sync upstream FIRST (Step 0) - pristine sources are mandatory
3. `.knowledge/curated-docs-web/` contains ONLY documentation content (no website chrome, ads, tracking, or infrastructure)
4. Each curated docs site serves ONE specialist agent exclusively
5. Schema MUST be canonical (see section 5)
6. Reasons MUST be one of three exact formats (see section 5.1)
7. NO navigation components in output (validated post-copy)
8. Size is an OUTCOME of qualitative decisions, NOT a constraint
9. Use BOTH httrack AND crawl4ai sources - pick cleanest for each section or combine

Inputs
------
- WEBSITE_URL: Website URL (e.g., `https://nextjs.org/docs`)
  **DO NOT FETCH THIS URL** - it's only used to derive DOMAIN and check for scraped sources

**IMPORTANT: All paths in this prompt are ABSOLUTE paths starting with /**
Derived Paths (compute, don't ask)
-----------------------------------
- BUILDER_ROOT = `/Users/MN/GITHUB/.knowledge-builder/curated-docs-web-builder`
- KNOWLEDGE_ROOT = `/Users/MN/GITHUB/.knowledge`
- FULL_DOCS_DIR = `${KNOWLEDGE_ROOT}/full-docs-website`
- CURATED_DOCS_DIR = `${KNOWLEDGE_ROOT}/curated-docs-web`
- DOMAIN = parse from WEBSITE_URL (e.g., "nextjs.org" from "https://nextjs.org/docs")
- FULL_DOCS_PATH = `${FULL_DOCS_DIR}/${DOMAIN}`
- DEST = `${CURATED_DOCS_DIR}/${DOMAIN}`
- HTTRACK_PATH = `${FULL_DOCS_PATH}/httrack`
- CRAWL4AI_PATH = `${FULL_DOCS_PATH}/crawl4ai`
- PLAYWRIGHT_PATH = `${FULL_DOCS_PATH}/playwright`
- SNAPSHOT_DIR = `${BUILDER_ROOT}/snapshots/${DOMAIN}`
- PROJECT_DIR = `${BUILDER_ROOT}/projects/${DOMAIN}`

Workflow Steps
==============

0) CHECK UPSTREAM (Pristine Website Scrape) - DO THIS FIRST

   **CRITICAL: Work from local scraped files, NEVER fetch WEBSITE_URL directly**

   0.1) Sync scraped sources

   - Read `${FULL_DOCS_DIR}/MANIFEST.yaml`
   - Check if entry exists for `${DOMAIN}`:
     - **Missing**: Execute `/Users/MN/GITHUB/.knowledge-builder/full-docs-website-sync/sync.sh ${WEBSITE_URL}` and wait
     - **Stale (>30 days)**: Execute `/Users/MN/GITHUB/.knowledge-builder/full-docs-website-sync/sync.sh ${WEBSITE_URL}` and wait
     - **Fresh (<30 days)**: Continue with existing
   - Verify BOTH `${HTTRACK_PATH}` and `${CRAWL4AI_PATH}` exist after sync
   - STOP if either path is missing - cannot proceed without scraped sources

   0.2) VALIDATE SCRAPE QUALITY (MANDATORY GATE)

   **CRITICAL: Use subagent to validate scrape before proceeding with curation**

   Launch a general-purpose subagent with this task:

   ```
   Task: Validate that scraped content captures complete website documentation

   You are validating whether scraped content is complete enough for specialist agent training.

   **Inputs:**
   - Website URL: ${WEBSITE_URL}
   - Scraped httrack content: ${HTTRACK_PATH}
   - Scraped crawl4ai content: ${CRAWL4AI_PATH}

   **Your Job:**

   1. **Browse the live website** using browser tools
      - Navigate through main documentation sections
      - Note major topics, guides, API references, tutorials
      - Count how many major sections exist (# headings or navigation items)
      - Identify what a developer would come here to learn
      - IGNORE: navigation chrome, marketing, branding, CSS/JS infrastructure

   2. **Examine scraped content**
      - Read ${CRAWL4AI_PATH}/content.md
      - If JSON format: Extract `.markdown.raw_markdown` field first
      - Count major sections in scraped markdown (# headings)
      - Check if sections have actual content or just TOC links
      - Survey httrack HTML files (if relevant)

   3. **Answer decisively:**

      ✅ **PASS** if:
      - All major documentation sections are captured with actual content
      - Content exists (not just TOC links or navigation)
      - Code examples are preserved
      - Developer could learn the library from this scraped content
      - Missing sections are minor/redundant (changelogs, legal, etc.)

      ❌ **FAIL** if:
      - Major sections are missing (>50% of important docs absent)
      - Only navigation/TOC captured without actual content
      - Content is truncated or incomplete
      - Scrape has <3 sections but live site has 10+ sections
      - Content density <20 lines per section (TOC-only indicator)
      - Developer would be confused or unable to use library from this

   **Output Format (write to ${PROJECT_DIR}/validation-report.json):**

   {
     "result": "PASS" | "FAIL",
     "confidence": "high" | "medium" | "low",
     "website_sections_found": ["Quick Start", "API Reference", "Guides", ...],
     "website_section_count": 12,
     "scraped_sections_found": ["Quick Start - YES with content", "API Reference - NO, only TOC", ...],
     "scraped_section_count": 2,
     "verdict": "Clear 1-2 sentence explanation of pass/fail decision",
     "evidence": [
       "Website has 12 major documentation sections",
       "Scrape captured 2 sections with full content",
       "Remaining 10 sections are TOC links only",
       "Likely cause: SPA with hash routing not followed"
     ]
   }

   **Critical:**
   - Be decisive. PASS or FAIL, not "maybe"
   - If FAIL, explain what's missing clearly
   - Ignore website infrastructure (CSS, JS, nav components, marketing)
   - Focus on: Can a developer learn to USE this library from scraped content?
   ```

   **After subagent completes:**

   - Read `${PROJECT_DIR}/validation-report.json`
   - Check `result` field

   **If validation returns FAIL:**
   ```
   Print diagnostic message:

   ❌ SCRAPE VALIDATION FAILED - Aborting Curation

   Verdict: [validation.verdict]

   Evidence:
   [each line from validation.evidence]

   This website cannot be curated until scraping is improved.

   Likely causes:
   - Single-page app with hash routing (see full-docs-website-sync/README.md Known Limitations)
   - JavaScript-heavy site requiring special scraping configuration
   - Authentication or anti-bot protection

   Recommendations:
   - Check if site has alternative documentation sources (GitHub docs, static sites)
   - Look for sitemap.xml or static export
   - Wait for enhanced scraper with SPA hash route navigation
   ```

   Then EXIT - do not proceed to curation.

   **If validation returns PASS:**
   - Save validation report to `${PROJECT_DIR}/.validation/` for audit trail
   - Print success message
   - Continue to step 1

1) READ CONSTRAINTS
   - Read `/Users/MN/GITHUB/.knowledge-builder/curated-docs-web-builder/CONSTRAINTS.md` in full
   - Understand all INVARIANTS, RULES, and GUIDELINES

2) ANALYZE SCRAPED SOURCES

   2.1) Read validation report (MANDATORY)
   - Read `${FULL_DOCS_PATH}/validation-report.json`
   - This cross-validates all three scrapers (httrack, crawl4ai, playwright)
   - Check `overall.recommendation` field for which source to use
   - Check `scrapers.*.verdict` to see which scrapers completed successfully
   - Check `scrapers.httrack.has_tree_structure` (if httrack is COMPLETE)
   - Check `scrapers.playwright.directories` (if playwright is COMPLETE)

   2.2) MANDATORY: Deploy subagent to validate tree completeness

   **CRITICAL: Always validate tree structure against live website**

   Launch a general-purpose subagent with this task:

   ```
   Task: Validate which scraped tree structure is most complete

   You are validating tree structure completeness by comparing against the live website.

   **Inputs:**
   - Website URL: ${WEBSITE_URL}
   - Available tree structures:
     * playwright/: ${PLAYWRIGHT_PATH} (if exists)
     * httrack/: ${HTTRACK_PATH} (if has_tree_structure per validation report)
   - Validation report: ${FULL_DOCS_PATH}/validation-report.json

   **Your Job:**

   1. **Browse the live website** using browser tools
      - Navigate through ALL documentation sections
      - Build complete map of site structure:
        * Major sections (top-level navigation)
        * Subsections within each major section
        * Count total documentation pages
      - Note: Ignore marketing pages, blog, pricing, etc. - ONLY documentation

   2. **Examine available tree structures**

      For playwright/ (if exists):
      - List all directories: ls ${PLAYWRIGHT_PATH}/
      - Count markdown files: find ${PLAYWRIGHT_PATH} -name "*.md" | wc -l
      - Check section coverage: Does each live site section have a corresponding directory?

      For httrack/ (if has tree structure):
      - List subdirectories: find ${HTTRACK_PATH} -type d -mindepth 1 -maxdepth 2
      - Count HTML files: find ${HTTRACK_PATH} -name "*.html" | wc -l
      - Check section coverage: Does each live site section have corresponding HTML files?

   3. **Compare and decide**

      For each tree structure, answer:
      - Does it have ALL major sections from live site? (YES/NO)
      - Does it have ALL subsections within each major section? (YES/NO)
      - Are any sections missing? (List them)
      - Is the directory/file organization logical? (YES/NO)

   4. **Output Format (write to ${PROJECT_DIR}/tree-validation.json):**

   {
     "result": "COMPLETE_TREE_FOUND" | "INCOMPLETE_TREES" | "NO_TREES",
     "live_website": {
       "major_sections": ["Overview", "Quick Start", "Core Concepts", ...],
       "total_sections": 12,
       "total_pages": 43,
       "navigation_structure": "hash-routing" | "multi-page" | "mixed"
     },
     "trees_evaluated": {
       "playwright": {
         "exists": true,
         "directories": 17,
         "markdown_files": 43,
         "has_all_sections": true,
         "missing_sections": [],
         "verdict": "COMPLETE",
         "notes": "Perfect 1:1 match with live site"
       },
       "httrack": {
         "exists": true,
         "subdirectories": 1,
         "html_files": 3,
         "has_all_sections": false,
         "missing_sections": ["Quick Start", "Core Concepts", ...],
         "verdict": "INCOMPLETE",
         "notes": "SPA - only React shell captured"
       }
     },
     "recommendation": {
       "primary_source": "playwright",
       "reason": "Only complete tree structure with all 43 pages",
       "requires_conversion": false
     },
     "discrepancies": [
       "httrack missing 40/43 pages - SPA issue",
       "playwright has complete coverage - all sections present"
     ]
   }

   **Critical:**
   - Be thorough - check EVERY section on live site
   - If multiple trees claim completeness, find discrepancies
   - Recommend the tree that most accurately represents live site
   - If NO complete tree exists, report which sections are missing from ALL trees
   ```

   **After subagent completes:**

   - Read `${PROJECT_DIR}/tree-validation.json`
   - Check `result` field
   - Check `recommendation.primary_source`

   **If result is "NO_TREES" or "INCOMPLETE_TREES":**
   ```
   Print diagnostic message:

   ❌ TREE VALIDATION FAILED - No Complete Tree Structure

   Live site has: [total_pages] pages across [total_sections] sections

   Available trees:
   [for each tree: verdict, missing sections]

   Recommendation: Cannot curate without complete tree structure.

   Options:
   - Re-run scraping with different parameters
   - Use playwright scraper for complete coverage
   - Manual investigation required
   ```

   Then EXIT - do not proceed to curation.

   **If result is "COMPLETE_TREE_FOUND":**
   - Note `recommendation.primary_source` (playwright, httrack, or crawl4ai)
   - Note `requires_conversion` (true if httrack HTML needs → markdown)
   - Continue to step 2.3

   2.3) Examine all THREE sources based on tree-validation.json recommendation
   - Primary source: As determined by subagent tree validation
   - Inspect structure and prepare for curation

   **Source selection (from tree-validation.json):**
   - Use `recommendation.primary_source` field
   - Check `requires_conversion` flag

   2.4) Process source based on tree-validation recommendation

   **A) If recommendation.primary_source = "playwright":**

   - **Directory tree structure** (already clean):
     * Each major section is a directory (e.g., `quick-start/`, `core-concepts/`)
     * Each subsection is a .md file (e.g., `installation.md`, `getting-started.md`)
     * Each file has YAML frontmatter (source_url, section, subsection, scraped_at)

   - **Curation approach - MANUAL DEDUPLICATION**:

     **DO NOT use scripts or MD5 hashing - they don't work reliably**

     **Step 1: Copy and clean**
     * Copy entire directory tree to curated output
     * Strip YAML frontmatter (lines between `---` markers) from each file
     * Strip breadcrumb navigation (e.g., "Documentation› Quick Start› Installation")

     **Step 2: Manually walk through and deduplicate**
     * Go through EACH directory one by one
     * For each directory, read the first 5-10 lines of each file
     * Identify files with identical content (common in SPA hash-routed sites)
     * When you find duplicates:
       - Keep ONE file with the most representative name (e.g., keep parent section)
       - DELETE the duplicate files
       - Move kept file to root and delete empty directory

     **Example process**:
     ```bash
     cd curated-output/

     # Check pro-features directory
     head -5 ./pro-features/*.md
     # See they're all identical → delete duplicates
     rm ./pro-features/context-builder.md ./pro-features/mcp-integration.md
     mv ./pro-features/pro-mode.md ./pro-features.md
     rmdir ./pro-features

     # Repeat for EVERY directory
     ```

     **Step 3: Verify completeness**
     * Count final files: should be ~10-15 unique content files
     * Read first 20 lines of each to confirm they're different
     * Check against website navigation to ensure nothing missing

     **Critical**: This is grunt work. Don't try to automate it. Just read files and delete duplicates manually.

   **B) If recommendation.primary_source = "httrack" AND requires_conversion = true:**

   - **HTML tree structure** (needs conversion):
     * HTML files organized in directories matching site structure
     * Contains website chrome (nav, footer, etc.) - must remove

   - **Curation approach**:
     * Create parallel markdown tree structure in temp location
     * For each HTML file:
       ```bash
       # Extract main content and convert to markdown
       # Use pandoc or similar tool to convert HTML → markdown
       # Strip website chrome (nav, header, footer)
       pandoc "${html_file}" \
         --from html \
         --to markdown \
         --output "${md_file}" \
         --wrap=none
       ```
     * Preserve directory hierarchy
     * Clean up navigation artifacts from converted markdown

   - **HTML content extraction** (before pandoc):
     * Use CSS selectors to extract only `<main>`, `<article>`, or `.content` sections
     * Remove `<nav>`, `<header>`, `<footer>`, `<aside>` elements
     * This ensures clean conversion to markdown

   **C) If recommendation.primary_source = "crawl4ai":**
   **ONLY use if playwright is INCOMPLETE per validation report**
   **IMPORTANT: crawl4ai outputs JSON-wrapped content, NOT plain markdown**

   - Check if `${CRAWL4AI_PATH}/content.md` is JSON or plain text:
     ```bash
     head -1 ${CRAWL4AI_PATH}/content.md
     ```

   - **If JSON format detected** (starts with `{`):
     * Extract `raw_markdown` field from JSON
     * Save to temporary file for analysis
     * This is the actual documentation content

   - **Analyze markdown structure**:
     * Identify major sections (# headings)
     * Identify subsections (## and ### headings)
     * Determine if single-file or multi-file structure is appropriate
     * **Rule**: If >10K tokens or >5 major sections → split into multiple files

   - **Create file structure**:
     * Single topic site → Keep as one file
     * Multi-section documentation → Split by major sections (# headings)
     * Directory structure should mirror logical navigation
     * File names: lowercase-with-hyphens.md (e.g., `quick-start.md`)

   2.5) Read MANIFEST metadata
   - Extract `scraped_at`, `scraper`, `url` from MANIFEST.yaml for this domain
   - This provides timestamp and scraper info for curation metadata

3) GENERATE FILE TREE SNAPSHOT

   3.1) Survey available content
   ```bash
   # Examine httrack structure
   find ${HTTRACK_PATH} -type f -name "*.html" | head -20
   find ${HTTRACK_PATH} -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.svg" \) | head -10

   # Examine crawl4ai content
   ls -lh ${CRAWL4AI_PATH}/
   wc -l ${CRAWL4AI_PATH}/content.md
   ```

   3.2) Build comprehensive file tree
   - List all files from both sources
   - Categorize by type (HTML, markdown, images, other)
   - Calculate sizes for awareness
   - Save to `${SNAPSHOT_DIR}/file-tree.json`:

   ```json
   {
     "domain": "nextjs.org",
     "url": "https://nextjs.org/docs",
     "scraped_at": "2025-01-09T12:00:00Z",
     "sources": {
       "httrack": {
         "path": "httrack/",
         "total_files": 250,
         "html_files": 150,
         "image_files": 75,
         "other_files": 25
       },
       "crawl4ai": {
         "path": "crawl4ai/",
         "total_files": 2,
         "markdown_files": 1,
         "metadata_files": 1
       }
     },
     "entries": [
       {
         "path": "httrack/nextjs.org/docs/getting-started.html",
         "type": "file",
         "source": "httrack",
         "size": 12345,
         "category": "documentation"
       },
       {
         "path": "crawl4ai/content.md",
         "type": "file",
         "source": "crawl4ai",
         "size": 456789,
         "category": "documentation"
       }
     ]
   }
   ```

4) ANALYZE & DERIVE PATTERNS

   4.1) Compute sizes
   - Calculate directory sizes from tree
   - Identify largest files
   - Focus on documentation vs. infrastructure

   4.2) Identify documentation content vs. website chrome

   **Documentation content (KEEP):**
   - Pages under /docs/, /documentation/, /guides/, /tutorials/, /api/, /reference/
   - Markdown files from crawl4ai/ (already pre-filtered)
   - Code example blocks and snippets
   - Diagrams, screenshots, and educational images
   - API reference pages
   - Tutorial and guide pages

   **Website chrome (EXCLUDE):**
   - Navigation: header.html, nav.html, sidebar.html, footer.html, breadcrumb.html
   - Components: search-widget.js, theme-toggle.js, cookie-banner.js, announcement-bar.html
   - Analytics: google-analytics.js, gtag.js, tracking*.js, analytics*.js
   - Marketing: pricing.html, enterprise.html, about.html, careers.html, contact.html
   - Infrastructure: _next/, webpack/, node_modules/, .docusaurus/, dist/, build/
   - Blog: /blog/ (unless it's tutorial content - use judgment)
   - SEO/Marketing: landing pages, call-to-action sections

   4.3) Build explicit patterns

   **SOURCE SELECTION STRATEGY:**
   - **Primary content**: Use crawl4ai/content.md if it's comprehensive and clean
   - **Structured docs**: Use httrack/ HTML files if site has good structure
   - **Images/assets**: Always from httrack/ (crawl4ai doesn't capture these)
   - **Code examples**: Prefer source that preserves formatting best
   - **Hybrid**: Can combine - use crawl4ai content + httrack images

   **ALLOWLIST (what to keep from httrack):**
   - Documentation pages:
     * `httrack/${DOMAIN}/docs/**/*.html`
     * `httrack/${DOMAIN}/documentation/**/*.html`
     * `httrack/${DOMAIN}/guides/**/*.html`
     * `httrack/${DOMAIN}/tutorials/**/*.html`
     * `httrack/${DOMAIN}/api/**/*.html`
     * `httrack/${DOMAIN}/reference/**/*.html`

   - Documentation assets:
     * `httrack/${DOMAIN}/docs/**/*.{png,jpg,jpeg,svg,gif,webp}`
     * `httrack/${DOMAIN}/images/**/*.{png,jpg,jpeg,svg,gif,webp}`
     * `httrack/${DOMAIN}/assets/docs/**/*`

   - Code examples (if clearly in docs):
     * `httrack/${DOMAIN}/docs/**/*.{js,ts,jsx,tsx,py,go,rs}` (use judgment - exclude if website code)

   **ALLOWLIST (what to keep from crawl4ai):**
   - Pre-filtered content:
     * `crawl4ai/content.md` (if comprehensive)
     * `crawl4ai/docs/**/*.md` (if structured)
     * `crawl4ai/metadata.json`

   **DENYLIST (what to exclude from both sources):**

   - Website navigation and chrome:
     * `**/header.html`, `**/nav.html`, `**/footer.html`, `**/sidebar*.html`
     * `**/breadcrumb*.html`, `**/menu*.html`, `**/navigation*.html`
     * `**/toc.html`, `**/table-of-contents.html` (external ones, not in-page)

   - Website infrastructure:
     * `**/_next/**`, `**/.next/**`, `**/webpack/**`, `**/node_modules/**`
     * `**/.docusaurus/**`, `**/dist/**`, `**/build/**`, `**/.cache/**`
     * `**/.nuxt/**`, `**/.vuepress/**`, `**/.vitepress/**`

   - Analytics and tracking:
     * `**/analytics*.js`, `**/gtag*.js`, `**/tracking*.js`, `**/google-analytics*.js`
     * `**/cookie*.js`, `**/consent*.js`, `**/tag-manager*.js`

   - Website components and interactivity:
     * `**/search*.js`, `**/theme*.js`, `**/dark-mode*.js`, `**/light-mode*.js`
     * `**/announcement*.js`, `**/banner*.js`, `**/popup*.js`, `**/modal*.js`

   - Marketing and non-docs pages:
     * `**/pricing/**`, `**/enterprise/**`, `**/about/**`, `**/careers/**`
     * `**/contact/**`, `**/team/**`, `**/customers/**`, `**/case-studies/**`
     * `**/blog/**` (unless clearly tutorial content)
     * `**/news/**`, `**/press/**`, `**/media/**`

   - SEO and marketing assets:
     * `**/seo*.js`, `**/meta*.js`, `**/og-image*.png` (Open Graph images for social media)
     * `**/landing/**`, `**/marketing/**`, `**/campaigns/**`

   4.4) Apply QUALITATIVE inclusion criteria
   - Every file/directory decision based on: "Does this help an agent teach library usage from official docs?"
   - ✅ INCLUDE: Tutorials, guides, API docs, examples, concepts, diagrams
   - ❌ EXCLUDE: Navigation, headers, footers, ads, tracking, marketing, infrastructure
   - Size is an OUTCOME - comprehensive docs may be large, that's okay
   - Each micro-decision should be qualitative, not quantitative
   - When in doubt between httrack and crawl4ai: include both or pick cleanest

5) GENERATE ARTIFACTS

   5.1) curated-tree.json (CANONICAL SCHEMA ONLY)
   ```json
   {
     "domain": "nextjs.org",
     "url": "https://nextjs.org/docs",
     "scraped_at": "2025-01-09T12:00:00Z",
     "truncated": false,
     "sources_used": ["httrack", "crawl4ai"],
     "entries": [
       {
         "path": "path/to/item",
         "node": "dir|file",
         "decision": "keep_all|omit_all|mixed|keep|omit",
         "source": "httrack|crawl4ai",
         "reasons": ["<see below>"]
       }
     ]
   }
   ```

   **REASONS MUST BE EXACTLY ONE OF:**
   - `"Included by pattern '<actual_glob>'"`
   - `"Excluded by pattern '<actual_glob>'"`
   - `"Outside include patterns"`

   **ENTRIES RULES:**
   - Directory paths MUST end with `/`
   - File paths MUST NOT end with `/`
   - Sort by `path` alphabetically
   - For `mixed` directories: MUST include child entries
   - Include `source` field to track httrack vs crawl4ai

   5.2) selection-manifest.json
   This replaces sparse-checkout (which is git-specific). It specifies which files to copy from scraped sources.

   ```json
   {
     "domain": "nextjs.org",
     "url": "https://nextjs.org/docs",
     "scraped_at": "2025-01-09T12:00:00Z",
     "curation_date": "2025-01-09",
     "sources_used": ["httrack", "crawl4ai"],
     "copy_operations": [
       {
         "source_path": "httrack/nextjs.org/docs/getting-started.html",
         "dest_path": "docs/getting-started.html",
         "reason": "Included by pattern 'httrack/*/docs/**/*.html'",
         "source": "httrack"
       },
       {
         "source_path": "httrack/nextjs.org/docs/images/diagram.png",
         "dest_path": "docs/images/diagram.png",
         "reason": "Included by pattern 'httrack/*/docs/**/*.png'",
         "source": "httrack"
       },
       {
         "source_path": "crawl4ai/content.md",
         "dest_path": "content.md",
         "reason": "Included by pattern 'crawl4ai/content.md'",
         "source": "crawl4ai"
       }
     ],
     "statistics": {
       "total_files": 175,
       "from_httrack": 150,
       "from_crawl4ai": 25,
       "html_files": 120,
       "markdown_files": 25,
       "images": 45,
       "code_examples": 10
     }
   }
   ```

   5.3) curation.yaml
   ```yaml
   domain: nextjs.org
   url: https://nextjs.org/docs
   scraped_at: 2025-01-09T12:00:00Z
   curation_date: 2025-01-09
   sources: [httrack, crawl4ai]

   keep:
     # httrack - Documentation pages
     - httrack/*/docs/**/*.html
     - httrack/*/documentation/**/*.html
     - httrack/*/guides/**/*.html
     - httrack/*/api/**/*.html

     # httrack - Documentation assets
     - httrack/*/docs/**/*.{png,jpg,svg}
     - httrack/*/images/**/*.{png,jpg,svg}

     # crawl4ai - Pre-filtered content
     - crawl4ai/content.md
     - crawl4ai/metadata.json

   exclude:
     # Website navigation and chrome
     - "**/header.html"
     - "**/footer.html"
     - "**/nav*.html"
     - "**/sidebar*.html"
     - "**/breadcrumb*.html"

     # Website infrastructure
     - "**/_next/**"
     - "**/.next/**"
     - "**/node_modules/**"
     - "**/webpack/**"
     - "**/.docusaurus/**"
     - "**/dist/**"
     - "**/build/**"

     # Analytics and tracking
     - "**/analytics*.js"
     - "**/gtag*.js"
     - "**/tracking*.js"
     - "**/cookie*.js"

     # Website components
     - "**/search*.js"
     - "**/theme*.js"
     - "**/dark-mode*.js"

     # Marketing and non-docs
     - "**/pricing/**"
     - "**/enterprise/**"
     - "**/about/**"
     - "**/blog/**"
     - "**/careers/**"
   ```

6) VALIDATION GATES (ABORT IF ANY FAIL)

   6.1) Schema validation
   - curated-tree.json MUST match canonical schema
   - Every reason MUST match one of three allowed formats
   - Paths must follow slash rules (dirs end with `/`)
   - source field must be "httrack" or "crawl4ai"

   6.2) Consistency validation
   - selection-manifest.json copy_operations MUST be subset of keep decisions
   - For each `mixed` dir: child entries MUST exist
   - All source_path entries must exist in FULL_DOCS_PATH

   6.3) Pattern validation
   - Every keep/omit decision MUST cite a pattern
   - Verify documentation content is being kept
   - Verify website chrome is being excluded

   **IF ANY VALIDATION FAILS:**
   - Print error details
   - Regenerate artifacts
   - Re-validate before proceeding

7) COPY SELECTED FILES TO DESTINATION

   7.1) Create destination structure
   ```bash
   mkdir -p ${DEST}
   ```

   7.2) Process and copy files according to selection-manifest.json

   **For crawl4ai content.md files:**
   - **If source is JSON**: Extract raw_markdown field first
   - **If content is large** (decided in step 2.2): Split into multiple files
     * Parse markdown to identify section boundaries (# headings)
     * Create separate .md files for each major section
     * Use descriptive filenames based on section titles
     * Preserve heading hierarchy within each file
   - **If content is manageable**: Copy as single documentation.md file

   **For httrack HTML files:**
   - Copy as-is if they're clean documentation pages
   - Skip if they're React SPA shells or website infrastructure

   **For images and assets:**
   - Copy preserving directory structure
   - Place in `images/` subdirectory in destination

   Example copy operation with JSON extraction and splitting:
   ```bash
   # Extract raw_markdown from JSON if needed
   if file starts with '{'; then
     jq -r '.raw_markdown' source.md > temp_markdown.md

     # Split by major sections if large
     if [ sections > 5 ] || [ size > 10K ]; then
       # Split logic: parse # headings, create separate files
       # overview.md, quick-start.md, core-concepts.md, etc.
     else
       cp temp_markdown.md ${DEST}/documentation.md
     fi
   fi
   ```

   7.3) Create curation metadata
   Copy `curation.yaml` and `curated-tree.json` to `${DEST}/.curation/`:
   ```bash
   mkdir -p ${DEST}/.curation
   cp ${PROJECT_DIR}/curation.yaml ${DEST}/.curation/
   cp ${PROJECT_DIR}/curated-tree.json ${DEST}/.curation/
   cp ${PROJECT_DIR}/selection-manifest.json ${DEST}/.curation/
   ```

   7.4) Create provenance file
   ```bash
   cat > ${DEST}/.curation/provenance.yaml <<EOF
   domain: ${DOMAIN}
   url: ${WEBSITE_URL}
   scraped_at: <from_MANIFEST>
   curated_at: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
   sources_used: [httrack, crawl4ai]
   httrack_path: ${HTTRACK_PATH}
   crawl4ai_path: ${CRAWL4AI_PATH}
   total_files_copied: <count>
   EOF
   ```

8) POST-COPY VERIFICATION

   8.1) Chrome removal check (MUST PASS)
   ```bash
   find ${DEST} -type f \( -name "*header*" -o -name "*footer*" -o -name "*nav*.html" -o -name "*sidebar*.html" \) | wc -l
   ```
   MUST return 0. If not, navigation components were included.

   8.2) Documentation content check (MUST PASS)
   ```bash
   find ${DEST} -type f \( -name "*.html" -o -name "*.md" -o -name "*.mdx" \) -not -path "*/.curation/*" | wc -l
   ```
   MUST return >0. If not, no documentation was extracted.

   8.2.1) Content format check (MUST PASS)
   ```bash
   # Check if any .md files are actually JSON
   find ${DEST} -name "*.md" -not -path "*/.curation/*" -exec head -1 {} \; | grep -c "^{"
   ```
   MUST return 0. If not, JSON wasn't extracted properly - files are unusable.

   8.2.2) Content size check (SHOULD PASS)
   ```bash
   # Find any markdown files >50KB (may be too large for agent context)
   find ${DEST} -name "*.md" -not -path "*/.curation/*" -exec wc -c {} \; | awk '$1 > 51200 {print}'
   ```
   SHOULD return empty. If large files found, consider if they should have been split.

   8.3) Infrastructure check (MUST PASS)
   ```bash
   find ${DEST} -type d \( -name "_next" -o -name "node_modules" -o -name "webpack" -o -name ".docusaurus" \) | wc -l
   ```
   MUST return 0. If not, website infrastructure was included.

   8.4) Analytics/tracking check (MUST PASS)
   ```bash
   find ${DEST} -type f -name "*analytics*.js" -o -name "*gtag*.js" -o -name "*tracking*.js" | wc -l
   ```
   MUST return 0. If not, tracking code was included.

   Additional check:
   ```bash
   grep -r "google-analytics\|gtag\|analytics\.js" ${DEST} --include="*.html" --include="*.js" | wc -l
   ```
   SHOULD be very low (or 0). Some inline references may remain, but scripts should be gone.

   8.5) Marketing pages check (SHOULD PASS)
   ```bash
   find ${DEST} -type d \( -name "pricing" -o -name "enterprise" -o -name "about" -o -name "careers" \) | wc -l
   ```
   SHOULD return 0. Marketing pages should be excluded.

   8.6) Size awareness (NOT a constraint)
   ```bash
   du -sh ${DEST}
   ```
   Report the size. Large size is FINE if it's comprehensive documentation.
   Check for missed exclusions if unusually large (node_modules, build outputs).

   8.7) Content type distribution
   ```bash
   echo "HTML files: $(find ${DEST} -name "*.html" | wc -l)"
   echo "Markdown files: $(find ${DEST} -name "*.md" -o -name "*.mdx" | wc -l)"
   echo "Images: $(find ${DEST} -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.svg" -o -name "*.gif" \) | wc -l)"
   echo "Code examples: $(find ${DEST} -type f \( -name "*.js" -o -name "*.ts" -o -name "*.py" \) | wc -l)"
   ```
   Report distribution. Verify balanced mix appropriate to the documentation.

   8.8) Source distribution
   ```bash
   echo "Files from httrack: $(grep -c '"source": "httrack"' ${DEST}/.curation/selection-manifest.json)"
   echo "Files from crawl4ai: $(grep -c '"source": "crawl4ai"' ${DEST}/.curation/selection-manifest.json)"
   ```
   Report which source was used more. Both sources should contribute if both had useful content.

   8.9) Top directories report
   ```bash
   du -h ${DEST} | sort -rh | head -20
   ```
   Print top 20 directories by size. Verify they contain documentation, not excluded categories.

9) SPECIALIST READINESS CHECK
   Ask: "Does this give a web docs specialist agent everything needed to teach library usage from official docs?"
   - Can the specialist explain how to use the library?
   - Are tutorials, guides, and API docs complete?
   - Are code examples preserved?
   - Is website chrome (nav, headers, footers, ads) completely removed?
   - Are images and diagrams preserved?
   - Is tracking/analytics code removed?
   - **Are files in USABLE format?** (Not JSON, not monolithic blobs)
   - **Are files APPROPRIATELY SIZED?** (<50KB each for agent readability)
   - **Is structure LOGICAL?** (Split by topic if multi-section site)

   If NO to any: adjust patterns and regenerate.

   **CRITICAL FAILURE CONDITIONS:**
   - ❌ Markdown files that are actually JSON → Agent cannot read
   - ❌ Single file >100KB → Exceeds agent context limits
   - ❌ No logical file structure → Agent cannot navigate topics

ERROR HANDLING
--------------
- If MANIFEST shows no scrape: Execute sync.sh first
- If validation fails: MUST fix and re-validate, don't proceed
- If chrome found post-copy: MUST fix patterns and re-copy
- If no documentation found post-copy: MUST fix patterns
- If httrack or crawl4ai path missing: Check MANIFEST, re-sync if needed

SUCCESS CRITERIA
----------------
✅ Zero navigation components (headers, footers, sidebars)
✅ Zero analytics/tracking scripts
✅ Zero marketing pages (pricing, enterprise)
✅ At least some documentation pages exist (HTML or markdown)
✅ Canonical schema with proper reasons
✅ selection-manifest.json has all copy operations
✅ Specialist agent has comprehensive usage documentation
✅ Every included file serves the goal: "teach library usage from official docs"
✅ Website infrastructure excluded (node_modules, webpack, build tools)
✅ Both httrack AND crawl4ai sources utilized (or justified why only one)

OUTPUT LOCATIONS
----------------
- **Curated docs**: `${DEST}/` (copied files from httrack and/or crawl4ai)
- **Curation metadata**: `${DEST}/.curation/` (provenance, tree, manifest)
- **Planning/meta**: `${PROJECT_DIR}/` (JSON + YAML)
- **Snapshot**: `${SNAPSHOT_DIR}/file-tree.json` (shared)

FORBIDDEN ACTIONS
-----------------
- NO navigation components in `.knowledge/curated-docs-web/`
- NO analytics/tracking code in output
- NO marketing pages in output
- NO custom reason strings
- NO asking user for paths/URLs
- NO proceeding past failed validation
- NO using only one source if both have valuable content
