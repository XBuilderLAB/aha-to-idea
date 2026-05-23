import SwiftUI
import SwiftData

struct AhaListView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \AhaMoment.updatedAt, order: .reverse) var ahaMoments: [AhaMoment]

    @Binding var selectedAha: AhaMoment?
    @State private var filterPhase: AhaPhase?

    var filteredMoments: [AhaMoment] {
        if let phase = filterPhase {
            return ahaMoments.filter { $0.phase == phase }
        }
        return ahaMoments
    }

    var body: some View {
        List {
            if ahaMoments.isEmpty {
                ContentUnavailableView(
                    "还没有捕捉想法",
                    systemImage: "lightbulb",
                    description: Text("点击右下角 + 开始记录你的第一个 Aha Moment")
                )
            } else {
                Picker("筛选阶段", selection: $filterPhase) {
                    Text("全部").tag(nil as AhaPhase?)
                    ForEach(AhaPhase.allCases, id: \.self) { phase in
                        Text(phase.label).tag(phase as AhaPhase?)
                    }
                }
                .pickerStyle(.segmented)
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))

                ForEach(filteredMoments) { aha in
                    AhaListRow(ahaMoment: aha)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedAha = aha
                        }
                }
                .onDelete(perform: deleteMoments)
            }
        }
        .listStyle(.plain)
    }

    private func deleteMoments(at offsets: IndexSet) {
        for index in offsets {
            let aha = filteredMoments[index]
            modelContext.delete(aha)
        }
        try? modelContext.save()
    }
}

struct AhaListRow: View {
    let ahaMoment: AhaMoment

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(ahaMoment.title)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                PhaseBadge(phase: ahaMoment.phase)
            }

            HStack(spacing: 4) {
                ForEach(ahaMoment.keywords.prefix(5), id: \.self) { keyword in
                    KeywordCapsule(text: keyword)
                }
                if ahaMoment.keywords.count > 5 {
                    Text("+\(ahaMoment.keywords.count - 5)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            HStack {
                if let project = ahaMoment.taggedProjectName {
                    Label(project, systemImage: "folder")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(ahaMoment.createdAt, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
