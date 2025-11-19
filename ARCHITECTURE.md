# Knowledge Curation System Architecture

**Version**: 1.1
**Date**: 2025-11-08
**Status**: Finalized - Ready for Implementation

---

## 🎯 Purpose

Enable specialist AI agents to operate with maximum expertise by providing three types of curated resources:
1. **Curated Code** - Minimal, implementation-focused code from repositories
2. **Curated Docs (GitHub)** - Documentation from GitHub repositories
3. **Curated Docs (Web)** - Documentation from official websites

Each resource type serves different agent consultation patterns and requires different curation approaches.

---

## 🏗️ Directory Structure

```
/Users/MN/GITHUB/
├── .knowledge/                          # All curated and pristine resources
│   ├── full-repo/                       # Pristine GitHub clones
│   │   ├── MANIFEST.yaml                # Registry of all repos with metadata
│   │   ├── vercel-next.js/              # Full clone of vercel/next.js
│   │   ├── facebook-react/              # Full clone of facebook/react
│   │   └── {owner}-{repo}/              # Pattern: owner-repo (lowercase)
│   │
│   ├── full-docs-website/               # Complete website scrapes
│   │   ├── MANIFEST.yaml                # Registry of all websites with metadata
│   │   ├── nextjs.org/                  # Full scrape of nextjs.org
│   │   ├── react.dev/                   # Full scrape of react.dev
│   │   └── {domain}/                    # Pattern: domain name
│   │
│   ├── curated-code/                    # Curated code (current .context)
│   │   ├── vercel-next.js/              # Minimal code-only for next.js specialist
│   │   ├── facebook-react/              # Minimal code-only for react specialist
│   │   └── {owner}-{repo}/              # Same naming as full-repo
│   │
│   ├── curated-docs-gh/                 # Curated docs from GitHub
│   │   ├── vercel-next.js/              # Curated docs for next.js
│   │   └── {owner}-{repo}/              # Same naming pattern
│   │
│   └── curated-docs-web/                # Curated docs from websites
│       ├── nextjs.org/                  # Curated docs from nextjs.org
│       └── {domain}/                    # Same naming as full-docs-website
│
└── .knowledge-builder/                  # All knowledge system infrastructure
    ├── ARCHITECTURE.md                  # This document
    │
    ├── full-repo-sync/                  # Sync system for GitHub repos
    │   ├── README.md                    # Brief usage instructions
    │   └── sync.sh                      # Script: clone or pull GitHub repos
    │
    ├── full-docs-website-sync/          # Sync system for websites
    │   ├── README.md                    # Brief usage instructions
    │   └── sync.sh                      # Script: scrape websites (httrack + crawl4ai)
    │
    ├── curated-code-repo-builder/            # Code curation system (current .context-builder)
    │   ├── META-BUILDER-PROMPT.md       # Instructions for improving this system
    │   ├── PROMPT.md                    # One-shot curation instructions
    │   ├── CONTEXT.md                   # Vision and goals (IMMUTABLE)
    │   ├── CONSTRAINTS.md               # Rules and invariants (IMMUTABLE)
    │   ├── README.md                    # Simple: how to invoke
    │   ├── CHANGELOG/                   # Historical changes
    │   ├── projects/                    # Project-specific planning/meta
    │   │   └── {owner}-{repo}/
    │   │       ├── curation.yaml
    │   │       ├── curated-tree.json
    │   │       ├── sparse-checkout
    │   │       └── scripts/curate.sh
    │   ├── snapshots/                   # GitHub API snapshots
    │   │   └── {owner}-{repo}/{commit}/
    │   │       └── github-api-tree.json
    │   ├── _template/                   # Templates for new projects
    │   └── tools/
    │       ├── scaffold.sh
    │       └── generate-manifest.sh
    │
    ├── curated-docs-repo-builder/         # Docs-from-GH curation system
    │   ├── META-BUILDER-PROMPT.md       # Instructions for improving this system
    │   ├── PROMPT.md                    # One-shot docs curation instructions
    │   ├── CONTEXT.md                   # Vision for docs curation (IMMUTABLE)
    │   ├── CONSTRAINTS.md               # Rules for docs curation (IMMUTABLE)
    │   ├── README.md                    # Simple: how to invoke
    │   ├── CHANGELOG/                   # Historical changes
    │   ├── projects/                    # Project-specific planning/meta
    │   └── tools/                       # Scaffolding and tooling
    │
    └── curated-docs-web-builder/        # Docs-from-web curation system
        ├── META-BUILDER-PROMPT.md       # Instructions for improving this system
        ├── PROMPT.md                    # One-shot web docs curation instructions
        ├── CONTEXT.md                   # Vision for web docs (IMMUTABLE)
        ├── CONSTRAINTS.md               # Rules for web docs (IMMUTABLE)
        ├── README.md                    # Simple: how to invoke
        ├── CHANGELOG/                   # Historical changes
        ├── projects/                    # Project-specific planning/meta
        └── tools/                       # Scraping and tooling
```

---

## 🔄 Workflows

### Workflow 1: Curate Code from GitHub

```
USER INVOKES:
"read .curated-code-repo-builder/PROMPT.md with https://github.com/vercel/next.js"

↓

AGENT READS PROMPT.md
├─ Parse URL → owner=vercel, repo=next.js
├─ Check: Does .knowledge/full-repo/vercel-next.js/ exist?
│  ├─ NO → Execute: .full-repo-sync/sync.sh https://github.com/vercel/next.js
│  │        └─ Clones to .knowledge/full-repo/vercel-next.js/
│  └─ YES → Continue
│
├─ Run curation analysis
│  ├─ Fetch GitHub API tree
│  ├─ Analyze structure (source dirs, tests, docs, etc.)
│  ├─ Apply qualitative criteria (keep implementation, exclude tests/docs)
│  ├─ Generate artifacts:
│  │  ├─ .curated-code-repo-builder/projects/vercel-next.js/curated-tree.json
│  │  ├─ .curated-code-repo-builder/projects/vercel-next.js/sparse-checkout
│  │  └─ .curated-code-repo-builder/projects/vercel-next.js/curation.yaml
│  └─ Validate against CONSTRAINTS.md
│
└─ Clone with sparse-checkout to .knowledge/curated-code-repo/vercel-next.js/
   └─ Post-clone verification (zero test files, zero docs dirs)

OUTPUT: .knowledge/curated-code-repo/vercel-next.js/ (minimal, code-only)
```

### Workflow 2: Curate Docs from GitHub

```
USER INVOKES:
"read .curated-docs-repo-builder/PROMPT.md with https://github.com/vercel/next.js"

↓

AGENT READS PROMPT.md
├─ Parse URL → owner=vercel, repo=next.js
├─ Check: Does .knowledge/full-repo/vercel-next.js/ exist?
│  ├─ NO → Execute: .full-repo-sync/sync.sh https://github.com/vercel/next.js
│  └─ YES → Continue
│
├─ Run docs curation analysis
│  ├─ Identify docs directories (docs/, documentation/, website/content/, etc.)
│  ├─ Apply docs-specific criteria:
│  │  ├─ KEEP: Tutorials, guides, API docs, examples in docs
│  │  ├─ EXCLUDE: Website boilerplate, tests, build configs for docs site
│  ├─ Generate artifacts:
│  │  ├─ .curated-docs-repo-builder/projects/vercel-next.js/curated-tree.json
│  │  └─ .curated-docs-repo-builder/projects/vercel-next.js/curation.yaml
│  └─ Validate against docs-specific constraints
│
└─ Copy/filter docs to .knowledge/curated-docs-repo/vercel-next.js/

OUTPUT: .knowledge/curated-docs-repo/vercel-next.js/ (curated documentation)
```

### Workflow 3: Curate Docs from Website

```
USER INVOKES:
"read .curated-docs-web-builder/PROMPT.md with https://nextjs.org/docs"

↓

AGENT READS PROMPT.MD
├─ Parse URL → domain=nextjs.org, path=/docs
├─ Check: Does .knowledge/full-docs-website/nextjs.org/ exist?
│  ├─ NO → Execute: .full-docs-website-sync/sync.sh https://nextjs.org/docs
│  │        └─ Scrapes to .knowledge/full-docs-website/nextjs.org/
│  └─ YES → Continue
│
├─ Run web docs curation analysis
│  ├─ Identify content vs. boilerplate
│  ├─ Apply web-specific criteria:
│  │  ├─ KEEP: Documentation content (markdown, MDX, converted HTML)
│  │  ├─ EXCLUDE: Navigation, footers, sidebars, ads, tracking
│  ├─ Generate artifacts:
│  │  ├─ .curated-docs-web-builder/projects/nextjs.org/curated-tree.json
│  │  └─ .curated-docs-web-builder/projects/nextjs.org/curation.yaml
│  └─ Validate
│
└─ Copy/filter content to .knowledge/curated-docs-web/nextjs.org/

OUTPUT: .knowledge/curated-docs-web/nextjs.org/ (curated web docs)
```

---

## 🔌 System Responsibilities

### `.knowledge-builder/full-repo-sync/sync.sh`

**Purpose**: Maintain pristine GitHub repository clones

**Interface**:
```bash
.knowledge-builder/full-repo-sync/sync.sh <github-url> [--branch=BRANCH] [--force]
```

**Behavior**:
1. Parse `{owner}` and `{repo}` from URL
2. Read `.knowledge/full-repo/MANIFEST.yaml`
3. Check if entry exists:
   - **Missing**: Clone fresh
   - **Exists + fresh (<7 days)**: Skip unless --force
   - **Exists + stale (>7 days)**: Pull updates
4. Clone/pull with specified or default branch
5. Update MANIFEST.yaml with:
   - name, url, branch, last_synced timestamp, latest commit SHA
6. Always clone full repo (no sparse checkout)

**Dependencies**: git, yq (for YAML manipulation)

**Error Handling**:
- Invalid URL: exit with error
- Network failure: exit with error
- Git conflicts: report to user (manual intervention required)
- MANIFEST.yaml missing: create it

---

### `.knowledge-builder/full-docs-website-sync/sync.sh`

**Purpose**: Maintain pristine website scrapes

**Interface**:
```bash
.knowledge-builder/full-docs-website-sync/sync.sh <website-url> [--scraper=httrack|crawl4ai|both] [--force]
```

**Behavior**:
1. Parse domain from URL
2. Read `.knowledge/full-docs-website/MANIFEST.yaml`
3. Check if entry exists:
   - **Missing**: Scrape fresh with both tools
   - **Exists + fresh (<30 days)**: Skip unless --force
   - **Exists + stale (>30 days)**: Re-scrape
4. Scrape based on --scraper flag (default: both):
   - **httrack**: Complete offline mirror → `{domain}/httrack/`
   - **crawl4ai**: Markdown extraction → `{domain}/crawl4ai/`
   - **both**: Run both scrapers (recommended)
5. Update MANIFEST.yaml with:
   - name, url, last_synced timestamp, scraper(s) used

**Tools**:
- `httrack`: Pristine HTML mirror, offline browsable
- `crawl4ai`: AI-powered content extraction to markdown

**Dependencies**: httrack, crawl4ai (Python package), yq

**Error Handling**:
- Invalid URL: exit with error
- Network failure: exit with error
- Scraping blocked (403, captcha): report to user, suggest manual intervention
- MANIFEST.yaml missing: create it

---

### `.knowledge-builder/curated-code-repo-builder/` (Migrated from `.context-builder/`)

**Purpose**: Create minimal, code-only context for specialist agents

**Input**: GitHub URL (via PROMPT.md invocation)

**Upstream Dependency**: `.knowledge/full-repo/{owner}-{repo}/`
- Checks `.knowledge/full-repo/MANIFEST.yaml` for entry
- If missing or stale, calls `.knowledge-builder/full-repo-sync/sync.sh {url}` first

**Curation Criteria** (from CONSTRAINTS.md):
- ✅ KEEP: Implementation code (src/, lib/, packages/*/src/, core/, pkg/, cmd/)
- ✅ KEEP: Manifests (package.json, go.mod, etc.)
- ✅ KEEP: Navigation files (index.*, router.*)
- ❌ EXCLUDE: Tests (`**/*.test.*`, `**/__tests__/**`, etc.)
- ❌ EXCLUDE: Docs (`docs/`, `**/*.md` except LICENSE/NOTICE)
- ❌ EXCLUDE: Build outputs (dist/, build/, node_modules/)
- ❌ EXCLUDE: Media, vendored code, compiled files

**Output**: `.knowledge/curated-code-repo/{owner}-{repo}/` (sparse checkout)

**Meta/Planning**: `.knowledge-builder/curated-code-repo-builder/projects/{owner}-{repo}/`

**Migration Changes**:
- Moved `.context-builder/` → `.knowledge-builder/curated-code-repo-builder/`
- Updated paths: `.context/` → `.knowledge/curated-code-repo/`
- Added MANIFEST.yaml check in PROMPT.md (step 0)
- Simplified README.md

---

### `.curated-docs-repo-builder/` (NEW)

**Purpose**: Curate documentation from GitHub repositories

**Input**: GitHub URL (via PROMPT.md invocation)

**Upstream Dependency**: `.knowledge/full-repo/{owner}-{repo}/`
- If missing, calls `.full-repo-sync/sync.sh {url}` first

**Curation Criteria** (docs-specific):
- ✅ KEEP: Documentation content (docs/, documentation/, website/content/)
- ✅ KEEP: Tutorials, guides, API references, examples within docs
- ✅ KEEP: Markdown, MDX, code samples in docs
- ❌ EXCLUDE: Website rendering code (React components for docs site)
- ❌ EXCLUDE: Build configs (next.config.js in docs site)
- ❌ EXCLUDE: Tests for documentation
- ❌ EXCLUDE: node_modules, build outputs

**Philosophy**: Keep content that helps understand the library, exclude website boilerplate

**Output**: `.knowledge/curated-docs-repo/{owner}-{repo}/`

**Meta/Planning**: `.curated-docs-repo-builder/projects/{owner}-{repo}/`

**Relationship to Code**: Same repo may appear in both `curated-code/` and `curated-docs-gh/`
- Example: `vercel-next.js` could have:
  - `.knowledge/curated-code-repo/vercel-next.js/` (implementation)
  - `.knowledge/curated-docs-repo/vercel-next.js/` (documentation)
  - Both sourced from same `.knowledge/full-repo/vercel-next.js/`

---

### `.curated-docs-web-builder/` (NEW)

**Purpose**: Curate documentation from official websites

**Input**: Website URL (via PROMPT.md invocation)

**Upstream Dependency**: `.knowledge/full-docs-website/{domain}/`
- If missing, calls `.full-docs-website-sync/sync.sh {url}` first

**Curation Criteria** (web-specific):
- ✅ KEEP: Documentation content (articles, guides, API refs)
- ✅ KEEP: Code examples, tutorials
- ✅ KEEP: Converted to markdown/clean format
- ❌ EXCLUDE: Navigation, headers, footers
- ❌ EXCLUDE: Ads, tracking scripts, analytics
- ❌ EXCLUDE: Duplicate content (same page in multiple formats)
- ❌ EXCLUDE: Marketing pages (pricing, about, etc.)

**Philosophy**: Extract pure documentation content, discard website chrome

**Output**: `.knowledge/curated-docs-web/{domain}/`

**Meta/Planning**: `.curated-docs-web-builder/projects/{domain}/`

**Challenge**: HTML → structured docs (may need conversion tools)

---

## 🔗 Cross-System Relationships

### Same Repo, Multiple Resources

A single project (e.g., Next.js) may have:

```
.knowledge/
├── full-repo/vercel-next.js/          # Pristine clone (shared source)
├── curated-code/vercel-next.js/       # Code curation
└── curated-docs-gh/vercel-next.js/    # Docs curation

# Both curations source from same full-repo clone
```

**No coupling**: Each curation is independent, just happens to share upstream source.

### Docs: GitHub vs. Web

A library may have docs in both places:

```
.knowledge/
├── curated-docs-gh/vercel-next.js/    # Docs from next.js GitHub repo
└── curated-docs-web/nextjs.org/       # Docs from nextjs.org website

# These are SEPARATE resources, may have different content
```

**When to use which**:
- Use GitHub docs if repo has comprehensive docs/ directory
- Use web docs if official site is the canonical source
- May keep both if they differ significantly

---

## 📋 Naming Conventions

### GitHub Repositories

**Pattern**: `{owner}-{repo}` (lowercase, hyphenated)

**Examples**:
- `https://github.com/vercel/next.js` → `vercel-next.js`
- `https://github.com/facebook/react` → `facebook-react`
- `https://github.com/Effect-TS/effect` → `effect-ts-effect`

**Applied to**:
- `.knowledge/full-repo/{owner}-{repo}/`
- `.knowledge/curated-code-repo/{owner}-{repo}/`
- `.knowledge/curated-docs-repo/{owner}-{repo}/`
- `.curated-code-repo-builder/projects/{owner}-{repo}/`
- `.curated-docs-repo-builder/projects/{owner}-{repo}/`

### Websites

**Pattern**: `{domain}` (preserve dots, lowercase)

**Examples**:
- `https://nextjs.org/docs` → `nextjs.org`
- `https://react.dev` → `react.dev`
- `https://docs.expo.dev` → `docs.expo.dev`

**Applied to**:
- `.knowledge/full-docs-website/{domain}/`
- `.knowledge/curated-docs-web/{domain}/`
- `.curated-docs-web-builder/projects/{domain}/`

---

## 🎭 Agent Usage Patterns (Out of Scope)

**Note**: How specialist agents USE these resources is NOT the concern of this system. This system only PRODUCES the resources.

**Examples of agent usage** (for context, not implementation):
- Single specialist: "nextjs-agent" loads `curated-code/vercel-next.js/`
- Dual consultation: Code agent + Docs agent both answer, then synthesize
- Pristine reference: Agent checks `full-repo/` for ground truth when uncertain

**This system's job**: Make resources available. Agent orchestration is separate.

---

## 🚧 Migration Path

### Phase 1: No Disruption (Keep Current System Working)

1. Create `.knowledge/` structure alongside existing `.context/`
2. Build new sync systems
3. Migrate `.context-builder/` → `.curated-code-repo-builder/` with dual output (to both `.context/` and `.knowledge/curated-code-repo/`)
4. Test with Effect-TS project

### Phase 2: Transition

1. Switch all curation to output only to `.knowledge/curated-code-repo/`
2. Symlink `.context/` → `.knowledge/curated-code-repo/` for backward compatibility (if needed)
3. Remove `.context/` once agents are updated

### Phase 3: Expansion

1. Add first docs-gh curation
2. Add first docs-web curation
3. Iterate based on usage

---

## ⚖️ Design Principles

### Independence

Each builder system is **completely independent**:
- Different META-BUILDER-PROMPT.md (different improvement concerns)
- Different PROMPT.md (different curation logic)
- Different CONTEXT.md and CONSTRAINTS.md (different goals)
- No agent works on multiple systems in one session

**Why**: Prevents context pollution, simplifies maintenance, allows evolution of each system independently.

### Simplicity

**Sync systems are dead simple**:
- `.full-repo-sync/`: Just git clone/pull, no logic
- `.full-docs-website-sync/`: Just scrape, no logic

**Why**: Complex sync systems break. Simple systems endure. All intelligence lives in curation, not sync.

### Single Invocation

**No manifest, no batch processing**:
- You manually invoke one URL at a time
- Full control over what gets added
- Easier to debug and understand

**Why**: Avoids complexity, gives you visibility, reduces failure modes.

### Upstream-First

**Always check for pristine source before curation**:
- Curation never works directly from GitHub/web
- Always works from local pristine copy
- Pristine copy is updated via sync scripts

**Why**: Reproducibility, offline capability, consistent source of truth.

### Qualitative Over Quantitative

**All curation decisions based on value, not size**:
- Code: "Does this enable library-maintainer thinking?"
- Docs: "Does this help understand how to use the library?"
- Web: "Is this actual content vs. website chrome?"

**Why**: Size is outcome, not constraint. Right size = achieves the goal.

---

## ✅ Finalized Design Decisions

### 1. Manifest System for Upstream Tracking

**Decision**: MANIFEST.yaml files in `full-repo/` and `full-docs-website/`

**Format**:
```yaml
# .knowledge/full-repo/MANIFEST.yaml
repos:
  - name: vercel-next.js
    url: https://github.com/vercel/next.js
    branch: canary
    last_synced: 2025-11-08T17:25:00Z
    commit: abc123def456...

# .knowledge/full-docs-website/MANIFEST.yaml
websites:
  - name: nextjs.org
    url: https://nextjs.org/docs
    last_synced: 2025-11-08T17:30:00Z
    scraper: httrack  # or crawl4ai or both
    notes: "Uses both httrack (pristine) and crawl4ai (pre-filtered)"
```

**Benefits**:
- Check existence without filesystem operations
- Track staleness for smart re-sync
- Record metadata (branch, commit, scraper used)

### 2. Website Scraping: Both httrack AND crawl4ai

**Decision**: Implement both scrapers, let curation use both outputs

**Rationale**:
- **httrack**: Truly pristine, offline-capable, everything preserved
- **crawl4ai**: Pre-filtered markdown, faster to curate
- Curation agent can reference both to ensure nothing important lost

**Implementation**:
```bash
# Scrape with both tools
.knowledge-builder/full-docs-website-sync/sync.sh https://nextjs.org --scraper=both
# Creates:
# - .knowledge/full-docs-website/nextjs.org/httrack/  (complete HTML)
# - .knowledge/full-docs-website/nextjs.org/crawl4ai/ (markdown)
```

### 3. Docs Output Format: Preserve Source Format

**Decision**: Keep original formats in curated output

- Docs-GH: Preserve as-is (.md, .mdx, .rst, whatever exists)
- Docs-Web (httrack): Keep HTML
- Docs-Web (crawl4ai): Keep markdown

**Rationale**: Agents are multimodal and can parse various formats. Don't force conversion - let curation remove noise, not standardize format.

### 4. Branch Tracking: Flexible with Sensible Defaults

**Decision**: Support `--branch` flag, default to main/master

```bash
# Defaults to main/master/default branch
.knowledge-builder/full-repo-sync/sync.sh https://github.com/vercel/next.js

# Explicit branch override
.knowledge-builder/full-repo-sync/sync.sh https://github.com/vercel/next.js --branch=canary
```

**Rationale**: Minimal complexity - just pass branch to git. No multi-branch tracking unless explicitly invoked. MANIFEST records which branch per repo.

### 5. Update Strategy: Smart Manual Sync

**Decision**: Manual trigger with intelligent staleness checks

**Staleness Thresholds**:
- Repos: 7 days
- Websites: 30 days

**Behavior**:
```
When curation starts:
  ├─ Read MANIFEST
  ├─ If entry missing → sync.sh (first time)
  ├─ If last_synced > threshold → sync.sh (stale)
  └─ If fresh → use existing
```

**Manual override**:
```bash
# Force re-sync regardless of staleness
.knowledge-builder/full-repo-sync/sync.sh {url} --force
```

**Rationale**: No cron complexity. Smart enough to stay fresh. Manual control when needed.

---

## ✅ Success Criteria

### System Works When:

1. **Code curation**: Can invoke with GitHub URL, get minimal code-only output
2. **Docs-GH curation**: Can invoke with GitHub URL, get curated docs without website boilerplate
3. **Docs-Web curation**: Can invoke with website URL, get clean documentation content
4. **Independence**: Each system can be improved without affecting others
5. **Maintainability**: You actually use and maintain it (not too burdensome)
6. **Agent-ready**: Outputs are suitable for specialist agents to consume

### Migration Succeeds When:

1. Current Effect-TS project still works after migration
2. `.context-builder/` → `.curated-code-repo-builder/` transition is seamless
3. No loss of existing curation quality

---

## 📝 Next Steps (After Design Approval)

1. **Review this document**: Correct any misunderstandings, answer open questions
2. **Phase 2: Build sync systems** (simple, low-risk)
3. **Phase 3: Migrate current system** (careful, test thoroughly)
4. **Phase 4: Build new curation systems** (one at a time)
5. **Phase 5: End-to-end testing**

---

## 🔄 Document Status

- **Version**: 1.1 (Finalized)
- **Status**: ✅ Ready for Implementation
- **Next Steps**: Begin Phase 2 - Build sync systems

---

## 📋 Implementation Summary

### What We're Building

A knowledge curation system with 3 resource types:
1. **Curated Code** - Minimal implementation code for specialist agents
2. **Curated Docs (GitHub)** - Documentation from repos, without website boilerplate
3. **Curated Docs (Web)** - Clean docs from official sites, without chrome

### Key Features

- **Manifest tracking** for smart staleness detection
- **Dual scraping** (httrack + crawl4ai) for comprehensive web docs
- **Format preservation** (no forced conversions)
- **Branch flexibility** with sensible defaults
- **Independent systems** - each builder completely isolated

### Directory Organization

```
/Users/MN/GITHUB/
├── .knowledge/                    # All resources (5 subdirs)
└── .knowledge-builder/            # All infrastructure (5 systems + ARCHITECTURE.md)
```

Clean separation: resources vs. infrastructure, all under `.knowledge-builder/` umbrella.
