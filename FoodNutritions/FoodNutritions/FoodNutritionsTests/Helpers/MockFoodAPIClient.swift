import Foundation
@testable import FoodNutritions

final class MockFoodAPIClient: FoodAPIClientProtocol {
    var searchResult: [FoodSearchResult] = []
    var autocompleteResult: [AutocompleteSuggestion] = []
    var bulkNutritionResult: NutritionResponse?
    var errorToThrow: Error?

    var searchCallCount = 0
    var autocompleteCallCount = 0
    var bulkNutritionCallCount = 0
    var lastBulkItems: [MealItemRequest] = []

    func searchFoods(query: String, limit: Int, filters: SearchFilters) async throws -> [FoodSearchResult] {
        searchCallCount += 1
        if let error = errorToThrow { throw error }
        return searchResult
    }

    func autocomplete(query: String, limit: Int) async throws -> [AutocompleteSuggestion] {
        autocompleteCallCount += 1
        if let error = errorToThrow { throw error }
        return autocompleteResult
    }

    func bulkNutrition(items: [MealItemRequest]) async throws -> NutritionResponse {
        bulkNutritionCallCount += 1
        lastBulkItems = items
        if let error = errorToThrow { throw error }
        guard let result = bulkNutritionResult else { throw FoodError.invalidResponse }
        return result
    }
}
