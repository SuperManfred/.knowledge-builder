# One-Shot Documentation Curation Prompt

## MISSION

Create a comprehensive, clean documentation knowledge base for ONE specialist AI agent from a Git repository's documentation.

MANDATORY READS (Before Starting)

- `/Users/MN/GITHUB/.knowledge-builder/curated-docs-repo-builder/CONTEXT.md` — Vision and goals
- `/Users/MN/GITHUB/.knowledge-builder/curated-docs-repo-builder/CONSTRAINTS.md` — Invariants and rules you MUST follow

ACKNOWLEDGEMENT (Required)

- Before any action, print EXACTLY this single line:
  ACK: ReadConstraints→Scaffold→Snapshot→Analyze→Derive→Validate→Clone→Verify→SpecialistGen

## CRITICAL PHILOSOPHY: 10X ENGINEER EXPERTISE

**Goal:** Create specialist knowledge that makes ANY agent function like a 10x engineer with deep internalized expertise for using this library/framework.

**The Nightmare to Avoid:**

- ❌ Abstracting/paraphrasing documentation into summaries
- ❌ Creating a specialist that _sounds_ knowledgeable but works from vibes
- ❌ Q&A knowledge base that requires prompting for every decision
- ❌ Navigation guide focused on "where things are" instead of "how to build optimally"

**What We're Building:**

- ✅ Curated documentation preserves ALL usage guidance verbatim
- ✅ Specialist prompt creates 10X ENGINEER EXPERTISE
- ✅ Agent reads detailed spec → automatically knows optimal usage patterns
- ✅ Agent makes implementation decisions instinctively, without prompting
- ✅ Agent applies latest patterns by default, optimizing for best practices

**How 10x Engineers Use Libraries (from docs):**

- Read requirement → automatically recognize which features/APIs apply
- Instinctively structure implementation using framework patterns
- Make integration decisions without conscious thought
- Apply best practices by default
- Stay on cutting edge (stable + canary/beta patterns)

**The Specialist Prompt Creates This 10X ENGINEER Expertise.**

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

If YES (makes optimal decisions automatically) → Specialist created 10X ENGINEER expertise
If NO (needs prompting for usage decisions) → Specialist failed

**Size Philosophy:**
Size is an OUTCOME of qualitative decisions, NOT a constraint.
If it's documentation that creates 10x engineer instincts for library usage, KEEP IT.

## CRITICAL INVARIANTS (From CONSTRAINTS.md)

1. `.knowledge/curated-docs-repo/` contains ONLY documentation content (no website code, tests, or build artifacts)
2. Each curated docs repo serves ONE specialist agent exclusively
3. Schema MUST be canonical (see section 5)
4. Reasons MUST be one of three exact formats (see section 5.1)
5. NO test files in output (validated post-clone)
6. Size is an OUTCOME of qualitative decisions, NOT a constraint

## Inputs

- REPO_URL: Git URL (e.g., `https://github.com/<owner>/<repo>`)

**IMPORTANT: All paths in this prompt are ABSOLUTE paths starting with /**
Derived Paths (compute, don't ask)

---

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

# Workflow Steps

0. CHECK UPSTREAM (Pristine Repo)

   - Execute: `/Users/MN/GITHUB/.knowledge-builder/full-repo-sync/check-and-sync.sh ${REPO_URL} ${DEST}`
   - This script automatically:
     - **Initial curation** (destination doesn't exist): Syncs to get absolute latest
     - **Re-curation** (destination exists): Checks freshness, syncs only if >7 days stale
   - Verify `${FULL_REPO_PATH}/` exists after script completes

1. READ CONSTRAINTS

   - Read `/Users/MN/GITHUB/.knowledge-builder/curated-docs-repo-builder/CONSTRAINTS.md` in full
   - Understand all INVARIANTS, RULES, and GUIDELINES

2. SCAFFOLD PROJECT

   - Run: `${BUILDER_ROOT}/tools/scaffold.sh ${REPO_URL} ${BRANCH}`
   - Move output to `${PROJECT_DIR}`

3-4. SNAPSHOT & CHUNKING (Automated)

   **Execute preparation script (deterministic snapshot + chunking):**

   ```bash
   /Users/MN/GITHUB/.knowledge-builder/tools/prepare-analysis.sh ${FULL_REPO_PATH} ${SNAPSHOT_DIR}
   ```

   This script automatically performs:
   - **Step 3:** Generate git tree snapshot from pristine clone
   - **Step 4.0:** Pre-filter tree (remove build artifacts, node_modules, etc.)
   - **Step 4.1:** Calculate agent distribution (~100k tokens/agent, max 10 agents)
   - **Step 4.2:** Split filtered tree into chunks for parallel analysis

   **Script outputs:**
   - `${SNAPSHOT_DIR}/github-api-tree.txt` - Full repository tree
   - `${SNAPSHOT_DIR}/filtered-tree.txt` - Pre-filtered tree
   - `${SNAPSHOT_DIR}/tree-chunk-*` - Chunks for parallel analysis
   - `${SNAPSHOT_DIR}/analysis-metadata.txt` - Metadata (agent count, entries, etc.)

   **After script completes, launch pattern analysis agents:**

   Read `${SNAPSHOT_DIR}/analysis-metadata.txt` to get `num_agents`, then:

   **Agent Spawning (Task tool with model="haiku"):**

   - For each tree chunk (`tree-chunk-*`), spawn a subagent with:
     - `subagent_type: "general-purpose"`
     - `model: "haiku"`
     - Prompt: "Read PATTERN-ANALYSIS-SUBAGENT-INSTRUCTIONS.md, then analyze tree chunk ${chunk_file} for documentation patterns. Return structured recommendations."
   - Launch all agents in parallel (single message with multiple Task tool calls)
   - Save each agent's output to `${SNAPSHOT_DIR}/pattern-analysis/agent-${N}-results.md`

   **4.3) Combine pattern analysis results**

   Synthesize recommendations from all agents:

   ```bash
   # Curator reads all agent results
   # Identifies consensus patterns across chunks
   # Resolves conflicts (e.g., one agent says include, another says exclude)
   # Creates unified ALLOWLIST and DENYLIST
   ```

   **Combined patterns should include:**

   - ALLOWLIST (what to keep):

     - Documentation directories: `docs/**/*.md`, `docs/**/*.mdx`, `documentation/**/*.md`
     - Content directories: `content/**/*.md`, `guides/**/*.md`, `website/content/**/*.md`
     - Documentation assets: `docs/**/*.png`, `docs/**/*.svg`, `docs/**/*.jpg`, `docs/**/*.gif`
     - Code examples in docs: `docs/**/*.js`, `docs/**/*.ts` (if they're examples, not site code)
     - API references and generated docs
     - Root docs: `README.md` at repo root (but exclude in subdirs unless in docs/)

   - DENYLIST (what to exclude):
     - Website components: `docs/**/*.jsx`, `docs/**/*.tsx`, `docs/**/*.vue`, `website/components/**`
     - Build configs: `docs/next.config.js`, `docs/docusaurus.config.js`, `website/next.config.js`
     - Tests: `docs/**/*.test.*`, `docs/**/__tests__/**`, `docs/**/*.spec.*`, `test_*` (root-level test files)
     - Build outputs: `docs/dist/**`, `docs/build/**`, `docs/.next/**`, `docs/.docusaurus/**`
     - Node modules: `docs/node_modules/**`, `website/node_modules/**`, `**/node_modules/**`
     - CI/CD: `.github/**`, `.gitlab/**`, `.circleci/**`
     - Non-docs code: `src/**`, `lib/**`, `packages/**/src/**`, `crawl4ai/**` (source code dirs)
     - Non-docs markdown: `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`
     - Infrastructure at root: `Dockerfile`, `docker-compose.yml`, `.dockerignore`, `uv.lock`, `cliff.toml`, `.env*`, `MANIFEST.in`, `setup.py`, `setup.cfg`, `pyproject.toml`
     - Other: `scripts/**`, `bench/**`, `.vscode/**`, `.devcontainer/**`, `.changeset/**`, `patches/**`

   **4.4) Apply QUALITATIVE inclusion criteria**

   Review combined patterns using qualitative judgment:

   - Every file/directory decision based on: "Does this help an agent teach library usage?"
   - ✅ INCLUDE: Tutorials, guides, API docs, examples, concepts, diagrams
   - ❌ EXCLUDE: Website rendering code, build tools, tests, infrastructure
   - Size is an OUTCOME - comprehensive docs may be large, that's okay
   - Each micro-decision should be qualitative, not quantitative

   **Optional: RepoPrompt validation**

   ```
   - Can optionally open ${FULL_REPO_PATH} as RepoPrompt workspace
   - Call: mcp__RepoPrompt__get_file_tree (type="files", mode="auto")
   - Useful to see documentation structure and validate decisions
   ```

5. GENERATE ARTIFACTS

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

6. VALIDATION GATES (ABORT IF ANY FAIL)

   **Execute validation script (deterministic enforcement):**

   ```bash
   /Users/MN/GITHUB/.knowledge-builder/tools/validate-curation.sh ${PROJECT_DIR} docs
   ```

   This script validates:
   - **6.1) Schema validation:** JSON structure, reason formats, path slash rules
   - **6.2) Consistency validation:** sparse-checkout ⊂ keep decisions, global exclusions, mixed dir children
   - **6.3) Pattern validation:** All decisions cite patterns, docs kept, website excluded

   **Script will exit non-zero if validation fails.**

   **IF VALIDATION FAILS:**
   - Review error details printed by script
   - Regenerate artifacts (curated-tree.json, sparse-checkout, curation.yaml)
   - Re-run validation script before proceeding

7. CLONE WITH SPARSE CHECKOUT (Automated)

   **Execute sparse clone script (deterministic git operations):**

   ```bash
   /Users/MN/GITHUB/.knowledge-builder/tools/sparse-clone.sh ${REPO_URL} ${DEST} ${PROJECT_DIR}/sparse-checkout
   ```

   This script automatically:
   - Detects initial clone vs update
   - Configures sparse-checkout patterns
   - Performs optimized clone (--filter=blob:none --depth=1)
   - Applies sparse-checkout to working tree
   - Verifies clone success

   **Script handles:**
   - Network failures (clear error messages with troubleshooting)
   - Authentication issues (checks for private repos)
   - Update existing clones (reset + clean)
   - Verification (ensures files checked out)

8. POST-CLONE VERIFICATION

   **Execute verification script (deterministic quality gates):**

   ```bash
   /Users/MN/GITHUB/.knowledge-builder/tools/verify-clone.sh ${DEST} docs
   ```

   This script verifies:
   - **8.1) Test files:** MUST be 0 (or ≤5 if doc examples)
   - **8.2) Documentation:** MUST have docs/documentation/content directories
   - **8.3) Website code:** SHOULD be 0 (.tsx/.jsx files)
   - **8.4) Infrastructure files:** SHOULD be 0 (Dockerfile, setup.py, etc.)
   - **8.5) Source code:** MUST be 0 (src/lib directories outside docs/)
   - **8.6) Size awareness:** Report total size (NOT a constraint)
   - **8.7) File count awareness:** Report total files (NOT a constraint)
   - **8.8) Top subtrees:** Report largest directories

   **Script will exit non-zero if critical verifications fail.**

   **IF VERIFICATION FAILS:**
   - Review error details printed by script
   - Fix sparse-checkout patterns
   - Re-clone with corrected sparse-checkout
   - Re-run verification script

   8.9) Create directory structure markers

   ```bash
   # Preserve mental model of full repository structure
   # Create empty directories with .omitted markers for excluded content

   # Identify major omitted directories from curated-tree.json
   OMITTED_DIRS=$(jq -r '.entries[] |
     select(.decision == "omit_all" and .node == "dir") |
     .path' ${PROJECT_DIR}/curated-tree.json | sed 's:/$::')

   # Create marker directories for excluded content
   for dir in $OMITTED_DIRS; do
     if [ ! -d "${DEST}/${dir}" ]; then
       mkdir -p "${DEST}/${dir}"

       # Extract exclusion reasons for this directory
       REASONS=$(jq -r ".entries[] | select(.path == \"${dir}/\") | .reasons[]" \
         ${PROJECT_DIR}/curated-tree.json)

       # Create .omitted marker file
       cat > "${DEST}/${dir}/.omitted" << EOF
   ```

# Directory Excluded from Curation

This directory exists in the source repository but was excluded from curation.

**Excluded directory:** ${dir}/

**Reasons:**
${REASONS}

**To access full content:** Check pristine source at:
${FULL_REPO_PATH}/${dir}/

This marker preserves the repository structure so you understand what's missing.
EOF

       echo "Created marker: ${dir}/.omitted"
     fi

done

echo "✅ Directory structure preserved with .omitted markers"

````

This helps the specialist understand the full documentation structure and know where
to find excluded content in the pristine source when needed.

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
````

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

10. GENERATE SPECIALIST-PROMPT.md (RepoPrompt-Enhanced Multi-Agent)

    **CRITICAL PHILOSOPHY:**

- Specialist prompt creates 10X ENGINEER EXPERTISE
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
- Goal: Create 10X ENGINEER EXPERTISE for library usage
- NOT navigation guide, NOT Q&A knowledge base
- Focus: What makes agent automatically choose optimal usage patterns

Invoke ALL 6 agents in a single message (parallel execution):

```
Task 1 (Haiku - Independent Analysis):
  model: "haiku"
  subagent_type: "general-purpose"
  description: "Generate specialist prompt - independent perspective 1"
  prompt: """
  Read SPECIALIST-SUBAGENT-INSTRUCTIONS.md in the current directory for complete instructions.

  Also read RepoPrompt specialist for context:
  /Users/MN/GITHUB/.knowledge/curated-docs-web/repoprompt.com/SPECIALIST-PROMPT.md

  RepoPrompt context:
  - Workspace: ${DEST}
  - Full curated documentation selected

  Required metadata (include verbatim):
  ${METADATA_CONTEXT}

  Your focus: Independent analysis of 10X teaching expertise for library usage.

  Write your complete SPECIALIST-PROMPT.md proposal to:
  ${DEST}/.curation/specialist-proposals/proposal-1-haiku-independent.md
  """

Task 2 (Haiku - Independent Analysis):
  model: "haiku"
  subagent_type: "general-purpose"
  description: "Generate specialist prompt - independent perspective 2"
  prompt: """
  Read SPECIALIST-SUBAGENT-INSTRUCTIONS.md in the current directory for complete instructions.

  Also read RepoPrompt specialist:
  /Users/MN/GITHUB/.knowledge/curated-docs-web/repoprompt.com/SPECIALIST-PROMPT.md

  RepoPrompt context:
  - Workspace: ${DEST}
  - Full curated documentation selected

  Required metadata (include verbatim):
  ${METADATA_CONTEXT}

  Your focus: Independent analysis from a different perspective.

  Write your complete SPECIALIST-PROMPT.md proposal to:
  ${DEST}/.curation/specialist-proposals/proposal-2-haiku-independent.md
  """

Task 3 (Sonnet - Independent Analysis):
  model: "sonnet"
  subagent_type: "general-purpose"
  description: "Generate specialist prompt - independent perspective 3"
  prompt: """
  Read SPECIALIST-SUBAGENT-INSTRUCTIONS.md in the current directory for complete instructions.

  Also read RepoPrompt specialist:
  /Users/MN/GITHUB/.knowledge/curated-docs-web/repoprompt.com/SPECIALIST-PROMPT.md

  RepoPrompt context:
  - Workspace: ${DEST}
  - Full curated documentation selected

  Required metadata (include verbatim):
  ${METADATA_CONTEXT}

  Your focus: Independent analysis with Sonnet-level reasoning.

  Write your complete SPECIALIST-PROMPT.md proposal to:
  ${DEST}/.curation/specialist-proposals/proposal-3-sonnet-independent.md
  """

Task 4 (Sonnet - Deep Expertise Analysis):
  model: "sonnet"
  subagent_type: "general-purpose"
  description: "Generate specialist prompt - deep reasoning perspective 1"
  prompt: """
  Read SPECIALIST-SUBAGENT-INSTRUCTIONS.md in the current directory for complete instructions.

  Also read RepoPrompt specialist:
  /Users/MN/GITHUB/.knowledge/curated-docs-web/repoprompt.com/SPECIALIST-PROMPT.md

  RepoPrompt context:
  - Workspace: ${DEST}
  - Full curated documentation selected

  Required metadata (include verbatim):
  ${METADATA_CONTEXT}

  Your focus: Deep reasoning to identify core usage patterns that become instinctive.
  Use Sonnet's reasoning to find what makes library usage "just work".

  Write your complete SPECIALIST-PROMPT.md proposal to:
  ${DEST}/.curation/specialist-proposals/proposal-4-sonnet-deep.md
  """

Task 5 (Opus - Deep Expertise Analysis):
  model: "opus"
  subagent_type: "general-purpose"
  description: "Generate specialist prompt - deep reasoning perspective 2"
  prompt: """
  Read SPECIALIST-SUBAGENT-INSTRUCTIONS.md in the current directory for complete instructions.

  Also read RepoPrompt specialist:
  /Users/MN/GITHUB/.knowledge/curated-docs-web/repoprompt.com/SPECIALIST-PROMPT.md

  RepoPrompt context:
  - Workspace: ${DEST}
  - Full curated documentation selected

  Required metadata (include verbatim):
  ${METADATA_CONTEXT}

  Your focus: Deep expertise analysis using Opus-level reasoning.
  Identify integration patterns and best practices that become automatic.

  Write your complete SPECIALIST-PROMPT.md proposal to:
  ${DEST}/.curation/specialist-proposals/proposal-5-opus-deep.md
  """

Task 6 (Opus - Deep Expertise Analysis):
  model: "opus"
  subagent_type: "general-purpose"
  description: "Generate specialist prompt - deep reasoning perspective 3"
  prompt: """
  Read SPECIALIST-SUBAGENT-INSTRUCTIONS.md in the current directory for complete instructions.

  Also read RepoPrompt specialist:
  /Users/MN/GITHUB/.knowledge/curated-docs-web/repoprompt.com/SPECIALIST-PROMPT.md

  RepoPrompt context:
  - Workspace: ${DEST}
  - Full curated documentation selected

  Required metadata (include verbatim):
  ${METADATA_CONTEXT}

  Your focus: Deep expertise analysis from a third Opus perspective.
  Focus on cutting-edge patterns and troubleshooting instincts.

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
  6. **Maintain ENGINEER EXPERTISE FOCUS:** Create 10x engineer instincts, not Q&A database

  CRITICAL PHILOSOPHY (enforce in synthesis):
  Create 10X ENGINEER EXPERTISE for library usage:
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
  - Validation: Does this create 10x engineer expertise for library usage?
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

**10.5 - Validate specialist prompt:**

```bash
# Run consolidated validation script
/Users/MN/GITHUB/.knowledge-builder/tools/verify-curation.sh "${DEST}/SPECIALIST-PROMPT.md"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ RepoPrompt-enhanced multi-agent specialist prompt generation complete!"
    echo "📍 Final prompt: ${DEST}/SPECIALIST-PROMPT.md"
else
    echo "❌ Validation failed. Review specialist prompt quality."
    exit 1
fi
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

## ERROR HANDLING

- If GitHub API is truncated: Note it, proceed, reconcile from local clone
- If validation fails: MUST fix and re-validate, don't proceed
- If test files found post-clone: MUST fix sparse-checkout
- If no docs directories found post-clone: MUST fix patterns

## SUCCESS CRITERIA

✅ Zero test files in `.knowledge/curated-docs-repo/`
✅ At least one docs directory exists
✅ Canonical schema with proper reasons
✅ sparse-checkout has global exclusions
✅ Specialist creates 10X ENGINEER EXPERTISE for library usage
✅ Agent reads spec → automatically knows optimal usage patterns
✅ Agent makes implementation decisions instinctively, without prompting
✅ Specialist includes cutting-edge patterns (stable + canary/beta)
✅ 6-agent consensus achieved in synthesis
✅ Every included file creates deep internalized usage expertise
✅ Documentation preserved verbatim, no paraphrasing
✅ NOT a Q&A database or navigation guide
✅ Website rendering code excluded (React components, configs)

## OUTPUT LOCATIONS

- **Curated docs**: `${DEST}/` (sparse clone)
- **Planning/meta**: `${PROJECT_DIR}/` (JSON + YAML)
- **API snapshot**: `${SNAPSHOT_DIR}/github-api-tree.json` (shared)

## FORBIDDEN ACTIONS

- NO website code in `.knowledge/curated-docs-repo/`
- NO custom reason strings
- NO test files in output
- NO asking user for paths/branches
- NO proceeding past failed validation
