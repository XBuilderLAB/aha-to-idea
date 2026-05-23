import Foundation
import SwiftData

@Model
final class ConfirmationRound {
    var id: UUID = UUID()
    var roundNumber: Int = 1
    var aiSummary: String = ""
    var aiUncertainties: [String] = []
    var aiQuestions: [String] = []
    var userFeedback: String?
    var userConfirmed: Bool = false
    var timestamp: Date = Date()

    var ahaMoment: AhaMoment?

    init(roundNumber: Int = 1, aiSummary: String = "", aiUncertainties: [String] = [], aiQuestions: [String] = []) {
        self.id = UUID()
        self.roundNumber = roundNumber
        self.aiSummary = aiSummary
        self.aiUncertainties = aiUncertainties
        self.aiQuestions = aiQuestions
    }
}
