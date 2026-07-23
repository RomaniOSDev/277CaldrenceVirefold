import SwiftUI

struct TagDetailView: View {
    @EnvironmentObject private var store: AppDataStore
    let tag: MusicTag

    private var linkedEntries: [JournalEntry] {
        store.entries(for: tag)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                SoftCard {
                    HStack(spacing: 14) {
                        Text(tag.emoji)
                            .font(.system(size: 44))
                        VStack(alignment: .leading, spacing: 6) {
                            Text(tag.name)
                                .font(.title3.weight(.bold))
                                .foregroundStyle(Color("AppTextPrimary"))
                                .lineLimit(1)
                            Text("\(tag.songCount) songs · \(linkedEntries.count) journal links")
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                        Spacer()
                    }
                }

                if linkedEntries.isEmpty {
                    SoftCard {
                        VStack(spacing: 10) {
                            Text("No linked notes")
                                .font(.headline)
                                .foregroundStyle(Color("AppTextPrimary"))
                            Text("Attach this tag in the journal editor to connect listening notes.")
                                .font(.subheadline)
                                .foregroundStyle(Color("AppTextSecondary"))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                    }
                } else {
                    ForEach(linkedEntries) { entry in
                        SoftCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(entry.trackName)
                                    .font(.headline)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                    .lineLimit(1)
                                Text(entry.content)
                                    .font(.subheadline)
                                    .foregroundStyle(Color("AppTextSecondary"))
                                    .lineLimit(4)
                                Text(entry.date, style: .date)
                                    .font(.caption2)
                                    .foregroundStyle(Color("AppAccent"))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
            .padding(16)
        }
        .screenBackground(opacity: 0.16)
        .navigationTitle(tag.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("AppBackground"), for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
