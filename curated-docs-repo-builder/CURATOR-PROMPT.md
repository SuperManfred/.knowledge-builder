One-Shot Documentation Curation Prompt
=======================================

MISSION
-------
Create a comprehensive, clean documentation knowledge base for ONE specialist AI agent from a GitHub repository's documentation.

MANDATORY READS (Before Starting)
- `/Users/MN/GITHUB/.knowledge-builder/curated-docs-repo-builder/CONTEXT.md` — Vision and goals
- `/Users/MN/GITHUB/.knowledge-builder/curated-docs-repo-builder/CONSTRAINTS.md` — Invariants and rules you MUST follow

ACKNOWLEDGEMENT (Required)
- Before any action, print EXACTLY this single line:
  ACK: ReadConstraints→Scaffold→Snapshot→Analyze→Derive→Validate→Clone→Verify→SpecialistGen

CRITICAL PHILOSOPHY: INVISIBLE 10X ENGINEER EXPERTISE
------------------------------------------------------
**Goal:** Create specialist knowledge that makes ANY agent function like a 10x engineer with deep internalized expertise for using this library/framework.

**The Nightmare to Avoid:**
- ❌ Abstracting/paraphrasing documentation into summaries
- ❌ Creating a specialist that *sounds* knowledgeable but works from vibes
- ❌ Q&A knowledge base that requires prompting for every decision
- ❌ Navigation guide focused on "where things are" instead of "how to build optimally"

**What We're Building:**
- ✅ Curated documentation preserves ALL usage guidance verbatim
- ✅ Specialist prompt creates INVISIBLE 10X ENGINEER EXPERTISE
- ✅ Agent reads detailed spec → automatically knows optimal usage patterns
- ✅ Agent makes implementation decisions instinctively, without prompting
- ✅ Agent applies latest patterns by default, optimizing for best practices

**How 10x Engineers Use Libraries (from docs):**
- Read requirement → automatically recognize which features/APIs apply
- Instinctively structure implementation using framework patterns
- Make integration decisions without conscious thought
- Apply best practices by default
- Stay on cutting edge (stable + canary/beta patterns)

**The Specialist Prompt Creates This Invisible Expertise.**

When agent reads detailed spec (GitHub issue/PR comment):
- ✅ Automatically recognizes optimal usage patterns
- ✅ Instinctively applies framework best practices
- ✅ Naturally chooses correct APIs/features
- ✅ Defaults to latest/recommended approaches
- ✅ Makes decisions without being prompted

**The Test:**
Can agent read complex spec and implement correctly without being told:
- "Use feature X here"
- "Apply pattern Y"
- "Follow best practice Z"

If YES (makes optimal decisions automatically) → Specialist created invisible expertise
If NO (needs prompting for usage decisions) → Specialist failed

**Size Philosophy:**
Size is an OUTCOME of qualitative decisions, NOT a constraint.
If it's documentation that creates 10x engineer instincts for library usage, KEEP IT.

CRITICAL INVARIANTS (From CONSTRAINTS.md)
------------------------------------------
1. `.knowledge/curated-docs-repo/` contains ONLY documentation content (no website code, tests, or build artifacts)
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
- BUILDER_ROOT = `/Users/MN/GITHUB/.knowledge-builder/curated-docs-repo-builder`
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
   - Read `/Users/MN/GITHUB/.knowledge-builder/curated-docs-repo-builder/CONSTRAINTS.md` in full
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

10) GENERATE SPECIALIST-PROMPT.md (RepoPrompt-Enhanced Multi-Agent)

   **CRITICAL PHILOSOPHY:**
   - Specialist prompt creates INVISIBLE 10X ENGINEER EXPERTISE
   - Agent reads spec → automatically knows optimal library usage
   - Agent makes implementation decisions instinctively, without prompting
   - NO abstraction/paraphrasing of documentation
   - Curated docs ARE the knowledge base (preserved verbatim)

   **10.1 - Create proposals directory:**

   ```bash
   mkdir -p ${DEST}/.curation/specialist-proposals
   ```

   **10.1.5 - Prepare metadata context:**

   ```bash
   # Set curation date
   CURATION_DATE=$(date -u +"%Y-%m-%d")

   # Create metadata for agents
   METADATA_CONTEXT="
   === KNOWLEDGE FRESHNESS PROTOCOL ===

   MUST include in SPECIALIST-PROMPT.md <metadata> section:

   **Curated:** ${CURATION_DATE}
   **Source:** ${FULL_REPO_PATH}
   **Curated Resource:** ${DEST}

   **When to access pristine source:**
   When specialist needs unabstracted view or finds curation unclear:
   - Check pristine source at ${FULL_REPO_PATH}
   - Access full documentation tree, all examples, complete guides
   - Useful for understanding excluded website code or build configurations
   - See full documentation structure before curation

   **Knowledge Freshness Protocol:**

   IMPORTANT: This documentation was curated on ${CURATION_DATE}.

   Before implementing any feature:
   1. Check CHANGELOG.md or releases since ${CURATION_DATE}
   2. If significant changes found (new APIs, breaking changes, major features):
      - STOP and discuss with user: \"The documentation has changed significantly since curation (${CURATION_DATE}). Should we re-curate first, or proceed with current knowledge?\"
      - User decides: re-curate vs. proceed anyway
   3. If no relevant changes, proceed with implementation

   Don't guess or assume - always check changelog first, then collaborate with user on the decision.
   "

   echo "$METADATA_CONTEXT"
   ```

   **10.2 - Launch 6 parallel agents (ALL ANALYZING SAME DOCUMENTATION):**

   **CRITICAL: All 6 agents must read RepoPrompt specialist first:**
   ```
   Read: /Users/MN/GITHUB/.knowledge/curated-docs-web/repoprompt.com/SPECIALIST-PROMPT.md
   ```

   **PHILOSOPHY:**
   - All agents analyze SAME full documentation independently
   - Goal: Create INVISIBLE 10X ENGINEER EXPERTISE for library usage
   - NOT navigation guide, NOT Q&A knowledge base
   - Focus: What makes agent automatically choose optimal usage patterns

   Invoke ALL 6 agents in a single message (parallel execution):

   ```
   Task 1 (Haiku - Independent Analysis):
     model: "haiku"
     subagent_type: "general-purpose"
     description: "Generate specialist prompt - independent perspective 1"
     prompt: """
     PREREQUISITE: Read /Users/MN/GITHUB/.knowledge/curated-docs-web/repoprompt.com/SPECIALIST-PROMPT.md

     You are analyzing curated documentation to create specialist expertise for using this library.

     CRITICAL PHILOSOPHY:
     Create INVISIBLE 10X ENGINEER EXPERTISE - not a navigation guide.

     What 10x engineers internalize from docs:
     - Read requirement → automatically know which features/APIs to use
     - Recognize usage patterns instinctively (not consciously)
     - Make integration decisions by default (not when prompted)
     - Apply latest features automatically (stable + canary/beta)
     - Follow best practices unconsciously

     The Nightmare to Avoid:
     - ❌ Q&A knowledge base: "When should you use X?"
     - ❌ Navigation guide: "Feature X is documented in page Y"
     - ❌ Concept explainer: "This library provides..."
     - ❌ Paraphrased summaries of docs

     What You're Building:
     - ✅ Deep internalized usage patterns
     - ✅ Automatic decision-making for library usage
     - ✅ Instinctive best practice awareness
     - ✅ Cutting-edge pattern knowledge (canary/beta included)

     REQUIRED METADATA:
     ${METADATA_CONTEXT}

     Analyze the ENTIRE documentation asking:
     "What does a 10x engineer internalize to use this library optimally without conscious thought?"

     Focus areas:
     - Usage pattern recognition: "For requirement X, automatically use API Y"
     - Automatic best practices: "This naturally follows pattern Z"
     - Cutting-edge awareness: "Latest approach is W (including canary/beta)"
     - Integration instincts: "These decisions are automatic"
     - Framework patterns: "This naturally fits usage pattern"

     Write your complete SPECIALIST-PROMPT.md proposal to:
     ${DEST}/.curation/specialist-proposals/proposal-1-sonnet-independent.md
     """

   Task 2 (Haiku - Independent Analysis):
     model: "haiku"
     subagent_type: "general-purpose"
     description: "Generate specialist prompt - independent perspective 2"
     prompt: """
     PREREQUISITE: Read /Users/MN/GITHUB/.knowledge/curated-docs-web/repoprompt.com/SPECIALIST-PROMPT.md

     [Same philosophy as Task 1]

     Independently analyze what creates 10x engineer instincts for using this library.
     Focus on invisible expertise that makes optimal usage decisions automatic.

     REQUIRED METADATA:
     ${METADATA_CONTEXT}

     Write your complete SPECIALIST-PROMPT.md proposal to:
     ${DEST}/.curation/specialist-proposals/proposal-2-sonnet-independent.md
     """

   Task 3 (Sonnet - Independent Analysis):
     model: "sonnet"
     subagent_type: "general-purpose"
     description: "Generate specialist prompt - independent perspective 3"
     prompt: """
     PREREQUISITE: Read /Users/MN/GITHUB/.knowledge/curated-docs-web/repoprompt.com/SPECIALIST-PROMPT.md

     [Same philosophy as Task 1]

     Independently analyze what creates 10x engineer instincts for using this library.
     Focus on invisible expertise that makes optimal usage decisions automatic.

     REQUIRED METADATA:
     ${METADATA_CONTEXT}

     Write your complete SPECIALIST-PROMPT.md proposal to:
     ${DEST}/.curation/specialist-proposals/proposal-3-sonnet-independent.md
     """

   Task 4 (Sonnet - Deep Expertise Analysis):
     model: "sonnet"
     subagent_type: "general-purpose"
     description: "Generate specialist prompt - deep reasoning perspective 1"
     prompt: """
     PREREQUISITE: Read /Users/MN/GITHUB/.knowledge/curated-docs-web/repoprompt.com/SPECIALIST-PROMPT.md

     [Same philosophy as Task 1, with Opus-level deep reasoning]

     Use deep reasoning to identify:
     - Core usage patterns that become instinctive
     - Integration decisions that happen automatically
     - Best practices internalized by experts
     - Cutting-edge patterns (stable + canary/beta) and when to adopt
     - What makes library usage "just work" on first try

     REQUIRED METADATA:
     ${METADATA_CONTEXT}

     Write your complete SPECIALIST-PROMPT.md proposal to:
     ${DEST}/.curation/specialist-proposals/proposal-4-opus-deep.md
     """

   Task 5 (Opus - Deep Expertise Analysis):
     model: "opus"
     subagent_type: "general-purpose"
     description: "Generate specialist prompt - deep reasoning perspective 2"
     prompt: """
     PREREQUISITE: Read /Users/MN/GITHUB/.knowledge/curated-docs-web/repoprompt.com/SPECIALIST-PROMPT.md

     [Same philosophy as Task 4]

     Deep analysis of what creates invisible 10x engineer expertise for library usage.

     REQUIRED METADATA:
     ${METADATA_CONTEXT}

     Write your complete SPECIALIST-PROMPT.md proposal to:
     ${DEST}/.curation/specialist-proposals/proposal-5-opus-deep.md
     """

   Task 6 (Opus - Deep Expertise Analysis):
     model: "opus"
     subagent_type: "general-purpose"
     description: "Generate specialist prompt - deep reasoning perspective 3"
     prompt: """
     PREREQUISITE: Read /Users/MN/GITHUB/.knowledge/curated-docs-web/repoprompt.com/SPECIALIST-PROMPT.md

     [Same philosophy as Task 4]

     Deep analysis of what creates invisible 10x engineer expertise for library usage.

     REQUIRED METADATA:
     ${METADATA_CONTEXT}

     Write your complete SPECIALIST-PROMPT.md proposal to:
     ${DEST}/.curation/specialist-proposals/proposal-6-opus-deep.md
     """
   ```

   **10.3 - Synthesize with evaluator (7th agent):**

   After ALL 6 agents complete, invoke the synthesis agent:

   ```
   Task 7 (Synthesis with Consensus Finding):
     subagent_type: "general-purpose"
     description: "Synthesize final specialist prompt from 6 independent analyses"
     prompt: """
     PREREQUISITE: Read /Users/MN/GITHUB/.knowledge/curated-docs-web/repoprompt.com/SPECIALIST-PROMPT.md

     You have 6 independent specialist prompt proposals from agents analyzing the SAME documentation.

     Read all 6 proposals in:
     ${DEST}/.curation/specialist-proposals/

     Files:
     - proposal-1-sonnet-independent.md
     - proposal-2-sonnet-independent.md
     - proposal-3-sonnet-independent.md
     - proposal-4-opus-deep.md
     - proposal-5-opus-deep.md
     - proposal-6-opus-deep.md

     Your synthesis task:
     1. **Find CONSENSUS:** What do multiple agents agree on? (High signal)
     2. **Identify UNIQUE INSIGHTS:** What did only one agent notice? (Potentially valuable)
     3. **Choose CLEAREST WORDING:** When multiple agents describe same thing, pick best phrasing
     4. **Ensure COMPREHENSIVE COVERAGE:** Combine complementary sections without duplication
     5. **Preserve USAGE KNOWLEDGE:** Keep internalized patterns, not just descriptions
     6. **Maintain INVISIBLE EXPERTISE FOCUS:** Create 10x engineer instincts, not Q&A database

     CRITICAL PHILOSOPHY (enforce in synthesis):
     Create INVISIBLE 10X ENGINEER EXPERTISE for library usage:
     - Agent reads spec → automatically knows optimal usage patterns
     - Instinctive feature/API selection (not conscious decisions)
     - Automatic best practice awareness
     - Cutting-edge pattern knowledge (stable + canary/beta)
     - NEVER abstract/paraphrase documentation
     - Curated docs are ground truth (preserved verbatim)

     What to AVOID in synthesis:
     - ❌ Q&A format: "When should you...?"
     - ❌ Navigation focus: "Feature X is in docs/Y.md"
     - ❌ Concept explanations: "This library allows you to..."
     - ❌ Abstract summaries that lose documentation reality

     What to CREATE:
     - ✅ Usage pattern recognition: "For requirement X, instinctively use API Y"
     - ✅ Automatic decisions: "This naturally follows framework pattern Z"
     - ✅ Cutting-edge awareness: "Latest approach is W (canary/beta)"
     - ✅ Best practice instincts: "By default, structure usage like this"

     Quality criteria:
     - Role definition: 10x engineer specialist for library usage
     - Knowledge base: What curated docs preserve (verbatim guidance)
     - Internalized expertise: Usage patterns that become automatic
     - Implementation instincts: What agent does by default
     - Cutting-edge awareness: Latest patterns (stable + canary/beta)
     - Best practice defaults: What experts do automatically
     - Knowledge boundaries: Clear scope and limitations

     Required structure (use XML tags):
     - <role>: 10x engineer specialist for using this library
     - <knowledge_base>: Curated docs structure and what they preserve
     - <metadata>: Curation date, source paths, freshness protocol
     - <internalized_expertise>: Usage patterns that become automatic
     - <implementation_instincts>: What agent does by default
     - <cutting_edge>: Latest patterns including canary/beta
     - <initialization>: How specialist agent bootstraps

     CRITICAL: <metadata> section MUST include:
     - Curation date (YYYY-MM-DD)
     - Source and curated resource paths
     - Knowledge Freshness Protocol:
       * Check CHANGELOG.md since curation date before implementing
       * If significant changes found, discuss with user: re-curate or proceed?
       * Collaborative decision, not automated cadence

     Write the FINAL synthesized specialist prompt to:
     ${DEST}/SPECIALIST-PROMPT.md

     After writing, report:
     - Consensus patterns found across proposals
     - Unique insights included from single agents
     - Elements taken from which proposals
     - Token count of final specialist prompt
     - Validation: Does this create invisible 10x engineer expertise for library usage?
     - Confirmation: Metadata section included with all required fields?
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

   **10.5 - Structural validation:**

   ```bash
   # Verify specialist prompt has required structure
   SPECIALIST_FILE="${DEST}/SPECIALIST-PROMPT.md"

   echo "Validating SPECIALIST-PROMPT.md structure..."

   # Check for required sections
   MISSING_SECTIONS=""
   grep -q "<role>" "$SPECIALIST_FILE" || MISSING_SECTIONS="${MISSING_SECTIONS}<role> "
   grep -q "<knowledge_base>" "$SPECIALIST_FILE" || MISSING_SECTIONS="${MISSING_SECTIONS}<knowledge_base> "
   grep -q "<metadata>" "$SPECIALIST_FILE" || MISSING_SECTIONS="${MISSING_SECTIONS}<metadata> "
   grep -q "<internalized_expertise>" "$SPECIALIST_FILE" || MISSING_SECTIONS="${MISSING_SECTIONS}<internalized_expertise> "
   grep -q "<initialization>" "$SPECIALIST_FILE" || MISSING_SECTIONS="${MISSING_SECTIONS}<initialization> "

   if [ -n "$MISSING_SECTIONS" ]; then
       echo "❌ ERROR: SPECIALIST-PROMPT.md missing required sections: $MISSING_SECTIONS"
       echo "The specialist prompt structure is invalid. Check synthesis output."
       exit 1
   fi

   # Check for required metadata fields
   echo "Validating metadata section..."
   METADATA_SECTION=$(sed -n '/<metadata>/,/<\/metadata>/p' "$SPECIALIST_FILE")

   MISSING_METADATA=""
   echo "$METADATA_SECTION" | grep -q "Curated.*202[0-9]" || MISSING_METADATA="${MISSING_METADATA}curation-date "
   echo "$METADATA_SECTION" | grep -iq "changelog\|freshness.*protocol" || MISSING_METADATA="${MISSING_METADATA}changelog-protocol "
   echo "$METADATA_SECTION" | grep -iq "discuss.*user\|collaborate.*user" || MISSING_METADATA="${MISSING_METADATA}user-collaboration "

   if [ -n "$MISSING_METADATA" ]; then
       echo "⚠️ WARNING: Metadata section missing fields: $MISSING_METADATA"
       echo "Specialist should include curation date and Knowledge Freshness Protocol"
   fi

   # Verify substantial content
   PROMPT_SIZE=$(wc -l "$SPECIALIST_FILE" | awk '{print $1}')
   if [ $PROMPT_SIZE -lt 50 ]; then
       echo "⚠️ WARNING: SPECIALIST-PROMPT.md seems too short (${PROMPT_SIZE} lines)"
       echo "Consider reviewing the synthesis quality"
   fi

   echo "Checking for anti-patterns and expertise indicators..."

   # Check for Q&A anti-patterns (wrong approach - questions require prompting)
   QUESTION_COUNT=$(grep -iE "when should you|how do you|what is the|why use|should i|can i|do i need" "$SPECIALIST_FILE" | wc -l)
   if [ $QUESTION_COUNT -gt 5 ]; then
       echo "⚠️ WARNING: Q&A-style language detected (${QUESTION_COUNT} instances)"
       echo "Specialist should create internalized knowledge, not answer questions"
       echo "This suggests prompt is oriented toward Q&A interaction rather than invisible expertise"
   fi

   # Check for navigation anti-patterns (wrong focus - file locations)
   NAVIGATION_COUNT=$(grep -iE "located in|found in|check.*file|see.*\.md:" "$SPECIALIST_FILE" | wc -l)
   if [ $NAVIGATION_COUNT -gt 10 ]; then
       echo "⚠️ WARNING: Navigation/location focus detected (${NAVIGATION_COUNT} instances)"
       echo "Specialist should guide usage decisions, not documentation navigation"
       echo "This suggests prompt is a docs navigation guide rather than 10x engineer expertise"
   fi

   # Check for abstraction anti-patterns (wrong content - paraphrasing)
   ABSTRACTION_COUNT=$(grep -iE "allows you to|enables you to|provides|offers|supports" "$SPECIALIST_FILE" | wc -l)
   if [ $ABSTRACTION_COUNT -gt 10 ]; then
       echo "⚠️ WARNING: High abstraction language count (${ABSTRACTION_COUNT} instances)"
       echo "Verify prompt preserves documentation reality, not just describes capabilities"
   fi

   # Check for expertise indicators (correct approach - internalized knowledge)
   EXPERTISE_COUNT=$(grep -iE "automatically|instinctively|naturally|by default|optimal pattern|internalized" "$SPECIALIST_FILE" | wc -l)
   if [ $EXPERTISE_COUNT -lt 5 ]; then
       echo "⚠️ WARNING: Low invisible expertise language (${EXPERTISE_COUNT} instances)"
       echo "Specialist should describe automatic/instinctive decision-making for library usage"
       echo "This suggests prompt may not create 10x engineer expertise"
   fi

   # Check for cutting-edge awareness
   CUTTING_EDGE_COUNT=$(grep -iE "canary|beta|latest|cutting.edge|newest" "$SPECIALIST_FILE" | wc -l)
   if [ $CUTTING_EDGE_COUNT -lt 2 ]; then
       echo "⚠️ WARNING: Limited cutting-edge pattern awareness (${CUTTING_EDGE_COUNT} instances)"
       echo "Specialist should include latest/canary/beta usage patterns"
   fi

   echo ""
   echo "✅ SPECIALIST-PROMPT.md structure validated"
   echo "✅ RepoPrompt-enhanced multi-agent specialist prompt generation complete!"
   echo "📍 Final prompt: ${DEST}/SPECIALIST-PROMPT.md"
   ```

   **10.6 - Update manifest:**

   ```bash
   # Update knowledge base manifest
   HAS_SPECIALIST=$([ -f "${DEST}/SPECIALIST-PROMPT.md" ] && echo "true" || echo "false")
   /Users/MN/GITHUB/.knowledge-builder/tools/update-manifest.sh \
       "docs_repos" \
       "${REPO_NAME}" \
       "curated-docs-repo/${REPO_NAME}" \
       "${HAS_SPECIALIST}"
   ```

   Print completion:
   ```
   ✅ CURATION COMPLETE
   ✅ SPECIALIST-PROMPT.md GENERATED (6-agent ensemble + synthesis)
   ✅ MANIFEST UPDATED

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
✅ Zero test files in `.knowledge/curated-docs-repo/`
✅ At least one docs directory exists
✅ Canonical schema with proper reasons
✅ sparse-checkout has global exclusions
✅ Specialist creates INVISIBLE 10X ENGINEER EXPERTISE for library usage
✅ Agent reads spec → automatically knows optimal usage patterns
✅ Agent makes implementation decisions instinctively, without prompting
✅ Specialist includes cutting-edge patterns (stable + canary/beta)
✅ 6-agent consensus achieved in synthesis
✅ Every included file creates deep internalized usage expertise
✅ Documentation preserved verbatim, no paraphrasing
✅ NOT a Q&A database or navigation guide
✅ Website rendering code excluded (React components, configs)

OUTPUT LOCATIONS
----------------
- **Curated docs**: `${DEST}/` (sparse clone)
- **Planning/meta**: `${PROJECT_DIR}/` (JSON + YAML)
- **API snapshot**: `${SNAPSHOT_DIR}/github-api-tree.json` (shared)

FORBIDDEN ACTIONS
-----------------
- NO website code in `.knowledge/curated-docs-repo/`
- NO custom reason strings
- NO test files in output
- NO asking user for paths/branches
- NO proceeding past failed validation
