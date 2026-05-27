[中文](README_CN.md)

# Aha to Idea

A **Claude Code skill** that turns your "aha moment" into a structured ideation report — from fleeting intuition to something you can actually work with.

```
/aha AI教育 个性化学习 认知科学
```

## The Problem

You get an idea in the shower, on a walk, in a conversation. You think you'll remember it. You don't. By the time you sit down to think it through, the insight is gone — or mutated into something vaguer.

Note-taking apps capture text. Voice memos capture sound. Neither captures **thinking**.

## What This Skill Does

Aha to Idea is a structured thinking workflow, not a note-taking app. It guides you from raw intuition to a structured ideation report through four phases:

### Phase 1: Capture
Give it keywords. That's it. No forms, no templates — just the raw fragments of your idea.

### Phase 2: Dialogue
The AI acts as a **thinking partner**, not an expert. It assumes you already understand your keywords and asks questions that push your thinking deeper:

- "What's the connection between these two ideas?"
- "If this worked out, what would excite you the most?"
- "What do you think the biggest obstacle would be?"

Only when you explicitly signal uncertainty ("I'm not sure about this", "I just heard about it") does it shift to foundational questions.

### Phase 3: Confirmation
The AI presents its understanding in three parts:
- **What I understood** — your exact words, quoted in 「」
- **What I'm uncertain about** — where ambiguity lives
- **What I need from you** — follow-up questions

You correct, it updates. Rounds continue until you confirm.

### Phase 4: Report
A structured Markdown report is generated with one critical rule: **the AI writes structure, you write content**. Your original words are preserved as-is. Gaps are marked `[待展开]` instead of filled with AI-generated filler.

## Install

```bash
# Clone the repo
git clone https://github.com/XBuilderLAB/aha-to-idea.git

# Copy the skill to your Claude Code skills directory
cp -r aha-to-idea/skills/aha ~/.claude/skills/aha
```

## Usage

```bash
# Start from scratch — will ask for keywords
/aha

# Provide keywords directly to skip capture phase
/aha AI教育 个性化学习 认知科学
```

The skill walks you through: Capture → Dialogue → Confirmation → Report. At the end, you get a structured Markdown report saved to `/tmp/`.

## Design Philosophy

Most AI tools either capture (voice memos, notes) or generate (ChatGPT). This skill sits in between — it **extends your thinking** without replacing it.

- **AI as thinking partner, not expert** — it pushes your thinking deeper, doesn't think for you
- **Your words, not AI's** — the final report uses your original phrasing
- **Assume understanding** — it treats you as someone who knows their keywords, not a beginner
- **Iterative** — you can go back and re-dialogue after seeing the report

## Also Available as an iOS App

The same workflow is available as a native iOS app with additional features:

| | Claude Code Skill | iOS App |
|---|---|---|
| Input | Text only | Voice (ASR) + Text |
| Portability | At your desk, in terminal | On-the-go, shower thoughts |
| Output | Markdown file | In-app report view |
| Voice features | None | Recording, ASR, LLM polish |

### iOS App Prerequisites
- Xcode 15+
- iOS 17.0+ device or simulator
- [xcodegen](https://github.com/yonaskolb/XcodeGen)
- API keys for LLM (OpenAI/DeepSeek) and ASR (Tencent Cloud) — stored locally, never shared

### iOS App Setup
```bash
git clone https://github.com/XBuilderLAB/aha-to-idea.git
cd aha-to-idea
xcodegen generate
open AhaToIdea.xcodeproj
```

### iOS App Status
~30-40% complete. Core 4-phase workflow runs. In progress: resource attachments, report export, TTS playback, on-device ASR fallback.

## Author

**aidenhhyy1030** — [GitHub](https://github.com/aidenhhyy1030)

Part of [X Builder Lab](https://github.com/XBuilderLAB).

## License

MIT
