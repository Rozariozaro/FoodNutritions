import Foundation

struct FoodDetailState {
    var foodItem: FoodItem
    var selectedServingUnit: ServingUnit
    var quantity: Double
    var isMicronutrientsVisible: Bool = false
    var isLoadingMicros: Bool = false
    var errorMessage: String? = nil

    init(foodItem: FoodItem) {
        self.foodItem = foodItem
        // Default to first serving unit if available, otherwise 100g
        self.selectedServingUnit = foodItem.servingUnits.first ?? ServingUnit(name: "100g", gramEquivalent: 100.0)
        // Default quantity 100 for grams, or 1 for other units
        self.quantity = selectedServingUnit.name.lowercased().contains("g") ? selectedServingUnit.gramEquivalent : 1.0
    }

    /// Computed nutrition based on current quantity and serving unit
    struct NutritionContext {
        let calories: Double
        let protein: Double
        let carbs: Double
        let fat: Double
        let micronutrients: [Micronutrient]
    }

    /// Total grams for the current quantity + unit selection.
    /// When the "Custom" unit is selected (gramEquivalent == 0), the user enters grams directly as `quantity`.
    var effectiveGrams: Double {
        selectedServingUnit.gramEquivalent == 0 ? quantity : quantity * selectedServingUnit.gramEquivalent
    }

    var nutritionContext: NutritionContext {
        let ratio = effectiveGrams / 100.0

        return NutritionContext(
            calories: foodItem.caloriesPer100g * ratio,
            protein: foodItem.proteinPer100g * ratio,
            carbs: foodItem.carbsPer100g * ratio,
            fat: foodItem.fatPer100g * ratio,
            micronutrients: foodItem.micronutrients.map { micro in
                Micronutrient(name: micro.name, value: micro.value * ratio, unit: micro.unit)
            }
        )
    }
}
