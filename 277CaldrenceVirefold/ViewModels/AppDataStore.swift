import Foundation
import SwiftUI
import Combine

final class AppDataStore: ObservableObject {
    static let shared = AppDataStore()

    @Published var tags: [MusicTag] = []
    @Published var entries: [JournalEntry] = []
    @Published var tagRules: [TagRule] = []
    @Published var stats: UserStats = UserStats()
    @Published var unlockedAchievements: Set<String> = []
    @Published var hasSeenOnboarding: Bool = false
    @Published var bannerTitle: String?
    @Published var bannerSubtitle: String?
    @Published var favoriteCuratedIds: Set<String> = []
    @Published var dailyPromptAnsweredDay: String = ""

    private let defaults = UserDefaults.standard
    private let tagsKey = "ht_tags"
    private let entriesKey = "ht_entries"
    private let rulesKey = "ht_tag_rules"
    private let statsKey = "ht_stats"
    private let unlockedKey = "ht_unlocked"
    private let onboardingKey = "ht_onboarding"
    private let favoritesKey = "ht_fav_curated"
    private let promptDayKey = "ht_prompt_day"

    static let curatedCatalog: [MusicTag] = [
        MusicTag(id: UUID(uuidString: "11111111-1111-1111-1111-111111111101")!, name: "Chill Vibes", emoji: "🌊", isCurated: true),
        MusicTag(id: UUID(uuidString: "11111111-1111-1111-1111-111111111102")!, name: "Workout", emoji: "💪", isCurated: true),
        MusicTag(id: UUID(uuidString: "11111111-1111-1111-1111-111111111103")!, name: "Relaxation", emoji: "🧘", isCurated: true),
        MusicTag(id: UUID(uuidString: "11111111-1111-1111-1111-111111111104")!, name: "Focus Flow", emoji: "🎯", isCurated: true),
        MusicTag(id: UUID(uuidString: "11111111-1111-1111-1111-111111111105")!, name: "Party Mix", emoji: "🎉", isCurated: true),
        MusicTag(id: UUID(uuidString: "11111111-1111-1111-1111-111111111106")!, name: "Late Night", emoji: "🌙", isCurated: true),
        MusicTag(id: UUID(uuidString: "11111111-1111-1111-1111-111111111107")!, name: "Morning Drive", emoji: "☀️", isCurated: true),
        MusicTag(id: UUID(uuidString: "11111111-1111-1111-1111-111111111108")!, name: "Romance", emoji: "💕", isCurated: true),
        MusicTag(id: UUID(uuidString: "11111111-1111-1111-1111-111111111109")!, name: "Indie Finds", emoji: "🎸", isCurated: true),
        MusicTag(id: UUID(uuidString: "11111111-1111-1111-1111-111111111110")!, name: "Jazz Lounge", emoji: "🎷", isCurated: true),
        MusicTag(id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!, name: "Throwback", emoji: "📻", isCurated: true),
        MusicTag(id: UUID(uuidString: "11111111-1111-1111-1111-111111111112")!, name: "Rainy Day", emoji: "🌧️", isCurated: true)
    ]

    static let defaultRules: [TagRule] = [
        TagRule(keyword: "rain", tagName: "Rainy Day", emoji: "🌧️"),
        TagRule(keyword: "gym", tagName: "Workout", emoji: "💪"),
        TagRule(keyword: "workout", tagName: "Workout", emoji: "💪"),
        TagRule(keyword: "chill", tagName: "Chill Vibes", emoji: "🌊"),
        TagRule(keyword: "relax", tagName: "Relaxation", emoji: "🧘"),
        TagRule(keyword: "focus", tagName: "Focus Flow", emoji: "🎯"),
        TagRule(keyword: "study", tagName: "Focus Flow", emoji: "🎯"),
        TagRule(keyword: "night", tagName: "Late Night", emoji: "🌙"),
        TagRule(keyword: "party", tagName: "Party Mix", emoji: "🎉"),
        TagRule(keyword: "drive", tagName: "Morning Drive", emoji: "☀️"),
        TagRule(keyword: "love", tagName: "Romance", emoji: "💕"),
        TagRule(keyword: "jazz", tagName: "Jazz Lounge", emoji: "🎷")
    ]

    private init() {
        load()
    }

    var libraryTags: [MusicTag] {
        tags.filter { !$0.isCurated }.sorted { $0.createdAt > $1.createdAt }
    }

    var favoriteTags: [MusicTag] {
        let curated = Self.curatedCatalog.filter { favoriteCuratedIds.contains($0.id.uuidString) }
        let custom = tags.filter { $0.isFavorite && !$0.isCurated }
        return curated + custom
    }

    var smartFavoriteTags: [MusicTag] {
        let calendar = Calendar.current
        guard let cutoff = calendar.date(byAdding: .day, value: -14, to: Date()) else { return favoriteTags }
        var scores: [UUID: Int] = [:]
        for entry in entries where entry.date >= cutoff {
            for id in entry.tagIds {
                scores[id, default: 0] += 2
            }
        }
        for tag in libraryTags where tag.createdAt >= cutoff {
            scores[tag.id, default: 0] += 1 + min(tag.songCount, 5)
        }
        let ranked = libraryTags
            .map { ($0, scores[$0.id, default: 0] + ($0.isFavorite ? 3 : 0)) }
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
            .prefix(8)
            .map(\.0)
        if ranked.isEmpty { return Array(favoriteTags.prefix(8)) }
        return Array(ranked)
    }

    var moodPlaylists: [MoodPlaylist] {
        let source = libraryTags.isEmpty ? favoriteTags : libraryTags
        return source.compactMap { tag in
            let tracks = entries.filter { $0.tagIds.contains(tag.id) }
            guard !tracks.isEmpty else { return nil }
            return MoodPlaylist(id: tag.id, tag: tag, tracks: tracks)
        }
    }

    var showDailyPrompt: Bool {
        dayStamp(from: Date()) != dailyPromptAnsweredDay
    }

    // MARK: - Tags

    @discardableResult
    func addTag(name: String, emoji: String, songCount: Int = 0, silent: Bool = false) -> MusicTag? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if let existing = tags.first(where: { $0.name.caseInsensitiveCompare(trimmed) == .orderedSame }) {
            return existing
        }
        let tag = MusicTag(name: trimmed, emoji: emoji, songCount: max(0, songCount))
        tags.append(tag)
        stats.itemsAdded += 1
        refreshUniqueTags()
        recordActivity()
        persist()
        evaluateAchievements()
        if !silent { HapticService.success() }
        return tag
    }

    func updateTag(_ tag: MusicTag) {
        guard let idx = tags.firstIndex(where: { $0.id == tag.id }) else { return }
        tags[idx] = tag
        refreshUniqueTags()
        persist()
        HapticService.light()
    }

    func deleteTag(_ tag: MusicTag) {
        tags.removeAll { $0.id == tag.id }
        for i in entries.indices {
            entries[i].tagIds.removeAll { $0 == tag.id }
        }
        refreshUniqueTags()
        persist()
        HapticService.warning()
    }

    func toggleFavorite(_ tag: MusicTag) {
        if tag.isCurated {
            let key = tag.id.uuidString
            if favoriteCuratedIds.contains(key) {
                favoriteCuratedIds.remove(key)
            } else {
                favoriteCuratedIds.insert(key)
                HapticService.success()
            }
            persist()
            return
        }
        guard let idx = tags.firstIndex(where: { $0.id == tag.id }) else { return }
        tags[idx].isFavorite.toggle()
        if tags[idx].isFavorite { HapticService.success() } else { HapticService.light() }
        persist()
    }

    func adoptCuratedTag(_ curated: MusicTag) {
        if tags.contains(where: { $0.name.caseInsensitiveCompare(curated.name) == .orderedSame }) {
            HapticService.warning()
            return
        }
        _ = addTag(name: curated.name, emoji: curated.emoji, songCount: 0)
    }

    func mergeTags(source: MusicTag, into target: MusicTag) {
        guard source.id != target.id,
              let targetIdx = tags.firstIndex(where: { $0.id == target.id }),
              tags.contains(where: { $0.id == source.id }) else {
            HapticService.warning()
            return
        }
        tags[targetIdx].songCount += source.songCount
        tags[targetIdx].isFavorite = tags[targetIdx].isFavorite || source.isFavorite
        for i in entries.indices {
            if entries[i].tagIds.contains(source.id) {
                entries[i].tagIds.removeAll { $0 == source.id }
                if !entries[i].tagIds.contains(target.id) {
                    entries[i].tagIds.append(target.id)
                }
            }
        }
        tags.removeAll { $0.id == source.id }
        refreshUniqueTags()
        persist()
        HapticService.success()
        showBanner("Tags Merged", subtitle: "\(source.name) → \(target.name)")
    }

    func tags(for entry: JournalEntry) -> [MusicTag] {
        let ids = Set(entry.tagIds)
        return tags.filter { ids.contains($0.id) }
    }

    func entries(for tag: MusicTag) -> [JournalEntry] {
        entries.filter { $0.tagIds.contains(tag.id) }
    }

    // MARK: - Journal

    func addEntry(trackName: String, content: String, date: Date = Date(), tagIds: [UUID] = []) {
        let trimmedTrack = trackName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTrack.isEmpty, !trimmedContent.isEmpty else { return }
        var resolved = Set(tagIds)
        for id in applyRules(to: "\(trimmedTrack) \(trimmedContent)") {
            resolved.insert(id)
        }
        entries.insert(
            JournalEntry(trackName: trimmedTrack, content: trimmedContent, date: date, tagIds: Array(resolved)),
            at: 0
        )
        stats.entriesWritten += 1
        recordActivity()
        persist()
        evaluateAchievements()
        HapticService.success()
    }

    func updateEntry(_ entry: JournalEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        var updated = entry
        var resolved = Set(updated.tagIds)
        for id in applyRules(to: "\(updated.trackName) \(updated.content)") {
            resolved.insert(id)
        }
        updated.tagIds = Array(resolved)
        entries[idx] = updated
        persist()
        HapticService.light()
    }

    func deleteEntry(_ entry: JournalEntry) {
        entries.removeAll { $0.id == entry.id }
        persist()
        HapticService.warning()
    }

    func quickAdd(trackName: String, note: String, tagName: String?, emoji: String) {
        var tagIds: [UUID] = []
        if let tagName, !tagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if let tag = addTag(name: tagName, emoji: emoji, songCount: 1, silent: true) {
                tagIds = [tag.id]
            }
        }
        let content = note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "Quick capture"
            : note
        addEntry(trackName: trackName, content: content, tagIds: tagIds)
    }

    func answerDailyPrompt(trackName: String, note: String) {
        addEntry(trackName: trackName, content: note)
        dailyPromptAnsweredDay = dayStamp(from: Date())
        persist()
    }

    func dismissDailyPrompt() {
        dailyPromptAnsweredDay = dayStamp(from: Date())
        persist()
        HapticService.light()
    }

    // MARK: - Tag Rules

    func addTagRule(keyword: String, tagName: String, emoji: String) {
        let key = keyword.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let name = tagName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty, !name.isEmpty else { return }
        tagRules.append(TagRule(keyword: key, tagName: name, emoji: emoji))
        persist()
        HapticService.success()
    }

    func deleteTagRule(_ rule: TagRule) {
        tagRules.removeAll { $0.id == rule.id }
        persist()
        HapticService.warning()
    }

    func applyRules(to text: String) -> [UUID] {
        let haystack = text.lowercased()
        var ids: [UUID] = []
        for rule in tagRules {
            guard haystack.contains(rule.keyword.lowercased()) else { continue }
            if let tag = addTag(name: rule.tagName, emoji: rule.emoji, songCount: 0, silent: true) {
                if !ids.contains(tag.id) { ids.append(tag.id) }
            }
        }
        return ids
    }

    // MARK: - Search / Compare / Timeline helpers

    func search(query: String) -> [SearchHit] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return [] }
        var hits: [SearchHit] = []
        for tag in libraryTags where tag.name.lowercased().contains(q) || tag.emoji.contains(q) {
            hits.append(SearchHit(id: tag.id, kind: .tag, title: tag.name, subtitle: "\(tag.songCount) songs", emoji: tag.emoji))
        }
        for tag in Self.curatedCatalog where tag.name.lowercased().contains(q) {
            hits.append(SearchHit(id: tag.id, kind: .curated, title: tag.name, subtitle: "Curated mood", emoji: tag.emoji))
        }
        for entry in entries {
            let blob = "\(entry.trackName) \(entry.content)".lowercased()
            if blob.contains(q) {
                hits.append(SearchHit(id: entry.id, kind: .entry, title: entry.trackName, subtitle: entry.content, emoji: "🎵"))
            }
        }
        return hits
    }

    func weekSnapshot(offsetWeeks: Int) -> WeekCompareSnapshot {
        let calendar = Calendar.current
        let now = Date()
        guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -offsetWeeks, to: calendar.startOfDay(for: now)),
              let intervalStart = calendar.dateInterval(of: .weekOfYear, for: weekStart)?.start,
              let intervalEnd = calendar.date(byAdding: .day, value: 7, to: intervalStart) else {
            return WeekCompareSnapshot(tagsCreated: 0, entriesWritten: 0, songsLogged: 0)
        }
        let tagsCreated = libraryTags.filter { $0.createdAt >= intervalStart && $0.createdAt < intervalEnd }.count
        let weekEntries = entries.filter { $0.date >= intervalStart && $0.date < intervalEnd }
        let songs = weekEntries.count
        return WeekCompareSnapshot(tagsCreated: tagsCreated, entriesWritten: weekEntries.count, songsLogged: songs)
    }

    struct TimelineItem: Identifiable, Equatable {
        enum Kind: Equatable { case tag, entry }
        let id: UUID
        let kind: Kind
        let date: Date
        let title: String
        let detail: String
        let emoji: String
    }

    func timelineItems() -> [TimelineItem] {
        var items: [TimelineItem] = []
        for tag in libraryTags {
            items.append(TimelineItem(id: tag.id, kind: .tag, date: tag.createdAt, title: tag.name, detail: "Tag created · \(tag.songCount) songs", emoji: tag.emoji))
        }
        for entry in entries {
            let tagNames = tags(for: entry).map { "\($0.emoji) \($0.name)" }.joined(separator: " · ")
            let detail = tagNames.isEmpty ? entry.content : "\(tagNames)\n\(entry.content)"
            items.append(TimelineItem(id: entry.id, kind: .entry, date: entry.date, title: entry.trackName, detail: detail, emoji: "🎧"))
        }
        return items.sorted { $0.date > $1.date }
    }

    func shareCardQuote() -> (tagsLine: String, entryLine: String) {
        let top = libraryTags.sorted { $0.songCount > $1.songCount }.prefix(3)
        let tagsLine = top.isEmpty
            ? "Building my listening map"
            : top.map { "\($0.emoji) \($0.name)" }.joined(separator: "  ")
        let entryLine = entries.first?.content ?? "Every track leaves a mark."
        return (tagsLine, entryLine)
    }

    // MARK: - Onboarding / Reset

    func completeOnboarding() {
        hasSeenOnboarding = true
        defaults.set(true, forKey: onboardingKey)
        HapticService.success()
    }

    func resetOnboarding() {
        hasSeenOnboarding = false
        defaults.set(false, forKey: onboardingKey)
        HapticService.medium()
    }

    func resetAll() {
        tags = []
        entries = []
        tagRules = Self.defaultRules
        stats = UserStats()
        unlockedAchievements = []
        favoriteCuratedIds = []
        bannerTitle = nil
        bannerSubtitle = nil
        dailyPromptAnsweredDay = ""
        persist()
        HapticService.warning()
    }

    // MARK: - Achievements

    func evaluateAchievements() {
        for kind in AchievementKind.allCases {
            guard kind.isUnlocked(stats: stats) else { continue }
            let key = kind.rawValue
            guard !unlockedAchievements.contains(key) else { continue }
            unlockedAchievements.insert(key)
            showBanner(kind.title, subtitle: kind.celebrationLine)
            HapticService.success()
            HapticService.play(1025)
        }
        persist()
    }

    func showBanner(_ title: String, subtitle: String? = nil) {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
            bannerTitle = title
            bannerSubtitle = subtitle
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) { [weak self] in
            withAnimation(.easeOut(duration: 0.35)) {
                self?.bannerTitle = nil
                self?.bannerSubtitle = nil
            }
        }
    }

    // MARK: - Persistence

    private func refreshUniqueTags() {
        let names = Set(libraryTags.map { $0.name.lowercased() })
        stats.uniqueTags = names.count
    }

    private func recordActivity() {
        let today = dayStamp(from: Date())
        if stats.lastActiveDay.isEmpty {
            stats.streak = 1
            stats.lastActiveDay = today
            return
        }
        if stats.lastActiveDay == today { return }
        if let last = date(from: stats.lastActiveDay),
           let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()),
           dayStamp(from: yesterday) == stats.lastActiveDay || Calendar.current.isDate(last, inSameDayAs: yesterday) {
            stats.streak += 1
        } else {
            stats.streak = 1
        }
        stats.lastActiveDay = today
    }

    private func dayStamp(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func date(from stamp: String) -> Date? {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: stamp)
    }

    private func load() {
        hasSeenOnboarding = defaults.bool(forKey: onboardingKey)
        dailyPromptAnsweredDay = defaults.string(forKey: promptDayKey) ?? ""
        if let data = defaults.data(forKey: tagsKey),
           let decoded = try? JSONDecoder().decode([MusicTag].self, from: data) {
            tags = decoded
        }
        if let data = defaults.data(forKey: entriesKey),
           let decoded = try? JSONDecoder().decode([JournalEntry].self, from: data) {
            entries = decoded
        }
        if let data = defaults.data(forKey: rulesKey),
           let decoded = try? JSONDecoder().decode([TagRule].self, from: data) {
            tagRules = decoded
        } else {
            tagRules = Self.defaultRules
        }
        if let data = defaults.data(forKey: statsKey),
           let decoded = try? JSONDecoder().decode(UserStats.self, from: data) {
            stats = decoded
        }
        if let arr = defaults.array(forKey: unlockedKey) as? [String] {
            unlockedAchievements = Set(arr)
        }
        if let arr = defaults.array(forKey: favoritesKey) as? [String] {
            favoriteCuratedIds = Set(arr)
        }
        refreshUniqueTags()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(tags) {
            defaults.set(data, forKey: tagsKey)
        }
        if let data = try? JSONEncoder().encode(entries) {
            defaults.set(data, forKey: entriesKey)
        }
        if let data = try? JSONEncoder().encode(tagRules) {
            defaults.set(data, forKey: rulesKey)
        }
        if let data = try? JSONEncoder().encode(stats) {
            defaults.set(data, forKey: statsKey)
        }
        defaults.set(Array(unlockedAchievements), forKey: unlockedKey)
        defaults.set(Array(favoriteCuratedIds), forKey: favoritesKey)
        defaults.set(hasSeenOnboarding, forKey: onboardingKey)
        defaults.set(dailyPromptAnsweredDay, forKey: promptDayKey)
    }
}
