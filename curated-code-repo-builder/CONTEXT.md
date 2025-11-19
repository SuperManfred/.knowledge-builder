# Context Builder Vision & Goals

This document defines the vision, purpose, and success metrics for the context builder system. It is immutable by agents and represents the core intent of the system.

## 🎯 Ultimate Goal
**Enable AI agents on this machine to operate with maximum specialization and expertise by providing optimal context resources**

## 🏛️ Architecture Vision
**Multi-Agent Specialization Model**: Each agent becomes a deep expert in ONE curated resource
- `next.js-agent`: Deep expertise in Next.js patterns, APIs, internals
- `vercel-agent`: Deep expertise in Vercel platform, deployment, configuration
- `effect-agent`: Deep expertise in Effect-TS patterns, functional programming
- `expo-agent`: Deep expertise in React Native/Expo ecosystem

*Note: Specialized agents will naturally collaborate with other specialists as needed*

## 🏗️ System Purpose
Build an automated curation system that creates minimal, high-signal codebases optimized for how AI agents search, use, and understand code patterns → enabling each specialist agent to achieve deep expertise in their domain

## 📊 Refined Weighted Priorities

### 1. **Agent Expertise Enhancement** (40%)
- Each curated repo becomes the complete knowledge base for ONE specialist agent
- Depth over breadth - better to deeply know one library than partially know many
- Include implementation details, internal patterns, architectural decisions
- *Why: Specialization requires comprehensive domain knowledge*

### 2. **Pattern Recognition & Learning** (30%)
- Preserve idioms and conventions specific to each library
- Keep internal utilities that show "how the experts do it"
- Maintain enough context to understand design decisions
- *Why: Specialist agents need to think like library maintainers*

### 3. **Inter-Agent Compatibility** (15%)
- Consistent curation structure across all repos
- Standardized ways to reference code locations
- Clear boundaries between domains
- *Why: Agents must speak a common language when collaborating*

### 4. **Search & Navigation Efficiency** (10%)
- Optimize for deep dives, not just surface-level searches
- Keep internal cross-references and dependency chains
- Include enough context for understanding complex interactions
- *Why: Specialists need to answer "how does this REALLY work?"*

### 5. **Maintenance Simplicity** (5%)
- One command to update all curated repos
- Smart defaults, minimal manual intervention
- Let LLM providers handle agent capability improvements
- *Why: Focus on providing resources, not building complex meta-systems*

## 🔄 Value Chain
```
Project Need → Specialist Agents Apply Deep Domain Knowledge →
Consensus Building (with healthy tension) → Optimal Implementation
```

## ✅ Success Metrics
- Each specialist agent can answer deep implementation questions about their domain
- Specialists provide consistent, domain-appropriate advice
- Healthy tension between specialists leads to optimal solutions (not sub-optimal agreeableness)
- Solutions reflect genuine library best practices balanced against project needs
- Human rarely needs to correct agent misunderstandings

## 📝 Implementation Focus
- Keep it simple: curate code, not complex meta-systems
- Each `.context/` repo = one specialist's complete knowledge base
- Optimize for maintenance ease over perfection
- Trust LLM providers to improve agent capabilities over time
- Success = agents have what they need to excel in your projects

## 🚀 North Star Question
*"Does this curation give a specialist agent everything needed to think like a library maintainer?"*

If yes → include it
If no → exclude it
If uncertain → start without, add if agents struggle

## 📈 Evolution Principles
1. **Start Minimal**: Better to have less perfect content than more noise
2. **Iterate Based on Usage**: Watch what agents actually need and reference
3. **Maintain Focus**: Resist scope creep - each repo serves ONE specialist
4. **Preserve Simplicity**: Complex systems fail; simple systems endure

## 🎓 Why This Matters
When agents have deep, focused expertise in the actual libraries used in projects:
- Fewer hallucinations about APIs that don't exist
- Better architectural decisions aligned with library patterns
- Faster problem-solving using library-native approaches
- More maintainable code that follows ecosystem conventions
- Reduced human correction and intervention

This isn't about building perfect curations—it's about giving specialist agents the focused knowledge they need to excel at helping with real projects on this machine.