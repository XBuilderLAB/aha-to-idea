import SwiftUI

struct ReportView: View {
    let report: IdeationReport
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Original keywords
                    VStack(alignment: .leading, spacing: 8) {
                        Text("原始关键词")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(report.originalKeywords, id: \.self) { keyword in
                                    KeywordCapsule(text: keyword)
                                }
                            }
                        }
                    }

                    Divider()

                    // Report sections
                    if !report.sections.isEmpty {
                        ForEach(report.sections.sorted(by: { $0.sortOrder < $1.sortOrder })) { section in
                            ReportSectionView(section: section)
                        }
                    } else {
                        // Fallback: render raw markdown
                        Text(report.fullMarkdown)
                            .font(.body)
                    }
                }
                .padding()
            }
            .navigationTitle("思考报告")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("完成") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: report.fullMarkdown) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
}

struct ReportSectionView: View {
    let section: ReportSection

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(section.title)
                .font(.headline)

            Text(section.body)
                .font(.body)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
