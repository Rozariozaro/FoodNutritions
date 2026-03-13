import Foundation
@testable import FoodNutritions

final class MockRecentSearchRepository: RecentSearchRepositoryProtocol {
    var searches: [String] = []

    func loadRecentSearches() -> [String] {
        searches
    }

    func saveSearch(_ query: String) {
        searches.removeAll { $0 == query }
        searches.insert(query, at: 0)
        if searches.count > 5 {
            searches = Array(searches.prefix(5))
        }
    }

    func clearAll() {
        searches = []
    }
}
