# Docs-GH Curation Constraints

This document defines immutable rules that govern the repository documentation curation system. These constraints ensure consistency, reliability, and maintainability.

## Constraint Categories

- **INVARIANT**: MUST NEVER be violated or changed. System breaks if violated.
- **RULE**: STRONGLY enforced. Only override with exceptional justification.
- **GUIDELINE**: Preferred approach. Can flex based on specific needs.

---

## INVARIANTS

### INVARIANT: Docs-Only Content Directory
**Rule**: `.knowledge/curated-docs-repo/` contains ONLY documentation content. No website code, build artifacts, or tests.
**Why**: Agents need clean docs without website infrastructure noise.
**Explicitly Excluded**: React/Vue/Svelte components for docs sites, build configs, tests for docs
**Example**:
- ✅ `.knowledge/curated-docs-repo/vercel-next.js/docs/api-reference.md`
- ✅ `.knowledge/curated-docs-repo/vercel-next.js/docs/guides/getting-started.mdx`
- ❌ `.knowledge/curated-docs-repo/vercel-next.js/website/components/Navigation.tsx`
- ❌ `.knowledge/curated-docs-repo/vercel-next.js/docs/__tests__/links.test.js`

### INVARIANT: Meta-Docs Separation
**Rule**: `.knowledge-builder/curated-docs-repo-builder/` contains ALL planning, meta, and tooling. Never mix with `.knowledge/curated-docs-repo/`.
**Why**: Clean separation ensures agents working with docs never see curation logic.
**Example**:
- Curated docs: `.knowledge/curated-docs-repo/vercel-next.js/`
- Curation data: `.knowledge-builder/curated-docs-repo-builder/projects/vercel-next.js/`

### INVARIANT: Canonical Schema
**Rule**: `curated-tree.json` MUST follow this exact schema:
```json
{
  "repo": "owner/name",
  "branch": "main",
  "commit": "sha",
  "truncated": false,
  "entries": [
    {
      "path": "path/to/item",
      "node": "dir|file",
      "decision": "keep_all|omit_all|mixed|keep|omit",
      "reasons": ["Included by pattern 'X'"|"Excluded by pattern 'Y'"|"Outside include patterns"]
    }
  ]
}
```
**Why**: Agents and tools depend on this structure. Changes break downstream processing.

### INVARIANT: Directory Naming Convention
**Rule**: Curated docs repos MUST be named `{owner}-{repo}` (lowercase, hyphenated).
**Why**: Predictable paths enable automation and agent discovery.
**Example**:
- GitHub: `https://github.com/vercel/next.js`
- Directory: `.knowledge/curated-docs-repo/vercel-next.js`

### INVARIANT: Snapshot Immutability
**Rule**: Files in `.knowledge-builder/curated-docs-repo-builder/snapshots/` are write-once, read-only audit trails.
**Why**: Snapshots provide forensic history for debugging bad curations. Modifications destroy evidence.

### INVARIANT: One Repo Per Specialist
**Rule**: Each curated docs repository is the complete documentation domain for exactly ONE specialist agent.
**Why**: Deep specialization requires exclusive focus. Shared domains create confused expertise.
**Example**:
- `next.js-docs-specialist` uses ONLY `.knowledge/curated-docs-repo/vercel-next.js/`
- Never split next.js docs across multiple curations

### INVARIANT: No Test Files in Curated Output
**Rule**: Curated docs repos MUST contain zero test files: `*.test.*`, `*.spec.*`, `__tests__/`, `test/`, `tests/`
**Why**: Tests for docs are infrastructure noise, not content.
**Validation**: `find .knowledge/curated-docs-repo/repo -name "*.test.*" -o -name "*.spec.*" | wc -l` must return 0

---

## RULES

### RULE: Content-First Inclusion Criteria
**Rule**: Include/exclude decisions MUST be based on documentation value, NOT size constraints.
**Why**: The goal is complete, helpful documentation. Size is an outcome of correct qualitative decisions.
**Decision Criteria**:
- ✅ INCLUDE if it helps explain library usage, concepts, APIs, patterns
- ❌ EXCLUDE if it's website infrastructure, build tools, rendering code
- Each decision answers: "Does this help an agent teach library usage?"
**Size Awareness**: Monitor size as a signal of curation quality:
- Unusually large? Check for missed exclusions (React components, build files)
- Unusually small? Verify comprehensive documentation coverage
- The RIGHT size = complete documentation without website noise

### RULE: Reasons Format
**Rule**: Decision reasons MUST be one of these exact strings:
- `"Included by pattern '<glob>'"`
- `"Excluded by pattern '<glob>'"`
- `"Outside include patterns"`
**Why**: Standardized reasons enable automated validation and pattern tracing.
**Override**: Only during migration from old format.

### RULE: Source of Truth
**Rule**: GitHub tree API response is the authoritative file list. Local discoveries don't override.
**Why**: Reproducibility requires canonical source. Local variations create inconsistencies.
**Override**: Only when API is truncated (then reconcile from local clone).

### RULE: Sparse Checkout Alignment
**Rule**: `sparse-checkout` patterns MUST be a subset of curated-tree.json "keep" decisions.
**Why**: Misalignment causes files to exist that shouldn't, breaking curation promises.

### RULE: No Build Artifacts
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
