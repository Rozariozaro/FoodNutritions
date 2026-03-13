import Foundation

struct AutocompleteSuggestion: Codable, Identifiable {
    let id: UUID
    let name: String
    let type: String

    init(name: String, type: String) {
        self.id = UUID()
        self.name = name
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case name, type
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.name = try container.decode(String.self, forKey: .name)
        self.type = try container.decode(String.self, forKey: .type)
    }
}
