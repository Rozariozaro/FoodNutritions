import Foundation

protocol FoodRepositoryProtocol {
    func searchFoods(query: String, limit: Int, filters: SearchFilters) async throws -> [FoodItem]
    func autocomplete(query: String, limit: Int) async throws -> [AutocompleteSuggestion]
    func bulkNutrition(items: [MealItemRequest]) async throws -> NutritionResponse
}

final class FoodRepository: FoodRepositoryProtocol {
    private let client: FoodAPIClientProtocol
    private var cache: [String: CacheEntry] = [:]
    private let cacheTTL: TimeInterval = 24 * 60 * 60

    struct CacheEntry {
        let results: [FoodItem]
        let timestamp: Date
    }

    init(client: FoodAPIClientProtocol) {
        self.client = client
    }

    func searchFoods(query: String, limit: Int = 20, filters: SearchFilters) async throws -> [FoodItem] {
        let cacheKey = "\(query)|\(filters.proteinMin)|\(filters.caloriesMax)|\(filters.carbsMax)"

        if let entry = cache[cacheKey], Date().timeIntervalSince(entry.timestamp) < cacheTTL {
            return entry.results
        }

        do {
            let dtos = try await client.searchFoods(query: query, limit: limit, filters: filters)
            let items = dtos.map { FoodAPIMapper.foodItem(from: $0) }
            cache[cacheKey] = CacheEntry(results: items, timestamp: Date())
            return items
        } catch FoodError.networkUnavailable {
            if let entry = cache[cacheKey] {
                return entry.results
            }
            throw FoodError.offlineNoCache
        } catch {
            if let entry = cache[cacheKey], Date().timeIntervalSince(entry.timestamp) < cacheTTL {
                return entry.results
            }
            throw error
        }
    }

    func autocomplete(query: String, limit: Int = 10) async throws -> [AutocompleteSuggestion] {
        try await client.autocomplete(query: query, limit: limit)
    }

    func bulkNutrition(items: [MealItemRequest]) async throws -> NutritionResponse {
        try await client.bulkNutrition(items: items)
    }
}
