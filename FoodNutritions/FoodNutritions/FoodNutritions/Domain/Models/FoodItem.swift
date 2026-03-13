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

    // Convenience getters for UI and mapping
    var calories: Double { caloriesPer100g }
    var protein: Double { proteinPer100g }
    var carbs: Double { carbsPer100g }
    var fat: Double { fatPer100g }
    
    var fiber: Double? {
        micronutrients.first { $0.name.lowercased() == "fiber" }?.value
    }
    
    var sodiumMg: Double? {
        micronutrients.first { $0.name.lowercased() == "sodium" }?.value
    }
}
