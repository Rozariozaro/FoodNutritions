import Foundation

struct NutritionResponse: Codable {
    let itemId: Int
    let itemType: String
    let name: String
    let grams: Double
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double?
    let sodiumMg: Double?

    enum CodingKeys: String, CodingKey {
        case itemId   = "item_id"
        case itemType = "item_type"
        case name, grams, calories, protein, carbs, fat, fiber
        case sodiumMg = "sodium_mg"
    }
}
