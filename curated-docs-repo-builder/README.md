# Curated Docs-GH Builder

Curates documentation from GitHub repositories into clean, comprehensive docs for specialist agents.

## Usage

Invoke curation agent with:

```bash
Read /Users/MN/GITHUB/.knowledge-builder/curated-docs-repo-builder/CURATOR-PROMPT.md with REPO_URL=https://github.com/owner/repo
```

Or simply:

```bash
Read /Users/MN/GITHUB/.knowledge-builder/curated-docs-repo-builder/CURATOR-PROMPT.md and curate https://github.com/owner/repo
```

The agent handles everything else automatically.

## What It Does

1. Checks for pristine repo clone (syncs if missing/stale)
2. Analyzes repository structure for documentation
3. Applies docs-specific curation criteria (keep docs content, exclude website code)
4. Outputs comprehensive documentation to `.knowledge/curated-docs-repo/{owner}-{repo}/`

## What Gets Kept

- Documentation directories (`docs/`, `documentation/`, `content/`, `guides/`)
- Markdown and MDX files
- Code examples within docs
- Images and diagrams
- API references

## What Gets Excluded

- Website rendering code (React/Vue components)
- Build configurations
- Tests for documentation
- Build outputs (dist/, .next/, etc.)
- node_modules

## Output

```
.knowledge/curated-docs-repo/
├── vercel-next.js/         # Next.js documentation
└── unclecode-crawl4ai/     # Crawl4AI documentation
```

## System Details

See `CONTEXT.md` for vision and `CONSTRAINTS.md` for rules.

## Difference from Code Curation

- **Code curation**: "How it works internally" (implementation)
- **Docs curation**: "How to use it" (tutorials, guides, API refs)
