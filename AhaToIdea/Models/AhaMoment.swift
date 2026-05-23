import Foundation
import SwiftData

enum AhaPhase: String, Codable, CaseIterable {
    case captured
    case dialoguing
    case confirming
    case completed

    var label: String {
        switch self {
        case .captured: return "已捕捉"
        case .dialoguing: return "对话中"
        case .confirming: return "确认中"
        case .completed: return "已完成"
        }
    }

    var iconName: String {
        switch self {
        case .captured: return "lightbulb"
        case .dialoguing: return "bubble.left.and.bubble.right"
        case .confirming: return "checkmark.circle"
        case .completed: return "doc.text"
        }
    }

    static func canTransition(from: AhaPhase, to: AhaPhase) -> Bool {
        switch (from, to) {
        case (.captured, .dialoguing): return true
        case (.dialoguing, .confirming): return true
        case (.confirming, .confirming): return true
        case (.confirming, .dialoguing): return true
        case (.confirming, .completed): return true
        case (.completed, .dialoguing): return true
        default: return false
        }
    }
}

@Model
final class AhaMoment {
    var id: UUID = UUID()
    var keywords: [String] = []
    var rawKeywordText: String = ""
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var phase: AhaPhase = AhaPhase.captured
    var taggedProjectName: String?

    @Relationship(deleteRule: .cascade, inverse: \ResourceRef.ahaMoment)
    var resources: [ResourceRef] = []

    @Relationship(deleteRule: .cascade, inverse: \DialogueSession.ahaMoment)
    var dialogueSessions: [DialogueSession] = []

    @Relationship(deleteRule: .cascade, inverse: \ConfirmationRound.ahaMoment)
    var confirmations: [ConfirmationRound] = []

    @Relationship(deleteRule: .cascade, inverse: \IdeationReport.ahaMoment)
    var report: IdeationReport?

    var title: String {
        if keywords.isEmpty { return "新想法" }
        return keywords.joined(separator: " · ")
    }

    init(keywords: [String] = [], rawKeywordText: String = "", taggedProjectName: String? = nil) {
        self.id = UUID()
        self.keywords = keywords
        self.rawKeywordText = rawKeywordText
        self.taggedProjectName = taggedProjectName
    }

    @discardableResult
    func transition(to newPhase: AhaPhase) -> Bool {
        guard AhaPhase.canTransition(from: phase, to: newPhase) else { return false }
        phase = newPhase
        updatedAt = Date()
        return true
    }
}
