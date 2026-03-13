import Foundation

struct MealLogState {
    var items: [MealItem] = []
    var selectedMealType: MealType = .lunch
    var isSaving: Bool = false
    var errorMessage: String?
    var totals: DailySummary = DailySummary(
        calories: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
        fiber: 0,
        sodiumMg: 0
    )
    
    // Edit Mode properties
    var isEditMode: Bool = false
    var editingMealRecord: MealRecord? = nil
    
    // Flag to handle navigation back after successful save
    var shouldNavigateBack: Bool = false
}
