import SwiftUI

struct TagsHubView: View {
    @State private var mode = 0
    @State private var showSearch = false
    @State private var showQuickAdd = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Mode", selection: $mode) {
                    Text("Library").tag(0)
                    Text("Explorer").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                if mode == 0 {
                    TagLibraryView()
                } else {
                    TagExplorerView()
                }
            }
            .screenBackground(opacity: 0.22)
            .navigationTitle(mode == 0 ? "Tag Library" : "Tag Explorer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        NavigationLink("Mood Playlists") { MoodPlaylistsView() }
                        NavigationLink("Listening History") { ListeningTimelineView() }
                        NavigationLink("Tag Rules") { TagRulesView() }
                        NavigationLink("Merge Tags") { TagMergeView() }
                        NavigationLink("Share Card") { ShareCardView() }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(Color("AppPrimary"))
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        showSearch = true
                        HapticService.light()
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Color("AppPrimary"))
                    }
                    Button {
                        showQuickAdd = true
                        HapticService.medium()
                    } label: {
                        Image(systemName: "plus.square.on.square")
                            .foregroundStyle(Color("AppPrimary"))
                    }
                }
            }
            .sheet(isPresented: $showSearch) {
                GlobalSearchView()
            }
            .sheet(isPresented: $showQuickAdd) {
                QuickAddSheet()
            }
        }
    }
}
