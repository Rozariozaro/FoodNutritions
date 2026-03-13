import Foundation
import SwiftData

@Model
final class MealItem {
    @Attribute(.unique) var id: UUID = UUID()
    var apiItemId: Int
    var apiItemType: String
    var foodName: String
    var servingGrams: Double
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var fiber: Double?
    var sodiumMg: Double?
    var meal: MealRecord?

    init(apiItemId: Int, apiItemType: String, foodName: String,
         servingGrams: Double, calories: Double, protein: Double,
         carbs: Double, fat: Double, fiber: Double? = nil, sodiumMg: Double? = nil) {
        self.apiItemId = apiItemId
        self.apiItemType = apiItemType
        self.foodName = foodName
        self.servingGrams = max(servingGrams, 0.1)
        self.calories = max(calories, 0)
        self.protein = max(protein, 0)
        self.carbs = max(carbs, 0)
        self.fat = max(fat, 0)
        self.fiber = fiber
        self.sodiumMg = sodiumMg
    }
}
