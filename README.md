# Knowledge Builder System

Build curated knowledge bases from code repositories and documentation websites for specialist AI agents.

**Agent-First Design**: This system is designed to be used by AI agents. Simply clone the repo and tell your agent to read the appropriate prompt file.

---

## Quick Start (Agent-Driven)

### 1. Add a New Resource

Tell your AI agent:

**For curated website docs resource:**

```
Read .knowledge-builder/curated-docs-web-builder/CURATOR-PROMPT.md with WEBSITE_URL=https://repoprompt.com/docs
```

**For curated GitHub code resource:**

```
Read .knowledge-builder/curated-code-builder/CURATOR-PROMPT.md with REPO_URL=https://github.com/unclecode/crawl4ai
```

**For curated GitHub docs resource:**

```
Read .knowledge-builder/curated-docs-gh-builder/CURATOR-PROMPT.md with REPO_URL=https://github.com/vercel/next.js
```

The agent will:

1. Scrape/clone the source (if needed)
2. Analyze and curate the content
3. Output clean, minimal knowledge base

---

### 2. Use a Resource in Your Project

Tell your AI agent working on another project:

```
Read /Users/MN/GITHUB/.knowledge/curated-docs-web/repoprompt.com/SPECIALIST-PROMPT.md
```

The agent will become a specialist in that resource and can answer questions or help you use it.

---

### 3. Improve the Builder System

Tell your AI agent:

```
Read .knowledge-builder/META-BUILDER-PROMPT.md
```

The agent will audit and improve the curation system itself.

---

## System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    KNOWLEDGE BUILDER                        │
│                                                             │
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
- **Purpose**: Understand how a library works internally
- **Use Case**: Fork a library, debug internals, understand architecture
- **Output**: `.knowledge/curated-code/{owner}-{repo}/`

**Agent Command**:

```
Read .knowledge-builder/curated-code-builder/CURATOR-PROMPT.md with REPO_URL=https://github.com/unclecode/crawl4ai
```

---

### 2. **Curated Docs-GH** (GitHub Docs)

- **Source**: GitHub repository docs/ directory
- **Purpose**: Learn how to use a library (from repo docs)
- **Use Case**: Implement features, understand API, follow guides
- **Output**: `.knowledge/curated-docs-gh/{owner}-{repo}/`

**Agent Command**:

```
Read .knowledge-builder/curated-docs-gh-builder/CURATOR-PROMPT.md with REPO_URL=https://github.com/vercel/next.js
```

---

### 3. **Curated Docs-Web** (Website Docs)

- **Source**: Official documentation website
- **Purpose**: Learn how to use a tool/framework (from official site)
- **Use Case**: Most comprehensive docs, tutorials, best practices
- **Output**: `.knowledge/curated-docs-web/{domain}/`

**Agent Command**:

```
Read .knowledge-builder/curated-docs-web-builder/CURATOR-PROMPT.md with WEBSITE_URL=https://repoprompt.com/docs
```

---

## Usage Patterns

### Pattern 1: Use a Knowledge Base (have your agent imbued with optimal resource knowledge)

Tell your agent working on a project to become a specialist of the resource:

```
Read /Users/MN/GITHUB/.knowledge/curated-docs-web/docs.example.com/SPECIALIST-PROMPT.md
```

### Pattern 2: Add a Knowledge Base (have an agent add another resource and curate it optimally)

Tell your agent to curate a new resource (one-time setup):

```
Read .knowledge-builder/curated-docs-web-builder/CURATOR-PROMPT.md with WEBSITE_URL=https://docs.example.com
```

### Pattern 3: Improve the System (two paths: self improve based on performance over time, user/agent brainstorm for how to improve the system)

#### Self improvement: (have an agent improve the prompts to make the system better - do not DIY)

Tell your agent an idea/concept to improve the builder infrastructure:

```
Read .knowledge-builder/META-BUILDER-PROMPT.md
```

#### User/AI collaborative improvement: (have an agent brainstorm with you for how to improve the system)

<!-- to do: write this -->

### Pattern 4: Browse Available Resources

```
ls .knowledge/curated-code/        # Implementation code
ls .knowledge/curated-docs-gh/     # GitHub documentation
ls .knowledge/curated-docs-web/    # Website documentation
```

Each directory contains a SPECIALIST-PROMPT.md you can use.

---

## Complete Workflow Example

### Building and Using a RepoPrompt Specialist

**Scenario**: You want to use RepoPrompt in your project and need an AI specialist to help.

**Step 1: Create the knowledge base (one-time setup)**

Tell your AI agent:

```
Read .knowledge-builder/curated-docs-web-builder/CURATOR-PROMPT.md with WEBSITE_URL=https://repoprompt.com/docs
```

The agent will scrape, curate, and create `.knowledge/curated-docs-web/repoprompt.com/`

**Step 2: Use the specialist in your project**

In a new agent session working on your project, tell the agent:

```
Read /Users/MN/GITHUB/.knowledge/curated-docs-web/repoprompt.com/SPECIALIST-PROMPT.md
```

Now ask questions:

- "How do I configure RepoPrompt for my codebase?"
- "What's the best way to structure my repository for RepoPrompt?"
- "Help me debug this RepoPrompt configuration error..."

The agent has deep knowledge of RepoPrompt and can help you use it effectively.

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
    ├── CURATOR-PROMPT.md
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
- `curated-docs-web-builder/CURATOR-PROMPT.md` - Curate website docs

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
