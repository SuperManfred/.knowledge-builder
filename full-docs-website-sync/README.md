# Full Docs Website Sync

Scrapes documentation websites with httrack and/or crawl4ai.

## Usage

```bash
./sync.sh <website-url> [--scraper=httrack|crawl4ai|both] [--force]
```

## Examples

```bash
# Scrape with both tools (recommended)
./sync.sh https://nextjs.org/docs

# Scrape with httrack only (pristine HTML)
./sync.sh https://react.dev --scraper=httrack

# Scrape with crawl4ai only (markdown extraction)
./sync.sh https://react.dev --scraper=crawl4ai

# Force re-scrape even if fresh
./sync.sh https://nextjs.org/docs --force
```

## Behavior

- **First time**: Scrapes website to `../.knowledge/full-docs-website/{domain}/`
- **Subsequent**: Checks staleness (>30 days), re-scrapes if needed
- **Fresh (<30 days)**: Skips scrape unless `--force` flag used
- **Updates**: `../.knowledge/full-docs-website/MANIFEST.yaml` with metadata

## Scrapers

### httrack
- **Output**: Complete HTML mirror in `{domain}/httrack/`
- **Browsable**: Can open offline in browser
- **Pristine**: Everything preserved (CSS, JS, images)

### crawl4ai
- **Output**: Markdown content in `{domain}/crawl4ai/`
- **Clean**: Pre-filtered, navigation/boilerplate removed
- **Fast**: Easier to curate, smaller output

### both (default)
- Runs both scrapers
- Curation can reference both for best results

## Dependencies

### Required
- `bash`
- `yq` (for MANIFEST.yaml updates)
  - Install: `brew install yq`

### Optional (based on scraper)
- `httrack` (for --scraper=httrack or both)
  - Install: `brew install httrack`
- `crawl4ai` (for --scraper=crawl4ai or both)
  - Install: `pipx install crawl4ai` (recommended, provides `crwl` command)
  - Or: `pip install crawl4ai`

## Output

```
../.knowledge/full-docs-website/
├── MANIFEST.yaml           # Registry of all scraped sites
├── nextjs.org/
│   ├── httrack/            # Complete HTML mirror
│   └── crawl4ai/           # Markdown extraction
│       ├── content.md
│       └── metadata.json
└── react.dev/
    ├── httrack/
    └── crawl4ai/
```

## Known Limitations

### Single-Page Apps with Hash Routing

**Issue**: Sites using hash-based routing (e.g., `#section=overview`) may only capture the initial page load.

**Affected sites**:
- React SPAs with client-side routing via URL fragments
- Vue Router in hash mode
- Sites where navigation happens via `#` without triggering page reloads

**Example**: `https://repoprompt.com/docs` has 12+ sections accessible via hash routes like `#s=quick-start&ss=installation`, but scraper only captures the Overview section visible on initial load.

**Why**:
- Hash changes don't trigger browser navigation events
- `wait_for="networkidle"` doesn't detect hash navigation
- Scrapers capture single page state, not all reachable content

**Workarounds**:
1. Check if site has a static export or sitemap.xml
2. Look for alternative documentation sources (GitHub docs, static sites)
3. Manually scrape individual routes if known
4. Wait for enhanced scraper with hash route navigation (future)

**Detection**: Use curation workflow's validation step - subagent will compare live site vs scraped content and detect missing sections.

### Static Sites and SSR - Works Well

**Full support for**:
- Static HTML documentation sites (MkDocs, Docusaurus with SSG)
- Server-side rendered sites (Next.js SSR, traditional multi-page sites)
- Sites with traditional `<a href>` navigation

## Notes

- httrack may take longer for large sites (downloads everything)
- crawl4ai is faster and handles JavaScript rendering with SPA support
- Using both gives best of both worlds for curation
- crawl4ai uses `wait_for="networkidle"` and `delay_before_return_html=3.0` for React/Vue apps
- For best results, prefer official docs with static HTML or SSR over client-side SPAs
