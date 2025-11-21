# RepoPrompt-Enhanced Repository Curation Prompt

## MISSION

Create a minimal, code-only knowledge base for ONE specialist AI agent from a Git repository.
**Enhanced with RepoPrompt capabilities for superior specialist prompt generation.**

## PREREQUISITE: GAIN REPOPROMPT SUPERPOWERS

**CRITICAL: Execute these steps BEFORE anything else:**

1. **Read RepoPrompt Specialist Knowledge**

   ```
   Read: /Users/MN/GITHUB/.knowledge/curated-docs-web/repoprompt.com/SPECIALIST-PROMPT.md
   ```

   This gives you RepoPrompt expertise: Context Builder, MCP tools, Code Maps, workflow patterns.

2. **Verify MCP Connection (MANDATORY - EARLY EXIT IF FAILS)**

   ```
   Call: mcp__RepoPrompt__list_models
   ```

   **IF THIS CALL FAILS:**

   ```
   ❌ FATAL ERROR: RepoPrompt MCP Server NOT Connected

   This curation prompt REQUIRES RepoPrompt MCP to be available.
   The enhanced specialist prompt generation depends on:
   - RepoPrompt workspace access
   - Code structure analysis (codemaps)
   - Full context selection
   - Token statistics

   REQUIRED ACTION:
   1. Ensure RepoPrompt MCP server is running
   2. Verify MCP connection in your environment
   3. Confirm mcp__RepoPrompt__* tools are accessible
   4. Re-run this curation after connection is established

   CANNOT PROCEED WITHOUT REPOPROMPT MCP.
   Workflow terminated.
   ```

   **STOP EXECUTION. DO NOT PROCEED TO STEP 3. REPORT THE ISSUE TO THE USER.**

   **IF CALL SUCCEEDS:**
   Continue to step 3.

3. **Acknowledge Readiness**
   Print EXACTLY this line:
   ```
   ✅ REPOPROMPT-ENHANCED CURATOR READY
   ACK: RepoPrompt→ReadConstraints→Scaffold→Snapshot→Analyze→Derive→Validate→Clone→Verify→SpecialistGen
   ```

## MANDATORY READS (After RepoPrompt Setup)

- `/Users/MN/GITHUB/.knowledge-builder/curated-code-repo-builder/CONTEXT.md` — Vision and goals
- `/Users/MN/GITHUB/.knowledge-builder/curated-code-repo-builder/CONSTRAINTS.md` — Invariants and rules you MUST follow

## CRITICAL PHILOSOPHY: 10X ENGINEER EXPERTISE

**Goal:** Create specialist knowledge that makes ANY agent function like a 10x engineer with deep internalized expertise.

**The Nightmare to Avoid:**

- ❌ Abstracting/paraphrasing source code into natural language summaries
- ❌ Creating a specialist that _sounds_ authoritative but works from vibes
- ❌ Losing implementation ground truth in favor of descriptions
- ❌ Q&A knowledge base that requires prompting for every decision
- ❌ Navigation guide focused on "where things are" instead of "how to build optimally"

**What We're Building:**

- ✅ Curated code preserves ALL implementation details verbatim
- ✅ Specialist prompt creates 10X ENGINEER EXPERTISE over the curated resource
- ✅ Agent reads detailed spec → automatically knows optimal implementation approach
- ✅ Agent makes architectural decisions instinctively, without prompting
- ✅ Agent applies latest patterns by default, optimizing for performance/security

**How 10x Engineers Work:**

- Read business requirement
- Automatically recognize which patterns apply
- Instinctively structure for optimal implementation
- Make technical decisions without conscious thought
- Apply best practices by default
- Stay on cutting edge (stable + canary/beta patterns)

**The Specialist Prompt Creates This 10X Engineer Expertise.**

When agent reads detailed spec (GitHub issue/PR comment):

- ✅ Automatically recognizes optimal patterns to apply
- ✅ Instinctively structures code for performance/security
- ✅ Naturally applies caching, pre-rendering, optimization
- ✅ Defaults to latest/best practices
- ✅ Makes decisions without being prompted

**The Test:**
Can agent read complex spec and implement correctly without being told:

- "Use pattern X here"
- "Add optimization Y"
- "This should be structured as Z"

If YES (makes optimal decisions automatically) → Specialist created 10X Engineer expertise
If NO (needs prompting for technical decisions) → Specialist failed

**Size Philosophy:**
Size is an OUTCOME of qualitative decisions, NOT a constraint.
If it's implementation code that creates 10x engineer instincts, KEEP IT.

## Inputs

- REPO_URL: GitHub URL (e.g., `https://github.com/<owner>/<repo>`)

**IMPORTANT: All paths in this prompt are ABSOLUTE paths starting with /**

## Derived Paths (compute, don't ask)

- BUILDER_ROOT = `/Users/MN/GITHUB/.knowledge-builder/curated-code-repo-builder`
- KNOWLEDGE_ROOT = `/Users/MN/GITHUB/.knowledge`
- FULL_REPO_DIR = `${KNOWLEDGE_ROOT}/full-repo`
- CURATED_CODE_REPO_DIR = `${KNOWLEDGE_ROOT}/curated-code-repo`
- OWNER, REPO = parse from REPO_URL (lowercase, hyphenated)
- REPO_NAME = `${OWNER}-${REPO}`
- DEST = `${CURATED_CODE_REPO_DIR}/${REPO_NAME}`
- FULL_REPO_PATH = `${FULL_REPO_DIR}/${REPO_NAME}`
- BRANCH = default branch via GitHub API
- COMMIT = branch head SHA via GitHub API
- SNAPSHOT_DIR = `${BUILDER_ROOT}/snapshots/${REPO_NAME}/${COMMIT}`
- PROJECT_DIR = `${BUILDER_ROOT}/projects/${REPO_NAME}`

# Workflow Steps

0. CHECK UPSTREAM (Pristine Repo)

   - Read `${FULL_REPO_DIR}/MANIFEST.yaml`
   - Check if entry exists for `${REPO_NAME}`:
     - **Missing**: Execute `/Users/MN/GITHUB/.knowledge-builder/full-repo-sync/sync.sh ${REPO_URL}`
     - **Stale (>7 days)**: Execute `/Users/MN/GITHUB/.knowledge-builder/full-repo-sync/sync.sh ${REPO_URL}`
     - **Fresh (<7 days)**: Continue with existing
   - Verify `${FULL_REPO_PATH}/` exists after sync
   - This ensures we have a pristine clone to work from

1. READ CONSTRAINTS

   - Read `/Users/MN/GITHUB/.knowledge-builder/curated-code-repo-builder/CONSTRAINTS.md` in full
   - Understand all INVARIANTS, RULES, and GUIDELINES

2. SCAFFOLD PROJECT

   - Run: `${BUILDER_ROOT}/tools/scaffold.sh ${REPO_URL} ${BRANCH}`
   - Move output to `${PROJECT_DIR}`

3. FETCH API SNAPSHOT

   - Use local pristine clone from `${FULL_REPO_PATH}`
   - Generate tree from local repository:
     ```bash
     cd ${FULL_REPO_PATH}
     git ls-tree -r -t --full-tree HEAD
     ```
   - Convert output to GitHub API tree format
   - Save to `${SNAPSHOT_DIR}/github-api-tree.json`
   - If local clone has issues: Step 0 should have ensured pristine clone exists

4. ANALYZE & DERIVE PATTERNS

   **4.0) Pre-filter git tree (bash)**

   Reduce tree size before pattern analysis to improve agent performance:

   ```bash
   # Count total entries
   TOTAL_ENTRIES=$(wc -l < ${SNAPSHOT_DIR}/github-api-tree.txt)

   # Pre-filter: Remove obvious non-code patterns
   grep -vE '(node_modules/|\.git/|dist/|build/|\.next/|\.cache/|vendor/|__pycache__/|\.min\.|\.map$|\.png$|\.jpg$|\.svg$|\.ico$|\.woff|\.ttf)' \
     ${SNAPSHOT_DIR}/github-api-tree.txt > ${SNAPSHOT_DIR}/filtered-tree.txt

   FILTERED_ENTRIES=$(wc -l < ${SNAPSHOT_DIR}/filtered-tree.txt)
   REDUCTION_PCT=$(echo "scale=1; ($TOTAL_ENTRIES - $FILTERED_ENTRIES) * 100 / $TOTAL_ENTRIES" | bc)

   echo "Pre-filter: ${TOTAL_ENTRIES} → ${FILTERED_ENTRIES} entries (${REDUCTION_PCT}% reduction)"
   ```

   **4.1) Calculate agent distribution**

   Target ~100k tokens per agent (50% of 200k limit for safety):

   ```bash
   # Estimate: ~20 tokens per tree entry (path + metadata)
   # Target: 5000 entries per agent = ~100k tokens
   ENTRIES_PER_AGENT=5000

   NUM_AGENTS=$(echo "($FILTERED_ENTRIES + $ENTRIES_PER_AGENT - 1) / $ENTRIES_PER_AGENT" | bc)

   # Cap at 10 agents max (for repos >50k entries)
   if [ $NUM_AGENTS -gt 10 ]; then
     NUM_AGENTS=10
     ENTRIES_PER_AGENT=$(echo "($FILTERED_ENTRIES + $NUM_AGENTS - 1) / $NUM_AGENTS" | bc)
   fi

   echo "Will launch ${NUM_AGENTS} pattern analysis agents (${ENTRIES_PER_AGENT} entries each)"
   ```

   **4.2) Split tree and launch pattern analysis agents**

   Launch multiple Haiku agents in parallel to analyze patterns:

   ```bash
   # Split filtered tree into chunks
   split -l $ENTRIES_PER_AGENT ${SNAPSHOT_DIR}/filtered-tree.txt ${SNAPSHOT_DIR}/tree-chunk-

   # Create results directory
   mkdir -p ${SNAPSHOT_DIR}/pattern-analysis

   # NOTE: Curator will now spawn pattern analysis subagents
   # Each subagent reads: PATTERN-ANALYSIS-SUBAGENT-INSTRUCTIONS.md
   # Each analyzes one chunk and returns pattern recommendations
   ```

   **Agent Spawning (Task tool with model="haiku"):**

   - For each tree chunk, spawn a subagent with:
     - `subagent_type: "general-purpose"`
     - `model: "haiku"`
     - Prompt: "Read PATTERN-ANALYSIS-SUBAGENT-INSTRUCTIONS.md, then analyze tree chunk ${chunk_file} for patterns. Return structured recommendations."
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
     - Core source directories: `src/`, `lib/`, `packages/*/src/`, `app/`, `core/`, `pkg/`, `cmd/`
     - Be specific: `packages/next/src/**` not `packages/next/**`
     - Include root: manifest files, configuration (exclude \*.md files)
   - DENYLIST (what to exclude):
     - Tests: `**/__tests__/**`, `**/test/**`, `**/tests/**`, `**/*.test.*`, `**/*.spec.*`, `**/*.snap`
     - Build: `dist/**`, `build/**`, `out/**`, `target/**`, `compiled/**`
     - Vendor: `node_modules/**`, `vendor/**`, `.venv/**`, `__pycache__/**`
     - Docs: `docs/**`, `doc/**`, `documentation/**`, `website/**`, `examples/**`, `demos/**`, `**/*.md` (except LICENSE/NOTICE)
     - CI: `.github/**`, `.gitlab/**`, `.circleci/**`
     - Media/Large files: `**/*.min.*`, binaries, images, videos

   **4.4) Apply QUALITATIVE inclusion criteria**

   Review combined patterns using qualitative judgment:

   - Every file/directory decision based on: "Does this enable library-maintainer level thinking?"
   - ✅ INCLUDE: Implementation code, internal utilities, architectural patterns, core logic
   - ❌ EXCLUDE: Tests, docs, examples, demos, build outputs, media, vendored dependencies
   - Size is an OUTCOME, not a constraint - the RIGHT size = whatever achieves specialist expertise
   - Each micro-decision should be qualitative, not quantitative

   **Optional: RepoPrompt validation**

   ```
   - Can optionally open ${FULL_REPO_PATH} as RepoPrompt workspace
   - Call: mcp__RepoPrompt__get_file_tree (type="files", mode="auto")
   - Call: mcp__RepoPrompt__get_code_structure to see what has codemaps (+)
   - This validates pattern decisions but shouldn't replace qualitative judgment
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

6. VALIDATION GATES (ABORT IF ANY FAIL)

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

7. CLONE WITH SPARSE CHECKOUT

   - Clone to `${DEST}` using generated sparse-checkout
   - Depth=1, blobless for efficiency
   - Update if already exists

8. POST-CLONE VERIFICATION

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

   8.6) Create directory structure markers

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

This helps the specialist understand the full repository structure and know where
to find excluded content in the pristine source when needed.

9) SPECIALIST READINESS CHECK
Ask: "Does this give a specialist agent everything needed to think like a library maintainer?"
- Can the specialist understand internal architecture?
- Are key patterns and idioms preserved?
- Is the API surface complete?

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
- Low activity (<5 commits/month): Re-curate every 6 months
- Moderate activity (5-20 commits/month): Re-curate every 2-3 months
- High activity (>20 commits/month): Re-curate monthly

This helps you decide when to refresh this knowledge base.
```

10. GENERATE SPECIALIST-PROMPT.md (RepoPrompt-Enhanced Multi-Agent)

    **CRITICAL PHILOSOPHY:**

- Specialist prompt creates 10X ENGINEER EXPERTISE
- Agent reads spec → automatically knows optimal implementation
- Agent makes decisions instinctively, without prompting
- NO abstraction/paraphrasing of implementation
- Curated code IS the knowledge base (preserved verbatim)

**10.1 - Open curated repository in RepoPrompt:**

```bash
# Create RepoPrompt workspace for curated repo
# Use MCP tools to prepare context
```

Call MCP tools:

```
mcp__RepoPrompt__manage_workspaces(action="list")
# Note current workspaces

# If needed, open ${DEST} as workspace (via RepoPrompt UI or URL scheme)
# repoprompt://open?workspace=${DEST}
```

**10.2 - Prepare full context for all agents:**

```
# Select ALL curated files (this is the full knowledge base)
mcp__RepoPrompt__manage_selection(
  op="set",
  paths=["${DEST}"],
  mode="full"
)

# Get code structure (codemaps for all files)
mcp__RepoPrompt__get_code_structure(
  scope="selected",
  max_results=1000
)

# Get hierarchical understanding
mcp__RepoPrompt__list_codemaps_tree()

# Check token stats
mcp__RepoPrompt__token_stats()

# Preview what agents will receive
mcp__RepoPrompt__get_prompt_preview()
```

**CRITICAL: All 6 agents get the SAME FULL CONTEXT**

- Same workspace
- Same file selection
- Same code maps + full content
- Goal: 6 independent perspectives on SAME ground truth → consensus

**10.2.5 - Prepare metadata context:**

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
- Particularly useful when curation excluded 95%+ of files and context seems missing
- Access full commit history, all files, complete implementation
- Examples: understanding test patterns, seeing excluded examples, checking build configs

**Knowledge Freshness Protocol:**

IMPORTANT: This knowledge base was curated on ${CURATION_DATE}.

Before implementing any feature:
1. Check CHANGELOG.md or releases since ${CURATION_DATE}
2. If significant changes found (new APIs, breaking changes, major features):
   - STOP and discuss with user: \"The codebase has changed significantly since curation (${CURATION_DATE}). Should we re-curate first, or proceed with current knowledge?\"
   - User decides: re-curate vs. proceed anyway
3. If no relevant changes, proceed with implementation

Don't guess or assume - always check changelog first, then collaborate with user on the decision.
"

echo "$METADATA_CONTEXT"
```

**10.3 - Create proposals directory:**

```bash
mkdir -p ${DEST}/.curation/specialist-proposals
```

**10.4 - Launch 6 parallel agents (ALL ANALYZING SAME CODEBASE):**

**CRITICAL: All 6 agents must read RepoPrompt specialist first:**

```
Read: /Users/MN/GITHUB/.knowledge/curated-docs-web/repoprompt.com/SPECIALIST-PROMPT.md
```

**PHILOSOPHY:**

- All agents analyze SAME full codebase independently
- Goal: Create 10X ENGINEER EXPERTISE
- NOT navigation guide, NOT Q&A knowledge base
- Focus: What makes agent automatically choose optimal patterns

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
  - Full curated codebase selected
  - Code maps for API structure
  - Full source for implementation reality

  Required metadata (include verbatim):
  ${METADATA_CONTEXT}

  Your focus: Independent analysis of 10x engineer expertise.

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
  - Full curated codebase selected

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
  - Full curated codebase selected

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
  - Full curated codebase selected

  Required metadata (include verbatim):
  ${METADATA_CONTEXT}

  Your focus: Deep reasoning to identify core patterns that become instinctive.
  Use Sonnet's reasoning capabilities to find patterns that make implementation "just work".

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
  - Full curated codebase selected

  Required metadata (include verbatim):
  ${METADATA_CONTEXT}

  Your focus: Deep expertise analysis using Opus-level reasoning.
  Identify architectural decisions that happen automatically and cutting-edge patterns.

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
  - Full curated codebase selected

  Required metadata (include verbatim):
  ${METADATA_CONTEXT}

  Your focus: Deep expertise analysis from a third Opus perspective.
  Focus on performance/security considerations internalized by experts.

  Write your complete SPECIALIST-PROMPT.md proposal to:
  ${DEST}/.curation/specialist-proposals/proposal-6-opus-deep.md
  """
```

**10.5 - Synthesize with evaluator (7th agent):**

After ALL 6 agents complete, invoke the synthesis agent:

```
Task 7 (Synthesis with Consensus Finding):
  subagent_type: "general-purpose"
  description: "Synthesize final specialist prompt from 6 independent analyses"
  prompt: """
  PREREQUISITE: Read /Users/MN/GITHUB/.knowledge/curated-docs-web/repoprompt.com/SPECIALIST-PROMPT.md

  You have 6 independent specialist prompt proposals from agents analyzing the SAME codebase.

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
  5. **Preserve PATTERN KNOWLEDGE:** Keep internalized expertise, not just descriptions
  6. **Maintain 10X Engineer EXPERTISE FOCUS:** Create 10x engineer instincts, not Q&A database

  CRITICAL PHILOSOPHY (enforce in synthesis):
  Create 10X ENGINEER EXPERTISE:
  - Agent reads spec → automatically knows optimal implementation
  - Instinctive pattern recognition (not conscious decisions)
  - Automatic optimization awareness (performance/security by default)
  - Cutting-edge pattern knowledge (stable + canary/beta)
  - NEVER abstract/paraphrase implementations
  - Curated code is ground truth (preserved verbatim)

  What to AVOID in synthesis:
  - ❌ Q&A format: "When should you...?"
  - ❌ Navigation focus: "Feature X is in file Y"
  - ❌ Concept explanations: "This allows you to..."
  - ❌ Abstract summaries that lose implementation reality

  What to CREATE:
  - ✅ Pattern recognition: "For requirement X, instinctively apply pattern Y"
  - ✅ Automatic decisions: "This naturally gets optimized/cached/pre-rendered"
  - ✅ Cutting-edge awareness: "Latest approach is Z (canary/beta)"
  - ✅ Performance/security instincts: "By default, do X for security"

  Quality criteria:
  - Role definition: 10x engineer specialist in this domain
  - Knowledge base: What curated code preserves (verbatim implementation)
  - Internalized expertise: Patterns that become automatic
  - Implementation instincts: Decisions made without prompting
  - Cutting-edge awareness: Latest patterns (stable + canary/beta)
  - Performance/security defaults: What experts do automatically
  - Knowledge boundaries: Clear scope and limitations

  Required structure (use XML tags):
  - <role>: 10x engineer specialist identity
  - <knowledge_base>: Curated code structure and what it preserves
  - <metadata>: Curation date, activity level, staleness check instructions
  - <internalized_expertise>: Patterns and decisions that become automatic
  - <implementation_instincts>: What agent does by default
  - <cutting_edge>: Latest patterns including canary/beta
  - <initialization>: How specialist agent bootstraps

  CRITICAL: <metadata> section MUST include:
  - Curation date (YYYY-MM-DD)
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
  - Validation: Does this create 10x engineer expertise?
  - Confirmation: Metadata section included with all required fields?
  """
```

**10.6 - Automatic cleanup:**

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

**10.7 - Validate specialist prompt:**

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

**10.8 - Update manifest:**

```bash
# Update knowledge base manifest
HAS_SPECIALIST=$([ -f "${DEST}/SPECIALIST-PROMPT.md" ] && echo "true" || echo "false")
/Users/MN/GITHUB/.knowledge-builder/tools/update-manifest.sh \
    "code_repos" \
    "${REPO_NAME}" \
    "curated-code-repo/${REPO_NAME}" \
    "${HAS_SPECIALIST}"
```

Print completion:

```
✅ CURATION COMPLETE (RepoPrompt-Enhanced)
✅ SPECIALIST-PROMPT.md GENERATED (6-agent consensus + Opus synthesis)
✅ MANIFEST UPDATED

🎯 Enhancement Summary:
- All 6 agents analyzed SAME full codebase
- Synthesis found consensus across independent perspectives
- Navigation-focused (points to actual code, no abstraction)
- God-like intuition for finding implementations

Resource ready: ${DEST}/
```

## ERROR HANDLING

- If RepoPrompt MCP not available: EARLY EXIT at prerequisite step 2 with fatal error message
- If GitHub API is truncated: Note it, proceed, reconcile after clone
- If validation fails: MUST fix and re-validate, don't proceed
- If test files found post-clone: MUST fix sparse-checkout
- If docs directories found post-clone: MUST fix sparse-checkout
- If specialist prompt has abstraction anti-patterns: WARN but don't block

## SUCCESS CRITERIA

✅ Zero test files in curated output
✅ Zero docs/doc/documentation directories in curated output
✅ Canonical schema with proper reasons
✅ sparse-checkout has global exclusions
✅ Specialist creates 10X ENGINEER EXPERTISE
✅ Agent reads spec → automatically knows optimal implementation
✅ Agent makes decisions instinctively, without prompting
✅ Specialist includes cutting-edge patterns (stable + canary/beta)
✅ 6-agent consensus achieved in synthesis
✅ Every included file creates deep internalized expertise
✅ Implementation preserved verbatim, no paraphrasing
✅ NOT a Q&A database or navigation guide

## REPOPROMPT ADVANTAGES SUMMARY

**Where RepoPrompt transforms the workflow:**

1. **Step 4 (Optional):** Validate patterns with code structure

   - Files with codemaps = actual code in supported languages
   - Built-in qualitative filter for "what's implementation?"

2. **Step 10 (Critical):** Enhanced specialist prompt generation

   - All 6 agents get SAME full context via RepoPrompt workspace
   - Code Maps for API structure understanding (60-80% token efficiency)
   - Full source for implementation reality
   - `list_codemaps_tree` for hierarchical architecture
   - Token stats to validate curation quality
   - Consensus from independent analyses of same ground truth

3. **10X Engineer Expertise Creation:**

   - All agents have RepoPrompt capabilities for deep analysis
   - Can analyze patterns that create automatic decision-making
   - Identify what makes implementation "just work" on first try
   - Focus on internalized knowledge, not navigation

4. **Quality Validation:**
   - Code Maps confirm API surface completeness
   - Token stats ensure reasonable context size
   - Structural validation via codemaps (not just path patterns)
   - Anti-pattern detection (Q&A, navigation, abstraction)
   - Expertise indicator validation

## OUTPUT LOCATIONS

- **Curated code**: `${DEST}/` (sparse clone, implementation only)
- **Planning/meta**: `${PROJECT_DIR}/` (JSON + YAML)
- **API snapshot**: `${SNAPSHOT_DIR}/github-api-tree.json` (shared)
- **Specialist prompt**: `${DEST}/SPECIALIST-PROMPT.md` (10x engineer expertise)
- **Proposals archive**: `${DEST}/.curation/specialist-proposals-archive.tar.gz`

## FORBIDDEN ACTIONS

- NO Markdown files in curated output (except SPECIALIST-PROMPT.md at root)
- NO custom reason strings (use exact 3 formats)
- NO test files in output
- NO docs in output
- NO asking user for paths/branches
- NO proceeding past failed validation
- NO abstracting/paraphrasing implementations in specialist prompt
- NO partitioning agent attention (all 6 get same full context)
