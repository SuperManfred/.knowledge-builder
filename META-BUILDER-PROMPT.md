META PROMPT — Improve the Curator System (Builder)
=================================================

PURPOSE
- You are NOT executing curation for a specific repo.
- You ARE maintaining and improving the curation system so that operational agents (reading `.knowledge-builder/curated-code-builder/PROMPT.md`) produce analysis‑driven, high‑quality, code‑only curations automatically.

ACKNOWLEDGEMENT (Required)
- Before any action, print exactly this single line:
  ACK: Read-Context→Audit→Measure→Refine→Validate→Release

CRITICAL READS (Required First)
1. Read `.knowledge-builder/curated-code-builder/CONTEXT.md` — Understand vision and goals (IMMUTABLE - never modify)
2. Read `.knowledge-builder/curated-code-builder/CONSTRAINTS.md` — Learn invariants and rules (IMMUTABLE - never modify)
3. Read `/Users/MN/AGENTS.md`, `/Users/MN/GITHUB/AGENTS.md` — General agent guidelines

SCOPE OF WORK
1) Audit current system and outputs
   - Read: `.knowledge-builder/curated-code-builder/PROMPT.md`, `_template/*`, `tools/*`
   - Validate every project under `.knowledge-builder/curated-code-builder/projects/*`:
     - curated-tree.json MUST match canonical schema defined in CONSTRAINTS.md
     - Reasons MUST be exactly one of the three allowed formats in CONSTRAINTS.md
     - sparse-checkout MUST be subset of curated keeps
   - Compare snapshots vs curated decisions:
     - Use `.knowledge-builder/curated-code-builder/snapshots/<owner>-<repo>/<commit>/github-api-tree.json` as source of truth
     - Verify INVARIANT compliance: No test files, size limits, naming conventions
     - Flag violations of CONSTRAINTS.md rules

2) Refine the operational prompt and templates
   - Update `.knowledge-builder/curated-code-builder/PROMPT.md` to enforce CONSTRAINTS.md invariants
   - Ensure PROMPT.md serves the vision in CONTEXT.md
   - Keep system generic: derive keeps from measured sizes and runtime structure
   - Update `_template/curation.yaml.example` and `sparse-checkout.example` to align with constraints
   - Ensure all changes support specialist agent architecture from CONTEXT.md

3) Add/maintain validation tooling
   - Build validators that enforce CONSTRAINTS.md invariants
   - Add checks for: zero test files, correct schema, size limits, pattern compliance
   - Handle truncated API snapshots by reconciling from local clone

4) Archive and track changes
   - Before modifying PROMPT.md: Copy current to `CHANGELOG/YYYY-MM-DD/PROMPT.md`
   - Document why changes were made in audit report
   - Ensure changes align with CONTEXT.md goals and CONSTRAINTS.md rules

5) Test and release
   - Run one‑shot flow on 2–3 varied repos to verify compliance
   - Verify each specialist agent can work with their curated domain
   - Follow AGENTS.md commit/push rules

OUTPUTS (Builder)
- Updated `.knowledge-builder/curated-code-builder/PROMPT.md`, `_template/*`, `tools/*` aligned with CONTEXT.md and CONSTRAINTS.md
- Archived previous PROMPT.md in `CHANGELOG/YYYY-MM-DD/`
- Audit report under `.knowledge-builder/curated-code-builder/AUDIT-{date}.md` listing issues and changes

FORBIDDEN ACTIONS (Builder)
- NEVER modify `.knowledge-builder/curated-code-builder/CONTEXT.md` or `.knowledge-builder/curated-code-builder/CONSTRAINTS.md`
- NEVER modify `.knowledge-builder/curated-code-builder/projects/*` or `.knowledge-builder/curated-code-builder/snapshots/*`
- NEVER write to `.knowledge/curated-code/` directly
- NEVER violate invariants defined in CONSTRAINTS.md
- NEVER create Markdown manifests in `.knowledge/curated-code/` (code-only per CONSTRAINTS.md)
