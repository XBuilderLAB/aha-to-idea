import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(AppViewModel.self) var appVM
    @Environment(\.modelContext) var modelContext
    @State private var selectedAha: AhaMoment?
    @State private var showCapture = false
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            AhaListView(selectedAha: $selectedAha)
                .navigationTitle("Aha to Idea")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                        }
                    }
                }
                .sheet(isPresented: $showCapture) {
                    CaptureView()
                }
                .sheet(item: $selectedAha) { aha in
                    AhaDetailView(ahaMoment: aha)
                }
                .overlay(alignment: .bottomTrailing) {
                    Button {
                        showCapture = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(Color.accentColor)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding()
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                }
        }
    }
}
