# Docs-Web Curation Constraints

This document defines immutable rules that govern the web documentation curation system. These constraints ensure consistency, reliability, and maintainability.

## Constraint Categories

- **INVARIANT**: MUST NEVER be violated or changed. System breaks if violated.
- **RULE**: STRONGLY enforced. Only override with exceptional justification.
- **GUIDELINE**: Preferred approach. Can flex based on specific needs.

---

## INVARIANTS

### INVARIANT: Docs-Only Content Directory
**Rule**: `.knowledge/curated-docs-web/` contains ONLY documentation content. No website chrome, ads, tracking, or infrastructure.
**Why**: Agents need pure educational content without website navigation and marketing noise.
**Explicitly Excluded**: Navigation (headers, footers, sidebars), analytics/tracking scripts, marketing pages, website infrastructure
**Example**:
- ✅ `.knowledge/curated-docs-web/nextjs.org/docs/getting-started.html`
- ✅ `.knowledge/curated-docs-web/nextjs.org/docs/images/diagram.png`
- ✅ `.knowledge/curated-docs-web/nextjs.org/content.md` (from crawl4ai)
- ❌ `.knowledge/curated-docs-web/nextjs.org/header.html`
- ❌ `.knowledge/curated-docs-web/nextjs.org/analytics.js`
- ❌ `.knowledge/curated-docs-web/nextjs.org/pricing/index.html`

### INVARIANT: Meta-Docs Separation
**Rule**: `.knowledge-builder/curated-docs-web-builder/` contains ALL planning, meta, and tooling. Never mix with `.knowledge/curated-docs-web/`.
**Why**: Clean separation ensures agents working with docs never see curation logic.
**Example**:
- Curated docs: `.knowledge/curated-docs-web/nextjs.org/`
- Curation data: `.knowledge-builder/curated-docs-web-builder/projects/nextjs.org/`

### INVARIANT: Canonical Schema
**Rule**: `curated-tree.json` MUST follow this exact schema:
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
      "reasons": ["Included by pattern 'X'"|"Excluded by pattern 'Y'"|"Outside include patterns"]
    }
  ]
}
```
**Why**: Agents and tools depend on this structure. Changes break downstream processing.

### INVARIANT: Directory Naming Convention
**Rule**: Curated docs sites MUST be named `{domain}` exactly as appears in URL.
**Why**: Predictable paths enable automation and agent discovery.
**Example**:
- Website: `https://nextjs.org/docs`
- Domain: `nextjs.org`
- Directory: `.knowledge/curated-docs-web/nextjs.org`

### INVARIANT: Snapshot Immutability
**Rule**: Files in `.knowledge-builder/curated-docs-web-builder/snapshots/` are write-once, read-only audit trails.
**Why**: Snapshots provide forensic history for debugging bad curations. Modifications destroy evidence.

### INVARIANT: One Domain Per Specialist
**Rule**: Each curated docs website is the complete documentation domain for exactly ONE specialist agent.
**Why**: Deep specialization requires exclusive focus. Shared domains create confused expertise.
**Example**:
- `nextjs.org-web-docs-specialist` uses ONLY `.knowledge/curated-docs-web/nextjs.org/`
- Never split nextjs.org docs across multiple curations

### INVARIANT: No Website Chrome in Curated Output
**Rule**: Curated docs sites MUST contain zero navigation components: `*header*`, `*footer*`, `*nav*.html`, `*sidebar*.html`
**Why**: Website chrome is infrastructure noise, not documentation content.
**Validation**: `find .knowledge/curated-docs-web/domain -name "*header*" -o -name "*footer*" | wc -l` must return 0

### INVARIANT: Use Both Sources
**Rule**: Both httrack AND crawl4ai sources MUST be utilized unless one is demonstrably unusable.
**Why**: httrack provides structure and assets; crawl4ai provides pre-filtered content. Using both maximizes quality.
**Example**:
- ✅ Use httrack for images + crawl4ai for text content
- ✅ Use httrack for well-structured HTML pages
- ✅ Use crawl4ai when HTML is messy
- ❌ Only use httrack when crawl4ai exists and is clean
- ❌ Only use crawl4ai when httrack has useful assets

### INVARIANT: Upstream Scraping Quality
**Rule**: Curation MUST NOT proceed if upstream scraping is demonstrably incomplete.
**Why**: Garbage in = garbage out. Curating incomplete scrapes produces unusable specialist agents.
**Detection**: Use subagent validation (CURATOR-PROMPT.md Step 0.5) to compare live site vs scraped content.
**Abort Conditions**:
- Live site has 10+ documentation sections, scrape captured <3 sections
- Content density <20 lines/section (indicates TOC-only capture)
- Subagent validation returns FAIL with evidence of missing content
**Known Issue**: Single-page apps with hash routing (e.g., `#section=overview`) often fail to scrape completely. See full-docs-website-sync/README.md Known Limitations.

---

## RULES

### RULE: Content-First Inclusion Criteria
**Rule**: Include/exclude decisions MUST be based on documentation value, NOT size constraints.
**Why**: The goal is complete, helpful documentation from official websites. Size is an outcome of correct qualitative decisions.
**Decision Criteria**:
- ✅ INCLUDE if it helps explain library usage from official docs (tutorials, guides, API docs, examples)
- ❌ EXCLUDE if it's website chrome (navigation, headers, footers, ads, analytics, marketing)
- Each decision answers: "Does this help an agent teach library usage from official docs?"
**Size Awareness**: Monitor size as a signal of curation quality:
- Unusually large? Check for missed exclusions (website infrastructure, marketing pages)
- Unusually small? Verify comprehensive documentation coverage
- The RIGHT size = complete documentation without website chrome

### RULE: Reasons Format
**Rule**: Decision reasons MUST be one of these exact strings:
- `"Included by pattern '<glob>'"`
- `"Excluded by pattern '<glob>'"`
- `"Outside include patterns"`
**Why**: Standardized reasons enable automated validation and pattern tracing.
**Override**: Only during migration from old format.

### RULE: Source of Truth
**Rule**: Scraped website content in `full-docs-website/{domain}/` is the authoritative source. Both httrack and crawl4ai subdirectories exist.
**Why**: Reproducibility requires canonical source. Local variations create inconsistencies.

### RULE: Selection Manifest Alignment
**Rule**: `selection-manifest.json` copy operations MUST be a subset of curated-tree.json "keep" decisions.
**Why**: Misalignment causes files to exist that shouldn't, breaking curation promises.

### RULE: No Website Infrastructure
**Rule**: Exclude `dist/`, `build/`, `.next/`, `.docusaurus/`, `node_modules/`, compiled outputs
**Why**: Build artifacts are generated files, not source documentation.
**Override**: Only if it's the ONLY source available (no original markdown exists).

---

## GUIDELINES

### GUIDELINE: Prefer Documentation Directories
**Preference**: Keep `docs/`, `documentation/`, `website/content/`, `content/`, `guides/`
**Why**: These conventionally contain user-facing documentation.
**Flexibility**: Adapt to project structure (e.g., `pages/` for Next.js, `docs/` for Docusaurus).

### GUIDELINE: Include Markdown and MDX
**Preference**: Keep `.md`, `.mdx`, `.markdown` files within docs directories.
**Why**: Primary documentation content format.
**Flexibility**: Include other formats if they contain docs (`.rst`, `.asciidoc`).

### GUIDELINE: Include Documentation Assets
**Preference**: Keep images, diagrams, videos referenced by docs.
**Why**: Visual aids enhance documentation understanding.
**Flexibility**: Exclude if purely decorative or website branding.

### GUIDELINE: Exclude Website Components
**Preference**: Exclude `.jsx`, `.tsx`, `.vue`, `.svelte` files in docs directories.
**Why**: These are website rendering code, not documentation content.
**Flexibility**: Include if they ARE the documentation (e.g., React component showcase).

### GUIDELINE: Manifest Files in Docs
**Preference**: Keep `package.json`, config files at docs root if relevant.
**Why**: May contain important metadata or dependencies for understanding docs.
**Flexibility**: Omit if purely for docs website build.

### GUIDELINE: File Count as Completeness Signal
**Preference**: File count should reflect comprehensive documentation coverage.
**Why**: A docs specialist needs all tutorials, guides, API refs, examples.
**Quality Indicators**:
- Small count (<20 files): Verify all important docs captured
- Medium count (20-200 files): Common for comprehensive docs
- Large count (>200 files): Check for included website infrastructure
**Remember**: 500 doc files > 50 files missing key guides

### GUIDELINE: Incremental Curation
**Preference**: Start comprehensive, refine based on noise.
**Why**: Documentation should be complete by default.
**Flexibility**: Can exclude obvious noise upfront (tests, build configs).

---

## Documentation-Specific Patterns

### What to KEEP
- `docs/**/*.md`, `docs/**/*.mdx` (markdown content)
- `documentation/`, `content/`, `guides/`, `website/content/`
- Code examples within docs directories
- Images/diagrams (`docs/**/*.png`, `docs/**/*.svg`, etc.)
- API references and generated docs
- Tutorials, how-tos, getting-started guides

### What to EXCLUDE
- Website components: `docs/**/*.jsx`, `docs/**/*.tsx`, `docs/**/*.vue`
- Build configs: `docs/next.config.js`, `docs/docusaurus.config.js`
- Tests: `docs/**/*.test.*`, `docs/**/__tests__/`
- Build outputs: `docs/dist/`, `docs/.next/`, `docs/build/`
- Node modules: `docs/node_modules/`
- Website infrastructure: Navigation, layouts, themes (when separate from content)

---

## Modification Rules

### Who Can Modify This Document
- **Humans**: Can modify any section with justification
- **Agents**: PROHIBITED from modifying this document
- **META-BUILDER-PROMPT agent**: Can read but never write

### When to Add Constraints
- When a pattern causes repeated failures
- When automation requires predictability
- When agents make consistent mistakes with docs

### When to Promote Guidelines→Rules→Invariants
- Guideline→Rule: After 3+ repos benefit from enforcement
- Rule→Invariant: When violation would break system functionality
