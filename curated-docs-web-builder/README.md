# Curated Docs-Web Builder

Curates documentation from scraped websites into clean, comprehensive docs for specialist agents. Removes all website chrome (navigation, headers, footers, ads, analytics) to extract pure educational content.

## Usage

Invoke curation agent with:

```bash
Read /Users/MN/GITHUB/.knowledge-builder/curated-docs-web-builder/CURATOR-PROMPT.md with WEBSITE_URL=https://nextjs.org/docs
```

Or simply:

```bash
Read /Users/MN/GITHUB/.knowledge-builder/curated-docs-web-builder/CURATOR-PROMPT.md and curate https://nextjs.org/docs
```

The agent handles everything else automatically.

## What It Does

1. Checks for pristine website scrape (syncs if missing/stale >30 days)
2. Analyzes BOTH httrack (HTML) and crawl4ai (markdown) sources
3. **Extracts clean markdown from crawl4ai JSON wrapper**
4. **Splits large documentation into logical, topic-based files**
5. Applies web docs curation criteria (keep documentation, exclude website chrome)
6. Creates structured, agent-friendly output in `.knowledge/curated-docs-web/{domain}/`

## What Gets Kept

- Documentation pages (HTML or markdown)
- Tutorials, guides, API references
- Code examples embedded in docs
- Diagrams, screenshots, educational images
- Content from BOTH httrack and crawl4ai sources

## What Gets Excluded

- Website chrome (headers, footers, sidebars, navigation)
- Analytics and tracking scripts (gtag, google-analytics)
- Marketing pages (pricing, enterprise, about, careers)
- Website infrastructure (_next/, node_modules/, webpack/)
- SEO and social media assets

## Output

```
.knowledge/curated-docs-web/
├── nextjs.org/              # Next.js docs from official site
│   ├── docs/                # HTML pages from httrack
│   ├── content.md           # Markdown from crawl4ai
│   └── .curation/           # Provenance metadata
└── react.dev/               # React docs from official site
```

## System Details

See `CONTEXT.md` for vision and `CONSTRAINTS.md` for rules.

## Difference from Docs-GH

- **Docs-GH**: GitHub repo docs/ directory (Markdown, MDX, code structure)
- **Docs-Web**: Official website docs (HTML + markdown, remove chrome not React components)
