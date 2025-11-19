#!/usr/bin/env python3
"""
Cross-validate scraper outputs to detect incomplete or failed scraping
Compares httrack, crawl4ai, and playwright outputs against sitemap ground truth
"""

import json
import sys
from pathlib import Path


def validate_scrapers(domain_dir: str) -> dict:
    """
    Validate all scraper outputs for a domain

    Args:
        domain_dir: Path to domain directory (e.g., .../full-docs-website/repoprompt.com)

    Returns:
        Validation report dict
    """
    domain_path = Path(domain_dir)

    # Load sitemap (ground truth from playwright)
    sitemap_file = domain_path / "sitemap.json"

    if not sitemap_file.exists():
        return {
            "status": "ERROR",
            "error": f"Sitemap not found at {sitemap_file}",
            "recommendation": "Playwright scraper must run to generate sitemap ground truth"
        }

    with open(sitemap_file) as f:
        sitemap = json.load(f)

    ground_truth_sections = sitemap.get("scraped_sections", 0)
    ground_truth_dirs = set(sitemap.get("directories", []))

    report = {
        "domain": domain_path.name,
        "ground_truth": {
            "sections": ground_truth_sections,
            "directories": len(ground_truth_dirs),
            "coverage": sitemap.get("coverage", 0),
            "scraper": sitemap.get("scraper", "unknown")
        },
        "scrapers": {}
    }

    # Validate httrack
    httrack_path = domain_path / "httrack"
    if httrack_path.exists():
        html_files = list(httrack_path.rglob("*.html"))
        # Exclude HTTrack's own files (index.html, hts-cache, etc.)
        doc_files = [f for f in html_files if 'hts-' not in str(f) and 'index.html' not in f.name]

        # Check if httrack has tree structure (multiple subdirectories with content)
        subdirs = set()
        for f in doc_files:
            # Get parent directory relative to httrack root
            rel_path = f.relative_to(httrack_path)
            if len(rel_path.parts) > 1:  # Has subdirectory
                subdirs.add(rel_path.parts[0])

        has_tree_structure = len(subdirs) >= 3  # At least 3 section directories

        report["scrapers"]["httrack"] = {
            "exists": True,
            "html_files": len(doc_files),
            "total_files": len(html_files),
            "subdirectories": len(subdirs),
            "has_tree_structure": has_tree_structure,
            "verdict": "COMPLETE" if len(doc_files) >= ground_truth_sections * 0.8 else "INCOMPLETE",
            "notes": "React SPA shell (no content)" if len(doc_files) < 5 else
                     f"Full HTML mirror with tree structure ({len(subdirs)} sections)" if has_tree_structure else
                     "HTML files but flat structure"
        }
    else:
        report["scrapers"]["httrack"] = {
            "exists": False,
            "verdict": "MISSING"
        }

    # Validate crawl4ai
    crawl4ai_path = domain_path / "crawl4ai"
    if crawl4ai_path.exists():
        content_file = crawl4ai_path / "content.md"

        if content_file.exists():
            with open(content_file) as f:
                content = f.read()

            # Try to parse as JSON
            try:
                data = json.loads(content)
                raw_markdown = data.get("markdown", {}).get("raw_markdown", "")
                lines = raw_markdown.split('\n')
                sections = [l for l in lines if l.startswith('## ')]

                report["scrapers"]["crawl4ai"] = {
                    "exists": True,
                    "lines": len(lines),
                    "sections_detected": len(sections),
                    "expected_sections": ground_truth_sections,
                    "coverage": len(sections) / ground_truth_sections if ground_truth_sections > 0 else 0,
                    "verdict": "COMPLETE" if len(sections) >= ground_truth_sections * 0.8 else "INCOMPLETE",
                    "notes": "TOC-only capture" if len(lines) < 300 else "Full content"
                }
            except json.JSONDecodeError:
                # Plain markdown
                lines = content.split('\n')
                sections = [l for l in lines if l.startswith('## ')]

                report["scrapers"]["crawl4ai"] = {
                    "exists": True,
                    "lines": len(lines),
                    "sections_detected": len(sections),
                    "expected_sections": ground_truth_sections,
                    "coverage": len(sections) / ground_truth_sections if ground_truth_sections > 0 else 0,
                    "verdict": "COMPLETE" if len(sections) >= ground_truth_sections * 0.8 else "INCOMPLETE",
                    "notes": "Plain markdown format"
                }
        else:
            report["scrapers"]["crawl4ai"] = {
                "exists": True,
                "verdict": "ERROR",
                "notes": "Directory exists but content.md missing"
            }
    else:
        report["scrapers"]["crawl4ai"] = {
            "exists": False,
            "verdict": "MISSING"
        }

    # Validate playwright
    playwright_path = domain_path / "playwright"
    if playwright_path.exists():
        md_files = list(playwright_path.rglob("*.md"))
        directories = [d.name for d in playwright_path.iterdir() if d.is_dir()]

        report["scrapers"]["playwright"] = {
            "exists": True,
            "markdown_files": len(md_files),
            "directories": len(directories),
            "expected_sections": ground_truth_sections,
            "coverage": len(md_files) / ground_truth_sections if ground_truth_sections > 0 else 0,
            "verdict": "COMPLETE" if len(md_files) >= ground_truth_sections * 0.9 else "INCOMPLETE",
            "notes": "Directory tree structure (ground truth)"
        }
    else:
        report["scrapers"]["playwright"] = {
            "exists": False,
            "verdict": "MISSING"
        }

    # Overall verdict
    complete_scrapers = [
        name for name, data in report["scrapers"].items()
        if data.get("verdict") == "COMPLETE"
    ]

    report["overall"] = {
        "complete_scrapers": complete_scrapers,
        "incomplete_scrapers": [
            name for name, data in report["scrapers"].items()
            if data.get("verdict") == "INCOMPLETE"
        ],
        "missing_scrapers": [
            name for name, data in report["scrapers"].items()
            if data.get("verdict") == "MISSING"
        ],
        "recommendation": ""
    }

    # Generate recommendation
    if "playwright" in complete_scrapers:
        if "crawl4ai" not in complete_scrapers and "httrack" not in complete_scrapers:
            report["overall"]["recommendation"] = "Use playwright/ for curation (only complete source)"
        elif "crawl4ai" in complete_scrapers:
            report["overall"]["recommendation"] = "Use crawl4ai/ or playwright/ for curation (both complete)"
        else:
            report["overall"]["recommendation"] = "Use playwright/ for curation (most complete)"
    else:
        report["overall"]["recommendation"] = "WARNING: No complete scraper output found. Manual review required."

    return report


def print_report(report: dict):
    """Print human-readable validation report"""
    print("\n" + "="*80)
    print(f"SCRAPER VALIDATION REPORT: {report['domain']}")
    print("="*80)

    print(f"\n📊 Ground Truth (from sitemap):")
    gt = report['ground_truth']
    print(f"   Sections: {gt['sections']}")
    print(f"   Directories: {gt['directories']}")
    print(f"   Coverage: {gt['coverage']:.1%}")

    print(f"\n🔍 Scraper Results:")

    for scraper, data in report['scrapers'].items():
        verdict = data.get('verdict', 'UNKNOWN')
        emoji = {
            'COMPLETE': '✅',
            'INCOMPLETE': '⚠️',
            'MISSING': '❌',
            'ERROR': '🔴'
        }.get(verdict, '❓')

        print(f"\n   {emoji} {scraper.upper()}: {verdict}")

        if data.get('exists'):
            if scraper == 'httrack':
                print(f"      HTML files: {data.get('html_files', 0)}")
                print(f"      Notes: {data.get('notes', '')}")
            elif scraper == 'crawl4ai':
                print(f"      Lines: {data.get('lines', 0)}")
                print(f"      Sections: {data.get('sections_detected', 0)}/{data.get('expected_sections', 0)}")
                print(f"      Coverage: {data.get('coverage', 0):.1%}")
                print(f"      Notes: {data.get('notes', '')}")
            elif scraper == 'playwright':
                print(f"      Files: {data.get('markdown_files', 0)}")
                print(f"      Directories: {data.get('directories', 0)}")
                print(f"      Coverage: {data.get('coverage', 0):.1%}")
                print(f"      Notes: {data.get('notes', '')}")

    print(f"\n💡 Recommendation:")
    print(f"   {report['overall']['recommendation']}")

    if report['overall']['incomplete_scrapers']:
        print(f"\n⚠️  Incomplete scrapers: {', '.join(report['overall']['incomplete_scrapers'])}")
        print(f"   These scrapers failed to capture complete content.")
        print(f"   Use playwright output for curation.")

    print("\n" + "="*80 + "\n")


def main():
    """CLI entry point"""
    if len(sys.argv) != 2:
        print("Usage: validate_scrapers.py <domain_dir>", file=sys.stderr)
        print("Example: validate_scrapers.py /Users/MN/GITHUB/.knowledge/full-docs-website/repoprompt.com", file=sys.stderr)
        sys.exit(1)

    domain_dir = sys.argv[1]

    if not Path(domain_dir).exists():
        print(f"ERROR: Directory not found: {domain_dir}", file=sys.stderr)
        sys.exit(1)

    report = validate_scrapers(domain_dir)

    if "error" in report:
        print(f"ERROR: {report['error']}", file=sys.stderr)
        print(f"RECOMMENDATION: {report['recommendation']}", file=sys.stderr)
        sys.exit(1)

    # Print human-readable report
    print_report(report)

    # Save JSON report
    report_file = Path(domain_dir) / "validation-report.json"
    with open(report_file, 'w') as f:
        json.dump(report, f, indent=2)

    print(f"📝 Full report saved to: {report_file}")

    # Exit code based on completeness
    if not report['overall']['complete_scrapers']:
        sys.exit(1)  # No complete scrapers

    sys.exit(0)


if __name__ == "__main__":
    main()
