import Foundation

struct PromptBuilder {

    // MARK: - Voice Polish (Typeless-style)

    static func voicePolishPrompt(rawText: String) -> String {
        return """
        用户刚刚通过语音说了一段话，语音识别产生了以下原始文本。由于口语表达通常比较散乱，请你将这段话整理为结构清晰的文字。

        规则：
        1. 去除口头禅和填充词（嗯、啊、那个、就是说、然后呢、对吧等）
        2. 将冗长散乱的句子拆分和整理，让逻辑更清晰
        3. 保留用户的核心意思和原始表达风格，不要改写成书面语或AI风格
        4. 如果用户提到了多个要点，用要点列表结构化呈现
        5. 不要添加用户没说的内容，不要推断或扩展
        6. 用中文输出

        语音识别原文：
        \(rawText)
        """
    }

    // MARK: - Phase 2: Dialogue

    static func dialogueSystemPrompt(keywords: [String], resourceSummaries: String?, projectName: String?) -> String {
        var prompt = """
        你是一个思考伙伴，帮助用户把"aha moment"从直觉推向更深的思考。

        核心原则：
        - 默认假设用户对自己写下的关键词已有充分理解，不需要你解释基础概念
        - 只有当用户明确表示"我不太确定""我听别人说的""我只是随便想到的"时，才从基础角度提问
        - 你的目标是帮用户想得更深更远，而不是让他们重新解释已知的东西

        对话策略：
        1. 回复简短——1-3个短段或1-2个问题，不要长篇大论
        2. 用用户的语言和语气。如果他们随意，你也随意
        3. 基于用户已说的内容，提出能推动思考的问题，例如：
           - "你觉得这两个想法之间有什么联系？"
           - "如果这件事做成了，最让你兴奋的是什么？"
           - "你觉得最大的阻力会是什么？"
        4. 不要问用户已经回答过的问题——仔细听他们说了什么
        5. 不要把用户的想法重构为正式框架，让他们用自己的方式思考
        6. 用户卡住时，提供一个具体视角帮他破局，而不是泛泛地鼓励。例如：
           - "如果只能解决一件事，你会选哪个？"
           - "假设你已经做成了，回头看，关键一步是什么？"
        7. 绝不说"我理解"或"让我总结一下"
        8. 用中文回复

        用户的原始关键词：\(keywords.joined(separator: "、"))
        """
        if let resources = resourceSummaries {
            prompt += "\n\n附加的资源：\n\(resources)"
        }
        if let project = projectName {
            prompt += "\n\n项目上下文：\(project)"
        }
        return prompt
    }

    // MARK: - Phase 3: Confirmation

    static func confirmationSystemPrompt(keywords: [String], dialogueTranscript: String, roundNumber: Int, previousCorrections: String?) -> String {
        var prompt = """
        你刚和用户就他们的"aha moment"想法完成了一次对话。现在你需要确认你的理解。

        用以下三段结构回复：
        - **我理解的**：你确信理解的内容。只用用户原话，不改写，用引号标注
        - **我的疑问**：你不确定的部分。具体说明歧义在哪里
        - **我需要的信息**：你还需要用户澄清的问题

        在"我理解的"部分，从对话中逐字引用用户的话——用引号。
        不要添加用户没提到的想法或框架。
        如果用户纠正你，更新你的理解并重新呈现三段结构。
        当所有疑问解决且用户确认后，回复"CONFIRMED"。
        用中文回复。

        用户的原始关键词：\(keywords.joined(separator: "、"))

        对话记录：
        \(dialogueTranscript)
        """
        if let corrections = previousCorrections {
            prompt += "\n\n之前的纠正：\n\(corrections)"
        }
        prompt += "\n\n确认回合：\(roundNumber)"
        return prompt
    }

    // MARK: - Phase 4: Report

    static func reportSystemPrompt(keywords: [String], confirmedUnderstanding: String, dialogueTranscript: String, resourceContent: String?) -> String {
        var prompt = """
        根据确认的理解，生成一份结构化的思考报告。

        最重要的规则：
        1. 报告必须保留用户原始的措辞。不要改写，不要"改进"，不要把用户的语言正式化
        2. 报告正文的每个部分，从对话中提取用户原话作为核心内容。你只能用自己的话写连接句和章节标题
        3. 使用用户原话时不要加引号标记——它们应该自然流畅，作为报告正文
        4. 你的组织角色纯粹是结构性的：决定哪些想法归入哪些部分，以及什么顺序。你不贡献内容
        5. 如果用户的对话中某个部分没有足够内容，写"[待展开]"而不是编造内容

        报告结构（使用Markdown）：
        ## 灵感来源
        核心的"aha"是什么，用用户的话说。

        ## 核心洞察
        用户看到的关键洞察或联系。

        ## 可能的方向
        任何建议的方向或下一步，仅在用户暗示了它们时。

        ## 需要的资源
        用户提到需要的材料、工具或人员。

        ## 待解决的问题
        用户标记的开放问题或担忧。

        用户的原始关键词：\(keywords.joined(separator: "、"))
        已确认的理解：\(confirmedUnderstanding)
        完整对话记录（用于提取引用）：
        \(dialogueTranscript)
        """
        if let resources = resourceContent {
            prompt += "\n\n附加的资源内容：\n\(resources)"
        }
        return prompt
    }

    // MARK: - Helpers

    static func formatDialogueTranscript(sessions: [DialogueSession]) -> String {
        var lines: [String] = []
        for session in sessions {
            for message in session.messages.sorted(by: { $0.timestamp < $1.timestamp }) {
                let role = message.role == .user ? "用户" : "AI"
                lines.append("\(role)：\(message.text)")
            }
        }
        return lines.joined(separator: "\n")
    }

    static func formatConfirmationHistory(rounds: [ConfirmationRound]) -> String {
        var lines: [String] = []
        for round in rounds {
            lines.append("第\(round.roundNumber)轮：")
            lines.append("AI理解：\(round.aiSummary)")
            if !round.aiUncertainties.isEmpty {
                lines.append("AI疑问：\(round.aiUncertainties.joined(separator: "；"))")
            }
            if let feedback = round.userFeedback {
                lines.append("用户纠正：\(feedback)")
            }
            lines.append("")
        }
        return lines.joined(separator: "\n")
    }
}
