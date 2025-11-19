One-Shot Specialist Curation Prompt
====================================

MISSION
-------
Create a minimal, code-only knowledge base for ONE specialist AI agent from a GitHub repository.

MANDATORY READS (Before Starting)
- `/Users/MN/GITHUB/.knowledge-builder/curated-code-builder/CONTEXT.md` — Vision and goals
- `/Users/MN/GITHUB/.knowledge-builder/curated-code-builder/CONSTRAINTS.md` — Invariants and rules you MUST follow

ACKNOWLEDGEMENT (Required)
- Before any action, print EXACTLY this single line:
  ACK: ReadConstraints→Scaffold→Snapshot→Analyze→Derive→Validate→Clone→Verify

CRITICAL INVARIANTS (From CONSTRAINTS.md)
------------------------------------------
1. `.knowledge/curated-code/` contains ONLY code (no docs, tests, or meta files)
2. Each curated repo serves ONE specialist agent exclusively
3. Schema MUST be canonical (see section 4)
4. Reasons MUST be one of three exact formats (see section 4.1)
5. NO test files in output (validated post-clone)
6. Size is an OUTCOME of qualitative decisions, NOT a constraint

Inputs
------
- REPO_URL: GitHub URL (e.g., `https://github.com/<owner>/<repo>`)

**IMPORTANT: All paths in this prompt are ABSOLUTE paths starting with /**
Derived Paths (compute, don't ask)
-----------------------------------
- BUILDER_ROOT = `/Users/MN/GITHUB/.knowledge-builder/curated-code-builder`
- KNOWLEDGE_ROOT = `/Users/MN/GITHUB/.knowledge`
- FULL_REPO_DIR = `${KNOWLEDGE_ROOT}/full-repo`
- CURATED_CODE_DIR = `${KNOWLEDGE_ROOT}/curated-code`
- OWNER, REPO = parse from REPO_URL (lowercase, hyphenated)
- REPO_NAME = `${OWNER}-${REPO}`
- DEST = `${CURATED_CODE_DIR}/${REPO_NAME}`
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
   - Read `/Users/MN/GITHUB/.knowledge-builder/curated-code-builder/CONSTRAINTS.md` in full
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
   - If local clone has issues: Step 0 should have ensured pristine clone exists

4) ANALYZE & DERIVE PATTERNS

   4.1) Compute sizes
   - Calculate directory sizes from tree
   - Identify largest subtrees and files
   - Flag files >500KB for review (potential bundles)

   4.2) Identify runtime code
   - Source directories: `src/`, `lib/`, `packages/*/src/`, `app/`, `core/`, `pkg/`, `cmd/`
   - Must be adjacent to manifest: `package.json`, `pyproject.toml`, `go.mod`, etc.
   - Navigation files: `index.*`, `router.*`, `registry.*` (help agents understand structure)

   4.3) Build explicit patterns
   - ALLOWLIST (what to keep):
     * Core source directories: `src/`, `lib/`, `packages/*/src/`, `app/`, `core/`, `pkg/`, `cmd/`
     * Be specific: `packages/next/src/**` not `packages/next/**`
     * Include root: manifest files, configuration (exclude *.md files)
   - DENYLIST (what to exclude):
     * Tests: `**/__tests__/**`, `**/test/**`, `**/tests/**`, `**/*.test.*`, `**/*.spec.*`, `**/*.snap`
     * Build: `dist/**`, `build/**`, `out/**`, `target/**`, `compiled/**`
     * Vendor: `node_modules/**`, `vendor/**`, `.venv/**`, `__pycache__/**`
     * Docs: `docs/**`, `doc/**`, `documentation/**`, `website/**`, `examples/**`, `demos/**`, `**/*.md` (except LICENSE/NOTICE)
     * CI: `.github/**`, `.gitlab/**`, `.circleci/**`
     * Media/Large files: `**/*.min.*`, binaries, images, videos

   4.4) Apply QUALITATIVE inclusion criteria
   - Every file/directory decision based on: "Does this enable library-maintainer level thinking?"
   - ✅ INCLUDE: Implementation code, internal utilities, architectural patterns, core logic
   - ❌ EXCLUDE: Tests, docs, examples, demos, build outputs, media, vendored dependencies
   - Size is an OUTCOME, not a constraint - the RIGHT size = whatever achieves specialist expertise
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
   - MANDATORY: End with global test exclusions:
   ```
   # MANDATORY GLOBAL EXCLUSIONS (DO NOT OMIT)
   !**/__tests__/**
   !**/test/**
   !**/tests/**
   !**/*.test.*
   !**/*.spec.*
   !**/*.snap
   !**/__mocks__/**
   !**/fixtures/**
   !docs/**
   !doc/**
   !documentation/**
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
   - Global test exclusions MUST be present
   - For each `mixed` dir: child entries MUST exist

   6.3) Pattern validation
   - Every keep/omit decision MUST cite a pattern
   - No "Outside include patterns" for top-level dirs

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
   find ${DEST} -type f \( -name "*.test.*" -o -name "*.spec.*" \) | wc -l
   ```
   MUST return 0. If not, fix sparse-checkout and re-clone.

   8.2) Documentation check (MUST PASS)
   ```bash
   find ${DEST} -type d \( -name "docs" -o -name "doc" -o -name "documentation" \) | wc -l
   ```
   MUST return 0. Docs are extracted separately, not included in code context.

   8.3) Size awareness (NOT a constraint)
   ```bash
   du -sh ${DEST}
   ```
   Report the size. Large size is FINE if it's all implementation code.
   Check for missed exclusions if unusually large (vendor, build, generated files).

   8.4) File count awareness
   ```bash
   find ${DEST} -type f | wc -l
   ```
   Report the count. High count is FINE if files contain implementation knowledge.

   8.5) Top subtrees report
   Print top 10 directories by size. Verify they contain implementation code, not excluded categories.

9) SPECIALIST READINESS CHECK
   Ask: "Does this give a specialist agent everything needed to think like a library maintainer?"
   - Can the specialist understand internal architecture?
   - Are key patterns and idioms preserved?
   - Is the API surface complete?

   If NO to any: adjust patterns and regenerate.

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
     Read /Users/MN/GITHUB/.knowledge/curated-code/SPECIALIST-META-PROMPT.md with KB_PATH=${DEST}

     Focus specifically on: Common usage patterns, typical workflows, and frequent use cases.

     Write your complete SPECIALIST-PROMPT.md proposal to:
     ${DEST}/.curation/specialist-proposals/proposal-1-sonnet-usage.md
     """

   Task 2 (Sonnet - Troubleshooting):
     model: "sonnet"
     subagent_type: "general-purpose"
     description: "Generate specialist prompt focusing on troubleshooting"
     prompt: """
     Read /Users/MN/GITHUB/.knowledge/curated-code/SPECIALIST-META-PROMPT.md with KB_PATH=${DEST}

     Focus specifically on: Troubleshooting guidance, error handling, and edge cases.

     Write your complete SPECIALIST-PROMPT.md proposal to:
     ${DEST}/.curation/specialist-proposals/proposal-2-sonnet-troubleshooting.md
     """

   Task 3 (Sonnet - Integration):
     model: "sonnet"
     subagent_type: "general-purpose"
     description: "Generate specialist prompt focusing on integration"
     prompt: """
     Read /Users/MN/GITHUB/.knowledge/curated-code/SPECIALIST-META-PROMPT.md with KB_PATH=${DEST}

     Focus specifically on: Integration patterns, best practices, and ecosystem compatibility.

     Write your complete SPECIALIST-PROMPT.md proposal to:
     ${DEST}/.curation/specialist-proposals/proposal-3-sonnet-integration.md
     """

   Task 4 (Opus - Comprehensive Capabilities):
     model: "opus"
     subagent_type: "general-purpose"
     description: "Generate specialist prompt with comprehensive capability mapping"
     prompt: """
     Read /Users/MN/GITHUB/.knowledge/curated-code/SPECIALIST-META-PROMPT.md with KB_PATH=${DEST}

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
     Read /Users/MN/GITHUB/.knowledge/curated-code/SPECIALIST-META-PROMPT.md with KB_PATH=${DEST}

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
     Read /Users/MN/GITHUB/.knowledge/curated-code/SPECIALIST-META-PROMPT.md with KB_PATH=${DEST}

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
     - Must include concrete examples from the actual code

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
- If GitHub API is truncated: Note it, proceed, reconcile after clone
- If validation fails: MUST fix and re-validate, don't proceed
- If test files found post-clone: MUST fix sparse-checkout
- If docs directories found post-clone: MUST fix sparse-checkout

SUCCESS CRITERIA
----------------
✅ Zero test files in `.context/`
✅ Zero docs/doc/documentation directories in `.context/`
✅ Canonical schema with proper reasons
✅ sparse-checkout has global exclusions
✅ Specialist agent has comprehensive domain knowledge
✅ Every included file serves the goal: "library-maintainer level thinking"

OUTPUT LOCATIONS
----------------
- **Curated code**: `${DEST}/` (sparse clone)
- **Planning/meta**: `${PROJECT_DIR}/` (JSON + YAML)
- **API snapshot**: `${SNAPSHOT_DIR}/github-api-tree.json` (shared)

FORBIDDEN ACTIONS
-----------------
- NO Markdown files in `.context/`
- NO custom reason strings
- NO test files in output
- NO asking user for paths/branches
- NO proceeding past failed validation