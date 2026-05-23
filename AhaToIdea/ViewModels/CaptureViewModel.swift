import Foundation
import SwiftData

@Observable
final class CaptureViewModel {
    var rawText = ""
    var keywords: [String] = []
    var projectName = ""
    var showResourcePicker = false
    var resources: [ResourceRef] = []

    var parsedKeywords: [String] {
        KeywordParser.parse(rawText)
    }

    func save(modelContext: ModelContext) -> AhaMoment {
        let aha = AhaMoment(
            keywords: parsedKeywords,
            rawKeywordText: rawText,
            taggedProjectName: projectName.isEmpty ? nil : projectName
        )
        for resource in resources {
            resource.ahaMoment = aha
        }
        aha.resources = resources
        modelContext.insert(aha)
        try? modelContext.save()
        return aha
    }

    func addTextResource(title: String, content: String) {
        let resource = ResourceRef(type: .textNote, title: title, textContent: content)
        resources.append(resource)
    }

    func addURLResource(title: String, url: String) {
        let resource = ResourceRef(type: .url, title: title, urlString: url)
        resources.append(resource)
    }

    func removeResource(at index: Int) {
        guard resources.indices.contains(index) else { return }
        resources.remove(at: index)
    }

    func reset() {
        rawText = ""
        keywords = []
        projectName = ""
        showResourcePicker = false
        resources = []
    }
}
