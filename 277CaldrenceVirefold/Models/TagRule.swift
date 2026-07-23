import Foundation

struct TagRule: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var keyword: String
    var tagName: String
    var emoji: String

    init(
        id: UUID = UUID(),
        keyword: String,
        tagName: String,
        emoji: String
    ) {
        self.id = id
        self.keyword = keyword
        self.tagName = tagName
        self.emoji = emoji
    }
}

struct SearchHit: Identifiable, Equatable {
    enum Kind: Equatable { case tag, entry, curated }
    let id: UUID
    let kind: Kind
    let title: String
    let subtitle: String
    let emoji: String
}

struct WeekCompareSnapshot: Equatable {
    var tagsCreated: Int
    var entriesWritten: Int
    var songsLogged: Int
}

struct MoodPlaylist: Identifiable, Equatable {
    let id: UUID
    let tag: MusicTag
    let tracks: [JournalEntry]
}

enum DailyPrompt {
    static let prompts = [
        "What track hit hardest today, and why?",
        "Which song matched your mood this evening?",
        "Name one lyric or groove you can't shake.",
        "What would you put on a late-night drive right now?",
        "Which discovery deserves a permanent tag?"
    ]

    static func prompt(for date: Date = Date()) -> String {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        return prompts[day % prompts.count]
    }
}
