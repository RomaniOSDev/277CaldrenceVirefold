import Foundation

struct MusicTag: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var name: String
    var emoji: String
    var songCount: Int
    var isFavorite: Bool
    var createdAt: Date
    var isCurated: Bool

    init(
        id: UUID = UUID(),
        name: String,
        emoji: String,
        songCount: Int = 0,
        isFavorite: Bool = false,
        createdAt: Date = Date(),
        isCurated: Bool = false
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.songCount = songCount
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.isCurated = isCurated
    }
}
