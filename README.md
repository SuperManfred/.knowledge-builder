# Knowledge Builder System

Build curated knowledge bases from code repositories and documentation websites for specialist AI agents.

---

## Quick Start

### 1. Scrape a Website
```bash
/Users/MN/GITHUB/.knowledge-builder/full-docs-website-sync/sync.sh https://repoprompt.com/docs
```

### 2. Curate Documentation
```bash
Read /Users/MN/GITHUB/.knowledge-builder/curated-docs-web-builder/CURATOR-PROMPT-V2.md with WEBSITE_URL=https://repoprompt.com/docs
```

### 3. Generate Specialist Prompt
```bash
Read /Users/MN/GITHUB/.knowledge/curated-docs-web/SPECIALIST-META-PROMPT.md with KB_PATH=/Users/MN/GITHUB/.knowledge/curated-docs-web/repoprompt.com
```

### 4. Use the Specialist
The generated specialist prompt lives at:
```
/Users/MN/GITHUB/.knowledge/curated-docs-web/repoprompt.com/SPECIALIST-PROMPT.md
```

Invoke it by reading that file in a fresh agent session.

---

## System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    KNOWLEDGE BUILDER                         │
│                                                              │
│  Input: URLs, GitHub repos                                  │
│  Output: Curated knowledge bases for specialist agents      │
└─────────────────────────────────────────────────────────────┘

Step 1: SCRAPE                    Step 2: CURATE                Step 3: GENERATE SPECIALIST
─────────────────                 ──────────────                ────────────────────────
Source: Website/Repo              Input: Scraped files          Input: Curated KB
Tool: sync.sh                     Tool: CURATOR-PROMPT          Tool: SPECIALIST-META-PROMPT
Output: Raw scraped data          Output: Clean docs            Output: Specialist prompt
Location: .knowledge/             Location: .knowledge/         Location: KB/SPECIALIST-PROMPT.md
  full-docs-website/                curated-docs-web/
  full-repo/                        curated-code/
                                    curated-docs-gh/
```

---

## Three Knowledge Types

### 1. **Curated Code** (Implementation)
- **Source**: GitHub repository code
- **Purpose**: Understand how it works internally
- **Scraper**: `full-repo-sync/sync.sh`
- **Curator**: `curated-code-builder/CURATOR-PROMPT.md`
- **Output**: `.knowledge/curated-code/{owner}-{repo}/`

**Example**:
```bash
# Scrape
/Users/MN/GITHUB/.knowledge-builder/full-repo-sync/sync.sh https://github.com/unclecode/crawl4ai

# Curate
Read /Users/MN/GITHUB/.knowledge-builder/curated-code-builder/CURATOR-PROMPT.md with REPO_URL=https://github.com/unclecode/crawl4ai
```

---

### 2. **Curated Docs-GH** (GitHub Docs)
- **Source**: GitHub repository docs/ directory
- **Purpose**: Learn how to use it (from repo docs)
- **Scraper**: `full-repo-sync/sync.sh`
- **Curator**: `curated-docs-gh-builder/CURATOR-PROMPT.md`
- **Output**: `.knowledge/curated-docs-gh/{owner}-{repo}/`

**Example**:
```bash
# Scrape
/Users/MN/GITHUB/.knowledge-builder/full-repo-sync/sync.sh https://github.com/vercel/next.js

# Curate
Read /Users/MN/GITHUB/.knowledge-builder/curated-docs-gh-builder/CURATOR-PROMPT.md with REPO_URL=https://github.com/vercel/next.js
```

---

### 3. **Curated Docs-Web** (Website Docs)
- **Source**: Official documentation website
- **Purpose**: Learn how to use it (from official site)
- **Scraper**: `full-docs-website-sync/sync.sh`
- **Curator**: `curated-docs-web-builder/CURATOR-PROMPT-V2.md`
- **Output**: `.knowledge/curated-docs-web/{domain}/`

**Example**:
```bash
# Scrape
/Users/MN/GITHUB/.knowledge-builder/full-docs-website-sync/sync.sh https://repoprompt.com/docs

# Curate
Read /Users/MN/GITHUB/.knowledge-builder/curated-docs-web-builder/CURATOR-PROMPT-V2.md with WEBSITE_URL=https://repoprompt.com/docs
```

---

## Complete Workflow Example

### Building a RepoPrompt Documentation Specialist

**Step 1: Scrape the website**
```bash
/Users/MN/GITHUB/.knowledge-builder/full-docs-website-sync/sync.sh https://repoprompt.com/docs
```

**Step 2: Curate into clean docs**
```bash
Read /Users/MN/GITHUB/.knowledge-builder/curated-docs-web-builder/CURATOR-PROMPT-V2.md with WEBSITE_URL=https://repoprompt.com/docs
```

**Step 3: Generate specialist prompt**
```bash
Read /Users/MN/GITHUB/.knowledge/curated-docs-web/SPECIALIST-META-PROMPT.md with KB_PATH=/Users/MN/GITHUB/.knowledge/curated-docs-web/repoprompt.com
```

**Step 4: Use the specialist**
```bash
Read /Users/MN/GITHUB/.knowledge/curated-docs-web/repoprompt.com/SPECIALIST-PROMPT.md
```

Then ask it questions about RepoPrompt.

---

## Directory Structure

```
.knowledge-builder/
├── README.md                          ← You are here
├── ARCHITECTURE.md                    ← System design
├── META-BUILDER-PROMPT.md            ← Builds new curator systems
│
├── full-repo-sync/                    ← Clone GitHub repos
│   └── sync.sh
│
├── full-docs-website-sync/            ← Scrape documentation websites
│   ├── sync.sh
│   ├── crawl4ai_scraper.py
│   ├── playwright_scraper.py
│   └── validate_scrapers.py
│
├── curated-code-builder/              ← Curate code for "how it works"
│   ├── CURATOR-PROMPT.md
│   ├── CONSTRAINTS.md
│   └── CONTEXT.md
│
├── curated-docs-gh-builder/           ← Curate GitHub docs for "how to use"
│   ├── CURATOR-PROMPT.md
│   ├── CONSTRAINTS.md
│   └── CONTEXT.md
│
└── curated-docs-web-builder/          ← Curate website docs for "how to use"
    ├── CURATOR-PROMPT-V2.md           ← USE THIS (simple, works)
    ├── CURATOR-PROMPT.md              ← OLD (overcomplicated, don't use)
    ├── CONSTRAINTS.md
    └── CONTEXT.md

.knowledge/
├── full-repo/                         ← Raw GitHub repo clones
├── full-docs-website/                 ← Raw scraped websites
├── curated-code/                      ← Clean code (implementation)
├── curated-docs-gh/                   ← Clean docs from GitHub
└── curated-docs-web/                  ← Clean docs from websites
    └── SPECIALIST-META-PROMPT.md      ← Generates specialist prompts
```

---

## Key Files

### Scrapers
- `full-repo-sync/sync.sh` - Clone GitHub repos
- `full-docs-website-sync/sync.sh` - Scrape websites (httrack + crawl4ai + playwright)

### Curators
- `curated-code-builder/CURATOR-PROMPT.md` - Curate code
- `curated-docs-gh-builder/CURATOR-PROMPT.md` - Curate GitHub docs
- `curated-docs-web-builder/CURATOR-PROMPT-V2.md` - **Curate website docs (USE THIS)**

### Specialist Generators
- `.knowledge/curated-code/SPECIALIST-META-PROMPT.md`
- `.knowledge/curated-docs-gh/SPECIALIST-META-PROMPT.md`
- `.knowledge/curated-docs-web/SPECIALIST-META-PROMPT.md`

---

## Quality Checks

After curation, verify:

1. **No duplication**: Files contain unique content
2. **No website chrome**: Zero navigation/headers/footers
3. **Complete coverage**: All major sections from source present
4. **Actionable content**: Documentation, not marketing
5. **File count**: 10-20 files for docs (not 40+ duplicates)

---

## Troubleshooting

**Problem**: Scraped files are duplicates (SPA hash routing)
**Solution**: Curator must manually deduplicate by reading files

**Problem**: Scraping failed (empty/incomplete)
**Solution**: Re-run sync.sh, check for SPA/JavaScript heavy sites

**Problem**: Too many files after curation
**Solution**: Agent didn't deduplicate - files likely contain duplicate content

---

## Philosophy

**Curation = Reading + Judgment**

There's no shortcut. Scripts and automation fail. Agents must:
1. Read the files
2. Understand the content
3. Identify duplicates
4. Delete/merge as needed
5. Verify completeness

Manual work beats complex automation every time.
