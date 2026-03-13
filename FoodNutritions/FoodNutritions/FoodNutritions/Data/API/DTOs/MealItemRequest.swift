import Foundation

struct MealItemRequest: Codable {
    let itemType: String
    let itemId: Int
    let grams: Double

    enum CodingKeys: String, CodingKey {
        case itemType = "item_type"
        case itemId   = "item_id"
        case grams
    }
}
