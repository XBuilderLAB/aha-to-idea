import Foundation
import SwiftData

@Observable
final class ConfirmationViewModel {
    var messages: [ChatMessage] = []
    var inputText = ""
    var isLoading = false
    var isConfirmed = false
    var confirmedUnderstanding = ""

    private var ahaMoment: AhaMoment?
    private var currentRound: ConfirmationRound?
    private var roundNumber = 1

    func setup(ahaMoment: AhaMoment, modelContext: ModelContext, llmClient: LLMClient?) async {
        self.ahaMoment = ahaMoment
        ahaMoment.transition(to: .confirming)
        try? modelContext.save()

        await requestConfirmation(modelContext: modelContext, llmClient: llmClient)
    }

    func requestConfirmation(modelContext: ModelContext, llmClient: LLMClient?) async {
        guard let client = llmClient, let aha = ahaMoment else { return }
        isLoading = true

        let keywords = aha.keywords
        let transcript = PromptBuilder.formatDialogueTranscript(sessions: aha.dialogueSessions ?? [])
        let previousCorrections: String?
        if !aha.confirmations.isEmpty {
            previousCorrections = PromptBuilder.formatConfirmationHistory(rounds: aha.confirmations)
        } else {
            previousCorrections = nil
        }

        let systemPrompt = PromptBuilder.confirmationSystemPrompt(
            keywords: keywords,
            dialogueTranscript: transcript,
            roundNumber: roundNumber,
            previousCorrections: previousCorrections
        )

        let chatMessages = [ChatMessage(role: .system, content: systemPrompt)]

        do {
            let response = try await client.chat(messages: chatMessages)

            if response.contains("CONFIRMED") {
                isConfirmed = true
                confirmedUnderstanding = response
            } else {
                let round = ConfirmationRound(
                    roundNumber: roundNumber,
                    aiSummary: response
                )
                round.ahaMoment = aha
                modelContext.insert(round)
                currentRound = round
                try? modelContext.save()

                messages.append(ChatMessage(role: .assistant, content: response))
            }
        } catch {
            messages.append(ChatMessage(role: .assistant, content: "确认请求失败：\(error.localizedDescription)"))
        }

        isLoading = false
    }

    func sendFeedback(_ feedback: String, modelContext: ModelContext, llmClient: LLMClient?) async {
        guard !feedback.isEmpty else { return }
        messages.append(ChatMessage(role: .user, content: feedback))

        currentRound?.userFeedback = feedback
        try? modelContext.save()

        roundNumber += 1
        await requestConfirmation(modelContext: modelContext, llmClient: llmClient)
    }

    func confirmUnderstanding(modelContext: ModelContext) {
        currentRound?.userConfirmed = true
        isConfirmed = true
        try? modelContext.save()
    }

    func rejectUnderstanding() {
        currentRound?.userConfirmed = false
    }
}
