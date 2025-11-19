# Test Instructions: Code Curation Workflow

## Your Task

You are testing the newly migrated code curation system. Follow the PROMPT.md instructions exactly.

**Working Directory**: `/Users/MN/GITHUB` (initiate agent from this path)

**Repository to curate**: https://github.com/unclecode/crawl4ai

**Prompt to follow**: /Users/MN/GITHUB/.knowledge-builder/curated-code-builder/PROMPT.md

## Why This Working Directory?
- All absolute paths in the system assume `/Users/MN/GITHUB` as the base
- Sync scripts use relative paths that resolve correctly from here
- PROMPT.md references absolute paths starting with `/Users/MN/GITHUB/`

## CRITICAL RULES

### 1. NO IMPROVISATION
- Follow PROMPT.md steps EXACTLY as written
- Do NOT skip steps or reorder them
- Do NOT modify paths or try "fixes"
- Do NOT proceed if something is unclear

### 2. STOP AND ASK IF:
- Any file path doesn't exist that should exist
- Any command fails with an error
- MANIFEST.yaml format is unclear or missing
- Staleness check logic is confusing
- Any step in PROMPT.md is ambiguous
- You encounter any error you didn't expect
- You're unsure whether to proceed

### 3. REPORT EVERYTHING
When you encounter issues, report:
```
ISSUE ENCOUNTERED:
- Step number: [which step from PROMPT.md]
- What I tried: [exact command/action]
- What happened: [exact error or unexpected result]
- What I think should happen: [expected behavior]

QUESTION FOR USER:
[Your specific question about how to proceed]
```

### 4. DO NOT:
- Create directories that don't exist (except as explicitly instructed in PROMPT.md)
- Modify sync scripts
- Change MANIFEST.yaml manually
- Work around errors
- Assume anything

### 5. DO:
- Print acknowledgement: `ACK: ReadConstraints→Scaffold→Snapshot→Analyze→Derive→Validate→Clone→Verify`
- Execute each step verbatim
- Verify outputs after each step
- Ask questions when stuck

## Expected Happy Path

If everything works correctly, you should:

1. **Step 0**: Check MANIFEST.yaml, run full-repo-sync if needed
2. **Step 1**: Read CONSTRAINTS.md
3. **Step 2**: Run scaffold.sh
4. **Step 3**: Fetch GitHub API snapshot
5. **Steps 4-9**: Analysis, curation, validation, clone, verify

**Final output should be**: `.knowledge/curated-code/unclecode-crawl4ai/` with minimal code-only content

## Success Criteria

Report success when:
- [ ] `.knowledge/curated-code/unclecode-crawl4ai/` exists
- [ ] Contains ONLY code (no tests, no docs)
- [ ] Post-clone verification passed (zero test files found)

## If You Complete Successfully

Report:
```
SUCCESS:
- Output location: [path]
- File count: [number]
- Size: [du -sh output]
- Verification passed: [yes/no]
- Any warnings encountered: [list or "none"]
```

## Remember

This is a TEST. We want to find issues. Stopping to ask questions is SUCCESS, not failure. Do not try to work around problems - report them so we can fix the system.
