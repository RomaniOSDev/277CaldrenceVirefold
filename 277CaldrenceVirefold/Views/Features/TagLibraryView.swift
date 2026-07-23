import SwiftUI

struct TagLibraryView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var showEditor = false
    @State private var editingTag: MusicTag?
    @State private var appear = false
    @State private var filter: LibraryFilter = .all

    enum LibraryFilter: String, CaseIterable {
        case all = "All"
        case favorites = "Favorites"
        case recent = "Recent"
        case mostSongs = "Most Songs"
    }

    private var filteredTags: [MusicTag] {
        switch filter {
        case .all:
            return store.libraryTags
        case .favorites:
            return store.libraryTags.filter(\.isFavorite)
        case .recent:
            return Array(store.libraryTags.prefix(12))
        case .mostSongs:
            return store.libraryTags.sorted { $0.songCount > $1.songCount }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                libraryHero
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 18)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(LibraryFilter.allCases, id: \.self) { item in
                            Button {
                                filter = item
                                HapticService.light()
                            } label: {
                                Text(item.rawValue)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(filter == item ? Color("AppBackground") : Color("AppTextPrimary"))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule().fill(filter == item ? Color("AppPrimary") : Color("AppSurface"))
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                if !store.smartFavoriteTags.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Smart Favorites")
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(store.smartFavoriteTags) { tag in
                                    NavigationLink {
                                        TagDetailView(tag: tag)
                                    } label: {
                                        HStack(spacing: 6) {
                                            Text(tag.emoji)
                                            Text(tag.name)
                                                .font(.caption.weight(.semibold))
                                                .foregroundStyle(Color("AppTextPrimary"))
                                                .lineLimit(1)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Capsule().fill(Color("AppSurface")))
                                        .overlay(Capsule().stroke(Color("AppAccent").opacity(0.5), lineWidth: 1))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }

                if store.libraryTags.isEmpty {
                    emptyState
                } else if filteredTags.isEmpty {
                    SoftCard {
                        Text("Nothing in this filter yet.")
                            .font(.subheadline)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .frame(maxWidth: .infinity)
                    }
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(filteredTags.enumerated()), id: \.element.id) { index, tag in
                            NavigationLink {
                                TagDetailView(tag: tag)
                            } label: {
                                tagRow(tag)
                            }
                            .buttonStyle(.plain)
                            .opacity(appear ? 1 : 0)
                            .offset(y: appear ? 0 : 12)
                            .animation(.easeOut(duration: 0.4).delay(Double(index) * 0.04), value: appear)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 28)
        }
        .overlay(alignment: .bottomTrailing) {
            Button {
                editingTag = nil
                showEditor = true
                HapticService.medium()
            } label: {
                Image(systemName: "plus")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color("AppBackground"))
                    .frame(width: 56, height: 56)
                    .background(
                        LinearGradient(colors: [Color("AppPrimary"), Color("AppAccent")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .clipShape(Circle())
                    .shadow(color: Color("AppPrimary").opacity(0.5), radius: 12, y: 6)
            }
            .padding(20)
        }
        .sheet(isPresented: $showEditor) {
            TagEditorSheet(tag: editingTag)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appear = true }
        }
    }

    private var libraryHero: some View {
        ZStack(alignment: .bottomLeading) {
            Image("img_banner")
                .resizable()
                .scaledToFill()
                .frame(height: 140)
                .clipped()
                .overlay {
                    LinearGradient(
                        colors: [Color("AppBackground").opacity(0.15), Color("AppBackground").opacity(0.92)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            VStack(alignment: .leading, spacing: 6) {
                Text("Your Collection")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text("\(store.libraryTags.count) tags · \(store.libraryTags.reduce(0) { $0 + $1.songCount }) songs")
                    .font(.subheadline)
                    .foregroundStyle(Color("AppAccent"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.4), radius: 14, y: 8)
    }

    private var emptyState: some View {
        SoftCard {
            VStack(spacing: 14) {
                Image(systemName: "opticaldisc")
                    .font(.system(size: 44))
                    .foregroundStyle(Color("AppPrimary"))
                    .shadow(color: Color("AppPrimary").opacity(0.4), radius: 10)
                Text("No tags yet")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                Text("Create your first tag to start organizing tracks by mood and moment.")
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
                Button {
                    editingTag = nil
                    showEditor = true
                    HapticService.medium()
                } label: {
                    Text("Add First Tag")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
    }

    private func tagRow(_ tag: MusicTag) -> some View {
        SoftCard {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color("AppPrimary").opacity(0.45), Color("AppSurface")],
                                center: .center,
                                startRadius: 2,
                                endRadius: 28
                            )
                        )
                        .frame(width: 52, height: 52)
                    Text(tag.emoji)
                        .font(.title2)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(tag.name)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text("\(tag.songCount) songs · \(store.entries(for: tag).count) notes")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                Button {
                    store.toggleFavorite(tag)
                } label: {
                    Image(systemName: tag.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(tag.isFavorite ? Color("AppPrimary") : Color("AppTextSecondary"))
                }
                .buttonStyle(.plain)
                Menu {
                    Button("Edit") {
                        editingTag = tag
                        showEditor = true
                    }
                    Button("Delete", role: .destructive) {
                        store.deleteTag(tag)
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                        .foregroundStyle(Color("AppAccent"))
                        .frame(minWidth: 44, minHeight: 44)
                }
            }
        }
    }
}

struct TagEditorSheet: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss
    let tag: MusicTag?

    @State private var name = ""
    @State private var emoji = "🎵"
    @State private var songCount = 0
    @State private var shake: CGFloat = 0

    private let emojiChoices = ["🎵", "🎧", "🎸", "🎹", "🥁", "🎷", "🎤", "🔥", "🌙", "☀️", "🌊", "💫"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Tag") {
                    TextField("Name", text: $name)
                    Stepper("Songs: \(songCount)", value: $songCount, in: 0...999)
                }
                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(emojiChoices, id: \.self) { item in
                            Text(item)
                                .font(.title)
                                .padding(8)
                                .background(
                                    Circle()
                                        .fill(item == emoji ? Color("AppPrimary").opacity(0.35) : Color.clear)
                                )
                                .onTapGesture {
                                    emoji = item
                                    HapticService.light()
                                }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("AppBackground"))
            .navigationTitle(tag == nil ? "New Tag" : "Edit Tag")
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
            .onAppear {
                if let tag {
                    name = tag.name
                    emoji = tag.emoji
                    songCount = tag.songCount
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            withAnimation(.default) { shake += 1 }
            HapticService.warning()
            return
        }
        if var existing = tag {
            existing.name = trimmed
            existing.emoji = emoji
            existing.songCount = songCount
            store.updateTag(existing)
        } else {
            _ = store.addTag(name: trimmed, emoji: emoji, songCount: songCount)
        }
        dismiss()
    }
}
