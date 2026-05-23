import Foundation
import SwiftData

enum MessageRole: String, Codable {
    case user
    case assistant
}

@Model
final class DialogueMessage {
    var id: UUID = UUID()
    var role: MessageRole = MessageRole.user
    var text: String = ""
    var audioFilePath: String?
    var timestamp: Date = Date()

    var session: DialogueSession?

    init(role: MessageRole = .user, text: String = "", audioFilePath: String? = nil) {
        self.id = UUID()
        self.role = role
        self.text = text
        self.audioFilePath = audioFilePath
    }
}
