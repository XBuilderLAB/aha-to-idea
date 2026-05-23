import Foundation

struct ResourceContentExtractor {

    static func extractSummary(from resource: ResourceRef) -> String {
        switch resource.type {
        case .textNote:
            let text = resource.textContent ?? ""
            return String(text.prefix(500))
        case .url:
            var summary = "[链接: \(resource.title)](\(resource.urlString ?? ""))"
            if let text = resource.textContent {
                summary += " - \(String(text.prefix(200)))"
            }
            return summary
        case .file:
            return "[文件: \(resource.title)]"
        case .photo:
            return "[图片: \(resource.title)]"
        }
    }

    static func extractFullContent(from resource: ResourceRef) -> String {
        switch resource.type {
        case .textNote:
            return resource.textContent ?? ""
        case .url:
            var content = "链接: \(resource.urlString ?? "")"
            if let text = resource.textContent {
                content += "\n内容摘要: \(text)"
            }
            return content
        case .file:
            guard let path = resource.contentPath else { return "[文件: \(resource.title)]" }
            let url = URL(fileURLWithPath: path)
            guard let content = try? String(contentsOf: url, encoding: .utf8) else {
                return "[文件: \(resource.title)]（无法读取内容）"
            }
            return String(content.prefix(2000))
        case .photo:
            return "[图片: \(resource.title)]"
        }
    }

    static func extractAllSummaries(from resources: [ResourceRef]) -> String? {
        let summaries = resources.map { extractSummary(from: $0) }
        if summaries.isEmpty { return nil }
        return summaries.joined(separator: "\n\n")
    }

    static func extractAllFullContent(from resources: [ResourceRef]) -> String? {
        let contents = resources.map { extractFullContent(from: $0) }
        if contents.isEmpty { return nil }
        return contents.joined(separator: "\n\n")
    }
}
