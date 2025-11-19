# Full Repo Sync

Maintains pristine GitHub repository clones.

## Usage

```bash
./sync.sh <github-url> [--branch=BRANCH] [--force]
```

## Examples

```bash
# Clone/update with default branch
./sync.sh https://github.com/vercel/next.js

# Clone/update specific branch
./sync.sh https://github.com/vercel/next.js --branch=canary

# Force re-sync even if fresh
./sync.sh https://github.com/vercel/next.js --force
```

## Behavior

- **First time**: Clones repository to `../.knowledge/full-repo/{owner}-{repo}/`
- **Subsequent**: Checks staleness (>7 days), pulls updates if needed
- **Fresh (<7 days)**: Skips sync unless `--force` flag used
- **Updates**: `../.knowledge/full-repo/MANIFEST.yaml` with metadata

## Dependencies

- `git` (required)
- `yq` (optional, for MANIFEST.yaml updates)
  - Install: `brew install yq`
  - Without yq: manual MANIFEST.yaml entry needed

## Output

```
../.knowledge/full-repo/
├── MANIFEST.yaml           # Registry of all synced repos
├── vercel-next.js/         # Full clone
└── facebook-react/         # Full clone
```
