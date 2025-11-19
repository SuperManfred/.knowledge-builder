#!/usr/bin/env python3
"""
crawl4ai scraper with SPA support for full-docs-website-sync
Uses the correct parameters to handle single-page apps with hash routing

Uses web-context-builder's venv which has crawl4ai installed
"""

import asyncio
import json
import sys
import os
from datetime import datetime
from pathlib import Path

# Add web-context-builder venv to path if not already activated
venv_site_packages = Path.home() / "GITHUB/.web-context-builder/venv/lib/python3.13/site-packages"
if venv_site_packages.exists() and str(venv_site_packages) not in sys.path:
    sys.path.insert(0, str(venv_site_packages))

try:
    from crawl4ai import AsyncWebCrawler
except ImportError:
    print("ERROR: crawl4ai not installed", file=sys.stderr)
    print("       Install with: pipx install crawl4ai", file=sys.stderr)
    print("       Or: pip install crawl4ai", file=sys.stderr)
    print(f"       Or: Ensure web-context-builder venv exists at {venv_site_packages}", file=sys.stderr)
    sys.exit(1)


async def scrape_website(url: str, output_dir: str) -> bool:
    """
    Scrape a documentation website using crawl4ai with SPA support

    Args:
        url: Website URL to scrape
        output_dir: Directory to save output (will create crawl4ai/ subdirectory)

    Returns:
        True if successful, False otherwise
    """
    output_path = Path(output_dir) / "crawl4ai"
    output_path.mkdir(parents=True, exist_ok=True)

    print(f"    Crawling {url} with SPA support...", file=sys.stderr)

    try:
        async with AsyncWebCrawler(verbose=False) as crawler:
            result = await crawler.arun(
                url=url,
                # ⭐ CRITICAL FOR SPAs: Wait for JavaScript to fully load
                wait_for="networkidle",
                # ⭐ CRITICAL FOR SPAs: Give React/Vue time to render
                delay_before_return_html=3.0,
                # Nice-to-haves
                remove_overlay_elements=True,
                exclude_external_links=True,
            )

            if not result.success:
                print(f"ERROR: Crawl failed: {result.error_message}", file=sys.stderr)
                return False

            # Extract the markdown content
            markdown = result.markdown

            # Save as JSON (matching existing format for compatibility)
            content_file = output_path / "content.md"
            output_data = {
                "url": url,
                "markdown": {
                    "raw_markdown": markdown,
                },
                "scraped_at": datetime.utcnow().isoformat() + "Z",
                "scraper": "crawl4ai-spa",
                "success": True,
                "stats": {
                    "markdown_length": len(markdown),
                    "links_found": len(result.links.get('internal', [])),
                }
            }

            with open(content_file, 'w') as f:
                json.dump(output_data, f, indent=2)

            print(f"    Saved markdown to: {content_file}", file=sys.stderr)

            # Create metadata file
            metadata_file = output_path / "metadata.json"
            metadata = {
                "url": url,
                "scraped_at": output_data["scraped_at"],
                "scraper": "crawl4ai-spa",
                "output": "content.md",
                "stats": output_data["stats"]
            }

            with open(metadata_file, 'w') as f:
                json.dump(metadata, f, indent=2)

            print(f"    Saved metadata to: {metadata_file}", file=sys.stderr)
            print(f"    Stats: {len(markdown):,} chars, {len(result.links.get('internal', []))} links", file=sys.stderr)

            return True

    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        return False


def main():
    """CLI entry point"""
    if len(sys.argv) != 3:
        print("Usage: crawl4ai_scraper.py <url> <output_dir>", file=sys.stderr)
        sys.exit(1)

    url = sys.argv[1]
    output_dir = sys.argv[2]

    success = asyncio.run(scrape_website(url, output_dir))
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
