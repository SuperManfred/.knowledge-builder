#!/usr/bin/env bash
set -euo pipefail

# Orchestrate updates for all curated repos under .context/<owner>-<repo>/scripts/curate.sh

BUILDER_ROOT="$(cd "$(dirname "$0")" && pwd)"
CONTEXT_ROOT="$(cd "$BUILDER_ROOT/.." && pwd)/.context"

shopt -s nullglob
SCRIPTS=("$CONTEXT_ROOT"/*/scripts/curate.sh)

if [ ${#SCRIPTS[@]} -eq 0 ]; then
  echo "No curated repos found under $CONTEXT_ROOT/<owner>-<repo>/scripts/curate.sh"
  exit 0
fi

for script in "${SCRIPTS[@]}"; do
  base="$(basename "$(dirname "$script")")"
  # Skip shadow paths
  if [[ "$script" == *"/_shadow/"* ]]; then
    continue
  fi
  echo "=== Running: $script ==="
  bash "$script"
done

echo "All curated repos updated."

