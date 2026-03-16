import Foundation
import Observation

@Observable
final class MealLogProcessor {
    private(set) var state: MealLogState

    private let mealRepository: MealRepositoryProtocol
    private let foodRepository: FoodRepositoryProtocol

    init(state: MealLogState,
         mealRepository: MealRepositoryProtocol,
         foodRepository: FoodRepositoryProtocol) {
        self.state = state
        self.mealRepository = mealRepository
        self.foodRepository = foodRepository
    }

    func send(_ intent: MealLogIntent) {
        switch intent {
        case .addItem(let item):
            state.items.append(item)
            updateTotals()

        case .removeItem(let id):
            state.items.removeAll { $0.id == id }
            updateTotals()

        case .mealTypeChanged(let type):
            state.selectedMealType = type

        case .saveMeal:
            Task { await saveMeal() }

        case .loadMealForEditing(let record):
            loadMealForEditing(record)

        case .resetForNewMeal:
            resetState()

        case .resetNavigation:
            state.shouldNavigateBack = false

        case .dismissError:
            state.errorMessage = nil
        }
    }

    private func loadMealForEditing(_ record: MealRecord) {
        state.isEditMode = true
        state.editingMealRecord = record
        state.selectedMealType = MealType(rawValue: record.mealType) ?? .lunch
        state.items = record.items
        updateTotals()
    }

    private func updateTotals() {
        state.totals = DailySummary.from(items: state.items)
    }

    @MainActor
    private func saveMeal() async {
        guard !state.items.isEmpty else {
            state.errorMessage = "Add at least one item to save the meal."
            return
        }

        state.isSaving = true
        state.errorMessage = nil

        // FUNC-05: bulkNutrition is best-effort — failures fall back to locally-computed values
        for item in state.items {
            let request = MealItemRequest(itemType: item.apiItemType, itemId: item.apiItemId, grams: item.servingGrams)
            do {
                let response = try await foodRepository.bulkNutrition(items: [request])
                item.calories = response.calories
                item.protein = response.protein
                item.carbs = response.carbs
                item.fat = response.fat
                item.fiber = response.fiber
                item.sodiumMg = response.sodiumMg
            } catch {
                // Network unavailable or server error — keep locally-computed values and continue
            }
        }

        do {
            if state.isEditMode, let record = state.editingMealRecord {
                record.mealType = state.selectedMealType.rawValue
                record.items = state.items
                for item in record.items {
                    item.meal = record
                }
                try await mealRepository.updateMeal(record)
            } else {
                let record = MealRecord(date: Date(), mealType: state.selectedMealType)
                record.items = state.items
                for item in record.items {
                    item.meal = record
                }
                try await mealRepository.saveMeal(record)
            }

            // FUNC-03: notify Dashboard to reload
            NotificationCenter.default.post(name: .mealDidSave, object: nil)

            state.shouldNavigateBack = true
            resetState()
        } catch {
            state.errorMessage = "Failed to save meal: \(error.localizedDescription)"
        }

        state.isSaving = false
    }

    private func resetState() {
        state.items = []
        state.isEditMode = false
        state.editingMealRecord = nil
        state.errorMessage = nil
        updateTotals()
    }
}
