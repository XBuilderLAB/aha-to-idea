import Foundation
import SwiftData

@Observable
final class ReportViewModel {
    var report: IdeationReport?
    var isLoading = false
    var errorMessage: String?

    func generateReport(ahaMoment: AhaMoment, confirmationVM: ConfirmationViewModel, modelContext: ModelContext, llmClient: LLMClient?) async {
        guard let client = llmClient else {
            errorMessage = "请先在设置中配置API Key"
            return
        }
        isLoading = true

        let keywords = ahaMoment.keywords
        let confirmedUnderstanding = confirmationVM.confirmedUnderstanding
        let transcript = PromptBuilder.formatDialogueTranscript(sessions: ahaMoment.dialogueSessions ?? [])
        let resourceContent = ResourceContentExtractor.extractAllFullContent(from: ahaMoment.resources ?? [])

        let systemPrompt = PromptBuilder.reportSystemPrompt(
            keywords: keywords,
            confirmedUnderstanding: confirmedUnderstanding,
            dialogueTranscript: transcript,
            resourceContent: resourceContent
        )

        let chatMessages = [ChatMessage(role: .system, content: systemPrompt)]

        do {
            let response = try await client.chat(messages: chatMessages)

            let newReport = IdeationReport()
            newReport.originalKeywords = keywords
            newReport.fullMarkdown = response
            newReport.generatedAt = Date()
            newReport.ahaMoment = ahaMoment

            let sections = parseMarkdownSections(response)
            for (index, section) in sections.enumerated() {
                let reportSection = ReportSection(
                    title: section.title,
                    body: section.body,
                    sortOrder: index
                )
                reportSection.report = newReport
                newReport.sections.append(reportSection)
            }

            modelContext.insert(newReport)
            ahaMoment.transition(to: .completed)
            try? modelContext.save()

            self.report = newReport
        } catch {
            errorMessage = "报告生成失败：\(error.localizedDescription)"
        }

        isLoading = false
    }

    private func parseMarkdownSections(_ markdown: String) -> [(title: String, body: String)] {
        var sections: [(title: String, body: String)] = []
        let lines = markdown.components(separatedBy: "\n")
        var currentTitle = ""
        var currentBody: [String] = []

        for line in lines {
            if line.hasPrefix("## ") {
                if !currentTitle.isEmpty {
                    sections.append((title: currentTitle, body: currentBody.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)))
                }
                currentTitle = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                currentBody = []
            } else {
                currentBody.append(line)
            }
        }

        if !currentTitle.isEmpty {
            sections.append((title: currentTitle, body: currentBody.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)))
        }

        return sections
    }

    func exportMarkdown() -> String? {
        report?.fullMarkdown
    }
}
