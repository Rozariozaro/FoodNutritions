import Foundation

struct FoodItem: Identifiable, Hashable {
    let id: Int
    let name: String
    let type: FoodType
    let caloriesPer100g: Double
    let proteinPer100g: Double
    let carbsPer100g: Double
    let fatPer100g: Double
    let proteinDensity: Double
    var micronutrients: [Micronutrient]
    var servingUnits: [ServingUnit]
}
