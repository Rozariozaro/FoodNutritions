import Foundation

struct SearchState {
    var query: String = ""
    var autocompleteSuggestions: [AutocompleteSuggestion] = []
    var searchResults: [FoodItem] = []
    var filters: SearchFilters = SearchFilters()
    var sortOption: SortOption = .relevance
    var recentSearches: [String] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil

    enum SortOption: String, CaseIterable, Identifiable {
        case relevance = "Relevance"
        case name = "Name"
        case calories = "Calories"
        case proteinDensity = "Protein Density"

        var id: String { rawValue }
    }
}
