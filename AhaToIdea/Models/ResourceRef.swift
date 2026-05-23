import Foundation
import SwiftData

enum ResourceType: String, Codable {
    case file
    case url
    case textNote
    case photo

    var iconName: String {
        switch self {
        case .file: return "doc"
        case .url: return "link"
        case .textNote: return "note.text"
        case .photo: return "photo"
        }
    }
}

@Model
final class ResourceRef {
    var id: UUID = UUID()
    var type: ResourceType = ResourceType.textNote
    var title: String = ""
    var contentPath: String?
    var urlString: String?
    var textContent: String?
    var createdAt: Date = Date()

    var ahaMoment: AhaMoment?

    init(type: ResourceType = .textNote, title: String = "", contentPath: String? = nil, urlString: String? = nil, textContent: String? = nil) {
        self.id = UUID()
        self.type = type
        self.title = title
        self.contentPath = contentPath
        self.urlString = urlString
        self.textContent = textContent
    }
}
