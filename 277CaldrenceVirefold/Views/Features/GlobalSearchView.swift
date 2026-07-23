import SwiftUI

struct GlobalSearchView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    var body: some View {
        NavigationStack {
            List {
                if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Search tags, curated moods, and journal notes.")
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .listRowBackground(Color("AppBackground"))
                } else if store.search(query: query).isEmpty {
                    Text("No matches")
                        .foregroundStyle(Color("AppTextSecondary"))
                        .listRowBackground(Color("AppBackground"))
                } else {
                    ForEach(store.search(query: query)) { hit in
                        HStack(spacing: 12) {
                            Text(hit.emoji)
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(hit.title)
                                    .font(.headline)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                    .lineLimit(1)
                                Text(hit.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(Color("AppTextSecondary"))
                                    .lineLimit(2)
                                Text(kindLabel(hit.kind))
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(Color("AppAccent"))
                            }
                        }
                        .listRowBackground(Color("AppSurface"))
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("AppBackground"))
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $query, prompt: "Tags, tracks, notes")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func kindLabel(_ kind: SearchHit.Kind) -> String {
        switch kind {
        case .tag: return "LIBRARY TAG"
        case .entry: return "JOURNAL"
        case .curated: return "CURATED"
        }
    }
}
