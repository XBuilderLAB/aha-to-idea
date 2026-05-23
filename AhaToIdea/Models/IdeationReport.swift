import Foundation
import SwiftData

@Model
final class IdeationReport {
    var id: UUID = UUID()
    var generatedAt: Date = Date()
    var originalKeywords: [String] = []
    var keyQuotes: [String] = []
    var fullMarkdown: String = ""

    @Relationship(deleteRule: .cascade, inverse: \ReportSection.report)
    var sections: [ReportSection] = []

    var ahaMoment: AhaMoment?

    init() {
        self.id = UUID()
    }
}

@Model
final class ReportSection {
    var id: UUID = UUID()
    var title: String = ""
    var body: String = ""
    var sourceQuoteIndices: [Int] = []
    var sortOrder: Int = 0

    var report: IdeationReport?

    init(title: String = "", body: String = "", sourceQuoteIndices: [Int] = [], sortOrder: Int = 0) {
        self.id = UUID()
        self.title = title
        self.body = body
        self.sourceQuoteIndices = sourceQuoteIndices
        self.sortOrder = sortOrder
    }
}
