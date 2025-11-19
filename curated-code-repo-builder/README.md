# Curated Code Builder

Curates GitHub repositories into minimal, code-only context for specialist agents.

## Usage

Invoke curation agent with:

```
read .knowledge-builder/curated-code-repo-builder/CURATOR-PROMPT.md with https://github.com/owner/repo
```

The agent handles everything else automatically.

## What It Does

1. Checks for pristine repo clone (syncs if missing/stale)
2. Analyzes repository structure
3. Applies qualitative curation criteria (keep implementation, exclude tests/docs)
4. Outputs minimal code-only curation to `.knowledge/curated-code-repo/{owner}-{repo}/`

## Output

```
.knowledge/curated-code-repo/
├── vercel-next.js/         # Curated Next.js code
└── facebook-react/         # Curated React code
```

## System Details

See `CONTEXT.md` for vision and `CONSTRAINTS.md` for rules.
