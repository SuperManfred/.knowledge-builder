# Context Builder Constraints

This document defines immutable rules that govern the context builder system. These constraints ensure consistency, reliability, and maintainability.

## Constraint Categories

- **INVARIANT**: MUST NEVER be violated or changed. System breaks if violated.
- **RULE**: STRONGLY enforced. Only override with exceptional justification.
- **GUIDELINE**: Preferred approach. Can flex based on specific needs.

---

## INVARIANTS

### INVARIANT: Code-Only Context Directory
**Rule**: `.context/` contains ONLY source code files. No documentation, build artifacts, or meta files.
**Why**: Agents need pure code context without distractions. Docs/meta add noise that degrades agent focus.
**Explicitly Excluded**: `/docs/`, `/doc/`, `/documentation/`, `*.md` files (except LICENSE/NOTICE when legally required)
**Example**:
- ✅ `.context/vercel-next.js/packages/next/src/server/api.ts`
- ❌ `.context/vercel-next.js/README.md`
- ❌ `.context/vercel-next.js/docs/api-reference.md`

### INVARIANT: Meta-Code Separation
**Rule**: `.context-builder/` contains ALL planning, meta, and tooling. Never mix with `.context/`.
**Why**: Clean separation ensures agents working with code never see curation logic, preventing confusion.
**Example**:
- Curated code: `.context/vercel-next.js/`
- Curation data: `.context-builder/projects/vercel-next.js/`

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
**Rule**: Curated repos MUST be named `{owner}-{repo}` (lowercase, hyphenated).
**Why**: Predictable paths enable automation and agent discovery.
**Example**:
- GitHub: `https://github.com/vercel/next.js`
- Directory: `.context/vercel-next.js`

### INVARIANT: Snapshot Immutability
**Rule**: Files in `.context-builder/snapshots/` are write-once, read-only audit trails.
**Why**: Snapshots provide forensic history for debugging bad curations. Modifications destroy evidence.

### INVARIANT: One Repo Per Specialist
**Rule**: Each curated repository is the complete knowledge domain for exactly ONE specialist agent.
**Why**: Deep specialization requires exclusive focus. Shared domains create confused expertise.
**Example**:
- `next.js-specialist` uses ONLY `.context/vercel-next.js/`
- Never split next.js across multiple curations

### INVARIANT: No Test Files in Curated Output
**Rule**: Curated repos MUST contain zero files matching: `*.test.*`, `*.spec.*`, `__tests__/`, `test/`, `tests/`
**Why**: Test files are noise for understanding implementation. They show usage but not how things work.
**Validation**: `find .context/repo -name "*.test.*" -o -name "*.spec.*" | wc -l` must return 0

---

## RULES

### RULE: Qualitative Inclusion Criteria
**Rule**: Include/exclude decisions MUST be based on qualitative value for specialist expertise, NOT size constraints.
**Why**: The goal is comprehensive specialist knowledge. Size is merely an outcome of correct qualitative decisions.
**Decision Criteria**:
- ✅ INCLUDE if it helps understand implementation, patterns, architecture, internals
- ❌ EXCLUDE if it's tests, docs, examples, demos, build outputs, media, vendored code
- Each decision answers: "Does this enable library-maintainer level thinking?"
**Size Awareness**: Monitor size as a signal of curation quality, not a limit:
- Unusually large? Check for missed exclusions (vendor, build, generated files)
- Unusually small? Verify comprehensive coverage of implementation
- The RIGHT size = whatever achieves specialist expertise

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

### RULE: No Compiled/Vendored Code
**Rule**: Exclude `dist/`, `build/`, `vendor/`, `node_modules/`, `*.min.js`, `compiled/`
**Why**: Compiled code is unreadable to agents. Vendored code belongs to different domains.
**Override**: Only if it's the ONLY source available (no original source exists).

---

## GUIDELINES

### GUIDELINE: Prefer Source Directories
**Preference**: Keep `src/`, `lib/`, `packages/*/src/` over other directories.
**Why**: These conventionally contain runtime implementation code.
**Flexibility**: Adapt to language conventions (e.g., `app/` for Ruby, `pkg/` for Go).

### GUIDELINE: Include Navigation Files
**Preference**: Keep `index.*`, `router.*`, `registry.*` files even if large.
**Why**: These files help agents understand codebase structure and entry points.
**Flexibility**: Omit if they're generated or mostly re-export.

### GUIDELINE: Manifest Files
**Preference**: Keep `package.json`, `pyproject.toml`, `go.mod`, etc. at package roots.
**Why**: Helps agents understand dependencies and package boundaries.
**Flexibility**: Omit if package has no source code kept.

### GUIDELINE: File Count as Quality Signal
**Preference**: File count should reflect comprehensive coverage, not arbitrary limits.
**Why**: A specialist needs whatever files contain the implementation knowledge.
**Quality Indicators**:
- Small repos (<100 files): Verify nothing important was missed
- Medium repos (100-2000 files): Common for comprehensive coverage
- Large repos (>2000 files): Check for proper exclusion of tests/docs/build
**Remember**: 5,000 implementation files > 100 files missing core modules

### GUIDELINE: Incremental Curation
**Preference**: Start minimal, expand based on agent needs.
**Why**: Easier to add than remove. Minimal surface aids focus.
**Flexibility**: Can front-load more if domain is well understood.

---

## Modification Rules

### Who Can Modify This Document
- **Humans**: Can modify any section with justification
- **Agents**: PROHIBITED from modifying this document
- **META-BUILDER-PROMPT agent**: Can read but never write

### When to Add Constraints
- When a pattern causes repeated failures
- When automation requires predictability
- When agents make consistent mistakes

### When to Promote Guidelines→Rules→Invariants
- Guideline→Rule: After 3+ repos benefit from enforcement
- Rule→Invariant: When violation would break system functionality