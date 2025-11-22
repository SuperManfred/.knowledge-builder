#!/usr/bin/env ts-node
/**
 * Generate curation artifacts for wxt-dev/wxt
 * Based on pattern analysis from agent-1-results.md
 */

import * as fs from 'fs';
import * as path from 'path';

const SNAPSHOT_DIR = '/Users/MN/GITHUB/.knowledge-builder/curated-code-repo-builder/snapshots/wxt-dev-wxt/78f8434a0691a2e1a5be80fbebad2a4cc07c73a0';
const PROJECT_DIR = '/Users/MN/GITHUB/.knowledge-builder/curated-code-repo-builder/projects/wxt-dev-wxt';

// Define patterns based on analysis
const INCLUDE_PATTERNS = [
  // Core framework
  'packages/wxt/src/**',
  'packages/wxt/package.json',
  'packages/wxt/tsconfig.json',

  // Representative modules
  'packages/storage/src/**',
  'packages/storage/package.json',
  'packages/i18n/src/**',
  'packages/i18n/package.json',
  'packages/runner/src/**',
  'packages/runner/package.json',

  // Root configuration
  'package.json',
  'pnpm-workspace.yaml',
  'tsconfig.base.json',
  'tsconfig.json',
];

const EXCLUDE_PATTERNS = [
  // Tests
  '**/__tests__/**',
  '**/test/**',
  '**/tests/**',
  '**/*.test.*',
  '**/*.spec.*',
  '**/*.snap',
  '**/e2e/**',
  '**/__snapshots__/**',
  '**/__mocks__/**',
  '**/fixtures/**',

  // Documentation
  'docs/**',
  'doc/**',
  'documentation/**',
  '**/*.md',

  // CI/CD
  '.github/**',

  // Configuration
  '.vscode/**',
  '.codecov.yml',
  '.commitlintrc.yml',
  '.prettierrc.yml',
  '.prettierignore',
  '.markdownlint.json',
  '.markdownlintignore',
  '.gitattributes',

  // Templates and examples
  'templates/**',
  'packages/wxt-demo/**',
  'packages/runner/demo-extension/**',

  // Build/scripts
  'scripts/**',
  'patches/**',

  // Lock files
  'pnpm-lock.yaml',
];

interface Entry {
  path: string;
  node: 'file' | 'dir';
  decision: 'keep_all' | 'omit_all' | 'mixed' | 'keep' | 'omit';
  reasons: string[];
}

function matchesPattern(filePath: string, pattern: string): boolean {
  // Convert glob pattern to regex
  const regexPattern = pattern
    .replace(/\./g, '\\.')
    .replace(/\*\*/g, '.*')
    .replace(/\*/g, '[^/]*');
  const regex = new RegExp(`^${regexPattern}$`);
  return regex.test(filePath);
}

function matchesAnyPattern(filePath: string, patterns: string[]): string | null {
  for (const pattern of patterns) {
    if (matchesPattern(filePath, pattern)) {
      return pattern;
    }
  }
  return null;
}

function determineDecision(filePath: string, isDir: boolean): { decision: Entry['decision'], reasons: string[] } {
  const reasons: string[] = [];

  // Check exclude patterns first
  const excludeMatch = matchesAnyPattern(filePath, EXCLUDE_PATTERNS);
  if (excludeMatch) {
    return {
      decision: isDir ? 'omit_all' : 'omit',
      reasons: [`Excluded by pattern '${excludeMatch}'`]
    };
  }

  // Check include patterns
  const includeMatch = matchesAnyPattern(filePath, INCLUDE_PATTERNS);
  if (includeMatch) {
    return {
      decision: isDir ? 'keep_all' : 'keep',
      reasons: [`Included by pattern '${includeMatch}'`]
    };
  }

  // Default: outside include patterns
  return {
    decision: isDir ? 'omit_all' : 'omit',
    reasons: ['Outside include patterns']
  };
}

async function main() {
  console.log('Reading tree snapshot...');
  const treeContent = fs.readFileSync(path.join(SNAPSHOT_DIR, 'github-api-tree.txt'), 'utf-8');
  const lines = treeContent.trim().split('\n');

  const entries: Entry[] = [];
  const dirEntries = new Map<string, Entry>();

  console.log(`Processing ${lines.length} entries...`);

  for (const line of lines) {
    const parts = line.split('\t');
    if (parts.length < 2) continue;

    const [mode, ...pathParts] = parts;
    const filePath = pathParts.join('\t').trim();
    const isDir = mode.includes('tree');

    const { decision, reasons } = determineDecision(filePath, isDir);

    const entry: Entry = {
      path: isDir ? `${filePath}/` : filePath,
      node: isDir ? 'dir' : 'file',
      decision,
      reasons
    };

    entries.push(entry);

    // Track directories for mixed decision handling
    if (isDir) {
      dirEntries.set(filePath, entry);
    }
  }

  // Sort entries alphabetically by path
  entries.sort((a, b) => a.path.localeCompare(b.path));

  // Generate curated-tree.json
  const curatedTree = {
    repo: 'wxt-dev/wxt',
    branch: 'main',
    commit: '78f8434a0691a2e1a5be80fbebad2a4cc07c73a0',
    truncated: false,
    entries
  };

  const curatedTreePath = path.join(PROJECT_DIR, 'curated-tree.json');
  fs.writeFileSync(curatedTreePath, JSON.stringify(curatedTree, null, 2));
  console.log(`✅ Generated: ${curatedTreePath}`);

  // Generate sparse-checkout
  const sparseCheckout = [
    '# Core wxt framework',
    ...INCLUDE_PATTERNS,
    '',
    '# MANDATORY GLOBAL EXCLUSIONS (DO NOT OMIT)',
    '!**/__tests__/**',
    '!**/test/**',
    '!**/tests/**',
    '!**/*.test.*',
    '!**/*.spec.*',
    '!**/*.snap',
    '!**/__mocks__/**',
    '!**/fixtures/**',
    '!docs/**',
    '!doc/**',
    '!documentation/**',
  ].join('\n');

  const sparseCheckoutPath = path.join(PROJECT_DIR, 'sparse-checkout');
  fs.writeFileSync(sparseCheckoutPath, sparseCheckout);
  console.log(`✅ Generated: ${sparseCheckoutPath}`);

  // Generate curation.yaml
  const curationYaml = [
    `repo: wxt-dev/wxt`,
    `branch: main`,
    `commit: 78f8434a0691a2e1a5be80fbebad2a4cc07c73a0`,
    `date: ${new Date().toISOString().split('T')[0]}`,
    `keep:`,
    ...INCLUDE_PATTERNS.map(p => `  - ${p}`),
    `exclude:`,
    ...EXCLUDE_PATTERNS.map(p => `  - ${p}`),
  ].join('\n');

  const curationYamlPath = path.join(PROJECT_DIR, 'curation.yaml');
  fs.writeFileSync(curationYamlPath, curationYaml);
  console.log(`✅ Generated: ${curationYamlPath}`);

  console.log('\n✅ All artifacts generated successfully');
  console.log(`\nStatistics:`);
  console.log(`  Total entries: ${entries.length}`);
  console.log(`  Keep decisions: ${entries.filter(e => e.decision === 'keep' || e.decision === 'keep_all').length}`);
  console.log(`  Omit decisions: ${entries.filter(e => e.decision === 'omit' || e.decision === 'omit_all').length}`);
}

main().catch(console.error);
