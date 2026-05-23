import Foundation
import SwiftData

@Model
final class DialogueSession {
    var id: UUID = UUID()
    var startedAt: Date = Date()
    var endedAt: Date?

    @Relationship(deleteRule: .cascade, inverse: \DialogueMessage.session)
    var messages: [DialogueMessage] = []

    var ahaMoment: AhaMoment?

    init() {
        self.id = UUID()
    }
}
