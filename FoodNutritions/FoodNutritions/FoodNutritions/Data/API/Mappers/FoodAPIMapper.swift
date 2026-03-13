import Foundation

enum FoodAPIMapper {
    static func foodItem(from result: FoodSearchResult) -> FoodItem {
        let type = FoodType(rawValue: result.type) ?? .recipe
        let servingUnits = synthesiseServingUnits()
        return FoodItem(
            id: result.id,
            name: result.name,
            type: type,
            caloriesPer100g: result.calories100g,
            proteinPer100g: result.protein100g,
            carbsPer100g: result.carbs100g,
            fatPer100g: result.fat100g,
            proteinDensity: result.proteinDensity,
            micronutrients: [],
            servingUnits: servingUnits
        )
    }

    static func micronutrients(from response: NutritionResponse) -> [Micronutrient] {
        var result: [Micronutrient] = []
        if let fiber = response.fiber {
            result.append(Micronutrient(name: "Fiber", value: fiber, unit: "g"))
        }
        if let sodium = response.sodiumMg {
            result.append(Micronutrient(name: "Sodium", value: sodium, unit: "mg"))
        }
        return result
    }

    static func synthesiseServingUnits() -> [ServingUnit] {
        [
            ServingUnit(name: "100g",   gramEquivalent: 100),
            ServingUnit(name: "50g",    gramEquivalent: 50),
            ServingUnit(name: "200g",   gramEquivalent: 200),
            ServingUnit(name: "Custom", gramEquivalent: 0)
        ]
    }
}
