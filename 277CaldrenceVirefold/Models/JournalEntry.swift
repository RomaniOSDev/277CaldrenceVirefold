import Foundation

struct JournalEntry: Identifiable, Codable, Equatable {
    var id: UUID
    var trackName: String
    var content: String
    var date: Date
    var tagIds: [UUID]

    init(
        id: UUID = UUID(),
        trackName: String,
        content: String,
        date: Date = Date(),
        tagIds: [UUID] = []
    ) {
        self.id = id
        self.trackName = trackName
        self.content = content
        self.date = date
        self.tagIds = tagIds
    }

    enum CodingKeys: String, CodingKey {
        case id, trackName, content, date, tagIds
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        trackName = try container.decode(String.self, forKey: .trackName)
        content = try container.decode(String.self, forKey: .content)
        date = try container.decode(Date.self, forKey: .date)
        tagIds = try container.decodeIfPresent([UUID].self, forKey: .tagIds) ?? []
    }
}
