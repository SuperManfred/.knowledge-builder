# Docs-GH Curation Vision & Goals

This document defines the vision, purpose, and success metrics for the repository documentation curation system. It is immutable by agents and represents the core intent of the system.

## 🎯 Ultimate Goal
**Enable AI agents to understand HOW TO USE libraries by providing clean, comprehensive documentation extracted from GitHub repositories**

## 🏛️ Architecture Vision
**Documentation Specialist Agents**: Each agent becomes an expert in explaining and teaching a library
- `next.js-docs-agent`: Deep knowledge of Next.js usage, APIs, patterns, best practices
- `react-docs-agent`: Expert in React concepts, hooks, component patterns
- `crawl4ai-docs-agent`: Specialist in crawl4ai usage, configuration, examples

*Note: Docs agents complement code agents - docs explain "how to use", code agents explain "how it works internally"*

## 🏗️ System Purpose
Build an automated curation system that extracts clean, high-value documentation from GitHub repositories → removing website boilerplate and focusing on content that helps agents teach library usage

## 📊 Refined Weighted Priorities

### 1. **Usage Clarity** (40%)
- Each curated docs repo teaches agents HOW TO USE the library
- Focus on tutorials, guides, API references, examples
- Include conceptual explanations and best practices
- *Why: Agents need to explain library usage to developers*

### 2. **Content Completeness** (30%)
- Preserve getting-started guides, tutorials, how-tos
- Keep API documentation and reference material
- Include code examples within docs
- Maintain images/diagrams that illustrate concepts
- *Why: Complete documentation enables better guidance*

### 3. **Noise Reduction** (20%)
- Exclude website rendering code (React/Vue/Svelte components)
- Remove build configs for docs sites
- Strip out navigation boilerplate, footers, sidebars
- Eliminate tests for documentation
- *Why: Agents don't need website infrastructure, just content*

### 4. **Cross-Resource Compatibility** (5%)
- Consistent structure with other curation systems
- Standardized naming and organization
- *Why: Multiple resource types serve different agent needs*

### 5. **Maintenance Simplicity** (5%)
- One command to update docs
- Smart defaults, minimal intervention
- *Why: Focus on content, not complexity*

## 🔄 Value Chain
```
Developer Question → Docs Agent Consults Curated Docs →
Clear Usage Guidance → Developer Success
```

## ✅ Success Metrics
- Agents can answer "how do I use X?" questions accurately
- Guides include relevant examples and code snippets
- Documentation reflects current library best practices
- Agents rarely reference outdated or incorrect usage patterns
- Developers get helpful, accurate guidance

## 📝 Implementation Focus
- Keep it simple: extract docs content, not website code
- Each curated-docs-gh repo = complete usage documentation
- Optimize for content quality over website aesthetics
- Success = agents can teach library usage effectively

## 🚀 North Star Question
*"Does this documentation help an agent teach someone how to use the library?"*

If yes → include it
If no → exclude it
If uncertain → include (docs are meant to be comprehensive)

## 📈 Evolution Principles
1. **Start Comprehensive**: Docs should be complete, not minimal
2. **Iterate Based on Quality**: Remove noise, keep signal
3. **Maintain Focus**: Each docs repo explains ONE library's usage
4. **Preserve Simplicity**: Extract content, don't rebuild websites

## 🎓 Why This Matters
When agents have clean, complete documentation:
- Better "how to use" guidance for developers
- Accurate API usage examples
- Current best practices and patterns
- Conceptual understanding to complement code knowledge
- Reduced outdated or incorrect advice

## 📚 Docs vs. Code Curation

| Aspect | Code Curation | Docs Curation |
|--------|---------------|---------------|
| **Goal** | "How it works internally" | "How to use it" |
| **Audience** | Library maintainer perspective | Library user perspective |
| **Content** | Implementation, internals | Tutorials, guides, API docs |
| **Agent Role** | Deep technical expert | Usage teacher/explainer |

This isn't about building perfect documentation—it's about giving docs specialist agents the content they need to teach library usage effectively.
