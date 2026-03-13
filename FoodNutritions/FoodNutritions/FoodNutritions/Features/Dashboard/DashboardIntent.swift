import Foundation

enum DashboardIntent {
    case loadData
    case deleteMeal(UUID)
    case dismissError
    case navigateToSearch
    case navigateToHistory
    case navigateToEditMeal(MealRecord)
}
