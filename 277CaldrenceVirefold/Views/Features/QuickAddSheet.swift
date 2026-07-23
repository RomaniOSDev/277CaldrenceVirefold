import SwiftUI

struct QuickAddSheet: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss

    @State private var trackName = ""
    @State private var note = ""
    @State private var tagName = ""
    @State private var emoji = "🎵"
    @State private var shake: CGFloat = 0

    private let emojiChoices = ["🎵", "🎧", "🎸", "🎹", "🔥", "🌙", "☀️", "🌊", "💫", "💪", "🎷", "💕"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Track") {
                    TextField("Track name", text: $trackName)
                    TextField("Short note (optional)", text: $note)
                }
                Section("Optional tag") {
                    TextField("Tag name", text: $tagName)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 10) {
                        ForEach(emojiChoices, id: \.self) { item in
                            Text(item)
                                .font(.title3)
                                .padding(6)
                                .background(Circle().fill(item == emoji ? Color("AppPrimary").opacity(0.35) : Color.clear))
                                .onTapGesture {
                                    emoji = item
                                    HapticService.light()
                                }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("AppBackground"))
            .navigationTitle("Quick Add")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .modifier(ShakeEffect(animatableData: shake))
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func save() {
        let track = trackName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !track.isEmpty else {
            withAnimation(.default) { shake += 1 }
            HapticService.warning()
            return
        }
        store.quickAdd(
            trackName: track,
            note: note,
            tagName: tagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : tagName,
            emoji: emoji
        )
        dismiss()
    }
}
