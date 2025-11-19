#!/usr/bin/env python3
"""
Playwright SPA scraper with directory tree output
Uses browser automation to scrape hash-routed SPAs into navigable directory structure
"""

import asyncio
import json
import sys
import re
from datetime import datetime
from pathlib import Path
from urllib.parse import urlparse, parse_qs

try:
    from playwright.async_api import async_playwright
except ImportError:
    print("ERROR: playwright not installed", file=sys.stderr)
    print("       Install with: pip install playwright", file=sys.stderr)
    print("       Then run: playwright install chromium", file=sys.stderr)
    sys.exit(1)


async def extract_navigation_links(page):
    """Extract all unique navigation hash links from the page"""
    result = await page.evaluate("""() => {
        const navLinks = Array.from(document.querySelectorAll('nav a[href^="#"], a[href*="#s="]'));
        const urls = [...new Set(navLinks.map(a => a.href))];
        return urls;
    }""")
    return result


async def get_main_content_text(page):
    """Get the current main content text (for change detection)"""
    return await page.evaluate("""() => {
        const main = document.querySelector('main') ||
                     document.querySelector('[role="main"]') ||
                     document.querySelector('.content') ||
                     document.querySelector('article');
        return main ? main.textContent.substring(0, 500) : null;
    }""")


async def extract_main_content_markdown(page):
    """Extract main content area and convert to clean markdown"""
    content = await page.evaluate("""() => {
        // Find the main content area (try multiple selectors)
        const mainContent = document.querySelector('main') ||
                          document.querySelector('[role="main"]') ||
                          document.querySelector('.content') ||
                          document.querySelector('article');

        if (!mainContent) return null;

        // Helper to convert DOM to markdown
        function elementToMarkdown(element, level = 0) {
            let result = '';

            for (const node of element.childNodes) {
                if (node.nodeType === Node.TEXT_NODE) {
                    const text = node.textContent.trim();
                    if (text) result += text + ' ';
                } else if (node.nodeType === Node.ELEMENT_NODE) {
                    const tag = node.tagName.toLowerCase();

                    // Handle different elements
                    if (tag.match(/^h[1-6]$/)) {
                        const level = parseInt(tag[1]);
                        const text = node.textContent.trim();
                        result += '\\n\\n' + '#'.repeat(level) + ' ' + text + '\\n\\n';
                    } else if (tag === 'p') {
                        result += '\\n\\n' + node.textContent.trim() + '\\n\\n';
                    } else if (tag === 'li') {
                        result += '\\n  * ' + node.textContent.trim();
                    } else if (tag === 'ul' || tag === 'ol') {
                        result += '\\n' + elementToMarkdown(node, level + 1);
                    } else if (tag === 'code') {
                        result += '`' + node.textContent.trim() + '`';
                    } else if (tag === 'strong' || tag === 'b') {
                        result += '**' + node.textContent.trim() + '**';
                    } else if (tag === 'em' || tag === 'i') {
                        result += '*' + node.textContent.trim() + '*';
                    } else if (tag === 'a') {
                        const text = node.textContent.trim();
                        const href = node.getAttribute('href');
                        if (href && !href.startsWith('#')) {
                            result += '[' + text + '](' + href + ')';
                        } else {
                            result += text;
                        }
                    } else if (tag === 'pre') {
                        const code = node.querySelector('code');
                        const lang = code ? (code.className.match(/language-(\\w+)/) || ['', ''])[1] : '';
                        result += '\\n\\n```' + lang + '\\n' + node.textContent.trim() + '\\n```\\n\\n';
                    } else if (tag === 'blockquote') {
                        const lines = node.textContent.trim().split('\\n');
                        result += '\\n\\n' + lines.map(l => '> ' + l).join('\\n') + '\\n\\n';
                    } else if (tag === 'img') {
                        const alt = node.getAttribute('alt') || '';
                        const src = node.getAttribute('src') || '';
                        result += '![' + alt + '](' + src + ')';
                    } else {
                        // For other elements, recurse
                        result += elementToMarkdown(node, level);
                    }
                }
            }

            return result;
        }

        return elementToMarkdown(mainContent).replace(/\\n{3,}/g, '\\n\\n').trim();
    }""")

    return content


def parse_hash_url(url):
    """Parse hash URL to extract section and subsection"""
    # Example: https://repoprompt.com/docs#s=quick-start&ss=installation
    parsed = urlparse(url)

    if not parsed.fragment:
        return None, None

    # Parse query params from hash
    # Handle both #s=section&ss=subsection and #section-subsection formats
    if '=' in parsed.fragment:
        params = {}
        for part in parsed.fragment.split('&'):
            if '=' in part:
                key, value = part.split('=', 1)
                params[key] = value

        section = params.get('s', 'unknown')
        subsection = params.get('ss', 'index')
        return section, subsection
    else:
        # Simple hash like #overview
        return parsed.fragment, 'index'


def sanitize_filename(name):
    """Convert section name to safe filename"""
    # Replace special chars with hyphens
    name = re.sub(r'[^\w\s-]', '', name)
    name = re.sub(r'[-\s]+', '-', name)
    return name.lower().strip('-')


async def scrape_spa_to_tree(base_url: str, output_dir: str) -> bool:
    """
    Scrape SPA with hash routing into directory tree structure

    Args:
        base_url: Website URL (e.g., https://repoprompt.com/docs)
        output_dir: Output directory (e.g., /Users/MN/GITHUB/.knowledge/full-docs-website/repoprompt.com)

    Returns:
        True if successful, False otherwise
    """
    output_path = Path(output_dir) / "playwright"
    output_path.mkdir(parents=True, exist_ok=True)

    print(f"    Launching browser for Playwright scraping...", file=sys.stderr)

    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page()

        # Navigate to base URL
        print(f"    Navigating to {base_url}...", file=sys.stderr)
        await page.goto(base_url, wait_until='domcontentloaded')
        await page.wait_for_timeout(3000)  # Wait for React to render

        # Extract all navigation links
        print(f"    Extracting navigation links...", file=sys.stderr)
        links = await extract_navigation_links(page)
        unique_links = list(set(links))

        print(f"    Found {len(unique_links)} unique sections to scrape", file=sys.stderr)

        # Track scraped sections for sitemap
        scraped_sections = []
        section_dirs = set()

        # Visit each link and extract content
        for i, link in enumerate(unique_links, 1):
            print(f"    [{i}/{len(unique_links)}] Scraping: {link}", file=sys.stderr)

            try:
                # Extract the hash to find the corresponding nav link
                parsed_url = urlparse(link)
                target_hash = parsed_url.fragment

                # Capture baseline content
                old_content = await page.evaluate("""() => {
                    const h1 = document.querySelector('main h1, article h1, .content h1');
                    return h1 ? h1.textContent.substring(0, 200) : null;
                }""")

                # APPROACH: Find and click the actual navigation link instead of using page.goto()
                # This triggers the proper SPA routing that the app expects
                click_succeeded = await page.evaluate(f"""() => {{
                    // Find the nav link with this exact hash
                    const targetLink = document.querySelector('nav a[href="#{target_hash}"], a[href*="#{target_hash}"]');
                    if (targetLink) {{
                        targetLink.click();
                        return true;
                    }}
                    return false;
                }}""")

                if click_succeeded:
                    print(f"      ✓ Clicked nav link for #{target_hash}", file=sys.stderr)
                else:
                    print(f"      ⚠️  Nav link not found, trying direct navigation", file=sys.stderr)
                    # Fallback to direct hash assignment
                    await page.evaluate(f"() => {{ window.location.hash = '{target_hash}'; }}")

                # Wait for content to change
                max_attempts = 20
                content_changed = False

                for attempt in range(max_attempts):
                    await page.wait_for_timeout(500)

                    new_content = await page.evaluate("""() => {
                        const h1 = document.querySelector('main h1, article h1, .content h1');
                        return h1 ? h1.textContent.substring(0, 200) : null;
                    }""")

                    if new_content and new_content != old_content:
                        print(f"      ✓ Content updated after {(attempt + 1) * 500}ms (h1: '{new_content[:50]}...')", file=sys.stderr)
                        content_changed = True
                        break

                if not content_changed:
                    print(f"      ⚠️  WARNING: Content did not change (h1: '{old_content[:50] if old_content else 'None'}...')", file=sys.stderr)

                # Additional wait
                await page.wait_for_timeout(500)

                # Extract content
                content = await extract_main_content_markdown(page)

                if not content:
                    print(f"      ⚠️  No content found", file=sys.stderr)
                    continue

                # Parse URL to determine file path
                section, subsection = parse_hash_url(link)

                if not section:
                    print(f"      ⚠️  Could not parse section from {link}", file=sys.stderr)
                    continue

                # Create directory structure
                section_dir = output_path / sanitize_filename(section)
                section_dir.mkdir(exist_ok=True)
                section_dirs.add(section_dir.name)

                # Create file
                filename = f"{sanitize_filename(subsection)}.md"
                file_path = section_dir / filename

                # Create frontmatter
                frontmatter = f"""---
source_url: {link}
section: {section}
subsection: {subsection}
scraped_at: {datetime.utcnow().isoformat()}Z
scraper: playwright-spa
---

"""

                # Write file
                file_path.write_text(frontmatter + content, encoding='utf-8')

                # Track for sitemap
                scraped_sections.append({
                    "url": link,
                    "section": section,
                    "subsection": subsection,
                    "file": f"{section_dir.name}/{filename}",
                    "size": len(content)
                })

                print(f"      ✓ Saved to {section_dir.name}/{filename}", file=sys.stderr)

            except Exception as e:
                print(f"      ❌ Error: {e}", file=sys.stderr)

        await browser.close()

        # Generate sitemap
        sitemap = {
            "url": base_url,
            "scraped_at": datetime.utcnow().isoformat() + "Z",
            "scraper": "playwright-spa",
            "sections": scraped_sections,
            "total_sections": len(unique_links),
            "scraped_sections": len(scraped_sections),
            "coverage": len(scraped_sections) / len(unique_links) if unique_links else 0,
            "directories": sorted(list(section_dirs)),
            "output_structure": "directory-tree"
        }

        sitemap_file = Path(output_dir) / "sitemap.json"
        with open(sitemap_file, 'w') as f:
            json.dump(sitemap, f, indent=2)

        print(f"    ✅ Playwright scraping complete!", file=sys.stderr)
        print(f"    📁 Created {len(section_dirs)} directories, {len(scraped_sections)} files", file=sys.stderr)
        print(f"    📊 Sitemap: {sitemap_file}", file=sys.stderr)

        return True


def main():
    """CLI entry point"""
    if len(sys.argv) != 3:
        print("Usage: playwright_scraper.py <url> <output_dir>", file=sys.stderr)
        sys.exit(1)

    url = sys.argv[1]
    output_dir = sys.argv[2]

    success = asyncio.run(scrape_spa_to_tree(url, output_dir))
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
