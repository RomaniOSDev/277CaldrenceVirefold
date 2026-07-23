import SwiftUI

struct MoodPlaylistsView: View {
    @EnvironmentObject private var store: AppDataStore

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                SoftCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mood Playlists")
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text("Built from journal entries linked to your tags.")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                if store.moodPlaylists.isEmpty {
                    SoftCard {
                        VStack(spacing: 12) {
                            Image(systemName: "music.note.list")
                                .font(.system(size: 36))
                                .foregroundStyle(Color("AppPrimary"))
                            Text("No playlists yet")
                                .font(.headline)
                                .foregroundStyle(Color("AppTextPrimary"))
                            Text("Link tags to journal entries to build mood playlists.")
                                .font(.subheadline)
                                .foregroundStyle(Color("AppTextSecondary"))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                    }
                } else {
                    ForEach(store.moodPlaylists) { playlist in
                        SoftCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text(playlist.tag.emoji)
                                        .font(.title)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(playlist.tag.name)
                                            .font(.headline)
                                            .foregroundStyle(Color("AppTextPrimary"))
                                            .lineLimit(1)
                                        Text("\(playlist.tracks.count) tracks")
                                            .font(.caption)
                                            .foregroundStyle(Color("AppTextSecondary"))
                                    }
                                    Spacer()
                                }
                                ForEach(playlist.tracks.prefix(8)) { track in
                                    HStack {
                                        Image(systemName: "play.circle.fill")
                                            .foregroundStyle(Color("AppAccent"))
                                        Text(track.trackName)
                                            .font(.subheadline)
                                            .foregroundStyle(Color("AppTextPrimary"))
                                            .lineLimit(1)
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(16)
        }
        .screenBackground(opacity: 0.16)
        .navigationTitle("Mood Playlists")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("AppBackground"), for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
