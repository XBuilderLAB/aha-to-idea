import SwiftUI
import SwiftData

@main
struct AhaToIdeaApp: App {
    let modelContainer: ModelContainer

    @State private var appVM = AppViewModel()

    init() {
        let schema = Schema([
            AhaMoment.self,
            ResourceRef.self,
            DialogueSession.self,
            DialogueMessage.self,
            ConfirmationRound.self,
            IdeationReport.self,
            ReportSection.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appVM)
                .modelContainer(modelContainer)
        }
    }
}
