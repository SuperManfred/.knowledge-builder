One-Shot Documentation Curation Prompt
=======================================

MISSION
-------
Create a comprehensive, clean documentation knowledge base for ONE specialist AI agent from a GitHub repository's documentation.

MANDATORY READS (Before Starting)
- `/Users/MN/GITHUB/.knowledge-builder/curated-docs-gh-builder/CONTEXT.md` — Vision and goals
- `/Users/MN/GITHUB/.knowledge-builder/curated-docs-gh-builder/CONSTRAINTS.md` — Invariants and rules you MUST follow

ACKNOWLEDGEMENT (Required)
- Before any action, print EXACTLY this single line:
  ACK: ReadConstraints→Scaffold→Snapshot→Analyze→Derive→Validate→Clone→Verify

CRITICAL INVARIANTS (From CONSTRAINTS.md)
------------------------------------------
1. `.knowledge/curated-docs-gh/` contains ONLY documentation content (no website code, tests, or build artifacts)
2. Each curated docs repo serves ONE specialist agent exclusively
3. Schema MUST be canonical (see section 5)
4. Reasons MUST be one of three exact formats (see section 5.1)
5. NO test files in output (validated post-clone)
6. Size is an OUTCOME of qualitative decisions, NOT a constraint

Inputs
------
- REPO_URL: GitHub URL (e.g., `https://github.com/<owner>/<repo>`)

**IMPORTANT: All paths in this prompt are ABSOLUTE paths starting with /**
Derived Paths (compute, don't ask)
-----------------------------------
- BUILDER_ROOT = `/Users/MN/GITHUB/.knowledge-builder/curated-docs-gh-builder`
- KNOWLEDGE_ROOT = `/Users/MN/GITHUB/.knowledge`
- FULL_REPO_DIR = `${KNOWLEDGE_ROOT}/full-repo`
- CURATED_DOCS_DIR = `${KNOWLEDGE_ROOT}/curated-docs-gh`
- OWNER, REPO = parse from REPO_URL (lowercase, hyphenated)
- REPO_NAME = `${OWNER}-${REPO}`
- DEST = `${CURATED_DOCS_DIR}/${REPO_NAME}`
- FULL_REPO_PATH = `${FULL_REPO_DIR}/${REPO_NAME}`
- BRANCH = default branch via GitHub API
- COMMIT = branch head SHA via GitHub API
- SNAPSHOT_DIR = `${BUILDER_ROOT}/snapshots/${REPO_NAME}/${COMMIT}`
- PROJECT_DIR = `${BUILDER_ROOT}/projects/${REPO_NAME}`

Workflow Steps
==============

0) CHECK UPSTREAM (Pristine Repo)
   - Read `${FULL_REPO_DIR}/MANIFEST.yaml`
   - Check if entry exists for `${REPO_NAME}`:
     - **Missing**: Execute `/Users/MN/GITHUB/.knowledge-builder/full-repo-sync/sync.sh ${REPO_URL}`
     - **Stale (>7 days)**: Execute `/Users/MN/GITHUB/.knowledge-builder/full-repo-sync/sync.sh ${REPO_URL}`
     - **Fresh (<7 days)**: Continue with existing
   - Verify `${FULL_REPO_PATH}/` exists after sync
   - This ensures we have a pristine clone to work from

1) READ CONSTRAINTS
   - Read `/Users/MN/GITHUB/.knowledge-builder/curated-docs-gh-builder/CONSTRAINTS.md` in full
   - Understand all INVARIANTS, RULES, and GUIDELINES

2) SCAFFOLD PROJECT
   - Run: `${BUILDER_ROOT}/tools/scaffold.sh ${REPO_URL} ${BRANCH}`
   - Move output to `${PROJECT_DIR}`

3) FETCH API SNAPSHOT
   - Use local pristine clone from `${FULL_REPO_PATH}`
   - Generate tree from local repository:
     ```bash
     cd ${FULL_REPO_PATH}
     git ls-tree -r -t --full-tree HEAD
     ```
   - Convert output to GitHub API tree format
   - Save to `${SNAPSHOT_DIR}/github-api-tree.json`

4) ANALYZE & DERIVE PATTERNS

   4.1) Compute sizes
   - Calculate directory sizes from tree
   - Identify largest subtrees and files
   - Focus on documentation directories

   4.2) Identify documentation directories
   - Common patterns: `docs/`, `documentation/`, `website/`, `content/`, `guides/`
   - Look for markdown/MDX files
   - Identify docs-specific assets (images, diagrams)
   - Navigation files within docs (for structure understanding)

   4.3) Build explicit patterns
   - ALLOWLIST (what to keep):
     * Documentation directories: `docs/**/*.md`, `docs/**/*.mdx`, `documentation/**/*.md`
     * Content directories: `content/**/*.md`, `guides/**/*.md`, `website/content/**/*.md`
     * Documentation assets: `docs/**/*.png`, `docs/**/*.svg`, `docs/**/*.jpg`, `docs/**/*.gif`
     * Code examples in docs: `docs/**/*.js`, `docs/**/*.ts` (if they're examples, not site code)
     * API references and generated docs
     * Root docs: `README.md` at repo root (but exclude in subdirs unless in docs/)

   - DENYLIST (what to exclude):
     * Website components: `docs/**/*.jsx`, `docs/**/*.tsx`, `docs/**/*.vue`, `website/components/**`
     * Build configs: `docs/next.config.js`, `docs/docusaurus.config.js`, `website/next.config.js`
     * Tests: `docs/**/*.test.*`, `docs/**/__tests__/**`, `docs/**/*.spec.*`, `test_*` (root-level test files)
     * Build outputs: `docs/dist/**`, `docs/build/**`, `docs/.next/**`, `docs/.docusaurus/**`
     * Node modules: `docs/node_modules/**`, `website/node_modules/**`, `**/node_modules/**`
     * CI/CD: `.github/**`, `.gitlab/**`, `.circleci/**`
     * Non-docs code: `src/**`, `lib/**`, `packages/**/src/**`, `crawl4ai/**` (source code dirs)
     * Non-docs markdown: `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`
     * Infrastructure at root: `Dockerfile`, `docker-compose.yml`, `.dockerignore`, `uv.lock`, `cliff.toml`, `.env*`, `MANIFEST.in`, `setup.py`, `setup.cfg`, `pyproject.toml`
     * Other: `scripts/**`, `bench/**`, `.vscode/**`, `.devcontainer/**`, `.changeset/**`, `patches/**`

   4.4) Apply QUALITATIVE inclusion criteria
   - Every file/directory decision based on: "Does this help an agent teach library usage?"
   - ✅ INCLUDE: Tutorials, guides, API docs, examples, concepts, diagrams
   - ❌ EXCLUDE: Website rendering code, build tools, tests, infrastructure
   - Size is an OUTCOME - comprehensive docs may be large, that's okay
   - Each micro-decision should be qualitative, not quantitative

5) GENERATE ARTIFACTS

   5.1) curated-tree.json (CANONICAL SCHEMA ONLY)
   ```json
   {
     "repo": "owner/repo",
     "branch": "main",
     "commit": "sha",
     "truncated": false,
     "entries": [
       {
         "path": "path/to/item",
         "node": "dir|file",
         "decision": "keep_all|omit_all|mixed|keep|omit",
         "reasons": ["<see below>"]
       }
     ]
   }
   ```

   **REASONS MUST BE EXACTLY ONE OF:**
   - `"Included by pattern '<actual_glob>'"`
   - `"Excluded by pattern '<actual_glob>'"`
   - `"Outside include patterns"`

   **ENTRIES RULES:**
   - Directory paths MUST end with `/`
   - File paths MUST NOT end with `/`
   - Sort by `path` alphabetically
   - For `mixed` directories: MUST include child entries

   5.2) sparse-checkout
   - Start with allowlist patterns
   - MANDATORY: End with global exclusions:
   ```
   # MANDATORY GLOBAL EXCLUSIONS (DO NOT OMIT)
   # Tests
   !**/__tests__/**
   !**/test/**
   !**/tests/**
   !**/*.test.*
   !**/*.spec.*
   !**/*.snap
   !/test_*

   # Build outputs and dependencies
   !**/node_modules/**
   !**/dist/**
   !**/build/**
   !**/.next/**
   !**/.docusaurus/**

   # Website code
   !**/*.tsx
   !**/*.jsx
   !/website/components/**
   !/website/src/**
   !/website/lib/**

   # Infrastructure at root
   !/Dockerfile
   !/docker-compose.yml
   !/uv.lock
   !/cliff.toml
   !/.env*
   !/MANIFEST.in
   !/setup.py
   !/setup.cfg
   !/pyproject.toml

   # Source code
   !/src/**
   !/lib/**
   !/packages/**/src/**
   !/crawl4ai/**

   # CI/CD
   !/.github/**
   !/.gitlab/**
   !/.circleci/**

   # Non-docs markdown
   !/CONTRIBUTING.md
   !/CODE_OF_CONDUCT.md
   !/SECURITY.md
   ```

   5.3) curation.yaml
   ```yaml
   repo: owner/repo
   branch: main
   commit: <actual_sha>
   date: <actual_YYYY-MM-DD>
   keep:
     - pattern1
     - pattern2
   exclude:
     - pattern3
     - pattern4
   ```

6) VALIDATION GATES (ABORT IF ANY FAIL)

   6.1) Schema validation
   - curated-tree.json MUST match canonical schema
   - Every reason MUST match one of three allowed formats
   - Paths must follow slash rules (dirs end with `/`)

   6.2) Consistency validation
   - sparse-checkout MUST be subset of keep decisions
   - Global exclusions MUST be present
   - For each `mixed` dir: child entries MUST exist

   6.3) Pattern validation
   - Every keep/omit decision MUST cite a pattern
   - Verify docs directories are being kept
   - Verify website infrastructure is being excluded

   **IF ANY VALIDATION FAILS:**
   - Print error details
   - Regenerate artifacts
   - Re-validate before proceeding

7) CLONE WITH SPARSE CHECKOUT
   - Clone to `${DEST}` using generated sparse-checkout
   - Depth=1, blobless for efficiency
   - Update if already exists

8) POST-CLONE VERIFICATION

   8.1) Test file check (MUST PASS)
   ```bash
   find ${DEST} -type f \( -name "*.test.*" -o -name "*.spec.*" -o -name "test_*" \) | wc -l
   ```
   MUST return 0 (or very low if test files are legitimate doc examples). If not, fix sparse-checkout and re-clone.
   NOTE: Test files WITHIN docs/ that are tutorial examples (showing how to test) are acceptable.

   8.2) Documentation check (MUST PASS)
   ```bash
   find ${DEST} -type d \( -name "docs" -o -name "documentation" -o -name "content" \) | wc -l
   ```
   MUST return >0. If not, curation missed docs directories - fix patterns.

   8.3) Website code check (SHOULD PASS)
   ```bash
   find ${DEST} -type f \( -name "*.tsx" -o -name "*.jsx" \) | wc -l
   ```
   SHOULD be 0 or very low. If high, check if website components were included.

   8.4) Infrastructure files check (SHOULD PASS)
   ```bash
   find ${DEST} -maxdepth 1 -type f \( -name "Dockerfile" -o -name "docker-compose.yml" -o -name "uv.lock" -o -name "setup.py" \) | wc -l
   ```
   SHOULD return 0. If not, infrastructure files were incorrectly included.

   8.5) Source code check (MUST PASS)
   ```bash
   find ${DEST} -type d \( -name "src" -o -name "lib" \) -not -path "*/docs/*" | wc -l
   ```
   MUST return 0. If not, source code directories were included.

   8.6) Size awareness (NOT a constraint)
   ```bash
   du -sh ${DEST}
   ```
   Report the size. Large size is FINE if it's comprehensive documentation.
   Check for missed exclusions if unusually large (node_modules, build outputs).

   8.7) File count awareness
   ```bash
   find ${DEST} -type f | wc -l
   ```
   Report the count. High count is FINE if it's complete documentation.

   8.8) Top subtrees report
   Print top 10 directories by size. Verify they contain documentation, not excluded categories.

9) SPECIALIST READINESS CHECK
   Ask: "Does this give a docs specialist agent everything needed to teach library usage?"
   - Can the specialist explain how to use the library?
   - Are tutorials, guides, and API docs complete?
   - Are code examples preserved?
   - Is website boilerplate removed?

   If NO to any: adjust patterns and regenerate.

   9.5) ANALYZE REPOSITORY COMMIT FREQUENCY

   **Track how actively this repository is developed to guide re-curation cadence:**

   ```bash
   cd ${FULL_REPO_PATH}

   # Count commits in last 3 months
   COMMITS_3MO=$(git log --since="3 months ago" --oneline --no-merges | wc -l)

   # Count commits in last 1 month
   COMMITS_1MO=$(git log --since="1 month ago" --oneline --no-merges | wc -l)

   # Calculate commits per month (average from 3-month window)
   COMMITS_PER_MONTH=$(echo "$COMMITS_3MO / 3" | bc)

   # Store in metadata
   cat >> ${DEST}/.curation/provenance.yaml << EOF
   commit_frequency:
     last_3_months: ${COMMITS_3MO}
     last_1_month: ${COMMITS_1MO}
     commits_per_month_avg: ${COMMITS_PER_MONTH}
     analyzed_at: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
   EOF
   ```

   **Report to user:**

   ```
   📊 Repository Activity Analysis:

   Commits (last 3 months): ${COMMITS_3MO}
   Commits (last month): ${COMMITS_1MO}
   Average: ~${COMMITS_PER_MONTH} commits/month

   Re-curation recommendation:
   - Low activity (<5 commits/month): Re-curate docs every 6 months
   - Moderate activity (5-20 commits/month): Re-curate docs every 2-3 months
   - High activity (>20 commits/month): Re-curate docs monthly

   This helps you decide when to refresh this documentation knowledge base.
   ```

10) GENERATE SPECIALIST-PROMPT.md (Multi-Agent)

   **10.1 - Create proposals directory:**

   ```bash
   mkdir -p ${DEST}/.curation/specialist-proposals
   ```

   **10.2 - Launch 6 parallel agents to generate proposals:**

   Invoke ALL 6 agents in a single message (parallel execution):

   ```
   Task 1 (Sonnet - Usage Patterns):
     model: "sonnet"
     subagent_type: "general-purpose"
     description: "Generate specialist prompt focusing on usage patterns"
     prompt: """
     Read /Users/MN/GITHUB/.knowledge/curated-docs-gh/SPECIALIST-META-PROMPT.md with KB_PATH=${DEST}

     Focus specifically on: Common usage patterns, typical workflows, and frequent use cases.

     Write your complete SPECIALIST-PROMPT.md proposal to:
     ${DEST}/.curation/specialist-proposals/proposal-1-sonnet-usage.md
     """

   Task 2 (Sonnet - Troubleshooting):
     model: "sonnet"
     subagent_type: "general-purpose"
     description: "Generate specialist prompt focusing on troubleshooting"
     prompt: """
     Read /Users/MN/GITHUB/.knowledge/curated-docs-gh/SPECIALIST-META-PROMPT.md with KB_PATH=${DEST}

     Focus specifically on: Troubleshooting guidance, error handling, and edge cases.

     Write your complete SPECIALIST-PROMPT.md proposal to:
     ${DEST}/.curation/specialist-proposals/proposal-2-sonnet-troubleshooting.md
     """

   Task 3 (Sonnet - Integration):
     model: "sonnet"
     subagent_type: "general-purpose"
     description: "Generate specialist prompt focusing on integration"
     prompt: """
     Read /Users/MN/GITHUB/.knowledge/curated-docs-gh/SPECIALIST-META-PROMPT.md with KB_PATH=${DEST}

     Focus specifically on: Integration patterns, best practices, and ecosystem compatibility.

     Write your complete SPECIALIST-PROMPT.md proposal to:
     ${DEST}/.curation/specialist-proposals/proposal-3-sonnet-integration.md
     """

   Task 4 (Opus - Comprehensive Capabilities):
     model: "opus"
     subagent_type: "general-purpose"
     description: "Generate specialist prompt with comprehensive capability mapping"
     prompt: """
     Read /Users/MN/GITHUB/.knowledge/curated-docs-gh/SPECIALIST-META-PROMPT.md with KB_PATH=${DEST}

     Focus specifically on: Complete capability inventory, feature coverage, and functional boundaries.
     Use reasoning to ensure comprehensive coverage.

     Write your complete SPECIALIST-PROMPT.md proposal to:
     ${DEST}/.curation/specialist-proposals/proposal-4-opus-capabilities.md
     """

   Task 5 (Opus - Knowledge Boundaries):
     model: "opus"
     subagent_type: "general-purpose"
     description: "Generate specialist prompt with precise knowledge boundaries"
     prompt: """
     Read /Users/MN/GITHUB/.knowledge/curated-docs-gh/SPECIALIST-META-PROMPT.md with KB_PATH=${DEST}

     Focus specifically on: What the specialist knows vs doesn't know, version coverage, and limitation acknowledgment.
     Use reasoning to define clear boundaries.

     Write your complete SPECIALIST-PROMPT.md proposal to:
     ${DEST}/.curation/specialist-proposals/proposal-5-opus-boundaries.md
     """

   Task 6 (Opus - Usage Scenarios):
     model: "opus"
     subagent_type: "general-purpose"
     description: "Generate specialist prompt with usage scenario modeling"
     prompt: """
     Read /Users/MN/GITHUB/.knowledge/curated-docs-gh/SPECIALIST-META-PROMPT.md with KB_PATH=${DEST}

     Focus specifically on: Real-world usage scenarios, project contexts, and implementation guidance.
     Use reasoning to model comprehensive scenarios.

     Write your complete SPECIALIST-PROMPT.md proposal to:
     ${DEST}/.curation/specialist-proposals/proposal-6-opus-scenarios.md
     """
   ```

   **10.3 - Synthesize with evaluator (7th agent):**

   After ALL 6 agents complete, invoke the synthesis agent:

   ```
   Task 7 (Opus - Synthesis):
     model: "opus"
     subagent_type: "general-purpose"
     description: "Synthesize final specialist prompt from 6 proposals"
     prompt: """
     You have 6 specialist prompt proposals in:
     ${DEST}/.curation/specialist-proposals/

     Read all 6 proposals:
     - proposal-1-sonnet-usage.md
     - proposal-2-sonnet-troubleshooting.md
     - proposal-3-sonnet-integration.md
     - proposal-4-opus-capabilities.md
     - proposal-5-opus-boundaries.md
     - proposal-6-opus-scenarios.md

     Your synthesis task:
     1. Identify the BEST elements from each proposal
     2. Combine complementary sections (don't duplicate)
     3. Choose the clearest wording when multiple versions exist
     4. Ensure comprehensive coverage without redundancy
     5. Preserve unique insights and specific examples

     Quality criteria:
     - Role definition must be crystal clear
     - Knowledge base contents must be accurately described
     - Capabilities must be comprehensive but realistic
     - Usage instructions must be actionable
     - Knowledge boundaries must be well-defined
     - Must include concrete examples from the actual docs

     Write the FINAL synthesized specialist prompt to:
     ${DEST}/SPECIALIST-PROMPT.md

     After writing, report which elements you took from which proposals.
     """
   ```

   **10.4 - Automatic cleanup:**

   ```bash
   # Verify final SPECIALIST-PROMPT.md exists
   if [ -f "${DEST}/SPECIALIST-PROMPT.md" ]; then
       echo "✅ SPECIALIST-PROMPT.md generated successfully"

       # Archive proposals
       tar -czf ${DEST}/.curation/specialist-proposals-archive.tar.gz \
           -C ${DEST}/.curation specialist-proposals/

       # Clean up proposal files
       rm -rf ${DEST}/.curation/specialist-proposals/
       echo "✅ Proposal files cleaned up (archived to specialist-proposals-archive.tar.gz)"
   else
       echo "❌ ERROR: SPECIALIST-PROMPT.md not found! Keeping proposals for debugging."
       echo "Check ${DEST}/.curation/specialist-proposals/ for the 6 proposals"
       exit 1
   fi
   ```

   **10.5 - Final validation:**

   ```bash
   # Verify specialist prompt is substantial
   PROMPT_SIZE=$(wc -l ${DEST}/SPECIALIST-PROMPT.md | awk '{print $1}')
   if [ $PROMPT_SIZE -lt 50 ]; then
       echo "⚠️ WARNING: SPECIALIST-PROMPT.md seems too short (${PROMPT_SIZE} lines)"
       echo "Consider reviewing the synthesis quality"
   fi

   echo "✅ Multi-agent specialist prompt generation complete!"
   echo "📍 Final prompt: ${DEST}/SPECIALIST-PROMPT.md"
   ```

   Print completion:
   ```
   ✅ CURATION COMPLETE
   ✅ SPECIALIST-PROMPT.md GENERATED (6-agent ensemble + synthesis)

   Resource ready: ${DEST}/
   ```

ERROR HANDLING
--------------
- If GitHub API is truncated: Note it, proceed, reconcile from local clone
- If validation fails: MUST fix and re-validate, don't proceed
- If test files found post-clone: MUST fix sparse-checkout
- If no docs directories found post-clone: MUST fix patterns

SUCCESS CRITERIA
----------------
✅ Zero test files in `.knowledge/curated-docs-gh/`
✅ At least one docs directory exists
✅ Canonical schema with proper reasons
✅ sparse-checkout has global exclusions
✅ Specialist agent has comprehensive usage documentation
✅ Every included file serves the goal: "teach library usage"
✅ Website rendering code excluded (React components, configs)

OUTPUT LOCATIONS
----------------
- **Curated docs**: `${DEST}/` (sparse clone)
- **Planning/meta**: `${PROJECT_DIR}/` (JSON + YAML)
- **API snapshot**: `${SNAPSHOT_DIR}/github-api-tree.json` (shared)

FORBIDDEN ACTIONS
-----------------
- NO website code in `.knowledge/curated-docs-gh/`
- NO custom reason strings
- NO test files in output
- NO asking user for paths/branches
- NO proceeding past failed validation
