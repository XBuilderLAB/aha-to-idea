# Aha to Idea

From fleeting moment to structured thinking — a 4-phase iOS workflow that turns your "aha" into something you can actually work with.

## The Problem

You get an idea in the shower, on a walk, in a conversation. You think you'll remember it. You don't. By the time you sit down to think it through, the insight is gone — or mutated into something vaguer.

Note-taking apps capture text. Voice memos capture sound. Neither captures **thinking**.

## What This App Does

Aha to Idea is a structured thinking workflow, not a note-taking app. It guides you from raw intuition to a structured ideation report through four phases:

### Phase 1: Capture (随手记)
Tap, type keywords, done. Under 5 seconds from app open to idea saved. Attach resources (links, notes, files) if you have them — but you don't need to.

### Phase 2: Dialogue (对话展开)
Talk it out. The AI acts as a curious listener — it asks questions, never gives answers. Your voice is transcribed and polished, then fed into the dialogue. The goal is to help you think out loud, not to summarize for you.

### Phase 3: Confirmation (理解确认)
The AI presents its understanding in three parts:
- **What I understood** — your exact words, quoted
- **What I'm uncertain about** — where ambiguity lives
- **What I need from you** — follow-up questions

You correct, it updates. Rounds continue until you confirm.

### Phase 4: Report (结构化报告)
A structured Markdown report is generated with one critical rule: **the AI writes structure, you write content**. Your original words are preserved as-is. Gaps are marked `[待展开]` instead of filled with AI-generated filler.

## Why This Workflow Matters

Most AI tools either capture (voice memos, notes) or generate (ChatGPT). This app sits in between — it **extends your thinking** without replacing it. The key design decisions:

- **AI as listener, not expert** — it asks questions, never provides answers
- **Your words, not AI's** — the final report uses your original phrasing
- **Low-friction entry** — keywords first, detail later
- **Iterative** — you can go back and re-dialogue after seeing the report

## Tech Stack

| Layer | Choice | Why |
|-------|--------|-----|
| UI | SwiftUI (iOS 17+) | Declarative, native, SwiftData integration |
| Persistence | SwiftData | Zero boilerplate `@Model` + `@Query` |
| Voice Input | AVAudioRecorder + Tencent Cloud ASR | Better Chinese recognition than on-device |
| Voice Polish | LLM | Raw ASR → structured text, preserving intent |
| AI Dialogue | DeepSeek / OpenAI API | Switchable provider via protocol |
| Text-to-Speech | AVFoundation | Built-in, free, multilingual |

## Project Status

**This project is actively being developed.** Many features are not yet complete — what's here is a working end-to-end skeleton, not a finished product. Expect rough edges, missing features, and breaking changes.

**~30-40% complete.** The core 4-phase workflow runs, but most phases need polish and several features are still TODO.

### What Works
- Keyword capture and parsing
- Voice recording with time limits
- Chinese ASR via Tencent Cloud
- ASR text polishing via LLM
- AI dialogue in listening mode
- Multi-round understanding confirmation
- Structured report generation with user-word preservation
- DeepSeek and OpenAI API support

### What's In Progress / TODO
- Photo and file resource attachments
- Report export (Markdown / PDF)
- TTS playback of AI responses
- On-device ASR fallback (Apple Speech)
- Report fidelity verification (detecting AI rewrites)
- UI polish and edge cases

## API Keys & Credentials

This app requires external API services to function. **No API keys or secrets are included in this repository** — you need to bring your own.

| Service | Provider | What You Need | Where to Get It |
|---------|----------|---------------|-----------------|
| LLM (Large Language Model) | OpenAI or DeepSeek | API Key | [OpenAI](https://platform.openai.com/api-keys) / [DeepSeek](https://platform.deepseek.com/api_keys) |
| ASR (Speech Recognition) | Tencent Cloud | SecretId + SecretKey | [Tencent Cloud Console](https://console.cloud.tencent.com/cam/capi) |

After launching the app, go to **Settings** to fill in your credentials. All keys are stored locally on your device via UserDefaults — they are never sent anywhere except to the respective API endpoints.

## Getting Started

### Prerequisites
- Xcode 15+
- iOS 17.0+ device or simulator
- [xcodegen](https://github.com/yonaskolb/XcodeGen) for project generation

### Setup

```bash
# Clone the repo
git clone https://github.com/aidenhhyy1030/aha-to-idea.git
cd aha-to-idea

# Generate Xcode project
xcodegen generate

# Open and run
open AhaToIdea.xcodeproj
```

## Architecture

```
MVVM + Service Layer

Views (SwiftUI)
  → ViewModels (@Observable)
    → Services (LLMClient, TencentASRClient, AudioRecordingService, PromptBuilder, TTSService)
      → SwiftData (ModelContext)
```

## Author

**aidenhhyy1030** — [GitHub](https://github.com/aidenhhyy1030)

Part of [X Builder Lab](https://github.com/XBuilderLAB).

## License

MIT
