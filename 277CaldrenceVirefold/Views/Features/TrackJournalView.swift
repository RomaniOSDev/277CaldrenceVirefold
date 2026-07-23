import SwiftUI

struct TrackJournalView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var showEditor = false
    @State private var editingEntry: JournalEntry?
    @State private var appear = false
    @State private var promptTrack = ""
    @State private var promptNote = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    journalHeader
                        .opacity(appear ? 1 : 0)
                        .scaleEffect(appear ? 1 : 0.96)

                    if store.showDailyPrompt {
                        dailyPromptCard
                    }

                    if store.entries.isEmpty {
                        SoftCard {
                            VStack(spacing: 12) {
                                Image(systemName: "music.note.list")
                                    .font(.system(size: 40))
                                    .foregroundStyle(Color("AppAccent"))
                                Text("No journal entries")
                                    .font(.headline)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                    .lineLimit(1)
                                Text("Capture thoughts about tracks as you listen — or answer today's prompt.")
                                    .font(.subheadline)
                                    .foregroundStyle(Color("AppTextSecondary"))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(3)
                                    .minimumScaleFactor(0.8)
                                Button {
                                    editingEntry = nil
                                    showEditor = true
                                    HapticService.medium()
                                } label: {
                                    Text("Write First Note")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(PrimaryButtonStyle())
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                        }
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(store.entries) { entry in
                                entryCard(entry)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 28)
            }
            .screenBackground(opacity: 0.2)
            .navigationTitle("Track Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        editingEntry = nil
                        showEditor = true
                        HapticService.medium()
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .foregroundStyle(Color("AppPrimary"))
                    }
                }
            }
            .toolbarBackground(Color("AppBackground"), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showEditor) {
                JournalEditorSheet(entry: editingEntry)
            }
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) { appear = true }
            }
        }
    }

    private var dailyPromptCard: some View {
        SoftCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Daily Prompt")
                        .font(.headline)
                        .foregroundStyle(Color("AppPrimary"))
                    Spacer()
                    Button("Skip") {
                        store.dismissDailyPrompt()
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppTextSecondary"))
                }
                Text(DailyPrompt.prompt())
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color("AppTextPrimary"))
                TextField("Track name", text: $promptTrack)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color("AppBackground").opacity(0.55)))
                TextField("Your answer", text: $promptNote)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color("AppBackground").opacity(0.55)))
                Button {
                    let track = promptTrack.trimmingCharacters(in: .whitespacesAndNewlines)
                    let note = promptNote.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !track.isEmpty, !note.isEmpty else {
                        HapticService.warning()
                        return
                    }
                    store.answerDailyPrompt(trackName: track, note: note)
                    promptTrack = ""
                    promptNote = ""
                } label: {
                    Text("Save Answer")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
    }

    private var journalHeader: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        AngularGradient(
                            colors: [Color("AppPrimary"), Color("AppAccent"), Color("AppPrimary").opacity(0.3), Color("AppPrimary")],
                            center: .center
                        )
                    )
                    .frame(width: 64, height: 64)
                    .blur(radius: 0.5)
                Image("img_accent")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 52, height: 52)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color("AppPrimary"), lineWidth: 2))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Listening Notes")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text("\(store.entries.count) entries written")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            LinearGradient(colors: [Color("AppSurface"), Color("AppBackground")], startPoint: .leading, endPoint: .trailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color("AppPrimary").opacity(0.2), radius: 12, y: 6)
    }

    private func entryCard(_ entry: JournalEntry) -> some View {
        SoftCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "waveform")
                        .foregroundStyle(Color("AppPrimary"))
                    Text(entry.trackName)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Spacer()
                    Text(entry.date, style: .date)
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(1)
                }
                Text(entry.content)
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(5)
                    .minimumScaleFactor(0.85)

                let linked = store.tags(for: entry)
                if !linked.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(linked) { tag in
                                Text("\(tag.emoji) \(tag.name)")
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(Color("AppTextPrimary"))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Capsule().fill(Color("AppPrimary").opacity(0.22)))
                            }
                        }
                    }
                }

                HStack {
                    Spacer()
                    Button("Edit") {
                        editingEntry = entry
                        showEditor = true
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppAccent"))
                    Button("Delete", role: .destructive) {
                        store.deleteEntry(entry)
                    }
                    .font(.caption.weight(.semibold))
                }
            }
        }
    }
}

struct JournalEditorSheet: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.dismiss) private var dismiss
    let entry: JournalEntry?

    @State private var trackName = ""
    @State private var content = ""
    @State private var date = Date()
    @State private var selectedTagIds: Set<UUID> = []
    @State private var shake: CGFloat = 0

    var body: some View {
        NavigationStack {
            Form {
                Section("Track") {
                    TextField("Track name", text: $trackName)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                Section("Notes") {
                    TextEditor(text: $content)
                        .frame(minHeight: 140)
                }
                if !store.libraryTags.isEmpty {
                    Section("Tags") {
                        ForEach(store.libraryTags) { tag in
                            Button {
                                if selectedTagIds.contains(tag.id) {
                                    selectedTagIds.remove(tag.id)
                                } else {
                                    selectedTagIds.insert(tag.id)
                                }
                                HapticService.light()
                            } label: {
                                HStack {
                                    Text("\(tag.emoji) \(tag.name)")
                                        .foregroundStyle(Color("AppTextPrimary"))
                                    Spacer()
                                    if selectedTagIds.contains(tag.id) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(Color("AppPrimary"))
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("AppBackground"))
            .navigationTitle(entry == nil ? "New Entry" : "Edit Entry")
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
                if let entry {
                    trackName = entry.trackName
                    content = entry.content
                    date = entry.date
                    selectedTagIds = Set(entry.tagIds)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func save() {
        let t = trackName.trimmingCharacters(in: .whitespacesAndNewlines)
        let c = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty, !c.isEmpty else {
            withAnimation(.default) { shake += 1 }
            HapticService.warning()
            return
        }
        if var existing = entry {
            existing.trackName = t
            existing.content = c
            existing.date = date
            existing.tagIds = Array(selectedTagIds)
            store.updateEntry(existing)
        } else {
            store.addEntry(trackName: t, content: c, date: date, tagIds: Array(selectedTagIds))
        }
        dismiss()
    }
}
