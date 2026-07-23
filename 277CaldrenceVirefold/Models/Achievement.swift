import Foundation

enum AchievementKind: String, Codable, CaseIterable {
    case firstTag
    case organizedCollection
    case diverseTags
    case powerUser
    case activeUser
    case dedicatedUser
    case threeDayStreak
    case weekLongHabit

    var title: String {
        switch self {
        case .firstTag: return "First Tag"
        case .organizedCollection: return "Organized Collection"
        case .diverseTags: return "Diverse Tags"
        case .powerUser: return "Power User"
        case .activeUser: return "Active User"
        case .dedicatedUser: return "Dedicated User"
        case .threeDayStreak: return "Three-Day Streak"
        case .weekLongHabit: return "Week-Long Habit"
        }
    }

    var detail: String {
        switch self {
        case .firstTag: return "Create your first music tag"
        case .organizedCollection: return "Add 10 tags to your library"
        case .diverseTags: return "Collect 5 unique tags"
        case .powerUser: return "Reach 50 tags created"
        case .activeUser: return "Write 10 journal entries"
        case .dedicatedUser: return "Write 50 journal entries"
        case .threeDayStreak: return "Stay active for 3 days"
        case .weekLongHabit: return "Keep a 7-day streak"
        }
    }

    var icon: String {
        switch self {
        case .firstTag: return "tag.fill"
        case .organizedCollection: return "rectangle.stack.fill"
        case .diverseTags: return "square.grid.2x2.fill"
        case .powerUser: return "bolt.fill"
        case .activeUser: return "book.fill"
        case .dedicatedUser: return "flame.fill"
        case .threeDayStreak: return "calendar"
        case .weekLongHabit: return "crown.fill"
        }
    }

    var celebrationLine: String {
        switch self {
        case .firstTag: return "Your library just took its first beat."
        case .organizedCollection: return "Ten tags deep — the collection is taking shape."
        case .diverseTags: return "Five unique vibes locked in."
        case .powerUser: return "Fifty tags. You're building a real archive."
        case .activeUser: return "Ten listening notes — the journal is alive."
        case .dedicatedUser: return "Fifty entries. Your taste has a paper trail."
        case .threeDayStreak: return "Three days in a row. Keep the groove."
        case .weekLongHabit: return "A full week of listening ritual. Crown earned."
        }
    }

    func isUnlocked(stats: UserStats) -> Bool {
        switch self {
        case .firstTag: return stats.itemsAdded >= 1
        case .organizedCollection: return stats.itemsAdded >= 10
        case .diverseTags: return stats.uniqueTags >= 5
        case .powerUser: return stats.itemsAdded >= 50
        case .activeUser: return stats.entriesWritten >= 10
        case .dedicatedUser: return stats.entriesWritten >= 50
        case .threeDayStreak: return stats.streak >= 3
        case .weekLongHabit: return stats.streak >= 7
        }
    }

    var goal: Int {
        switch self {
        case .firstTag: return 1
        case .organizedCollection: return 10
        case .diverseTags: return 5
        case .powerUser: return 50
        case .activeUser: return 10
        case .dedicatedUser: return 50
        case .threeDayStreak: return 3
        case .weekLongHabit: return 7
        }
    }

    func progress(stats: UserStats) -> Int {
        switch self {
        case .firstTag, .organizedCollection, .powerUser: return stats.itemsAdded
        case .diverseTags: return stats.uniqueTags
        case .activeUser, .dedicatedUser: return stats.entriesWritten
        case .threeDayStreak, .weekLongHabit: return stats.streak
        }
    }
}

struct UserStats: Codable, Equatable {
    var itemsAdded: Int = 0
    var entriesWritten: Int = 0
    var uniqueTags: Int = 0
    var streak: Int = 0
    var lastActiveDay: String = ""
}
