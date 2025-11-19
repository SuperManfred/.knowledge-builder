# Docs-Web Curation Vision & Goals

This document defines the vision, purpose, and success metrics for the web documentation curation system. It is immutable by agents and represents the core intent of the system.

## 🎯 Ultimate Goal
**Enable AI agents to understand HOW TO USE libraries by providing clean documentation extracted from official websites**

## 🏛️ Architecture Vision
**Web Documentation Specialist Agents**: Each agent becomes an expert in explaining library usage from official docs
- `next.js-web-docs-agent`: Expert in Next.js from nextjs.org
- `react-web-docs-agent`: Expert in React from react.dev  
- `crawl4ai-web-docs-agent`: Expert in crawl4ai from official site

*Note: Web docs agents complement GitHub docs agents - web docs may be more current or have different structure*

## 🏗️ System Purpose
Build an automated curation system that extracts clean documentation from scraped websites → removing website chrome (navigation, headers, footers) and focusing on pure content

## 📊 Refined Weighted Priorities

### 1. **Content Purity** (40%)
- Extract ONLY documentation content from scraped websites
- Remove navigation, headers, footers, sidebars
- Strip ads, tracking, analytics, marketing
- *Why: Agents need pure content without website noise*

### 2. **Content Completeness** (30%)
- Preserve all tutorial pages, guides, API docs
- Keep code examples and snippets
- Maintain images that illustrate concepts
- *Why: Complete docs enable comprehensive guidance*

### 3. **Format Flexibility** (15%)
- Accept both httrack (HTML) and crawl4ai (markdown) sources
- Preserve whichever format is cleaner
- Don't force conversion between formats
- *Why: Different scrapers produce different quality for different sites*

### 4. **Cross-Resource Compatibility** (10%)
- Consistent structure with other curation systems
- Standard naming conventions
- *Why: Multiple resource types serve different needs*

### 5. **Maintenance Simplicity** (5%)
- One command to update web docs
- Smart defaults, minimal intervention
- *Why: Focus on content extraction, not complexity*

## 🔄 Value Chain
```
Developer Question → Web Docs Agent Consults Curated Docs →
Clear Usage Guidance → Developer Success
```

## ✅ Success Criteria
- Agents can answer "how do I use X?" from official docs
- Documentation reflects current library state
- Website chrome completely removed (nav, footers, ads)
- Content is clean and readable
- Agents provide accurate, up-to-date guidance

## 📝 Implementation Focus
- Keep it simple: extract content, remove noise
- Each curated-docs-web repo = complete official docs
- Work from BOTH httrack and crawl4ai sources
- Success = agents can teach library usage from official docs

## 🚀 North Star Question
*"Does this documentation help an agent teach someone how to use the library, without website distractions?"*

If yes → include it
If no → exclude it
If uncertain → include (docs should be comprehensive)

## 📈 Evolution Principles
1. **Start Comprehensive**: Include all doc pages
2. **Remove Noise**: Strip navigation, chrome, infrastructure
3. **Maintain Focus**: Each docs repo explains ONE library
4. **Preserve Simplicity**: Extract content, don't rebuild

## 🎓 Why This Matters
When agents have clean, official documentation from websites:
- Up-to-date guidance (websites often fresher than GitHub)
- Official best practices and examples
- Clean content without distractions
- Comprehensive tutorials and guides
- Better user experience in answers

## 📚 Docs-Web vs. Docs-GH vs. Code

| Aspect | Code | Docs-GH | Docs-Web |
|--------|------|---------|----------|
| **Goal** | How it works | How to use (from repo) | How to use (from official site) |
| **Source** | GitHub repo code | GitHub repo docs/ | Official website |
| **Format** | Source files | Markdown/MDX | HTML or Markdown |
| **Noise** | Tests, examples | Website components | Navigation, chrome |
| **Freshness** | Stable | Stable | Most current |

## 🌐 Web Scraping Sources

We work from TWO upstream sources per website:

1. **httrack/** - Pristine HTML mirror
   - Complete offline copy
   - All assets preserved
   - Good when site structure is clean

2. **crawl4ai/** - AI-extracted markdown
   - Pre-filtered content
   - Navigation already removed
   - Good for complex sites

**Curation chooses**: Use whichever source produces cleaner results, or combine both.

This isn't about perfect extraction—it's about giving docs specialist agents clean, official documentation from websites to teach library usage effectively.
