import Foundation

struct HistoryState {
    var availableDates: [Date] = []
    var selectedDate: Date = Date()
    var meals: [MealRecord] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
}
