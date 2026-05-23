import SwiftUI

struct PhaseBadge: View {
    let phase: AhaPhase

    var color: Color {
        switch phase {
        case .captured: return .orange
        case .dialoguing: return .blue
        case .confirming: return .purple
        case .completed: return .green
        }
    }

    var body: some View {
        Label(phase.label, systemImage: phase.iconName)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}
