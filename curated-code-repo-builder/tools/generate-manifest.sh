#!/usr/bin/env bash
set -euo pipefail

# Generate a JSON decision tree for a curated repo and save a pristine GitHub API tree snapshot.
# Usage: .context-builder/tools/generate-manifest.sh <owner-repo> [branch]

if [ $# -lt 1 ]; then
  echo "Usage: $0 <owner-repo> [branch]" >&2
  exit 1
fi

OR="$1"
BR="${2:-}"
BUILDER_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_DIR="${BUILDER_ROOT}/projects/${OR}"
CYAML="${PROJECT_DIR}/curation.yaml"
SPARSE="${PROJECT_DIR}/sparse-checkout"
OUT_TREE_JSON="${PROJECT_DIR}/curated-tree.json"

if [ ! -f "$CYAML" ] || [ ! -f "$SPARSE" ]; then
  echo "ERROR: Missing curation.yaml or sparse-checkout under ${PROJECT_DIR}" >&2
  exit 1
fi

python3 - "$OR" "$BR" "$CYAML" "$SPARSE" "$OUT_TREE_JSON" "$BUILDER_ROOT" << 'PY'
import sys, json, re, subprocess, datetime, yaml  # type: ignore
from fnmatch import fnmatch
import os

owner_repo = sys.argv[1]
branch_arg = sys.argv[2]
curation_yaml = sys.argv[3]
sparse_file = sys.argv[4]
out_tree_json = sys.argv[5]
builder_root = sys.argv[6]

with open(curation_yaml,'r') as f:
    cur = yaml.safe_load(f)

repo_url = cur.get('repo')
branch = branch_arg or cur.get('branch','main')

def gh_api(path):
    try:
        r = subprocess.run(['gh','api',path], check=True, capture_output=True, text=True)
        return json.loads(r.stdout)
    except Exception:
        import urllib.request, json as _json
        with urllib.request.urlopen('https://api.github.com'+path) as resp:
            return _json.load(resp)

def repo_parts(url):
    m = re.search(r"github\.com[:/]+([^/]+)/([^/]+?)(?:\.git)?(?:$|/)", url)
    if not m:
        raise SystemExit(f"Cannot parse owner/repo from {url}")
    return m.group(1), m.group(2)

owner, repo = repo_parts(repo_url)

# Fetch API tree and commit (pristine snapshot)
branch_info = gh_api(f"/repos/{owner}/{repo}")
default_branch = branch_info.get('default_branch','main')
if branch is None or branch == '':
    branch = default_branch

tree = gh_api(f"/repos/{owner}/{repo}/git/trees/{branch}?recursive=1")
blobs = [e for e in tree.get('tree',[]) if e.get('type')=='blob']

commit = gh_api(f"/repos/{owner}/{repo}/commits/{branch}")
sha = commit.get('sha')

# Save API snapshots (exact JSON, no reformat)
snap_dir = os.path.join(builder_root, 'snapshots', f'{owner}-{repo}', sha or 'unknown')
os.makedirs(snap_dir, exist_ok=True)
with open(os.path.join(snap_dir,'github-api-tree.json'),'w') as f:
    # Write bytes as-is: no sorting, no pretty prints
    f.write(json.dumps(tree))

def load_sparse_patterns(path):
    pats=[]
    with open(path,'r') as f:
        for line in f:
            s=line.strip()
            if not s or s.startswith('#'): continue
            if s.startswith('/'):
                s=s[1:]
            pats.append(s)
    return pats

def load_globs(lst):
    pats=[]
    for s in lst or []:
        if isinstance(s,str):
            s=s.strip().strip('"').strip("'")
            if s.startswith('/'):
                s=s[1:]
            pats.append(s)
    return pats

include_pats = load_sparse_patterns(sparse_file)
exclude_pats = load_globs(cur.get('exclude',[]))

def match_any(path, patterns):
    return any(fnmatch(path, p) for p in patterns)

def include_reason(path):
    for p in include_pats:
        if fnmatch(path, p):
            return f"Included by pattern '{p}'"
    return "Included (fallback)"

def exclude_reason(path):
    for p in exclude_pats:
        if fnmatch(path, p):
            return f"Excluded by pattern '{p}'"
    return "Outside include patterns"

class Node:
    __slots__=("name","children","files","kept","reasons")
    def __init__(self, name):
        self.name=name
        self.children={}
        self.files=[]  # list[(path, keep:bool, reason:str)]
        self.kept='mixed'
        self.reasons=[]

root=Node("")

def add_file(path, kept, reason):
    parts=path.split('/')
    node=root
    for part in parts[:-1]:
        node=node.children.setdefault(part, Node(part))
    node.files.append((path, kept, reason))

for e in tree.get('tree',[]):
    if e.get('type')!='blob':
        continue
    p=e['path']
    kept=match_any(p, include_pats) and not match_any(p, exclude_pats)
    reason = include_reason(p) if kept else exclude_reason(p)
    add_file(p, kept, reason)

def collapse(node):
    flags=[k for (_,k,_) in node.files]
    reasons=[r for (_,_,r) in node.files]
    for child in node.children.values():
        collapse(child)
        if child.kept=='keep_all':
            flags.append(True)
            reasons.extend(child.reasons)
        elif child.kept=='omit_all':
            flags.append(False)
            reasons.extend(child.reasons)
        else:
            flags.append(None)
    if not flags:
        node.kept='mixed'
    elif all(f is True for f in flags):
        node.kept='keep_all'
    elif all(f is False for f in flags):
        node.kept='omit_all'
    else:
        node.kept='mixed'
    uniq=[]
    for r in reasons:
        if r not in uniq:
            uniq.append(r)
        if len(uniq)>=3:
            break
    node.reasons=uniq

collapse(root)

def export_entries(node, prefix=""):
    entries=[]
    for name in sorted(node.children.keys()):
        child=node.children[name]
        path = f"{prefix}{name}" if not prefix else f"{prefix}/{name}"
        entries.append({'path': path+'/', 'node': 'dir', 'decision': child.kept, 'reasons': child.reasons})
        if child.kept=='mixed':
            entries.extend(export_entries(child, path))
    # For mixed nodes, include direct file decisions
    if prefix:
        # resolve current node from prefix
        parts=prefix.split('/')
        cur=root
        for p in parts:
            if not p:
                continue
            cur=cur.children.get(p, cur)
    else:
        cur=root
    if cur.kept=='mixed':
        for (p,k,r) in sorted(cur.files, key=lambda t: t[0]):
            entries.append({
                'path': p,
                'node': 'file',
                'decision': 'keep' if k else 'omit',
                'reasons': [r] if r else []
            })
    return entries

entries = export_entries(root)

with open(out_tree_json,'w') as f:
    json.dump({
        'repo': f'{owner}/{repo}',
        'branch': branch,
        'commit': sha,
        'truncated': bool(tree.get('truncated')),
        'entries': entries
    }, f, indent=2)

print(f"Wrote {out_tree_json} and snapshot {os.path.join(snap_dir,'github-api-tree.json')}")
PY
