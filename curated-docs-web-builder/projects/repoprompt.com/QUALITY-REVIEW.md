# RepoPrompt Curation - Quality Review Report

**Review Date:** 2025-11-10  
**Reviewer:** Claude Code (Automated QA)  
**Domain:** repoprompt.com

---

## Executive Summary

**QUALITY RATING: POOR**  
**RECOMMENDATION: FIX_AND_RETRY**

The curation captured all unique content from the source (100% coverage) but **failed to remove duplicates**. Out of 34 files curated, only 11 contain unique content, resulting in a **67.6% duplication rate**. This is unacceptable for specialist agent training.

---

## 1. Content Quality Assessment

### Files Sampled (8 random files):
1. ✅ `applying-changes/apply-mode.md` - Real documentation (Advanced Workspace Management)
2. ✅ `quick-start/installation.md` - Real documentation (Quick Start guide)
3. ✅ `pro-features/pro-mode.md` - Real documentation (Pro Features)
4. ✅ `core-concepts/multiple-workspaces.md` - Real documentation (Core Concepts)
5. ✅ `workspace-management/managing-workspaces.md` - Real documentation (duplicate!)
6. ✅ `quick-start/opening-workspace.md` - Real documentation (multi-section SPA page)
7. ✅ `changelog/version-1-0.md` - Real documentation (Changelog)
8. ✅ `quick-start/navigating-file-tree.md` - Real documentation (duplicate!)

### Content Quality: ✅ EXCELLENT
- **No website chrome detected** - All headers, footers, navigation removed
- **No marketing fluff** - Pure technical documentation
- **Clean formatting** - Frontmatter and breadcrumbs successfully stripped
- **Actionable content** - Tutorials, API guides, configuration instructions
- **Professional writing** - Clear, concise, developer-focused

### Content Issues: ❌ CRITICAL
- **Massive duplication**: 23 files are duplicates (67.6% duplication rate)
- **File mismatches**: Files contain wrong content (e.g., `getting-started/installation.md` contains Chat Mode content)
- **SPA aggregation**: Subsection files contain entire parent section content

---

## 2. Duplication Analysis

### Duplicate Groups Found:

1. **Pro Features (3 files - ALL IDENTICAL)**
   - `pro-features/pro-mode.md`
   - `pro-features/context-builder.md` ❌ DUPLICATE
   - `pro-features/mcp-integration.md` ❌ DUPLICATE

2. **Compose Mode (5 files - ALL IDENTICAL)**
   - `compose-mode/composing-prompts.md`
   - `compose-mode/filtering-files.md` ❌ DUPLICATE
   - `compose-mode/searching-files.md` ❌ DUPLICATE
   - `compose-mode/storing-prompts.md` ❌ DUPLICATE
   - `faq/cursor-windsurf-difference.md` ❌ DUPLICATE

3. **Quick Start (4 files - ALL IDENTICAL)**
   - `quick-start/getting-started.md`
   - `quick-start/installation.md` ❌ DUPLICATE
   - `quick-start/navigating-file-tree.md` ❌ DUPLICATE
   - `quick-start/opening-workspace.md` ❌ DUPLICATE

4. **Workspace Management (4 files - ALL IDENTICAL)**
   - `workspace-management/managing-workspaces.md`
   - `workspace-management/file-operations.md` ❌ DUPLICATE
   - `workspace-management/file-watching.md` ❌ DUPLICATE
   - `applying-changes/apply-mode.md` ❌ DUPLICATE

5. **FAQ/Troubleshooting (6 files - ALL IDENTICAL)**
   - `faq-troubleshooting/solo-project.md`
   - `faq-troubleshooting/manage-subscription.md` ❌ DUPLICATE
   - `faq-troubleshooting/mcp-troubleshooting.md` ❌ DUPLICATE
   - `faq-troubleshooting/pay-for-services.md` ❌ DUPLICATE
   - `faq-troubleshooting/prompt-caching.md` ❌ DUPLICATE
   - `faq-troubleshooting/windows-linux.md` ❌ DUPLICATE

6. **Core Concepts (3 files - ALL IDENTICAL)**
   - `core-concepts/code-maps.md`
   - `core-concepts/multiple-workspaces.md` ❌ DUPLICATE
   - `core-concepts/selection-methods.md` ❌ DUPLICATE

7. **Setup/Configuration (2 files - IDENTICAL)**
   - `setup-configuration/api-keys.md`
   - `setup-configuration/supported-models.md` ❌ DUPLICATE

8. **Overview (2 files - IDENTICAL)**
   - `overview/what-is-repo-prompt.md`
   - `overview/cursor-windsurf-difference.md` ❌ DUPLICATE

9. **Misc (2 files - IDENTICAL)**
   - `changelog/version-1-0.md`
   - `file-selection/context-builder.md` ❌ DUPLICATE (wrong content!)

10. **Chat Mode (2 files - IDENTICAL)**
    - `getting-started/installation.md`
    - `chat-mode/multi-file-edits.md` ❌ DUPLICATE

### Root Cause:
**SPA Hash Routing** - The website serves the ENTIRE section for all hash-based subsection routes:
- `https://repoprompt.com/docs#s=quick-start&ss=installation` → Entire Quick Start section
- `https://repoprompt.com/docs#s=quick-start&ss=getting-started` → Entire Quick Start section (identical)
- `https://repoprompt.com/docs#s=quick-start&ss=navigating-file-tree` → Entire Quick Start section (identical)

### Deduplication Failure:
The curation process **detected duplicates but failed to remove them**. The deduplication logic used incorrect MD5 hashing (bash `tail -n +9` failed) and didn't validate the output.

---

## 3. Completeness Verification

### Source vs Curated:
- ✅ **Source files:** 43 total, **11 unique**
- ✅ **Curated files:** 34 total, **11 unique**
- ✅ **Content coverage:** 100% - All unique source content present

### Actual Unique Content (11 pieces):
1. ✅ **Compose Mode** - 6,937 chars - Workflow for external AI services
2. ✅ **Core Concepts** - 6,281 chars - Workspaces, file selection, code maps
3. ✅ **External Integration** - 2,516 chars - Apply Mode for external AI
4. ✅ **FAQ & Troubleshooting** - 13,362 chars - Common questions and troubleshooting
5. ✅ **Changelog** - 16,782 chars - Version history (1.0-1.3)
6. ✅ **Chat Mode** - 5,547 chars - Integrated AI chat fundamentals
7. ✅ **Overview** - 8,738 chars - What is RepoPrompt, vs Cursor/Windsurf
8. ✅ **Pro Features** - 15,472 chars - Pro Mode, Context Builder, MCP server
9. ✅ **Quick Start** - 4,401 chars - Installation, first workspace
10. ✅ **Setup & Configuration** - 4,630 chars - AI providers, API keys
11. ✅ **Advanced Workspace Management** - 7,575 chars - File operations, URL scheme

### Missing Content: ✅ NONE
All major sections are present and complete.

### File Naming Issues: ❌ CRITICAL
- `file-selection/context-builder.md` contains **Changelog** content (should be changelog/index.md)
- `getting-started/installation.md` contains **Chat Mode** content (should be chat-mode/index.md)
- Subsection files contain parent section content instead of subsection-specific content

---

## 4. Specialist Agent Usability

### Can a specialist learn from these docs? ✅ YES (content-wise)

**Content is excellent:**
- ✅ Installation & setup instructions
- ✅ Feature explanations (Workspace, File Selection, Code Maps, Pro Mode, MCP)
- ✅ Configuration guides (API keys, models)
- ✅ Advanced features (Context Builder, Multi-model workflows)
- ✅ Troubleshooting guides
- ✅ Integration patterns (URL scheme, external editors)
- ✅ Technical architecture details (MCP protocol, tree-sitter, parallel processing)

**BUT the duplication ruins it:**
- ❌ Agent would see the same content 3-6 times in different files
- ❌ Confusing file structure (wrong content in wrong files)
- ❌ Wasted tokens (3x token cost for same information)
- ❌ Training confusion (agent learns incorrect file → content mappings)

### Example Problems:

**Problem 1: Incorrect Content Mapping**
```
Agent query: "Show me the changelog"
File: file-selection/context-builder.md
Actual content: Full changelog (correct) but wrong filename!

Agent query: "How do I install RepoPrompt?"
File: getting-started/installation.md
Actual content: Chat Mode fundamentals (WRONG!)
```

**Problem 2: Massive Redundancy**
```
Agent reads: pro-features/pro-mode.md (15KB)
Agent reads: pro-features/context-builder.md (15KB - IDENTICAL)
Agent reads: pro-features/mcp-integration.md (15KB - IDENTICAL)
Total: 45KB to learn what should be 15KB
```

### Usability Rating: ❌ POOR
Content is high quality but duplication makes it unsuitable for agent training.

---

## 5. Detailed Issues

### Critical Issues (Must Fix):

1. **❌ 67.6% duplication rate** (23/34 files are duplicates)
   - Expected: 0% after deduplication
   - Actual: 67.6%
   - Impact: Wastes 3x tokens, confuses training

2. **❌ Wrong content in wrong files**
   - `file-selection/context-builder.md` → Contains Changelog
   - `getting-started/installation.md` → Contains Chat Mode
   - Impact: Breaks semantic file structure

3. **❌ Subsection files contain full parent section**
   - `quick-start/installation.md` → Full Quick Start (Getting Started + Installation + Workspace + File Tree)
   - Expected: Just Installation subsection
   - Impact: Agent can't distinguish subsections

### Minor Issues:

4. **⚠️ File naming mismatch**
   - Filenames suggest subsections but content is full sections
   - Should either: (a) Keep only section index files, OR (b) Actually split content by subsection

5. **⚠️ No index.md files**
   - Each section served as one blob
   - Should have: `quick-start/index.md` instead of 4 identical subsection files

---

## 6. Root Cause Analysis

### Why Deduplication Failed:

1. **Incorrect MD5 hashing during curation**
   - Used bash `tail -n +9` which failed in subshell
   - Hash check returned empty/wrong results
   - Duplicates weren't detected

2. **No post-copy validation**
   - Copied all files from selection manifest
   - Didn't verify uniqueness after copy
   - Assumed pre-copy deduplication worked

3. **SPA complexity underestimated**
   - Hash routing serves full section for all subsections
   - Playwright scraper couldn't distinguish subsections
   - Each hash route got saved as separate file with identical content

### What Went Right:

✅ Frontmatter stripping worked perfectly  
✅ Breadcrumb removal successful  
✅ Chrome removal successful (0 nav files)  
✅ Content quality excellent  
✅ 100% content coverage achieved  
✅ All major sections present  

### What Went Wrong:

❌ Deduplication logic broken  
❌ No post-copy validation  
❌ Kept 34 files when should have kept 11  

---

## 7. Recommended Fix

### Strategy: **RE-CURATE WITH PROPER DEDUPLICATION**

1. **Delete current curated output**
   ```bash
   rm -rf /Users/MN/GITHUB/.knowledge/curated-docs-web/repoprompt.com/*
   ```

2. **Copy only unique files** (11 files total)
   - Use Python to detect content hashes AFTER processing (frontmatter removed)
   - Keep first occurrence of each unique hash
   - Skip all duplicates

3. **Rename files to match content**
   - `file-selection/context-builder.md` → `changelog/index.md`
   - `getting-started/installation.md` → `chat-mode/index.md`
   - Create section-level `index.md` files instead of subsection files

4. **Validate post-copy**
   - Run duplicate detection on final output
   - Verify 11 unique files
   - Confirm 0% duplication

5. **Update artifacts**
   - Regenerate `curated-tree.json` with correct omit decisions
   - Update `selection-manifest.json` to only 11 files
   - Fix `curation.yaml` patterns

---

## 8. Final Verdict

### Quality Rating: **POOR**

| Criteria | Rating | Evidence |
|----------|--------|----------|
| Content Quality | ✅ EXCELLENT | Clean, actionable, professional documentation |
| Chrome Removal | ✅ EXCELLENT | 0 navigation files, 0 analytics, 0 marketing |
| Format Processing | ✅ EXCELLENT | Frontmatter and breadcrumbs removed |
| Completeness | ✅ EXCELLENT | 100% coverage of unique source content |
| **Deduplication** | **❌ FAILED** | **67.6% duplication rate (should be 0%)** |
| File Structure | ❌ POOR | Wrong content in wrong files |
| Specialist Usability | ❌ POOR | Duplicates ruin training effectiveness |

### Overall Assessment:
The curation **successfully extracted and cleaned all content**, but **catastrophically failed at deduplication**. The output contains 3x more files than necessary with massive redundancy that would confuse any specialist agent.

### Recommendation: **FIX_AND_RETRY**

**Do NOT use this output for specialist agent training.**

The curation must be re-run with proper deduplication to produce the expected **11 unique files** instead of 34 duplicated files.

---

## 9. Expected Final State

**Correct curated output should contain:**

```
repoprompt.com/
├── changelog.md                    # 16,782 chars - Version history
├── chat-mode.md                    # 5,547 chars - Integrated AI chat
├── compose-mode.md                 # 6,937 chars - External AI workflow
├── core-concepts.md                # 6,281 chars - Fundamentals
├── external-integration.md         # 2,516 chars - Apply Mode
├── faq-troubleshooting.md         # 13,362 chars - FAQ & troubleshooting
├── overview.md                     # 8,738 chars - What is RepoPrompt
├── pro-features.md                 # 15,472 chars - Pro Mode, Context Builder, MCP
├── quick-start.md                  # 4,401 chars - Installation & setup
├── setup-configuration.md          # 4,630 chars - AI providers & API keys
└── workspace-management.md         # 7,575 chars - Advanced workspace features
```

**Total: 11 files, 92,241 chars, 0% duplication**

---

## Appendix: Duplicate File List

Files to DELETE (23 duplicates):

```
pro-features/context-builder.md
pro-features/mcp-integration.md
compose-mode/filtering-files.md
compose-mode/searching-files.md
compose-mode/storing-prompts.md
faq/cursor-windsurf-difference.md
quick-start/getting-started.md
quick-start/installation.md
quick-start/navigating-file-tree.md
workspace-management/file-operations.md
workspace-management/file-watching.md
applying-changes/apply-mode.md
faq-troubleshooting/manage-subscription.md
faq-troubleshooting/mcp-troubleshooting.md
faq-troubleshooting/pay-for-services.md
faq-troubleshooting/prompt-caching.md
faq-troubleshooting/windows-linux.md
core-concepts/multiple-workspaces.md
core-concepts/selection-methods.md
setup-configuration/supported-models.md
overview/cursor-windsurf-difference.md
file-selection/context-builder.md
chat-mode/multi-file-edits.md
```

Files to KEEP and RENAME (11 unique):

```
compose-mode/composing-prompts.md → compose-mode.md
core-concepts/code-maps.md → core-concepts.md
external-integration/apply-mode.md → external-integration.md
faq-troubleshooting/solo-project.md → faq-troubleshooting.md
quick-start/opening-workspace.md → quick-start.md
setup-configuration/api-keys.md → setup-configuration.md
workspace-management/managing-workspaces.md → workspace-management.md
pro-features/pro-mode.md → pro-features.md
overview/what-is-repo-prompt.md → overview.md
getting-started/installation.md → chat-mode.md (RENAME - wrong filename!)
changelog/version-1-0.md → changelog.md (currently misnamed as file-selection/context-builder.md)
```
