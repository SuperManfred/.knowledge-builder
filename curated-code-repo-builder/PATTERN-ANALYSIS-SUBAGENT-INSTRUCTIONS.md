# Pattern Analysis Subagent Instructions

## Purpose

Analyze a subset of the repository's file tree to identify patterns for curation decisions.

## Inputs Provided

You will receive:
- **Chunk of git tree output**: A subset of the full repository tree (targeting ~100k tokens)
- **Repository context**: Project name, description, language
- **Analysis focus**: What patterns to identify

## Your Task

Analyze the provided tree chunk and identify:

### 1. Directory Patterns

**Infrastructure/tooling** (likely exclude):
- Build outputs: `dist/`, `build/`, `.next/`, `out/`
- Dependencies: `node_modules/`, `vendor/`, `packages/*/node_modules/`
- Cache: `.cache/`, `.turbo/`, `.parcel-cache/`
- IDE: `.vscode/`, `.idea/`, `.eclipse/`
- OS artifacts: `.DS_Store`, `Thumbs.db`

**Configuration** (likely exclude unless critical):
- Linting: `.eslintrc.*`, `.prettierrc.*`, `stylelint.config.*`
- Testing: `jest.config.*`, `vitest.config.*`, `.mocharc.*`
- Build tools: `webpack.config.*`, `vite.config.*`, `rollup.config.*`
- CI/CD: `.github/workflows/`, `.gitlab-ci.yml`, `circle.yml`

**Documentation** (contextual - often exclude):
- Examples: `examples/`, `demos/`
- Docs sites: `docs/`, `website/`, `documentation/`
- Contributor guides: `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`

**Core implementation** (likely include):
- Source code: `src/`, `lib/`, `core/`, `app/`
- Types: `types/`, `@types/`, `*.d.ts` (if TypeScript)
- Key configs: `package.json`, `tsconfig.json`

### 2. File Extension Patterns

**Source code** (include):
- Implementation: `.ts`, `.tsx`, `.js`, `.jsx`, `.py`, `.go`, `.rs`, `.java`
- Styles: `.css`, `.scss`, `.sass`, `.less` (if relevant to patterns)
- Templates: `.vue`, `.svelte`, `.astro`

**Generated/compiled** (exclude):
- Maps: `.map`, `.js.map`, `.css.map`
- Minified: `.min.js`, `.min.css`
- Compiled: `.d.ts.map`, `*.generated.*`

**Assets** (usually exclude):
- Images: `.png`, `.jpg`, `.svg`, `.ico`, `.gif`
- Fonts: `.woff`, `.woff2`, `.ttf`, `.eot`
- Media: `.mp4`, `.webm`, `.mp3`

**Data/config** (selective):
- Lock files: `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml` (usually exclude)
- Env examples: `.env.example` (include), `.env.local` (exclude)

### 3. Naming Convention Patterns

**Test files** (usually exclude):
- `*.test.ts`, `*.spec.ts`, `*.test.tsx`
- `__tests__/`, `test/`, `tests/`
- `*.stories.tsx` (Storybook)

**Internal/private** (contextual):
- `_*.ts`, `*.internal.ts`, `*.private.ts`
- `__mocks__/`, `__fixtures__/`

### 4. Monorepo Patterns

If monorepo detected (`packages/*/`, `apps/*/`):
- Identify shared vs. app-specific code
- Note workspace structure
- Recommend keeping root + one representative package for curation

## Output Format

Return analysis as structured data:

```markdown
## Pattern Analysis Results

### Directory Recommendations

**EXCLUDE (infrastructure/tooling):**
- dist/, build/, .next/
- node_modules/, .cache/
- Reason: Generated artifacts, not source of truth

**EXCLUDE (configuration):**
- .github/workflows/
- .eslintrc.js, prettier.config.js
- Reason: Tooling config, not implementation patterns

**INCLUDE (core implementation):**
- src/
- lib/
- Reason: Core implementation patterns

**CONTEXTUAL (documentation):**
- examples/
- Reason: May show usage patterns, review individually

### File Extension Recommendations

**INCLUDE:**
- .ts, .tsx (TypeScript implementation)
- .css, .scss (styling patterns)

**EXCLUDE:**
- .map (source maps)
- .png, .jpg, .svg (assets)
- .test.ts, .spec.ts (tests)

### Special Patterns Detected

- Monorepo structure: packages/[pkg1, pkg2, pkg3]
  - Recommend: Keep packages/core/ as representative

- Generated files: *.generated.ts
  - Pattern: Files ending in .generated.ts
  - Recommend: Exclude

- Barrel exports: index.ts re-exporting from subdirectories
  - Recommend: Include (shows public API structure)

### Statistics for This Chunk

- Total entries analyzed: 45,234
- Directories: 3,456
- Files: 41,778
- Estimated exclusion: ~65% (based on patterns above)
```

## Analysis Guidelines

1. **Be specific**: Identify exact patterns, not vague categories
2. **Provide rationale**: Explain WHY each pattern matters for curation
3. **Estimate impact**: How many files/dirs match each pattern
4. **Note exceptions**: When common patterns should be kept (e.g., critical configs)
5. **Detect frameworks**: Identify Next.js, Vite, etc. and their conventional structures

## Context Window Management

Your chunk is sized to fit comfortably in context (~100k tokens). Focus on:
- Pattern identification, not exhaustive listing
- Representative examples from each category
- Statistical summaries

The curator will combine your analysis with other chunks to make final curation decisions.
