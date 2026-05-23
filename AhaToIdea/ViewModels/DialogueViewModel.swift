import Foundation
import SwiftData

@Observable
final class DialogueViewModel {
    var messages: [DialogueMessage] = []
    var inputText = ""
    var isLoading = false
    var errorMessage: String?

    private var currentSession: DialogueSession?
    private var ahaMoment: AhaMoment?

    var isReady: Bool { currentSession != nil }

    func setup(ahaMoment: AhaMoment, modelContext: ModelContext) {
        self.ahaMoment = ahaMoment
        if ahaMoment.phase != .dialoguing {
            ahaMoment.transition(to: .dialoguing)
        }

        let session = DialogueSession()
        session.ahaMoment = ahaMoment
        currentSession = session
        modelContext.insert(session)

        if !ahaMoment.dialogueSessions.isEmpty {
            var allMessages: [DialogueMessage] = []
            for s in ahaMoment.dialogueSessions {
                allMessages.append(contentsOf: s.messages)
            }
            messages = allMessages.sorted { $0.timestamp < $1.timestamp }
        }

        try? modelContext.save()
    }

    func sendUserMessage(text: String, modelContext: ModelContext, llmClient: LLMClient?) async {
        guard !text.isEmpty else { return }

        guard let session = currentSession else {
            errorMessage = "会话未初始化，请返回重试"
            return
        }

        let userMsg = DialogueMessage(role: .user, text: text)
        userMsg.session = session
        modelContext.insert(userMsg)
        messages.append(userMsg)

        try? modelContext.save()

        await getAIResponse(modelContext: modelContext, llmClient: llmClient)
    }

    func sendTranscribedMessage(modelContext: ModelContext, llmClient: LLMClient?) async {
        guard !inputText.isEmpty else { return }
        let text = inputText
        inputText = ""
        await sendUserMessage(text: text, modelContext: modelContext, llmClient: llmClient)
    }

    private func getAIResponse(modelContext: ModelContext, llmClient: LLMClient?) async {
        guard let client = llmClient else {
            print("[DialogueVM] llmClient is nil — showing error")
            let errorMsg = DialogueMessage(role: .assistant, text: "请先在设置中配置 LLM API Key")
            errorMsg.session = currentSession
            modelContext.insert(errorMsg)
            messages.append(errorMsg)
            return
        }
        isLoading = true
        print("[DialogueVM] Calling LLM API...")

        let keywords = ahaMoment?.keywords ?? []
        let resourceSummaries = ResourceContentExtractor.extractAllSummaries(from: ahaMoment?.resources ?? [])

        let systemPrompt = PromptBuilder.dialogueSystemPrompt(
            keywords: keywords,
            resourceSummaries: resourceSummaries,
            projectName: ahaMoment?.taggedProjectName
        )

        var chatMessages: [ChatMessage] = [
            ChatMessage(role: .system, content: systemPrompt)
        ]
        for msg in messages {
            let role: ChatMessage.Role = msg.role == .user ? .user : .assistant
            chatMessages.append(ChatMessage(role: role, content: msg.text))
        }

        do {
            let response = try await client.chat(messages: chatMessages)
            print("[DialogueVM] LLM response received: \(response.prefix(100))")
            let assistantMsg = DialogueMessage(role: .assistant, text: response)
            assistantMsg.session = currentSession
            modelContext.insert(assistantMsg)
            messages.append(assistantMsg)
            try? modelContext.save()
        } catch {
            print("[DialogueVM] LLM error: \(error)")
            let errorMsg = DialogueMessage(role: .assistant, text: "抱歉，出了点问题：\(error.localizedDescription)")
            errorMsg.session = currentSession
            modelContext.insert(errorMsg)
            messages.append(errorMsg)
        }

        isLoading = false
    }

    func finishDialogue() -> AhaMoment? {
        currentSession?.endedAt = Date()
        return ahaMoment
    }
}
