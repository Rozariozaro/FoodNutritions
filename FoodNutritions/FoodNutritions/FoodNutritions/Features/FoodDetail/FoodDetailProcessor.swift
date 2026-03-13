import Foundation
import Observation

@Observable
final class FoodDetailProcessor {
    private(set) var state: FoodDetailState

    private let foodRepository: FoodRepositoryProtocol

    init(state: FoodDetailState, foodRepository: FoodRepositoryProtocol) {
        self.state = state
        self.foodRepository = foodRepository
    }

    func send(_ intent: FoodDetailIntent) {
        switch intent {
        case .servingUnitChanged(let unit):
            state.selectedServingUnit = unit
            // Custom unit (gramEquivalent==0): quantity is entered directly as grams, default to 100g
            if unit.gramEquivalent == 0 {
                state.quantity = 100.0
            } else if unit.name.lowercased().contains("g") {
                state.quantity = unit.gramEquivalent
            } else {
                state.quantity = 1.0
            }
            state.errorMessage = nil

        case .quantityChanged(let quantity):
            if quantity <= 0 {
                state.errorMessage = "Quantity must be greater than 0"
            } else {
                state.quantity = quantity
                state.errorMessage = nil
            }

        case .toggleMicronutrients:
            state.isMicronutrientsVisible.toggle()
            if state.isMicronutrientsVisible {
                Task { await fetchServerConfirmedNutrition() }
            }

        case .addToMeal:
            // This will be handled by navigation/coordinator or a parent processor in Phase 5
            break
        }
    }

    @MainActor
    private func fetchServerConfirmedNutrition() async {
        guard state.errorMessage == nil else { return }
        
        state.isLoadingMicros = true
        state.errorMessage = nil
        
        do {
            let request = MealItemRequest(
                itemType: state.foodItem.type.rawValue,
                itemId: state.foodItem.id,
                grams: state.effectiveGrams
            )
            
            let response = try await foodRepository.bulkNutrition(items: [request])
            
            // Update micronutrients from response
            var micros: [Micronutrient] = []
            if let fiber = response.fiber {
                micros.append(Micronutrient(name: "Fiber", value: fiber, unit: "g"))
            }
            if let sodium = response.sodiumMg {
                micros.append(Micronutrient(name: "Sodium", value: sodium, unit: "mg"))
            }
            
            state.foodItem.micronutrients = micros
        } catch {
            state.errorMessage = "Failed to fetch detailed nutrition: \(error.localizedDescription)"
        }
        
        state.isLoadingMicros = false
    }
}
