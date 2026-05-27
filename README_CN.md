[English](README.md)

# Aha to Idea

一个 **Claude Code skill**，把你的"aha moment"变成结构化的思考报告——从转瞬即逝的直觉，到可以落地推进的想法。

```
/aha AI教育 个性化学习 认知科学
```

## 问题

你在洗澡时、散步时、聊天时冒出一个想法。你以为自己会记住，但其实不会。等你坐下来想好好理一理的时候，那个灵感已经消失了——或者变成了一个更模糊的版本。

笔记软件记录文字。语音备忘录记录声音。但它们都捕捉不了**思考**。

## 这个 Skill 做什么

Aha to Idea 不是记笔记的工具，而是一个结构化思考的工作流。它引导你从原始直觉出发，经过四个阶段，最终生成一份结构化的思考报告：

### 第一阶段：捕捉
给几个关键词就行。没有表单，没有模板——只要想法的原始碎片。

### 第二阶段：对话
AI 扮演的是**思考伙伴**，不是专家。它默认你对关键词已有充分理解，提出能推动你思考更深入的问题：

- "你觉得这两个想法之间有什么联系？"
- "如果这件事做成了，最让你兴奋的是什么？"
- "你觉得最大的阻力会是什么？"

只有当你明确表示不确定（"我不太确定"、"我听别人说的"、"我就是随便想到的"）时，它才会从基础角度提问。

### 第三阶段：确认
AI 用三段式呈现它的理解：
- **我理解的** — 用「」引用你的原话
- **我的疑问** — 具体指出哪里有歧义
- **我需要确认的** — 追问

你纠正，它更新。多轮循环直到你确认。

### 第四阶段：报告
生成一份结构化的 Markdown 报告，核心规则：**AI 写结构，你写内容**。你的原话原样保留，缺失的部分写 `[待展开]` 而不是 AI 编造。

## 安装

```bash
# 克隆仓库
git clone https://github.com/XBuilderLAB/aha-to-idea.git

# 复制 skill 到 Claude Code 的 skills 目录
cp -r aha-to-idea/skills/aha ~/.claude/skills/aha
```

## 使用

```bash
# 从零开始 — 会先问你关键词
/aha

# 直接提供关键词，跳过捕捉阶段
/aha AI教育 个性化学习 认知科学
```

Skill 引导你走完：捕捉 → 对话 → 确认 → 报告。最后生成一份 Markdown 报告，保存在 `/tmp/`。

## 设计理念

大多数 AI 工具要么是记录（语音备忘录、笔记），要么是生成（ChatGPT）。这个 skill 处在两者之间——它**延伸你的思考**，而不是替代你的思考。

- **AI 是思考伙伴，不是专家** — 它推动你思考更深入，不会替你想
- **你的原话，不是 AI 的** — 报告使用你的原始措辞
- **默认你理解关键词** — 把你当作了解自己想法的人，不是新手
- **可迭代** — 看完报告后可以回去继续对话、重新生成

## 也有 iOS App 版本

同样的工作流也有原生 iOS app，附带更多功能：

| | Claude Code Skill | iOS App |
|---|---|---|
| 输入方式 | 仅文字 | 语音（ASR）+ 文字 |
| 使用场景 | 坐在桌前，在终端里 | 随时随地，洗澡时也行 |
| 输出 | Markdown 文件 | App 内报告视图 |
| 语音功能 | 无 | 录音、ASR、LLM 润色 |

### iOS App 前置条件
- Xcode 15+
- iOS 17.0+ 真机或模拟器
- [xcodegen](https://github.com/yonaskolb/XcodeGen)
- LLM（OpenAI/DeepSeek）和 ASR（腾讯云）的 API Key — 仅存储在本地，不会上传

### iOS App 安装
```bash
git clone https://github.com/XBuilderLAB/aha-to-idea.git
cd aha-to-idea
xcodegen generate
open AhaToIdea.xcodeproj
```

### iOS App 进度
约 30-40% 完成。核心 4 阶段工作流已可用。进行中：资源附件、报告导出、TTS 播放、端侧 ASR 备选方案。

## 作者

**aidenhhyy1030** — [GitHub](https://github.com/aidenhhyy1030)

[X Builder Lab](https://github.com/XBuilderLAB) 成员。

## 许可

MIT
