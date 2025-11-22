#!/bin/bash
set -euo pipefail

FILTERED_TREE="/Users/MN/GITHUB/.knowledge-builder/curated-docs-repo-builder/snapshots/wxt-dev-wxt/78f8434a0691a2e1a5be80fbebad2a4cc07c73a0/filtered-tree.txt"
OUTPUT_JSON="/Users/MN/GITHUB/.knowledge-builder/curated-docs-repo-builder/projects/wxt-dev-wxt/curated-tree.json"

# Start JSON
cat > "$OUTPUT_JSON" << 'EOFHEADER'
{
  "repo": "wxt-dev/wxt",
  "branch": "main",
  "commit": "78f8434a0691a2e1a5be80fbebad2a4cc07c73a0",
  "truncated": false,
  "entries": [
EOFHEADER

# Process each line and generate entries
awk '
BEGIN {
    first = 1
}
{
    # Extract path from git tree format
    split($0, parts, "\t")
    path = parts[2]

    # Skip if no path
    if (path == "") next

    # Determine if directory (040000 tree) or file (100644 blob)
    node = ($2 == "tree") ? "dir" : "file"

    # Normalize directory paths to end with /
    if (node == "dir" && path !~ /\/$/) {
        path = path "/"
    }

    # Determine decision and reasons
    decision = "omit"
    reason = "\"Excluded by pattern '\''*'\''\""

    # INCLUDE patterns
    if (path ~ /^README\.md$/) {
        decision = "keep"
        reason = "\"Included by pattern '\''README.md'\''\""
    }
    else if (path ~ /^docs\//) {
        # Exclude .vitepress infrastructure
        if (path ~ /^docs\/\.vitepress\//) {
            decision = "omit"
            reason = "\"Excluded by pattern '\''docs/.vitepress/**'\''\""
        }
        # Exclude public assets
        else if (path ~ /^docs\/public\//) {
            decision = "omit"
            reason = "\"Excluded by pattern '\''docs/public/**'\''\""
        }
        # Exclude typedoc.json
        else if (path ~ /^docs\/typedoc\.json$/) {
            decision = "omit"
            reason = "\"Excluded by pattern '\''**/*.json'\''\""
        }
        # Keep all markdown and assets
        else if (path ~ /\.(md|mdx|png|svg|jpg|gif)$/) {
            decision = "keep"
            reason = "\"Included by pattern '\''docs/**/*.{md,mdx,png,svg,jpg,gif}'\''\""
        }
        # Keep directories (they might contain docs)
        else if (node == "dir") {
            decision = "mixed"
            reason = "\"Included by pattern '\''docs/**'\''\""
        }
        else {
            decision = "omit"
            reason = "\"Excluded by pattern '\''**/*'\''\""
        }
    }
    else if (path ~ /^packages\/[^\/]+\/README\.md$/) {
        decision = "keep"
        reason = "\"Included by pattern '\''packages/*/README.md'\''\""
    }
    else if (path ~ /^packages\/[^\/]+\/CHANGELOG\.md$/) {
        decision = "keep"
        reason = "\"Included by pattern '\''packages/*/CHANGELOG.md'\''\""
    }
    else if (path ~ /^templates\/[^\/]+\/README\.md$/) {
        decision = "keep"
        reason = "\"Included by pattern '\''templates/*/README.md'\''\""
    }
    # Parent directories of included files need to be mixed
    else if (path ~ /^docs\/$/ || path ~ /^packages\/$/ || path ~ /^packages\/[^\/]+\/$/ || path ~ /^templates\/$/ || path ~ /^templates\/[^\/]+\/$/) {
        decision = "mixed"
        reason = "\"Included by pattern '\''docs/**'\''\""
    }
    # Everything else is excluded
    else {
        decision = "omit"
        reason = "\"Outside include patterns\""
    }

    # Print JSON entry
    if (!first) print ","
    first = 0
    printf "    {\"path\": \"%s\", \"node\": \"%s\", \"decision\": \"%s\", \"reasons\": [%s]}", path, node, decision, reason
}
END {
    print ""
}
' "$FILTERED_TREE" >> "$OUTPUT_JSON"

# Close JSON
cat >> "$OUTPUT_JSON" << 'EOFFOOTER'
  ]
}
EOFFOOTER

echo "✅ Generated curated-tree.json with $(jq '.entries | length' "$OUTPUT_JSON") entries"
echo "   Keep decisions: $(jq '[.entries[] | select(.decision == "keep")] | length' "$OUTPUT_JSON")"
echo "   Mixed decisions: $(jq '[.entries[] | select(.decision == "mixed")] | length' "$OUTPUT_JSON")"
echo "   Omit decisions: $(jq '[.entries[] | select(.decision == "omit")] | length' "$OUTPUT_JSON")"
