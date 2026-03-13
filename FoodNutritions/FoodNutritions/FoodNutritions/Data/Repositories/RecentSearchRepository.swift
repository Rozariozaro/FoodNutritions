import Foundation

protocol RecentSearchRepositoryProtocol {
    func loadRecentSearches() -> [String]
    func saveSearch(_ query: String)
    func clearAll()
}

final class UserDefaultsRecentSearchRepository: RecentSearchRepositoryProtocol {
    private let key = "recentSearchQueries"
    private let maxEntries = 5

    func loadRecentSearches() -> [String] {
        UserDefaults.standard.stringArray(forKey: key) ?? []
    }

    func saveSearch(_ query: String) {
        var searches = loadRecentSearches()
        searches.removeAll { $0 == query }
        searches.insert(query, at: 0)
        if searches.count > maxEntries {
            searches = Array(searches.prefix(maxEntries))
        }
        UserDefaults.standard.set(searches, forKey: key)
    }

    func clearAll() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
