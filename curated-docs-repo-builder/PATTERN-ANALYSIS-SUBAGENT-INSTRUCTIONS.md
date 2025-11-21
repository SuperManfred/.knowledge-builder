# Pattern Analysis Subagent Instructions (Documentation)

## Purpose

Analyze a subset of the documentation repository's file tree to identify patterns for curation decisions.

## Inputs Provided

You will receive:
- **Chunk of git tree output**: A subset of the full repository tree (targeting ~100k tokens)
- **Repository context**: Project name, description
- **Analysis focus**: What documentation patterns to identify

## Your Task

Analyze the provided tree chunk and identify:

### 1. Directory Patterns

**Documentation directories** (likely include):
- Content: `docs/`, `documentation/`, `content/`, `guides/`, `tutorials/`
- Website content: `website/content/`, `website/docs/`, `website/pages/`
- Examples: `examples/**/*.md`, `examples/**/*.mdx` (usage examples, not code)
- API references: `api/`, `reference/`, `api-docs/`

**Website infrastructure** (likely exclude):
- Components: `website/components/`, `docs/components/`, `website/src/components/`
- Build configs: `website/next.config.js`, `docs/docusaurus.config.js`, `website/vite.config.js`
- Build outputs: `website/dist/`, `website/build/`, `docs/.next/`, `docs/.docusaurus/`
- Node modules: `website/node_modules/`, `docs/node_modules/`, `**/node_modules/`

**Source code** (exclude - this is docs-repo, not code-repo):
- Implementation: `src/`, `lib/`, `packages/*/src/`, `core/`, `app/`
- Reason: These should be curated in code-repo-builder, not docs-repo-builder

**Infrastructure** (exclude):
- CI/CD: `.github/workflows/`, `.gitlab/`, `.circleci/`
- Containers: `Dockerfile`, `docker-compose.yml`, `.dockerignore`
- Package management: `pyproject.toml`, `setup.py`, `uv.lock`, `package-lock.json`, `yarn.lock`

**Non-documentation markdown** (exclude):
- Contributing: `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`
- Changelogs: `CHANGELOG.md` (unless it's part of docs for users)

### 2. File Extension Patterns

**Documentation content** (include):
- Markdown: `.md`, `.mdx`, `.markdown`
- ReStructuredText: `.rst` (Python projects)
- AsciiDoc: `.adoc`, `.asciidoc`

**Documentation assets** (include if in docs directories):
- Diagrams: `.svg`, `.png`, `.jpg`, `.gif` (only within docs/ paths)
- Videos: `.mp4`, `.webm` (if in docs/tutorials/)

**Code examples in docs** (contextual):
- Simple examples: `.js`, `.ts`, `.py`, `.go` (if in docs/examples/)
- Interactive demos: `.html`, `.jsx` (if demonstrating usage, not site infrastructure)

**Website code** (exclude):
- React/Vue components: `.jsx`, `.tsx`, `.vue` (in website/components/)
- Styling: `.css`, `.scss`, `.sass` (site styling, not docs content)
- Site scripts: `.js`, `.ts` (in website/lib/, website/src/)

**Generated/compiled** (exclude):
- Build outputs: `.html` (if generated), `.xml`, `.json` (if generated)
- API docs: Only exclude if auto-generated and source exists elsewhere

### 3. Naming Convention Patterns

**Documentation files** (include):
- Getting started: `getting-started.md`, `quickstart.md`, `introduction.md`
- Guides: `guide-*.md`, `how-to-*.md`, `tutorial-*.md`
- API docs: `api-reference.md`, `api/*.md`, `reference/*.md`
- Concepts: `concepts/*.md`, `architecture.md`

**Website files** (exclude):
- Components: `Header.tsx`, `Footer.tsx`, `Sidebar.jsx`
- Pages: `index.tsx`, `_app.tsx`, `_document.tsx` (if site infrastructure)
- Layouts: `Layout.tsx`, `DocsLayout.tsx`

**Test files** (exclude):
- `*.test.js`, `*.spec.js`, `*.test.md` (yes, even markdown tests)
- `__tests__/`, `test/`, `tests/`
- `test_*.py` (Python test files)

### 4. Documentation Site Patterns

**Static site generators detected:**
- **Docusaurus**: `docusaurus.config.js`, `.docusaurus/`, `sidebars.js`
  - Include: `docs/**/*.md`, `blog/**/*.md` (if usage-focused)
  - Exclude: `src/`, `website/src/`, build configs

- **Next.js**: `next.config.js`, `.next/`, `pages/` or `app/`
  - Include: `content/**/*.md`, MDX content files
  - Exclude: `pages/**/*.tsx` (site code), `components/`

- **VitePress**: `.vitepress/`, `vitepress.config.js`
  - Include: `docs/**/*.md`, `guide/**/*.md`
  - Exclude: `.vitepress/theme/`, `.vitepress/config.ts`

- **MkDocs**: `mkdocs.yml`
  - Include: `docs/**/*.md`
  - Exclude: `site/` (build output)

- **Sphinx**: `conf.py`, `_build/`
  - Include: `**/*.rst`, `docs/**/*.md`
  - Exclude: `_build/`, `_static/`, `_templates/` (themes)

## Output Format

Return analysis as structured data:

```markdown
## Pattern Analysis Results (Documentation)

### Directory Recommendations

**INCLUDE (documentation content):**
- docs/, guides/, tutorials/
- Reason: Core user-facing documentation

**INCLUDE (documentation assets):**
- docs/**/*.{png,svg,jpg}
- Reason: Diagrams and images that explain concepts

**EXCLUDE (website infrastructure):**
- website/components/, website/src/
- docs/.docusaurus/, docs/.next/
- Reason: Build tooling and site rendering code

**EXCLUDE (source code):**
- src/, lib/, packages/*/src/
- Reason: Implementation code (belongs in code-repo curation)

**EXCLUDE (non-docs markdown):**
- CONTRIBUTING.md, CODE_OF_CONDUCT.md
- Reason: Meta-documentation, not usage docs

### File Extension Recommendations

**INCLUDE:**
- .md, .mdx (documentation content)
- .svg, .png (diagrams within docs/)

**EXCLUDE:**
- .tsx, .jsx (React components)
- .css, .scss (styling)
- .test.js, .spec.ts (tests)

### Special Patterns Detected

- Static site generator: Docusaurus
  - Config: docusaurus.config.js
  - Recommend: Include docs/, blog/ (if usage-focused)
  - Recommend: Exclude src/, .docusaurus/

- Documentation assets directory: docs/assets/
  - Recommend: Include .svg, .png for diagrams
  - Recommend: Exclude .ico, .woff (site assets)

- Code examples: examples/**/*.md
  - Recommend: Include (shows usage patterns)
  - Note: May contain .js/.ts files that are examples, not infrastructure

### Statistics for This Chunk

- Total entries analyzed: 8,234
- Directories: 567
- Files: 7,667
- Estimated inclusion: ~30% (documentation-heavy repos may be higher)
```

## Analysis Guidelines

1. **Docs vs. site infrastructure**: Distinguish content from rendering code
2. **Usage examples**: Include examples that show library usage, exclude site demos
3. **Assets**: Include diagrams/images in docs paths, exclude site branding
4. **Generated docs**: Prefer source (e.g., .rst) over generated (e.g., .html)
5. **Comprehensive docs**: Documentation repos should be MORE inclusive than code repos

## Context Window Management

Your chunk is sized to fit comfortably in context (~100k tokens). Focus on:
- Pattern identification, not exhaustive listing
- Representative examples from each category
- Statistical summaries

The curator will combine your analysis with other chunks to make final curation decisions.
