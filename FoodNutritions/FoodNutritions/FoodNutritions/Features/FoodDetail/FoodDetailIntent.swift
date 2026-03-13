import Foundation

enum FoodDetailIntent {
    case servingUnitChanged(ServingUnit)
    case quantityChanged(Double)
    case toggleMicronutrients
    case addToMeal
}
