#!/usr/bin/env bash
set -euo pipefail

# Update knowledge base manifest after curation
# Usage: ./update-manifest.sh <type> <name> <path> <has_specialist>
# Example: ./update-manifest.sh code_repos unclecode-crawl4ai curated-code-repo/unclecode-crawl4ai true

TYPE="$1"           # code_repos, docs_repos, or docs_web
NAME="$2"           # Resource name
PATH="$3"           # Resource path
HAS_SPECIALIST="$4" # true or false

MANIFEST_FILE="/Users/MN/GITHUB/.knowledge/MANIFEST.yaml"

python3 << PYTHON
import yaml
from datetime import datetime

manifest_file = "${MANIFEST_FILE}"
resource_type = "${TYPE}"
resource_name = "${NAME}"
resource_path = "${PATH}"
has_specialist = "${HAS_SPECIALIST}" == "true"

# Load existing manifest
try:
    with open(manifest_file, 'r') as f:
        manifest = yaml.safe_load(f) or {}
except FileNotFoundError:
    manifest = {'curated_resources': {}}

# Get or create resource list
resources = manifest.setdefault('curated_resources', {}).setdefault(resource_type, [])

# Find existing entry
existing = next((r for r in resources if r['name'] == resource_name), None)

if existing:
    # Update existing
    existing['path'] = resource_path
    existing['has_specialist'] = has_specialist
else:
    # Add new
    resources.append({
        'name': resource_name,
        'path': resource_path,
        'has_specialist': has_specialist
    })

# Update timestamp
manifest['last_updated'] = datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')

# Write back
with open(manifest_file, 'w') as f:
    yaml.dump(manifest, f, default_flow_style=False, sort_keys=False)

print(f"✅ Manifest updated: {resource_type}/{resource_name}")
PYTHON
