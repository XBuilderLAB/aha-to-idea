import SwiftUI

struct DialogueBubbleView: View {
    let message: DialogueMessage

    var body: some View {
        HStack {
            if message.role == .user { Spacer(minLength: 40) }
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.role == .user ? "你" : "AI")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(message.text)
                    .font(.subheadline)
                    .padding(12)
                    .background(
                        message.role == .user
                        ? Color.accentColor.opacity(0.15)
                        : Color(.systemGray6)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            if message.role == .assistant { Spacer(minLength: 40) }
        }
    }
}
