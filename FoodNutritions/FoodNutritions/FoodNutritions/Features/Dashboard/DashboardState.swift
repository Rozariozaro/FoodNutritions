import Foundation

struct DashboardState {
    var todayMeals: [MealRecord] = []
    var summary: DailySummary = DailySummary(calories: 0, protein: 0, carbs: 0, fat: 0)
    var isLoading: Bool = false
    var errorMessage: String?
    // Navigation triggers
    var navigateToSearch: Bool = false
    var navigateToHistory: Bool = false
    var mealToEdit: MealRecord? = nil
}
