import SwiftUI

struct TagExplorerView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var pulse = false
    @State private var sort: ExplorerSort = .az

    enum ExplorerSort: String, CaseIterable {
        case az = "A–Z"
        case popular = "Popular"
        case recentFav = "Recent Favs"
    }

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    private var sortedCatalog: [MusicTag] {
        switch sort {
        case .az:
            return AppDataStore.curatedCatalog.sorted { $0.name < $1.name }
        case .popular:
            return AppDataStore.curatedCatalog.sorted {
                let a = store.favoriteCuratedIds.contains($0.id.uuidString) ? 1 : 0
                let b = store.favoriteCuratedIds.contains($1.id.uuidString) ? 1 : 0
                if a != b { return a > b }
                return $0.name < $1.name
            }
        case .recentFav:
            let favs = AppDataStore.curatedCatalog.filter { store.favoriteCuratedIds.contains($0.id.uuidString) }
            let rest = AppDataStore.curatedCatalog.filter { !store.favoriteCuratedIds.contains($0.id.uuidString) }
            return favs + rest.sorted { $0.name < $1.name }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                explorerBanner

                HStack {
                    Text("Sort")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppTextSecondary"))
                    Spacer()
                    ForEach(ExplorerSort.allCases, id: \.self) { item in
                        Button {
                            sort = item
                            HapticService.light()
                        } label: {
                            Text(item.rawValue)
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(sort == item ? Color("AppBackground") : Color("AppTextPrimary"))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(sort == item ? Color("AppPrimary") : Color("AppSurface")))
                        }
                        .buttonStyle(.plain)
                    }
                }

                if !store.smartFavoriteTags.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Smart Favorites")
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(1)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(store.smartFavoriteTags) { tag in
                                    favoriteChip(tag)
                                }
                            }
                        }
                    }
                } else if !store.favoriteTags.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Favorites")
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(1)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(store.favoriteTags) { tag in
                                    favoriteChip(tag)
                                }
                            }
                        }
                    }
                }

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Array(sortedCatalog.enumerated()), id: \.element.id) { index, tag in
                        curatedCard(tag, index: index)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 28)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }

    private var explorerBanner: some View {
        ZStack {
            Image("img_card")
                .resizable()
                .scaledToFill()
                .frame(height: 160)
                .clipped()
            LinearGradient(
                colors: [
                    Color("AppBackground").opacity(0.2),
                    Color("AppPrimary").opacity(0.25),
                    Color("AppBackground").opacity(0.85)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            VStack(spacing: 8) {
                Image(systemName: "opticaldisc.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color("AppPrimary"))
                    .scaleEffect(pulse ? 1.08 : 0.94)
                    .shadow(color: Color("AppPrimary").opacity(0.55), radius: pulse ? 16 : 6)
                Text("Curated Moods")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text("Discover ready-made tags for every vibe")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .padding()
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color("AppAccent"), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: .black.opacity(0.45), radius: 16, y: 10)
    }

    private func favoriteChip(_ tag: MusicTag) -> some View {
        HStack(spacing: 6) {
            Text(tag.emoji)
            Text(tag.name)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color("AppSurface"))
                .shadow(color: Color("AppPrimary").opacity(0.25), radius: 6, y: 3)
        )
        .overlay(
            Capsule().stroke(Color("AppPrimary").opacity(0.5), lineWidth: 1)
        )
    }

    private func curatedCard(_ tag: MusicTag, index: Int) -> some View {
        let isFavorite = store.favoriteCuratedIds.contains(tag.id.uuidString)
        return VStack(alignment: .leading, spacing: 10) {
            ZStack {
                Image(index % 2 == 0 ? "img_card" : "img_accent")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 90)
                    .clipped()
                    .opacity(0.55)
                LinearGradient(
                    colors: [Color("AppSurface").opacity(0.2), Color("AppBackground").opacity(0.85)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                Text(tag.emoji)
                    .font(.system(size: 36))
                    .shadow(color: .black.opacity(0.5), radius: 4, y: 2)
            }
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            Text(tag.name)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            HStack {
                Button {
                    store.toggleFavorite(tag)
                } label: {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .foregroundStyle(Color("AppPrimary"))
                        .frame(minWidth: 36, minHeight: 36)
                }
                .buttonStyle(.plain)

                Spacer()

                Button {
                    store.adoptCuratedTag(tag)
                } label: {
                    Text("Add")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("AppBackground"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(
                            LinearGradient(colors: [Color("AppPrimary"), Color("AppAccent")], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(
            LinearGradient(
                colors: [Color("AppSurface"), Color("AppSurface").opacity(0.75)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.35), radius: 10, y: 6)
    }
}
