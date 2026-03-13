import Foundation

struct FoodSearchResult: Codable, Identifiable {
    let id: Int
    let name: String
    let type: String
    let calories100g: Double
    let protein100g: Double
    let carbs100g: Double
    let fat100g: Double
    let proteinDensity: Double
    let rank: Double?

    enum CodingKeys: String, CodingKey {
        case id, name, type, rank
        case calories100g    = "calories_100g"
        case protein100g     = "protein_100g"
        case carbs100g       = "carbs_100g"
        case fat100g         = "fat_100g"
        case proteinDensity  = "protein_density"
    }
}
