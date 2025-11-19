Generic Curation Template
=========================

Use this folder to scaffold a new curated project under `.context-builder/projects/<owner>-<repo>/` (meta only). The code‑only sparse checkout will live at `.context/<owner>-<repo>/`.

Steps
1) Create `.context-builder/projects/<owner>-<repo>/`
2) Copy files:
   - `curation.yaml.example` → `.context-builder/projects/<owner>-<repo>/curation.yaml` (edit repo/branch/date)
   - `sparse-checkout.example` → `.context-builder/projects/<owner>-<repo>/sparse-checkout` (tailor patterns)
   - `scripts/curate.sh.template` → `.context-builder/projects/<owner>-<repo>/scripts/curate.sh`
3) Generate curated decisions + snapshot (analysis + plan):
   - `.context-builder/tools/generate-manifest.sh <owner-repo> [branch]`
   - Writes curated decisions: `.context-builder/projects/<owner>-<repo>/curated-tree.json`
   - Saves pristine API snapshot: `.context-builder/snapshots/<owner>-<repo>/<commit>/github-api-tree.json` (exact GitHub response)
4) Clone (one‑shot):
   - `bash .context-builder/projects/<owner>-<repo>/scripts/curate.sh` (clones to `.context/<owner>-<repo>`)

Notes
- Keep `.context` clean (code‑only). All meta and snapshots live under `.context-builder/`.
