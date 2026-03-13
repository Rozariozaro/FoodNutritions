import Foundation

enum MealLogIntent {
    case addItem(MealItem)
    case removeItem(UUID)
    case mealTypeChanged(MealType)
    case saveMeal
    case loadMealForEditing(MealRecord)
    case resetNavigation
    case dismissError
}
