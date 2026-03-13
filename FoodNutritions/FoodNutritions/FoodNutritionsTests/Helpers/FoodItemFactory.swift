import Foundation
@testable import FoodNutritions

enum FoodItemFactory {
    static func makeFoodSearchResult(
        id: Int = 1,
        name: String = "Test Food",
        type: String = "recipe",
        calories100g: Double = 200,
        protein100g: Double = 10,
        carbs100g: Double = 20,
        fat100g: Double = 8,
        proteinDensity: Double = 0.05
    ) -> FoodSearchResult {
        FoodSearchResult(
            id: id,
            name: name,
            type: type,
            calories100g: calories100g,
            protein100g: protein100g,
            carbs100g: carbs100g,
            fat100g: fat100g,
            proteinDensity: proteinDensity,
            rank: nil
        )
    }

    static func makeFoodItem(
        id: Int = 1,
        name: String = "Test Food",
        type: FoodType = .recipe,
        caloriesPer100g: Double = 200,
        proteinPer100g: Double = 10,
        carbsPer100g: Double = 20,
        fatPer100g: Double = 8
    ) -> FoodItem {
        FoodItem(
            id: id,
            name: name,
            type: type,
            caloriesPer100g: caloriesPer100g,
            proteinPer100g: proteinPer100g,
            carbsPer100g: carbsPer100g,
            fatPer100g: fatPer100g,
            proteinDensity: 0.05,
            micronutrients: [],
            servingUnits: FoodAPIMapper.synthesiseServingUnits()
        )
    }

    static func makeNutritionResponse(
        itemId: Int = 1,
        itemType: String = "recipe",
        name: String = "Test Food",
        grams: Double = 100,
        calories: Double = 200,
        protein: Double = 10,
        carbs: Double = 20,
        fat: Double = 8,
        fiber: Double? = 2.5,
        sodiumMg: Double? = 150
    ) -> NutritionResponse {
        NutritionResponse(
            itemId: itemId,
            itemType: itemType,
            name: name,
            grams: grams,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            fiber: fiber,
            sodiumMg: sodiumMg
        )
    }

    static func makeMealRecord(
        date: Date = Date(),
        mealType: MealType = .lunch
    ) -> MealRecord {
        MealRecord(date: date, mealType: mealType)
    }

    static func makeMealItem(
        apiItemId: Int = 1,
        foodName: String = "Test Food",
        servingGrams: Double = 100,
        calories: Double = 200,
        protein: Double = 10,
        carbs: Double = 20,
        fat: Double = 8
    ) -> MealItem {
        MealItem(
            apiItemId: apiItemId,
            apiItemType: "recipe",
            foodName: foodName,
            servingGrams: servingGrams,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat
        )
    }
}
